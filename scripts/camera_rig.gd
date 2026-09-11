class_name ThirdPersonRig
extends Node3D

var settings: TrainingSettings
var actor: CharacterBody3D
var camera: Camera3D
var pitch: float = -PI / 3.0
var model_visible := true
var cursor_position := Vector2.ZERO

func _ready() -> void:
	camera = Camera3D.new()
	camera.name = "TacticalCamera"
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = settings.camera_distance
	camera.near = 0.1
	camera.far = 150
	add_child(camera)
	camera.position = Vector3(0,24,14)
	camera.rotation.x = pitch
	camera.current = true
	cursor_position = get_viewport().get_visible_rect().size*.5
	snap_to_actor()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		cursor_position = event.position.clamp(Vector2.ZERO,get_viewport().get_visible_rect().size)

func snap_to_actor() -> void:
	if is_instance_valid(actor):
		global_position = follow_target()

func follow_target() -> Vector3:
	var target := actor.global_position
	# Keep the view on the arena at map edges, even at different aspect ratios.
	var viewport_size := get_viewport().get_visible_rect().size
	var upper := ground_at(Vector2.ZERO)-global_position
	var lower := ground_at(viewport_size)-global_position
	var min_x := -24.0-upper.x
	var max_x := 24.0-lower.x
	var min_z := -20.0-upper.z
	var max_z := 20.0-lower.z
	target.x = clampf(target.x,min_x,max_x) if min_x < max_x else 0.0
	target.z = clampf(target.z,min_z,max_z) if min_z < max_z else 0.0
	target.y = 0.0
	return target

func _process(dt: float) -> void:
	if not is_instance_valid(actor): return
	global_position = global_position.lerp(follow_target(),1.0-exp(-settings.camera_follow_speed*dt))
	camera.size = lerpf(camera.size,settings.camera_distance,1.0-exp(-10.0*dt))

func movement_direction(axis: Vector2) -> Vector3:
	var right := camera.global_basis.x
	var back := camera.global_basis.z
	right.y = 0
	back.y = 0
	return (right.normalized()*axis.x+back.normalized()*axis.y).limit_length(1.0)

func ground_at(screen: Vector2) -> Vector3:
	var hit = Plane(Vector3.UP,0).intersects_ray(camera.project_ray_origin(screen),camera.project_ray_normal(screen))
	return hit if hit != null else actor.global_position

func cursor_ground() -> Vector3:
	return ground_at(cursor_position)

func aim_query(max_distance: float = 100.0) -> Dictionary:
	return aim_at(cursor_position,max_distance)

func aim_at(cursor: Vector2, max_distance: float = 100.0) -> Dictionary:
	var origin := camera.project_ray_origin(cursor)
	var destination := origin + camera.project_ray_normal(cursor)*max_distance
	var excluded: Array[RID] = [actor.get_rid()]
	if actor is RiftFighter:
		for ally in actor.arena.fighters:
			if ally != actor and ally.team == actor.team:
				excluded.append(ally.get_rid())
	var query := PhysicsRayQueryParameters3D.create(origin,destination,1 | 2,excluded)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and hit.collider is RiftFighter:
		hit.position = hit.collider.global_position + Vector3.UP*1.2
		return hit
	# Ground cursor determines horizontal aim; projectiles stay at torso height.
	var point := ground_at(cursor)
	point.y = actor.global_position.y+1.2
	return {"position":point,"collider":null}
