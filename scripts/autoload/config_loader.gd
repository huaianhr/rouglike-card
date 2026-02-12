# 配置加载器
# 负责加载并缓存所有游戏配置资源
extends Node

# 配置缓存
var battle_rules: Resource  # BattleRuleConfig
var levels: Dictionary = {}  # level_id -> LevelConfig
var cards: Dictionary = {}  # card_id -> CardData
var units: Dictionary = {}  # unit_id -> UnitData

# 配置文件路径
const RULES_PATH = "res://resources/configs/default_rules.tres"
const LEVELS_DIR = "res://resources/configs/levels/"
const CARDS_DIR = "res://resources/cards/"
const UNITS_DIR = "res://resources/units/"

func _ready() -> void:
	load_all_configs()

# 加载所有配置
func load_all_configs() -> void:
	load_battle_rules()
	load_cards()
	load_units()
	load_levels()

# 加载战斗规则
func load_battle_rules() -> void:
	if ResourceLoader.exists(RULES_PATH):
		battle_rules = load(RULES_PATH)
		print("[ConfigLoader] 已加载战斗规则配置")
	else:
		push_warning("[ConfigLoader] 未找到战斗规则配置: %s" % RULES_PATH)

# 加载所有卡牌
func load_cards() -> void:
	var dir = DirAccess.open(CARDS_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var card_path = CARDS_DIR + file_name
				var card = load(card_path)
				if card and "id" in card and card.id != "":
					cards[card.id] = card
					print("[ConfigLoader] 已加载卡牌: %s" % card.id)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_warning("[ConfigLoader] 无法打开卡牌目录: %s" % CARDS_DIR)

# 加载所有单位
func load_units() -> void:
	var dir = DirAccess.open(UNITS_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var unit_path = UNITS_DIR + file_name
				var unit = load(unit_path)
				if unit and "id" in unit and unit.id != "":
					units[unit.id] = unit
					print("[ConfigLoader] 已加载单位: %s" % unit.id)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_warning("[ConfigLoader] 无法打开单位目录: %s" % UNITS_DIR)

# 加载所有关卡
func load_levels() -> void:
	var dir = DirAccess.open(LEVELS_DIR)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var level_path = LEVELS_DIR + file_name
				var level = load(level_path)
				if level and "level_id" in level and level.level_id != "":
					levels[level.level_id] = level
					print("[ConfigLoader] 已加载关卡: %s" % level.level_id)
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		push_warning("[ConfigLoader] 无法打开关卡目录: %s" % LEVELS_DIR)

# 获取卡牌
func get_card(card_id: String) -> Resource:
	if cards.has(card_id):
		return cards[card_id]
	push_warning("[ConfigLoader] 未找到卡牌: %s" % card_id)
	return null

# 获取单位
func get_unit(unit_id: String) -> Resource:
	if units.has(unit_id):
		return units[unit_id]
	push_warning("[ConfigLoader] 未找到单位: %s" % unit_id)
	return null

# 获取关卡
func get_level(level_id: String) -> Resource:
	if levels.has(level_id):
		return levels[level_id]
	push_warning("[ConfigLoader] 未找到关卡: %s" % level_id)
	return null
