extends SceneTree
var game: RiftArena
var p: RiftFighter
var enemy: RiftFighter
var checks := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(condition: bool,description: String) -> void:
	checks += 1
	if condition:
		print("PASS ",description)
	else:
		failures += 1
		push_error("FAIL "+description)
func frames(count: int) -> void:
	for i in count:
		await physics_frame
func setup(hero: String = "warrior") -> void:
	game.start_round(hero,true)
	for f in game.fighters:
		f.set_physics_process(false)
	p = game.player
	enemy = game.fighters[3]
	p.position = Vector3(0,.01,3)
	p.rotation.y = 0
	enemy.position = Vector3(0,.01,.5)
	p.aim_point = enemy.position+Vector3.UP*1.2
	game.rig.snap_to_actor()
	game.rig.set_process(false)
	var motion := InputEventMouseMotion.new()
	motion.position = game.rig.camera.unproject_position(p.aim_point)
	root.push_input(motion,true)
	await frames(3)
func unlock() -> void:
	p.ability_lock = 0
	p.basic_pending = false
	p.basic_clock = 0
	p.cooldowns = [0.0,0.0,0.0]
func run() -> void:
	seed(213)
	game = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	seed(213)
	check(not game.active and game.hud.overlay.visible,"initial hero selection")
	await setup()
	check(game.fighters.size() == 6 and game.living_counts() == [3,3],"exactly three fighters per team")
	check(game.fighters.filter(func(f): return f.human).size() == 1,"one human and five bots")
	check(game.player.hero == "warrior" and p.hp == 270,"warrior selectable with own stats")
	check(game.rig.camera.projection == Camera3D.PROJECTION_ORTHOGONAL,"tactical projection enabled")
	var old_position := p.position
	var camera_before := game.rig.camera.global_transform
	p.rotation.y = 1
	check(p.position == old_position and game.rig.camera.global_transform.is_equal_approx(camera_before),"turning actor leaves camera stable")
	p.rotation.y = 0
	check(p.can_melee(enemy),"melee arc reaches target ahead")
	p.rotation.y = PI
	check(not p.can_melee(enemy),"melee rejects target behind")
	p.rotation.y = 0
	check(p.request_basic(),"basic attack starts")
	check(not p.request_basic(),"basic attack obeys interval")
	p.set_physics_process(true)
	await frames(6)
	check(enemy.hp == enemy.max_hp,"melee windup before damage")
	await frames(100)
	p.set_physics_process(false)
	check(enemy.hp == enemy.max_hp-16 and p.attack_count == 1,"single click delivers one melee hit without repeat")
	p.position = Vector3(8,.01,10.4)
	enemy.position = Vector3(8,.01,8.5)
	await frames(3)
	check(not p.can_melee(enemy),"melee blocked by wall")
	await setup()
	p.guard_time = 2.5
	p.take_damage(40,enemy,p.position+Vector3.FORWARD)
	check(p.hp == 260,"guard blocks 75 percent from front")
	p.take_damage(40,enemy,p.position+Vector3.BACK)
	check(p.hp == 220,"guard does not block rear damage")
	p.guard_time = 0
	p.collect_rune(0,2)
	p.take_damage(40,enemy,enemy.position)
	check(is_equal_approx(p.hp,192),"aegis reduces damage 30 percent")
	var ally := game.fighters[0]
	p.take_damage(40,ally,ally.position)
	check(is_equal_approx(p.hp,192),"no friendly fire")
	await setup()
	check(p.begin_prepare(0) and p.cooldowns[0] == 0,"holding ability prepares without spending cooldown")
	check(not p.request_basic(),"basic attack blocked during preparation")
	p.cancel_prepare()
	check(p.preparing == -1 and p.cooldowns[0] == 0,"cancel preserves cooldown")
	enemy.position = Vector3(15,.01,15)
	check(p.cast(0),"warrior dash activates")
	old_position = p.position
	p.set_physics_process(true)
	await frames(20)
	p.set_physics_process(false)
	check(old_position.distance_to(p.position) > 5.5,"dash travels forward")
	await setup()
	p.position = Vector3(8,.01,11)
	enemy.position = Vector3(-15,.01,-15)
	p.cast(0)
	p.set_physics_process(true)
	await frames(20)
	p.set_physics_process(false)
	check(p.position.z > 9.8,"dash cannot cross cover")
	await setup()
	check(p.cast(2),"seismic ability activates")
	check(enemy.hp == enemy.max_hp-38 and enemy.slow_time > 0,"seismic applies damage and slow")
	check(p.cooldowns[2] == 20,"special has long cooldown")
	await setup("mage")
	check(p.hp == 200 and p.stats.range == 17,"mage selectable with different stats")
	var target_point := enemy.position+Vector3.UP*1.2
	game.shoot(p,target_point,12,false)
	await frames(15)
	check(enemy.hp == enemy.max_hp-12,"mage projectile hits enemy")
	var secondary := game.fighters[4]
	secondary.position = Vector3(1,.01,.5)
	await frames(3)
	p.cast(0)
	await frames(18)
	check(enemy.hp == enemy.max_hp-39 and secondary.hp == secondary.max_hp-27,"orb explosion damages each nearby enemy once")
	await setup("mage")
	p.position = Vector3(8,.01,11)
	enemy.position = Vector3(8,.01,3.5)
	p.aim_point = enemy.position+Vector3.UP*1.2
	await frames(3)
	game.shoot(p,p.aim_point,27,true)
	await frames(35)
	check(enemy.hp == enemy.max_hp,"cover blocks projectile and explosion through wall")
	p.move_axis_world = Vector3.FORWARD
	check(p.cast(1),"teleport activates")
	check(p.position.z > 9.8 and p.position.z < 11,"teleport stops at wall")
	await setup("mage")
	p.move_axis_world = Vector3.RIGHT
	old_position = p.position
	p.cast(1)
	check(p.position.x > old_position.x+5,"teleport follows movement rather than facing")
	unlock()
	p.move_axis_world = Vector3.ZERO
	old_position = p.position
	p.cast(1)
	check(p.position.z < old_position.z-5,"stationary teleport uses forward fallback")
	await setup("mage")
	p.human = false
	p.aim_point = Vector3(0,1,-30)
	var ground := p.ground_target(14)
	check(ground.valid and p.position.distance_to(ground.point) < 14.01,"ground cast clamps to maximum range")
	p.position = Vector3(8,.01,11)
	p.aim_point = Vector3(8,0,2)
	await frames(3)
	check(not p.ground_target(14).valid,"ground cast rejects target behind cover")
	check(not p.cast(2) and p.cooldowns[2] == 0,"invalid cast preserves cooldown")
	await setup("mage")
	var field := game.spawn_field(p,enemy.position)
	field.set_physics_process(false)
	for i in 150:
		field._physics_process(1.0/30.0)
	var damage_30 := enemy.max_hp-enemy.hp
	check(is_equal_approx(damage_30,50),"field deals configured damage over five seconds")
	check(enemy.slow_power == .35,"field applies slow")
	enemy.hp = enemy.max_hp
	var field2 := game.spawn_field(p,enemy.position)
	field2.set_physics_process(false)
	for i in 600:
		field2._physics_process(1.0/120.0)
	check(absf(enemy.max_hp-enemy.hp-damage_30) < .001,"field damage independent of update rate")
	enemy.apply_slow(.2,1)
	check(enemy.slow_power == .35,"slows do not multiply")
	await setup()
	p.collect_rune(0,0)
	p.collect_rune(1,0)
	check(p.passive == 0 and p.active_rune == 0,"passive and active rune coexist")
	p.collect_rune(0,1)
	check(p.passive == 1 and p.active_rune == 0,"passive replacement preserves active rune")
	p.collect_rune(1,1)
	check(p.passive == 1 and p.active_rune == 1,"active replacement preserves passive rune")
	check(p.cast(3) and p.active_rune == -1,"active shockwave consumes one use")
	check(not p.cast(3),"active rune cannot be reused")
	unlock()
	p.hp = 100
	p.collect_rune(1,0)
	p.cast(3)
	check(p.hp == 165,"healing rune restores health")
	p.passive_time = .01
	p.collect_rune(1,1)
	p.active_time = .01
	p.set_physics_process(true)
	await frames(3)
	p.set_physics_process(false)
	check(p.passive == -1 and p.active_rune == -1,"both rune categories expire")
	game.spawn_runes()
	check(game.runes.size() == 6,"all fixed rune locations populated")
	game.spawn_runes()
	check(game.runes.size() == 6,"occupied rune sites do not duplicate")
	p.position = game.runes[0].position
	await frames(4)
	check(game.runes.size() == 5 and p.passive >= 0,"rune picked by proximity exactly once")
	game.elapsed = game.next_runes-2
	game.update_rune_warning()
	check(game.rune_markers[0].material_override.albedo_color == Color("ffe394"),"empty rune site warns before spawn")
	await setup()
	p.collect_rune(0,0)
	p.collect_rune(1,0)
	p.cooldowns[0] = 5
	p.begin_prepare(2)
	game.hud.pause_game()
	var time := game.elapsed
	var passive_time := p.passive_time
	await frames(30)
	check(game.elapsed == time and p.passive_time == passive_time and p.cooldowns[0] == 5,"pause freezes round cooldowns and effects")
	check(p.preparing == -1 and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE,"pause cancels preparation and frees mouse")
	game.hud.resume_game()
	game.elapsed = 120
	p.position = Vector3(20,.01,0)
	enemy.position = Vector3(0,.01,0)
	var health := p.hp
	game.update_zone(1)
	check(p.hp < health and enemy.hp == enemy.max_hp,"zone damages outside only")
	check(game.zone_half.x < 24 and game.zone_visuals[0].visible,"zone contracts visibly")
	await setup()
	p.collect_rune(0,0)
	p.collect_rune(1,0)
	p.model.hide()
	p.take_damage(1000,enemy,enemy.position)
	check(not p.alive and p.passive == -1 and p.active_rune == -1,"death clears runes and eliminates player")
	check(game.spectator != null and game.spectator.alive and game.rig.actor == game.spectator,"eliminated player follows living ally")
	check(p.model.visible,"switching to spectator restores body hidden by close camera")
	var first := game.spectator
	game.cycle_spectator()
	check(game.spectator != first,"spectator cycles teammates")
	await setup()
	var score_before: int = game.score[0]
	for f in game.fighters:
		if f.team == 1:
			f.take_damage(10000,p,p.position)
	await frames(3)
	check(not game.active and game.result == "VITÓRIA" and game.score[0] == score_before+1,"elimination ends and scores round once")
	game.check_winner()
	check(game.score[0] == score_before+1,"winner check is idempotent")
	await setup()
	game.spawn_runes()
	game.spawn_field(p,Vector3.ZERO)
	game.shoot(p,Vector3.ZERO,12,false)
	game.start_round("mage",true)
	await frames(3)
	check(game.fighters.size() == 6 and game.effects.get_child_count() == 0 and game.runes.is_empty(),"restart clears old projectiles fields and runes")
	check(game.player.hero == "mage" and game.player.hp == 200 and game.zone_half == RiftRules.MAP_HALF,"restart resets hero health and zone")
	await setup()
	for f in game.fighters:
		f.take_damage(10000,null,Vector3.ZERO,true)
	await frames(3)
	check(game.result == "EMPATE","simultaneous team elimination is draw")
	# Full autonomous games exercise pathfinding, kits, runes and round cleanup.
	for hero in ["warrior","mage"]:
		game.start_round(hero,true)
		game.player.human = false
		for i in 10500:
			await physics_frame
			if not game.active:
				break
		check(not game.active and game.elapsed <= 166,"complete six-bot match terminates for "+hero)
		print("MATCH ",JSON.stringify(game.round_stats.back()))
	print("SUITE_COMPLETE checks=%d failures=%d" % [checks,failures])
	paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	game.queue_free()
	await frames(3)
	quit(1 if failures else 0)
