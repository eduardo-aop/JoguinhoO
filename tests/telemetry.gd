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
	game.start_round("warrior",true)
	for f in game.fighters: f.set_physics_process(false)
	var p: RiftFighter = game.player
	var enemy: RiftFighter = game.fighters[3]
	enemy.guard_time = 2
	enemy.rotation.y = 0
	enemy.take_damage(40,p,enemy.position+Vector3.FORWARD)
	check(is_equal_approx(p.damage_dealt,10) and is_equal_approx(enemy.damage_taken,10),"damage statistics use damage after guard reduction")
	enemy.hp = 5
	enemy.take_damage(1000,p,enemy.position+Vector3.FORWARD)
	check(is_equal_approx(p.damage_dealt,15),"overkill is excluded from damage statistics")
	enemy.take_damage(1000,p,enemy.position)
	check(p.eliminations == 1,"elimination counted only once")
	p.cast(0)
	p.cast(0)
	check(p.abilities_used[0] == 1,"only successful abilities are counted")
	p.collect_rune(1,0)
	p.ability_lock = 0
	p.cast(3)
	check(p.runes_collected == 1 and p.abilities_used[3] == 1,"rune collection and activation tracked separately")
	game.finish(0,"test")
	var summary: Dictionary = game.round_stats.back().participants[1]
	check(summary.kills == 1 and summary.damage == 15,"round result captures participant statistics")
	game.start_round("mage",true)
	check(game.player.damage_dealt == 0 and game.player.eliminations == 0 and summary.kills == 1,"new round resets statistics and preserves prior snapshot")
	game.queue_free()
	for i in 3: await process_frame
	print("TELEMETRY_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
