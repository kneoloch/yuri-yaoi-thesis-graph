extends Node3D
class_name World

@onready var background: WorldEnvironment = %Background
@onready var grid: Sprite3D = %Grid
@onready var grid_2: Sprite3D = %Grid2
@onready var theme_color_button: Button = %ThemeColorButton
@onready var scale_slider: HSlider = %ScaleSlider
@onready var x_axis: CSGCylinder3D = %XAxis
@onready var y_axis: CSGCylinder3D = %YAxis
@onready var t_axis: CSGCylinder3D = %TAxis
@onready var pos_x: Labels = %X
@onready var neg_x: Labels = %"-X"
@onready var pos_y: Labels = %Y
@onready var neg_y: Labels = %"-Y"
@onready var pos_z: Labels = %Z
@onready var neg_z: Labels = %"-Z"
@onready var grid_color_picker: ColorPickerButton = %GridColorPicker
@onready var bg_color_picker: ColorPickerButton = %BGColorPicker
@onready var highlight_color_picker: ColorPickerButton = %HighlightColorPicker
@onready var twin_towers_animated: AnimatedSprite3D = %TwinTowersAnimated
@onready var config_settings: VBoxContainer = %ConfigSettings
var white: Color = Color(0.94, 0.96, 0.94, 1)
var black: Color = Color(0.13, 0.13, 0.13, 1)
var default_light_theme_grid_color: Color = black * Color(1, 1, 1, 0.19)
var default_dark_theme_grid_color: Color = white
var custom_theme_bg_color: Color = Color(0.294, 0.596, 0.651, 1.0)
var custom_theme_grid_color: Color = Color(0.0, 1.0, 0.569, 1.0)

func _ready() -> void:
	_theme_color(Global.curr_theme)
	grid_color_picker.color = custom_theme_grid_color
	bg_color_picker.color = custom_theme_bg_color
	highlight_color_picker.color = Global.highlight_color
	Global.themeColor.connect(_theme_color)

func _theme_color(theme_color: Global.ThemeColor) -> void:
	match theme_color:
		Global.ThemeColor.LIGHT:
			background.environment.background_color = white
			grid.material_override.set_shader_parameter("gridColor", default_light_theme_grid_color)
			twin_towers_animated.hide()
		Global.ThemeColor.DARK:
			background.environment.background_color = black
			grid.material_override.set_shader_parameter("gridColor", default_dark_theme_grid_color)
			twin_towers_animated.hide()
		Global.ThemeColor.CUSTOM:
			background.environment.background_color = custom_theme_bg_color
			grid.material_override.set_shader_parameter("gridColor", custom_theme_grid_color)
			twin_towers_animated.show()
			twin_towers_animated.play("default", 3.0)

func _on_scale_slider_value_changed(value: float) -> void:
	var multiplier: float = value - 1
	Global.scaleAxis.emit(multiplier) # media_entry.global_position * new_multiplier
	grid.material_override.set_shader_parameter("unitSize", value)
	grid.material_override.set_shader_parameter("fadeEnd", 14 * value)
	grid.scale = Vector3(16.7 * value, 16.7 * value, 16.7 * value)
	x_axis.height = 20 * value
	y_axis.height = 20 * value
	t_axis.height = 20 * value
	pos_x.position.x = value * 12
	neg_x.position.x = -value * 12
	pos_y.position.y = value * 11
	neg_y.position.y = -value * 11
	pos_z.position.z = value * 12
	neg_z.position.z = -value * 12

func _on_theme_color_button_pressed() -> void:
	Global.curr_theme += 1 as Global.ThemeColor
	if Global.curr_theme > 2:
		Global.curr_theme = 0 as Global.ThemeColor
	match Global.curr_theme as Global.ThemeColor:
		Global.ThemeColor.LIGHT:
			_theme_color(Global.ThemeColor.LIGHT)
			theme_color_button.text = "Light"
		Global.ThemeColor.DARK:
			_theme_color(Global.ThemeColor.DARK)
			theme_color_button.text = "Dark"
		Global.ThemeColor.CUSTOM:
			_theme_color(Global.ThemeColor.CUSTOM)
			theme_color_button.text = "Custom"

func _on_color_picker_button_color_changed(color: Color) -> void:
	custom_theme_grid_color = color
	_theme_color(Global.ThemeColor.CUSTOM)
	theme_color_button.text = "Custom"
	Global.curr_theme = 2 as Global.ThemeColor

func _on_bg_color_picker_color_changed(color: Color) -> void:
	custom_theme_bg_color = color
	_theme_color(Global.ThemeColor.CUSTOM)
	theme_color_button.text = "Custom"
	Global.curr_theme = 2 as Global.ThemeColor

func _on_highlight_color_picker_color_changed(color: Color) -> void:
	Global.highlight_color = color

func _on_collapse_button_pressed() -> void:
	config_settings.visible = !config_settings.visible
