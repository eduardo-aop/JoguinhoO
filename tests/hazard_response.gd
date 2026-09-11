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
	game.start_round("mage",true)
	for f in game.fighters: f.set_physics_process(false)
	var bot := game.fighters[3]
	bot.position = Vector3(0,.01,0)
	game.player.position = Vector3(0,.01,6)
	await physics_frame
	var field := game.spawn_field(game.player,Vector3(.5,0,0))
	field.set_physics_process(false)
	var escape := bot.bot.hazard_escape()
	check(escape.length() > .9 and escape.x < 0,"bot exits hostile field outward")
	field.owner_fighter = bot
	check(bot.bot.hazard_escape().is_zero_approx(),"bot ignores friendly field")
	field.queue_free()
	await process_frame
	game.shoot(game.player,bot.position+Vector3.UP*1.2,12,false)
	var shot: RiftProjectile
	for e in game.effects.get_children():
		if e is RiftProjectile: shot = e
	shot.set_physics_process(false)
	shot.position = Vector3(0,1.2,5)
	shot.direction = Vector3.FORWARD
	check(absf(bot.bot.hazard_escape().x) > .9,"bot sidesteps incoming projectile")
	shot.direction = Vector3.BACK
	check(bot.bot.hazard_escape().is_zero_approx(),"bot ignores projectile traveling away")
	shot.direction = Vector3.FORWARD
	shot.owner_fighter = bot
	check(bot.bot.hazard_escape().is_zero_approx(),"bot ignores friendly projectile")
	shot.owner_fighter = game.player
	shot.position.x = 3
	check(bot.bot.hazard_escape().is_zero_approx(),"bot ignores projectile missing its path")
	Input.action_press("move_right")
	var p := game.player
	var initial := p.position
	var key := InputEventKey.new()
	key.physical_keycode = KEY_SPACE
	key.pressed = true
	p._unhandled_input(key)
	check(p.position.x > initial.x+5 and absf(p.position.z-initial.z) < .1,"blink reads movement on key press without waiting for physics")
	Input.action_release("move_right")
	game.start_round("mage",true)
	for f in game.fighters: f.set_physics_process(false)
	var dodger := game.fighters[3]
	dodger.position = Vector3(0,.01,0)
	game.player.position = Vector3(0,.01,7)
	dodger.bot.target = game.player
	dodger.bot.timer = 999
	dodger.bot.threat_clock = 0
	game.shoot(game.player,dodger.position+Vector3.UP*1.2,12,false)
	dodger.set_physics_process(true)
	for i in 30: await physics_frame
	dodger.set_physics_process(false)
	check(dodger.hp == dodger.max_hp and absf(dodger.position.x) > .5,"bot physically sidesteps a real projectile without damage")
	game.start_round("mage",true,true)
	game.moving_targets = true
	game.elapsed = .5
	game.update_practice_targets()
	var target := game.fighters[3]
	check(target.velocity.length() > .1 and absf(target.position.x+4) <= 1.2,"moving practice targets stay in their lane")
	var spot := target.position
	game.moving_targets = false
	game.elapsed = 1.5
	game.update_practice_targets()
	check(target.position == spot and target.velocity.is_zero_approx(),"disabling target movement stops immediately")
	game.hud.pause_game()
	check(game.hud.moving_targets_option.visible,"practice motion can be changed from pause")
	game.hud.resume_game()
	game.start_round("mage",true)
	game.hud.pause_game()
	check(not game.hud.moving_targets_option.visible,"practice controls stay out of live arena pause")
	game.hud.resume_game()
	game.queue_free()
	await process_frame
	await process_frame
	print("HAZARD_RESPONSE_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
