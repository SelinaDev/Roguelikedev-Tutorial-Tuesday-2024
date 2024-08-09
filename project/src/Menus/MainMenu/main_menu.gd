extends GameState

@export_file("*tscn") var main_game_path_1p
@export_file("*tscn") var main_game_path_2p
@export_file("*.tscn") var level_generator_scene
@export_file("*.tscn") var loading_screen_scene

@onready var devices_label: Label = $CenterContainer/VBoxContainer/DevicesLabel
@onready var start_button: Button = $CenterContainer/VBoxContainer/StartButton

var main_device: int
var other_devices: Array[int]


func enter(data: Dictionary = {}) -> void:
	assert(data.has("device"))
	main_device = data.device


func _ready() -> void:
	start_button.grab_focus.call_deferred()


func _input(event: InputEvent) -> void:
	if not event.is_pressed() or event.is_echo():
		return
	if event.is_action("device_join"):
		var index: int = InputManager.get_device_index(event)
		if index != main_device and not index in other_devices:
			other_devices.append(index)
			_update_devices_label()
	if event.is_action("device_disconnect"):
		var index: int = InputManager.get_device_index(event)
		if index in other_devices:
			other_devices.erase(index)
			_update_devices_label()


func _on_start_button_pressed() -> void:
	_start_game(1, true)


func _on_load_button_pressed() -> void:
	_start_game(1, false)


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
	devices_label.text = "Connected devices: %s" % ", ".join(other_devices)
