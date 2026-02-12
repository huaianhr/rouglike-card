# 召唤单位效果
class_name SpawnUnitEffect
extends CardEffect

# 要召唤的单位模板
@export var unit_template_id: String = ""

# 生成偏移（相对于目标位置）
@export var spawn_offset: Vector2i = Vector2i.ZERO

func execute(context: EffectContext) -> void:
	if not context.board:
		push_error("SpawnUnitEffect: 缺少棋盘引用")
		return
	
	var spawn_pos = context.target_position + spawn_offset
	
	# 检查位置合法性
	if not context.board.is_valid_position(spawn_pos):
		EventBus.ui_message.emit("无效的召唤位置", "error")
		return
	
	# 检查格子是否为空
	if context.board.is_occupied(spawn_pos):
		EventBus.ui_message.emit("目标格子已被占用", "warning")
		return
	
	# 从配置加载单位模板
	var unit_data = ConfigLoader.get_unit(unit_template_id)
	if not unit_data:
		push_error("SpawnUnitEffect: 未找到单位模板 %s" % unit_template_id)
		return
	
	# 生成单位
	context.board.spawn_unit(unit_data, spawn_pos)

func get_description() -> String:
	return "召唤单位: %s" % unit_template_id
