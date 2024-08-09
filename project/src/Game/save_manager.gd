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
	return ResourceSaver.save(WorldManager.get_world(), SAVE_PATH % slot) == OK


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
