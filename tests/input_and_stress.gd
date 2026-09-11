extends SceneTree
var failures := 0
var checks := 0
var arena: RiftArena
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool,description: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error("FAIL "+description)
	else:
		print("PASS ",description)
func frames(count: int) -> void:
	for i in count:
		await physics_frame
func key(code: Key,pressed: bool) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
func click(button: MouseButton,pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.position = root.get_visible_rect().size*.5
	event.pressed = pressed
	Input.parse_input_event(event)
func run() -> void:
	arena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(arena)
	arena.start_round("warrior")
	var initial_position := arena.player.position
	key(KEY_Q,true)
	click(MOUSE_BUTTON_LEFT,true)
	Input.action_press("move_forward")
	await frames(3)
	check(not arena.active and arena.player.position == initial_position and arena.player.attack_count == 0 and arena.player.preparing == -1,"countdown still blocks movement attacks and preparation")
	key(KEY_Q,false)
	click(MOUSE_BUTTON_LEFT,false)
	Input.action_release("move_forward")
	arena.start_round("warrior",true)
	for f in arena.fighters:
		f.set_physics_process(false)
	var player := arena.player
	await frames(3)
	key(KEY_Q,true)
	await frames(3)
	check(player.preparing == 0 and player.cooldowns[0] == 0,"Q key press only prepares")
	key(KEY_Q,false)
	await frames(3)
	check(player.preparing == -1 and player.cooldowns[0] == 7,"Q release executes once")
	player.ability_lock = 0
	key(KEY_R,true)
	await frames(3)
	check(player.preparing == 2,"R prepares before cancellation")
	click(MOUSE_BUTTON_RIGHT,true)
	await frames(3)
	key(KEY_R,false)
	await frames(3)
	check(player.cooldowns[2] == 0 and player.preparing == -1,"right click cancels and release does not execute")
	click(MOUSE_BUTTON_RIGHT,false)
	player.ability_lock = 0
	click(MOUSE_BUTTON_LEFT,true)
	await frames(60)
	check(player.attack_count == 1,"GUI mouse press produces one attack only")
	click(MOUSE_BUTTON_LEFT,false)
	player.basic_clock = 0
	player.basic_pending = false
	key(KEY_E,true)
	await frames(3)
	check(player.guard_time == 2.5,"guard is immediate on E press")
	key(KEY_E,false)
	key(KEY_ESCAPE,true)
	await frames(3)
	check(paused,"Esc pauses through input pipeline")
	key(KEY_ESCAPE,false)
	key(KEY_ESCAPE,true)
	await frames(3)
	check(not paused,"second Esc resumes through input pipeline")
	key(KEY_ESCAPE,false)
	# Maximum time is a safety rule even if every actor remains stationary.
	arena.elapsed = RiftRules.ROUND_LIMIT-.02
	await frames(5)
	check(not arena.active and arena.result != "","hard round limit always produces result")
	for run_index in 8:
		seed(1000+run_index)
		arena.start_round("warrior" if run_index%2 == 0 else "mage",true)
		arena.player.human = false
		for frame in 10100:
			await physics_frame
			if not arena.active:
				break
		check(not arena.active,"stress match %d terminates" % (run_index+1))
		check(arena.fighters.size() == 6,"stress restart maintains exactly six actors")
		print("STRESS_MATCH ",JSON.stringify(arena.round_stats.back()))
	print("INPUT_STRESS_COMPLETE checks=%d failures=%d" % [checks,failures])
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	arena.queue_free()
	await process_frame
	quit(1 if failures else 0)
