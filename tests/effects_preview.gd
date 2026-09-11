extends Node

func _ready() -> void:
	var arena: RiftArena = load("res://scenes/arena.tscn").instantiate()
	add_child(arena)
	arena.start_round("mage",true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for f in arena.fighters:
		f.set_physics_process(false)
	arena.player.position = Vector3(0,.01,5)
	arena.player.rotation.y = 0
	arena.fighters[3].position = Vector3(-2,.01,-4)
	arena.fighters[4].position = Vector3(3,.01,-4)
	for frame in 12:
		await get_tree().physics_frame
	var basic := arena.shoot(arena.player,Vector3(-2,1.2,-4),12,false)
	var orb := arena.shoot(arena.player,Vector3(3,1.2,-4),20,true)
	var field := arena.spawn_field(arena.fighters[4],Vector3(3,0,-4))
	for frame in 12:
		await get_tree().physics_frame
	basic.set_physics_process(false)
	orb.set_physics_process(false)
	field.set_physics_process(false)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://../v6-tatica-efeitos.png")
	arena.start_round("warrior",true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for f in arena.fighters:
		f.set_physics_process(false)
	arena.player.position = Vector3(0,.01,5)
	arena.player.rotation.y = 0
	arena.fighters[3].position = Vector3(0,.01,2.8)
	arena.player.set_physics_process(true)
	arena.player.request_basic()
	for frame in 18: await get_tree().physics_frame
	arena.player.set_physics_process(false)
	for fx in arena.effects.get_children(): fx.set_physics_process(false)
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://../v6-tatica-corte.png")
	print("EFFECTS_PREVIEW_COMPLETE")
