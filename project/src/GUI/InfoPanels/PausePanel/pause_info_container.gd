class_name PauseInfoContainer
extends InfoContainer

signal pause_completed

@onready var menu_list: MenuList = $MenuList

const options = [
	"save and quit",
	"abandon run"
]


func _setup() -> void:
	InputManager.obtain_input_handle(_device).received_input.connect(_on_event)
	for option: String in options:
		menu_list.add_button(option.capitalize(), option)
	menu_list.finish_menu()


func _on_event(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_on_action_button_pressed(menu_list.accept())
	elif event.is_action_pressed("move_down"):
		menu_list.select_next()
	elif event.is_action_pressed("move_up"):
		menu_list.select_previous()
	elif event.is_action_pressed("back"):
		pause_completed.emit()
		InputManager.pop_handle(_device)
		close()


func _on_action_button_pressed(option: String) -> void:
	match option:
		"abandon run":
			get_tree().paused = true
			SaveManager.clear_slot(WorldManager.get_current_slot())
			SignalBus.exit_game.emit()
		"save and quit":
			get_tree().paused = true
			SaveManager.save_world(WorldManager.get_current_slot())
			SignalBus.exit_game.emit()


func _get_control_hint_text_controller() -> String:
	return "Navigate: D-Pad, Accept: A, Cancel: B"


func _get_control_hint_text_keyboard() -> String:
	return "Navigate: Arrow Keys, Accept: Enter, Cancel: Backspace"
