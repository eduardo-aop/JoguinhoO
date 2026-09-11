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
	var original_ticks := Engine.physics_ticks_per_second
	var game: RiftArena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	for ticks in [30,60,120]:
		Engine.physics_ticks_per_second = ticks
		game.start_round("warrior",true)
		for fighter in game.fighters: fighter.set_physics_process(false)
		var p: RiftFighter = game.player
		p.position = Vector3(0,.01,0)
		p.rotation.y = 0
		await frames(4)
		var from := p.position
		p.cast(0)
		p.set_physics_process(true)
		await frames(int(ticks*.5))
		p.set_physics_process(false)
		var distance := Vector2(p.position.x-from.x,p.position.z-from.z).length()
		print("DASH ticks=",ticks," distance=",distance)
		check(absf(distance-6.21) < .04,"dash distance independent of physics frequency %d" % ticks)
		check(Vector2(p.velocity.x,p.velocity.z).length() < .01,"dash ends without coasting %d" % ticks)
	Engine.physics_ticks_per_second = original_ticks
	game.queue_free()
	await frames(3)
	print("DASH_TIMING_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
