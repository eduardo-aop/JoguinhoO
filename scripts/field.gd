class_name RiftField
extends Node3D
var arena: Node3D
var owner_fighter: Node3D
var duration := 5.0
var radius := 3.6
var dps := 10.0
var visual: MeshInstance3D
var crystals: Array[MeshInstance3D] = []
var elapsed := 0.0
func _ready() -> void:
	visual = TrainingVisuals.arc(self,radius,PI)
	visual.material_override = TrainingVisuals.mat(Color(0.35,0.7,1,0.22),0.2)
	for i in 10:
		var angle := i*TAU/10
		var crystal := FantasyWorld.crystal(self,Vector3(cos(angle)*radius*.88,.18,sin(angle)*radius*.88),Color("83cee9"),.45)
		crystal.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		crystals.append(crystal)
	TrainingVisuals.ring(self,radius,Vector3(0,.06,0),RiftRules.team_color(owner_fighter.team))
func _physics_process(dt: float) -> void:
	if not arena.active:
		return
	elapsed += dt
	for i in crystals.size():
		crystals[i].scale.y = maxf(.02,minf(elapsed*5,duration*3))*(.9+sin(elapsed*3+i)*.1)
	var step := minf(dt,duration)
	arena.area_damage(owner_fighter,global_position,radius,dps*step,0.35,0.2)
	duration -= step
	if duration <= 0:
		queue_free()
