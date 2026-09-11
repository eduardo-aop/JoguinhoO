class_name TrainingVisuals
extends RefCounted

static func mat(color: Color, emission: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = color
	m.roughness = 0.78
	if color.a < 1:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	if emission > 0:
		m.emission_enabled = true
		m.emission = color
		m.emission_energy_multiplier = emission
	return m

static func box(parent: Node3D, size: Vector3, pos: Vector3, color: Color, solid: bool = false) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var shape := BoxMesh.new()
	shape.size = size
	mesh.mesh = shape
	mesh.material_override = mat(color)
	parent.add_child(mesh)
	mesh.position = pos
	if solid:
		var body := StaticBody3D.new()
		body.collision_layer = 1
		var hit := CollisionShape3D.new()
		var collision := BoxShape3D.new()
		collision.size = size
		hit.shape = collision
		body.add_child(hit)
		mesh.add_child(body)
	return mesh

static func ring(parent: Node3D, radius: float, pos: Vector3, color: Color) -> MeshInstance3D:
	var mesh := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = radius - 0.025
	torus.outer_radius = radius
	torus.rings = 64
	torus.ring_segments = 6
	mesh.mesh = torus
	mesh.material_override = mat(color,0.3)
	parent.add_child(mesh)
	mesh.position = pos
	return mesh

static func label(parent: Node3D, words: String, pos: Vector3, font_size: int = 40) -> Label3D:
	var text := Label3D.new()
	text.text = words
	text.position = pos
	text.font_size = font_size
	text.pixel_size = 0.008
	text.outline_size = 5
	text.modulate = Color("dfe9e3")
	text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	parent.add_child(text)
	return text

static func arc(parent: Node3D, radius: float, angle: float) -> MeshInstance3D:
	var node := MeshInstance3D.new()
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 30:
		var a := lerpf(-angle,angle,float(i)/30.0)
		var b := lerpf(-angle,angle,float(i+1)/30.0)
		mesh.surface_add_vertex(Vector3.ZERO)
		mesh.surface_add_vertex(Vector3(sin(a),0,-cos(a))*radius)
		mesh.surface_add_vertex(Vector3(sin(b),0,-cos(b))*radius)
	mesh.surface_end()
	node.mesh = mesh
	var m := mat(Color(0.35,0.9,0.85,0.18),0.1)
	m.cull_mode = BaseMaterial3D.CULL_DISABLED
	node.material_override = m
	parent.add_child(node)
	node.position.y = 0.045
	return node
