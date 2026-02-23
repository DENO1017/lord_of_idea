# 富文本与解读书写规格（P3）

本文档约定 P3 阶段「手帐增强」中**富文本**与**解读**的数据结构、存储方式及与现有块模型的扩展关系。与 [project_manager P3](../project/project_manager.md)、[手帐数据模型](journal_data_models_spec.md)、[p3_deliverables](../project/p3_deliverables.md) 一致。

---

## 1. 设计原则

- **向后兼容**：P2 文本块 payload `{"content": "纯文本"}` 仍有效；P3 可识别「无格式标记」的 content 按纯文本展示。
- **易扩展**：富文本采用 **Markdown 子集** 存储（加粗、斜体、行内代码），便于日后扩展为完整 Markdown 或 Quill Delta。
- **解读与块绑定**：占卜/骰子/诗签块的解读与块一一对应，存储上可放在块 payload 内或独立「解读块」；本规格采用 **payload 内字段** 以简化查询与导出。

---

## 2. 文本块富文本（text 块）

**存储格式**：仍使用 `type: "text"`，payload 扩展为以下两种之一，**兼容 P2**。

| 方案 | payload 结构 | 说明 |
|------|----------------------|------|
| 纯文本（P2 兼容） | `{"content": "纯文本内容"}` | 无格式，与 P2 一致 |
| 富文本（P3） | `{"content": "支持 **加粗**、*斜体*、`代码` 的 Markdown 子集", "format": "markdown"}` | 可选 `format`，缺省视为纯文本 |

**Markdown 子集约定**（首版易实现、易扩展）：

- 支持：`**加粗**`、`*斜体*`、`` `行内代码` ``。
- 可选扩展：`\n` 换行、`## 标题`（若产品需要）。
- 实现方式：使用 `flutter_markdown` 或自研简单正则解析；存储层仅存字符串，不存 AST。

**约束**：`content` 长度建议上限与 P2 一致（如 10000 字符）；产品可定。

**实现位置**：  
- 解析/渲染：`lib/features/journal/` 下 widget 或 `shared/widgets/` 中「富文本展示组件」；  
- 编辑：手帐编辑态下文本块使用 `TextField` + 工具栏（加粗/斜体/代码）或简单 Markdown 编辑区。

---

## 3. 工具结果块的解读（dice / poem_slip / divination）

**绑定方式**：解读与「该块」一一对应，存储在**块 payload 内**，不新增块类型，便于导出与同步。

**payload 扩展**（在现有 DiceResult / PoemSlipResult / DivinationResult 的 toJson 上**不破坏**；解读单独存）：

- **方案 A（推荐）**：块表不变，payload 仍为工具结果 toJson()；**同一 page 上**在工具块后紧跟一个「解读块」`type: "interpretation"`，payload 为 `{"targetBlockId": "被解读的块 id", "content": "解读内容", "format": "markdown"}`。  
  - 优点：不改 P1 结果模型，不改已有块 payload；解读可富文本。  
  - 实现：展示时按 orderIndex 顺序，遇到 `interpretation` 块则挂到前一个或 targetBlockId 指向的块上显示。
- **方案 B**：在工具结果块 payload 内增加可选字段 `interpretation?: string`（纯文本或 Markdown 字符串）。  
  - 优点：无需新块类型，查询简单。  
  - 缺点：需扩展 P1 三个结果类的 toJson/fromJson（或仅在「插入手帐」时包装一层带 interpretation 的 payload）。

**本规格采用方案 A**：新增块类型 `interpretation`，payload 为 `{"targetBlockId": "uuid", "content": "解读内容", "format": "markdown"}`；同一页内「工具块」与「解读块」顺序相邻，展示时合并显示。若产品要求解读与块「强绑定不拆开」，可采用方案 B 并在本文档中替换说明。

**interpretation 块 payload**：

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| targetBlockId | String | 是 | 被解读的块 id（同页内 dice/poem_slip/divination 块） |
| content | String | 是 | 解读正文；支持与文本块相同的 Markdown 子集 |
| format | String | 否 | 固定 `"markdown"` 或省略（按纯文本展示） |

**展示**：阅读/编辑时，工具块下方可展示其对应的 interpretation 块（通过 targetBlockId 或 orderIndex 推断）；**入口与交互由产品定**，见 [p3_deliverables](../project/p3_deliverables.md)。

**实现位置**：  
- 块类型常量：在 `journal_data_models_spec` 或 `shared/models/journal_block.dart` 中增加 `type == "interpretation"`；  
- 增删解读：在 `JournalRepository` 或 BlockEditor 中提供 `addInterpretationBlock(pageId, targetBlockId, content)`、`updateInterpretation(blockId, content)`。

---

## 4. 与手帐数据模型的衔接

- **块类型**：在 [journal_data_models_spec](journal_data_models_spec.md) 的 Block type 中增加 `interpretation`；payload 见上文。  
- **迁移**：若 drift 表仅用 `type` + `payload` 存块，无需改表结构；若存在块类型枚举，需增加 `interpretation`。  
- **导出**：导出单页/整本时，解读块随页一起渲染在对应工具块下方。

---

## 5. 需要产品填写的内容（汇总）

- 解读**入口与位置**（块下折叠区、右侧按钮、长按菜单等）。  
- 文本块**富文本范围**（仅加粗/斜体/代码，或增加列表、标题等）。  
- 解读区域是否与文本块**同富文本能力**。  
- 相关 **l10n** key 与默认文案。  

详见 [p3_deliverables § 富文本/解读书写](../project/p3_deliverables.md#富文本解读书写--待产品填写)。

---

*本文档对应 [p3_deliverables](../project/p3_deliverables.md) 中「富文本/解读书写」项。*
