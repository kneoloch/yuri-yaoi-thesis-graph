extends PanelContainer
class_name FilteredSearch

@onready var filter_options: VBoxContainer = %FilterOptions
@onready var grid_container: GridContainer = %GridContainer
@onready var show_all_check_button: CheckButton = %ShowAllCheckButton
var matches: Array[Node] = []

func _ready() -> void:
	Global.initialize.connect(_initialize)

func _initialize() -> void:
	for child in grid_container.get_children():
			child.button_pressed = true

func _on_filter_category_button_pressed() -> void:
	filter_options.visible = !filter_options.visible
	if Global.init:
		get_tree().call_group("media_object", "filtered_transparency", MediaEntry.filtered_array)
	else:
		Global.initialize.emit()
		Global.init = true
		MediaEntry.filtered_array = get_tree().get_nodes_in_group("media_object")
		get_tree().call_group("media_object", "filtered_transparency", MediaEntry.filtered_array)

func _filter_media_type(media_type: String, action: String) -> void:
	var media_list: Array = get_tree().get_nodes_in_group("media_object")
	match action:
		"ADD":
			for entry: MediaEntry in media_list:
				if entry.unique_media_data["MediaType1"] == media_type or entry.unique_media_data["MediaType2"] == media_type:
					if !matches.has(entry):
						matches.append(entry)
		"REMOVE":
			for entry: MediaEntry in media_list:
				if entry.unique_media_data["MediaType1"] == media_type or entry.unique_media_data["MediaType2"] == media_type:
					if matches.has(entry):
						matches.erase(entry)
	Global.filterHide.emit(matches)

func _media_toggle(toggled_on: bool, media_type: String) -> void:
	if toggled_on:
		_filter_media_type(media_type, "ADD")
	else:
		_filter_media_type(media_type, "REMOVE")

func _on_film_check_button_toggled(toggled_on: bool) -> void:
	_media_toggle(toggled_on, "FILM")

func _on_game_check_button_toggled(toggled_on: bool) -> void:
	_media_toggle(toggled_on, "GAME")

func _on_book_check_button_toggled(toggled_on: bool) -> void:
	_media_toggle(toggled_on, "BOOK")

func _on_manga_check_button_toggled(toggled_on: bool) -> void:
	_media_toggle(toggled_on, "MANGA")

func _on_idol_check_button_toggled(toggled_on: bool) -> void:
	_media_toggle(toggled_on, "IDOL")

func _on_band_check_button_toggled(toggled_on: bool) -> void:
	_media_toggle(toggled_on, "BAND")

func _on_series_check_button_toggled(toggled_on: bool) -> void:
	_media_toggle(toggled_on, "SERIES")

func _on_show_all_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		for child in grid_container.get_children():
			child.button_pressed = true
	else:
		for child in grid_container.get_children():
			child.button_pressed = false

func _on_cluster_distance_slider_value_changed(value: float) -> void:
	get_tree().call_group("media_object", "scale_cluster", value)
