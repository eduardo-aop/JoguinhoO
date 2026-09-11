class_name ThirdPersonRig
extends Node3D

var settings: TrainingSettings
var actor: CharacterBody3D
var camera: Camera3D
var pitch: float = -.28
var yaw := 0.0
var model_visible := true
var cursor_position := Vector2.ZERO
var current_distance := 6.0
var collision_shape := SphereShape3D.new()

func _ready() -> void:
	camera = Camera3D.new()
	camera.name = "SurvivalCamera"
	camera.fov = 68
	camera.near = .08
	camera.far = 150
	add_child(camera)
	collision_shape.radius = .25
	current_distance = settings.camera_distance
	camera.position.z = current_distance
	camera.current = true
	yaw = actor.rotation.y
	snap_to_actor()

func _input(event: InputEvent) -> void:
	if get_tree().paused: return
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		cursor_position = event.position.clamp(Vector2.ZERO,get_viewport().get_visible_rect().size)

func look(delta: Vector2) -> void:
	yaw = wrapf(yaw-delta.x*settings.mouse_sensitivity,-PI,PI)
	pitch = clampf(pitch-delta.y*settings.mouse_sensitivity,-1.05,.45)
	rotation = Vector3(pitch,yaw,0)
	update_collision(0)

func aim_toward(point: Vector3) -> void:
	var offset := point-global_position
	yaw = atan2(-offset.x,-offset.z)
	pitch = clampf(atan2(offset.y,Vector2(offset.x,offset.z).length()),-1.05,.45)
	rotation = Vector3(pitch,yaw,0)
	update_collision(0)

func snap_to_actor() -> void:
	if not is_instance_valid(actor): return
	global_position = follow_target()
	rotation = Vector3(pitch,yaw,0)
	cursor_position = get_viewport().get_visible_rect().size*.5
	update_collision(0)

func follow_target() -> Vector3:
	return actor.global_position+Vector3.UP*2.65

func _physics_process(dt: float) -> void:
	if not is_instance_valid(actor): return
	global_position = global_position.lerp(follow_target(),1.0-exp(-settings.camera_follow_speed*dt))
	update_collision(dt)

func update_collision(dt: float) -> void:
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = collision_shape
	query.transform = Transform3D(Basis.IDENTITY,global_position)
	query.motion = global_basis.z*settings.camera_distance
	query.collision_mask = 1
	query.exclude = [actor.get_rid()]
	var space := get_world_3d().direct_space_state
	# Following a tight corner can place the smoothed pivot inside cover.
	if not space.intersect_shape(query,1).is_empty():
		global_position = follow_target()
		query.transform.origin = global_position
	var fractions := space.cast_motion(query)
	var distance := maxf(.25,settings.camera_distance*fractions[0]-.1)
	current_distance = distance if distance < current_distance else move_toward(current_distance,distance,5.0*dt)
	camera.position.z = current_distance
	if current_distance < .85: model_visible = false
	elif current_distance > 1.2: model_visible = true

func movement_direction(axis: Vector2) -> Vector3:
	return (Basis(Vector3.UP,yaw)*Vector3(axis.x,0,axis.y)).limit_length(1.0)

func ground_at(screen: Vector2) -> Vector3:
	var hit = Plane(Vector3.UP,0).intersects_ray(camera.project_ray_origin(screen),camera.project_ray_normal(screen))
	return hit if hit != null else Vector3.INF

func cursor_ground() -> Vector3:
	return ground_at(cursor_position)

func aim_query(max_distance: float = 100.0) -> Dictionary:
	return aim_at(cursor_position,max_distance)

func aim_at(screen: Vector2, max_distance: float = 100.0) -> Dictionary:
	var origin := camera.project_ray_origin(screen)
	var destination := origin+camera.project_ray_normal(screen)*max_distance
	var excluded: Array[RID] = [actor.get_rid()]
	if actor is RiftFighter:
		for ally in actor.arena.fighters:
			if ally != actor and ally.team == actor.team:
				excluded.append(ally.get_rid())
	var hit := get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(origin,destination,3,excluded))
	return hit if not hit.is_empty() else {"position":destination,"collider":null}
