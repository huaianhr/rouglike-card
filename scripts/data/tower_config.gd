# 核心防御塔配置
# 定义塔的基础属性和攻击模式
class_name TowerConfig
extends Resource

@export var tower_id: String = ""
@export var display_name: String = "核心防御塔"
@export var max_hp: int = 80
@export var attack: int = 100
@export var attack_interval: int = 5  # 每N回合攻击一次
@export var attack_pattern: String = "single_lane"  # 攻击模式：single_lane, all_lanes等
