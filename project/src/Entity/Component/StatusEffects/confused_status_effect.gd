class_name ConfusedStatusEffect
extends StatusEffect

@export var duration: int


func start(entity: Entity) -> void:
	Log.send_log(
		"%s's eyes glaze over as they start moving erratically." % entity.get_entity_name(),
		Log.COLOR_NEUTRAL
	)


func end(entity: Entity) -> void:
	Log.send_log(
		"%s is no longer confused." % entity.get_entity_name(),
		Log.COLOR_NEUTRAL
	)


func merge(new_effect: StatusEffect) -> void:
	if new_effect is ConfusedStatusEffect:
		duration += new_effect.duration


func process_message_precalculate(entity: Entity, message: Message) -> void:
	match message.type:
		"get_action":
			message.data.get("proposed_actions").append(
				ProposedAction.new().with_priority(ProposedAction.Priority.FORCE).with_action(
					BumpAction.new(entity, Globals.CARDINAL_OFFSETS.pick_random())
				)
			)


func process_message_execute(_entity: Entity, message: Message) -> void:
	match message.type:
		"turn_end":
			duration -= 1
			if duration <= 0:
				effect_ended.emit()
			else:
				effect_changed.emit()


func get_description(rich_text: bool = false) -> String:
	var info_text := "confused (%d)" % duration
	if rich_text:
		info_text = "[color=#%s]%s[/color]" % [Color.DARK_MAGENTA.to_html(false), info_text]
	return info_text


func get_type() -> String:
	return "confused"
