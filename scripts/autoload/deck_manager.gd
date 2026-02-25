# 卡组管理器
# 负责牌库、抽牌堆、手牌、弃牌堆的管理
extends Node

# 玩家拥有的所有卡牌（持久化数据，跨关卡保留）
var library: Array[Resource] = []  # Array[CardData]

# 标志位：牌库是否已初始化
var is_library_initialized: bool = false

# 当前局内的牌堆
var draw_pile: Array[Resource] = []  # 抽牌堆
var hand: Array[Resource] = []  # 手牌
var discard_pile: Array[Resource] = []  # 弃牌堆

# 手牌上限（从配置读取）
var max_hand_size: int = 10

func _ready() -> void:
	EventBus.turn_started.connect(_on_turn_started)

# 初始化卡组（从配置加载初始牌组）- 只在游戏首次开始时调用
func initialize_deck(starter_cards: Array[Resource]) -> void:
	if is_library_initialized:
		print("[DeckManager] ⚠️ 牌库已初始化，跳过重复初始化（保留现有 %d 张卡）" % library.size())
		return
	
	library.clear()
	library.append_array(starter_cards)
	is_library_initialized = true
	print("[DeckManager] ✅ 初始化永久牌库，共 %d 张卡" % library.size())
	prepare_battle_deck()

# 准备战斗牌组（将 library 复制到抽牌堆并洗牌）
func prepare_battle_deck() -> void:
	draw_pile.clear()
	hand.clear()
	discard_pile.clear()
	
	draw_pile.append_array(library)
	shuffle_deck()

# 洗牌
func shuffle_deck() -> void:
	draw_pile.shuffle()

# 抽牌
func draw_cards(count: int) -> void:
	for i in count:
		if hand.size() >= max_hand_size:
			EventBus.ui_message.emit("手牌已满！", "warning")
			break
		
		# 如果抽牌堆空了，将弃牌堆重新洗入
		if draw_pile.is_empty():
			if discard_pile.is_empty():
				EventBus.ui_message.emit("没有更多卡牌可抽！", "info")
				print("[DeckManager] ⚠️ 抽牌堆和弃牌堆都为空，无法继续抽牌")
				break
			print("[DeckManager] 🔄 抽牌堆为空，将弃牌堆（%d张）洗牌后补充" % discard_pile.size())
			draw_pile.append_array(discard_pile)
			discard_pile.clear()
			shuffle_deck()
			print("[DeckManager] ✅ 抽牌堆已补充：%d 张" % draw_pile.size())
		
		var card = draw_pile.pop_front()
		hand.append(card)
		print("[DeckManager] 抽到卡牌: %s" % card.display_name)
		EventBus.card_drawn.emit(card)
	
	print("[DeckManager] 抽牌完成，当前手牌: %d 张" % hand.size())
	EventBus.hand_updated.emit(hand)

# 打出卡牌
func play_card(card: Resource, target_position: Vector2i) -> bool:
	if not card in hand:
		push_warning("尝试打出不在手牌中的卡牌")
		return false
	
	# 从手牌移除
	hand.erase(card)
	
	# 根据卡牌类型决定去向
	if card.is_consumable:
		# 消耗类：直接消失，不进入弃牌堆
		print("[DeckManager] 💥 消耗卡牌: %s（直接移除）" % card.display_name)
	else:
		# 循环类：进入弃牌堆
		discard_pile.append(card)
		print("[DeckManager] 🔄 循环卡牌: %s（进入弃牌堆）" % card.display_name)
	
	EventBus.card_played.emit(card, target_position)
	EventBus.hand_updated.emit(hand)
	return true

# 弃置手牌（回合结束时）
func discard_hand() -> void:
	discard_pile.append_array(hand)
	hand.clear()
	EventBus.hand_updated.emit(hand)

# 回合开始时抽牌
func _on_turn_started(turn_number: int) -> void:
	print("[DeckManager] 回合 %d 开始，抽牌堆: %d 张，手牌: %d 张" % [turn_number, draw_pile.size(), hand.size()])
	
	if turn_number == 1:
		# 首回合抽初始手牌
		var starting_hand_size = GameManager.battle_rules.starting_hand_size if GameManager.battle_rules else 5
		print("[DeckManager] 首回合抽 %d 张牌" % starting_hand_size)
		draw_cards(starting_hand_size)
	else:
		# 后续回合先弃牌再抽牌
		discard_hand()
		draw_cards(GameManager.battle_rules.starting_hand_size if GameManager.battle_rules else 5)

# 添加卡牌到牌库（奖励获得）
func add_card_to_library(card: Resource) -> void:
	library.append(card)
	EventBus.ui_message.emit("获得新卡牌：%s" % card.display_name, "info")
	print("[DeckManager] ✅ 卡牌 %s 已添加到永久牌库（当前牌库: %d 张）" % [card.display_name, library.size()])
