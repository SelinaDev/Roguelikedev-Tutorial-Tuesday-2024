extends GameState

@export_file("*.tscn") var main_menu_path


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		_to_main_menu(-1)
	elif event is InputEventJoypadButton:
		_to_main_menu(event.device)


func _to_main_menu(device: int) -> void:
	transition_requested.emit(main_menu_path, {"device": device})
