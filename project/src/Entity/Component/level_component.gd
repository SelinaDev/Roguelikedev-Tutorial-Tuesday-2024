class_name LevelComponent
extends Component

signal level_changed(new_level)
signal xp_changed(xp_current, xp_to_next)

const LEVEL_UP_INFO_CONTAINER = preload("res://src/GUI/InfoPanels/LevelUpPanel/level_up_info_container.tscn")

@export_storage var current_level: int = 1:
	set(value):
		current_level = value
		level_changed.emit(current_level)
@export_storage var current_xp: int = 0:
	set(value):
		current_xp = value
		xp_changed.emit(current_xp, experience_to_next_level())
@export var level_up_base: int = 0
@export var level_up_factor: int = 150


func get_component_type() -> Type:
	return Type.Level


func process_message_execute(message: Message) -> void:
	match message.type:
		"xp_received":
			var xp: int = message.data.get("xp", 0)
			if xp > 0:
				add_xp(xp)
		"level_up":
			increase_level()


func experience_to_next_level() -> int:
	return level_up_base + current_level * level_up_factor


func requires_level_up() -> bool:
	return current_xp > experience_to_next_level()


func add_xp(xp: int) -> void:
	if xp == 0 or level_up_base == 0:
		return
	
	current_xp += xp
	
	Log.send_log(
		"%s gains %d experience points" % [_parent_entity.get_entity_name(), xp],
		Log.COLOR_POSITIVE
	)
	
	_check_level_up()


func _check_level_up() -> void:
	if requires_level_up():  
		Log.send_log(
				"%s advances to level %d" % [_parent_entity.get_entity_name(), current_level + 1],
				Log.COLOR_POSITIVE
			)
		_parent_entity.process_message(Message.new("level_up"))


func increase_level() -> void:
	current_xp -= experience_to_next_level()
	current_level += 1
	current_xp = current_xp
	await _spawn_level_up_menu().level_up_completed
	_check_level_up()


func _spawn_level_up_menu() -> LevelUpInfoContainer:
	var player_info: PlayerInfo = PlayerComponent.get_player_info(_parent_entity)
	return player_info.info_display.spawn_panel("Level Up", LEVEL_UP_INFO_CONTAINER, _parent_entity).info_container as LevelUpInfoContainer
