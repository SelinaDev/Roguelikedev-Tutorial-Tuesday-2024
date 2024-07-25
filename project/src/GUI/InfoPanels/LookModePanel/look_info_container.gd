class_name LookInfoContainer
extends InfoContainer

@onready var rich_text_label: RichTextLabel = $RichTextLabel


func set_look_info(tile: Tile, entities: Array[Entity]) -> void:
	var info_text: String
	if not tile.is_in_view:
		if tile.is_explored:
			info_text = "You remember here:\n[ul]%s%s\n[/ul]" % [
				entities.filter(
					func(entity: Entity) -> bool: return entity.has_component(Component.Type.Rememberable)
				).reduce(
					func(list: String, entity: Entity) -> String: return list + entity.name + "\n",
					""
				),
				tile.name
			]
		else:
			info_text = "You don't know what's here"
	else:
		info_text = "You see here:\n[ul]%s%s\n[/ul]" % [
			entities.reduce(
				func(list: String, entity: Entity) -> String: return list + entity.name + "\n",
				""
			),
			tile.name
		]
	rich_text_label.parse_bbcode(info_text)


func _get_control_hint_text_controller() -> String:
	return "D-Pad: move, <B>: close"


func _get_control_hint_text_keyboard() -> String:
	return "Arrow keys: move, Backspace: close"
