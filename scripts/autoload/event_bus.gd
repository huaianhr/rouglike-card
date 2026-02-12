# 全局事件总线
# 负责解耦各模块间的通信，避免直接引用
extends Node

# ========== 游戏流程信号 ==========
signal game_started()
signal game_ended(victory: bool)

# ========== 回合流信号 ==========
signal turn_started(turn_number: int)
signal combat_phase_changed(phase: String)  # "PLAYER_TURN" / "COMBAT" / "ENEMY_TURN"
signal turn_ended()

# ========== AP（行动点）信号 ==========
signal ap_changed(current: int, max_value: int)
signal ap_insufficient(required: int, current: int)

# ========== 卡牌信号 ==========
signal card_drawn(card_data: Resource)
signal card_played(card_data: Resource, target_position: Vector2i)
signal hand_updated(cards: Array)

# ========== 单位信号 ==========
signal unit_spawned(unit: Node, position: Vector2i)
signal unit_moved(unit: Node, from_pos: Vector2i, to_pos: Vector2i)
signal unit_damaged(unit: Node, damage: int, source: Node)
signal unit_healed(unit: Node, amount: int)
signal unit_stat_changed(unit: Node, stat_name: String, old_value: int, new_value: int)
signal unit_died(unit: Node, position: Vector2i)
signal unit_corrupted(unit: Node, new_faction: String)

# ========== 战斗信号 ==========
signal combat_started()
signal combat_resolved()
signal enemy_wave_spawned(wave_index: int, enemies: Array)
signal enemy_turn_ended()

# ========== 关卡信号 ==========
signal level_started(level_config: Resource)
signal level_completed(victory: bool, rewards: Array)
signal victory_achieved()
signal defeat_triggered()

# ========== UI信号 ==========
signal tile_hovered(position: Vector2i)
signal tile_selected(position: Vector2i)
signal ui_message(message: String, type: String)  # type: "info" / "warning" / "error"
