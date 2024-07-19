@tool
extends Control

const RESOURCE_DB_CATEGORY = preload("res://addons/resource_dbs/resource_db_category.tscn")
const CONFIG = "res://addons/resource_dbs/resource_db_config.cfg"
const PLUGIN_SETTING = "addons/resource_dbs/categories"

@onready var categories_container: VBoxContainer = $VBoxContainer/ScrollContainer/CategoriesContainer

var categories: Array[ResourceDbCategory]


func _ready() -> void:
	_rebuild()
	ProjectSettings.settings_changed.connect(_rebuild)


func _get_config() -> ConfigFile:
	var cfg := ConfigFile.new()
	var err := cfg.load(CONFIG)
	return cfg


func _rebuild() -> void:
	var target_categories: PackedStringArray = ProjectSettings.get_setting(PLUGIN_SETTING, [])
	var config := _get_config()
	
	for child: Node in categories_container.get_children():
		child.queue_free()
	
	for category: String in target_categories:
		var destination_path: String = config.get_value(category, "destination_path", "")
		var source_paths: Array = config.get_value(category, "source_paths", [])
		var category_node: ResourceDbCategory = RESOURCE_DB_CATEGORY.instantiate()
		categories_container.add_child(category_node)
		category_node.initialize(category, destination_path, source_paths)
		category_node.category_changed.connect(_on_category_changed)


func _save_config() -> void:
	var config := ConfigFile.new()
	
	for category_node: ResourceDbCategory in categories_container.get_children():
		print(category_node.category_name, category_node.category_path, category_node.get_source_paths())
		config.set_value(category_node.category_name, "destination_path", category_node.category_path)
		config.set_value(category_node.category_name, "source_paths", category_node.get_source_paths())
	
	config.save(CONFIG)


func _on_category_changed() -> void:
	_save_config()


func _on_generate_button_pressed() -> void:
	var config := ConfigFile.new()
	var err := config.load(CONFIG)
	if err != OK:
		return
	
	var target_categories: PackedStringArray = ProjectSettings.get_setting(PLUGIN_SETTING, [])
	print(target_categories)
	for category: String in target_categories:
		var destination_path: String = config.get_value(category, "destination_path", "")
		if destination_path == "":
			continue
		var source_paths: Array = config.get_value(category, "source_paths", [])
		
		var resource_db := ResourceDB.new()
		
		for source_path: String in source_paths:
			var file_names := DirAccess.get_files_at(source_path)
			for file_name: String in file_names:
				var file = load(source_path.path_join(file_name))
				if file is Resource:
					resource_db.entries[file_name.trim_suffix(".tres")] = file
		
		var db_name := category + "_db.tres"
		print(resource_db)
		ResourceSaver.save(resource_db, destination_path.path_join(db_name))
