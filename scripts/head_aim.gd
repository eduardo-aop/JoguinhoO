class_name RiftHeadAim
extends SkeletonModifier3D

var pitch := 0.0
var head_index := -1
var applied_rotation := Quaternion.IDENTITY

func _process_modification() -> void:
	var skeleton := get_skeleton()
	if skeleton == null:
		return
	if head_index < 0:
		head_index = skeleton.find_bone("head")
	if head_index < 0:
		return
	# Modifier processing restores the animated pose after skinning, so this
	# offset never feeds back into the next frame's source animation.
	applied_rotation = skeleton.get_bone_pose_rotation(head_index)*Quaternion(Vector3.RIGHT,clampf(pitch,-.5,.4))
	skeleton.set_bone_pose_rotation(head_index,applied_rotation)
