@tool
extends EditorPlugin

const PLUGIN_SETTING = "addons/resource_dbs/categories"

var dock


func _enter_tree() -> void:
	if not ProjectSettings.has_setting(PLUGIN_SETTING):
		ProjectSettings.set_setting(PLUGIN_SETTING, [])
		ProjectSettings.add_property_info({
			"name": PLUGIN_SETTING,
			"type": TYPE_PACKED_STRING_ARRAY
		})
	dock = preload("res://addons/resource_dbs/resource_db_interface.tscn").instantiate()
	add_control_to_bottom_panel(dock, "Resource DBs")


func _exit_tree() -> void:
	remove_control_from_bottom_panel(dock)
	dock.queue_free()
