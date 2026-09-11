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
	for hero in ["warrior","mage"]:
		game.start_round(hero,true,true)
		await frames(3)
		var p := game.player
		p.set_physics_process(false)
		check(game.practice_mode and game.active,"practice starts immediately "+hero)
		check(game.fighters.filter(func(f): return not f.human).all(func(f): return not f.is_physics_processing()),"practice opponents stay still "+hero)
		var dummy := game.fighters[3]
		dummy.take_damage(30,p,p.position)
		check(dummy.hp == dummy.max_hp-30 and dummy.hp_bar.scale.x < 1,"practice dummy displays damage "+hero)
		dummy.take_damage(10000,p,p.position)
		check(dummy.alive and dummy.hp == dummy.max_hp and p.eliminations == 0,"practice target restores without scoring an elimination "+hero)
		game.elapsed = 170
		game._physics_process(.1)
		check(game.active and game.zone_half == RiftRules.MAP_HALF,"practice has no time limit or zone "+hero)
		p.update_indicator()
		check(p.path_indicator.visible,"idle player has visible attack range guide "+hero)
		Input.action_press("move_right")
		p.velocity = Vector3.ZERO
		for i in 6: p._physics_process(1.0/60)
		check(p.velocity.x > float(p.stats.speed)*.95,"movement reaches speed within 100 ms "+hero)
		Input.action_release("move_right")
		Input.action_press("move_left")
		for i in 8: p._physics_process(1.0/60)
		check(p.velocity.x < -float(p.stats.speed)*.95,"direction reversal responds within 134 ms "+hero)
		Input.action_release("move_left")
		var space := InputEventKey.new()
		space.physical_keycode = KEY_SPACE
		space.pressed = true
		p._unhandled_input(space)
		var slot := 0 if hero == "warrior" else 1
		check(p.cooldowns[slot] > 0,"space uses class mobility "+hero)
		var uses: int = p.abilities_used[slot]
		p._unhandled_input(space)
		check(p.abilities_used[slot] == uses,"space respects mobility cooldown "+hero)
		game.hud.pause_game()
		check(game.hud.selection_button.visible and not game.hud.practice_button.visible,"pause exposes mode switch "+hero)
		game.hud.selection_button.pressed.emit()
		check(not game.active and not paused and game.hud.launch.visible and game.hud.practice_button.visible,"mode switch restores full selection "+hero)
	game.start_round("warrior",true)
	check(not game.practice_mode and game.fighters.all(func(f): return f.is_physics_processing()),"regular arena restores bots after practice")
	game.queue_free()
	await frames(3)
	print("BRAWLER_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
