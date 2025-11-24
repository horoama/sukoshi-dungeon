class_name Message
extends Label

var plain_text: String
# set theeme: font color, size, etc.
const font_size: int = 24
var count: int = 1:
	set(value):
		count = value
		text = full_text()

func _init(msg_text: String, color: Color) -> void:
	plain_text = msg_text
	label_settings = LabelSettings.new()
	label_settings.font_color = color
	label_settings.font_size = self.font_size
	text = plain_text

func full_text() -> String:
	if count > 1:
		return "%s (x%d)" % [plain_text, count]
	return plain_text
