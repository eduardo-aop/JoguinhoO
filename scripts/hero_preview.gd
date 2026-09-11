class_name RiftHeroPreview
extends SubViewportContainer
var viewport: SubViewport
var stage: Node3D
var model: Node3D
var current_hero := ""

func _ready() -> void:
	stretch = true
	custom_minimum_size = Vector2(165,175)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	viewport = SubViewport.new()
	viewport.size = Vector2i(330,350)
	viewport.own_world_3d = true
	viewport.transparent_bg = true
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(viewport)
	stage = Node3D.new()
	viewport.add_child(stage)
	var environment := WorldEnvironment.new()
	var settings := Environment.new()
	settings.background_mode = Environment.BG_COLOR
	settings.background_color = Color(.03,.05,.06,0)
	settings.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	settings.ambient_light_color = Color("c9d6e2")
	settings.ambient_light_energy = .75
	environment.environment = settings
	stage.add_child(environment)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-40,-30,0)
	light.light_energy = 1.2
	light.light_color = Color("fff0d4")
	stage.add_child(light)
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.position = Vector3(2.4,1.75,-4.1)
	camera.fov = 35
	camera.look_at(Vector3(0,1.15,0))
	camera.current = true

func show_hero(hero: String) -> void:
	if hero == current_hero: return
	current_hero = hero
	if is_instance_valid(model):
		stage.remove_child(model)
		model.queue_free()
	model = load("res://assets/%s_animated.glb" % hero).instantiate()
	stage.add_child(model)
	for mesh in model.find_children("*","MeshInstance3D",true,false):
		for surface in mesh.mesh.get_surface_count():
			var imported_material = mesh.get_active_material(surface)
			if imported_material is StandardMaterial3D:
				var cloth: bool = "cloth" in imported_material.resource_name.to_lower()
				mesh.set_surface_override_material(surface,RiftAppearance.painted_material(imported_material,cloth,0))
	var skeleton: Skeleton3D = model.find_children("*","Skeleton3D",true,false)[0]
	RiftAppearance.attach_to_bone(RiftAppearance.weapon(model,hero),skeleton,"hand_r")
	if hero == "warrior":
		RiftAppearance.attach_to_bone(RiftAppearance.shield(model,0),skeleton,"hand_l")
	var player: AnimationPlayer = model.find_children("*","AnimationPlayer",true,false)[0]
	for library_name in player.get_animation_library_list():
		var copy := player.get_animation_library(library_name).duplicate(true)
		player.remove_animation_library(library_name)
		player.add_animation_library(library_name,copy)
	player.get_animation("idle").loop_mode = Animation.LOOP_LINEAR
	player.play("idle")

func _process(_dt: float) -> void:
	var visible_now := is_visible_in_tree()
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS if visible_now else SubViewport.UPDATE_DISABLED
	viewport.process_mode = Node.PROCESS_MODE_INHERIT if visible_now else Node.PROCESS_MODE_DISABLED
