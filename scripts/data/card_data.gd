# 卡牌数据资源
class_name CardData
extends Resource

# 基础信息
@export var id: String = ""
@export var display_name: String = "未命名卡牌"
@export_multiline var description: String = ""

# 卡牌类型
@export var card_type: GameEnums.CardType = GameEnums.CardType.UNIT

# 费用
@export var cost: int = 1

# 是否为消耗类卡牌（使用后直接消失，不进入弃牌堆）
@export var is_consumable: bool = true

# 目标规则
@export var target_rule: GameEnums.TargetRule = GameEnums.TargetRule.EMPTY_TILE

# 效果列表（可以有多个效果）
@export var effects: Array[CardEffect] = []

# 图标路径（暂时用文字代替）
@export var icon_path: String = ""

# 检查是否可以对目标位置使用
func can_target(board: Node, position: Vector2i) -> bool:
	match target_rule:
		GameEnums.TargetRule.EMPTY_TILE:
			return board.is_valid_position(position) and not board.is_occupied(position)
		GameEnums.TargetRule.FRIENDLY_UNIT:
			var unit = board.get_unit_at(position)
			return unit != null and unit.faction == GameEnums.Faction.PLAYER
		GameEnums.TargetRule.ENEMY_UNIT:
			var unit = board.get_unit_at(position)
			return unit != null and unit.faction == GameEnums.Faction.ENEMY
		GameEnums.TargetRule.ANY_UNIT:
			return board.get_unit_at(position) != null
	return false

# 执行卡牌效果
func execute_effects(board: Node, target_position: Vector2i, caster = null) -> void:
	for effect in effects:
		var context = CardEffect.EffectContext.new(
			caster,
			target_position,
			board.get_unit_at(target_position),
			board
		)
		effect.execute(context)
