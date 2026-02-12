# 肉鸽卡牌回合制战斗游戏 - 开发文档

## 当前版本：阶段0+1 完成

### ✅ 已完成功能

#### 阶段0：基础设施与配置协议
1. **Autoload系统**
   - EventBus：全局事件总线
   - GameManager：游戏流程状态机
   - DeckManager：卡组管理
   - ConfigLoader：配置加载器

2. **Resource数据类**
   - BattleRuleConfig：战斗规则配置
   - CardData：卡牌数据
   - UnitData：单位数据
   - LevelConfig：关卡配置
   - WaveData：敌人波次
   - RewardPoolData：奖励池
   - CardEffect：卡牌效果基类
   - SpawnUnitEffect：召唤单位效果
   - BuffStatEffect：增益/减益效果

3. **测试配置文件**
   - default_rules.tres：3x10棋盘，5AP起始
   - 4张初始卡牌：
     * 召唤骑士（费用1，HP16 ATK8）
     * 召唤法师（费用1，HP5 ATK14）
     * 蓄势（费用1，+2攻击）
     * 亡灵永存（费用1，+5护甲）
   - 3种敌人单位：
     * 恶灵侍从（HP10 ATK5）
     * 恶灵骑士（HP25 ATK10）
     * 恶灵法师（HP3 ATK11）
   - level_01.tres：第一关配置（5回合波次）

#### 阶段1：战场可视化与手牌系统
1. **战场系统**
   - Board：3x10棋盘管理
   - Tile：格子交互（悬停、选择）
   - Unit：单位显示（HP、ATK、护甲、腐化计数）

2. **UI系统**
   - HandUI：手牌区显示
   - CardButton：卡牌按钮（显示名称、费用、描述）
   - APUI：行动点显示（进度条）
   - MessageUI：消息提示

3. **核心逻辑**
   - APManager：行动点管理
   - BattleController：战场总控制器
   - 卡牌选择 -> 目标选择 -> 效果执行流程

### 📁 项目结构

```
rouglike-card/
├── project.godot              # 项目配置
├── scenes/
│   ├── main.tscn             # 游戏入口
│   ├── battle/
│   │   ├── battle_scene.tscn # 战场主场景
│   │   ├── board.tscn        # 棋盘
│   │   ├── tile.tscn         # 格子
│   │   └── unit.tscn         # 单位
│   └── ui/
│       ├── hand_ui.tscn      # 手牌区
│       ├── card_button.tscn  # 卡牌按钮
│       └── ap_ui.tscn        # AP条
├── scripts/
│   ├── autoload/             # 全局单例
│   ├── battle/               # 战斗逻辑
│   ├── data/                 # 数据类定义
│   │   └── effects/          # 卡牌效果
│   └── ui/                   # UI脚本
└── resources/
    ├── configs/              # 配置文件
    │   └── levels/           # 关卡配置
    ├── cards/                # 卡牌资源
    └── units/                # 单位资源
```

### 🎮 当前可测试功能

1. ✅ 启动游戏自动加载第一关
2. ✅ 显示3x10棋盘
3. ✅ 显示5张初始手牌
4. ✅ 显示当前AP（5/10）
5. ✅ 点击卡牌高亮可用格子
6. ✅ 点击格子打出卡牌（召唤单位/增益）
7. ✅ AP扣费正常工作
8. ✅ 敌人按波次生成（第1、2、5回合）
9. ✅ 结束回合进入下一回合

### ⚠️ 已知限制（待后续阶段实现）

1. **战斗系统**
   - ❌ 单位尚未实现攻击逻辑
   - ❌ 敌人尚未实现推进逻辑
   - ❌ 腐化机制未完全实现（仅计数器显示）

2. **胜负判定**
   - ❌ 未实现胜利/失败检测
   - ❌ 未实现关卡结算奖励

3. **高级功能**
   - ❌ 无保存/加载系统
   - ❌ 无多关卡切换
   - ❌ 无道具系统

### 🔧 启动说明

1. 使用 Godot 4.6 打开项目
2. 点击运行按钮（F5）
3. 游戏将自动加载第一关并进入战斗

### 🎯 下一步计划（阶段2）

1. 实现回合状态机
2. 实现战斗结算逻辑
3. 实现敌人推进与腐化机制
4. 添加胜负判定

### 📝 配置说明

所有配置文件均为 `.tres` 格式，可在 Godot 编辑器中直接编辑：

- **修改战斗规则**：`resources/configs/default_rules.tres`
- **修改关卡**：`resources/configs/levels/level_01.tres`
- **修改卡牌**：`resources/cards/*.tres`
- **修改单位**：`resources/units/*.tres`

### 🐛 调试技巧

1. 查看输出面板（Output）查看日志
2. 使用远程调试（Remote）查看节点树
3. F3 可查看运行时FPS和内存使用

### 📚 代码规范

- 所有脚本使用中文注释
- 信号驱动的事件系统（通过EventBus）
- Resource类用于数据配置
- 场景和脚本分离

---

**当前版本**：v0.1 - 基础框架完成  
**开发日期**：2026-02-12  
**引擎版本**：Godot 4.6
