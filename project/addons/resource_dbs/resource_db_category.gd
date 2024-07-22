@tool
class_name ResourceDbCategory
extends VBoxContainer

signal category_changed

const SOURCE_PATH_LINE = preload("res://addons/resource_dbs/source_path_line.tscn")

@onready var file_dialog: FileDialog = $FileDialog
@onready var source_paths_node: VBoxContainer = $SourcePaths
@onready var category_name_label: Label = $HBoxContainer/CategoryNameLabel
@onready var dest_path_button: Button = $HBoxContainer/DestPathButton

var category_name: String
var category_path: String

func initialize(category_name: String, destination_path: String, source_paths: Array) -> void:
	self.category_name = category_name
	category_name_label.text = category_name
	category_path = destination_path
	var dest_path_text = destination_path
	if dest_path_text == "":
		dest_path_text = "Choose Category Path"
	dest_path_button.text = dest_path_text
	
	for source_path: String in source_paths:
		var source_path_line: SourcePathLine = SOURCE_PATH_LINE.instantiate()
		source_paths_node.add_child(source_path_line)
		source_path_line.path = source_path
		source_path_line.path_changed.connect(_on_source_paths_line_path_changed)


func get_source_paths() -> Array:
	var paths := []
	for line: SourcePathLine in source_paths_node.get_children():
		paths.append(line.path)
	return paths


func _on_dest_path_button_pressed() -> void:
	file_dialog.popup()


func _on_add_line_button_pressed() -> void:
	var source_paths_line: SourcePathLine = SOURCE_PATH_LINE.instantiate()
	source_paths_node.add_child(source_paths_line)
	source_paths_line.path_changed.connect(_on_source_paths_line_path_changed)


func _on_source_paths_line_path_changed() -> void:
	category_changed.emit()


func _on_file_dialog_dir_selected(dir: String) -> void:
	dest_path_button.text = dir
	category_path = dir
	category_changed.emit()
	
