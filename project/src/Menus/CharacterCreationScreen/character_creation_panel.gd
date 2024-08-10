class_name CharacterCreationPanel
extends PanelContainer

signal character_ready

const COLORS := [
	Color.WHITE,
	Color.RED,
	Color.GREEN,
	Color.BLUE,
	Color.YELLOW,
	Color.CYAN,
	Color.MAGENTA
]

@export var texture_not_ready: AtlasTexture
@export var texture_ready: AtlasTexture

@onready var player_name_label: Label = $VBoxContainer/PlayerNameLabel
@onready var regenerate_name: Pseudobutton = $VBoxContainer/RegenerateName
@onready var color_button: Pseudobutton = $VBoxContainer/HBoxContainer/ColorButton
@onready var color_rect: ColorRect = $VBoxContainer/HBoxContainer/ColorRect
@onready var ready_texture_rect: TextureRect = $VBoxContainer/ReadyLine/ReadyTextureRect
@onready var ready_button: Pseudobutton = $VBoxContainer/ReadyLine/ReadyButton

var _color_index := 0:
	set(value):
		_color_index = (value + COLORS.size()) % COLORS.size()
		color_rect.color = COLORS[_color_index]
var _selected_button: Pseudobutton:
	set(value):
		if _selected_button:
			_selected_button.selected = false
		_selected_button = value
		_selected_button.selected = true
var is_ready := false:
	set(value):
		if value == is_ready:
			return
		is_ready = value
		ready_texture_rect.texture = texture_ready if is_ready else texture_not_ready
		character_ready.emit()
var player_name: String:
	set(value):
		_previous_player_name = player_name
		player_name = value
		player_name_label.text = player_name
var _previous_player_name: String
var _player_name_generator := PlayerNameGenerator.new()
var _device: int


func _ready() -> void:
	_selected_button = regenerate_name


func setup(device: int) -> void:
	_device = device
	_player_name_generator.initialize()
	player_name = _player_name_generator.get_name()
	regenerate_name.text = "Generate New Name"
	regenerate_name.binding = func(checked: bool) -> void:
		if checked:
			player_name = _player_name_generator.get_name()
		else:
			player_name = _previous_player_name
	regenerate_name.link_next(color_button)
	_color_index = 0
	color_button.text = "Set Player Color"
	color_button.binding = func(checked: bool) -> void:
		if checked:
			_color_index += 1
		else:
			_color_index -= 1
	color_button.link_next(ready_button)
	ready_button.text = "Ready"
	ready_button.binding = func(checked: bool) -> void: 
		if checked:
			is_ready = not is_ready
	ready_button.link_next(regenerate_name)
	InputManager.obtain_input_handle(_device).received_input.connect(_on_event)


func get_color() -> Color:
	return COLORS[_color_index]


func _on_event(event: InputEvent) -> void:
	if event.is_action_pressed("move_up"):
		_selected_button = _selected_button.previous_button
		is_ready = false
	elif event.is_action_pressed("move_down"):
		_selected_button = _selected_button.next_button
		is_ready = false
	elif event.is_action_pressed("ui_accept"):
		_selected_button.binding.call(true)
	elif event.is_action_pressed("back"):
		_selected_button.binding.call(false)
