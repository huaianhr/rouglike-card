# 增益/减益效果
class_name BuffStatEffect
extends CardEffect

# 属性类型
@export_enum("attack", "max_hp", "armor") var stat_type: String = "attack"

# 数值变化（正数为增益，负数为减益）
@export var value: int = 0

# 持续时间（-1表示永久，0表示瞬时，>0表示回合数）
@export var duration: int = -1

func execute(context: EffectContext) -> void:
	if not context.target_unit:
		EventBus.ui_message.emit("必须选择一个单位作为目标", "warning")
		return
	
	# 检查目标是否为友军（根据卡牌的目标规则，这里假设已经过滤）
	if context.target_unit.faction != GameEnums.Faction.PLAYER:
		EventBus.ui_message.emit("只能对友军使用", "warning")
		return
	
	# 应用属性变化
	match stat_type:
		"attack":
			var old_value = context.target_unit.attack
			context.target_unit.attack += value
			print("[BuffStatEffect] %s 攻击力: %d -> %d" % [context.target_unit.unit_data.display_name, old_value, context.target_unit.attack])
			EventBus.unit_stat_changed.emit(context.target_unit, "attack", old_value, context.target_unit.attack)
		"max_hp":
			var old_value = context.target_unit.max_hp
			context.target_unit.max_hp += value
			context.target_unit.current_hp += value  # 同时增加当前HP
			print("[BuffStatEffect] %s 最大HP: %d -> %d" % [context.target_unit.unit_data.display_name, old_value, context.target_unit.max_hp])
			EventBus.unit_stat_changed.emit(context.target_unit, "max_hp", old_value, context.target_unit.max_hp)
		"armor":
			var old_value = context.target_unit.armor
			context.target_unit.armor += value
			print("[BuffStatEffect] %s 护甲: %d -> %d" % [context.target_unit.unit_data.display_name, old_value, context.target_unit.armor])
			EventBus.unit_stat_changed.emit(context.target_unit, "armor", old_value, context.target_unit.armor)
	
	# 立即更新单位UI显示
	context.target_unit.update_visual()
	
	# TODO: 如果有持续时间，需要注册buff并在回合结束时移除
	# 目前只实现永久效果

func get_description() -> String:
	var prefix = "+" if value > 0 else ""
	var stat_name = ""
	match stat_type:
		"attack": stat_name = "攻击力"
		"max_hp": stat_name = "生命值上限"
		"armor": stat_name = "护甲"
	return "%s%d %s" % [prefix, value, stat_name]
