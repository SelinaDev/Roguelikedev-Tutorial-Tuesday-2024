extends GameState

const NOT_CONNECTED_TEXT = "Second Player: Press <A> Button or <Enter> Key to join"
const CONNECTED_TEXT = "Second Player joined: Press <B> Button or <Escape> Key to disconnect"

@export_file("*tscn") var main_game_path_1p
@export_file("*tscn") var main_game_path_2p
@export_file("*.tscn") var level_generator_scene
@export_file("*.tscn") var loading_screen_scene

@onready var label: Label = $MarginContainer/HBoxContainer/Label
@onready var start_button: Button = $MarginContainer/HBoxContainer/VBoxContainer/StartButton
@onready var slot_selection_panel: SlotSelectionPanel = $CenterContainer/SlotSelectionPanel

var main_device: int
var other_devices: Array[int]


func enter(data: Dictionary = {}) -> void:
	assert(data.has("devices"))
	main_device = data.devices.front()
	other_devices = []
	for device: int in data.devices.slice(1):
		other_devices.append(device)


func _ready() -> void:
	InputManager.reset()
	start_button.grab_focus.call_deferred()
	_update_devices_label()


func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.is_action("device_join"):
		var index: int = InputManager.get_device_index(event)
		if index != main_device and not index in other_devices and other_devices.size() <= 1:
			other_devices.append(index)
			_update_devices_label()
	if event.is_action("device_disconnect"):
		var index: int = InputManager.get_device_index(event)
		if index in other_devices:
			other_devices.erase(index)
			_update_devices_label()


func _on_start_button_pressed() -> void:
	slot_selection_panel.open("New Game", _start_game.bind(true))


func _on_load_button_pressed() -> void:
	slot_selection_panel.open("New Game", _start_game.bind(false))


func _start_game(slot: int, new: bool) -> void:
	var all_devices := [main_device] + other_devices
	all_devices = all_devices.slice(0, 2)
	var scenes := [main_game_path_1p, main_game_path_2p]
	var num_devices := all_devices.size()
	var data := {
		"devices": all_devices,
		"slot": slot,
		"new": new,
		"game_scene": scenes[mini(scenes.size(), num_devices) - 1]
	}
	if new:
		transition_requested.emit(level_generator_scene, data)
	else:
		transition_requested.emit(loading_screen_scene, data)
	


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _update_devices_label() -> void:
	label.text = NOT_CONNECTED_TEXT if other_devices.is_empty() else CONNECTED_TEXT


func _on_slot_selection_panel_slot_selection_panel_closed() -> void:
	start_button.grab_focus()
