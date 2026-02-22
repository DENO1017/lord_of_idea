# 诗签功能规格（P1）

本文档约定 P1 阶段「诗签」工具的行为、数据来源与验收标准，与 [project_manager P1](../project/project_manager.md)、[工具结果模型](tool_result_models_spec.md) 一致。

---

## 1. 功能目标

- 用户可从诗签库中随机抽取一条签，展示文案。
- 支持至少一套默认诗签库；可配置/可换库（至少 1 套默认 + 换库能力）。
- 结果可序列化为 [PoemSlipResult](tool_result_models_spec.md#4-诗签结果poemslipresult)，便于 P2 插入手帐。

---

## 2. 诗签库（Library）

| 概念 | 说明 | 需填写/决策 |
|------|------|-------------|
| 库标识 | 唯一 ID；**命名规范**：小写字母+下划线（与 tool_result 一致）。**默认库 ID**：`poem_slip_mazu`（妈祖灵签）。 | — |
| 库内容 | 签条列表；每条含 slipId、content（及可选 extra）。**数据格式**：JSON；**存放路径**：`assets/poem_slips/{libraryId}.json`（如 `poem_slip_mazu.json`），便于按库扩展。 | — |
| 换库 | 用户可在多库间切换。**P1 预置库数量**：1 个；**库列表来源**：远程。 | — |

---

## 3. 抽签逻辑

- **随机**：从当前选中库中均匀随机选一条；随机源可注入（如服务接受 `Random` 或通过 Provider 注入），便于单测固定种子。
- **实现位置**：`features/divination/domain/services/poem_slip_service.dart`（或 `poem_slip_repository.dart` 负责加载 JSON，service 负责抽签）。
- **重复**：同一会话内**允许**连续抽到同一条（不限制重复）。

---

## 4. UI 与交互

| 项 | 说明 | 需填写/决策 |
|----|------|-------------|
| 入口 | 从「工具」页进入诗签子页；**路由**：`/tools/poem-slip`，**Screen**：`PoemSlipScreen`（见 [routes_spec](routes_spec.md)）。 | — |
| 选库 | 若有多库，提供库选择器。**默认选中库**：`poem_slip_mazu`（妈祖灵签）；**选择器样式**：下拉。 | — |
| 抽签 | 点击「抽签」后随机选一条并展示 content。 | — |
| 展示 | 展示签条正文（及可选 slipId、库名）。**再抽一次**：展示；**复制**：支持。 | — |
| 结果结构 | 生成 PoemSlipResult，含 libraryId、slipId、content、createdAt 等，见 [tool_result_models_spec](tool_result_models_spec.md#4-诗签结果poemslipresult)。 | — |

---

## 5. 默认诗签库数据（妈祖灵签）

- **数据文件路径**：`assets/poem_slips/poem_slip_mazu.json`。
- **内容来源**：妈祖灵签。
- **签条数量**：60 签（+签头）。
- **JSON 结构**：数组，每项含 `slipId`（字符串）、`content`（字符串），可选 `extra`（对象）。示例（第一签）：
```json
[
  { "slipId": "slip_001", "content": "日出便见风云散，光明清净照世间。一向前途通大道，万事清吉保平安。" }
]
```
- 其余签条按同一结构延续至第 60 签（及签头若单独建模），用于验收与文档。

---

## 6. 验收标准（与 project_manager 对齐）

- 可抽签并展示文案；可换库（至少 1 套默认）。  
- 结果可序列化为 PoemSlipResult，含 toJson()/fromJson()。

---

## 7. 需填写内容汇总（仅产品/体验相关）

- §2：P1 预置库 1 个，库列表来源远程。  
- §3：允许连续抽到同一条，不限制重复。  
- §4：默认选中库 `poem_slip_mazu`，选择器为下拉；有再抽一次与复制。  
- §5：默认库为妈祖灵签，60 签（+签头），示例第一签见上文。

---

*对应 [p1_deliverables](../project/p1_deliverables.md) 中「诗签」项。*
