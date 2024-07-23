class_name PlayerPanel
extends PanelContainer

@onready var hp_bar: Bar = $VBoxContainer/HpBar


func setup(player: Entity) -> void:
	_setup_hp_bar(player)


func _setup_hp_bar(player: Entity) -> void:
	var player_durability: DurabilityComponent = player.get_component(Component.Type.Durability)
	player_durability.hp_changed.connect(_on_player_hp_changed)
	_on_player_hp_changed(player_durability.current_hp, player_durability.max_hp)


func _on_player_hp_changed(hp: int, max_hp: int) -> void:
	hp_bar.max_value = max_hp
	hp_bar.value = hp
