extends SceneTree
func _initialize() -> void:
	call_deferred("run")
func run() -> void:
	var model = load("res://assets/warrior_animated.glb").instantiate()
	root.add_child(model)
	model.print_tree_pretty()
	for child in model.find_children("*","AnimationPlayer",true,false):
		print("ANIMATIONS ",child.get_animation_list())
		for a in child.get_animation_list():
			var clip: Animation = child.get_animation(a)
			print(a," length=",clip.length," first_track=",clip.track_get_path(0))
	for child in model.find_children("*","Skeleton3D",true,false):
		print("SKELETON ",child.get_path()," bones=",child.get_bone_count())
	model.queue_free()
	await process_frame
	quit()
