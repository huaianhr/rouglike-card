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

func _ready():
	print("[配置管理器] _ready() 开始")
	
	# 获取UI节点
	tab_container = $VBox/TabContainer
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
	create_global_tab()
	
	# 加载数据
	load_all_configs()
	
	print("[配置管理器] 初始化完成")

func create_card_tab():
	print("[配置管理器] 创建卡牌页签")
	
	var card_tab = VBoxContainer.new()
	
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
	card_table.columns = 5
	card_table.set_column_title(0, "ID")
	card_table.set_column_title(1, "名称")
	card_table.set_column_title(2, "类型")
	card_table.set_column_title(3, "费用")
	card_table.set_column_title(4, "描述")
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

func create_global_tab():
	print("[配置管理器] 创建全局配置页签")
	
	var global_tab = VBoxContainer.new()
	
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
	tab_container.set_tab_title(4, "全局配置")

func load_all_configs():
	print("[配置管理器] 加载配置")
	load_cards()
	load_units()
	load_towers()
	load_levels()
	load_global_config()
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
					all_cards.append({
						"resource": res,
						"path": "res://resources/cards/" + file_name,
						"id": res.id,
						"display_name": res.display_name,
						"card_type": res.card_type,
						"cost": res.cost,
						"description": res.description
					})
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
		item.set_text(4, card.description.substr(0, 30))
		
		# 可编辑
		item.set_editable(0, true)
		item.set_editable(1, true)
		item.set_editable(3, true)
		item.set_editable(4, true)
		
		# 类型列设置为下拉选择
		item.set_cell_mode(2, TreeItem.CELL_MODE_RANGE)
		item.set_text(2, "UNIT,SPELL,BUFF")
		item.set_range(2, card.card_type)
		item.set_editable(2, true)
		
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
	
	var text_edit = tab_container.get_node_or_null("GlobalConfig/InitialDeckEdit")
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
		3: 
			var val = item.get_text(3)
			if val.is_valid_int():
				card.cost = int(val)
				update_status("已修改费用: " + str(card.cost))
		4: 
			card.description = item.get_text(4)
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
		"description": ""
	}
	all_cards.append(new_card)
	refresh_card_table()

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
	
	var text_edit = tab_container.get_node_or_null("GlobalConfig/InitialDeckEdit")
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
	
	update_status("已保存 %d 项配置" % saved)
	load_all_configs()

func _on_refresh_pressed():
	load_all_configs()

func update_status(msg: String):
	status_label.text = msg
	print("[配置管理器] ", msg)
