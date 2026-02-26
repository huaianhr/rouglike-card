# 战斗结算器
# 负责处理单位间的攻击、伤害计算
class_name CombatResolver
extends Node

# 棋盘引用
var board: Board
var tower_manager  # 核心防御塔管理器引用（动态设置）

func _ready() -> void:
	EventBus.combat_phase_changed.connect(_on_combat_phase_changed)

# 设置棋盘引用
func set_board(b: Board) -> void:
	board = b

# 设置塔管理器引用
func set_tower_manager(tm) -> void:
	tower_manager = tm

# 战斗阶段改变时触发
func _on_combat_phase_changed(phase: String) -> void:
	if phase == "COMBAT":
		execute_combat()

# 执行战斗结算
func execute_combat() -> void:
	print("[CombatResolver] ========== 开始战斗结算 ==========")
	
	if not board:
		push_error("[CombatResolver] 棋盘引用为空")
		return
	
	# 1. 玩家单位攻击
	print("[CombatResolver] --- 玩家单位攻击阶段 ---")
	execute_faction_attacks(GameEnums.Faction.PLAYER)
	
	# 等待一小段时间以便看清动画（后期可替换为真实动画）
	await get_tree().create_timer(0.3).timeout
	
	# 2. 敌人单位攻击（塔攻击改为手动，在玩家回合触发）
	print("[CombatResolver] --- 敌人单位攻击阶段 ---")
	execute_faction_attacks(GameEnums.Faction.ENEMY)
	
	# 等待一小段时间
	await get_tree().create_timer(0.3).timeout
	
	print("[CombatResolver] ========== 战斗结算完成 ==========")
	EventBus.combat_resolved.emit()
	
	# 通知GameManager战斗结算完成
	GameManager.on_combat_resolved()

# 执行指定阵营的所有单位攻击
func execute_faction_attacks(faction: GameEnums.Faction) -> void:
	# 如果是敌人阵营，检查每行是否有玩家单位，决定攻击目标
	if faction == GameEnums.Faction.ENEMY and tower_manager:
		print("[CombatResolver] 🔍 开始检查敌人攻击目标（逐行检查）")
		for lane in range(3):
			var player_units_in_lane = board.get_units_in_lane(lane, GameEnums.Faction.PLAYER)
			var enemy_units_in_lane = board.get_units_in_lane(lane, GameEnums.Faction.ENEMY)
			
			print("[CombatResolver] 第 %d 行: 玩家单位数=%d, 敌人单位数=%d" % [lane, player_units_in_lane.size(), enemy_units_in_lane.size()])
			
			if player_units_in_lane.is_empty() and not enemy_units_in_lane.is_empty():
				# 该行无玩家单位，所有敌人攻击塔
				print("[CombatResolver] ⚠️ 第 %d 行无玩家单位，%d 个敌人攻击核心防御塔" % [lane, enemy_units_in_lane.size()])
				for enemy in enemy_units_in_lane:
					if enemy and is_instance_valid(enemy):
						var damage = enemy.attack
						print("[CombatResolver] 💥 %s 攻击核心防御塔，造成 %d 点伤害" % [enemy.unit_data.display_name, damage])
						tower_manager.take_damage(damage, enemy)
			else:
				# 该行有玩家单位，敌人正常攻击玩家单位
				print("[CombatResolver] ✅ 第 %d 行有玩家单位，敌人正常攻击玩家单位" % lane)
				for enemy in enemy_units_in_lane:
					if enemy and is_instance_valid(enemy):
						execute_unit_attack(enemy)
	else:
		# 玩家阵营正常攻击
		var units = board.get_units_by_faction(faction)
		print("[CombatResolver] %s 阵营共有 %d 个单位" % ["玩家" if faction == GameEnums.Faction.PLAYER else "敌人", units.size()])
		for unit in units:
			if unit and is_instance_valid(unit):
				execute_unit_attack(unit)

# 执行单个单位的攻击
func execute_unit_attack(unit: Unit) -> void:
	# 检查单位是否还活着
	if not unit or not is_instance_valid(unit):
		return
	
	# 检查攻击模式
	if unit.attack_pattern == GameEnums.AttackPattern.NONE:
		print("[CombatResolver] %s 不进行攻击" % unit.unit_data.display_name)
		return
	
	# 根据攻击模式查找目标
	var target = find_attack_target(unit)
	
	if target and is_instance_valid(target):
		print("[CombatResolver] %s 攻击 %s，造成 %d 点伤害" % [unit.unit_data.display_name, target.unit_data.display_name, unit.attack])
		target.take_damage(unit.attack, unit)
	else:
		print("[CombatResolver] %s 没有找到攻击目标" % unit.unit_data.display_name)

# 查找攻击目标
func find_attack_target(attacker: Unit) -> Unit:
	match attacker.attack_pattern:
		GameEnums.AttackPattern.MELEE:
			return find_melee_target(attacker)
		GameEnums.AttackPattern.RANGED:
			return find_ranged_target(attacker)
		GameEnums.AttackPattern.AOE:
			# TODO: 范围攻击暂未实现
			return find_melee_target(attacker)
	
	return null

# 查找近战目标（同行首个敌人）
func find_melee_target(attacker: Unit) -> Unit:
	var attacker_pos = attacker.grid_position
	var target_faction = GameEnums.Faction.ENEMY if attacker.faction == GameEnums.Faction.PLAYER else GameEnums.Faction.PLAYER
	
	# 玩家单位向右查找（列增加），敌人单位向左查找（列减少）
	var direction = 1 if attacker.faction == GameEnums.Faction.PLAYER else -1
	var start_col = attacker_pos.x + direction
	
	# 从攻击者位置开始，沿着同一行查找第一个敌人
	if direction > 0:
		# 玩家向右查找
		for col in range(start_col, board.cols):
			var check_pos = Vector2i(col, attacker_pos.y)
			var unit = board.get_unit_at(check_pos)
			if unit and unit.faction == target_faction:
				return unit
	else:
		# 敌人向左查找
		for col in range(start_col, -1, -1):
			var check_pos = Vector2i(col, attacker_pos.y)
			var unit = board.get_unit_at(check_pos)
			if unit and unit.faction == target_faction:
				return unit
	
	return null

# 查找远程目标（暂时使用近战逻辑，后续可扩展）
func find_ranged_target(attacker: Unit) -> Unit:
	# TODO: 实现真正的远程攻击逻辑（可配置攻击范围）
	return find_melee_target(attacker)
