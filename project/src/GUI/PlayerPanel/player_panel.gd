class_name PlayerPanel
extends PanelContainer

@onready var hp_bar: Bar = $VBoxContainer/HpBar
@onready var controls_label: Label = $ControlsLabel
@onready var status_list: RichTextLabel = $VBoxContainer/StatusList
@onready var player_label: Label = $VBoxContainer/PlayerLabel

var _status_effects_component: StatusEffectsComponent


func setup(player: Entity) -> void:
	_setup_player_name(player)
	_setup_hp_bar(player)
	_setup_status_list(player)
	_setup_controls_label(player)


func _setup_player_name(player: Entity) -> void:
	var player_info := PlayerComponent.get_player_info(player)
	player_label.text = player_info.player_name


func _setup_hp_bar(player: Entity) -> void:
	var player_durability: DurabilityComponent = player.get_component(Component.Type.Durability)
	player_durability.hp_changed.connect(_on_player_hp_changed)
	_on_player_hp_changed(player_durability.current_hp, player_durability.max_hp)


func _on_player_hp_changed(hp: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp


func _setup_status_list(player: Entity) -> void:
	_status_effects_component = player.get_component(Component.Type.StatusEffects)
	_status_effects_component.effects_changed.connect(_update_status_list)
	_update_status_list()


func _update_status_list() -> void:
	status_list.parse_bbcode(
		"\n".join(_status_effects_component.get_descriptions(true))
	)


func _setup_controls_label(player: Entity) -> void:
	var player_device: int = PlayerComponent.get_player_info(player).device
	var controls_text: String = _get_keyboard_controls() if player_device == -1 else _get_controller_controls()
	controls_label.text = controls_text


func _get_keyboard_controls() -> String:
	return "Move: arrow keys, actions: space, zoom (in, out): _/,"


func _get_controller_controls() -> String:
	return "Move: D-pad, actions: select, zoom (in, out): L1/R1"
