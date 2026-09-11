class_name RiftProjectile
extends Node3D

var arena: Node3D
var owner_fighter: Node3D
var direction := Vector3.FORWARD
var speed := 22.0
var remaining := 17.0
var damage := 12.0
var explosive := false
var radius := 2.6

func _ready() -> void:
	var trail := MeshInstance3D.new()
	var shape := SphereMesh.new()
	shape.radius = .13 if explosive else .07
	shape.height = shape.radius*2
	trail.mesh = shape
	trail.scale = Vector3(1,1,3.5)
	trail.position = -direction*.2
	trail.quaternion = Quaternion(Vector3.FORWARD,direction)
	trail.material_override = TrainingVisuals.mat(Color(RiftRules.team_color(owner_fighter.team),.35),.4)
	trail.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(trail)

func _physics_process(dt: float) -> void:
	if not arena.active:
		return
	var distance := minf(speed*dt,remaining)
	var destination := global_position+direction*distance
	var excluded: Array[RID] = []
	for f in arena.fighters:
		if f.team == owner_fighter.team:
			excluded.append(f.get_rid())
	var query := PhysicsRayQueryParameters3D.create(global_position,destination,3,excluded)
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty():
		var impact: Vector3 = hit.position + hit.normal*0.06
		if explosive:
			arena.area_damage(owner_fighter,impact,radius,damage,0,0)
		elif hit.collider.has_method("take_damage"):
			hit.collider.take_damage(damage,owner_fighter,global_position)
		arena.combat_fx(impact,"explosion" if explosive else "impact",Color("b698ef") if explosive else RiftRules.team_color(owner_fighter.team),radius if explosive else .45)
		queue_free()
		return
	global_position = destination
	remaining -= distance
	if remaining <= 0:
		# Explosive orbs also detonate at maximum range.
		if explosive:
			arena.area_damage(owner_fighter,global_position,radius,damage,0,0)
			arena.combat_fx(global_position,"explosion",Color("b698ef"),radius)
		queue_free()
