extends GameState

@export var player_ui: Array[PlayerUiResource]

@onready var scheduler: Scheduler = $Scheduler

var entities: Array[Entity] = []
var _player_info: Array[PlayerInfo] = []
# TODO: Enter function that assigns players to their viewports

func enter(data: Dictionary = {}) -> void:
	_new_game(data)


func _new_game(data: Dictionary) -> void:
	for i: int in player_ui.size():
		var device = data.devices[i]
		_player_info.append(create_player_info(i, device))
	WorldManager.generate_new_world(null, _player_info)
	var active_map: MapData = WorldManager.get_map(0)
	for entity: Entity in active_map.get_entities([Component.Type.Actor]):
		scheduler.actors.append(entity.get_component(Component.Type.Actor))
	
	for info: PlayerInfo in _player_info:
		var map: MapData = info.player_entity.map_data
		RenderingServer.viewport_attach_canvas(info.sub_viewport.get_viewport_rid(), map.canvas)
		info.player_entity.process_message(Message.new("render"))


func create_player_info(player_index: int, device: int) -> PlayerInfo:
	var info := PlayerInfo.new()
	
	var ui_info: PlayerUiResource = player_ui[player_index]
	info.device = device
	info.player_index = player_index
	info.sub_viewport = get_node(ui_info.viewport)
	
	return info
