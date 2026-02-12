# 消息UI
class_name MessageUI
extends Control

@onready var message_label: Label = $MessageLabel

# 消息显示时间
var message_timer: float = 0.0
const MESSAGE_DURATION: float = 3.0

func _ready() -> void:
	EventBus.ui_message.connect(_on_ui_message)
	message_label.text = ""

func _process(delta: float) -> void:
	if message_timer > 0:
		message_timer -= delta
		if message_timer <= 0:
			message_label.text = ""

# 显示消息
func _on_ui_message(message: String, type: String) -> void:
	message_label.text = message
	message_timer = MESSAGE_DURATION
	
	# 根据类型改变颜色
	match type:
		"info":
			message_label.modulate = Color.WHITE
		"warning":
			message_label.modulate = Color.YELLOW
		"error":
			message_label.modulate = Color.RED
