# 手牌UI
class_name HandUI
extends Control

# 场景引用
const CARD_BUTTON_SCENE = preload("res://scenes/ui/card_button.tscn")

# 当前选中的卡牌
var selected_card: CardButton = null

# 是否正在选择目标
var is_selecting_target: bool = false

# UI节点
@onready var cards_container: HBoxContainer = $Panel/MarginContainer/HBoxContainer

# 引用Board
var board: Board

func _ready() -> void:
	EventBus.hand_updated.connect(_on_hand_updated)
	EventBus.tile_selected.connect(_on_tile_selected)

# 设置Board引用
func set_board(b: Board) -> void:
	board = b

# 更新手牌显示
func _on_hand_updated(cards: Array) -> void:
	print("[HandUI] 更新手牌显示，收到 %d 张卡" % cards.size())
	
	# 清空现有卡牌按钮
	for child in cards_container.get_children():
		child.queue_free()
	
	# 创建新卡牌按钮
	for card in cards:
		if card:
			print("[HandUI] 添加卡牌按钮: %s" % card.display_name)
			var card_button = CARD_BUTTON_SCENE.instantiate()
			cards_container.add_child(card_button)
			card_button.set_card_data(card)
		else:
			push_warning("[HandUI] 收到空卡牌")

# 卡牌被选中
func _on_card_selected(card_button: CardButton) -> void:
	print("[HandUI] 卡牌被选中: %s" % card_button.card_data.display_name)
	
	# 检查AP是否足够（修正路径）
	var ap_manager = get_node_or_null("/root/Main/BattleScene/APManager")
	if not ap_manager:
		# 尝试备用路径
		ap_manager = get_tree().root.get_node_or_null("BattleScene/APManager")
	print("[HandUI] AP管理器: %s" % ("找到" if ap_manager else "未找到"))
	
	if ap_manager:
		print("[HandUI] 当前AP: %d, 需要: %d" % [ap_manager.get_current_ap(), card_button.card_data.cost])
		if not ap_manager.can_afford(card_button.card_data.cost):
			EventBus.ui_message.emit("行动点不足！", "warning")
			return
	
	selected_card = card_button
	is_selecting_target = true
	
	# 高亮可选择的格子
	print("[HandUI] 开始高亮有效目标，Board: %s" % ("存在" if board else "不存在"))
	highlight_valid_targets(card_button.card_data)
	
	EventBus.ui_message.emit("请选择目标位置", "info")

# 高亮有效目标
func highlight_valid_targets(card: CardData) -> void:
	if not board:
		push_warning("[HandUI] Board引用为空！")
		return
	
	var valid_positions: Array[Vector2i] = []
	
	print("[HandUI] 开始检查目标，棋盘大小: %dx%d" % [board.cols, board.rows])
	
	# 遍历所有格子，检查是否可作为目标
	for row in board.rows:
		for col in board.cols:
			var pos = Vector2i(col, row)
			if card.can_target(board, pos):
				valid_positions.append(pos)
	
	print("[HandUI] 找到 %d 个有效目标位置" % valid_positions.size())
	board.set_tiles_selectable(valid_positions)

# 格子被选中
func _on_tile_selected(position: Vector2i) -> void:
	if not is_selecting_target or not selected_card:
		return
	
	var card = selected_card.card_data
	
	# 检查目标是否有效
	if not card.can_target(board, position):
		EventBus.ui_message.emit("无效的目标！", "warning")
		return
	
	# 扣除AP（修正路径）
	var ap_manager = get_node_or_null("/root/Main/BattleScene/APManager")
	if not ap_manager:
		# 尝试备用路径
		ap_manager = get_tree().root.get_node_or_null("BattleScene/APManager")
	if ap_manager:
		if not ap_manager.spend_ap(card.cost):
			EventBus.ui_message.emit("行动点不足！", "warning")
			return
	
	# 执行卡牌效果
	card.execute_effects(board, position)
	
	# 打出卡牌
	DeckManager.play_card(card, position)
	
	# 清除选择状态
	clear_selection()

# 清除选择状态
func clear_selection() -> void:
	selected_card = null
	is_selecting_target = false
	if board:
		board.clear_tile_selection()

# 处理取消操作（ESC键）
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and is_selecting_target:
		clear_selection()
		EventBus.ui_message.emit("已取消", "info")
