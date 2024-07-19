@tool
class_name SourcePathLine
extends HBoxContainer

signal path_changed

@onready var path_button: Button = $Button
@onready var file_dialog: FileDialog = $FileDialog

var path: String:
	set(value):
		path = value
		path_button.text = value
		path_changed.emit()


func _on_delete_button_pressed() -> void:
	queue_free()
	get_parent().remove_child(self)
	path_changed.emit()


func _on_file_dialog_dir_selected(dir: String) -> void:
	path = dir


func _on_button_pressed() -> void:
	file_dialog.popup_centered()
