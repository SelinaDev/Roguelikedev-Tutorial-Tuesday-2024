class_name MenuList
extends ScrollContainer

const PSEUDOBUTTON = preload("res://src/GUI/ButtonList/pseudobutton.tscn")

@onready var list: VBoxContainer = $List

var _selected_button: Pseudobutton:
	set(value):
		if _selected_button:
			_selected_button.selected = false
		_selected_button = value
		_selected_button.selected = true


func add_button(text: String, binding = null) -> void:
	var pseudobutton: Pseudobutton = PSEUDOBUTTON.instantiate()
	list.add_child(pseudobutton)
	pseudobutton.text = text
	pseudobutton.binding = binding


func finish_menu() -> void:
	var buttons := list.get_children()
	if buttons.is_empty():
		return
	_selected_button = buttons.front()
	for i: int in buttons.size():
		var button: Pseudobutton = buttons[i]
		var next_button: Pseudobutton = buttons[(i + 1) % buttons.size()]
		button.link_next(next_button)


func select_next() -> void:
	_selected_button = _selected_button.next_button


func select_previous() -> void:
	_selected_button = _selected_button.previous_button


func accept():
	return _selected_button.binding
