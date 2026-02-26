# 胜负判定器
# 负责检测胜利和失败条件
class_name VictoryChecker
extends Node

# 棋盘引用
var board: Board
var tower_manager  # 核心防御塔管理器引用（动态设置）

# 关卡配置
var level_config: LevelConfig

func _ready() -> void:
	EventBus.level_started.connect(_on_level_started)
	EventBus.combat_phase_changed.connect(_on_combat_phase_changed)
	EventBus.tower_destroyed.connect(_on_tower_destroyed)

# 设置棋盘引用
func set_board(b: Board) -> void:
	board = b

# 设置塔管理器引用
func set_tower_manager(tm) -> void:
	tower_manager = tm

# 关卡开始时初始化
func _on_level_started(config: Resource) -> void:
	level_config = config
	print("[VictoryChecker] 关卡开始: %s" % config.level_id)

# 战斗阶段改变时触发
func _on_combat_phase_changed(phase: String) -> void:
	if phase == "CHECK_VICTORY":
		check_conditions()

# 检查胜负条件
func check_conditions() -> void:
	print("==========================================")
	print("[VictoryChecker] ========== 检查胜负条件 ==========")
	print("[VictoryChecker] 当前回合: %d" % GameManager.current_turn)
	print("[VictoryChecker] 当前阶段: %s" % GameManager.CombatPhase.keys()[GameManager.current_phase])
	print("==========================================")
	
	# 先检查失败
	if check_defeat():
		print("[VictoryChecker] ❌❌❌ 检测到失败条件！触发失败！")
		GameManager.trigger_defeat()
		return
	
	# 再检查胜利
	if check_victory():
		print("[VictoryChecker] ✅✅✅ 检测到胜利条件！触发胜利！")
		GameManager.trigger_victory()
		return
	
	print("[VictoryChecker] ✅ 未触发胜负，继续战斗")
	# 没有触发胜负，继续下一回合
	GameManager.continue_game()

# 检查失败条件：任意敌人到达或越过第0列 OR 核心防御塔被摧毁
func check_defeat() -> bool:
	if not board:
		print("[VictoryChecker] ⚠️ Board引用为空")
		return false
	
	print("[VictoryChecker] ========== 开始检查失败条件 ==========")
	
	# 1. 检查核心防御塔是否被摧毁
	if tower_manager:
		print("[VictoryChecker] 检查塔状态 - 当前HP: %d, 最大HP: %d" % [tower_manager.current_hp, tower_manager.config.max_hp])
		if tower_manager.current_hp <= 0:
			print("[VictoryChecker] ❌❌❌ 失败原因：核心防御塔被摧毁！")
			return true
		else:
			print("[VictoryChecker] ✅ 塔状态正常")
	else:
		print("[VictoryChecker] ⚠️ TowerManager引用为空")
	
	# 2. 检查是否有敌人到达败北列
	var defeat_column = 0
	if GameManager.battle_rules:
		defeat_column = GameManager.battle_rules.defeat_column
	
	var enemies = board.get_units_by_faction(GameEnums.Faction.ENEMY)
	print("[VictoryChecker] 当前场上敌人数量: %d" % enemies.size())
	
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			print("[VictoryChecker] 检查敌人: %s 位置: %s (X=%d, 败北列=%d)" % [enemy.unit_data.display_name, enemy.grid_position, enemy.grid_position.x, defeat_column])
			if enemy.grid_position.x <= defeat_column:
				print("[VictoryChecker] ❌❌❌ 失败原因：%s 到达第 %d 列（位置: %s）" % [enemy.unit_data.display_name, enemy.grid_position.x, enemy.grid_position])
				return true
	
	print("[VictoryChecker] ✅ 未检测到失败条件")
	return false

# 塔被摧毁事件（立即触发失败）
func _on_tower_destroyed() -> void:
	print("[VictoryChecker] 核心防御塔被摧毁，立即触发失败")
	GameManager.trigger_defeat()

# 检查胜利条件：所有波次已生成 + 场上无敌人
func check_victory() -> bool:
	if not board or not level_config:
		return false
	
	# 1. 检查是否所有波次都已经过了生成回合
	var all_waves_passed = check_all_waves_passed()
	
	# 2. 检查场上是否还有敌人
	var enemies = board.get_units_by_faction(GameEnums.Faction.ENEMY)
	var no_enemies = enemies.is_empty()
	
	print("[VictoryChecker] 所有波次已过: %s, 场上敌人数: %d" % [all_waves_passed, enemies.size()])
	
	return all_waves_passed and no_enemies

# 检查是否所有波次的生成回合都已经过去
func check_all_waves_passed() -> bool:
	if not level_config or level_config.enemy_waves.is_empty():
		return true
	
	# 找到最后一个波次的生成回合
	var last_wave_turn = 0
	for wave in level_config.enemy_waves:
		if wave and wave.spawn_turn > last_wave_turn:
			last_wave_turn = wave.spawn_turn
	
	var current_turn = GameManager.current_turn
	
	print("[VictoryChecker] 当前回合: %d, 最后波次回合: %d" % [current_turn, last_wave_turn])
	
	# 当前回合必须大于最后波次回合
	return current_turn > last_wave_turn
