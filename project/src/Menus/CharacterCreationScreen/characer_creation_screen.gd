extends GameState

const CHARACTER_CREATION_PANEL = preload("res://src/Menus/CharacterCreationScreen/character_creation_panel.tscn")

@export_file("*.tscn") var level_generator_screen

@onready var character_boxes: HBoxContainer = $CenterContainer/VBoxContainer/CharacterBoxes

var _data: Dictionary
var _character_panels: Array[CharacterCreationPanel]


func enter(data: Dictionary = {}) -> void:
	_data = data
	for device: int in data.get("devices", []):
		var character_panel: CharacterCreationPanel = CHARACTER_CREATION_PANEL.instantiate()
		character_boxes.add_child(character_panel)
		character_panel.setup(device)
		character_panel.character_ready.connect(_on_character_ready)
		_character_panels.append(character_panel)


func exit() -> void:
	InputManager.reset()


func _on_character_ready() -> void:
	if _character_panels.all(func(p: CharacterCreationPanel) -> bool: return p.is_ready):
		_data["names"] = _character_panels.map(func(p: CharacterCreationPanel) -> String: return p.player_name)
		_data["colors"] = _character_panels.map(func(p: CharacterCreationPanel) -> Color: return p.get_color())
		transition_requested.emit(level_generator_screen, _data)
