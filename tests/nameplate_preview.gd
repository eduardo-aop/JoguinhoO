extends Node

func _ready() -> void:
	var arena: RiftArena = load("res://scenes/arena.tscn").instantiate()
	add_child(arena)
	arena.start_round("warrior",true)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	for fighter in arena.fighters: fighter.set_physics_process(false)
	arena.player.position = Vector3(0,.01,7)
	arena.player.rotation.y = 0
	for i in 3:
		var fighter: RiftFighter = arena.fighters[i+3]
		fighter.position = Vector3((i-1)*3,.01,0)
		fighter.rotation.y = i*PI*.5
		fighter.caption.text = fighter.stats.name
		fighter.hp_bar.scale.x = .65
	for i in 20: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://../v5-barras-de-vida.png")
	print("NAMEPLATE_PREVIEW_COMPLETE")
