extends Node

func settle() -> void:
	for i in 12: await get_tree().process_frame

func capture(path: String) -> void:
	await settle()
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(path)

func fits(control: Control) -> bool:
	return get_viewport().get_visible_rect().encloses(control.get_global_rect())

func _ready() -> void:
	var original_size := get_window().size
	var valid := true
	for dimensions in [Vector2i(1280,720),Vector2i(1024,768)]:
		get_window().size = dimensions
		var arena: RiftArena = load("res://scenes/arena.tscn").instantiate()
		add_child(arena)
		await settle()
		var menu_fits := fits(arena.hud.launch) and fits(arena.hud.hero_preview)
		valid = valid and menu_fits
		await capture("res://../v5-menu-%dx%d.png" % [dimensions.x,dimensions.y])
		arena.selected_hero = "mage"
		arena.hud.update_choice()
		await capture("res://../v5-menu-mago-%dx%d.png" % [dimensions.x,dimensions.y])
		arena.start_round("mage",true)
		for fighter in arena.fighters: fighter.set_physics_process(false)
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		await settle()
		var combat_fits := fits(arena.hud.combat_panel) and fits(arena.hud.minimap)
		valid = valid and combat_fits
		await capture("res://../v5-hud-%dx%d.png" % [dimensions.x,dimensions.y])
		print("LAYOUT ",dimensions," menu=",menu_fits," combat=",combat_fits)
		arena.queue_free()
		await settle()
	get_window().size = original_size
	print("LAYOUT_PREVIEW_COMPLETE passed=",valid)
	if not valid: push_error("A main control exceeded viewport bounds")
