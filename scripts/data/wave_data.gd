# 敌人波次数据
class_name WaveData
extends Resource

# 生成的回合数
@export var spawn_turn: int = 1

# 生成的行（0-based，0表示第一行）
@export var lane: int = 0

# 生成的敌人单位ID列表（允许重复ID，支持同类型多个敌人）
@export var enemy_unit_ids: Array[String] = []

# 每个敌人的列偏移（与enemy_unit_ids一一对应，0表示最右列）
@export var enemy_offsets: Array[int] = []

# [已废弃] 旧版全局偏移，保留用于兼容性
@export var spawn_column_offset: int = 0
