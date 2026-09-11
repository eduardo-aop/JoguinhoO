extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int) -> void:
	for i in n: await physics_frame
func run() -> void:
	var game: RiftArena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	game.start_round("mage",true)
	for f in game.fighters: f.set_physics_process(false)
	var rig := game.rig
	rig.set_process(false)
	var p := game.player
	p.position = Vector3(0,0,0)
	rig.snap_to_actor()
	await frames(3)
	check(rig.camera.projection == Camera3D.PROJECTION_ORTHOGONAL,"elevated orthographic view")
	var original := rig.camera.global_transform
	p.rotation.y += PI
	check(rig.camera.global_transform.is_equal_approx(original),"character turning does not rotate camera")
	check(rig.movement_direction(Vector2(0,-1)).is_equal_approx(Vector3.FORWARD),"W moves toward top of screen regardless of facing")
	check(rig.movement_direction(Vector2.RIGHT).is_equal_approx(Vector3.RIGHT),"D strafes toward screen right")
	check(is_equal_approx(rig.movement_direction(Vector2(1,1)).length(),1),"diagonal movement capped")
	var center := root.get_visible_rect().size*.5
	var event := InputEventMouseMotion.new()
	event.position = center+Vector2(100,0)
	root.push_input(event,true)
	check(rig.cursor_position == event.position,"aim follows viewport input event coordinates")
	check(rig.aim_offset().x > 0 and rig.aim_offset().length() <= 3.0,"camera anticipates aim with bounded displacement")
	var saved_cursor := rig.cursor_position
	rig.cursor_position = center
	check(rig.aim_offset().is_zero_approx(),"centered cursor has no camera displacement")
	rig.cursor_position = saved_cursor
	var middle := rig.ground_at(center)
	check(rig.ground_at(center+Vector2(100,0)).x > middle.x,"cursor to right aims farther right")
	check(rig.ground_at(center-Vector2(0,100)).z < middle.z,"cursor upward aims farther into arena")
	var enemy: RiftFighter = game.fighters[3]
	enemy.position = Vector3(2,0,-2)
	await frames(3)
	var screen := rig.camera.unproject_position(enemy.global_position+Vector3.UP*1.2)
	check(rig.aim_at(screen).collider == enemy,"cursor selects enemy body")
	check(rig.aim_at(screen).position.is_equal_approx(enemy.global_position+Vector3.UP*1.2),"ranged aim targets enemy torso")
	var empty := rig.aim_at(rig.camera.unproject_position(Vector3(-3,0,2)))
	check(is_equal_approx(empty.position.y,p.global_position.y+1.2),"empty ground aim keeps projectiles above floor")
	var empty_screen := rig.camera.unproject_position(Vector3(-3,0,2))
	check(rig.camera.unproject_position(empty.position).distance_to(empty_screen) < .01,"ranged aim projects exactly onto the cursor")
	p.position.x = 6
	rig._process(1.0/60)
	check(rig.position.x > 0 and rig.position.x < rig.follow_target().x,"camera follows without snapping")
	var one_step := rig.position
	rig.position = Vector3.ZERO
	rig._process(1.0/120)
	rig._process(1.0/120)
	check(rig.position.is_equal_approx(one_step),"follow smoothing independent of render frame rate for fixed target")
	for i in 120: rig._process(1.0/60)
	check(rig.position.distance_to(rig.follow_target()) < .001,"camera settles without drift")
	game.hud.pause_game()
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE,"pause restores system pointer")
	game.hud.resume_game()
	if DisplayServer.get_name() != "headless":
		check(Input.mouse_mode == Input.MOUSE_MODE_HIDDEN,"game uses free custom cursor without capture")
	var settings := TrainingSettings.new()
	var path := "res://tests/.tactical-preferences.cfg"
	settings.camera_distance = 26
	settings.camera_follow_speed = 12
	check(settings.save_preferences(path) == OK,"save tactical preferences")
	var restored := TrainingSettings.new()
	restored.load_preferences(path)
	check(restored.camera_distance == 26 and restored.camera_follow_speed == 12,"restore field of view and follow speed")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	game.cycle_spectator()
	check(rig.get_parent() == game and rig.position.is_equal_approx(rig.follow_target()),"spectator keeps independent camera and snaps to ally")
	p.position = Vector3(-23,0,0)
	rig.snap_to_actor()
	check(rig.ground_at(Vector2.ZERO).x >= -24.01,"camera stays within arena at left edge")
	game.clear_round()
	game.queue_free()
	await frames(3)
	print("TACTICAL_CAMERA_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
