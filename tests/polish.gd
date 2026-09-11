extends SceneTree
var game: RiftArena
var checks := 0
var failures := 0
func _initialize() -> void:
	call_deferred("run")
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int) -> void:
	for i in n: await physics_frame
func run() -> void:
	game = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	for hero in ["warrior","mage"]:
		game.start_round(hero,true)
		for fighter in game.fighters: fighter.set_physics_process(false)
		var p: RiftFighter = game.player
		p.position = Vector3(0,.01,0)
		await frames(5)
		check(p.animator.head_pitch == 0,"tactical camera keeps head neutral "+hero)
		check(p.animator.skeleton.get_bone_count() == 16,"imported skeleton "+hero)
		check(p.weapon_pivot.get_parent() is BoneAttachment3D,"weapon attached to hand "+hero)
		var bone: int = p.animator.skeleton.find_bone("thigh_r")
		p.velocity = Vector3(0,0,-5)
		await frames(10)
		var pose := p.animator.skeleton.get_bone_pose_rotation(bone)
		p.animator.strike()
		await frames(10)
		check(not pose.is_equal_approx(p.animator.skeleton.get_bone_pose_rotation(bone)),"legs keep animating during attack "+hero)
		check(p.animator.tree.get("parameters/Motion/Attack/active"),"attack animation plays "+hero)
		p.velocity = Vector3.ZERO
		p.basic_clock = .07
		p.request_basic()
		check(p.buffer_time > 0,"late click buffered "+hero)
		p.set_physics_process(true)
		await frames(75)
		p.set_physics_process(false)
		check(p.attack_count == 1,"buffer executes exactly once "+hero)
		p.basic_clock = .06
		p.request_basic()
		p.cancel_prepare()
		check(p.buffer_time == 0,"cancel clears queued input "+hero)
		p.velocity = Vector3(5,0,0)
		p.set_physics_process(true)
		await frames(12)
		p.set_physics_process(false)
		check(absf(p.velocity.x) < .01,"release brakes promptly "+hero)
		game.sound.play("hit",p.position)
		game.sound.reset()
		check(game.sound.voices.size() == 18 and game.sound.voices.all(func(v): return not v.playing and v.stream == null),"audio reset releases voice streams "+hero)
	print("POLISH_COMPLETE checks=%d failures=%d" % [checks,failures])
	game.queue_free()
	await frames(3)
	quit(1 if failures else 0)
