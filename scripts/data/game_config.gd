# 游戏全局配置
# 存储游戏级别的初始配置，如初始卡组、初始行动点等
class_name GameConfig
extends Resource

# 初始卡组配置
@export var initial_deck_ids: Array[String] = []
