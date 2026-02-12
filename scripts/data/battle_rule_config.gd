# 战斗规则配置
class_name BattleRuleConfig
extends Resource

# 棋盘尺寸
@export_group("棋盘设置")
@export var board_rows: int = 3
@export var board_cols: int = 10

# AP（行动点）设置
@export_group("行动点设置")
@export var starting_ap: int = 5
@export var ap_per_turn: int = 3
@export var max_ap: int = 10

# 手牌设置
@export_group("手牌设置")
@export var starting_hand_size: int = 5
@export var max_hand_size: int = 10

# 战斗设置
@export_group("战斗设置")
@export var corrupt_threshold_turns: int = 3  # 腐化阈值（持续几回合）
@export var player_attacks_first: bool = true  # 玩家是否先手攻击

# 胜负条件
@export_group("胜负条件")
@export var defeat_column: int = 0  # 敌人到达第几列算失败
