# 全局枚举定义
class_name GameEnums
extends RefCounted

enum Faction {
	PLAYER,   # 玩家阵营
	ENEMY     # 敌人阵营
}

enum CardType {
	UNIT,     # 召唤单位卡
	SPELL,    # 法术卡
	BUFF      # 增益卡
}

enum TargetRule {
	EMPTY_TILE,      # 空格子
	FRIENDLY_UNIT,   # 友军单位
	ENEMY_UNIT,      # 敌方单位
	ANY_UNIT,        # 任意单位
	SELF             # 自身
}

enum AttackPattern {
	MELEE,           # 近战（攻击同行首个敌人）
	RANGED,          # 远程（可跨格攻击）
	AOE,             # 范围攻击
	NONE             # 不攻击
}

enum MovePattern {
	STATIC,          # 静止不动
	FORWARD,         # 向前推进
	CUSTOM           # 自定义移动逻辑
}
