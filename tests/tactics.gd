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
	game.start_round("mage",true)
	for f in game.fighters: f.set_physics_process(false)
	var p: RiftFighter = game.player
	p.human = false
	p.position = Vector3(8,.01,10.7)
	var hidden: RiftFighter = game.fighters[3]
	var exposed: RiftFighter = game.fighters[4]
	hidden.position = Vector3(8,.01,8)
	exposed.position = Vector3(12,.01,10.7)
	game.fighters[5].position = Vector3(-18,.01,-15)
	await frames(4)
	check(p.bot.choose_target() == exposed,"bot favors reachable visible enemy over enemy behind cover")
	p.position = Vector3(20,.01,15)
	exposed.position = Vector3(18,.01,15)
	await frames(4)
	var escape := p.bot.choose_kite_position(exposed)
	check(p.bot.safe_destination(escape),"mage retreat stays inside navigable arena")
	check(escape.distance_to(exposed.position) > p.position.distance_to(exposed.position),"mage retreat increases distance from threat")
	check(not p.bot.safe_destination(Vector3(8,0,7)),"cover cannot become retreat destination")
	check(not p.bot.safe_destination(Vector3(25,0,0)),"retreat cannot leave arena")
	game.zone_half = Vector2(4,4)
	check(not p.bot.safe_destination(Vector3(10,0,0)),"retreat cannot enter danger zone")
	p.position = Vector3.ZERO
	exposed.position = Vector3(0,0,2)
	hidden.position = Vector3(15,0,15)
	p.cooldowns = [99.0,0.0,99.0]
	p.basic_clock = 1
	game.zone_half = Vector2(.5,.5)
	await frames(4)
	p.bot.timer = 0
	p.bot.direction(.016)
	check(p.cooldowns[1] == 0,"mage does not teleport forward when no retreat is available")
	game.zone_half = RiftRules.MAP_HALF
	var ally: RiftFighter = game.fighters[0]
	p.position = Vector3(0,.01,-1)
	ally.position = Vector3(0,.01,1)
	p.velocity = Vector3.ZERO
	ally.velocity = Vector3.ZERO
	p.bot.path = [Vector3(0,0,4)]
	ally.bot.path = [Vector3(0,0,-4)]
	p.bot.timer = 99
	ally.bot.timer = 99
	p.bot.target = null
	ally.bot.target = null
	p.set_physics_process(true)
	ally.set_physics_process(true)
	await frames(90)
	check(p.position.z > 1 and ally.position.z < -1,"allied bots pass each other instead of blocking head-on")
	game.queue_free()
	await frames(3)
	print("TACTICS_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
