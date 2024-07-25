class_name Bar
extends Label

@export_color_no_alpha var fill_color: Color
@export_color_no_alpha var background_color: Color
@export var stat_name: String

var max_value: int:
	set(new_max_value):
		progress_bar.max_value = new_max_value
		max_value = new_max_value
		_update_label()
var value: int:
	set(new_value):
		progress_bar.value = new_value
		value = new_value
		_update_label()

@onready var progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	var style_box_fill := StyleBoxFlat.new()
	style_box_fill.bg_color = fill_color
	progress_bar.set(&"theme_override_styles/fill", style_box_fill)
	var style_box_background := StyleBoxFlat.new()
	style_box_background.bg_color = background_color
	progress_bar.set(&"theme_override_styles/background", style_box_background)
	_update_label()


func _update_label() -> void:
	text = "%s: %d/%d" % [stat_name, value, max_value]
