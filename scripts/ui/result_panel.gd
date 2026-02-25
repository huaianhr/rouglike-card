# 胜负结果面板
class_name ResultPanel
extends Control

# UI节点
@onready var panel: Panel = $Panel
@onready var result_label: Label = $Panel/MarginContainer/VBoxContainer/ResultLabel
@onready var message_label: Label = $Panel/MarginContainer/VBoxContainer/MessageLabel
@onready var reward_container: VBoxContainer = $Panel/MarginContainer/VBoxContainer/RewardContainer
@onready var continue_button: Button = $Panel/MarginContainer/VBoxContainer/ContinueButton

# 奖励列表
var rewards: Array = []

func _ready() -> void:
	# 初始隐藏
	visible = false
	
	# 连接信号
	EventBus.victory_achieved.connect(_on_victory)
	EventBus.defeat_triggered.connect(_on_defeat)
	continue_button.pressed.connect(_on_continue_pressed)

# 胜利时显示
func _on_victory() -> void:
	print("[ResultPanel] 显示胜利面板")
	result_label.text = "🎉 胜利！"
	result_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	message_label.text = "成功守住了防线！\n选择一个奖励："
	continue_button.visible = false  # 先隐藏，选择奖励后再显示
	
	# 生成奖励
	generate_rewards()
	
	visible = true

# 失败时显示
func _on_defeat() -> void:
	print("[ResultPanel] 显示失败面板")
	result_label.text = "💀 失败"
	result_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	message_label.text = "防线被攻破了...\n下次再来吧！"
	continue_button.text = "重试"
	continue_button.visible = true
	
	# 清空奖励区
	clear_rewards()
	
	visible = true

# 生成奖励
func generate_rewards() -> void:
	clear_rewards()
	
	# 从关卡配置获取奖励池
	if not GameManager.current_level or not GameManager.current_level.reward_pool:
		print("[ResultPanel] 无奖励池配置")
		var label = Label.new()
		label.text = "暂无奖励"
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		reward_container.add_child(label)
		continue_button.visible = true
		return
	
	var reward_pool = GameManager.current_level.reward_pool
	rewards = reward_pool.generate_rewards()
	
	print("[ResultPanel] 生成 %d 个奖励选项" % rewards.size())
	
	# 显示奖励按钮
	for i in rewards.size():
		var reward = rewards[i]
		var reward_button = create_reward_button(reward, i)
		reward_container.add_child(reward_button)

# 创建奖励按钮
func create_reward_button(reward: Dictionary, index: int) -> Button:
	var button = Button.new()
	button.custom_minimum_size = Vector2(0, 80)
	
	# 根据奖励类型显示不同文本
	var button_text = ""
	match reward["type"]:
		"card":
			var card = ConfigLoader.get_card(reward["id"])
			if card:
				button_text = "🃏 卡牌：%s\n费用: %d\n%s" % [card.display_name, card.cost, card.description]
			else:
				button_text = "未知卡牌：%s" % reward["id"]
		"item":
			button_text = "🎁 道具：%s\n（道具系统开发中）" % reward["id"]
	
	button.text = button_text
	
	# 连接选择信号
	button.pressed.connect(func(): _on_reward_selected(reward, index))
	
	return button

# 选择奖励
func _on_reward_selected(reward: Dictionary, index: int) -> void:
	print("[ResultPanel] 选择奖励 %d: %s - %s" % [index, reward["type"], reward["id"]])
	
	match reward["type"]:
		"card":
			var card = ConfigLoader.get_card(reward["id"])
			if card:
				DeckManager.add_card_to_library(card)
				print("[ResultPanel] 卡牌 %s 已添加到牌库" % card.display_name)
		"item":
			# TODO: 添加道具到背包
			print("[ResultPanel] 道具系统暂未实现")
	
	# 清空奖励按钮，显示继续按钮
	clear_rewards()
	
	var confirm_label = Label.new()
	confirm_label.text = "✅ 奖励已获得！"
	confirm_label.add_theme_font_size_override("font_size", 18)
	confirm_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	reward_container.add_child(confirm_label)
	
	continue_button.text = "进入下一关"
	continue_button.visible = true

# 清空奖励显示
func clear_rewards() -> void:
	for child in reward_container.get_children():
		child.queue_free()

# 继续按钮
func _on_continue_pressed() -> void:
	visible = false
	
	if GameManager.current_state == GameManager.GameState.SETTLEMENT:
		# 胜利：进入下一关
		print("[ResultPanel] 进入下一关")
		EventBus.level_completed.emit(true, rewards)
		# 暂时重新加载当前关（TODO: 后续实现真正的下一关加载）
		get_tree().reload_current_scene()
	else:
		# 失败：重试当前关
		print("[ResultPanel] 重试当前关卡")
		EventBus.level_completed.emit(false, [])
		get_tree().reload_current_scene()
