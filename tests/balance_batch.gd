extends SceneTree
var rows: Array[Dictionary] = []
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var game: RiftArena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	for sample in 16:
		for mirrored in [false,true]:
			seed(2400+sample)
			var choice := "warrior" if sample%2 == 0 else "mage"
			game.start_round(choice,true)
			game.player.human = false
			if mirrored:
				for fighter in game.fighters:
					fighter.position = Vector3(-fighter.position.x,fighter.position.y,-fighter.position.z)
					fighter.rotation.y += PI
			for frame in 10100:
				await physics_frame
				if not game.active: break
			if game.active:
				push_error("A match did not terminate")
				quit(1)
				return
			var row: Dictionary = game.round_stats.back().duplicate(true)
			row["seed"] = 2400+sample
			row["mirrored"] = mirrored
			row["player_slot_hero"] = choice
			rows.append(row)
			print("BATCH ",rows.size()," winner=",row.winner," seconds=",row.seconds)
	var file := FileAccess.open("res://docs/BALANCE-BATCH-V5.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"note":"32 deterministic bot-only matches, 16 mirrored pairs; exploratory, not proof of human balance.","matches":rows},"  "))
	game.queue_free()
	for i in 3: await process_frame
	print("BALANCE_BATCH_COMPLETE matches=",rows.size())
	quit()
