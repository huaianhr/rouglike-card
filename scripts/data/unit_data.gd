# 单位数据资源
class_name UnitData
extends Resource

# 基础信息
@export var id: String = ""
@export var display_name: String = "未命名单位"

# 阵营
@export var faction: GameEnums.Faction = GameEnums.Faction.PLAYER

# 等级（用于腐化降级，数字越大越高级）
@export var tier: int = 1

# 属性
@export var max_hp: int = 10
@export var attack: int = 5

# 攻击模式
@export var attack_pattern: GameEnums.AttackPattern = GameEnums.AttackPattern.MELEE

# 攻击范围（0=不攻击，1=近战，2+=远程）
@export var attack_range: int = 1

# 移动模式
@export var move_pattern: GameEnums.MovePattern = GameEnums.MovePattern.STATIC

# 腐化降级后的单位ID（如果为空则表示无法降级）
@export var degraded_unit_id: String = ""

# 图标路径（暂时用文字代替）
@export var icon_path: String = ""
