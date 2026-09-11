extends SceneTree
var checks := 0
var failures := 0

func _initialize() -> void: call_deferred("run")

func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)

func cast_ray(game: RiftArena,height: float,x: float = 0) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(Vector3(x,height,4),Vector3(x,height,-4),2)
	return game.get_world_3d().direct_space_state.intersect_ray(query)

func run() -> void:
	var game: RiftArena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	for hero in ["warrior","mage"]:
		game.start_round(hero,true)
		for fighter in game.fighters: fighter.set_physics_process(false)
		game.player.position = Vector3.ZERO
		for i in 4: await physics_frame
		check(cast_ray(game,1.2).get("collider") == game.player,"torso is hittable "+hero)
		check(cast_ray(game,2.02).get("collider") == game.player,"upper head is hittable "+hero)
		check(cast_ray(game,2.4).is_empty(),"decorative crown does not enlarge body collision "+hero)
		check(cast_ray(game,1.7,.95).is_empty(),"weapon and shoulder tips do not enlarge body collision "+hero)
	game.queue_free()
	for i in 3: await physics_frame
	print("HITBOX_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
