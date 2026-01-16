extends Node3D
class_name Labels

var original_scale: Vector3 = scale

func _process(_delta: float) -> void:
	# TODO: Billboard to look up as well (x)
	## Billboarding
	var camera_transform: Transform3D = get_viewport().get_camera_3d().global_transform
	var sprite_transform: Transform3D = global_transform
	
	var basis_y: Vector3 = sprite_transform.basis.y
	var basis_z: Vector3 = (camera_transform.origin - sprite_transform.origin).normalized() * original_scale.z
	var basis_x: Vector3 = basis.y.cross(basis_z).normalized() * original_scale.x
	
	global_transform = Transform3D(basis_x, basis_y, basis_z, sprite_transform.origin)
