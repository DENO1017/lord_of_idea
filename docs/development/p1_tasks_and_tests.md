# P1 开发任务拆解与测试用例

本文档将 [P1 工具先行](project/p1_deliverables.md) 拆解为可执行的开发任务，并为每条任务撰写对应的测试用例。测试类型包括：**单元测试（Unit）**、**Widget 测试（Widget）**、**集成测试（Integration）**。实现时可将用例落地到 `test/` 下对应文件。

---

## 任务与测试索引

| 任务编号 | 开发内容概要 | 测试类型 | 测试文件建议 |
|----------|--------------|----------|--------------|
| P1-1 | 工具结果模型（DiceResult / PoemSlipResult / DivinationResult） | Unit | `test/shared/models/tool_result_models_test.dart` |
| P1-2 | 骰子表达式解析与掷骰逻辑（DiceRoller / 表达式解析） | Unit | `test/features/divination/domain/dice_parser_test.dart`、`dice_roller_test.dart` |
| P1-3 | 骰子页（DiceScreen）与路由 | Widget | `test/features/divination/presentation/dice_screen_test.dart` |
| P1-4 | 诗签库数据与抽签服务（PoemSlipService） | Unit | `test/features/divination/domain/poem_slip_service_test.dart` |
| P1-5 | 诗签页（PoemSlipScreen）与路由 | Widget | `test/features/divination/presentation/poem_slip_screen_test.dart` |
| P1-6 | 塔罗牌组数据与单张抽牌服务（TarotService / DivinationService） | Unit | `test/features/divination/domain/divination_service_test.dart` |
| P1-7 | 简易占卜页（TarotScreen / DivinationScreen）与路由 | Widget | `test/features/divination/presentation/tarot_screen_test.dart` |
| P1-8 | 工具聚合页（ToolsScreen）入口与子路由导航 | Widget | `test/features/divination/presentation/tools_screen_test.dart`、路由测试 |
| P1-9 | 结果可复制（可选）与序列化一致性 | Unit + Widget | 各模型 toJson/fromJson 往返、复制按钮行为 |

---

## P1-1：工具结果模型（DiceResult / PoemSlipResult / DivinationResult）

**开发内容**  
- 按 [tool_result_models_spec](../technical/tool_result_models_spec.md) 实现基类 `ToolResult` 及三种结果类，位于 `shared/models/`（`tool_result.dart`、`dice_result.dart`、`poem_slip_result.dart`、`divination_result.dart`）。  
- 每种结果含 `type`、`createdAt`、`toJson()`、`fromJson()`（或 factory）；与规格中示例 JSON 一致。

**验收**  
可构造结果并序列化/反序列化；fromJson 与 toJson 往返一致。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P1-1-U1 | Unit | DiceResult.toJson() 含 type、createdAt、expression、rolls、modifier、total | 构造 DiceResult，toJson() 含上述 key，type 为 `"dice"`。 |
| P1-1-U2 | Unit | DiceResult.fromJson(上述 json) 还原为相等对象 | toJson 后 fromJson，与原对象字段一致（createdAt 可比较到毫秒或秒）。 |
| P1-1-U3 | Unit | PoemSlipResult toJson/fromJson 往返一致 | 同上，含 libraryId、slipId、content。 |
| P1-1-U4 | Unit | DivinationResult toJson/fromJson 往返一致 | 同上，含 cardId、cardName、reversed、meaning。 |

---

## P1-2：骰子表达式解析与掷骰逻辑

**开发内容**  
- 表达式解析：输入字符串（如 `2d6+3`）解析为「数量、面数、修正」；非法输入返回明确错误。解析器与掷骰逻辑位于 `features/divination/domain/services/dice_roller.dart`（见 [dice_spec](../technical/dice_spec.md)）。  
- 掷骰：根据解析结果生成随机点数（可注入 Random），组装 DiceResult。  
- 随机源通过 Provider（如 `diceRollerProvider`）或构造函数注入，便于测试固定种子。

**验收**  
合法表达式掷骰得到合法 DiceResult；非法表达式不掷骰并返回可展示错误。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P1-2-U1 | Unit | 解析 "2d6+3" 得到 count=2, faces=6, modifier=3 | 调用解析器，断言数量 2、面数 6、修正 3。 |
| P1-2-U2 | Unit | 解析 "d20" 得到 count=1, faces=20, modifier=0 | 同上。 |
| P1-2-U3 | Unit | 解析非法字符串（如 "d"、"0d6"）返回错误或 throws | 断言解析失败，错误信息非空或抛出 ParseException。 |
| P1-2-U4 | Unit | 掷骰（固定 Random 种子）结果在 1..faces 范围内且 total 正确 | 使用 seed，掷 2d6+3，rolls 每项 value 在 1..6，total = sum(rolls)+3。 |
| P1-2-U5 | Unit | 掷骰产出 DiceResult，含 expression、rolls、total | 掷骰后结果为 DiceResult 类型，expression 与输入一致。 |

---

## P1-3：骰子页（DiceScreen）与路由

**开发内容**  
- 实现 DiceScreen：表达式输入、掷骰按钮、结果展示（total、rolls、expression）。路由 `/tools/dice`，见 [routes_spec](../technical/routes_spec.md)。  
- 在 go_router 中注册子路由 `/tools/dice`，从 ToolsScreen 可导航到 DiceScreen 并返回。

**验收**  
从工具页进入骰子页，输入 2d6+3 掷骰后可见结果；返回回到工具页。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P1-3-W1 | Widget | DiceScreen 含输入框与掷骰按钮 | pumpWidget DiceScreen（提供必要 Provider），find 输入框与按钮。 |
| P1-3-W2 | Widget | 输入合法表达式并点击掷骰后展示结果区域（含 total 或 rolls） | 输入 "2d6"，tap 掷骰，pump，find 结果相关文案或 Widget。 |
| P1-3-W3 | Widget | 路由 /tools/dice 解析为 DiceScreen | 使用 appRouterProvider，go('/tools/dice')，pump，find.byType(DiceScreen)。 |

---

## P1-4：诗签库数据与抽签服务

**开发内容**  
- 诗签库数据：默认库路径 `assets/poem_slips/default.json`，格式见 [poem_slip_spec](../technical/poem_slip_spec.md)；加载库返回签条列表。  
- PoemSlipService（`features/divination/domain/services/poem_slip_service.dart`）：根据 libraryId 加载库，随机选一条，返回 PoemSlipResult；Random 可注入。

**验收**  
给定库 ID 可抽到一条签；结果含 libraryId、slipId、content、createdAt。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P1-4-U1 | Unit | 加载默认库得到非空签条列表 | 调用加载方法，断言 list.isNotEmpty。 |
| P1-4-U2 | Unit | 抽签（固定 Random）得到确定的一条 PoemSlipResult | 固定种子，多次抽签或单次，断言 content 非空、type 为 poem_slip。 |
| P1-4-U3 | Unit | PoemSlipResult 含 libraryId、slipId、content、createdAt | 抽签结果字段齐全。 |

---

## P1-5：诗签页（PoemSlipScreen）与路由

**开发内容**  
- 实现 PoemSlipScreen：选库（若多库）、抽签按钮、签条展示。路由 `/tools/poem-slip`，见 [routes_spec](../technical/routes_spec.md)。  
- 注册路由 `/tools/poem-slip`，可从 ToolsScreen 进入并返回。

**验收**  
可抽签并看到文案；可换库（若有多库）。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P1-5-W1 | Widget | PoemSlipScreen 含抽签按钮 | pumpWidget，find 抽签按钮。 |
| P1-5-W2 | Widget | 点击抽签后展示签条内容（content） | tap 抽签，pump，find.text 包含某段签条文案（或通过 mock 固定一条）。 |
| P1-5-W3 | Widget | 路由 /tools/poem-slip 解析为 PoemSlipScreen | go('/tools/poem-slip')，find.byType(PoemSlipScreen)。 |

---

## P1-6：塔罗牌组数据与单张抽牌服务

**开发内容**  
- 牌组数据：路径 `assets/tarot/rws.json`，结构见 [simple_divination_spec](../technical/simple_divination_spec.md)；加载牌组得到牌列表（含 cardId、uprightMeaning、reversedMeaning）。  
- 抽牌服务（`features/divination/domain/services/divination_service.dart`）：随机选一张、随机正逆位，组装 DivinationResult；Random 可注入。

**验收**  
抽牌得到 DivinationResult；reversed 与 meaning 对应正确。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P1-6-U1 | Unit | 加载默认牌组得到 22 或 78 张牌 | 依规格约定，断言牌数。 |
| P1-6-U2 | Unit | 抽牌（固定 Random）得到 DivinationResult，含 cardId、reversed、meaning | 固定种子，断言 type 为 divination、meaning 非空。 |
| P1-6-U3 | Unit | reversed 为 true 时 meaning 为逆位释义 | mock 或固定牌组，控制 Random 使 reversed=true，断言 meaning 与逆位文案一致。 |

---

## P1-7：简易占卜页（TarotScreen / DivinationScreen）与路由

**开发内容**  
- 实现占卜页 TarotScreen：抽牌按钮、牌名、正/逆位、释义展示。路由 `/tools/tarot`，见 [simple_divination_spec](../technical/simple_divination_spec.md)。  
- 注册路由 `/tools/tarot`。

**验收**  
可抽牌并看到牌面与释义。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P1-7-W1 | Widget | 占卜页含抽牌按钮 | pumpWidget，find 抽牌按钮。 |
| P1-7-W2 | Widget | 点击抽牌后展示牌名与释义 | tap 抽牌，pump，find 牌名或 meaning 文案。 |
| P1-7-W3 | Widget | 路由解析为占卜 Screen | go('/tools/tarot')，find.byType(TarotScreen)。 |

---

## P1-8：工具聚合页（ToolsScreen）入口与子路由导航

**开发内容**  
- ToolsScreen 从占位升级：展示骰子、诗签、占卜三个入口（**卡片形式**）；点击分别跳转 `/tools/dice`、`/tools/poem-slip`、`/tools/tarot`。l10n key：`toolDice`、`toolPoemSlip`、`toolTarot`（见 [p1_deliverables](project/p1_deliverables.md)）。  
- 子页可返回（AppBar back 或显式返回按钮）。

**验收**  
从首页或主导航进入 /tools，可见三个工具入口；点击进入各子页并返回。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P1-8-W1 | Widget | ToolsScreen 含至少三个可点击入口（骰子、诗签、占卜） | pumpWidget ToolsScreen，find 三个入口（按文案或 Key）。 |
| P1-8-W2 | Widget | 点击骰子入口后跳转到 /tools/dice（或约定路径） | tap 骰子入口，验证 router 当前 location 或 find DiceScreen。 |
| P1-8-I1 | Integration | 从启动 → 进入工具页 → 进入骰子页 → 返回工具页，无崩溃 | 启动 app，导航 /tools，tap 骰子，pump，tap 返回，验证回到 ToolsScreen。 |

---

## P1-9：结果可复制与序列化一致性（可选）

**开发内容**  
- 各工具结果页可选「复制」按钮；复制内容格式由产品定稿后在各 spec 中记录。  
- 所有结果模型 toJson → fromJson 往返与原始对象一致（必要时忽略 DateTime 精度差异）。

**验收**  
复制功能（若实现）符合规格；单元测试已覆盖 toJson/fromJson 往返。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P1-9-U1 | Unit | 三种结果 toJson 后 fromJson 得到的对象与原始关键字段一致 | 各构造一个结果，toJson → fromJson，比较 type、主要业务字段。 |
| P1-9-W1 | Widget | 骰子结果页有复制按钮时，点击后剪贴板为约定格式（可选） | 若实现复制，tap 复制，读取剪贴板，断言包含 expression 与 total。 |

---

## 测试文件目录建议

```
test/
├── shared/
│   └── models/
│       └── tool_result_models_test.dart   # P1-1：DiceResult / PoemSlipResult / DivinationResult
├── features/
│   └── divination/
│       ├── domain/
│       │   ├── dice_parser_test.dart      # P1-2：表达式解析
│       │   ├── dice_roller_test.dart      # P1-2：掷骰
│       │   ├── poem_slip_service_test.dart # P1-4
│       │   └── divination_service_test.dart # P1-6
│       └── presentation/
│           ├── tools_screen_test.dart     # P1-8
│           ├── dice_screen_test.dart      # P1-3
│           ├── poem_slip_screen_test.dart # P1-5
│           └── tarot_screen_test.dart     # P1-7（或 divination_screen_test）
└── core/
    └── router/
        └── app_router_test.dart           # 补充 P1 子路由断言（P1-3-W3、P1-5-W3、P1-7-W3）
integration_test/
└── tools_flow_test.dart                   # P1-8-I1：工具页 → 骰子 → 返回
```

---

## 与 P1 交付清单的对应

| [p1_deliverables](project/p1_deliverables.md) 交付项 | 本文档任务 | 验收测试 |
|-----------------------------------------------------|------------|----------|
| 骰子 | P1-1、P1-2、P1-3 | P1-1-U1/U2，P1-2-U1～U5，P1-3-W1～W3 |
| 诗签 | P1-1、P1-4、P1-5 | P1-1-U3，P1-4-U1～U3，P1-5-W1～W3 |
| 简易占卜 | P1-1、P1-6、P1-7 | P1-1-U4，P1-6-U1～U3，P1-7-W1～W3 |
| 工具入口 | P1-8 | P1-8-W1/W2，P1-8-I1 |
| 结果数据结构 | P1-1、P1-9 | P1-1-U1～U4，P1-9-U1 |

---

*本文档随 P1 实现可增补具体测试代码片段或更新文件路径。*
