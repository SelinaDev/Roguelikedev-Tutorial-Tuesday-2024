class_name ItemInfoContainer
extends InfoContainer

signal action_selected(action)

@onready var menu_list: MenuList = $MenuList

var _item: Entity


func _setup() -> void:
	InputManager.obtain_input_handle(_device).received_input.connect(_on_event)


func setup_item(item: Entity) -> void:
	_item = item
	
	var use_component: UsableComponent = item.get_component(Component.Type.Use)
	if use_component:
		menu_list.add_button(
			use_component.get_use_verb_active().capitalize(),
			_on_use_button_pressed.bind(use_component.targeting)
		)
	
	var equippable_component: EquippableComponent = item.get_component(Component.Type.Equippable)
	var equipment_component: EquipmentComponent = _player.get_component(Component.Type.Equipment)
	if equippable_component and equipment_component:
		menu_list.add_button(
			"Unequip" if equipment_component.is_equipped(item) else "Equip",
			_submit_action.bind(EquipAction.new(_player, item))
		)
	
	menu_list.add_button(
		"Drop", 
		_on_drop_button_pressed
	)
	
	menu_list.finish_menu()


func _on_event(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		menu_list.select_previous()
	elif event.is_action_pressed("move_down"):
		menu_list.select_next()
	elif event.is_action_pressed("ui_accept"):
		menu_list.accept().call()
	elif event.is_action_pressed("back"):
		_submit_action(null)


func _on_drop_button_pressed() -> void:
	var drop_action := DropAction.new(_player, _item)
	_submit_action(drop_action)


func _on_use_button_pressed(use_target: UseTarget) -> void:
	var targets := await use_target.get_targets(_player)
	var use_action: Action = null
	if not targets.is_empty():
		use_action = UseAction.new(_player, _item, targets)
	_submit_action(use_action)


func _submit_action(action: Action) -> void:
	InputManager.pop_handle(_device)
	close()
	action_selected.emit(action)
