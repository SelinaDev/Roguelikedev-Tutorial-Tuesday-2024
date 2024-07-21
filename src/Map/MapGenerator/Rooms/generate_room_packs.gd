@tool
extends EditorScript

const SOURCES_PATH = "res://resources/MapGeneration/RoomFiles/"
const TARGET_PATH = "res://resources/MapGeneration/RoomPacks/"
const ROOMS_PATH = "Rooms"
const CORRIDORS_PATH = "Corridors"


func _run() -> void:
	var categories := DirAccess.get_directories_at(SOURCES_PATH)
	for category: String in categories:
		var room_pack := RoomPack.new()
		var category_path := SOURCES_PATH.path_join(category)
		var rooms_path := category_path.path_join(ROOMS_PATH)
		if not DirAccess.dir_exists_absolute(rooms_path):
			continue
		room_pack.rooms = _get_rooms_array(rooms_path)
		var corridors_path := category_path.path_join(CORRIDORS_PATH)
		if DirAccess.dir_exists_absolute(corridors_path):
			room_pack.corridors = _get_rooms_array(corridors_path)
		var category_target_path := TARGET_PATH.path_join(category.to_lower() + ".tres")
		ResourceSaver.save(room_pack, category_target_path)


func _get_rooms_array(path: String) -> Array[Room]:
	var rooms_array: Array[Room] = []
	for file_name: String in DirAccess.get_files_at(path):
		var file := FileAccess.open(path.path_join(file_name), FileAccess.READ)
		var room_source := file.get_as_text(true)
		var room := Room.parse_room(room_source)
		rooms_array.append(room)
	return rooms_array
