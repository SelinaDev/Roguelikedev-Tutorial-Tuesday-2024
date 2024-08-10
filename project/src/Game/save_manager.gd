class_name SaveManager
extends RefCounted

const SAVE_PATH = "user://saved_world_%d.tres"
const NUM_SLOTS = 3


var _current_slot: int
var _slot_path: String
var progress: int = 0


static func save_world(slot: int) -> bool:
	if not is_slot_valid(slot):
		return false
	var save_path := SAVE_PATH % slot
	var metadata := SaveMetadata.new()
	var world := WorldManager.get_world()
	var save_err := ResourceSaver.save(world, save_path)
	if save_err != OK:
		return false
	
	var players := world.get_player_entities()
	metadata.num_players = players.size()
	metadata.player_names = players.map(
		func(e: Entity) -> String: return (e.get_component(Component.Type.Player) as PlayerComponent).player_name
	)
	metadata.file_hash = FileAccess.get_md5(save_path)
	metadata.save_slot(slot)
	return true


static func is_slot_used(slot: int) -> bool:
	if not is_slot_valid(slot):
		return false
	return FileAccess.file_exists(SAVE_PATH % slot)


static func is_slot_valid(slot: int) -> bool:
	return slot > 0 and slot <= NUM_SLOTS


static func get_used_slots() -> Array[int]:
	return range(1, NUM_SLOTS+1).filter(func(i: int) -> bool: return is_slot_used(i))


static func clear_slot(slot: int) -> void:
	if not is_slot_used(slot):
		return
	DirAccess.remove_absolute(SAVE_PATH % slot)
	SaveMetadata.clear_slot(slot)


static func get_metadata(slot: int) -> SaveMetadata:
	assert(is_slot_valid(slot))
	if not is_slot_used(slot):
		return null
	var metadata := SaveMetadata.new()
	metadata.load_slot(slot)
	return metadata


static func check_slot_hash(slot: int) -> bool:
	var metadata := get_metadata(slot)
	return FileAccess.get_md5(SAVE_PATH % slot) == metadata.file_hash


func _init(slot: int) -> void:
	assert(is_slot_valid(slot))
	_current_slot = slot
	_slot_path = SAVE_PATH % slot


func start_loading() -> void:
	ResourceLoader.load_threaded_request(_slot_path)


func get_status() -> ResourceLoader.ThreadLoadStatus:
	var progress_array := []
	var status := ResourceLoader.load_threaded_get_status(_slot_path, progress_array)
	if not progress_array.is_empty():
		progress = int(progress_array[0])
	return status


func get_world() -> World:
	if ResourceLoader.load_threaded_get_status(_slot_path) != ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
		return null
	return ResourceLoader.load_threaded_get(_slot_path)
