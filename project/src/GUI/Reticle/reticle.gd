class_name Reticle
extends RefCounted

signal reticle_finished

const RETICLE_TEXTURE = preload("res://resources/Textures/reticle_texture.tres")
const LOOK_INFO_CONTAINER = preload("res://src/GUI/InfoPanels/LookModePanel/look_info_container.tscn")
const BLINK_FREQUENCY = 1.0

var _canvas_item: RID
var _player_entity: Entity
var _position: Vector2i:
	set = set_position
var _camera_state: PlayerCameraState
var _map_data: MapData
var _device: int
var _cell_size: Vector2
var _tween: Tween
var _visible: bool = true
var _info_container: LookInfoContainer


func setup(player: Entity) -> void:
	_player_entity = player
	_map_data  = _player_entity.map_data
	var player_info: PlayerInfo = (_player_entity.get_component(Component.Type.Player) as PlayerComponent).player_info
	var info_panel: InfoPanel = player_info.info_display.spawn_panel("Look", LOOK_INFO_CONTAINER, player)
	_info_container = info_panel.info_container
	_canvas_item = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(_canvas_item, _map_data.canvas)
	_cell_size = Vector2(ProjectSettings.get_setting("global/cell_size"))
	RenderingServer.canvas_item_add_texture_rect_region(
		_canvas_item,
		Rect2(Vector2i.ZERO, _cell_size),
		RETICLE_TEXTURE.atlas.get_rid(),
		RETICLE_TEXTURE.region
	)
	RenderingServer.canvas_item_set_z_index(_canvas_item, DrawableComponent.RenderOrder.UI)
	_camera_state = player_info.player_camera.obtain_state()
	_device = player_info.device
	InputManager.obtain_input_handle(_device).received_input.connect(_on_event)
	_position = PositionComponent.get_entity_position(_player_entity)
	_tween = Engine.get_main_loop().create_tween().set_loops()
	_tween.tween_interval(BLINK_FREQUENCY / 2.0)
	_tween.tween_callback(_toggle_visibility)


func _toggle_visibility() -> void:
	_visible = not _visible
	RenderingServer.canvas_item_set_visible(_canvas_item, _visible)


func set_position(new_position: Vector2i) -> void:
	_position = new_position
	var transform = Transform2D().translated(_cell_size * Vector2(_position))
	RenderingServer.canvas_item_set_transform(_canvas_item, transform)
	_camera_state.grid_position = _position
	_update_look_info()


func _update_look_info() -> void:
	var tile: Tile = _map_data.tiles.get(_position, null)
	if not tile:
		return
	var entities: Array[Entity] = _map_data.get_entities_at(_position)
	_info_container.set_look_info(tile, entities)


func _on_event(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	if event.is_action_pressed("move_up"):
		_position += Vector2i.UP
	elif event.is_action_pressed("move_down"):
		_position += Vector2i.DOWN
	elif event.is_action_pressed("move_left"):
		_position += Vector2i.LEFT
	elif event.is_action_pressed("move_right"):
		_position += Vector2i.RIGHT
	elif event.is_action_pressed("zoom_in"):
		_camera_state.zoom *= 2
	elif event.is_action_pressed("zoom_out"):
		_camera_state.zoom /= 2
	elif event.is_action_pressed("back"):
		_free_reticle()


func _free_reticle() -> void:
	InputManager.pop_handle(_device)
	_camera_state.discard()
	RenderingServer.canvas_item_clear(_canvas_item)
	_canvas_item = RID()
	_info_container.close()
	_tween.kill()
