# 战斗棋盘
class_name Board
extends Control

# 棋盘尺寸
var rows: int = 3
var cols: int = 10

# 格子大小
const TILE_SIZE = 64
const TILE_SPACING = 2

# 场景引用
const TILE_SCENE = preload("res://scenes/battle/tile.tscn")
const UNIT_SCENE = preload("res://scenes/battle/unit.tscn")

# 格子数组 [row][col]
var tiles: Array = []

# 单位字典 {Vector2i: Unit}
var units: Dictionary = {}

# UI节点
@onready var grid_container: Control = $GridContainer
@onready var units_layer: Control = $UnitsLayer

func _ready() -> void:
	EventBus.level_started.connect(_on_level_started)

# 初始化棋盘
func initialize_board(battle_rules: BattleRuleConfig) -> void:
	rows = battle_rules.board_rows
	cols = battle_rules.board_cols
	create_grid()

# 创建格子网格
func create_grid() -> void:
	# 清空现有格子
	for child in grid_container.get_children():
		child.queue_free()
	tiles.clear()
	
	# 创建新格子
	for row in rows:
		var row_array = []
		for col in cols:
			var tile = TILE_SCENE.instantiate()
			grid_container.add_child(tile)
			tile.set_grid_position(Vector2i(col, row))
			tile.position = Vector2(col * (TILE_SIZE + TILE_SPACING), row * (TILE_SIZE + TILE_SPACING))
			row_array.append(tile)
		tiles.append(row_array)
	
	# 设置GridContainer大小
	grid_container.custom_minimum_size = Vector2(
		cols * (TILE_SIZE + TILE_SPACING) - TILE_SPACING,
		rows * (TILE_SIZE + TILE_SPACING) - TILE_SPACING
	)

# 检查位置是否合法
func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < cols and pos.y >= 0 and pos.y < rows

# 检查格子是否被占用
func is_occupied(pos: Vector2i) -> bool:
	return units.has(pos)

# 获取指定位置的单位
func get_unit_at(pos: Vector2i) -> Unit:
	return units.get(pos, null)

# 生成单位
func spawn_unit(unit_data: UnitData, pos: Vector2i) -> Unit:
	if not is_valid_position(pos):
		push_warning("尝试在无效位置生成单位: %s" % pos)
		return null
	
	if is_occupied(pos):
		push_warning("尝试在已占用位置生成单位: %s" % pos)
		return null
	
	# 创建单位
	var unit = UNIT_SCENE.instantiate()
	units_layer.add_child(unit)
	unit.initialize(unit_data, pos)
	
	# 定位单位
	update_unit_position(unit, pos)
	
	# 注册单位
	units[pos] = unit
	if is_valid_position(pos):
		tiles[pos.y][pos.x].set_unit(unit)
	
	EventBus.unit_spawned.emit(unit, pos)
	return unit

# 更新单位位置（视觉）
func update_unit_position(unit: Unit, pos: Vector2i) -> void:
	if is_valid_position(pos):
		unit.position = Vector2(
			pos.x * (TILE_SIZE + TILE_SPACING) + 2,
			pos.y * (TILE_SIZE + TILE_SPACING) + 2
		)

# 移动单位
func move_unit(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	if not is_valid_position(from_pos) or not is_valid_position(to_pos):
		return false
	
	if not is_occupied(from_pos) or is_occupied(to_pos):
		return false
	
	var unit = units[from_pos]
	units.erase(from_pos)
	units[to_pos] = unit
	
	tiles[from_pos.y][from_pos.x].set_unit(null)
	tiles[to_pos.y][to_pos.x].set_unit(unit)
	
	unit.grid_position = to_pos
	update_unit_position(unit, to_pos)
	
	EventBus.unit_moved.emit(unit, from_pos, to_pos)
	return true

# 移除单位
func remove_unit(pos: Vector2i) -> void:
	if is_occupied(pos):
		var unit = units[pos]
		units.erase(pos)
		if is_valid_position(pos):
			tiles[pos.y][pos.x].set_unit(null)
		unit.queue_free()

# 获取所有单位
func get_all_units() -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units.values():
		result.append(unit)
	return result

# 获取指定阵营的所有单位
func get_units_by_faction(faction: GameEnums.Faction) -> Array[Unit]:
	var result: Array[Unit] = []
	for unit in units.values():
		if unit.faction == faction:
			result.append(unit)
	return result

# 设置格子可选择状态（用于卡牌目标）
func set_tiles_selectable(positions: Array[Vector2i]) -> void:
	print("[Board] 设置可选择格子，数量: %d" % positions.size())
	
	# 先清除所有选择状态
	for row in tiles:
		for tile in row:
			tile.set_selectable(false)
	
	# 设置指定格子为可选择
	for pos in positions:
		if is_valid_position(pos):
			print("[Board] 设置格子 %s 为可选择" % pos)
			tiles[pos.y][pos.x].set_selectable(true)

# 清除所有格子选择状态
func clear_tile_selection() -> void:
	for row in tiles:
		for tile in row:
			tile.set_selectable(false)

func _on_level_started(level_config: Resource) -> void:
	initialize_board(level_config.battle_rules)
