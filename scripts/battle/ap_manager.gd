# 行动点管理器
class_name APManager
extends Node

# 当前AP
var current_ap: int = 0

# 最大AP
var max_ap: int = 10

# 每回合获得的AP
var ap_per_turn: int = 3

func _ready() -> void:
	EventBus.turn_started.connect(_on_turn_started)
	EventBus.level_started.connect(_on_level_started)

# 初始化AP
func initialize(battle_rules: BattleRuleConfig) -> void:
	# 每回合固定AP，无上限（设置为999表示无限制）
	ap_per_turn = battle_rules.ap_per_turn
	max_ap = 999  # 无上限
	current_ap = 0  # 初始为0，等待第0回合开始时设置
	EventBus.ap_changed.emit(current_ap, max_ap)

# 回合开始时重置AP
func _on_turn_started(turn_number: int) -> void:
	# 每回合直接设置为固定AP，不累加
	current_ap = ap_per_turn
	print("[APManager] 回合 %d 开始，AP重置为 %d" % [turn_number, current_ap])
	EventBus.ap_changed.emit(current_ap, max_ap)

# 恢复AP（保留接口，但改为直接设置）
func restore_ap(amount: int) -> void:
	current_ap = amount
	EventBus.ap_changed.emit(current_ap, max_ap)

# 消耗AP
func spend_ap(amount: int) -> bool:
	print("[APManager] 尝试消耗 %d AP，当前 %d AP" % [amount, current_ap])
	if current_ap < amount:
		EventBus.ap_insufficient.emit(amount, current_ap)
		print("[APManager] AP不足")
		return false
	
	current_ap -= amount
	print("[APManager] 消耗成功，剩余 %d AP" % current_ap)
	EventBus.ap_changed.emit(current_ap, max_ap)
	return true

# 检查是否能支付
func can_afford(amount: int) -> bool:
	return current_ap >= amount

# 获取当前AP
func get_current_ap() -> int:
	return current_ap

# 获取最大AP
func get_max_ap() -> int:
	return max_ap

func _on_level_started(level_config: Resource) -> void:
	initialize(level_config.battle_rules)
