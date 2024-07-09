extends Node

#TEMPORARY
var _cached_map_info: MapInfo

#TEMPORARY
func get_map_info(id: int = 0) -> MapInfo:
	if not _cached_map_info:
		_cached_map_info = MapInfo.new()
		_cached_map_info.id = 0
		_cached_map_info.canvas = RenderingServer.canvas_create()
	return _cached_map_info
