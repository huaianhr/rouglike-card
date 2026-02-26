# 战斗单位
class_name Unit
extends Control

# 单位数据模板
var unit_data: UnitData

# 当前属性
var faction: GameEnums.Faction
var current_hp: int
var max_hp: int
var attack: int
var armor: int = 0  # 护甲值

# 攻击属性
var attack_pattern: GameEnums.AttackPattern
var attack_range: int

# 移动属性
var move_pattern: GameEnums.MovePattern

# 腐化相关
var corruption_counter: int = 0
var corruption_source: Unit = null

# 位置
var grid_position: Vector2i = Vector2i.ZERO

# UI节点引用
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var hp_label: Label = $VBoxContainer/HPLabel
@onready var stats_label: Label = $VBoxContainer/StatsLabel

func _ready() -> void:
	update_visual()

# 初始化单位
func initialize(data: UnitData, position: Vector2i) -> void:
	unit_data = data
	grid_position = position
	
	# 复制数据到运行时属性
	faction = data.faction
	max_hp = data.max_hp
	current_hp = max_hp
	attack = data.attack
	attack_pattern = data.attack_pattern
	attack_range = data.attack_range
	move_pattern = data.move_pattern
	
	update_visual()

# 更新视觉显示
func update_visual() -> void:
	if not is_node_ready():
		return
	
	name_label.text = unit_data.display_name if unit_data else "未知"
	hp_label.text = "HP: %d/%d" % [current_hp, max_hp]
	stats_label.text = "ATK: %d" % attack
	
	if armor > 0:
		stats_label.text += " | 护甲: %d" % armor
	
	if corruption_counter > 0:
		stats_label.text += " | 腐化: %d/3" % corruption_counter
	
	# 根据阵营改变颜色
	var bg_color = Color(0.3, 0.5, 0.8, 1.0) if faction == GameEnums.Faction.PLAYER else Color(0.8, 0.3, 0.3, 1.0)
	$Background.color = bg_color

# 受到伤害
func take_damage(damage: int, source: Node = null) -> void:
	var actual_damage = damage
	
	# 先扣护甲
	if armor > 0:
		if armor >= actual_damage:
			armor -= actual_damage
			actual_damage = 0
		else:
			actual_damage -= armor
			armor = 0
	
	# 再扣HP
	current_hp -= actual_damage
	current_hp = max(0, current_hp)
	
	EventBus.unit_damaged.emit(self, actual_damage, source)
	update_visual()
	
	if current_hp <= 0:
		die()

# 治疗
func heal(amount: int) -> void:
	var old_hp = current_hp
	current_hp = min(current_hp + amount, max_hp)
	EventBus.unit_healed.emit(self, current_hp - old_hp)
	update_visual()

# 死亡
func die() -> void:
	EventBus.unit_died.emit(self, grid_position)
	queue_free()

# 应用腐化
func apply_corruption(source: Unit) -> void:
	corruption_source = source
	corruption_counter += 1
	
	if corruption_counter >= GameManager.battle_rules.corrupt_threshold_turns:
		corrupt_to_enemy()
	else:
		update_visual()

# 腐化为敌人
func corrupt_to_enemy() -> void:
	# TODO: 根据 degraded_unit_id 转化为低一级敌人
	# 暂时简单处理：直接转为敌方阵营
	print("[Unit] %s 被腐化，转为敌方单位" % unit_data.display_name)
	faction = GameEnums.Faction.ENEMY
	move_pattern = GameEnums.MovePattern.FORWARD  # 设置为前进模式，让它也能推进
	corruption_counter = 0
	EventBus.unit_corrupted.emit(self, "ENEMY")
	update_visual()

# 播放受击特效（超级增强版：巨大闪烁+剧烈抖动+缩放）
func play_hit_effect() -> void:
	print("========================================")
	print("[Unit] 🎬🎬🎬 %s 开始播放受击特效！！！" % unit_data.display_name)
	print("========================================")
	
	# 保存原始位置和缩放
	var original_position = position
	var original_scale = scale
	
	# 创建Tween动画
	var tween = create_tween()
	tween.set_parallel(true)
	
	# 1. 极其强烈的颜色闪烁（3次，纯红色）
	tween.tween_property(self, "modulate", Color(3.0, 0.0, 0.0), 0.12)  # 第1次变红（极红）
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.12).set_delay(0.12)  # 恢复
	tween.tween_property(self, "modulate", Color(3.0, 0.0, 0.0), 0.12).set_delay(0.24)  # 第2次变红
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.12).set_delay(0.36)  # 恢复
	tween.tween_property(self, "modulate", Color(3.0, 0.0, 0.0), 0.12).set_delay(0.48)  # 第3次变红
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0), 0.15).set_delay(0.6)  # 最终恢复
	
	# 2. 巨大缩放效果：瞬间放大1.5倍 -> 弹性恢复
	tween.tween_property(self, "scale", original_scale * 1.5, 0.15)  # 快速放大
	tween.tween_property(self, "scale", original_scale, 0.4).set_delay(0.15).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)  # 弹性恢复
	
	# 3. 剧烈抖动效果：大幅度左右抖动（8次）
	var shake_amplitude = 15.0  # 抖动幅度
	tween.tween_property(self, "position", original_position + Vector2(shake_amplitude, 0), 0.04)
	tween.tween_property(self, "position", original_position + Vector2(-shake_amplitude, 0), 0.04).set_delay(0.04)
	tween.tween_property(self, "position", original_position + Vector2(shake_amplitude, 0), 0.04).set_delay(0.08)
	tween.tween_property(self, "position", original_position + Vector2(-shake_amplitude, 0), 0.04).set_delay(0.12)
	tween.tween_property(self, "position", original_position + Vector2(shake_amplitude * 0.7, 0), 0.04).set_delay(0.16)
	tween.tween_property(self, "position", original_position + Vector2(-shake_amplitude * 0.7, 0), 0.04).set_delay(0.2)
	tween.tween_property(self, "position", original_position + Vector2(shake_amplitude * 0.4, 0), 0.04).set_delay(0.24)
	tween.tween_property(self, "position", original_position, 0.1).set_delay(0.28)
	
	# 4. 添加旋转效果（新增）
	tween.tween_property(self, "rotation", deg_to_rad(10), 0.1)
	tween.tween_property(self, "rotation", deg_to_rad(-10), 0.1).set_delay(0.1)
	tween.tween_property(self, "rotation", deg_to_rad(5), 0.1).set_delay(0.2)
	tween.tween_property(self, "rotation", deg_to_rad(0), 0.15).set_delay(0.3)
	
	# 5. 添加完成回调，确保恢复到原始状态
	tween.finished.connect(func():
		modulate = Color(1.0, 1.0, 1.0)
		scale = original_scale
		position = original_position
		rotation = 0
	)
