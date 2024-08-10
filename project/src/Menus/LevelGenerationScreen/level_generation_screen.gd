extends GameState


func enter(data: Dictionary = {}) -> void:
	# Needs to be called twice for the screen to render properly
	await get_tree().process_frame
	await get_tree().process_frame
	_create_new_world(data)
	transition_requested.emit(data.get("game_scene"), data)


func _create_new_world(data: Dictionary) -> void:
	var player_info: Array[PlayerInfo] = []
	for i: int in data.devices.size():
		player_info.append(_create_player_info(i, data))
	WorldManager.generate_new_world(null, player_info, data.get("slot"))
	data["player_info"] = player_info


func _create_player_info(player_index: int, data: Dictionary) -> PlayerInfo:
	var info := PlayerInfo.new()
	info.device = data["devices"][player_index]
	info.player_color = data["colors"][player_index]
	info.player_name = data["names"][player_index]
	info.player_index = player_index
	return info
