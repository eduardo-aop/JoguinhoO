class_name FantasyWorld
extends RefCounted

static func crystal(parent: Node3D,at: Vector3,color: Color,size: float = 1) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var prism := PrismMesh.new()
	prism.size = Vector3(.35,.85,.35)*size
	mesh.mesh = prism
	mesh.position = at
	mesh.material_override = TrainingVisuals.mat(color,.35)
	parent.add_child(mesh)
	return mesh

static func decorate(arena: Node3D) -> void:
	var decor := Node3D.new()
	decor.name = "FantasyArchitecture"
	arena.add_child(decor)
	var stone := Color("485653")
	var trim := Color("938568")
	for x in [-8,8]:
		for z in [-7,7]:
			for side in [-1,1]:
				TrainingVisuals.box(decor,Vector3(.32,2.7,.32),Vector3(x+side*1.5,1.35,z-2.25),trim)
				TrainingVisuals.box(decor,Vector3(.32,2.7,.32),Vector3(x+side*1.5,1.35,z+2.25),trim)
			for y in [.35,2.25]:
				TrainingVisuals.box(decor,Vector3(3.52,.10,5.02),Vector3(x,y,z),stone)
			TrainingVisuals.box(decor,Vector3(3.1,.18,4.55),Vector3(x,2.88,z),stone)
			crystal(decor,Vector3(x,3.3,z),Color("64b8a9"),.7)
	for x in range(-24,25,6):
		for z in [-20,20]:
			TrainingVisuals.box(decor,Vector3(1.15,.28,1.15),Vector3(x,3.3,z),trim)
			TrainingVisuals.box(decor,Vector3(.95,.2,.95),Vector3(x,4.5,z),stone)
			crystal(decor,Vector3(x,4.96,z),Color("67a6ad"),.85)
	# Vegetation stays beyond the playable walls and inside cover footprints.
	var rng := RandomNumberGenerator.new()
	rng.seed = 430
	for i in 30:
		var side := -1 if i%2 == 0 else 1
		var at := Vector3(rng.randf_range(-27,27),0,side*rng.randf_range(23,28))
		TrainingVisuals.box(decor,Vector3(.38,4,.38),at+Vector3.UP*2,Color("3d3931"))
		for tier in 3:
			var tree := MeshInstance3D.new()
			var cone := CylinderMesh.new()
			cone.top_radius = .05
			cone.bottom_radius = 2.1-tier*.45
			cone.height = 3
			cone.radial_segments = 7
			tree.mesh = cone
			tree.position = at+Vector3.UP*(3.2+tier*1.1)
			tree.material_override = TrainingVisuals.mat(Color("274b43").lightened(tier*.035))
			decor.add_child(tree)
	for side in [-1,1]:
		for z in [-3,3]:
			TrainingVisuals.box(decor,Vector3(.35,4.3,.35),Vector3(side*24,2.15,z),trim)
			TrainingVisuals.box(decor,Vector3(.07,1.8,1.1),Vector3(side*23.8,3.2,z),Color("25506a") if side < 0 else Color("7c3442"))

	if arena.batch_decoration_enabled:
		batch_static_decoration(decor)

static func batch_static_decoration(decor: Node3D) -> void:
	var groups: Dictionary = {}
	for node in decor.get_children():
		if not node is MeshInstance3D or not node.material_override is StandardMaterial3D:
			continue
		var material: StandardMaterial3D = node.material_override
		var geometry: Mesh = node.mesh
		var transform: Transform3D = node.transform
		var geometry_key := str(geometry.get_class())
		if geometry is BoxMesh:
			transform = transform.scaled_local(geometry.size)
			var unit_box := BoxMesh.new()
			unit_box.size = Vector3.ONE
			geometry = unit_box
		elif geometry is PrismMesh:
			transform = transform.scaled_local(geometry.size)
			var unit_prism := PrismMesh.new()
			unit_prism.size = Vector3.ONE
			geometry = unit_prism
		elif geometry is CylinderMesh:
			geometry_key += str([geometry.top_radius,geometry.bottom_radius,geometry.height,geometry.radial_segments])
		else:
			continue
		var key := geometry_key+material.albedo_color.to_html()+str(material.emission_enabled)+str(material.emission_energy_multiplier)
		if not groups.has(key):
			groups[key] = {"mesh":geometry,"material":material,"transforms":[],"nodes":[]}
		groups[key].transforms.append(transform)
		groups[key].nodes.append(node)
	for group in groups.values():
		if group.nodes.size() < 2:
			continue
		var instances := MultiMesh.new()
		instances.transform_format = MultiMesh.TRANSFORM_3D
		instances.mesh = group.mesh
		instances.instance_count = group.transforms.size()
		for i in group.transforms.size():
			instances.set_instance_transform(i,group.transforms[i])
		var batch := MultiMeshInstance3D.new()
		batch.multimesh = instances
		batch.material_override = group.material
		decor.add_child(batch)
		for old in group.nodes:
			decor.remove_child(old)
			old.queue_free()
