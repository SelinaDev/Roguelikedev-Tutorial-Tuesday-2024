extends InfoContainer

@onready var rich_text_label: RichTextLabel = $RichTextLabel

func _setup() -> void:
	var direction_method: String
	var cancel_button: String
	if _device == -1:
		direction_method = "the arrow keys"
		cancel_button = "backspace"
	else:
		direction_method = "the D-pad"
		cancel_button = "B"
	var text: String = "Choose a direction using %s. Cancel with %s." % [
		direction_method,
		cancel_button
	]
	rich_text_label.parse_bbcode(text)
