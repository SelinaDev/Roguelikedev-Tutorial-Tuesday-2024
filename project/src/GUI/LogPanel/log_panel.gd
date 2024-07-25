class_name Log
extends PanelContainer

const COLOR_NEUTRAL = Color.WHITE
const COLOR_IMPORTANT = Color.RED
const COLOR_NEGATIVE = Color.LIGHT_CORAL
const COLOR_POSITIVE = Color.LIGHT_GREEN
const COLOR_IMPOSSIBLE = Color.GRAY

var last_log: LogLine = null

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var log_list: VBoxContainer = $ScrollContainer/LogList


func _ready() -> void:
	SignalBus.add_log.connect(add_log)


static func send_log(text: String, text_color: Color = Color.WHITE) -> void:
	SignalBus.add_log.emit(text, text_color)


func add_log(text: String, text_color: Color) -> void:
	if last_log != null and last_log.plain_text == text:
		last_log.count += 1
	else:
		var new_log := LogLine.new(text, text_color)
		last_log = new_log
		log_list.add_child(new_log)
		await get_tree().process_frame
		scroll_container.ensure_control_visible(new_log)
