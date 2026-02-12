# 卡牌效果基类
# 所有卡牌效果都应继承此类
class_name CardEffect
extends Resource

# 效果上下文（执行时传入）
class EffectContext:
	var caster: Node  # 施法者（可能为null）
	var target_position: Vector2i  # 目标位置
	var target_unit: Node  # 目标单位（可能为null）
	var board: Node  # 棋盘引用
	
	func _init(_caster = null, _target_pos = Vector2i.ZERO, _target_unit = null, _board = null):
		caster = _caster
		target_position = _target_pos
		target_unit = _target_unit
		board = _board

# 执行效果（子类必须重写）
func execute(context: EffectContext) -> void:
	push_warning("CardEffect.execute() 未被重写")

# 获取效果描述（用于UI显示）
func get_description() -> String:
	return "未定义效果"
