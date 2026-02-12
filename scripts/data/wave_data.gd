# 敌人波次数据
class_name WaveData
extends Resource

# 生成的回合数
@export var spawn_turn: int = 1

# 生成的行（0-based，0表示第一行）
@export var lane: int = 0

# 生成的敌人单位ID列表
@export var enemy_unit_ids: Array[String] = []

# 生成位置偏移（从右侧边界开始，默认为最右列）
@export var spawn_column_offset: int = 0  # 0表示最右列，1表示倒数第二列，以此类推
