class_name SaveMetadata
extends RefCounted

const METADATA_PATH = "user://slots.save"
const KEY_CATEGORY_SLOT = "SLOT_%d"
const KEY_NUM_PLAYERS = "num_players"
const KEY_PLAYER_NAMES = "player_names"
const KEY_FILE_HASH = "file_hash"

var num_players: int = -1
var player_names: Array = []
var file_hash: String = ""
var is_valid := false


static func clear_slot(slot: int) -> void:
	var config := ConfigFile.new()
	var slot_category := KEY_CATEGORY_SLOT % slot
	if config.has_section(slot_category):
		config.erase_section(slot_category)
	config.save(METADATA_PATH)


func load_slot(slot: int) -> void:
	var config := _load_file()
	var slot_category := KEY_CATEGORY_SLOT % slot
	if not config.has_section(slot_category):
		return
	if [KEY_NUM_PLAYERS, KEY_PLAYER_NAMES, KEY_FILE_HASH].any(
		func(key: String) -> bool: return not config.has_section_key(slot_category, key)
	):
		return
	num_players = config.get_value(slot_category, KEY_NUM_PLAYERS)
	player_names = config.get_value(slot_category, KEY_PLAYER_NAMES)
	file_hash = config.get_value(slot_category, KEY_FILE_HASH)
	is_valid = true


func save_slot(slot: int) -> void:
	var config := _load_file()
	var slot_category := KEY_CATEGORY_SLOT % slot
	config.set_value(slot_category, KEY_NUM_PLAYERS, num_players)
	config.set_value(slot_category, KEY_PLAYER_NAMES, player_names)
	config.set_value(slot_category, KEY_FILE_HASH, file_hash)
	
	config.save(METADATA_PATH)


func _load_file() -> ConfigFile:
	var config := ConfigFile.new()
	var err := config.load(METADATA_PATH)
	if err != OK:
		return ConfigFile.new()
	return config
