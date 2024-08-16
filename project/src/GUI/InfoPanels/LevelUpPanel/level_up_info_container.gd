class_name LevelUpInfoContainer
extends InfoContainer

signal level_up_completed

@onready var menu_list: MenuList = $MenuList


func _setup() -> void:
	InputManager.obtain_input_handle(_device).received_input.connect(_on_event)
	menu_list.add_button("Increase Max HP (+20)", _level_up_increase_hp)
	menu_list.add_button("Increase Power (+1)", _level_up_increase_power)
	menu_list.add_button("Increase Defense (+1)", _level_up_increase_defense)
	menu_list.finish_menu()


func _level_up_increase_hp() -> void:
	var increase_amount: int = 20
	_player.process_message(Message.new("increase_max_hp", {"amount": increase_amount}))
	Log.send_log(
		"%s feels healthier." % _player.get_entity_name(),
		Log.COLOR_POSITIVE
	)


func _level_up_increase_power() -> void:
	var incease_amount: int = 1
	_player.process_message(Message.new("increase_power", {"amount": incease_amount}))
	Log.send_log(
		"%s feels stronger." % _player.get_entity_name(),
		Log.COLOR_POSITIVE
	)


func _level_up_increase_defense() -> void:
	var increase_amount: int = 1
	_player.process_message(Message.new("increase_defense", {"amount": increase_amount}))
	Log.send_log(
		"%s feels more durable." % _player.get_entity_name(),
		Log.COLOR_POSITIVE
	)


func _on_event(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		menu_list.accept().call()
		InputManager.pop_handle(_device)
		close()
		level_up_completed.emit()
	elif event.is_action_pressed("move_down"):
		menu_list.select_next()
	elif event.is_action_pressed("move_up"):
		menu_list.select_previous()
