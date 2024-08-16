class_name CharacterPanelInfoContainer
extends InfoContainer

signal character_screen_finished

@onready var character_label: RichTextLabel = $CharacterLabel


func _setup() -> void:
	character_label.parse_bbcode(_generate_character_text())
	InputManager.obtain_input_handle(_device).received_input.connect(_on_event)


func _on_event(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("back"):
		InputManager.pop_handle(_device)
		close()
		character_screen_finished.emit()


func _generate_character_text() -> String:
	var text := ""
	var info := PlayerComponent.get_player_info(_player)
	text = "[color=#%s]%s[/color]" % [info.player_color.to_html(false), info.player_name]
	var level_component: LevelComponent = _player.get_component(Component.Type.Level)
	text += "  (Level %d)\n\n" % level_component.current_level
	var durability_component: DurabilityComponent = _player.get_component(Component.Type.Durability)
	text += "HP: %d/%d\n" % [durability_component.current_hp, durability_component.max_hp]
	text += "XP: %d/%d\n" % [level_component.current_xp, level_component.experience_to_next_level()]
	text += "\n"
	var power_message := Message.new("calculate_power")
	_player.process_message(power_message)
	var power := power_message.get_calculation("power").get_result()
	var defense_message := Message.new("calculate_defense")
	_player.process_message(defense_message)
	var defense := defense_message.get_calculation("defense").get_result()
	text += "Power: %d\n" % power
	text += "Defense: %d\n" % defense
	var status_component: StatusEffectsComponent = _player.get_component(Component.Type.StatusEffects)
	text += "\n" + "\n".join(status_component.get_descriptions(true))
	
	return text
