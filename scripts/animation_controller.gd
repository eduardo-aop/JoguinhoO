class_name RiftAnimation
extends Node
var actor: Node3D
var tree: AnimationTree
var skeleton: Skeleton3D
var playback: AnimationNodeStateMachinePlayback
var guard_blend := 0.0
var locomotion := Vector2.ZERO
var head_aim: RiftHeadAim
var head_pitch := 0.0

func clip(name_value: String) -> AnimationNodeAnimation:
	var node := AnimationNodeAnimation.new()
	node.animation = name_value
	return node

func upper_filter(node: AnimationNode) -> void:
	node.set_filter_enabled(true)
	for i in skeleton.get_bone_count():
		var bone := skeleton.get_bone_name(i)
		if bone in ["chest","head"] or "arm" in bone or "hand" in bone:
			node.set_filter_path(NodePath(str(actor.model.get_path_to(skeleton))+":"+bone),true)

func _ready() -> void:
	skeleton = actor.model.find_children("*","Skeleton3D",true,false)[0]
	head_aim = RiftHeadAim.new()
	skeleton.add_child(head_aim)
	skeleton.modifier_callback_mode_process = Skeleton3D.MODIFIER_CALLBACK_MODE_PROCESS_IDLE
	process_physics_priority = 1
	var player: AnimationPlayer = actor.model.find_children("*","AnimationPlayer",true,false)[0]
	# Imported resources may be shared. Duplicate before setting loop flags.
	for library_name in player.get_animation_library_list():
		var lib := player.get_animation_library(library_name).duplicate(true)
		player.remove_animation_library(library_name)
		player.add_animation_library(library_name,lib)
	for name_value in ["idle","forward","backward","left","right","guard"]:
		player.get_animation(name_value).loop_mode = Animation.LOOP_LINEAR
	var motion := AnimationNodeBlendTree.new()
	var locomotion_node := AnimationNodeBlendSpace2D.new()
	locomotion_node.add_blend_point(clip("idle"),Vector2.ZERO,-1,"idle")
	locomotion_node.add_blend_point(clip("forward"),Vector2(0,-1),-1,"forward")
	locomotion_node.add_blend_point(clip("backward"),Vector2(0,1),-1,"backward")
	locomotion_node.add_blend_point(clip("left"),Vector2(-1,0),-1,"left")
	locomotion_node.add_blend_point(clip("right"),Vector2(1,0),-1,"right")
	motion.add_node("Locomotion",locomotion_node)
	motion.add_node("AttackClip",clip("attack"))
	var attack := AnimationNodeOneShot.new()
	attack.fadein_time = .04
	attack.fadeout_time = .12
	upper_filter(attack)
	motion.add_node("Attack",attack)
	motion.connect_node("Attack",0,"Locomotion")
	motion.connect_node("Attack",1,"AttackClip")
	motion.add_node("GuardClip",clip("guard"))
	var guard := AnimationNodeBlend2.new()
	guard.set_filter_enabled(true)
	for bone in ["upper_arm_l","forearm_l","hand_l"]:
		guard.set_filter_path(NodePath(str(actor.model.get_path_to(skeleton))+":"+bone),true)
	motion.add_node("Guard",guard)
	motion.connect_node("Guard",0,"Attack")
	motion.connect_node("Guard",1,"GuardClip")
	motion.add_node("CastClip",clip("cast"))
	var cast_node := AnimationNodeOneShot.new()
	cast_node.fadein_time = .05
	cast_node.fadeout_time = .15
	upper_filter(cast_node)
	motion.add_node("Cast",cast_node)
	motion.connect_node("Cast",0,"Guard")
	motion.connect_node("Cast",1,"CastClip")
	motion.add_node("HitClip",clip("hit"))
	var hit := AnimationNodeOneShot.new()
	hit.fadein_time = .025
	hit.fadeout_time = .12
	upper_filter(hit)
	motion.add_node("Hit",hit)
	motion.connect_node("Hit",0,"Cast")
	motion.connect_node("Hit",1,"HitClip")
	motion.connect_node("output",0,"Hit")
	var machine := AnimationNodeStateMachine.new()
	machine.add_node("Motion",motion)
	machine.add_node("Death",clip("death"))
	var transition := AnimationNodeStateMachineTransition.new()
	transition.xfade_time = .08
	machine.add_transition("Motion","Death",transition)
	tree = AnimationTree.new()
	actor.model.add_child(tree)
	tree.anim_player = tree.get_path_to(player)
	tree.tree_root = machine
	tree.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS
	tree.active = true
	playback = tree.get("parameters/playback")
	playback.start("Motion")
	attach(actor.weapon_pivot,"hand_r")
	attach(actor.team_plate,"chest")
	if is_instance_valid(actor.shield_mesh):
		attach(actor.shield_mesh,"hand_l")

func attach(item: Node3D,bone: String) -> void:
	RiftAppearance.attach_to_bone(item,skeleton,bone)

func strike() -> void:
	tree.set("parameters/Motion/Hit/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	tree.set("parameters/Motion/Cast/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	tree.set("parameters/Motion/Attack/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func cast() -> void:
	tree.set("parameters/Motion/Hit/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT)
	tree.set("parameters/Motion/Cast/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func hurt() -> void:
	tree.set("parameters/Motion/Hit/request",AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func die() -> void:
	head_pitch = 0
	head_aim.pitch = 0
	for material in actor.cloth_materials:
		material.set_shader_parameter("motion_strength",0)
	playback.travel("Death")

func _physics_process(dt: float) -> void:
	if not actor.alive:
		return
	var relative: Vector3 = actor.global_basis.inverse()*actor.velocity if actor.arena.active else Vector3.ZERO
	var target := Vector2(relative.x,relative.z)/float(actor.stats.speed)
	locomotion = locomotion.lerp(target.limit_length(),1-exp(-14*dt))
	guard_blend = move_toward(guard_blend,1.0 if actor.guard_time > 0 and actor.arena.active else 0.0,dt*10)
	tree.set("parameters/Motion/Locomotion/blend_position",locomotion)
	tree.set("parameters/Motion/Guard/blend_amount",guard_blend)
	head_pitch = lerpf(head_pitch,0.0,1-exp(-12*dt))
	head_aim.pitch = head_pitch
	for material in actor.cloth_materials:
		material.set_shader_parameter("motion_strength",clampf(relative.length()/float(actor.stats.speed),0,1))
