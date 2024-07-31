extends InfoContainer

signal action_selected(action)

const INVENTORY_INFO_CONTAINER = preload("res://src/GUI/InfoPanels/InventoryPanel/inventory_info_container.tscn")

@onready var menu_list: MenuList = $MenuList


const actions = [
	"attack",
	"close",
	"inventory",
	"look",
	"open",
	"pickup"
]

const action_mapping_controller = {
	"look": "X",
	"inventory": "Y"
}

const action_mapping_keyboard = {
	"attack": "A",
	"close": "C",
	"inventory": "I",
	"open": "O",
	"look": "L",
	"pickup": "P"
}



func _setup() -> void:
	InputManager.obtain_input_handle(_device).received_input.connect(_on_event)
	for action: String in actions:
		_create_action_button(action)
	menu_list.finish_menu()


func _on_event(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	if event.is_action_pressed("ui_accept"):
		_on_action_button_pressed(menu_list.accept())
	elif event.is_action_pressed("move_down"):
		menu_list.select_next()
	elif event.is_action_pressed("move_up"):
		menu_list.select_previous()
	elif event.is_action_pressed("back"):
		_submit_action(null)


func _create_action_button(action: String) -> void:
	var mapping: Dictionary = action_mapping_keyboard if _device == -1 else action_mapping_controller
	var action_text = action.capitalize()
	var hint_text: String = mapping.get(action, "")
	if not hint_text.is_empty():
		action_text += " (" + hint_text + ")"
	menu_list.add_button(action_text, action)


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
		"pickup":
			action = PickupAction.new(_player, Vector2i.ZERO)
		"inventory":
			action = await _spawn_inventory()
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


func _spawn_inventory() -> Action:
	var player_info: PlayerInfo = PlayerComponent.get_player_info(_player)
	var inventory_info: InventoryInfoContainer = player_info.info_display.spawn_panel("Inventory", INVENTORY_INFO_CONTAINER, _player).info_container
	inventory_info.set_mode_list()
	return await inventory_info.action_selected
