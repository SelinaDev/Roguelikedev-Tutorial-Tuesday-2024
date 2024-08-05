class_name PlayerActorComponent
extends ActorComponent

const ACTIONS_INFO_CONTAINER = preload("res://src/GUI/InfoPanels/ActionsPanel/actions_info_container.tscn")
const INVENTORY_INFO_CONTAINER = preload("res://src/GUI/InfoPanels/InventoryPanel/inventory_info_container.tscn")

var device: int


func set_device(new_device: int) -> void:
	device = new_device
	InputManager.obtain_input_handle(device).received_input.connect(_on_event)


func _on_event(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	if event.is_action_pressed("zoom_in"):
		_parent_entity.process_message(Message.new("zoom_in"))
	elif event.is_action_pressed("zoom_out"):
		_parent_entity.process_message(Message.new("zoom_out"))
	
	if event.is_action_pressed("move_left"):
		_queued_action = BumpAction.new(_parent_entity, Vector2i.LEFT)
	elif event.is_action_pressed("move_right"):
		_queued_action = BumpAction.new(_parent_entity, Vector2i.RIGHT)
	elif event.is_action_pressed("move_up"):
		_queued_action = BumpAction.new(_parent_entity, Vector2i.UP)
	elif event.is_action_pressed("move_down"):
		_queued_action = BumpAction.new(_parent_entity, Vector2i.DOWN)
	elif event.is_action_pressed("wait"):
		_queued_action = WaitAction.new(_parent_entity)
	elif event.is_action_pressed("look"):
		_spawn_reticle()
	
	elif event.is_action_pressed("attack"):
		_queued_action = await DirectionGetter.new(
			_parent_entity,
			"Attack",
			MeleeAction.new(_parent_entity, Vector2i.ZERO)
		).direction_selected
	
	elif event.is_action_pressed("open"):
		_queued_action = await DirectionGetter.new(
			_parent_entity,
			"Open",
			OpenAction.new(_parent_entity, Vector2i.ZERO)
		).direction_selected
	
	elif event.is_action_pressed("close"):
		_queued_action = await DirectionGetter.new(
			_parent_entity,
			"Close",
			CloseAction.new(_parent_entity, Vector2i.ZERO)
		).direction_selected
	
	elif event.is_action_pressed("pickup"):
		_queued_action = PickupAction.new(_parent_entity, Vector2i.ZERO)
	
	elif event.is_action_pressed("actions"):
		_spawn_actions_menu()
	
	elif event.is_action_pressed("inventory"):
		_spawn_inventory_list()
	
	elif event.is_action_pressed("interact"):
		_queued_action = InteractAction.new(_parent_entity, Vector2i.ZERO)
	
	elif event.is_action_pressed("drop"):
		var item: Entity = await _get_item_from_inventory()
		if item:
			_queued_action = DropAction.new(_parent_entity, item)


func _spawn_reticle() -> void:
	var reticle := Reticle.new()
	reticle.setup(_parent_entity).with_look_info()
	var _targets = await reticle.targets_selected


func _spawn_actions_menu() -> void:
	var player_info: PlayerInfo = PlayerComponent.get_player_info(_parent_entity)
	var info_panel: InfoPanel = player_info.info_display.spawn_panel("Actions", ACTIONS_INFO_CONTAINER, _parent_entity)
	_queued_action = await info_panel.info_container.action_selected


func _spawn_inventory_menu() -> InventoryInfoContainer:
	var player_info: PlayerInfo = PlayerComponent.get_player_info(_parent_entity)
	var info_panel: InfoPanel = player_info.info_display.spawn_panel("Inventory", INVENTORY_INFO_CONTAINER, _parent_entity)
	return info_panel.info_container


func _spawn_inventory_list() -> void:
	var inventory_container := _spawn_inventory_menu()
	inventory_container.set_mode_list()
	_queued_action = await inventory_container.action_selected


func _get_item_from_inventory() -> Entity:
	var inventory_container := _spawn_inventory_menu()
	inventory_container.set_mode_select()
	return await inventory_container.item_selected
