# 核心防御塔管理器
# 管理塔的状态、攻击和受伤逻辑
class_name TowerManager
extends Node

var config: TowerConfig  # 塔配置
var current_hp: int      # 当前生命值
var last_attack_turn: int = -999  # 上次攻击的回合数

var board: Board  # 战场引用

# 初始化塔
func initialize(tower_config: TowerConfig, starting_hp: int = -1) -> void:
	config = tower_config
	if starting_hp == -1:
		current_hp = config.max_hp
	else:
		current_hp = starting_hp
	last_attack_turn = -999
	
	print("========================================")
	print("[TowerManager] 🏰 初始化塔: %s" % config.display_name)
	print("[TowerManager] 起始HP: %d, 最大HP: %d" % [starting_hp, config.max_hp])
	print("[TowerManager] 当前HP: %d" % current_hp)
	print("========================================")
	EventBus.tower_initialized.emit(config, current_hp)
	EventBus.tower_hp_changed.emit(current_hp, config.max_hp)

# 设置Board引用
func set_board(board_ref: Board) -> void:
	board = board_ref

# 检查是否可以攻击
func can_attack(current_turn: int) -> bool:
	return (current_turn - last_attack_turn) >= config.attack_interval

# 执行攻击
func execute_attack(current_turn: int) -> void:
	if not can_attack(current_turn):
		return
	
	if not board:
		push_error("[TowerManager] Board引用未设置")
		return
	
	var target = select_attack_target()
	if target:
		var target_name = target.unit_data.display_name if target.unit_data else "未知"
		print("[TowerManager] 🗼 核心防御塔攻击 %s，造成 %d 伤害" % [target_name, config.attack])
		target.take_damage(config.attack)
		EventBus.tower_attacked.emit(target)
		last_attack_turn = current_turn
	else:
		print("[TowerManager] 核心防御塔无攻击目标")

# 选择攻击目标（优先从第0行到第2行，选择首个有敌人的行）
func select_attack_target() -> Node:
	for lane in range(3):
		var enemies_in_lane = board.get_units_in_lane(lane, GameEnums.Faction.ENEMY)
		if not enemies_in_lane.is_empty():
			# 按X坐标排序，选择最左侧的敌人
			enemies_in_lane.sort_custom(func(a, b): return a.grid_position.x < b.grid_position.x)
			return enemies_in_lane[0]
	return null

# 受到伤害
func take_damage(damage: int, attacker: Node = null) -> void:
	var attacker_name = "未知"
	if attacker and "unit_data" in attacker and attacker.unit_data:
		attacker_name = attacker.unit_data.display_name
	
	print("========================================")
	print("[TowerManager] 💥💥💥 核心防御塔受到攻击！")
	print("[TowerManager] 攻击者: %s" % attacker_name)
	print("[TowerManager] 伤害值: %d" % damage)
	print("[TowerManager] 攻击前HP: %d/%d" % [current_hp, config.max_hp])
	
	current_hp -= damage
	if current_hp < 0:
		current_hp = 0
	
	print("[TowerManager] 攻击后HP: %d/%d" % [current_hp, config.max_hp])
	print("========================================")
	
	EventBus.tower_took_damage.emit(damage, attacker)
	EventBus.tower_hp_changed.emit(current_hp, config.max_hp)
	
	if current_hp <= 0:
		trigger_destroyed()

# 触发塔被摧毁
func trigger_destroyed() -> void:
	print("[TowerManager] ⚠️ 核心防御塔被摧毁！")
	EventBus.tower_destroyed.emit()

# 获取下次攻击的剩余回合数
func get_turns_until_attack(current_turn: int) -> int:
	var turns = config.attack_interval - (current_turn - last_attack_turn)
	return max(0, turns)

# 手动攻击（玩家选择目标）
func manual_attack(target: Node, current_turn: int) -> void:
	if not can_attack(current_turn):
		print("[TowerManager] 塔还在冷却中，无法攻击")
		return
	
	if not target:
		push_error("[TowerManager] 攻击目标为空")
		return
	
	var target_name = target.unit_data.display_name if target.unit_data else "未知"
	print("[TowerManager] 🗼 核心防御塔攻击 %s，造成 %d 伤害" % [target_name, config.attack])
	
	# 先播放受击特效（在造成伤害前，避免单位死亡导致特效无法播放）
	if target.has_method("play_hit_effect"):
		target.play_hit_effect()
	
	# 等待特效播放一小段时间后再造成伤害
	await get_tree().create_timer(0.3).timeout
	
	# 造成伤害
	if is_instance_valid(target):
		target.take_damage(config.attack)
	
	# 发送信号
	EventBus.tower_attacked.emit(target)
	
	# 重置冷却
	last_attack_turn = current_turn
	print("[TowerManager] 塔攻击完成，重置冷却")

# 获取所有可攻击的前排敌人
func get_valid_targets() -> Array[Node]:
	var targets: Array[Node] = []
	
	if not board:
		return targets
	
	# 遍历每一行，找到最左侧的敌人
	for lane in range(3):
		var enemies_in_lane = board.get_units_in_lane(lane, GameEnums.Faction.ENEMY)
		if not enemies_in_lane.is_empty():
			# 按X坐标排序，找到最左侧的敌人
			enemies_in_lane.sort_custom(func(a, b): return a.grid_position.x < b.grid_position.x)
			targets.append(enemies_in_lane[0])
	
	return targets
