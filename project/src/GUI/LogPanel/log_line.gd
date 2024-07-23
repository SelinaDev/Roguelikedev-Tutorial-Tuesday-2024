class_name LogLine
extends RichTextLabel

var plain_text: String
var count: int = 1:
	set(value):
		count = value
		parse_bbcode(full_text())
var color: Color


func _init(msg_text: String, text_color: Color) -> void:
	bbcode_enabled = true
	fit_content = true
	plain_text = msg_text
	color = text_color
	parse_bbcode(full_text())


func full_text() -> String:
	var out_text: String
	if count > 1:
		out_text = "%s (x%d)" % [plain_text, count]
	else:
		out_text = plain_text
	return "[color=#%s]%s[/color]" % [color.to_html(false), out_text]
