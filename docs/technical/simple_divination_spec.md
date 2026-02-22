# 简易占卜规格（单张塔罗，P1）

本文档约定 P1 阶段「简易占卜」：单张塔罗抽取、正逆位与简明释义（本地数据），与 [project_manager P1](../project/project_manager.md)、[工具结果模型](tool_result_models_spec.md) 一致。

---

## 1. 功能目标

- 用户可进行单张塔罗抽牌，得到牌面、正/逆位与简明释义。
- 牌面与释义均为本地数据，无需网络。
- 结果可序列化为 [DivinationResult](tool_result_models_spec.md#5-占卜结果简易塔罗divinationresult)，便于 P2 插入手帐。

---

## 2. 牌组与牌面数据

| 项 | 说明 | 决策 |
|----|------|------|
| 牌组 | 至少一套塔罗牌组；**默认牌组 ID**：`rws`。**牌组名称展示**：采用应用内文案 l10n（如 key `deck_rws`），与当前语言一致。 | 应用内 l10n |
| 牌数量 | 标准 78 张全卡组（22 张大阿尔卡纳 + 56 张小阿尔卡纳）。 | **78 张** |
| 每张牌数据 | 含 cardId、cardName、正位释义、逆位释义；可选图片路径。**字段名**：`uprightMeaning`、`reversedMeaning`；多语言由牌组数据与 l10n 在展示层处理，结果存当前语言文案。 | — |
| 数据来源 | 本地 JSON；**路径**：`assets/tarot/rws.json`。**JSON 结构**：对象，key 为 cardId，值为牌数据；或数组，每项含 `cardId`、`cardName`、`uprightMeaning`、`reversedMeaning`，可选 `imagePath`。示例（数组）：`[{ "cardId": "rws_00", "cardName": "愚者", "uprightMeaning": "新的开始…", "reversedMeaning": "鲁莽…" }]`。 | — |

---

## 3. 正逆位

- 抽牌时随机决定正位或逆位（约 50%）；随机源可注入（服务接受 `Random` 或 Provider 注入），便于单测。
- **实现位置**：与抽牌逻辑同在 `features/divination/domain/services/divination_service.dart`（或 `tarot_service.dart`）。
- 展示时需明确标注「正位」或「逆位」，并展示对应释义。

---

## 4. 抽牌逻辑

- **抽牌模式**：支持两种玩法——**放回**（每次独立随机，可连续抽到同一张）与**不放回**（不重复直到牌组抽完）。交互上用**按钮或滑块**切换模式。
- 从当前牌组中按所选模式随机抽一张。
- 随机正/逆位。
- 生成 DivinationResult，含 deckId、cardId、cardName、reversed、meaning（根据 reversed 取正位或逆位释义）。

---

## 5. UI 与交互

| 项 | 说明 | 决策 |
|----|------|------|
| 入口 | 从「工具」页进入占卜子页；**路由**：`/tools/tarot`，**Screen**：`TarotScreen`（见 [routes_spec](routes_spec.md)）。 | — |
| 操作 | 点击「抽牌」触发一次单张抽牌；抽牌模式（放回/不放回）用**按钮或滑块**切换。 | — |
| 展示 | 牌名、正/逆位、释义；**展示牌面图**。**图片路径规则**：`assets/tarot/images/{cardId}.png`（与 cardId 一致，易扩展）。**支持复制**；复制格式：`{cardId}_{正逆}:{cardName} 正位/逆位`，其中正逆为数字（正位=0，逆位=1）。例：`rws_00_0:愚者 正位`。 | 牌图✓、复制✓、格式见上 |

---

## 6. 释义与本地数据

- 释义为简短文案（一两句话），非长文解读；**长度上限**：512 字符（与 tool_result_models_spec 一致），便于存储与展示。
- **释义来源**：公域资料。默认牌组 78 张的 cardId 列表及至少 3 张牌的示例数据见 **content/tarot/rws/**（`card_list.json`、`sample_cards.json`），用于验收与文档。

---

## 7. 验收标准（与 project_manager 对齐）

- 可抽牌并看到牌面与释义；正/逆位正确展示；牌面图可展示。
- 可通过按钮/滑块切换放回、不放回两种抽牌模式，行为符合所选模式。
- 支持复制结果，格式为 `{cardId}_{0|1}:{cardName} 正位/逆位`（例：`rws_00_0:愚者 正位`）。
- 结果可序列化为 DivinationResult，含 toJson()/fromJson()。

---

## 8. 需填写内容汇总（仅产品/体验相关）

- 无。牌组 78 张、cardId 列表与示例数据见 content/tarot/rws/。

---

*对应 [p1_deliverables](../project/p1_deliverables.md) 中「简易占卜」项。*
