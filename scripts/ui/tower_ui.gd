# 核心防御塔UI
# 显示塔的生命值、攻击力和冷却时间
class_name TowerUI
extends Control

@onready var tower_name_label: Label = $Panel/MarginContainer/VBoxContainer/TowerNameLabel
@onready var hp_label: Label = $Panel/MarginContainer/VBoxContainer/HPLabel
@onready var hp_bar: ProgressBar = $Panel/MarginContainer/VBoxContainer/HPBar
@onready var attack_label: Label = $Panel/MarginContainer/VBoxContainer/AttackLabel
@onready var cooldown_label: Label = $Panel/MarginContainer/VBoxContainer/CooldownLabel

# 塔管理器引用
var tower_manager: TowerManager

func _ready() -> void:
	# 连接信号
	EventBus.tower_initialized.connect(_on_tower_initialized)
	EventBus.tower_hp_changed.connect(_on_tower_hp_changed)
	EventBus.turn_started.connect(_on_turn_started)

# 设置塔管理器引用
func set_tower_manager(tm: TowerManager) -> void:
	tower_manager = tm
	update_display()

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
