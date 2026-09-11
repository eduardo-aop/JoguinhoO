class_name RiftRune
extends Node3D
var arena: Node3D
var category := 0
var kind := 0
var site := 0
var taken := false
var gem: MeshInstance3D
func _ready() -> void:
	var color: Color = [Color("75e9af"),Color("ffc67c"),Color("bba1f0")][kind] if category == 0 else Color("6ec9ff")
	gem = TrainingVisuals.box(self,Vector3(.65,.65,.65),Vector3(0,1,0),color)
	gem.rotation_degrees = Vector3(45,0,45)
	gem.material_override = TrainingVisuals.mat(color,.35)
	TrainingVisuals.ring(self,1.1,Vector3(0,.04,0),color)
	TrainingVisuals.label(self,("BÔNUS · " + RiftRules.PASSIVES[kind]) if category == 0 else ("F · " + RiftRules.ACTIVES[kind]),Vector3(0,2.1,0),30)
func _physics_process(dt: float) -> void:
	if not arena.active or taken:
		return
	gem.rotation.y += dt
	for f in arena.fighters:
		if f.alive and f.global_position.distance_to(global_position) < 1.15:
			taken = true
			f.collect_rune(category,kind)
			arena.runes.erase(self)
			queue_free()
			break
