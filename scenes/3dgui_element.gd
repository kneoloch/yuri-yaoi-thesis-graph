extends SubViewportContainer
class_name GUIElement

@onready var camera: Camera3D = %Camera
@onready var perspective_cube: Node3D = %PerspectiveCube
@export_range(0.0, 1.0) var sensitivity: float = 0.25
var orbiting: bool = false
var dragging: bool = false
var _mouse_position: Vector2 = Vector2(0.0, 0.0)
var drag_sensitivity: float = 0.02
var _total_pitch: float = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("orbit") or event.is_action_pressed("cameraRotate"):
		orbiting = true
	if event.is_action_released("orbit") or event.is_action_pressed("cameraRotate"):
		orbiting = false
	
	## Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
		if orbiting:
			camera.global_transform = orbit_transform(perspective_cube.global_position, camera.global_transform, event.relative * drag_sensitivity)

	## Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			## Only allows rotation if right click down
			MOUSE_BUTTON_RIGHT: 
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)

func _process(_delta: float) -> void:
	_update_mouselook()

## Updates mouse look 
func _update_mouselook() -> void:
	## Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	
	_mouse_position *= sensitivity
	#var yaw = _mouse_position.x
	var pitch = _mouse_position.y
	_mouse_position = Vector2(0, 0)
	
	## Prevents looking up/down too far
	pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
	_total_pitch += pitch

func orbit_transform(origin: Vector3, t: Transform3D, orbit_angle: Vector2) -> Transform3D:
	var dt = Transform3D().rotated(t.basis.x, -orbit_angle.y).rotated(Vector3.UP, -orbit_angle.x)
	t.basis = dt.basis * t.basis;
	t.origin = origin + t.basis.z * (t.origin - origin).length()
	return t
