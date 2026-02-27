@tool
extends Control

# UI节点引用
var tab_container: TabContainer
var save_button: Button
var refresh_button: Button
var status_label: Label

# 数据
var all_cards: Array[Dictionary] = []
var all_units: Array[Dictionary] = []
var all_towers: Array[Dictionary] = []
var all_levels: Array[Dictionary] = []
var game_config_data: Dictionary = {}

# 表格
var card_table: Tree
var selected_card_data: Dictionary = {}
var unit_table: Tree
var selected_unit_data: Dictionary = {}
var tower_table: Tree
var selected_tower_data: Dictionary = {}
var level_table: Tree
var selected_level_data: Dictionary = {}
var wave_table: Tree
var selected_wave_data: Dictionary = {}
var current_level_for_waves: Dictionary = {}
var wave_detail_panel: VBoxContainer
var enemy_instances_ui: Dictionary = {}  # 存储每个敌人类型的UI容器 {unit_id: VBoxContainer}

func _ready():
	print("[配置管理器] _ready() 开始")
	
	# 获取UI节点
	tab_container = $VBox/ScrollContainer/TabContainer
	save_button = $VBox/TopBar/SaveButton
	refresh_button = $VBox/TopBar/RefreshButton
	status_label = $VBox/StatusBar/StatusLabel
	
	print("[配置管理器] 节点获取完成")
	
	# 连接信号
	save_button.pressed.connect(_on_save_pressed)
	refresh_button.pressed.connect(_on_refresh_pressed)
	
	# 创建页签
	create_card_tab()
	create_unit_tab()
	create_tower_tab()
	create_level_tab()
	create_wave_tab()
	create_global_tab()
	
	# 加载数据
	load_all_configs()
	
	print("[配置管理器] 初始化完成")

func create_card_tab():
	print("[配置管理器] 创建卡牌页签")
	
	var card_tab = VBoxContainer.new()
	card_tab.name = "CardTab"
	
	# 工具栏
	var toolbar = HBoxContainer.new()
	var add_btn = Button.new()
	add_btn.text = "+ 新增"
	add_btn.pressed.connect(_on_add_card)
	toolbar.add_child(add_btn)
	
	var del_btn = Button.new()
	del_btn.text = "- 删除"
	del_btn.pressed.connect(_on_delete_card)
	toolbar.add_child(del_btn)
	
	card_tab.add_child(toolbar)
	
	# 表格
	card_table = Tree.new()
	card_table.columns = 6
	card_table.set_column_title(0, "ID")
	card_table.set_column_title(1, "名称")
	card_table.set_column_title(2, "类型")
	card_table.set_column_title(3, "费用")
	card_table.set_column_title(4, "单位ID")
	card_table.set_column_title(5, "描述")
	card_table.column_titles_visible = true
	card_table.hide_root = true
	card_table.custom_minimum_size = Vector2(0, 400)
	card_table.item_selected.connect(_on_card_selected)
	card_table.item_edited.connect(_on_card_edited)
	card_tab.add_child(card_table)
	
	tab_container.add_child(card_tab)
	tab_container.set_tab_title(0, "卡牌配置")

func create_unit_tab():
	print("[配置管理器] 创建单位页签")
	
	var unit_tab = VBoxContainer.new()
	unit_tab.name = "UnitTab"
	
	# 工具栏
	var toolbar = HBoxContainer.new()
	var add_btn = Button.new()
	add_btn.text = "+ 新增"
	add_btn.pressed.connect(_on_add_unit)
	toolbar.add_child(add_btn)
	
	var del_btn = Button.new()
	del_btn.text = "- 删除"
	del_btn.pressed.connect(_on_delete_unit)
	toolbar.add_child(del_btn)
	
	unit_tab.add_child(toolbar)
	
	# 表格
	unit_table = Tree.new()
	unit_table.columns = 6
	unit_table.set_column_title(0, "ID")
	unit_table.set_column_title(1, "名称")
	unit_table.set_column_title(2, "阵营")
	unit_table.set_column_title(3, "HP")
	unit_table.set_column_title(4, "攻击")
	unit_table.set_column_title(5, "移动")
	unit_table.column_titles_visible = true
	unit_table.hide_root = true
	unit_table.custom_minimum_size = Vector2(0, 400)
	unit_table.item_selected.connect(_on_unit_selected)
	unit_table.item_edited.connect(_on_unit_edited)
	unit_tab.add_child(unit_table)
	
	tab_container.add_child(unit_tab)
	tab_container.set_tab_title(1, "单位配置")

func create_tower_tab():
	print("[配置管理器] 创建防御塔页签")
	
	var tower_tab = VBoxContainer.new()
	tower_tab.name = "TowerTab"
	
	# 工具栏
	var toolbar = HBoxContainer.new()
	var add_btn = Button.new()
	add_btn.text = "+ 新增"
	add_btn.pressed.connect(_on_add_tower)
	toolbar.add_child(add_btn)
	
	var del_btn = Button.new()
	del_btn.text = "- 删除"
	del_btn.pressed.connect(_on_delete_tower)
	toolbar.add_child(del_btn)
	
	tower_tab.add_child(toolbar)
	
	# 表格
	tower_table = Tree.new()
	tower_table.columns = 5
	tower_table.set_column_title(0, "ID")
	tower_table.set_column_title(1, "名称")
	tower_table.set_column_title(2, "HP")
	tower_table.set_column_title(3, "攻击")
	tower_table.set_column_title(4, "攻击间隔")
	tower_table.column_titles_visible = true
	tower_table.hide_root = true
	tower_table.custom_minimum_size = Vector2(0, 400)
	tower_table.item_selected.connect(_on_tower_selected)
	tower_table.item_edited.connect(_on_tower_edited)
	tower_tab.add_child(tower_table)
	
	tab_container.add_child(tower_tab)
	tab_container.set_tab_title(2, "防御塔配置")

func create_level_tab():
	print("[配置管理器] 创建关卡页签")
	
	var level_tab = VBoxContainer.new()
	level_tab.name = "LevelTab"
	
	# 工具栏
	var toolbar = HBoxContainer.new()
	var refresh_btn = Button.new()
	refresh_btn.text = "刷新"
	refresh_btn.pressed.connect(_on_refresh_levels)
	toolbar.add_child(refresh_btn)
	
	var hint = Label.new()
	hint.text = "提示：关卡配置较复杂，建议在Godot编辑器中直接编辑.tres文件"
	hint.add_theme_color_override("font_color", Color(1, 0.7, 0))
	toolbar.add_child(hint)
	
	level_tab.add_child(toolbar)
	
	# 表格
	level_table = Tree.new()
	level_table.columns = 5
	level_table.set_column_title(0, "ID")
	level_table.set_column_title(1, "名称")
	level_table.set_column_title(2, "章节ID")
	level_table.set_column_title(3, "波次数")
	level_table.set_column_title(4, "描述")
	level_table.column_titles_visible = true
	level_table.hide_root = true
	level_table.custom_minimum_size = Vector2(0, 400)
	level_table.item_selected.connect(_on_level_selected)
	level_tab.add_child(level_table)
	
	tab_container.add_child(level_tab)
	tab_container.set_tab_title(3, "关卡配置")

func create_wave_tab():
	print("[配置管理器] 创建波次配置页签")
	
	var wave_tab = VBoxContainer.new()
	wave_tab.name = "WaveTab"
	
	# 顶部工具栏
	var top_bar = HBoxContainer.new()
	top_bar.name = "TopBar"
	
	var level_label = Label.new()
	level_label.text = "选择关卡:"
	top_bar.add_child(level_label)
	
	var level_option = OptionButton.new()
	level_option.name = "LevelOption"
	level_option.custom_minimum_size = Vector2(300, 0)
	level_option.item_selected.connect(_on_wave_level_changed)
	top_bar.add_child(level_option)
	
	var refresh_btn = Button.new()
	refresh_btn.text = "刷新"
	refresh_btn.pressed.connect(_on_refresh_waves)
	top_bar.add_child(refresh_btn)
	
	var save_btn = Button.new()
	save_btn.text = "保存波次"
	save_btn.pressed.connect(_on_save_waves)
	top_bar.add_child(save_btn)
	
	wave_tab.add_child(top_bar)
	
	# 波次列表标题栏
	var list_bar = HBoxContainer.new()
	var list_title = Label.new()
	list_title.text = "波次列表"
	list_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	list_bar.add_child(list_title)
	
	var add_wave_btn = Button.new()
	add_wave_btn.text = "+ 新增"
	add_wave_btn.pressed.connect(_on_add_wave)
	list_bar.add_child(add_wave_btn)
	
	var del_wave_btn = Button.new()
	del_wave_btn.text = "- 删除"
	del_wave_btn.pressed.connect(_on_delete_wave)
	list_bar.add_child(del_wave_btn)
	
	wave_tab.add_child(list_bar)
	
	# 波次表格
	wave_table = Tree.new()
	wave_table.columns = 5
	wave_table.set_column_title(0, "回合")
	wave_table.set_column_title(1, "行")
	wave_table.set_column_title(2, "敌人数量")
	wave_table.set_column_title(3, "敌人列表")
	wave_table.set_column_title(4, "列偏移")
	wave_table.column_titles_visible = true
	wave_table.hide_root = true
	wave_table.custom_minimum_size = Vector2(0, 250)
	wave_table.item_selected.connect(_on_wave_selected)
	wave_tab.add_child(wave_table)
	
	# 分隔线
	var separator = HSeparator.new()
	wave_tab.add_child(separator)
	
	# 详情编辑区
	var detail_title = Label.new()
	detail_title.text = "选中波次详情编辑："
	detail_title.add_theme_font_size_override("font_size", 14)
	wave_tab.add_child(detail_title)
	
	wave_detail_panel = VBoxContainer.new()
	wave_detail_panel.name = "WaveDetailPanel"
	
	# 回合和行号
	var basic_row = HBoxContainer.new()
	basic_row.name = "BasicRow"
	
	var turn_label = Label.new()
	turn_label.text = "生成回合:"
	turn_label.custom_minimum_size = Vector2(80, 0)
	basic_row.add_child(turn_label)
	
	var turn_spin = SpinBox.new()
	turn_spin.name = "TurnSpin"
	turn_spin.min_value = 1
	turn_spin.max_value = 99
	turn_spin.value_changed.connect(_on_wave_turn_changed)
	basic_row.add_child(turn_spin)
	
	var lane_label = Label.new()
	lane_label.text = "生成行号:"
	lane_label.custom_minimum_size = Vector2(80, 0)
	basic_row.add_child(lane_label)
	
	var lane_option = OptionButton.new()
	lane_option.name = "LaneOption"
	lane_option.add_item("0", 0)
	lane_option.add_item("1", 1)
	lane_option.add_item("2", 2)
	lane_option.item_selected.connect(_on_wave_lane_changed)
	basic_row.add_child(lane_option)
	
	wave_detail_panel.add_child(basic_row)
	
	# 敌人单位列表标题
	var enemy_title = Label.new()
	enemy_title.text = "敌人单位列表 (勾选要生成的敌人):"
	enemy_title.add_theme_font_size_override("font_size", 12)
	wave_detail_panel.add_child(enemy_title)
	
	# 敌人列表容器（动态创建CheckBox）
	var enemy_container = VBoxContainer.new()
	enemy_container.name = "EnemyContainer"
	wave_detail_panel.add_child(enemy_container)
	
	# 提示
	var hint = Label.new()
	hint.text = "提示: 列偏移自动计算，第1个敌人=0(最右列)，第2个=1，第3个=2..."
	hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	hint.add_theme_font_size_override("font_size", 11)
	wave_detail_panel.add_child(hint)
	
	wave_tab.add_child(wave_detail_panel)
	
	tab_container.add_child(wave_tab)
	tab_container.set_tab_title(4, "关卡波次配置")

func create_global_tab():
	print("[配置管理器] 创建全局配置页签")
	
	var global_tab = VBoxContainer.new()
	global_tab.name = "GlobalTab"
	
	# 标题
	var title = Label.new()
	title.text = "全局配置 - 初始牌组"
	title.add_theme_font_size_override("font_size", 16)
	global_tab.add_child(title)
	
	# 说明
	var hint = Label.new()
	hint.text = "格式：每行一个卡牌ID，支持重复"
	hint.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	global_tab.add_child(hint)
	
	# 文本编辑框
	var text_edit = TextEdit.new()
	text_edit.name = "InitialDeckEdit"
	text_edit.custom_minimum_size = Vector2(0, 400)
	text_edit.placeholder_text = "summon_knight\nsummon_mage\npower_up\n..."
	global_tab.add_child(text_edit)
	
	# 保存按钮
	var save_btn = Button.new()
	save_btn.text = "保存全局配置"
	save_btn.pressed.connect(_on_save_global_config)
	global_tab.add_child(save_btn)
	
	tab_container.add_child(global_tab)
	tab_container.set_tab_title(5, "初始卡牌配置")

func load_all_configs():
	print("[配置管理器] 加载配置")
	# 先加载单位，再加载卡牌（因为卡牌需要引用单位）
	load_units()
	load_cards()
	load_towers()
	load_levels()
	load_global_config()
	populate_wave_level_options()
	update_status("已加载 %d 张卡牌, %d 个单位, %d 个防御塔, %d 个关卡" % [all_cards.size(), all_units.size(), all_towers.size(), all_levels.size()])

func load_cards():
	all_cards.clear()
	var dir = DirAccess.open("res://resources/cards/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var res = load("res://resources/cards/" + file_name)
				if res:
					var card_dict = {
						"resource": res,
						"path": "res://resources/cards/" + file_name,
						"id": res.id,
						"display_name": res.display_name,
						"card_type": res.card_type,
						"cost": res.cost,
						"description": res.description,
						"unit_id": ""  # 单位ID（UNIT类型卡牌）
					}
					
					# 提取UNIT卡牌的单位ID
					if res.card_type == 0 and res.effects and res.effects.size() > 0:
						var effect = res.effects[0]
						if effect and effect.get("unit_template_id") != null:
							card_dict.unit_id = effect.unit_template_id
					
					all_cards.append(card_dict)
			file_name = dir.get_next()
		dir.list_dir_end()
	refresh_card_table()

func load_units():
	all_units.clear()
	var dir = DirAccess.open("res://resources/units/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var res = load("res://resources/units/" + file_name)
				if res:
					all_units.append({
						"resource": res,
						"path": "res://resources/units/" + file_name,
						"id": res.id,
						"display_name": res.display_name,
						"faction": res.faction,
						"max_hp": res.max_hp,
						"attack": res.attack,
						"move_pattern": res.move_pattern
					})
			file_name = dir.get_next()
		dir.list_dir_end()
	refresh_unit_table()

func load_towers():
	all_towers.clear()
	var dir = DirAccess.open("res://resources/towers/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var res = load("res://resources/towers/" + file_name)
				if res:
					all_towers.append({
						"resource": res,
						"path": "res://resources/towers/" + file_name,
						"tower_id": res.tower_id,
						"display_name": res.display_name,
						"max_hp": res.max_hp,
						"attack": res.attack,
						"attack_interval": res.attack_interval
					})
			file_name = dir.get_next()
		dir.list_dir_end()
	refresh_tower_table()

func load_levels():
	all_levels.clear()
	var dir = DirAccess.open("res://resources/configs/levels/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var res = load("res://resources/configs/levels/" + file_name)
				if res:
					all_levels.append({
						"resource": res,
						"path": "res://resources/configs/levels/" + file_name,
						"level_id": res.level_id,
						"display_name": res.display_name,
						"chapter_id": res.chapter_id,
						"wave_count": res.enemy_waves.size() if res.enemy_waves else 0,
						"description": res.description
					})
			file_name = dir.get_next()
		dir.list_dir_end()
	refresh_level_table()

func load_global_config():
	var res = load("res://resources/configs/game_config.tres")
	if res:
		game_config_data = {
			"resource": res,
			"path": "res://resources/configs/game_config.tres",
			"initial_deck_ids": res.initial_deck_ids.duplicate()
		}
		refresh_global_config()

func refresh_card_table():
	card_table.clear()
	var root = card_table.create_item()
	
	for card in all_cards:
		var item = card_table.create_item(root)
		item.set_text(0, card.id)
		item.set_text(1, card.display_name)
		item.set_text(2, get_card_type_name(card.card_type))
		item.set_text(3, str(card.cost))
		item.set_text(4, card.unit_id if card.card_type == 0 else "-")
		item.set_text(5, card.description.substr(0, 30))
		
		# 可编辑
		item.set_editable(0, true)
		item.set_editable(1, true)
		item.set_editable(3, true)
		item.set_editable(5, true)
		
		# 类型列设置为下拉选择
		item.set_cell_mode(2, TreeItem.CELL_MODE_RANGE)
		item.set_text(2, "UNIT,SPELL,BUFF")
		item.set_range(2, card.card_type)
		item.set_editable(2, true)
		
		# 单位ID列 - 仅UNIT类型可编辑，下拉选择
		if card.card_type == 0:  # UNIT类型
			item.set_cell_mode(4, TreeItem.CELL_MODE_RANGE)
			# 构建单位列表（仅PLAYER阵营）
			var unit_options = []
			var unit_ids = []
			var selected_index = 0
			var index = 0
			for unit in all_units:
				# 只显示PLAYER阵营的单位
				if unit.faction == 0:  # 0 = PLAYER
					unit_options.append(unit.display_name + " (" + unit.id + ")")
					unit_ids.append(unit.id)
					if unit.id == card.unit_id:
						selected_index = index
					index += 1
			
			if unit_options.size() > 0:
				item.set_text(4, ",".join(unit_options))
				item.set_range(4, selected_index)
				item.set_editable(4, true)
				# 保存unit_ids映射到metadata
				item.set_metadata(4, unit_ids)
			else:
				# 没有可用的PLAYER单位时显示提示
				item.set_text(4, "无可用单位")
				item.set_editable(4, false)
		else:
			item.set_editable(4, false)
		
		item.set_metadata(0, card)

func refresh_unit_table():
	unit_table.clear()
	var root = unit_table.create_item()
	
	for unit in all_units:
		var item = unit_table.create_item(root)
		item.set_text(0, unit.id)
		item.set_text(1, unit.display_name)
		item.set_text(2, "PLAYER" if unit.faction == 0 else "ENEMY")
		item.set_text(3, str(unit.max_hp))
		item.set_text(4, str(unit.attack))
		item.set_text(5, get_move_pattern_name(unit.move_pattern))
		
		# 可编辑
		item.set_editable(0, true)
		item.set_editable(1, true)
		item.set_editable(3, true)
		item.set_editable(4, true)
		
		# 阵营列设置为下拉选择
		item.set_cell_mode(2, TreeItem.CELL_MODE_RANGE)
		item.set_text(2, "PLAYER,ENEMY")
		item.set_range(2, unit.faction)
		item.set_editable(2, true)
		
		# 移动模式列设置为下拉选择
		item.set_cell_mode(5, TreeItem.CELL_MODE_RANGE)
		item.set_text(5, "STATIC,FORWARD,CUSTOM")
		item.set_range(5, unit.move_pattern)
		item.set_editable(5, true)
		
		item.set_metadata(0, unit)

func get_card_type_name(type: int) -> String:
	match type:
		0: return "UNIT"
		1: return "SPELL"
		2: return "BUFF"
	return "?"

func get_move_pattern_name(pattern: int) -> String:
	match pattern:
		0: return "STATIC"
		1: return "FORWARD"
		2: return "CUSTOM"
	return "?"

func refresh_tower_table():
	tower_table.clear()
	var root = tower_table.create_item()
	
	for tower in all_towers:
		var item = tower_table.create_item(root)
		item.set_text(0, tower.tower_id)
		item.set_text(1, tower.display_name)
		item.set_text(2, str(tower.max_hp))
		item.set_text(3, str(tower.attack))
		item.set_text(4, str(tower.attack_interval))
		
		# 可编辑
		item.set_editable(0, true)
		item.set_editable(1, true)
		item.set_editable(2, true)
		item.set_editable(3, true)
		item.set_editable(4, true)
		
		item.set_metadata(0, tower)

func refresh_level_table():
	level_table.clear()
	var root = level_table.create_item()
	
	for level in all_levels:
		var item = level_table.create_item(root)
		item.set_text(0, level.level_id)
		item.set_text(1, level.display_name)
		item.set_text(2, str(level.chapter_id))
		item.set_text(3, str(level.wave_count))
		item.set_text(4, level.description.substr(0, 40))
		
		item.set_metadata(0, level)

func refresh_global_config():
	if game_config_data.is_empty():
		return
	
	var text_edit = tab_container.get_node_or_null("GlobalTab/InitialDeckEdit")
	if text_edit:
		var deck_text = "\n".join(game_config_data.initial_deck_ids)
		text_edit.text = deck_text

func _on_card_selected():
	var sel = card_table.get_selected()
	if sel:
		selected_card_data = sel.get_metadata(0)

func _on_card_edited():
	var item = card_table.get_edited()
	if not item:
		return
	var card = item.get_metadata(0)
	var col = card_table.get_edited_column()
	
	match col:
		0: 
			card.id = item.get_text(0)
			update_status("已修改ID: " + card.id)
		1: 
			card.display_name = item.get_text(1)
			update_status("已修改名称: " + card.display_name)
		2:
			card.card_type = int(item.get_range(2))
			update_status("已修改类型: " + get_card_type_name(card.card_type))
			# 类型改变后刷新表格（更新单位ID列的可编辑状态）
			refresh_card_table()
		3: 
			var val = item.get_text(3)
			if val.is_valid_int():
				card.cost = int(val)
				update_status("已修改费用: " + str(card.cost))
		4:
			# 单位ID列
			if card.card_type == 0:  # UNIT类型
				var unit_ids = item.get_metadata(4)
				if unit_ids and unit_ids is Array:
					var selected_index = int(item.get_range(4))
					if selected_index >= 0 and selected_index < unit_ids.size():
						card.unit_id = unit_ids[selected_index]
						update_status("已修改单位ID: " + card.unit_id)
		5: 
			card.description = item.get_text(5)
			update_status("已修改描述")

func _on_unit_selected():
	var sel = unit_table.get_selected()
	if sel:
		selected_unit_data = sel.get_metadata(0)

func _on_unit_edited():
	var item = unit_table.get_edited()
	if not item:
		return
	var unit = item.get_metadata(0)
	var col = unit_table.get_edited_column()
	
	match col:
		0: 
			unit.id = item.get_text(0)
			update_status("已修改ID: " + unit.id)
		1: 
			unit.display_name = item.get_text(1)
			update_status("已修改名称: " + unit.display_name)
		2: 
			unit.faction = int(item.get_range(2))
			update_status("已修改阵营: " + ("PLAYER" if unit.faction == 0 else "ENEMY"))
		3:
			var val = item.get_text(3)
			if val.is_valid_int():
				unit.max_hp = int(val)
				update_status("已修改HP: " + str(unit.max_hp))
		4:
			var val = item.get_text(4)
			if val.is_valid_int():
				unit.attack = int(val)
				update_status("已修改攻击: " + str(unit.attack))
		5:
			unit.move_pattern = int(item.get_range(5))
			update_status("已修改移动模式: " + get_move_pattern_name(unit.move_pattern))

func _on_add_card():
	var new_card = {
		"resource": null,
		"path": "",
		"id": "new_card",
		"display_name": "新卡牌",
		"card_type": 0,
		"cost": 1,
		"unit_id": "",
		"description": ""
	}
	all_cards.append(new_card)
	refresh_card_table()
	update_status("已添加新卡牌，请设置单位ID后保存")

func _on_delete_card():
	if not selected_card_data.is_empty():
		all_cards.erase(selected_card_data)
		selected_card_data = {}
		refresh_card_table()

func _on_add_unit():
	var new_unit = {
		"resource": null,
		"path": "",
		"id": "new_unit",
		"display_name": "新单位",
		"faction": 0,
		"max_hp": 10,
		"attack": 5,
		"move_pattern": 0
	}
	all_units.append(new_unit)
	refresh_unit_table()

func _on_delete_unit():
	if not selected_unit_data.is_empty():
		all_units.erase(selected_unit_data)
		selected_unit_data = {}
		refresh_unit_table()

func _on_tower_selected():
	var sel = tower_table.get_selected()
	if sel:
		selected_tower_data = sel.get_metadata(0)

func _on_tower_edited():
	var item = tower_table.get_edited()
	if not item:
		return
	var tower = item.get_metadata(0)
	var col = tower_table.get_edited_column()
	
	match col:
		0: 
			tower.tower_id = item.get_text(0)
			update_status("已修改ID: " + tower.tower_id)
		1: 
			tower.display_name = item.get_text(1)
			update_status("已修改名称: " + tower.display_name)
		2:
			var val = item.get_text(2)
			if val.is_valid_int():
				tower.max_hp = int(val)
				update_status("已修改HP: " + str(tower.max_hp))
		3:
			var val = item.get_text(3)
			if val.is_valid_int():
				tower.attack = int(val)
				update_status("已修改攻击: " + str(tower.attack))
		4:
			var val = item.get_text(4)
			if val.is_valid_int():
				tower.attack_interval = int(val)
				update_status("已修改攻击间隔: " + str(tower.attack_interval))

func _on_add_tower():
	var new_tower = {
		"resource": null,
		"path": "",
		"tower_id": "new_tower",
		"display_name": "新防御塔",
		"max_hp": 80,
		"attack": 100,
		"attack_interval": 5
	}
	all_towers.append(new_tower)
	refresh_tower_table()

func _on_delete_tower():
	if not selected_tower_data.is_empty():
		all_towers.erase(selected_tower_data)
		selected_tower_data = {}
		refresh_tower_table()

func _on_level_selected():
	var sel = level_table.get_selected()
	if sel:
		selected_level_data = sel.get_metadata(0)

func _on_refresh_levels():
	load_levels()
	update_status("已刷新关卡配置")

func _on_save_global_config():
	if game_config_data.is_empty():
		return
	
	var text_edit = tab_container.get_node_or_null("GlobalTab/InitialDeckEdit")
	if not text_edit:
		return
	
	# 解析文本
	var lines = text_edit.text.split("\n")
	var deck_ids = []
	for line in lines:
		var trimmed = line.strip_edges()
		if trimmed != "":
			deck_ids.append(trimmed)
	
	# 保存到资源
	var res: GameConfig
	if game_config_data.resource:
		res = game_config_data.resource
	else:
		res = GameConfig.new()
	
	res.initial_deck_ids = deck_ids
	
	if ResourceSaver.save(res, game_config_data.path) == OK:
		update_status("已保存全局配置，共 %d 张初始卡牌" % deck_ids.size())
		load_global_config()
	else:
		update_status("保存失败！")

func _on_save_pressed():
	var saved = 0
	
	# 保存卡牌
	for card in all_cards:
		var res: CardData
		if card.resource:
			res = card.resource
		else:
			res = CardData.new()
		
		res.id = card.id
		res.display_name = card.display_name
		res.card_type = card.card_type
		res.cost = card.cost
		res.description = card.description
		
		# 处理Effect（全量刷新）
		if card.card_type == 0:  # UNIT类型
			res.effects.clear()
			if card.unit_id != "":
				# 加载SpawnUnitEffect脚本
				var effect_script = load("res://scripts/data/effects/spawn_unit_effect.gd")
				if effect_script:
					var effect = effect_script.new()
					effect.unit_template_id = card.unit_id
					res.effects.append(effect)
		
		var path = card.path if card.path != "" else "res://resources/cards/" + card.id + ".tres"
		if ResourceSaver.save(res, path) == OK:
			saved += 1
	
	# 保存单位
	for unit in all_units:
		var res: UnitData
		if unit.resource:
			res = unit.resource
		else:
			res = UnitData.new()
		
		res.id = unit.id
		res.display_name = unit.display_name
		res.faction = unit.faction
		res.max_hp = unit.max_hp
		res.attack = unit.attack
		res.move_pattern = unit.move_pattern
		
		var path = unit.path if unit.path != "" else "res://resources/units/" + unit.id + ".tres"
		if ResourceSaver.save(res, path) == OK:
			saved += 1
	
	# 保存防御塔
	for tower in all_towers:
		var res: TowerConfig
		if tower.resource:
			res = tower.resource
		else:
			res = TowerConfig.new()
		
		res.tower_id = tower.tower_id
		res.display_name = tower.display_name
		res.max_hp = tower.max_hp
		res.attack = tower.attack
		res.attack_interval = tower.attack_interval
		
		var path = tower.path if tower.path != "" else "res://resources/towers/" + tower.tower_id + ".tres"
		if ResourceSaver.save(res, path) == OK:
			saved += 1
	
	# 保存波次（如果当前有选中的关卡）
	var wave_saved = false
	var current_wave_level_index = -1
	if not current_level_for_waves.is_empty():
		current_wave_level_index = get_current_wave_level_index()
		if save_waves_internal():
			saved += 1
			wave_saved = true
	
	update_status("已保存 %d 项配置%s" % [saved, " (含波次)" if wave_saved else ""])
	
	# 重新加载
	load_cards()
	load_units()
	load_towers()
	load_levels()
	load_global_config()
	
	# 恢复波次页签的选中状态
	populate_wave_level_options()
	if current_wave_level_index >= 0:
		var level_option = tab_container.get_node_or_null("WaveTab/TopBar/LevelOption")
		if level_option and current_wave_level_index < level_option.item_count:
			level_option.selected = current_wave_level_index
			load_waves_for_level(current_wave_level_index)

func _on_refresh_pressed():
	load_all_configs()

func populate_wave_level_options():
	var wave_tab = tab_container.get_node_or_null("WaveTab")
	if not wave_tab:
		return
	
	var level_option = wave_tab.get_node_or_null("TopBar/LevelOption")
	if not level_option:
		return
	
	level_option.clear()
	for i in range(all_levels.size()):
		var level = all_levels[i]
		level_option.add_item(level.level_id + " - " + level.display_name, i)
	
	# 默认选择第一个关卡
	if all_levels.size() > 0:
		level_option.selected = 0
		load_waves_for_level(0)

func load_waves_for_level(level_index: int):
	if level_index < 0 or level_index >= all_levels.size():
		return
	
	current_level_for_waves = all_levels[level_index]
	
	# 加载波次数据
	var level_res = current_level_for_waves.resource
	if not level_res or not level_res.enemy_waves:
		current_level_for_waves["waves"] = []
	else:
		var waves = []
		for wave_res in level_res.enemy_waves:
			# 复制敌人ID数组
			var unit_ids: Array = []
			for id in wave_res.enemy_unit_ids:
				unit_ids.append(id)
			
			# 复制偏移数组（如果存在）
			var offsets: Array = []
			if wave_res.enemy_offsets and wave_res.enemy_offsets.size() > 0:
				for offset in wave_res.enemy_offsets:
					offsets.append(offset)
			else:
				# 兼容旧版配置：自动生成偏移
				for i in unit_ids.size():
					offsets.append(wave_res.spawn_column_offset + i)
			
			waves.append({
				"spawn_turn": wave_res.spawn_turn,
				"lane": wave_res.lane,
				"enemy_unit_ids": unit_ids,
				"enemy_offsets": offsets
			})
		current_level_for_waves["waves"] = waves
	
	refresh_wave_table()
	create_enemy_instances_ui()
	update_status("已加载关卡：%s，共%d个波次" % [current_level_for_waves.level_id, current_level_for_waves.waves.size()])

func refresh_wave_table():
	wave_table.clear()
	var root = wave_table.create_item()
	
	if not current_level_for_waves.has("waves"):
		return
	
	for wave in current_level_for_waves.waves:
		var item = wave_table.create_item(root)
		item.set_text(0, str(wave.spawn_turn))
		item.set_text(1, str(wave.lane))
		item.set_text(2, str(wave.enemy_unit_ids.size()))
		
		# 显示敌人名称和偏移
		var enemy_display = []
		
		# 确保 enemy_offsets 存在
		if not wave.has("enemy_offsets"):
			wave.enemy_offsets = []
		
		for i in wave.enemy_unit_ids.size():
			var enemy_id = wave.enemy_unit_ids[i]
			var enemy_name = get_unit_name_by_id(enemy_id)
			var display_name = enemy_name if enemy_name != "" else enemy_id
			
			# 获取偏移（如果没有则显示?）
			var offset_str = "?"
			if i < wave.enemy_offsets.size():
				offset_str = str(wave.enemy_offsets[i])
			
			enemy_display.append(display_name + "@" + offset_str)
		
		item.set_text(3, ", ".join(enemy_display))
		
		# 列偏移列现在显示详细偏移数组
		var offsets = []
		for i in wave.enemy_offsets.size():
			offsets.append(str(wave.enemy_offsets[i]))
		item.set_text(4, "[" + ",".join(offsets) + "]")
		
		item.set_metadata(0, wave)

func get_unit_name_by_id(unit_id: String) -> String:
	for unit in all_units:
		if unit.id == unit_id:
			return unit.display_name
	return ""

func create_enemy_instances_ui():
	# 清空现有UI
	var enemy_container = wave_detail_panel.get_node_or_null("EnemyContainer")
	if not enemy_container:
		return
	
	for child in enemy_container.get_children():
		child.queue_free()
	
	enemy_instances_ui.clear()
	
	# 为每个敌人类型创建可折叠的实例编辑器（仅ENEMY阵营）
	for unit in all_units:
		if unit.faction == 1:  # 1 = ENEMY
			var unit_section = VBoxContainer.new()
			unit_section.name = unit.id + "_Section"
			
			# 标题行：敌人名称 + 添加按钮 + 折叠按钮
			var header = HBoxContainer.new()
			header.name = "Header"
			
			var name_label = Label.new()
			name_label.text = unit.display_name + " (" + unit.id + ")"
			name_label.custom_minimum_size = Vector2(200, 0)
			header.add_child(name_label)
			
			var count_label = Label.new()
			count_label.name = "CountLabel"
			count_label.text = "(共0个)"
			header.add_child(count_label)
			
			var add_btn = Button.new()
			add_btn.text = "+ 添加实例"
			add_btn.pressed.connect(_on_add_enemy_instance.bind(unit.id))
			header.add_child(add_btn)
			
			var toggle_btn = Button.new()
			toggle_btn.name = "ToggleBtn"
			toggle_btn.text = "▼"
			toggle_btn.custom_minimum_size = Vector2(30, 0)
			toggle_btn.pressed.connect(_on_toggle_enemy_section.bind(unit.id))
			header.add_child(toggle_btn)
			
			unit_section.add_child(header)
			
			# 实例列表容器（可折叠）
			var instances_container = VBoxContainer.new()
			instances_container.name = "InstancesContainer"
			unit_section.add_child(instances_container)
			
			enemy_container.add_child(unit_section)
			enemy_instances_ui[unit.id] = unit_section

func refresh_wave_detail():
	if selected_wave_data.is_empty():
		return
	
	var turn_spin = wave_detail_panel.get_node_or_null("BasicRow/TurnSpin")
	var lane_option = wave_detail_panel.get_node_or_null("BasicRow/LaneOption")
	
	if turn_spin:
		turn_spin.value = selected_wave_data.spawn_turn
	if lane_option:
		lane_option.selected = selected_wave_data.lane
	
	# 清空所有实例UI
	for unit_id in enemy_instances_ui:
		var section = enemy_instances_ui[unit_id]
		var instances_container = section.get_node_or_null("InstancesContainer")
		if instances_container:
			for child in instances_container.get_children():
				child.queue_free()
	
	# 确保 enemy_offsets 存在且长度匹配
	if not selected_wave_data.has("enemy_offsets"):
		selected_wave_data.enemy_offsets = []
	
	# 如果offsets数组长度不够，填充默认值
	while selected_wave_data.enemy_offsets.size() < selected_wave_data.enemy_unit_ids.size():
		selected_wave_data.enemy_offsets.append(0)
	
	# 按类型统计敌人
	var enemy_counts: Dictionary = {}
	for unit_id in selected_wave_data.enemy_unit_ids:
		enemy_counts[unit_id] = enemy_counts.get(unit_id, 0) + 1
	
	print("[配置管理器] 波次敌人统计: ", enemy_counts)
	
	# 填充实例UI
	for i in selected_wave_data.enemy_unit_ids.size():
		var unit_id = selected_wave_data.enemy_unit_ids[i]
		var offset = selected_wave_data.enemy_offsets[i]
		
		if enemy_instances_ui.has(unit_id):
			var section = enemy_instances_ui[unit_id]
			var instances_container = section.get_node_or_null("InstancesContainer")
			if instances_container:
				_add_instance_row(instances_container, i, unit_id, offset)
	
	# 更新数量标签
	for unit_id in enemy_instances_ui:
		var section = enemy_instances_ui[unit_id]
		var count_label = section.get_node_or_null("Header/CountLabel")
		if count_label:
			var count = enemy_counts.get(unit_id, 0)
			count_label.text = "(共%d个)" % count
			print("[配置管理器] 更新计数标签: ", unit_id, " = ", count)
		else:
			push_warning("[配置管理器] 找不到CountLabel: " + unit_id)

func _on_wave_level_changed(index: int):
	load_waves_for_level(index)

func _on_wave_selected():
	var sel = wave_table.get_selected()
	if sel:
		selected_wave_data = sel.get_metadata(0)
		refresh_wave_detail()

func _on_wave_turn_changed(value: float):
	if not selected_wave_data.is_empty():
		selected_wave_data.spawn_turn = int(value)
		call_deferred("refresh_wave_table")
		update_status("已修改回合: " + str(value))

func _on_wave_lane_changed(index: int):
	if not selected_wave_data.is_empty():
		selected_wave_data.lane = index
		call_deferred("refresh_wave_table")
		update_status("已修改行号: " + str(index))

# 添加一行实例UI
func _add_instance_row(container: VBoxContainer, index: int, unit_id: String, offset: int):
	var row = HBoxContainer.new()
	row.name = "Instance_" + str(index)
	
	var instance_label = Label.new()
	instance_label.text = "  实例 " + str(container.get_child_count() + 1) + ":"
	instance_label.custom_minimum_size = Vector2(100, 0)
	row.add_child(instance_label)
	
	var offset_label = Label.new()
	offset_label.text = "列偏移:"
	row.add_child(offset_label)
	
	var offset_spin = SpinBox.new()
	offset_spin.min_value = 0
	offset_spin.max_value = 20
	offset_spin.value = offset
	offset_spin.custom_minimum_size = Vector2(80, 0)
	offset_spin.value_changed.connect(_on_instance_offset_changed.bind(index))
	row.add_child(offset_spin)
	
	var delete_btn = Button.new()
	delete_btn.text = "删除"
	delete_btn.pressed.connect(_on_delete_enemy_instance.bind(index))
	row.add_child(delete_btn)
	
	container.add_child(row)

# 添加敌人实例
func _on_add_enemy_instance(unit_id: String):
	if selected_wave_data.is_empty():
		return
	
	selected_wave_data.enemy_unit_ids.append(unit_id)
	selected_wave_data.enemy_offsets.append(0)  # 默认偏移0
	
	call_deferred("refresh_wave_detail")
	call_deferred("refresh_wave_table")
	update_status("已添加敌人实例: " + unit_id)

# 删除敌人实例
func _on_delete_enemy_instance(index: int):
	if selected_wave_data.is_empty():
		return
	
	if index < selected_wave_data.enemy_unit_ids.size():
		selected_wave_data.enemy_unit_ids.remove_at(index)
	if index < selected_wave_data.enemy_offsets.size():
		selected_wave_data.enemy_offsets.remove_at(index)
	
	call_deferred("refresh_wave_detail")
	call_deferred("refresh_wave_table")
	update_status("已删除敌人实例")

# 修改实例偏移
func _on_instance_offset_changed(value: float, index: int):
	if selected_wave_data.is_empty():
		return
	
	if index < selected_wave_data.enemy_offsets.size():
		selected_wave_data.enemy_offsets[index] = int(value)
		print("[配置管理器] 修改偏移: index=%d, value=%d, 完整offsets=%s" % [index, int(value), selected_wave_data.enemy_offsets])
		call_deferred("refresh_wave_table")
		update_status("已修改列偏移: " + str(value))

# 折叠/展开敌人类型
func _on_toggle_enemy_section(unit_id: String):
	if not enemy_instances_ui.has(unit_id):
		return
	
	var section = enemy_instances_ui[unit_id]
	var instances_container = section.get_node_or_null("InstancesContainer")
	var toggle_btn = section.get_node_or_null("Header/ToggleBtn")
	
	if instances_container and toggle_btn:
		instances_container.visible = not instances_container.visible
		toggle_btn.text = "▼" if instances_container.visible else "▶"

func _on_add_wave():
	if current_level_for_waves.is_empty():
		update_status("请先选择关卡")
		return
	
	var new_wave = {
		"spawn_turn": 1,
		"lane": 0,
		"enemy_unit_ids": [],
		"enemy_offsets": []
	}
	current_level_for_waves.waves.append(new_wave)
	refresh_wave_table()
	update_status("已添加新波次")

func _on_delete_wave():
	if selected_wave_data.is_empty():
		update_status("请先选择要删除的波次")
		return
	
	current_level_for_waves.waves.erase(selected_wave_data)
	selected_wave_data = {}
	refresh_wave_table()
	update_status("已删除波次")

func _on_save_waves():
	if save_waves_internal():
		update_status("已保存关卡波次配置：%s，共%d个波次" % [current_level_for_waves.level_id, current_level_for_waves.waves.size()])
		load_waves_for_level(get_current_wave_level_index())
	else:
		update_status("保存波次失败！")

func save_waves_internal() -> bool:
	if current_level_for_waves.is_empty():
		return false
	
	var level_res: LevelConfig
	if current_level_for_waves.resource:
		level_res = current_level_for_waves.resource
	else:
		return false
	
	# 全量刷新波次
	level_res.enemy_waves.clear()
	
	var wave_script = load("res://scripts/data/wave_data.gd")
	if not wave_script:
		return false
	
	for wave_config in current_level_for_waves.waves:
		var wave = wave_script.new()
		wave.spawn_turn = wave_config.spawn_turn
		wave.lane = wave_config.lane
		
		# 显式转换为Array[String]类型
		var enemy_ids: Array[String] = []
		for enemy_id in wave_config.enemy_unit_ids:
			enemy_ids.append(enemy_id)
		wave.enemy_unit_ids = enemy_ids
		
		# 显式转换enemy_offsets为Array[int]类型
		var offsets: Array[int] = []
		if wave_config.has("enemy_offsets"):
			for offset in wave_config.enemy_offsets:
				offsets.append(int(offset))
		wave.enemy_offsets = offsets
		
		wave.spawn_column_offset = 0  # 保留用于兼容性
		level_res.enemy_waves.append(wave)
		
		print("[配置管理器] 保存波次: turn=%d, lane=%d, enemies=%s, offsets=%s" % [
			wave.spawn_turn, wave.lane, enemy_ids, offsets
		])
	
	# 保存关卡
	if ResourceSaver.save(level_res, current_level_for_waves.path) == OK:
		print("[配置管理器] 已保存波次: ", current_level_for_waves.path)
		return true
	else:
		push_error("[配置管理器] 保存波次失败: " + current_level_for_waves.path)
		return false

func _on_refresh_waves():
	var index = get_current_wave_level_index()
	load_levels()
	populate_wave_level_options()
	if index >= 0 and index < all_levels.size():
		var level_option = tab_container.get_node_or_null("WaveTab/TopBar/LevelOption")
		if level_option:
			level_option.selected = index
		load_waves_for_level(index)

func get_current_wave_level_index() -> int:
	var level_option = tab_container.get_node_or_null("WaveTab/TopBar/LevelOption")
	if level_option:
		return level_option.selected
	return 0

func update_status(msg: String):
	status_label.text = msg
	print("[配置管理器] ", msg)
