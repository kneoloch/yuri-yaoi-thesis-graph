extends Camera3D
class_name FreeLookCamera

@onready var graph_origin: Marker3D = %Origin
@onready var marker: Marker3D = %Marker3D
## Modifier keys' speed multiplier
const SHIFT_MULTIPLIER: float = 2.5
const ALT_MULTIPLIER: float = 1.0 / SHIFT_MULTIPLIER
@export_range(0.0, 1.0) var sensitivity: float = 0.25
var drag_sensitivity: float = 0.02

## Mouse state
var _mouse_position: Vector2 = Vector2(0.0, 0.0)
var _total_pitch: float = 0.0

## Movement state
var _direction: Vector3 = Vector3(0.0, 0.0, 0.0)
var _velocity: Vector3 = Vector3(0.0, 0.0, 0.0)
var _acceleration: int = 30
var _deceleration: int = -10
var _vel_multiplier: int = 5

## Keyboard state
var _w: bool = false
var _s: bool = false
var _a: bool = false
var _d: bool = false
var _q: bool = false
var _e: bool = false
var _shift: bool = false
var _alt: bool = false

var orbiting: bool = false
var dragging: bool = false
var target_pos: Vector3 = Vector3(0, 0, 0)

func _ready() -> void:
	target_lock(graph_origin)
	Global.selectObject.connect(target_lock)

func target_lock(selected_object: Node3D) -> void:
	if selected_object == null:
		target_pos = marker.global_position
	elif selected_object == graph_origin:
		target_pos = graph_origin.global_position
		look_at(graph_origin.global_position)
	else:
		target_pos = selected_object.global_position
		global_position = selected_object.camera_marker.global_position
		look_at(selected_object.global_position)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("recenter"):
		target_lock(graph_origin)
	
	if event.is_action_pressed("orbit"):
		orbiting = true
	if event.is_action_released("orbit"):
		orbiting = false
	
	if event.is_action_pressed("screen_drag"):
		dragging = true
	if event.is_action_released("screen_drag"):
		dragging = false
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
	
	## Receives mouse motion
	if event is InputEventMouseMotion:
		_mouse_position = event.relative
		if orbiting:
			global_transform = orbit_transform(target_pos, global_transform, event.relative * drag_sensitivity)
		if dragging:
			Input.set_default_cursor_shape(Input.CURSOR_DRAG)
			translate_object_local(Vector3(-event.relative.x, event.relative.y, 0) * drag_sensitivity)
			target_lock(null)
	
	## Receives mouse button input
	if event is InputEventMouseButton:
		match event.button_index:
			## Only allows rotation if right click down
			MOUSE_BUTTON_RIGHT: 
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if event.pressed else Input.MOUSE_MODE_VISIBLE)
				target_lock(null)
			MOUSE_BUTTON_XBUTTON1: # Increases max velocity
				_vel_multiplier = clamp(_vel_multiplier * 1.1, 0.2, 20)
			MOUSE_BUTTON_XBUTTON2: # Decereases max velocity
				_vel_multiplier = clamp(_vel_multiplier / 1.1, 0.2, 20)

	## Receives key input
	if event is InputEventKey:
		match event.keycode:
			KEY_Q:
				_w = event.pressed
			KEY_E:
				_s = event.pressed
			KEY_A:
				_a = event.pressed
				target_lock(null)
			KEY_D:
				_d = event.pressed
				target_lock(null)
			KEY_S:
				_q = event.pressed
				target_lock(null)
			KEY_W:
				_e = event.pressed
				target_lock(null)
			KEY_SHIFT:
				_shift = event.pressed
			KEY_ALT:
				_alt = event.pressed

## Updates mouselook and movement every frame
func _process(delta: float) -> void:
	_update_mouselook()
	_update_movement(delta)
	
	if !Global.curr_theme == Global.ThemeColor.CUSTOM:
		return
	else:
		if position.x < 0:
			Global.flipSprite.emit("right")
		if position.x > 0:
			Global.flipSprite.emit("left")

## Updates camera movement
func _update_movement(delta) -> void:
	## Computes desired direction from key states
	_direction = Vector3(
		(_d as float) - (_a as float), # left and right
		(_e as float) - (_q as float), # forward and backward
		(_s as float) - (_w as float) # up and down
	)
	
	## Computes the change in velocity due to desired direction and "drag"
	## The "drag" is a constant acceleration on the camera to bring it's velocity to 0
	var offset = _direction.normalized() * _acceleration * _vel_multiplier * delta \
		+ _velocity.normalized() * _deceleration * _vel_multiplier * delta
	
	## Compute modifiers' speed multiplier
	var speed_multi = 1
	if _shift: speed_multi *= SHIFT_MULTIPLIER
	if _alt: speed_multi *= ALT_MULTIPLIER
	
	## Checks if we should bother translating the camera
	if _direction == Vector3.ZERO and offset.length_squared() > _velocity.length_squared():
		## Sets the velocity to 0 to prevent jittering due to imperfect deceleration
		_velocity = Vector3.ZERO
	else:
		## Clamps speed to stay within maximum value (_vel_multiplier)
		_velocity.x = clamp(_velocity.x + offset.x, -_vel_multiplier, _vel_multiplier)
		_velocity.y = clamp(_velocity.y + offset.y, -_vel_multiplier, _vel_multiplier)
		_velocity.z = clamp(_velocity.z + offset.z, -_vel_multiplier, _vel_multiplier)
		
		translate_object_local(_velocity * delta * speed_multi)
	
	## Zoom
	if(Input.is_action_just_pressed("zoomIn")):
		translate_object_local(Vector3(0, 0, -transform.origin.length() / 10))
	if(Input.is_action_just_pressed("zoomOut")):
		translate_object_local(Vector3(0, 0, transform.origin.length() / 10))

#func _physics_process(_delta: float) -> void:
	#if Input.is_action_pressed("select"):
		#var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
		#var raycast: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(project_ray_origin(get_viewport().get_mouse_position()), project_ray_origin(get_viewport().get_mouse_position()) * 7000)#far)
		#var collision: Dictionary = space_state.intersect_ray(raycast)
		#if !collision.is_empty():
			#print(collision)
		#else:
			#print("no collision: %s" % str(get_viewport().get_mouse_position()))

## Updates mouse look 
func _update_mouselook() -> void:
	## Only rotates mouse if the mouse is captured
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return
	
	_mouse_position *= sensitivity
	var yaw = _mouse_position.x
	var pitch = _mouse_position.y
	_mouse_position = Vector2(0, 0)
	
	## Prevents looking up/down too far
	pitch = clamp(pitch, -90 - _total_pitch, 90 - _total_pitch)
	_total_pitch += pitch
	
	if Input.is_action_pressed("cameraRotate"):
		rotate_y(deg_to_rad(-yaw))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-pitch))

func orbit_transform(origin: Vector3, t: Transform3D, orbit_angle: Vector2) -> Transform3D:
	var dt = Transform3D().rotated(t.basis.x, -orbit_angle.y).rotated(Vector3.UP, -orbit_angle.x)
	t.basis = dt.basis * t.basis;
	t.origin = origin + t.basis.z * (t.origin - origin).length()
	return t
