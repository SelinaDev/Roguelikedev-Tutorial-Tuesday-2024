class_name PlayerInfoDisplay
extends MarginContainer

const INFO_PANEL = preload("res://src/GUI/InfoPanels/info_panel.tscn")


func spawn_panel(title: String, info_container: PackedScene, player: Entity) -> InfoPanel:
	var info_panel: InfoPanel = INFO_PANEL.instantiate()
	add_child(info_panel)
	info_panel.setup(title, info_container, player)
	return info_panel
