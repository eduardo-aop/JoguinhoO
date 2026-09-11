extends Node
var arena: RiftArena
var initial := Vector3.ZERO
var timer := 0.0
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	arena = load("res://scenes/arena.tscn").instantiate()
	add_child(arena)
	arena.start_round("warrior",true)
	for f in arena.fighters:
		if not f.human: f.set_physics_process(false)
	arena.player.position = Vector3(0,0,6)
	arena.rig.snap_to_actor()
	initial = arena.player.position
func _process(dt: float) -> void:
	timer -= dt
	if timer > 0: return
	timer = .25
	var p: RiftFighter = arena.player
	var state := {"cursor_mode":Input.mouse_mode,"cursor":str(get_viewport().get_mouse_position()),"aim":str(p.aim_point),"viewport":str(get_viewport().get_visible_rect().size),"facing":p.rotation.y,"camera_rotation":[arena.rig.camera.global_rotation.x,arena.rig.camera.global_rotation.y,arena.rig.camera.global_rotation.z],"initial":[initial.x,initial.y,initial.z],"position":[p.position.x,p.position.y,p.position.z],"distance":p.position.distance_to(initial),"attacks":p.attack_count,"abilities":p.abilities_used,"paused":get_tree().paused,"alive":p.alive,"velocity":[p.velocity.x,p.velocity.y,p.velocity.z]}
	var file := FileAccess.open("res://docs/NATIVE-INPUT-V6.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(state,"  "))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var record := {"event_position":str(event.position),"cursor":str(get_viewport().get_mouse_position()),"aim":str(arena.rig.aim_query().position),"ground":str(arena.rig.cursor_ground()),"screen_player":str(arena.rig.camera.unproject_position(arena.player.global_position))}
		var file := FileAccess.open("res://docs/NATIVE-CLICK-V6.json",FileAccess.WRITE)
		file.store_string(JSON.stringify(record,"  "))
