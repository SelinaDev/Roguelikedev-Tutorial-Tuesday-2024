class_name Reticle
extends RefCounted

signal targets_selected(targets)

const RETICLE_TEXTURE = preload("res://resources/Textures/reticle_texture.tres")
const LOOK_INFO_CONTAINER = preload("res://src/GUI/InfoPanels/ReticleInfoContainers/LookModePanel/look_info_container.tscn")
const TARGET_INFO_CONTAINER = preload("res://src/GUI/InfoPanels/ReticleInfoContainers/TargetModePanel/target_info_container.tscn")
const BLINK_FREQUENCY = 1.0
const COLOR_RADIUS = Color(Color.RED, 0.5)
const COLOR_LINE = Color(Color.WHITE, 0.5)

var _canvas_item_reticle: RID
var _canvas_item_line: RID
var _canvas_item_radius: RID
var _player_entity: Entity
var _position: Vector2i:
	set = set_position
var _camera_state: PlayerCameraState
var _map_data: MapData
var _device: int
var _cell_size: Vector2
var _blink_tween: Tween
var _visible: bool = true
var _info_container: InfoContainer
@warning_ignore("standalone_expression")
var _info_update: Callable = func() -> void: {}
var _radius: int = 0
var _max_range: int = -1
var _line_config: LineConfig
var _target_faction: UseTarget.TargetFaction = UseTarget.TargetFaction.ALL
@warning_ignore("standalone_expression")
var _accept_func: Callable = func() -> void: {}


func setup(player: Entity) -> Reticle:
	_player_entity = player
	_map_data = _player_entity.map_data
	var player_info := PlayerComponent.get_player_info(player)
	_setup_input(player_info)
	_setup_reticle_visuals(player_info)
	return self


func with_radius(radius: int) -> Reticle:
	_radius = radius
	_canvas_item_radius = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_add_rect(
		_canvas_item_radius,
		Rect2(_cell_size * (-_radius), _cell_size * (_radius * 2 + 1)),
		COLOR_RADIUS
	)
	RenderingServer.canvas_item_set_parent(_canvas_item_radius, _canvas_item_reticle)
	RenderingServer.canvas_item_set_draw_behind_parent(_canvas_item_radius, true)
	return self


func with_line(line_config: LineConfig) -> Reticle:
	_line_config = line_config
	_update_line()
	return self


func with_range(max_range: int) -> Reticle:
	_max_range = max_range
	return self


func with_look_info() -> Reticle:
	if _info_container:
		_info_container.close()
	var player_info := PlayerComponent.get_player_info(_player_entity)
	var info_panel: InfoPanel = player_info.info_display.spawn_panel("Look", LOOK_INFO_CONTAINER, _player_entity)
	_info_container = info_panel.info_container
	_info_update = _update_look_info
	return self


func with_target_info() -> Reticle:
	if _info_container:
		_info_container.close()
	var player_info := PlayerComponent.get_player_info(_player_entity)
	var info_panel: InfoPanel = player_info.info_display.spawn_panel("Look", TARGET_INFO_CONTAINER, _player_entity)
	_info_container = info_panel.info_container
	_info_update = _update_target_info
	_accept_func = _confirm_targets
	return self


func with_target_faction(faction: UseTarget.TargetFaction) -> Reticle:
	_target_faction = faction
	return self


func _setup_reticle_visuals(player_info: PlayerInfo) -> void:
	_canvas_item_reticle = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(_canvas_item_reticle, _map_data.canvas)
	_cell_size = Vector2(Globals.CELL_SIZE)
	RenderingServer.canvas_item_add_texture_rect_region(
		_canvas_item_reticle,
		Rect2(Vector2.ZERO, _cell_size),
		RETICLE_TEXTURE.atlas.get_rid(),
		RETICLE_TEXTURE.region
	)
	RenderingServer.canvas_item_set_z_index(_canvas_item_reticle, DrawableComponent.RenderOrder.UI)
	_camera_state = player_info.player_camera.obtain_state()
	_position = PositionComponent.get_entity_position(_player_entity)
	_blink_tween = Engine.get_main_loop().create_tween().set_loops()
	_blink_tween.tween_interval(BLINK_FREQUENCY / 2.0)
	_blink_tween.tween_callback(_toggle_visibility)


func _setup_input(player_info: PlayerInfo) -> void:
	_device = player_info.device
	InputManager.obtain_input_handle(_device).received_input.connect(_on_event)


func set_position(new_position: Vector2i) -> void:
	_position = new_position
	var transform = Transform2D().translated(_cell_size * Vector2(_position))
	RenderingServer.canvas_item_set_transform(_canvas_item_reticle, transform)
	_camera_state.grid_position = _position
	_update_line()
	_info_update.call()


func _on_event(event: InputEvent) -> void:
	if not event.is_pressed():
		return
	if InputMap.event_is_action(event, "move_up"):
		_position += Vector2i.UP
	elif InputMap.event_is_action(event, "move_down"):
		_position += Vector2i.DOWN
	elif InputMap.event_is_action(event, "move_left"):
		_position += Vector2i.LEFT
	elif InputMap.event_is_action(event, "move_right"):
		_position += Vector2i.RIGHT
	elif InputMap.event_is_action(event, "zoom_in"):
		_camera_state.zoom *= 2
	elif InputMap.event_is_action(event, "zoom_out"):
		_camera_state.zoom /= 2
	elif InputMap.event_is_action(event, "back"):
		_free_reticle()
		var empty_array: Array[Entity] = []
		targets_selected.emit(empty_array)
	elif InputMap.event_is_action(event, "ui_accept"):
		_accept_func.call()


func _update_look_info() -> void:
	assert(_info_container is LookInfoContainer)
	var tile: Tile = _map_data.tiles.get(_position, null)
	if not tile:
		return
	var entities: Array[Entity] = _map_data.get_entities_at(_position)
	_info_container.set_look_info(tile, entities)


func _update_target_info() -> void:
	assert(_info_container is TargetInfoContainer)
	var target_error := _evaluate_target_position()
	if target_error.is_empty():
		_info_container.set_target_info(_get_targets())
	else:
		_info_container.set_target_error(target_error)


func _update_line() -> void:
	if not _line_config:
		return
	if not _canvas_item_line.is_valid():
		_canvas_item_line = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_clear(_canvas_item_line)
	RenderingServer.canvas_item_set_parent(_canvas_item_line, _canvas_item_reticle)
	RenderingServer.canvas_item_set_draw_behind_parent(_canvas_item_line, true)
	RenderingServer.canvas_item_set_z_index(_canvas_item_line, DrawableComponent.RenderOrder.UI)
	var line := _map_data.draw_line(PositionComponent.get_entity_position(_player_entity), _position, _line_config)
	for point: Vector2i in line:
		RenderingServer.canvas_item_add_rect(
			_canvas_item_line,
			Rect2i(Vector2(_position - point) * _cell_size * -1.0, _cell_size),
			COLOR_LINE
		)


func _evaluate_target_position() -> String:
	var _player_position := PositionComponent.get_entity_position(_player_entity)
	var _player_position_component: PositionComponent = _player_entity.get_component(Component.Type.Position)
	var _player_index := PlayerComponent.get_player_index(_player_entity)
	if _max_range >= 0 and _player_position_component.distance_to(_position) > _max_range:
		return "Selected position is out of range"
	if not _map_data.is_in_fov(_position, _player_index):
		return "Selected position is out of sight"
	if _line_config and _map_data.cast_ray(_player_position, _position, _line_config) != _position:
		return "Path to selected position is interrupted."
	return ""


func _is_valid_target_position() -> bool:
	return _evaluate_target_position().is_empty()


func _get_targets() -> Array[Entity]:
	var targets := _map_data.get_entities([Component.Type.Position])
	targets = targets.filter(
		func(e: Entity) -> bool:
			var position_component: PositionComponent = e.get_component(Component.Type.Position)
			return position_component.distance_to(_position) <= _radius
	)
	targets = UseTarget.filter_faction(_player_entity, targets, _target_faction)
	return targets


func _confirm_targets() -> void:
	if not _is_valid_target_position():
		return
	targets_selected.emit(_get_targets())
	_free_reticle()


func _toggle_visibility() -> void:
	_visible = not _visible
	RenderingServer.canvas_item_set_visible(_canvas_item_reticle, _visible)


func _free_reticle() -> void:
	InputManager.pop_handle(_device)
	_camera_state.discard()
	RenderingServer.canvas_item_clear(_canvas_item_reticle)
	_canvas_item_reticle = RID()
	if _canvas_item_radius.is_valid():
		RenderingServer.canvas_item_clear(_canvas_item_radius)
		_canvas_item_radius = RID()
	if _canvas_item_line.is_valid():
		RenderingServer.canvas_item_clear(_canvas_item_line)
		_canvas_item_line = RID()
	_info_container.close()
	_blink_tween.kill()
