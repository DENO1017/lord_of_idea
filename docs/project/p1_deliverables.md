# P1 工具先行：交付清单与文档索引

本文档对应 [project_manager](project_manager.md) 中的 **P1：工具先行**，列出每项交付内容、验收标准、相关文档位置，以及**需要填写或决策的内容**。

---

## 交付项与文档映射

| P1 交付项 | 验收标准 | 对应文档 | 需填写/决策项 |
|-----------|----------|----------|----------------|
| 骰子 | 可掷 d4/d6/d8/d10/d12/d20（仅标准面数），支持快捷与骰子盘、表达式（如 2d6+3）；结果可序列化 | [骰子规格](../technical/dice_spec.md)、[工具结果模型](../technical/tool_result_models_spec.md) | ✅ 已定稿 |
| 诗签 | 可抽签并展示文案；可换库（至少 1 套默认）；结果可序列化 | [诗签规格](../technical/poem_slip_spec.md)、[工具结果模型](../technical/tool_result_models_spec.md) | ✅ 已定稿 |
| 简易占卜 | 单张塔罗抽取 + 正逆位 + 简明释义（本地数据）；结果可序列化 | [简易占卜规格](../technical/simple_divination_spec.md)、[工具结果模型](../technical/tool_result_models_spec.md) | ✅ 已定稿 |
| 工具入口 | 首页或工具页集中入口，每个工具独立页；从首页可进入各工具并返回 | [路由规格](../technical/routes_spec.md)（P1 工具子路由）、本文档 § 工具入口 | ✅ 已定稿（卡片形式；l10n：toolDice、toolPoemSlip、toolTarot） |
| 结果数据结构 | 骰子/诗签/占卜结果的通用可序列化模型，与手帐块模型对齐 | [工具结果模型](../technical/tool_result_models_spec.md) | ✅ 已定稿 |

**任务拆解与测试用例**：见 [P1 开发任务拆解与测试用例](../development/p1_tasks_and_tests.md)。

---

## 需要填写的内容汇总（填写状态）

以下为各文档中「需填写」项的集中列表；**填写后请在对应文档中落实，并在本表勾选或更新状态**。

### 工具结果模型 — ✅ 已填写（技术约定）

- 通用基类（方案 A）、`type`/`createdAt`/`toJson`、实现位置、与 P2 块类型（字符串 `dice`/`poem_slip`/`divination`）已定稿，见 [tool_result_models_spec](../technical/tool_result_models_spec.md)。

### 骰子 — ✅ 已填写

- 技术：dN 仅标准面数 4/6/8/10/12/20、表达式单组 NdX+M、最大数量 20、modifier -999～+999、随机源与实现位置、路由 `/tools/dice`、Screen `DiceScreen`。
- 产品/体验：快捷按钮、骰子盘与珠子、解析失败弹框与 l10n key `INVALID_DICE`、复制格式（表达式=总和）、会话历史 100 条及舍弃/重 Roll 规则，均已写入 [dice_spec](../technical/dice_spec.md)。

### 诗签 — ✅ 已填写

- 技术：默认库 ID `poem_slip_mazu`、路径 `assets/poem_slips/{libraryId}.json`、抽签服务实现位置、路由 `/tools/poem-slip`、Screen `PoemSlipScreen`、JSON 结构。
- 产品/体验：预置库 1 个、允许连续重复、默认选中库与下拉选择器、再抽一次与复制、妈祖灵签 60 签及示例，均已写入 [poem_slip_spec](../technical/poem_slip_spec.md)。

### 简易占卜 — ✅ 已填写

- 技术：默认牌组 `rws`、78 张、字段名、数据路径 `assets/tarot/rws.json`、实现位置、释义长度 512、路由 `/tools/tarot`、Screen `TarotScreen`、图片路径规则。
- 产品/体验：牌组名称 l10n、放回/不放回模式、牌面图与复制格式、释义来源与示例数据（见 content/tarot/rws/），均已写入 [simple_divination_spec](../technical/simple_divination_spec.md)。

### 工具入口与路由 — ✅ 已填写

- 已定稿：子路由 `/tools/dice`、`/tools/poem-slip`、`/tools/tarot` 及对应 `DiceScreen`、`PoemSlipScreen`、`TarotScreen`（见 [routes_spec](../technical/routes_spec.md)）。
- **已决策**：工具聚合页（ToolsScreen）入口 UI 使用**卡片形式**；l10n key：`toolDice`、`toolPoemSlip`、`toolTarot`。

---

## P1 完成检查

- [ ] 骰子：支持 d4～d20 及自定义面数，支持表达式（如 2d6+3），结果可序列化为 DiceResult。
- [ ] 诗签：至少 1 套默认库，可抽签、可换库，结果可序列化为 PoemSlipResult。
- [ ] 简易占卜：单张塔罗 + 正逆位 + 释义（本地数据），结果可序列化为 DivinationResult。
- [ ] 工具入口：从首页或工具页可进入骰子/诗签/占卜各子页并返回。
- [ ] 结果数据结构：三种结果模型已实现且与 [tool_result_models_spec](../technical/tool_result_models_spec.md) 一致，便于 P2 插入手帐。
- [x] 所有「需填写」项已在对应文档中填写或定稿（见上文各节）。

---

*本文档随 P1 推进更新勾选与需填写汇总。*
