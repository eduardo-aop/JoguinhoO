extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var arena: RiftArena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(arena)
	for heroes in [["warrior","warrior"],["warrior","mage"],["mage","mage"]]:
		for repetition in 2:
			seed(900+repetition)
			arena.start_round(heroes[0],true)
			arena.next_runes = 999
			for f in arena.fighters:
				f.human = false
				if f != arena.player and f != arena.fighters[3]:
					f.alive = false
					f.collision_layer = 0
					f.collision_mask = 0
					f.hide()
			var rival := arena.fighters[3]
			rival.hero = heroes[1]
			rival.stats = RiftRules.HEROES[heroes[1]].duplicate(true)
			rival.max_hp = rival.stats.hp
			rival.hp = rival.max_hp
			arena.player.position = Vector3(0,.01,5)
			rival.position = Vector3(0,.01,-5)
			for frame in 10200:
				await physics_frame
				if not arena.active:
					break
			print("DUEL ",heroes," ",JSON.stringify(arena.round_stats.back()))
	arena.queue_free()
	paused = false
	await process_frame
	quit()
