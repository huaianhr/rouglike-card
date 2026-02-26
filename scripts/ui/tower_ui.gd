# 核心防御塔UI
# 显示塔的生命值、攻击力和冷却时间
class_name TowerUI
extends Control

@onready var tower_name_label: Label = $Panel/MarginContainer/VBoxContainer/TowerNameLabel
@onready var hp_label: Label = $Panel/MarginContainer/VBoxContainer/HPLabel
@onready var hp_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/HPBar
@onready var attack_label: Label = $Panel/MarginContainer/VBoxContainer/AttackLabel
@onready var cooldown_label: Label = $Panel/MarginContainer/VBoxContainer/CooldownLabel
@onready var attack_button: Button = $Panel/MarginContainer/VBoxContainer/AttackButton

# 塔管理器引用
var tower_manager
var board  # Board引用
var is_selecting_target: bool = false  # 是否正在选择目标

func _ready() -> void:
	# 连接信号
	EventBus.tower_initialized.connect(_on_tower_initialized)
	EventBus.tower_hp_changed.connect(_on_tower_hp_changed)
	EventBus.turn_started.connect(_on_turn_started)
	EventBus.combat_phase_changed.connect(_on_combat_phase_changed)
	EventBus.tile_selected.connect(_on_tile_selected)
	
	# 连接攻击按钮
	attack_button.pressed.connect(_on_attack_button_pressed)

# 设置塔管理器引用
func set_tower_manager(tm) -> void:
	tower_manager = tm
	update_display()

# 设置Board引用
func set_board(b: Board) -> void:
	board = b

# 塔初始化时更新UI
func _on_tower_initialized(tower_config: Resource, current_hp: int) -> void:
	update_display()

# 塔HP变化时更新
func _on_tower_hp_changed(current_hp: int, max_hp: int) -> void:
	update_hp_display(current_hp, max_hp)

# 回合开始时更新冷却显示
func _on_turn_started(turn_number: int) -> void:
	if tower_manager:
		update_cooldown_display(turn_number)

# 更新完整显示
func update_display() -> void:
	if not tower_manager or not tower_manager.config:
		return
	
	var config = tower_manager.config
	var current_hp = tower_manager.current_hp
	
	tower_name_label.text = config.display_name
	attack_label.text = "攻击力: %d" % config.attack
	update_hp_display(current_hp, config.max_hp)
	update_cooldown_display(GameManager.current_turn)

# 更新HP显示
func update_hp_display(current_hp: int, max_hp: int) -> void:
	hp_label.text = "生命: %d / %d" % [current_hp, max_hp]
	hp_bar.value = current_hp
	hp_bar.max_value = max_hp
	
	# 根据HP百分比改变颜色
	var hp_percent = float(current_hp) / float(max_hp)
	if hp_percent > 0.6:
		hp_bar.modulate = Color(0.3, 1.0, 0.3)  # 绿色
	elif hp_percent > 0.3:
		hp_bar.modulate = Color(1.0, 1.0, 0.3)  # 黄色
	else:
		hp_bar.modulate = Color(1.0, 0.3, 0.3)  # 红色

# 更新冷却显示
func update_cooldown_display(current_turn: int) -> void:
	if not tower_manager:
		return
	
	var turns_until_attack = tower_manager.get_turns_until_attack(current_turn)
	
	if turns_until_attack <= 0:
		cooldown_label.text = "⚡ 准备就绪！"
		cooldown_label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.3))
	else:
		cooldown_label.text = "冷却：%d 回合" % turns_until_attack
		cooldown_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	
	# 更新攻击按钮状态
	update_attack_button()

# 更新攻击按钮状态
func update_attack_button() -> void:
	if not tower_manager or not attack_button:
		return
	
	# 只有在玩家回合且塔可以攻击时才启用按钮
	var can_attack = tower_manager.can_attack(GameManager.current_turn)
	var is_player_turn = GameManager.current_phase == GameManager.CombatPhase.PLAYER_TURN
	
	attack_button.disabled = not (can_attack and is_player_turn)
	
	# 高亮显示
	if can_attack and is_player_turn:
		attack_button.modulate = Color(1.0, 1.0, 0.5)  # 黄色高亮
	else:
		attack_button.modulate = Color(1.0, 1.0, 1.0)  # 正常颜色

# 战斗阶段改变时更新按钮
func _on_combat_phase_changed(phase: String) -> void:
	update_attack_button()
	
	# 如果不在玩家回合，取消目标选择
	if phase != "PLAYER_TURN" and is_selecting_target:
		cancel_target_selection()

# 攻击按钮被点击
func _on_attack_button_pressed() -> void:
	if not tower_manager or not board:
		return
	
	print("[TowerUI] 玩家点击塔攻击按钮，开始选择目标")
	is_selecting_target = true
	
	# 获取可攻击的前排敌人并高亮
	var valid_targets = tower_manager.get_valid_targets()
	if valid_targets.is_empty():
		print("[TowerUI] 没有可攻击的目标")
		EventBus.ui_message.emit("没有可攻击的目标", "warning")
		is_selecting_target = false
		return
	
	# 高亮可选择的格子
	var target_positions: Array[Vector2i] = []
	for target in valid_targets:
		target_positions.append(target.grid_position)
	
	board.set_tiles_selectable(target_positions)
	EventBus.ui_message.emit("请选择攻击目标", "info")

# 格子被选中（目标选择）
func _on_tile_selected(position: Vector2i) -> void:
	if not is_selecting_target:
		return
	
	# 获取选中位置的单位
	var target_unit = board.get_unit_at(position)
	if not target_unit or target_unit.faction != GameEnums.Faction.ENEMY:
		return
	
	print("[TowerUI] 玩家选择目标: %s at %s" % [target_unit.unit_data.display_name, position])
	
	# 取消选择模式（先取消高亮）
	cancel_target_selection()
	
	# 立即执行攻击（等待攻击完成）
	await tower_manager.manual_attack(target_unit, GameManager.current_turn)
	
	print("[TowerUI] 攻击完成，更新UI")
	
	# 更新UI（攻击完成后才更新）
	update_attack_button()
	update_cooldown_display(GameManager.current_turn)
	
	# 强制发送信号，确保UI刷新
	EventBus.tower_attacked.emit(target_unit)

# 取消目标选择
func cancel_target_selection() -> void:
	is_selecting_target = false
	if board:
		board.clear_tile_selection()
