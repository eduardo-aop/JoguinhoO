extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int) -> void:
	for i in n: await physics_frame
func run() -> void:
	var game: RiftArena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	game.start_round("warrior",true)
	for f in game.fighters: f.set_physics_process(false)
	var p: RiftFighter = game.player
	p.basic_clock = .6
	p.take_damage(1,game.fighters[3],game.fighters[3].position)
	check(p.animator.tree.get("parameters/Motion/Hit/request") != AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE,"damage does not overwrite active attack animation")
	check(p.reaction_clock > 0,"damage feedback has a cooldown")
	p.basic_clock = 0
	p.take_damage(1,game.fighters[3],game.fighters[3].position)
	check(p.animator.tree.get("parameters/Motion/Hit/request") != AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE,"continuous damage cannot repeatedly restart reaction")
	p.animator.hurt()
	p.animator.strike()
	check(p.animator.tree.get("parameters/Motion/Hit/request") == AnimationNodeOneShot.ONE_SHOT_REQUEST_ABORT,"new attack interrupts previous hit reaction")
	p.guard_time = 2.5
	await frames(16)
	var right := p.animator.skeleton.find_bone("upper_arm_r")
	var pose := p.animator.skeleton.get_bone_pose_rotation(right)
	p.animator.strike()
	await frames(14)
	check(not pose.is_equal_approx(p.animator.skeleton.get_bone_pose_rotation(right)),"guard keeps right arm available for attack")
	for kind in ["slash","heal","teleport","shock","explosion"]:
		check(game.combat_fx(Vector3.ZERO,kind,Color.WHITE,1) != null,"effect created "+kind)
	for i in 80: game.combat_fx(Vector3.ZERO,"impact",Color.WHITE,1)
	check(get_nodes_in_group("transient_combat_fx").size() == 48,"transient effects have bounded count")
	await frames(60)
	check(get_nodes_in_group("transient_combat_fx").is_empty(),"transient effects expire completely")
	var field := game.spawn_field(p,Vector3.ZERO)
	check(field.crystals.size() == 10,"frost field has perimeter markers")
	for i in 310: await physics_frame
	check(not is_instance_valid(field),"frost field and crystals expire together")
	p.velocity = Vector3(4,0,0)
	await frames(15)
	check(p.animator.locomotion.length() > .4,"moving actor enters locomotion animation")
	p.guard_visual.show()
	p.attack_visual.show()
	game.finish(0,"animation test")
	check(not p.guard_visual.visible and not p.attack_visual.visible,"round end clears guard and attack overlays")
	await frames(45)
	check(p.animator.locomotion.length() < .001,"survivor returns to idle after round ends")
	game.combat_fx(Vector3.ZERO,"heal",Color.WHITE,1)
	game.start_round("mage",true)
	await frames(3)
	check(get_nodes_in_group("transient_combat_fx").is_empty(),"restart clears transient effects")
	game.queue_free()
	await frames(3)
	print("EFFECTS_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
