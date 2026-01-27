extends Sprite3D
class_name MediaEntry

@onready var name_label: Label3D = %NameLabel
@onready var coordinates: Label3D = %Coordinates
@onready var media_type_label: Label3D = %MediaTypeLabel
@onready var camera_marker: Marker3D = %CameraMarker

static var filtered_array: Array[Node] = []
static var filter_opacity: float = 0.2
var mouse_in: bool = false
var unique_media_data: Dictionary = {}
var original_scale: Vector3 = scale
var pos: Vector3
var media_coordinates: Array[Vector3]
var scale_multiplier: float = 1.0
var cluster_distance: float = 0.5
var transparent_toggle: bool = false

func _ready() -> void:
	media_type_label.hide()
	Global.selectObject.connect(_selected)
	Global.scaleAxis.connect(_scale_pos)
	Global.flipSprite.connect(_flip_sprite)
	Global.filterHide.connect(_filter_hide)

func _process(_delta: float) -> void:
	# TODO: Billboard to look up as well (x)
	## Billboarding
	var camera_transform: Transform3D = get_viewport().get_camera_3d().global_transform
	var sprite_transform: Transform3D = global_transform
	
	var basis_y: Vector3 = sprite_transform.basis.y
	var basis_z: Vector3 = (camera_transform.origin - sprite_transform.origin).normalized() * original_scale.z
	var basis_x: Vector3 = basis.y.cross(basis_z).normalized() * original_scale.x
	
	global_transform = Transform3D(basis_x, basis_y, basis_z, sprite_transform.origin)

func _flip_sprite(direction: String) -> void:
	match direction:
		"left":
			flip_h = true
		"right":
			flip_h = false

func _selected(object: Node) -> void:
	media_type_label.hide()
	object.media_type_label.show()
	var selected_array: Array[Node] = [object]
	filtered_transparency(selected_array)

func _filter_hide(matches: Array[Node]) -> void:
	filtered_array = matches
	filtered_transparency(filtered_array)

func filtered_transparency(array: Array[Node]) -> void:
	transparent_toggle = true
	modulate.a = filter_opacity
	material_overlay.set_shader_parameter("opacity", filter_opacity)
	material_overlay.set_shader_parameter("line_color", Color(1.0, 1.0, 1.0, 0.0))
	for i: Node3D in get_children():
		if i.is_class("Label3D"):
			i.modulate.a = filter_opacity
			i.outline_modulate.a = filter_opacity
	for entry: MediaEntry in array:
		entry.transparent_toggle = false
		entry.modulate.a = 1.0
		entry.material_overlay.set_shader_parameter("opacity", 1.0)
		entry.material_overlay.set_shader_parameter("line_color", Color(1.0, 1.0, 1.0, 1.0))
		for i: Node3D in entry.get_children():
			if i.is_class("Label3D"):
				i.modulate.a = 1.0
				i.outline_modulate.a = 1.0

func add_media_entry(object_data: Dictionary) -> void:
	unique_media_data = object_data
	## Name and Year
	name = unique_media_data["MediaName"]
	if unique_media_data["Year"] != "":
		name_label.text = "%s (%s)" % [unique_media_data["MediaName"], unique_media_data["Year"]]
	else:
		name_label.text = "%s" % unique_media_data["MediaName"]
	
	## Coordinates
	var x_axis: float = float(unique_media_data["X-Axis"])
	if unique_media_data["X-Axis"] == "±n":
		x_axis = 0.0
		modulate = Color.AQUA
	var y_axis: float = float(unique_media_data["Y-Axis"])
	if unique_media_data["Y-Axis"] == "±n":
		y_axis = 0.0
		modulate = Color.AQUA
	var t_axis: float = float(unique_media_data["T-Axis"])
	if unique_media_data["T-Axis"] == "±n":
		y_axis = 0.0
		modulate = Color.AQUA
	pos = Vector3(x_axis, y_axis, t_axis)
	var media_list: Array[Node] = get_tree().get_nodes_in_group("media_object")
	for i: int in media_list.size():
		media_coordinates.append(media_list[i].pos)
	if media_coordinates.count(pos) != 1:
		pos = Vector3(x_axis + (randf_range(-cluster_distance, cluster_distance)), y_axis + (randf_range(-cluster_distance, cluster_distance)), t_axis + (randf_range(-cluster_distance, cluster_distance)))
	global_translate(pos)
	
	var x_coordinate_text: String = str(unique_media_data["X-Axis"])
	if unique_media_data["X-Axis"] == "":
		x_coordinate_text = "x"
	var y_coordinate_text: String = str(unique_media_data["Y-Axis"])
	if unique_media_data["Y-Axis"] == "":
		y_coordinate_text = "y"
	var t_coordinate_text: String = str(unique_media_data["T-Axis"])
	if unique_media_data["T-Axis"] == "":
		t_coordinate_text = "t"
	coordinates.text = "(%s, %s, %s)" % [x_coordinate_text, y_coordinate_text, t_coordinate_text]
	
	## Tags
	if !unique_media_data["MediaType2"] == "":
		media_type_label.text = "#%s  #%s" % [unique_media_data["MediaType1"], unique_media_data["MediaType2"]]
	else: 
		media_type_label.text = "#%s" % unique_media_data["MediaType1"]

## TODO: FIX SCALING, ADD LERP
func scale_cluster(value: float) -> void:
	cluster_distance = value
	global_position = pos 
	var cluster_random_dist_x: float = randf_range(-cluster_distance, cluster_distance)
	var cluster_random_dist_y: float = randf_range(-cluster_distance, cluster_distance)
	var cluster_random_dist_z: float = randf_range(-cluster_distance, cluster_distance)
	var random_dist: Vector3 = Vector3(cluster_random_dist_x, cluster_random_dist_y, cluster_random_dist_z)
	var tween = get_tree().create_tween()
	tween.tween_property(self, "global_position", pos * scale_multiplier + random_dist, 1.0)

func _scale_pos(multiplier: float) -> void:
	scale_multiplier = multiplier
	global_position = pos
	global_translate(global_position * multiplier)

func _on_area_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if !mouse_in:
		return
	if transparent_toggle:
		return
	if event.is_action_released("select"):
		Global.selectObject.emit(self)
		print("%s has been selected" % name)

func _on_area_3d_mouse_entered() -> void:
	mouse_in = true
	self.material_overlay.set_shader_parameter("line_color", Global.highlight_color)

func _on_area_3d_mouse_exited() -> void:
	mouse_in = false
	if !transparent_toggle:
		material_overlay.set_shader_parameter("line_color", Color(0.94, 0.96, 0.94, 1))
	else:
		material_overlay.set_shader_parameter("line_color", Color(1.0, 1.0, 1.0, 0.0))
