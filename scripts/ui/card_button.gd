# 卡牌按钮
class_name CardButton
extends Button

# 卡牌数据
var card_data: CardData

# UI节点
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var cost_label: Label = $VBoxContainer/CostLabel
@onready var desc_label: Label = $VBoxContainer/DescLabel

func _ready() -> void:
	pressed.connect(_on_pressed)

# 设置卡牌数据
func set_card_data(data: CardData) -> void:
	card_data = data
	update_visual()

# 更新视觉
func update_visual() -> void:
	if not is_node_ready() or not card_data:
		return
	
	name_label.text = card_data.display_name
	cost_label.text = "费用: %d" % card_data.cost
	desc_label.text = card_data.description
	
	# 根据卡牌类型改变颜色
	match card_data.card_type:
		GameEnums.CardType.UNIT:
			modulate = Color(0.8, 0.9, 1.0)
		GameEnums.CardType.SPELL:
			modulate = Color(1.0, 0.8, 0.8)
		GameEnums.CardType.BUFF:
			modulate = Color(0.8, 1.0, 0.8)

func _on_pressed() -> void:
	if card_data:
		# 向上查找HandUI节点
		var node = get_parent()
		while node:
			if node is HandUI:
				node._on_card_selected(self)
				return
			node = node.get_parent()
		push_warning("[CardButton] 未找到HandUI父节点")
