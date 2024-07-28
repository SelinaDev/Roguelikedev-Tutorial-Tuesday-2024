class_name UseTarget
extends Resource


func get_targets(_user: Entity) -> Array[Entity]:
	await _wait_a_tick()
	return []


func _wait_a_tick() -> void:
	await Engine.get_main_loop().process_frame


func get_target_string() -> String:
	return ""
