extends Node
var arena: RiftArena
var samples: Array[float] = []
var draws: Array[int] = []
var frames := 0
var rounds := 0
func _ready() -> void:
	arena = load("res://scenes/arena.tscn").instantiate()
	add_child(arena)
	arena.start_round("mage",true)
	arena.player.human = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
func _process(dt: float) -> void:
	frames += 1
	if frames > 180:
		samples.append(dt*1000)
		draws.append(int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME)))
	if not arena.active:
		rounds += 1
		arena.start_round("warrior" if rounds%2 else "mage",true)
		arena.player.human = false
	if frames == 1800:
		samples.sort()
		draws.sort()
		var report := {"samples":samples.size(),"median_ms":samples[int(samples.size()*.5)],"p95_ms":samples[int(samples.size()*.95)],"draw_calls_median":draws[int(draws.size()*.5)],"draw_calls_p95":draws[int(draws.size()*.95)],"rendering_method":"gl_compatibility","note":"Observed on this machine; includes frame pacing and is not a GPU-only benchmark."}
		var file := FileAccess.open("res://docs/PERFORMANCE-V5.json",FileAccess.WRITE)
		file.store_string(JSON.stringify(report,"  "))
		print("PERFORMANCE_COMPLETE ",JSON.stringify(report))
		set_process(false)
