extends Node3D
class_name PerspectiveCube

@export var camera: Camera3D

@onready var front_orthogonal: Marker3D = %FrontOrthogonal
@onready var right_orthogonal: Marker3D = %RightOrthogonal
@onready var top_orthogonal: Marker3D = %TopOrthogonal
@onready var rear_orthogonal: Marker3D = %RearOrthogonal
@onready var left_orthgonal: Marker3D = %LeftOrthgonal
@onready var bottom_orthogonal: Marker3D = %BottomOrthogonal

func _on_pos_t_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	_reposition(event, front_orthogonal)

func _on_pos_x_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	_reposition(event, right_orthogonal)

func _on_pos_y_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	_reposition(event, top_orthogonal)

func _on_neg_t_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	_reposition(event, rear_orthogonal)

func _on_neg_x_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	_reposition(event, left_orthgonal)

func _on_neg_y_area_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	_reposition(event, bottom_orthogonal)

func _reposition(event: InputEvent, marker: Marker3D) -> void:
	if camera != null and event.is_action_released("select"):
		camera.global_position = marker.global_position
		camera.look_at(global_position)
		Global.snapCameraPos.emit(marker.name)
