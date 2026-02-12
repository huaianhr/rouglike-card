# 敌人管理器
# 负责敌人波次生成和推进
class_name EnemyManager
extends Node

# 棋盘引用
var board: Board

# 腐化阈值（从配置读取）
var corrupt_threshold: int = 3

func _ready() -> void:
	EventBus.combat_phase_changed.connect(_on_combat_phase_changed)

# 设置棋盘引用
func set_board(b: Board) -> void:
	board = b

# 战斗阶段改变时触发
func _on_combat_phase_changed(phase: String) -> void:
	if phase == "ENEMY_TURN":
		execute_enemy_turn()

# 执行敌人回合
func execute_enemy_turn() -> void:
	print("[EnemyManager] ========== 敌人回合开始 ==========")
	
	if not board:
		push_error("[EnemyManager] 棋盘引用为空")
		return
	
	# 获取腐化阈值
	if GameManager.battle_rules:
		corrupt_threshold = GameManager.battle_rules.corrupt_threshold_turns
	
	# 执行敌人推进
	execute_enemy_push()
	
	await get_tree().create_timer(0.5).timeout
	
	print("[EnemyManager] ========== 敌人回合结束 ==========")
	
	# 通知GameManager敌人回合结束
	GameManager.on_enemy_turn_ended()

# 执行敌人推进
func execute_enemy_push() -> void:
	var enemies = board.get_units_by_faction(GameEnums.Faction.ENEMY)
	
	print("[EnemyManager] 共有 %d 个敌人单位" % enemies.size())
	
	# 创建推进列表（避免在遍历时修改字典）
	var push_actions: Array = []
	
	for enemy in enemies:
		if enemy and is_instance_valid(enemy):
			var current_pos = enemy.grid_position
			var target_pos = Vector2i(current_pos.x - 1, current_pos.y)  # 向左推进
			
			# 检查目标位置
			if board.is_valid_position(target_pos):
				var target_unit = board.get_unit_at(target_pos)
				
				if target_unit:
					# 目标位置有单位
					if target_unit.faction == GameEnums.Faction.PLAYER:
						# 是玩家单位，触发腐化
						push_actions.append({
							"type": "corrupt",
							"enemy": enemy,
							"target": target_unit,
							"pos": current_pos
						})
					else:
						# 是敌方单位，不推进
						print("[EnemyManager] %s 无法推进（前方有友军）" % enemy.unit_data.display_name)
				else:
					# 目标位置为空，正常推进
					push_actions.append({
						"type": "move",
						"enemy": enemy,
						"from": current_pos,
						"to": target_pos
					})
			else:
				# 到达边界
				print("[EnemyManager] %s 到达边界" % enemy.unit_data.display_name)
				# TODO: 触发失败条件检测
	
	# 执行所有推进动作
	for action in push_actions:
		execute_push_action(action)

# 执行单个推进动作
func execute_push_action(action: Dictionary) -> void:
	match action["type"]:
		"move":
			# 移动敌人
			var enemy = action["enemy"]
			var from_pos = action["from"]
			var to_pos = action["to"]
			
			if board.move_unit(from_pos, to_pos):
				print("[EnemyManager] %s 推进: %s -> %s" % [enemy.unit_data.display_name, from_pos, to_pos])
			
		"corrupt":
			# 触发腐化
			var enemy = action["enemy"]
			var target = action["target"]
			
			print("[EnemyManager] %s 尝试腐化 %s" % [enemy.unit_data.display_name, target.unit_data.display_name])
			
			# 应用腐化
			target.apply_corruption(enemy)
			
			print("[EnemyManager] %s 腐化计数: %d/%d" % [target.unit_data.display_name, target.corruption_counter, corrupt_threshold])
