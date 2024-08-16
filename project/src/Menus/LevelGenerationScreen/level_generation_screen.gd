extends GameState

const WORLD_CONFIG: WorldConfig = preload("res://resources/MapGeneration/world_config.tres")

@onready var progress_bar: ProgressBar = $CenterContainer/VBoxContainer/ProgressBar

var _progress_mutex := Mutex.new()
var _progress: int = 0
var _thread: Thread
var _data: Dictionary


func enter(data: Dictionary = {}) -> void:
	# Needs to be called twice for the screen to render properly
	_data = data
	await get_tree().process_frame
	await get_tree().process_frame
	_thread = Thread.new()
	_thread.start(_create_new_world.bind(data))


func _process(delta: float) -> void:
	_progress_mutex.lock()
	progress_bar.value = clampi(_progress, 0, 100)
	_progress_mutex.unlock()
	if _thread and not _thread.is_alive():
		transition_requested.emit(_data.get("game_scene"), _data)


func _create_new_world(data: Dictionary) -> void:
	var player_info: Array[PlayerInfo] = []
	for i: int in data.devices.size():
		player_info.append(_create_player_info(i, data))
	WorldManager.generate_new_world(
		WORLD_CONFIG,
		player_info,
		data.get("slot"),
		func(p: int) -> void:
			_progress_mutex.lock()
			_progress = p
			_progress_mutex.unlock()
	)
	data["player_info"] = player_info


func _create_player_info(player_index: int, data: Dictionary) -> PlayerInfo:
	var info := PlayerInfo.new()
	info.device = data["devices"][player_index]
	info.player_color = data["colors"][player_index]
	info.player_name = data["names"][player_index]
	info.player_index = player_index
	return info
