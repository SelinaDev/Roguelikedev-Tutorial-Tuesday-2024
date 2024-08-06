class_name BlinkDrawableEffect
extends DrawableEffect

@export var frequency: float = 1.0

var _tween: Tween


func _start() -> void:
	var scene_tree: SceneTree = Engine.get_main_loop()
	_tween = scene_tree.create_tween().set_loops()
	_tween.tween_interval(frequency / 2.0)
	_tween.tween_callback(_toggle_drawable_visibility)


func _toggle_drawable_visibility() -> void:
	_drawable_component.visible = not _drawable_component.visible


func stop() -> void:
	_drawable_component.visible = true
	_tween.kill()


func get_effect_type() -> String:
	return "blink"
