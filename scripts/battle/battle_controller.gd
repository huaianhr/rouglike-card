# 战场控制器
class_name BattleController
extends Node

# 子节点引用
@onready var board: Board = $Board
@onready var hand_ui: HandUI = $HandUI
@onready var ap_manager: APManager = $APManager
@onready var combat_resolver: CombatResolver = $CombatResolver
@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var victory_checker: VictoryChecker = $VictoryChecker
@onready var turn_label: Label = $TurnUI/Panel/MarginContainer/TurnLabel
@onready var end_turn_button: Button = $TurnUI/Panel/MarginContainer/EndTurnButton

# 核心防御塔管理器
var tower_manager  # TowerManager（动态创建）
var tower_ui  # TowerUI（动态加载）

# 当前关卡
var current_level: LevelConfig

func _ready() -> void:
	# 创建TowerManager
	tower_manager = TowerManager.new()
	add_child(tower_manager)
	
	# 创建TowerUI
	var tower_ui_scene = load("res://scenes/ui/tower_ui.tscn")
	tower_ui = tower_ui_scene.instantiate()
	add_child(tower_ui)
	# 设置UI位置（左上角）
	tower_ui.position = Vector2(10, 10)
	
	# 连接信号
	end_turn_button.pressed.connect(_on_end_turn_pressed)
	EventBus.turn_started.connect(_on_turn_started)
	EventBus.victory_achieved.connect(_on_level_end)
	EventBus.defeat_triggered.connect(_on_level_end)
	
	# 设置HandUI的Board引用
	hand_ui.set_board(board)
	
	# 设置战斗系统的Board引用
	combat_resolver.set_board(board)
	combat_resolver.set_tower_manager(tower_manager)
	enemy_manager.set_board(board)
	victory_checker.set_board(board)
	victory_checker.set_tower_manager(tower_manager)
	tower_manager.set_board(board)
	
	# 加载测试关卡
	await get_tree().create_timer(0.1).timeout  # 等待Autoload初始化
	load_test_level()

# 加载测试关卡
func load_test_level() -> void:
	# 从GameManager获取当前应该加载的关卡ID
	var level_id = GameManager.get_current_level_id()
	if level_id.is_empty():
		push_error("[BattleController] 无法获取当前关卡ID")
		return
	
	print("[BattleController] 加载关卡: %s" % level_id)
	var level = ConfigLoader.get_level(level_id)
	if not level:
		push_error("[BattleController] 无法加载关卡: %s" % level_id)
		return
	
	current_level = level
	GameManager.load_level(level)
	
	# 初始化核心防御塔
	var chapter_id = level.chapter_id
	var tower_config = level.tower_config
	var starting_hp = GameManager.get_tower_hp(chapter_id, tower_config.max_hp)
	tower_manager.initialize(tower_config, starting_hp)
	
	# 设置TowerUI引用
	if tower_ui:
		tower_ui.set_tower_manager(tower_manager)
		tower_ui.set_board(board)
	
	# 初始化卡组（只在首次战斗时初始化，后续关卡保留牌库）
	if not DeckManager.is_library_initialized:
		# 首次战斗：从全局配置初始化牌库
		var initial_deck_ids = ConfigLoader.get_initial_deck_ids()
		var starter_cards: Array[Resource] = []
		for card_id in initial_deck_ids:
			var card = ConfigLoader.get_card(card_id)
			if card:
				starter_cards.append(card)
				print("[BattleController] 添加初始卡牌: %s" % card.display_name)
			else:
				push_warning("[BattleController] 未找到卡牌: %s" % card_id)
		
		print("[BattleController] 首次战斗，从全局配置初始化卡组，共 %d 张卡" % starter_cards.size())
		DeckManager.initialize_deck(starter_cards)
	else:
		# 后续关卡：保留牌库，重新准备战斗牌组
		print("[BattleController] 后续关卡，保留牌库（%d 张卡），重新准备战斗" % DeckManager.library.size())
		DeckManager.prepare_battle_deck()
	
	# 开始第0回合（部署回合）
	print("[BattleController] 开始第0回合（部署回合）")
	EventBus.turn_started.emit(0)

# 回合开始
func _on_turn_started(turn_number: int) -> void:
	# 第0回合显示"部署回合"
	if turn_number == 0:
		turn_label.text = "部署回合"
	else:
		turn_label.text = "第 %d 回合" % turn_number
	
	# 重新启用结束回合按钮
	end_turn_button.disabled = false
	
	# 生成敌人波次
	spawn_enemy_waves(turn_number)

# 生成敌人波次
func spawn_enemy_waves(turn_number: int) -> void:
	if not current_level:
		return
	
	# 第0回合（部署回合）不生成敌人
	if turn_number == 0:
		print("[BattleController] 🎯 部署回合，不生成敌人")
		return
	
	for wave in current_level.enemy_waves:
		if wave.spawn_turn == turn_number:
			var spawn_row = wave.lane
			
			# 生成敌人（使用独立列偏移）
			for i in wave.enemy_unit_ids.size():
				var enemy_id = wave.enemy_unit_ids[i]
				var enemy_data = ConfigLoader.get_unit(enemy_id)
				if enemy_data:
					# 使用独立偏移，兼容旧版配置
					var offset = 0
					if i < wave.enemy_offsets.size():
						offset = wave.enemy_offsets[i]
					else:
						# 旧版兼容：使用全局偏移+索引
						offset = wave.spawn_column_offset + i
					
					var spawn_col = board.cols - 1 - offset
					var spawn_pos = Vector2i(spawn_col, spawn_row)
					
					if board.is_valid_position(spawn_pos) and not board.is_occupied(spawn_pos):
						board.spawn_unit(enemy_data, spawn_pos)
					else:
						push_warning("无法在 %s 生成敌人（位置无效或已占用）" % spawn_pos)

# 关卡结束时保存塔HP
func _on_level_end() -> void:
	if current_level and tower_manager:
		GameManager.save_tower_hp(current_level.chapter_id, tower_manager.current_hp)

# 结束回合按钮
func _on_end_turn_pressed() -> void:
	print("[BattleController] 玩家结束回合")
	end_turn_button.disabled = true
	EventBus.turn_ended.emit()
