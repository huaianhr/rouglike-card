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
	current_ap = battle_rules.starting_ap
	max_ap = battle_rules.max_ap
	ap_per_turn = battle_rules.ap_per_turn
	EventBus.ap_changed.emit(current_ap, max_ap)

# 回合开始时恢复AP
func _on_turn_started(turn_number: int) -> void:
	if turn_number == 1:
		# 第一回合已经在initialize中设置了
		return
	else:
		# 后续回合恢复AP
		restore_ap(ap_per_turn)

# 恢复AP
func restore_ap(amount: int) -> void:
	current_ap = min(current_ap + amount, max_ap)
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
