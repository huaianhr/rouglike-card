# 奖励池数据
class_name RewardPoolData
extends Resource

# 单个奖励项
class RewardEntry:
	var type: String  # "card" / "item"
	var id: String  # 卡牌ID或道具ID
	var weight: int  # 权重
	var count_min: int  # 最小数量
	var count_max: int  # 最大数量

# 奖励数量
@export var reward_count: int = 3  # 玩家可选择几个奖励

# 卡牌奖励池（格式：card_id:weight）
@export var card_pool: Array[String] = []

# 道具奖励池（格式：item_id:weight）
@export var item_pool: Array[String] = []

# 解析奖励池并随机抽取
func generate_rewards() -> Array:
	var all_entries = []
	
	# 解析卡牌池
	for entry in card_pool:
		var parts = entry.split(":")
		if parts.size() >= 2:
			all_entries.append({
				"type": "card",
				"id": parts[0],
				"weight": int(parts[1])
			})
	
	# 解析道具池
	for entry in item_pool:
		var parts = entry.split(":")
		if parts.size() >= 2:
			all_entries.append({
				"type": "item",
				"id": parts[0],
				"weight": int(parts[1])
			})
	
	# 权重随机抽取
	var rewards = []
	for i in reward_count:
		if all_entries.is_empty():
			break
		var reward = weighted_random(all_entries)
		rewards.append(reward)
	
	return rewards

# 权重随机
func weighted_random(entries: Array) -> Dictionary:
	var total_weight = 0
	for entry in entries:
		total_weight += entry["weight"]
	
	var random_value = randi() % total_weight
	var current_weight = 0
	
	for entry in entries:
		current_weight += entry["weight"]
		if random_value < current_weight:
			return entry
	
	return entries[0] if entries.size() > 0 else {}
