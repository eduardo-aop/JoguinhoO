extends SceneTree
var events: Array[Dictionary] = []

func _initialize() -> void: call_deferred("run")

func run() -> void:
	var game: RiftArena = load("res://scenes/arena.tscn").instantiate()
	root.add_child(game)
	for sample in 12:
		seed(3700+sample)
		game.start_round("mage" if sample%2 else "warrior",true)
		game.player.human = false
		var anchors: Array[Vector3] = []
		var stuck: Array[float] = []
		var recorded: Array[bool] = []
		for f in game.fighters:
			anchors.append(f.position)
			stuck.append(0)
			recorded.append(false)
		for frame in 10100:
			await physics_frame
			if not game.active: break
			if frame%6 != 0: continue
			for i in game.fighters.size():
				var f: RiftFighter = game.fighters[i]
				if not f.alive or f.move_axis_world.length() < .5 or f.position.distance_to(anchors[i]) > .35:
					anchors[i] = f.position
					stuck[i] = 0
					recorded[i] = false
					continue
				stuck[i] += .1
				if stuck[i] >= 1.5 and not recorded[i]:
					recorded[i] = true
					var p := f.position
					events.append({"seed":3700+sample,"seconds":game.elapsed,"fighter":i,"hero":f.hero,"position":[p.x,p.y,p.z],"path_points":f.bot.path.size(),"target_distance":f.position.distance_to(f.bot.target.position) if is_instance_valid(f.bot.target) else -1})
		print("NAV_AUDIT match=",sample+1," cumulative_stalls=",events.size())
	var file := FileAccess.open("res://docs/NAVIGATION-AUDIT-V5.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"definition":"Wanted movement above 0.5, less than 0.35 m displacement for at least 1.5 s; events may include intentional body blocking.","matches":12,"events":events},"  "))
	game.queue_free()
	for i in 3: await process_frame
	print("NAVIGATION_AUDIT_COMPLETE events=",events.size())
	quit()
