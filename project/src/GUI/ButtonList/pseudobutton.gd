class_name Pseudobutton
extends PanelContainer

@onready var label: Label = $Label

@export var stylebox_normal: StyleBox
@export var stylebox_selected: StyleBox

var binding
var next_button: Pseudobutton
var previous_button: Pseudobutton 
var text: String:
	set(value):
		text = value
		_update_text()
var selected: bool:
	set(value):
		selected = value
		set("theme_override_styles/panel", stylebox_selected if selected else stylebox_normal)
		_update_text()


func _ready() -> void:
	label.text = text
	set("theme_override_styles/panel", stylebox_selected if selected else stylebox_normal)
	_update_text()


func link_next(other_button: Pseudobutton) -> void:
	next_button = other_button
	other_button.previous_button = self


func _update_text() -> void:
	var label_text := text
	if selected:
		label_text = "    " + label_text
	label.text = label_text
