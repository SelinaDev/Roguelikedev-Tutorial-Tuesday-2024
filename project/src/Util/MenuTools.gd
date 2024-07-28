class_name MenuTools
extends RefCounted


static func connect_buttons(buttons: Array) -> void:
	assert(buttons.all(func(b) -> bool: return b is Button))
	
	for i: int in buttons.size():
		var prev_button: Button = buttons[(i - 1) % buttons.size()]
		var button: Button = buttons[i]
		var next_button: Button = buttons[(i + 1) % buttons.size()]
		
		var prev_button_path := button.get_path_to(prev_button)
		var next_button_path := button.get_path_to(next_button)
		
		button.focus_neighbor_top = prev_button_path
		button.focus_neighbor_left = prev_button_path
		button.focus_previous = prev_button_path
		
		button.focus_neighbor_bottom = next_button_path
		button.focus_neighbor_right = next_button_path
		button.focus_next = next_button_path
