# 游戏全局管理器
# 负责游戏流程状态机、关卡切换、胜负判定
extends Node

enum GameState {
	MENU,
	BATTLE,
	SETTLEMENT,
	GAME_OVER
}

enum CombatPhase {
	PLAYER_TURN,
	COMBAT,
	ENEMY_TURN,
	CHECK_VICTORY
}

# 当前状态
var current_state: GameState = GameState.MENU
var current_phase: CombatPhase = CombatPhase.PLAYER_TURN

# 关卡数据
var current_level: Resource  # LevelConfig
var current_turn: int = 0

# 游戏规则（运行时缓存）
var battle_rules: Resource  # BattleRuleConfig

func _ready() -> void:
	EventBus.turn_ended.connect(_on_turn_ended)

# 开始新游戏
func start_new_game() -> void:
	current_state = GameState.BATTLE
	EventBus.game_started.emit()

# 加载关卡
func load_level(level_config: Resource) -> void:
	current_level = level_config
	battle_rules = level_config.battle_rules
	current_turn = 0
	current_phase = CombatPhase.PLAYER_TURN
	EventBus.level_started.emit(level_config)

# 切换战斗阶段
func change_phase(new_phase: CombatPhase) -> void:
	current_phase = new_phase
	var phase_name = CombatPhase.keys()[new_phase]
	EventBus.combat_phase_changed.emit(phase_name)

# 玩家结束回合
func end_player_turn() -> void:
	if current_phase != CombatPhase.PLAYER_TURN:
		return
	
	change_phase(CombatPhase.COMBAT)
	# 战斗结算由 CombatResolver 监听信号后执行

# 战斗结算完成后调用
func on_combat_resolved() -> void:
	change_phase(CombatPhase.ENEMY_TURN)
	# 敌人推进逻辑由 EnemyManager 监听信号后执行

# 敌人回合结束后调用
func on_enemy_turn_ended() -> void:
	change_phase(CombatPhase.CHECK_VICTORY)
	check_victory_condition()

# 检测胜负
func check_victory_condition() -> void:
	# TODO: 后续由 VictoryChecker 实现具体逻辑
	# 暂时简单进入下一回合
	start_next_turn()

# 开始下一回合
func start_next_turn() -> void:
	current_turn += 1
	current_phase = CombatPhase.PLAYER_TURN
	EventBus.turn_started.emit(current_turn)

# 触发胜利
func trigger_victory() -> void:
	current_state = GameState.SETTLEMENT
	EventBus.victory_achieved.emit()
	# TODO: 生成奖励

# 触发失败
func trigger_defeat() -> void:
	current_state = GameState.GAME_OVER
	EventBus.defeat_triggered.emit()

func _on_turn_ended() -> void:
	end_player_turn()
