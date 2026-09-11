extends Node
func frames(n: int) -> void:
	for i in n: await get_tree().physics_frame
func capture(path: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)
func _ready() -> void:
	var arena: RiftArena = load("res://scenes/arena.tscn").instantiate()
	add_child(arena)
	for hero in ["warrior","mage"]:
		arena.start_round(hero,true)
		arena.hud.hide()
		for f in arena.fighters: f.set_physics_process(false)
		var p: RiftFighter = arena.player
		p.position = Vector3(0,.01,0)
		p.rotation.y = 0
		var view := Camera3D.new()
		arena.add_child(view)
		view.position = Vector3(3.8,2.5,-3.4)
		view.look_at(Vector3(0,1.15,0))
		view.current = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		await frames(5)
		await capture("res://../v5-"+hero+"-idle.png")
		p.animator.strike()
		await frames(14 if hero == "warrior" else 9)
		await capture("res://../v5-"+hero+"-impact.png")
		await frames(45)
		view.queue_free()
	print("ATTACK_PREVIEW_COMPLETE")
