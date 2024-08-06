class_name TargetInfoContainer
extends InfoContainer

@onready var rich_text_label: RichTextLabel = $RichTextLabel


func set_target_info(targets: Array[Entity]) -> void:
	var info_text := _list_targets(targets)
	rich_text_label.parse_bbcode(info_text)


func set_target_error(target_error: String) -> void:
	var info_text := "[color=#%s]%s[/color]" % [Color.RED.to_html(false), target_error]
	rich_text_label.parse_bbcode(info_text)


func _list_targets(targets: Array[Entity]) -> String:
	if targets.is_empty():
		return "[color=#%s]No targets[/color]" % Color.GRAY.to_html(false)
	return "Targeting:\n[ul]%s[/ul]" % targets.reduce(
		func(list: String, entity: Entity) -> String: return list + entity.name + "\n", ""
	)


func _get_control_hint_text_controller() -> String:
	return "D-Pad: move, <B>: close"


func _get_control_hint_text_keyboard() -> String:
	return "Arrow keys: move, Backspace: close"
