extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func run() -> void:
	var game: RiftArena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	game.start_round("mage",true,true)
	for f in game.fighters: f.set_physics_process(false)
	var rig := game.rig
	rig.set_physics_process(false)
	var initial := rig.yaw
	var motion := InputEventMouseMotion.new()
	motion.position = root.get_visible_rect().size*.5+Vector2(180,0)
	motion.screen_relative = Vector2(180,0)
	root.push_input(motion,true)
	check(rig.yaw == initial and rig.cursor_position == motion.position,"cursor stays free; camera does not snap on input")
	check(absf(angle_difference(initial,rig.return_yaw)) > .01 and absf(angle_difference(initial,rig.return_yaw)) <= deg_to_rad(25)+.001,"return samples aim with limited variation")
	var target := rig.return_yaw
	rig.update_orbit(1.0/60)
	check(absf(angle_difference(initial,rig.yaw)) > 0 and absf(angle_difference(initial,rig.yaw)) < absf(angle_difference(initial,target)),"camera eases toward character facing")
	for i in 180:
		game.player.refresh_cursor_aim()
		rig.update_orbit(1.0/60)
	check(absf(angle_difference(rig.yaw,target)) < .001,"camera settles behind sampled facing")
	var settled := rig.yaw
	for i in 300:
		game.player.refresh_cursor_aim()
		rig.update_orbit(1.0/60)
	check(absf(angle_difference(settled,rig.yaw)) < .001,"stationary cursor cannot cause endless orbit")
	check(rig.cursor_position == motion.position,"return does not warp or recenter cursor")
	rig.yaw = 0
	rig.return_yaw = .1
	rig.update_orbit(1.0/30)
	var one_step := rig.yaw
	rig.yaw = 0
	rig.update_orbit(1.0/60)
	rig.update_orbit(1.0/60)
	check(is_equal_approx(one_step,rig.yaw),"small-angle damping consistent across frame rates")
	rig.yaw = PI-.01
	rig.return_yaw = -PI+.02
	rig.update_orbit(1.0/60)
	check(absf(angle_difference(PI-.01,rig.yaw)) < .02,"return crosses angle wrap without a full turn")
	game.queue_free()
	await process_frame
	await process_frame
	print("CAMERA_RETURN_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
