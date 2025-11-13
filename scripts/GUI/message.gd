class_name Message
extends Label

var plain_text: String
var count: int = 1:
	set(value):
		count = value
		text = full_text()

func _init(msg_text: String, color: Color) -> void:
	plain_text = msg_text
	label_settings = LabelSettings.new()
	label_settings.font_color = color
	text = plain_text

func full_text() -> String:
	if count > 1:
		return "%s (x%d)" % [plain_text, count]
	return plain_text
