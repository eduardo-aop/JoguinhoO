extends SceneTree
var game: RiftArena
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int) -> void:
	for i in n: await physics_frame
func key(code: Key,pressed: bool) -> void:
	var actions := {KEY_A:"move_left",KEY_D:"move_right",KEY_W:"move_forward",KEY_S:"move_back"}
	if pressed: Input.action_press(actions[code])
	else: Input.action_release(actions[code])
func run() -> void:
	var path := "res://tests/.preferences-test.cfg"
	var settings := TrainingSettings.new()
	settings.camera_distance = 6.4
	settings.effects_volume = .25
	settings.camera_follow_speed = 12.0
	check(settings.save_preferences(path) == OK,"save preferences")
	var restored := TrainingSettings.new()
	check(restored.load_preferences(path) == OK and is_equal_approx(restored.camera_distance,6.4) and is_equal_approx(restored.effects_volume,.25) and is_equal_approx(restored.camera_follow_speed,12.0),"preferences survive a new settings instance")
	var config := ConfigFile.new()
	config.set_value("preferences","camera_distance",-10)
	config.set_value("preferences","effects_volume",4)
	config.set_value("preferences","camera_follow_speed","invalid")
	config.save(path)
	restored.load_preferences(path)
	check(restored.camera_distance == 3.5 and restored.effects_volume == 1,"out-of-range preferences clamped")
	check(is_equal_approx(restored.camera_follow_speed,12.0),"invalid preference type preserves last usable value")
	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	check(restored.load_preferences(path) == ERR_FILE_NOT_FOUND,"missing preferences file handled")
	game = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	await frames(3)
	check(game.hud.hero_preview.current_hero == "warrior","selection displays current hero preview")
	game.start_round("mage",true)
	for f in game.fighters: f.set_physics_process(false)
	await frames(3)
	check(game.hud.hero_preview.viewport.render_target_update_mode == SubViewport.UPDATE_DISABLED,"hero portrait stops rendering during gameplay")
	var p: RiftFighter = game.player
	p.position = Vector3(0,.01,0)
	p.rotation.y = 0
	await frames(4)
	key(KEY_D,true)
	p.velocity = Vector3.ZERO
	p._physics_process(1.0/60)
	var straight := Vector2(p.velocity.x,p.velocity.z).length()
	key(KEY_W,true)
	p.velocity = Vector3.ZERO
	p._physics_process(1.0/60)
	var diagonal := Vector2(p.velocity.x,p.velocity.z).length()
	check(straight > 0 and is_equal_approx(straight,diagonal),"diagonal and straight acceleration match")
	key(KEY_D,false)
	key(KEY_W,false)
	p.velocity = Vector3.ZERO
	game.rig.pitch = 0
	game.rig.snap_to_actor()
	game.rig.set_process(false)
	var camera: Camera3D = game.rig.camera
	var center := root.get_visible_rect().size*.5
	var origin := camera.project_ray_origin(center)
	var ray := camera.project_ray_normal(center)
	var ally: RiftFighter = game.fighters[0]
	var enemy: RiftFighter = game.fighters[3]
	ally.position = origin+ray*8-Vector3.UP*1.05
	enemy.position = origin+ray*12-Vector3.UP*1.05
	await frames(4)
	check(game.rig.aim_at(center).collider == enemy,"aim passes through ally to enemy")
	var wall := TrainingVisuals.box(game,Vector3(3,3,.3),origin+ray*10,Color.WHITE,true)
	await frames(4)
	check(game.rig.aim_at(center).collider != enemy,"wall still blocks aim")
	wall.queue_free()
	Input.action_press("move_forward")
	game.hud.pause_game()
	check(not Input.is_action_pressed("move_forward"),"pause releases movement action")
	var saved_volume := game.settings.effects_volume
	game.settings.effects_volume = 0
	check(AudioServer.is_bus_mute(game.sound.bus_index) and game.sound.voices.all(func(voice): return voice.bus == RiftSound.BUS_NAME),"muting in pause affects the bus of all existing voices")
	game.settings.effects_volume = .25
	check(not AudioServer.is_bus_mute(game.sound.bus_index) and is_equal_approx(AudioServer.get_bus_volume_db(game.sound.bus_index),linear_to_db(.25)),"volume change unmutes and adjusts existing audio while paused")
	game.settings.effects_volume = saved_volume
	game.hud.resume_game()
	check(not Input.is_action_pressed("move_forward"),"resume does not resurrect held movement")
	p.cooldowns[0] = float(p.stats.cooldowns[0])*.5
	game.hud._process(0)
	check(is_equal_approx(game.hud.skill_bars[1].value,.5),"skill bar shows half cooldown")
	p.preparing = 0
	game.hud._process(0)
	check(game.hud.skill_styles[1].border_color == Color("e5c781"),"prepared ability has distinct visual state")
	game.elapsed = 8
	game.next_runes = 10
	game.update_rune_warning()
	check(game.rune_markers[0].material_override.albedo_color == Color("ffe394"),"rune spawn warning is active before restart")
	game.start_round("warrior")
	check(game.rune_markers.all(func(marker): return marker.material_override.albedo_color == Color("918c68") and marker.scale == Vector3.ONE),"restart clears previous rune warning during countdown")
	game.clear_round()
	await frames(200)
	check(not game.active and game.actors.get_child_count() == 0 and game.countdown < 0,"clearing a countdown cannot reactivate an empty round")
	game.queue_free()
	await frames(3)
	print("CONTROL_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
