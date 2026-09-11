class_name RiftCombatFX
extends Node3D

var kind := "impact"
var tint := Color.WHITE
var radius := 1.0
var lifetime := .35
var elapsed := 0.0
var meshes: Array[MeshInstance3D] = []
var initial_positions: Array[Vector3] = []

func keep(mesh: MeshInstance3D) -> void:
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	var material := TrainingVisuals.mat(Color(tint,tint.a*.8),.45)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if mesh.mesh is ImmediateMesh:
		material.cull_mode = BaseMaterial3D.CULL_DISABLED
	mesh.material_override = material
	meshes.append(mesh)
	initial_positions.append(mesh.position)

func _ready() -> void:
	add_to_group("transient_combat_fx")
	if kind == "slash":
		lifetime = .24
		var arc := TrainingVisuals.arc(self,radius,deg_to_rad(48))
		arc.position.y = .8
		keep(arc)
	elif kind == "heal":
		lifetime = .65
		for i in 3:
			keep(TrainingVisuals.ring(self,radius*(.65+i*.12),Vector3(0,.12+i*.25,0),tint))
	elif kind == "teleport":
		lifetime = .42
		for i in 2:
			var ring := TrainingVisuals.ring(self,radius,Vector3(0,.4+i*.65,0),tint)
			ring.rotation.x = PI/2
			keep(ring)
	else:
		lifetime = .48 if kind == "shock" or kind == "explosion" else .28
		keep(TrainingVisuals.ring(self,radius,Vector3(0,.07,0),tint))
		for i in 6:
			var a := i*TAU/6
			var shard := FantasyWorld.crystal(self,Vector3(cos(a),.18,sin(a))*radius*.35,tint,.22)
			keep(shard)

func _physics_process(dt: float) -> void:
	elapsed += dt
	var phase := clampf(elapsed/lifetime,0,1)
	for i in meshes.size():
		var mesh := meshes[i]
		var material: StandardMaterial3D = mesh.material_override
		material.albedo_color.a = tint.a*(1-phase)*.8
		if kind == "slash":
			mesh.rotation.y = lerpf(-.5,.5,phase)
			mesh.scale = Vector3.ONE*lerpf(.72,1.05,phase)
		elif kind == "heal":
			mesh.position.y = initial_positions[i].y+phase*1.25
			mesh.scale = Vector3.ONE*(1-phase*.3)
		elif kind == "teleport":
			mesh.scale = Vector3.ONE*maxf(.01,1-phase)
		else:
			mesh.scale = Vector3.ONE*lerpf(.3,1.08,phase)
			if i > 0:
				mesh.position = initial_positions[i]*(1+phase*1.8)+Vector3.UP*sin(phase*PI)*.5
	if elapsed >= lifetime:
		queue_free()
