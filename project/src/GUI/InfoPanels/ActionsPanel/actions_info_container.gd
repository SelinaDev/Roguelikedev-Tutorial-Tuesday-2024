extends InfoContainer

signal action_selected(action)

@onready var actions_list: VBoxContainer = $ScrollContainer/ActionsList


const actions = [
	"attack",
	"close",
	"open",
	"look"
]

const action_mapping_controller = {
	"look": "X"
}

const action_mapping_keyboard = {
	"attack": "A",
	"close": "C",
	"open": "O",
	"look": "L"
}


func _setup() -> void:
	InputManager.obtain_input_handle(_device).received_input.connect(_on_event)
	var _first_button: Button = null
	for action: String in actions:
		var button := _create_action_button(action)
		actions_list.add_child(button)
		if not _first_button:
			_first_button = button
	if _first_button:
		_first_button.grab_focus()
	var action_buttons: Array = actions_list.get_children()
	if not action_buttons.is_empty():
		for i: int in action_buttons.size():
			var prev_button: Button = action_buttons[(i - 1) % action_buttons.size()]
			var button: Button = action_buttons[i]
			var next_button: Button = action_buttons[(i + 1) % action_buttons.size()]
			var prev_button_path := button.get_path_to(prev_button)
			var next_button_path := button.get_path_to(next_button)
			
			button.focus_neighbor_bottom = next_button_path
			button.focus_neighbor_right = next_button_path
			button.focus_next = next_button_path
			
			button.focus_neighbor_top = prev_button_path
			button.focus_neighbor_left = prev_button_path
			button.focus_previous = prev_button_path


func _on_event(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	if event.is_action_pressed(&"back"):
		_submit_action(null)


func _create_action_button(action: String) -> Button:
	var action_button := Button.new()
	var mapping: Dictionary = action_mapping_keyboard if _device == -1 else action_mapping_controller
	action_button.text = action.capitalize()
	var hint_text: String = mapping.get(action, "")
	if not hint_text.is_empty():
		action_button.text += " (" + hint_text + ")"
	action_button.pressed.connect(_on_action_button_pressed.bind(action))
	action_button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	return action_button


func _on_action_button_pressed(action_name: String) -> void:
	var action: Action = null
	match action_name:
		"attack":
			action = await DirectionGetter.new(
				_player,
				"Attack",
				MeleeAction.new(_player, Vector2i.ZERO)
			).direction_selected
		"close":
			action = await DirectionGetter.new(
				_player,
				"Close",
				CloseAction.new(_player, Vector2i.ZERO)
			).direction_selected
		"open":
			action = await DirectionGetter.new(
				_player,
				"Open",
				OpenAction.new(_player, Vector2i.ZERO)
			).direction_selected
		"look":
			_spawn_reticle()
	if action:
		_submit_action(action)


func _submit_action(action: Action) -> void:
	InputManager.pop_handle(_device)
	action_selected.emit(action)
	close()


func _get_control_hint_text_controller() -> String:
	return "Navigate: D-Pad, Accept: A, Cancel: B"


func _get_control_hint_text_keyboard() -> String:
	return "Navigate: Arrow Keys, Accept: Enter, Cancel: Backspace"


func _spawn_reticle() -> void:
	var reticle := Reticle.new()
	reticle.setup(_player)
	await reticle.reticle_finished
