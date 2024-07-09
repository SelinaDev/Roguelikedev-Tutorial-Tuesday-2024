extends GameState

@export_file("*tscn") var main_game_path_1p
@export_file("*tscn") var main_game_path_2p

@onready var devices_label: Label = $CenterContainer/VBoxContainer/DevicesLabel

var main_device: int
var other_devices: Array[int]


func enter(data: Dictionary = {}) -> void:
	assert(data.has("device"))
	main_device = data.device


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
	var all_devices := [main_device] + other_devices
	var data := {"devices": all_devices}
	if all_devices.size() == 1:
		transition_requested.emit(main_game_path_1p, data)
	else:
		transition_requested.emit(main_game_path_2p, data)


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _update_devices_label() -> void:
	devices_label.text = "Connected devices: %s" % ", ".join(other_devices)
