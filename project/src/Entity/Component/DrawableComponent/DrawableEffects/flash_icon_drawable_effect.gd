class_name FlashIconDrawableEffect
extends DrawableEffect

@export var frequency := 0.5
@export var times := 1
@export var icon: AtlasTexture

var _tween: Tween
var _canvas_item: RID
var _visible = true

func _start() -> void:
	var target_canvas: RID = _drawable_component._target_canvas
	_canvas_item = RenderingServer.canvas_item_create()
	RenderingServer.canvas_item_set_parent(_canvas_item, target_canvas)
	RenderingServer.canvas_item_set_z_index(_canvas_item, DrawableComponent.RenderOrder.EFFECT)
	RenderingServer.canvas_item_add_texture_rect_region(_canvas_item, Rect2(Vector2.ZERO, Globals.CELL_SIZE), icon.atlas.get_rid(), icon.region)
	RenderingServer.canvas_item_set_transform(_canvas_item, _drawable_component._transform)
	var scene_tree: SceneTree = Engine.get_main_loop()
	_tween = scene_tree.create_tween().set_loops(times * 2)
	_tween.tween_interval(frequency / 2.0)
	_tween.tween_callback(_toggle_canvas_item_visibility)
	_tween.finished.connect(_on_tween_finished)


func _on_tween_finished() -> void:
	effect_finished.emit()


func _toggle_canvas_item_visibility() -> void:
	_visible = not _visible
	RenderingServer.canvas_item_set_visible(_canvas_item, _visible)


func stop() -> void:
	RenderingServer.canvas_item_set_visible(_canvas_item, false)
	RenderingServer.canvas_item_clear(_canvas_item)
	_canvas_item = RID()
	_tween.kill()


func get_effect_type() -> String:
	return "flash_icon"
