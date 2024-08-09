extends GameState

@export_file("*.tscn") var main_menu_scene

@onready var player_displays: HBoxContainer = $CenterContainer/VBoxContainer/PlayerDisplays
@onready var button: Button = $CenterContainer/VBoxContainer/Button

var _devices: Array


func enter(data: Dictionary = {}) -> void:
	var player_infos: Array[PlayerInfo] = data.get("player_info", [])
	for player_info: PlayerInfo in player_infos:
		_add_player_text(player_info)
	_devices = player_infos.map(func(info: PlayerInfo) -> int: return info.device)
	
	button.grab_focus() 


func _add_player_text(player_info: PlayerInfo) -> void:
	var rich_text_label := RichTextLabel.new()
	rich_text_label.custom_minimum_size.x = 150
	rich_text_label.bbcode_enabled = true
	rich_text_label.fit_content = true
	
	var player: Entity = player_info.player_entity
	var player_component: PlayerComponent = player.get_component(Component.Type.Player)
	var text: String = player_component.player_name
	
	rich_text_label.parse_bbcode(text)
	
	player_displays.add_child(rich_text_label)


func _on_button_pressed() -> void:
	transition_requested.emit(main_menu_scene, {
		"devices": _devices
	})
