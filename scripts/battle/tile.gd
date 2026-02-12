# 棋盘格子
class_name Tile
extends Control

# 格子位置
var grid_position: Vector2i = Vector2i.ZERO

# 是否被占用
var is_occupied: bool = false

# 占用此格的单位
var occupying_unit: Node = null

# 格子状态颜色
const COLOR_NORMAL = Color(0.2, 0.2, 0.2, 1.0)
const COLOR_HOVER = Color(0.4, 0.4, 0.4, 1.0)
const COLOR_SELECTABLE = Color(0.3, 0.6, 0.3, 1.0)
const COLOR_INVALID = Color(0.6, 0.3, 0.3, 1.0)

# 是否可选择（用于卡牌目标）
var is_selectable: bool = false

# 背景节点引用
@onready var background: ColorRect = $Background

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	gui_input.connect(_on_gui_input)
	update_visual()

# 设置格子位置
func set_grid_position(pos: Vector2i) -> void:
	grid_position = pos

# 设置单位
func set_unit(unit: Node) -> void:
	occupying_unit = unit
	is_occupied = unit != null

# 设置可选择状态
func set_selectable(selectable: bool) -> void:
	is_selectable = selectable
	if selectable:
		print("[Tile] 格子 %s 设为可选择（占用: %s）" % [grid_position, is_occupied])
	update_visual()
	
	# 验证颜色是否设置成功
	if is_node_ready() and background:
		print("[Tile] 格子 %s 颜色已更新为: %s" % [grid_position, background.color])

# 更新视觉
func update_visual() -> void:
	if not is_node_ready() or not background:
		return
	
	if is_selectable:
		if is_occupied:
			background.color = COLOR_INVALID
		else:
			background.color = COLOR_SELECTABLE
	else:
		background.color = COLOR_NORMAL

func _on_mouse_entered() -> void:
	if not background:
		return
		
	if is_selectable:
		if not is_occupied:
			background.color = Color(0.4, 0.8, 0.4, 1.0)
	else:
		background.color = COLOR_HOVER
	EventBus.tile_hovered.emit(grid_position)

func _on_mouse_exited() -> void:
	update_visual()

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("[Tile] 格子 %s 被点击（占用: %s，可选择: %s）" % [grid_position, is_occupied, is_selectable])
			EventBus.tile_selected.emit(grid_position)
