class_name DrawableEffect
extends Resource

signal effect_finished

var _drawable_component: DrawableComponent


func start(drawable_component: DrawableComponent) -> void:
	_drawable_component = drawable_component
	_start()


func _start() -> void:
	pass


func stop() -> void:
	pass


func get_effect_type() -> String:
	return ""
