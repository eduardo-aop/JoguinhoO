extends Node
func capture(path: String) -> void:
	for frame in 8:
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var arena: RiftArena = load("res://scenes/arena.tscn").instantiate()
	add_child(arena)
	await capture("res://../v6-tatica-menu.png")
	arena.start_round("warrior",true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for f in arena.fighters:
		f.set_physics_process(false)
	arena.player.position = Vector3(0,.01,6)
	arena.player.rotation.y = 0
	arena.rig.snap_to_actor()
	arena.fighters[3].position = Vector3(0,.01,2)
	arena.fighters[4].position = Vector3(4,.01,-2)
	arena.spawn_runes()
	await capture("res://../v6-tatica-guerreiro.png")
	arena.start_round("mage",true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for f in arena.fighters:
		f.set_physics_process(false)
	arena.player.position = Vector3(0,.01,6)
	arena.player.rotation.y = 0
	arena.rig.snap_to_actor()
	arena.rig.snap_to_actor()
	arena.fighters[3].position = Vector3(0,.01,-1)
	arena.fighters[4].position = Vector3(5,.01,-3)
	arena.player.collect_rune(0,1)
	arena.player.collect_rune(1,1)
	arena.spawn_runes()
	arena.rig.cursor_position = arena.rig.camera.unproject_position(Vector3(0,0,-2))
	arena.player.aim_point = Vector3(0,0,-2)
	arena.player.preparing = 2
	arena.player.update_indicator()
	await capture("res://../v6-tatica-mago.png")
	arena.player.cancel_prepare()
	arena.spawn_field(arena.player,Vector3(0,0,-2))
	arena.elapsed = 119
	arena.update_zone(0)
	await capture("res://../v6-tatica-zona.png")
	for f in arena.fighters:
		if f.team == 1:
			f.take_damage(10000,arena.player,arena.player.position)
	await capture("res://../v6-tatica-resultado.png")
	print("FULL_PREVIEW_COMPLETE")
