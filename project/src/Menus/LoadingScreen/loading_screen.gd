extends GameState

@onready var progress_bar: ProgressBar = $CenterContainer/VBoxContainer/ProgressBar

var _save_manager: SaveManager
var _data: Dictionary
var _slot: int


func enter(data: Dictionary = {}) -> void:
	_data = data
	_slot = data.get("slot", 1)
	_save_manager = SaveManager.new(_slot)
	_save_manager.start_loading()


func _process(_delta: float) -> void:
	var status := _save_manager.get_status()
	# TODO: Error Handling
	progress_bar.value = _save_manager.progress
	match status:
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			_progress_to_game()
		_:
			pass


func _progress_to_game() -> void:
	var player_info: Array[PlayerInfo] = []
	var world: World = _save_manager.get_world()
	var player_entities = world.get_player_entities()
	for i: int in _data.devices.size():
		var device: int = _data.devices[i]
		var entity: Entity = player_entities[i]
		player_info.append(_create_player_info(i, device, entity))
		var player_component: PlayerComponent = entity.get_component(Component.Type.Player)
		player_component.player_info = player_info[i]
	WorldManager.set_world(world, _slot)
	_data["player_info"] = player_info
	transition_requested.emit(_data.get("game_scene"), _data)


func _create_player_info(player_index: int, device: int, entity: Entity) -> PlayerInfo:
	var info := PlayerInfo.new()
	info.device = device
	info.player_index = player_index
	info.player_entity = entity
	return info
