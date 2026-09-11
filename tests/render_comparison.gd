extends Node
var arena: RiftArena
var phase := 0
var count := 0
var draws: Array[int] = []
var times: Array[float] = []
var reports: Array[Dictionary] = []
func setup() -> void:
	arena = load("res://scenes/arena.tscn").instantiate()
	arena.batch_decoration_enabled = phase == 1
	add_child(arena)
	seed(510)
	arena.start_round("mage",true)
	for fighter in arena.fighters: fighter.set_physics_process(false)
	arena.active = false
	arena.hud.hide()
	var camera := Camera3D.new()
	arena.add_child(camera)
	camera.position = Vector3(0,18,25)
	camera.look_at(Vector3.ZERO)
	camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
func _ready() -> void: setup()
func _process(dt: float) -> void:
	count += 1
	if count > 180:
		draws.append(int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
		times.append(dt*1000)
	if count < 900: return
	draws.sort()
	times.sort()
	reports.append({"batched":phase == 1,"draw_calls_median":draws[int(draws.size()*.5)],"median_ms":times[int(times.size()*.5)],"p95_ms":times[int(times.size()*.95)],"samples":times.size()})
	if phase == 0:
		arena.queue_free()
		phase = 1
		count = 0
		draws.clear()
		times.clear()
		setup()
	else:
		var report := {"conditions":"Same static scene, seed, camera, six heroes and renderer; excludes active gameplay. Timing includes frame pacing.","results":reports}
		var file := FileAccess.open("res://docs/RENDER-COMPARISON-V5.json",FileAccess.WRITE)
		file.store_string(JSON.stringify(report,"  "))
		print("RENDER_COMPARISON_COMPLETE ",JSON.stringify(report))
		set_process(false)
