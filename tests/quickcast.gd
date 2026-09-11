extends SceneTree
var checks := 0
var failures := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func key(p: RiftFighter,code: Key,pressed: bool,echo: bool = false,preview: bool = false) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = pressed
	event.echo = echo
	event.shift_pressed = preview
	p._unhandled_input(event)
func run() -> void:
	var game: RiftArena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	for hero in ["warrior","mage"]:
		for slot in 4:
			game.start_round(hero,true,true)
			var p := game.player
			p.set_physics_process(false)
			game.rig.cursor_position = game.rig.camera.unproject_position(Vector3(0,0,0))
			if slot == 3: p.collect_rune(1,1)
			var code: Key = [KEY_Q,KEY_E,KEY_R,KEY_F][slot]
			key(p,code,true)
			check(p.abilities_used[slot] == 1 and p.preparing == -1,"press casts immediately %s/%d" % [hero,slot])
			key(p,code,true,true)
			key(p,code,false)
			check(p.abilities_used[slot] == 1,"echo and release do not recast %s/%d" % [hero,slot])
		game.start_round(hero,true,true)
		var p := game.player
		p.set_physics_process(false)
		key(p,KEY_R,true,false,true)
		p.update_indicator()
		check(p.preparing == 2 and p.aim_indicator.visible and p.cooldowns[2] == 0,"Shift R previews without casting "+hero)
		key(p,KEY_R,false)
		check(p.preparing == -1 and p.abilities_used[2] == 0,"releasing preview never casts "+hero)
		game.hud.pause_game()
		key(p,KEY_Q,true)
		check(p.abilities_used[0] == 0,"pause blocks quickcast "+hero)
		game.hud.resume_game()
		p.collect_rune(1,0)
		p.hp = 100
		key(p,KEY_F,true)
		check(p.hp == 165 and p.active_rune == -1,"heal remains immediate "+hero)
	game.start_round("mage",true,true)
	game.player.position = Vector3(8,.01,11)
	game.rig.snap_to_actor()
	game.rig.cursor_position = game.rig.camera.unproject_position(Vector3(8,0,2))
	await physics_frame
	key(game.player,KEY_R,true)
	check(game.player.cooldowns[2] == 0 and game.player.abilities_used[2] == 0,"blocked ground quickcast preserves cooldown")
	game.player.cooldowns[0] = 3
	key(game.player,KEY_Q,true)
	check(game.hud.toast_message.contains("RECARGA"),"unavailable skill explains cooldown")
	game.player.active_rune = -1
	key(game.player,KEY_F,true)
	check(game.hud.toast_message.contains("SEM RUNA"),"empty rune slot explains why it cannot cast")
	var opponent := game.fighters[5]
	opponent.basic_pending = true
	opponent.aim_point = game.player.position+Vector3.UP*1.2
	opponent.update_indicator()
	check(opponent.path_indicator.visible,"enemy basic windup shows attack direction")
	opponent.basic_pending = false
	opponent.update_indicator()
	check(not opponent.path_indicator.visible,"enemy telegraph clears after windup")
	game.queue_free()
	await process_frame
	await process_frame
	print("QUICKCAST_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
