extends Node

func _ready() -> void:
	var arena: RiftArena = load("res://scenes/arena.tscn").instantiate()
	add_child(arena)
	arena.start_round("warrior")
	for i in 8: await get_tree().process_frame
	var initial_yaw := arena.player.rotation.y
	var motion := InputEventMouseMotion.new()
	motion.relative = Vector2(70,12)
	motion.screen_relative = motion.relative
	Input.parse_input_event(motion)
	for i in 3: await get_tree().process_frame
	var passed := arena.countdown > 0 and not arena.active and arena.player.rotation.y != initial_yaw
	if not passed:
		push_error("Countdown look failed in graphical display")
	print("COUNTDOWN_LOOK_COMPLETE passed=",passed," mouse_mode=",Input.mouse_mode)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
