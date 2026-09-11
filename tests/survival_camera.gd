extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int) -> void:
	for i in n: await physics_frame
func run() -> void:
	var game: RiftArena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	game.start_round("mage",true,true)
	for f in game.fighters: f.set_physics_process(false)
	var rig := game.rig
	rig.set_physics_process(false)
	check(rig.current_distance <= game.settings.camera_distance,"camera validates collision on spawn")
	var p := game.player
	p.position = Vector3(0,.01,0)
	rig.yaw = 0
	rig.snap_to_actor()
	check(rig.camera.projection == Camera3D.PROJECTION_PERSPECTIVE,"perspective camera")
	check(rig.camera.global_position.y > p.position.y+2 and rig.camera.global_position.z > p.position.z+4,"camera is above and behind actor")
	var old_position := p.position
	rig.look(Vector2(150,-30))
	check(rig.yaw < 0 and rig.pitch > -.28 and p.position == old_position,"mouse turns view without moving actor")
	rig.look(Vector2(0,100000))
	check(is_equal_approx(rig.pitch,-1.05),"look down is clamped")
	rig.look(Vector2(0,-100000))
	check(is_equal_approx(rig.pitch,.45),"look up is clamped")
	check(not rig.cursor_ground().is_finite(),"looking at sky does not create a ground point")
	check(not p.ground_target(14).valid,"sky ground skill rejected")
	rig.yaw = PI/2
	check(rig.movement_direction(Vector2(0,-1)).is_equal_approx(Vector3.LEFT),"W follows camera yaw")
	check(rig.movement_direction(Vector2(1,1)).length() < 1.001,"diagonal input bounded")
	rig.yaw = 0
	rig.pitch = 0
	rig.snap_to_actor()
	await frames(3)
	var enemy := game.fighters[3]
	enemy.position = Vector3(0,1.1,-5)
	await frames(3)
	check(rig.aim_query().collider == enemy,"center ray targets visible enemy")
	var old_cursor := rig.cursor_position
	rig.cursor_position = Vector2.ZERO
	check(rig.aim_query().collider == enemy,"screen cursor cannot shift centered aim")
	rig.cursor_position = old_cursor
	var wall := TrainingVisuals.box(game,Vector3(4,5,.4),Vector3(0,2,2.5),Color.WHITE,true)
	await frames(3)
	rig.update_collision(1.0/60)
	check(rig.current_distance < 2.4,"camera retracts before wall")
	var close := rig.current_distance
	wall.queue_free()
	await frames(3)
	rig.update_collision(1.0/60)
	check(rig.current_distance > close and rig.current_distance < close+.1,"camera recovers smoothly after wall")
	for i in 120: rig.update_collision(1.0/60)
	check(rig.current_distance > 5.8,"camera restores normal distance")
	p.position.x = 2
	rig._physics_process(1.0/60)
	check(rig.position.x > 0 and rig.position.x < 2,"follow softens movement")
	game.hud.pause_game()
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE,"pause releases mouse")
	game.hud.resume_game()
	if DisplayServer.get_name() != "headless":
		check(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED,"resume captures mouse")
	game.cycle_spectator()
	check(rig.actor == game.spectator and rig.position.is_equal_approx(rig.follow_target()),"spectator repositions camera")
	game.queue_free()
	await frames(3)
	print("SURVIVAL_CAMERA_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
