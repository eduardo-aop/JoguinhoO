extends SceneTree
var failures := 0
var checks := 0
func _initialize() -> void: call_deferred("run")
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func run() -> void:
	for hero in ["warrior","mage"]:
		var model: Node3D = load("res://assets/%s_animated.glb" % hero).instantiate()
		root.add_child(model)
		var player: AnimationPlayer = model.find_children("*","AnimationPlayer",true,false)[0]
		var attack := player.get_animation("attack")
		var track := -1
		for i in attack.get_track_count():
			if attack.track_get_type(i) == Animation.TYPE_ROTATION_3D and str(attack.track_get_path(i)).ends_with(":upper_arm_r"):
				track = i
		check(track >= 0,"attack contains right arm animation "+hero)
		if track >= 0:
			var peak := 0.0
			var peak_time := 0.0
			var start := attack.rotation_track_interpolate(track,0)
			for i in 270:
				var t := i/300.0
				var angle := start.angle_to(attack.rotation_track_interpolate(track,minf(t,attack.length)))
				if angle > peak:
					peak = angle
					peak_time = t
			var windup: float = RiftRules.HEROES[hero].windup
			print("TIMING ",hero," peak=",peak_time," impact=",windup)
			check(absf(peak_time-windup) <= .035,"animation extension matches gameplay impact "+hero)
			check(start.angle_to(attack.rotation_track_interpolate(track,attack.length)) < .08,"attack recovers to starting pose "+hero)
		model.queue_free()
	await process_frame
	print("ATTACK_TIMING_COMPLETE checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)
