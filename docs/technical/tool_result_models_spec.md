# 工具结果数据结构规格（与手帐块对齐）

本文档定义 P1 阶段骰子、诗签、简易占卜（塔罗）等工具产出的**可序列化结果模型**，与 P2 手帐「块」模型对齐，便于插入手帐并持久化。与 [架构指南](../project/architecture_guide.md)、[project_manager P1](../project/project_manager.md) 一致。

---

## 1. 设计原则

- **可序列化**：所有结果支持 `toJson()` / `fromJson()`（或等价），便于本地存储与后续同步。
- **与块类型一一对应**：手帐块类型（如 `BlockType.diceResult`、`BlockType.poemSlipResult`、`BlockType.divinationResult`）与本文档模型对应，P2 插入时直接包装为块 payload。
- **时间戳与元数据**：每条结果建议包含生成时间（便于排序与展示）、可选来源工具标识。

---

## 2. 通用结果基类 / 联合类型

**选型**：采用 **方案 A**（抽象基类），便于扩展新工具结果类型且实现简单；各具体结果继承并实现 `toJson()`。

**当前决策**：基类 `ToolResult` 定义于 `shared/models/tool_result.dart`，含抽象 getter `type`、字段 `createdAt`、抽象方法 `toJson()`。`type` 常量统一放在同一文件或 `shared/models/tool_result.dart` 的静态常量中：`dice`、`poem_slip`、`divination`。

| 字段/方法 | 类型 | 说明 |
|-----------|------|------|
| `type` | String | 固定值：`dice` \| `poem_slip` \| `divination`；常量名建议 `ToolResultType.dice` 或直接字符串字面量 |
| `createdAt` | DateTime | 生成时间；**存储格式**：序列化时转为 ISO8601 UTC 字符串（如 `toIso8601String()`），便于跨端与手帐块一致 |
| `toJson()` | Map<String, dynamic> | 可逆序列化；**约定**：所有子类 toJson 的顶层均包含 `type`、`createdAt`，便于 P2 块 payload 反序列化时先读 type 再分发 |

---

## 3. 骰子结果（DiceResult）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | String | 是 | 固定 `"dice"` |
| createdAt | DateTime | 是 | 同 §2 |
| expression | String | 是 | 用户输入的表达式，如 `"2d6+3"`；**约定**：最大长度 64 字符，合法字符为数字、字母 d、+、- |
| rolls | List<SingleRoll> | 是 | 每颗骰子的面数与结果；**单次掷骰最大颗数**：20 颗（兼顾常见用法与性能） |
| modifier | int | 否 | 表达式中的加减修正，如 `+3` → 3；**约定**：支持负值，取值范围 -999～+999 |
| total | int | 是 | 所有 rolls 结果之和 + modifier |

**SingleRoll**（单颗骰子一次掷出）：

| 字段 | 类型 | 说明 |
|------|------|------|
| faces | int | 面数（如 6） |
| value | int | 掷出点数（1..faces） |

**示例 JSON**：

```json
{
  "type": "dice",
  "createdAt": "2025-02-22T10:00:00.000Z",
  "expression": "2d6+3",
  "rolls": [{"faces": 6, "value": 4}, {"faces": 6, "value": 2}],
  "modifier": 3,
  "total": 12
}
```

**实现位置**：`shared/models/dice_result.dart`（与手帐块共用，便于 P2 插入；若希望 divination feature 完全内聚，可再抽一层接口在 shared，实现放在 feature）。

---

## 4. 诗签结果（PoemSlipResult）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | String | 是 | 固定 `"poem_slip"` |
| createdAt | DateTime | 是 | 同 §2 |
| libraryId | String | 是 | 诗签库唯一标识；**命名规范**：小写字母 + 下划线，如 `default`、`classic_poetry` |
| libraryName | String | 否 | 展示用名称；**约定**：结果中不冗余，由调用方根据 libraryId 做 l10n 或查表 |
| slipId | String | 是 | 签条在库内唯一 ID；**格式**：任意唯一字符串即可（如 `slip_001`、索引 `"0"`），便于扩展 |
| content | String | 是 | 签条正文；**P1 约定**：单段字符串；多段可用 `\n` 分隔，后续若需标题可扩展 extra 或单独字段 |
| extra | Map<String, dynamic>? | 否 | 扩展字段（如作者、出处）；**约定**：开放使用，key 建议小写+下划线（如 `author`、`source`） |

**示例 JSON**：

```json
{
  "type": "poem_slip",
  "createdAt": "2025-02-22T10:00:00.000Z",
  "libraryId": "default",
  "slipId": "slip_001",
  "content": "春眠不觉晓，处处闻啼鸟。"
}
```

**实现位置**：`shared/models/poem_slip_result.dart`。

---

## 5. 占卜结果（简易塔罗，DivinationResult）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| type | String | 是 | 固定 `"divination"` |
| createdAt | DateTime | 是 | 同 §2 |
| deckId | String | 是 | 牌组标识；**默认牌组 ID**：`rws`（伟特系，易扩展其他牌组） |
| cardId | String | 是 | 牌在牌组内唯一 ID；**命名**：`{deckId}_{序号}`，如 `rws_00`、`rws_01`，序号两位数字便于排序 |
| cardName | String | 是 | 牌名（如「愚者」）；**约定**：结果存当前语言的展示文案，插入手帐时所见即所得；多语言由牌组数据与 l10n 在展示层处理 |
| reversed | bool | 是 | 是否逆位 |
| meaning | String | 是 | 简明释义（正位或逆位对应文案）；**约定**：纯文本，长度上限 512 字符，P1 不支持富文本 |
| imagePathOrUrl | String? | 否 | 本地资源路径或占位 URL；**P1**：可选，不填则仅展示牌名与释义 |

**示例 JSON**：

```json
{
  "type": "divination",
  "createdAt": "2025-02-22T10:00:00.000Z",
  "deckId": "rws",
  "cardId": "rws_00",
  "cardName": "愚者",
  "reversed": false,
  "meaning": "新的开始，冒险与天真。"
}
```

**实现位置**：`shared/models/divination_result.dart`。

---

## 6. 与手帐块（Block）的对应关系（P2 参考）

P2 手帐「块」模型中将包含块类型与 payload。**约定**：块类型与结果 `type` 一致，使用字符串便于扩展新工具类型，无需改枚举。

| 工具结果类型 | 手帐块类型（字符串） | payload 内容 |
|--------------|----------------------|--------------|
| DiceResult | `dice` | DiceResult.toJson() |
| PoemSlipResult | `poem_slip` | PoemSlipResult.toJson() |
| DivinationResult | `divination` | DivinationResult.toJson() |

块模型中的 `id`、`order`、`journalPageId` 等由手帐层维护，不写入工具结果本身。

---

## 7. 需填写内容汇总（仅产品/体验相关）

- 无；技术约定已在上述各节补全。产品侧若有「结果中是否冗余 libraryName」「牌名存 key 还是文案」等偏好，可在实现时覆盖上述约定并在此记录。

---

*本文档对应 [p1_deliverables](../project/p1_deliverables.md) 中「结果数据结构」项。*
