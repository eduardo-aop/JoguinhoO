extends Node

@export var rounds_to_run := 4
var arena: RiftArena
var reports: Array[Dictionary] = []
var samples: Array[float] = []
var started := 0
var completed := 0
var finishing := false
var maximum_effects := 0
var maximum_voices := 0

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://work"))
	process_mode = Node.PROCESS_MODE_ALWAYS
	arena = load("res://scenes/arena.tscn").instantiate()
	add_child(arena)
	arena.settings.effects_volume = .12
	started = Time.get_ticks_msec()
	start_next()

func start_next() -> void:
	seed(6100+completed)
	arena.start_round("mage" if completed%2 else "warrior",true)
	arena.player.human = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	samples.clear()
	maximum_effects = 0
	maximum_voices = 0
	finishing = false

func _process(dt: float) -> void:
	# This unattended diagnostic resumes itself. The real game still pauses on focus loss.
	if get_tree().paused:
		arena.hud.resume_game()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if finishing: return
	samples.append(dt*1000)
	maximum_effects = maxi(maximum_effects,get_tree().get_nodes_in_group("transient_combat_fx").size())
	var playing := 0
	for voice in arena.sound.voices:
		if voice.playing: playing += 1
	maximum_voices = maxi(maximum_voices,playing)
	if not arena.active:
		finishing = true
		finish_sample()

func finish_sample() -> void:
	var row: Dictionary = arena.round_stats.back().duplicate(true)
	samples.sort()
	row["median_frame_ms"] = samples[int(samples.size()*.5)]
	row["p95_frame_ms"] = samples[int(samples.size()*.95)]
	row["peak_effects"] = maximum_effects
	row["peak_playing_voices"] = maximum_voices
	arena.clear_round()
	for i in 5: await get_tree().process_frame
	row["nodes_after_cleanup"] = Performance.get_monitor(Performance.OBJECT_NODE_COUNT)
	row["orphan_nodes"] = Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)
	row["static_memory_bytes"] = Performance.get_monitor(Performance.MEMORY_STATIC)
	row["cleanup_ok"] = arena.actors.get_child_count() == 0 and arena.effects.get_child_count() == 0 and arena.sound.voices.all(func(v): return not v.playing and v.stream == null)
	reports.append(row)
	completed += 1
	var valid := reports.all(func(r): return r.cleanup_ok and r.peak_effects <= 48 and r.peak_playing_voices <= 18)
	var report := {"complete":completed == rounds_to_run,"rounds":completed,"wall_seconds":(Time.get_ticks_msec()-started)/1000.0,"checks_passed":valid,"note":"Real-time graphical bot-only sessions with spatial audio enabled at low volume. Frame timing includes pacing; focus pause is bypassed only by this diagnostic.","samples":reports}
	var file := FileAccess.open("res://work/endurance.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(report,"  "))
	print("SOAK_ROUND ",completed," cleanup=",row.cleanup_ok," nodes=",row.nodes_after_cleanup," memory=",row.static_memory_bytes)
	if completed < rounds_to_run:
		start_next()
	else:
		print("SOAK_COMPLETE rounds=",completed," passed=",valid)
		get_tree().quit(0 if valid else 1)
