class_name SlotSelectionPanel
extends PanelContainer

signal slot_selection_panel_closed

const SLOT_FREE_TEXT = "FREE"
const SLOT_USED_TEXT = "SLOT USED"

@onready var label: Label = $VBoxContainer/Label
@onready var slot_1_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer/Slot1Button
@onready var slot_2_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer/Slot2Button
@onready var slot_3_button: Button = $VBoxContainer/HBoxContainer/VBoxContainer/Slot3Button
var _buttons: Array[Button]
var _callback: Callable


func _ready() -> void:
	visible = false
	_buttons = [slot_1_button, slot_2_button, slot_3_button]
	for i: int in SaveManager.NUM_SLOTS:
		var slot_num := i + 1
		var slot_used := SaveManager.is_slot_used(slot_num)
		var button: Button = _buttons[i]
		button.text = _get_slot_text(slot_num)
		button.pressed.connect(_on_button_pressed.bind(slot_num))
		
		var prev_button: Button = _buttons[(i - 1) % _buttons.size()]
		var prev_button_path := button.get_path_to(prev_button)
		var next_button: Button = _buttons[(i + 1) % _buttons.size()]
		var next_button_path := button.get_path_to(next_button)
		
		button.focus_neighbor_bottom = next_button_path
		button.focus_neighbor_right = next_button_path
		button.focus_next = next_button_path
		
		button.focus_neighbor_top = prev_button_path
		button.focus_neighbor_left = prev_button_path
		button.focus_previous = prev_button_path


func _get_slot_text(slot: int) -> String:
	if SaveManager.is_slot_used(slot):
		var metadata := SaveManager.get_metadata(slot)
		if metadata:
			return ", ".join(metadata.player_names)
		else:
			return SLOT_USED_TEXT
	else:
		return SLOT_FREE_TEXT


func _on_button_pressed(slot_num: int) -> void:
	close()
	_callback.call(slot_num)


func open(title: String, callback: Callable) -> void:
	label.text = title
	_callback = callback
	(_buttons.front() as Button).grab_focus()
	visible = true


func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("back", false):
		close()
	if event is InputEventMouseButton and not Rect2(Vector2(), size).has_point(get_local_mouse_position()):
		close()


func close() -> void:
	visible = false
	slot_selection_panel_closed.emit()
