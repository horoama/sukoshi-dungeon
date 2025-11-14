class_name MessageContainer
extends ScrollContainer

var last_message: Message = null

@onready var message_list : VBoxContainer = $MessageList

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalBus.message_sent.connect(_on_message_sent)

static func send_message(text: String, color: Color = Color.WHITE) -> void:
	SignalBus.message_sent.emit(text, color)

func _on_message_sent(text: String, color: Color) -> void:
	if (
		last_message != null and
		last_message.plain_text == text
	):
		last_message.count += 1
	else:
		var message := Message.new(text, color)
		last_message = message
		message_list.add_child(message)
		await get_tree().process_frame
		ensure_control_visible(message)
