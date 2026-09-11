extends Node
func capture(path: String) -> void:
	for i in 20: await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://work"))
	var game: RiftArena = load("res://scenes/arena.tscn").instantiate()
	add_child(game)
	await capture("res://work/brawler-menu.png")
	game.start_round("mage",true,true)
	game.rig.cursor_position = game.rig.camera.unproject_position(Vector3(1,1.2,-2))
	await capture("res://work/brawler-training.png")
	game.hud.pause_game()
	await capture("res://work/brawler-pause.png")
	print("BRAWLER_PREVIEW_COMPLETE")
