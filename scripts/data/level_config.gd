# 关卡配置
class_name LevelConfig
extends Resource

# 基础信息
@export var level_id: String = ""
@export var display_name: String = "未命名关卡"
@export_multiline var description: String = ""
@export var chapter_id: int = 1  # 所属章节

# 战斗规则（引用）
@export var battle_rules: BattleRuleConfig

# 核心防御塔配置
@export var tower_config: TowerConfig

# 敌人波次列表
@export var enemy_waves: Array[WaveData] = []

# 奖励池
@export var reward_pool: RewardPoolData

# 胜利条件（暂时简化为清空所有波次）
@export var total_turns: int = 10  # 总回合数（如果到达此回合且无敌人则胜利）
