class_name InfoPanel
extends PanelContainer

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var hint_label: Label = $VBoxContainer/HintLabel
@onready var info_container_holder: MarginContainer = $VBoxContainer/InfoContainerHolder

var info_container: InfoContainer


func setup(title: String, info_scene: PackedScene, player: Entity) -> void:
	title_label.text = title
	info_container = info_scene.instantiate()
	info_container_holder.add_child(info_container)
	info_container.setup(player)
	info_container.closed.connect(_on_info_container_closed)


func _on_info_container_closed() -> void:
	queue_free()


func close() -> void:
	info_container.close()
