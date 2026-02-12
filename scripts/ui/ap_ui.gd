# 行动点UI
class_name APUI
extends Control

# UI节点
@onready var ap_label: Label = $Panel/MarginContainer/VBoxContainer/APLabel
@onready var progress_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/ProgressBar

func _ready() -> void:
	EventBus.ap_changed.connect(_on_ap_changed)
	EventBus.ap_insufficient.connect(_on_ap_insufficient)

# AP改变时更新显示
func _on_ap_changed(current: int, max_value: int) -> void:
	ap_label.text = "行动点: %d/%d" % [current, max_value]
	progress_bar.max_value = max_value
	progress_bar.value = current

# AP不足时提示
func _on_ap_insufficient(required: int, current: int) -> void:
	# 可以添加闪烁或抖动效果
	pass
