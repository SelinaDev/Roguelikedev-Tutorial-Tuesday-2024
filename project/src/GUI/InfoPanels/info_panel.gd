class_name InfoPanel
extends PanelContainer

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var hint_label: Label = $VBoxContainer/HintLabel
@onready var info_container_holder: MarginContainer = $VBoxContainer/InfoContainerHolder
@onready var h_separator_2: HSeparator = $VBoxContainer/HSeparator2

var info_container: InfoContainer


func setup(title: String, info_scene: PackedScene, player: Entity) -> void:
	title_label.text = title
	info_container = info_scene.instantiate()
	info_container_holder.add_child(info_container)
	info_container.setup(player)
	info_container.closed.connect(_on_info_container_closed)
	var hint_text: String = info_container.get_control_hint_text()
	if hint_text.is_empty():
		h_separator_2.hide()
		hint_label.hide()
	else:
		hint_label.text = info_container.get_control_hint_text()


func _on_info_container_closed() -> void:
	queue_free()


func close() -> void:
	info_container.close()
