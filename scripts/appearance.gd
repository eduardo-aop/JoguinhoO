class_name RiftAppearance
extends RefCounted

static func painted_material(source: StandardMaterial3D,cloth: bool = false,team: int = -1) -> ShaderMaterial:
	var result := ShaderMaterial.new()
	result.shader = load("res://shaders/cloth.gdshader" if cloth else "res://shaders/painted_hero.gdshader")
	if not cloth:
		result.set_shader_parameter("metalness",source.metallic)
		result.set_shader_parameter("surface_roughness",source.roughness)
	elif team >= 0:
		result.set_shader_parameter("team_tint",RiftRules.team_color(team))
		result.set_shader_parameter("team_strength",.85)
	return result

static func weapon(parent: Node3D,hero: String) -> Node3D:
	var pivot := Node3D.new()
	pivot.name = "HeroWeapon"
	parent.add_child(pivot)
	pivot.position = Vector3(.57,1.05,-.1)
	if hero == "warrior":
		var sword := FantasyWorld.crystal(pivot,Vector3(0,0,-.73),Color("a7c3c7"),1.4)
		sword.rotation.x = PI/2
		sword.scale.x = .45
		sword.scale.z = .28
		TrainingVisuals.box(pivot,Vector3(.10,.10,.30),Vector3(0,0,.04),Color("433832"))
		TrainingVisuals.box(pivot,Vector3(.38,.1,.1),Vector3(0,0,-.15),Color("b79459"))
	else:
		TrainingVisuals.box(pivot,Vector3(.09,1.7,.09),Vector3(0,.05,0),Color("b6a181"))
		FantasyWorld.crystal(pivot,Vector3(0,1,0),Color("97b2fb"),.8)
	return pivot

static func shield(parent: Node3D,team: int) -> MeshInstance3D:
	var mesh := TrainingVisuals.box(parent,Vector3(.14,.85,.60),Vector3(-.70,1.05,0),RiftRules.team_color(team).darkened(.35))
	mesh.name = "HeroShield"
	TrainingVisuals.box(mesh,Vector3(.025,.7,.045),Vector3(-.085,0,0),Color("c5a45d"))
	TrainingVisuals.box(mesh,Vector3(.025,.045,.5),Vector3(-.085,.07,0),Color("c5a45d"))
	return mesh

static func attach_to_bone(item: Node3D,skeleton: Skeleton3D,bone: String) -> void:
	var socket := BoneAttachment3D.new()
	skeleton.add_child(socket)
	socket.bone_name = bone
	socket.transform = skeleton.get_bone_global_rest(skeleton.find_bone(bone))
	item.reparent(socket,true)
