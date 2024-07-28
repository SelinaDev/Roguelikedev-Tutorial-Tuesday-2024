class_name InventoryInfoContainer
extends InfoContainer

signal item_selected(item)
signal action_selected(action)

const ITEM_INFO_CONTAINER = preload("res://src/GUI/InfoPanels/ItemPanel/item_info_container.tscn")

enum Mode {
	LIST,
	SELECT
}

@onready var menu_list: MenuList = $MenuList

var mode: Mode = Mode.SELECT


func _setup() -> void:
	InputManager.obtain_input_handle(_device).received_input.connect(_on_event)
	var inventory: InventoryComponent = _player.get_component(Component.Type.Inventory)
	if inventory.items.is_empty():
		_setup_empty_label()
		return
	for item: Entity in inventory.items:
		menu_list.add_button(item.name, item)
	menu_list.finish_menu()


func set_mode_list() -> void:
	mode = Mode.LIST


func set_mode_select() -> void:
	mode = Mode.SELECT


func _setup_empty_label() -> void:
	var empty_label := Label.new()
	add_child(empty_label)
	empty_label.text = "Inventory empty"
	empty_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	empty_label.size_flags_vertical = Control.SIZE_EXPAND_FILL


func _on_event(event: InputEvent) -> void:
	if event.is_action_pressed("back"):
		match mode:
			Mode.SELECT:
				_submit_item(null)
			Mode.LIST:
				_submit_action(null)
	elif event.is_action_pressed("move_up"):
		menu_list.select_previous()
	elif event.is_action_pressed("move_down"):
		menu_list.select_next()
	elif event.is_action_pressed("ui_accept"):
		_on_item_selected(menu_list.accept())


func _submit_action(action: Action) -> void:
	action_selected.emit(action)
	_cleanup()


func _submit_item(item: Entity) -> void:
	item_selected.emit(item)
	_cleanup()


func _cleanup() -> void:
	InputManager.pop_handle(_device)
	close()


func _on_item_selected(item: Entity) -> void:
	match mode:
		Mode.SELECT:
			_submit_item(item)
		Mode.LIST:
			# TODO
			_use_item(item)


func _use_item(item: Entity) -> void:
	var player_info := PlayerComponent.get_player_info(_player)
	var item_info_container: ItemInfoContainer = player_info.info_display.spawn_panel(item.name, ITEM_INFO_CONTAINER, _player).info_container
	item_info_container.setup_item(item)
	var action: Action = await item_info_container.action_selected
	if action != null:
		_submit_action(action)
