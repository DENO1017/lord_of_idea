# 手帐数据模型规格（P2）

本文档约定 P2 阶段「手帐核心」的本地数据模型：手帐、页面、块的结构、存储方式及与 P1 工具结果的对应关系。与 [project_manager P2](../project/project_manager.md)、[工具结果模型](tool_result_models_spec.md)、[架构指南](../project/architecture_guide.md) 一致。

---

## 1. 设计原则

- **块类型与 P1 结果一一对应**：块类型字符串 `text`、`dice`、`poem_slip`、`divination` 与 [tool_result_models_spec](tool_result_models_spec.md) 中 `type` 一致；工具结果插入时直接作为块 payload，无需二次转换。
- **可扩展**：新增块类型（如后续装饰块、图片块）时，仅增加类型常量与 payload 结构，不破坏现有块查询与展示。
- **本地优先**：P2 仅本地持久化，表结构预留可选字段（如 `syncedAt`、`serverId`）便于 P4 同步扩展，当前可为空或忽略。

---

## 2. 实体关系概览

```
Journal (手帐) 1 ---- N Page (页面)
Page (页面)   1 ---- N Block (块)
```

- 一个手帐包含多个页面，页面有顺序。
- 一个页面包含多个块，块有顺序；块类型决定 payload 结构。

---

## 3. 手帐（Journal）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | 是 | 本地唯一 ID；**生成方式**：UUID v4 或 nanoid，保证本地唯一即可 |
| title | String | 是 | 手帐标题；**默认值**：l10n key `journalDefaultTitle`（如「未命名手账」），见 [p2_deliverables](../project/p2_deliverables.md) |
| createdAt | DateTime | 是 | 创建时间；存储为 ISO8601 UTC 字符串 |
| updatedAt | DateTime | 是 | 最后更新时间；新建时等于 createdAt，任何本手帐或下属页/块变更时更新 |
| coverPath | String? | 否 | P2 可不实现；P3 装饰/封面可写此处 |

**约束**：`title` 长度建议上限 200 字符（产品可定）。

**实现位置**：`shared/models/journal.dart`（或 `features/journal/domain/entities/journal.dart` 若希望完全内聚；推荐放 shared 便于 P4 共享手帐复用）。

---

## 4. 页面（Page）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | 是 | 本地唯一 ID；生成方式同 Journal |
| journalId | String | 是 | 所属手帐 ID，外键 |
| title | String? | 否 | 可选页标题；**默认展示**：页签采用「N/Sum」形式（如 7/10 表示当前第 7 页共 10 页），见 [p2_deliverables](../project/p2_deliverables.md) |
| orderIndex | int | 是 | 页在该手帐内的顺序，从 0 起递增；插入新页时取当前 max+1 |
| createdAt | DateTime | 是 | 创建时间，ISO8601 UTC |

**约束**：同一 `journalId` 下 `orderIndex` 唯一；删页后可选重排 orderIndex 或留空位，实现时统一策略即可（建议删后重排 0..n-1）。

**实现位置**：`shared/models/journal_page.dart`。

---

## 5. 块（Block）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | 是 | 本地唯一 ID，生成方式同 Journal |
| pageId | String | 是 | 所属页面 ID，外键 |
| type | String | 是 | 块类型：`text` \| `dice` \| `poem_slip` \| `divination`；与 [tool_result_models_spec](tool_result_models_spec.md) §6 一致 |
| orderIndex | int | 是 | 块在页内顺序，从 0 起递增 |
| payload | String | 是 | JSON 字符串；内容见下表「按类型的 payload」 |
| createdAt | DateTime | 是 | 创建时间，ISO8601 UTC |

**按类型的 payload**：

| type | payload 内容 | 说明 |
|------|----------------------|------|
| text | `{"content": "纯文本内容"}` | P2 仅纯文本；P3 可扩展为富文本 JSON 或 Delta |
| dice | DiceResult.toJson() | 与 [DiceResult](tool_result_models_spec.md#3-骰子结果diceresult) 一致，整段作为 payload |
| poem_slip | PoemSlipResult.toJson() | 同 [PoemSlipResult](tool_result_models_spec.md#4-诗签结果poemslipresult) |
| divination | DivinationResult.toJson() | 同 [DivinationResult](tool_result_models_spec.md#5-占卜结果简易塔罗divinationresult) |

**约束**：同一 `pageId` 下 `orderIndex` 唯一；删块后建议重排。`payload` 存储为 JSON 字符串，便于 drift 用 `TEXT` 列存储且与 Dart `Map<String, dynamic>` 互转。

**实现位置**：`shared/models/journal_block.dart`；payload 解析可放在 domain 层或 block 的 factory 方法中（如 `Block.fromRow()` 内根据 type 解析 payload 为具体类型）。

---

## 6. 本地存储与迁移

- **选型**：采用 **drift**（原 moor）作为 SQLite 封装，支持类型安全、迁移、流式查询。
- **实现位置**：`lib/features/journal/data/local/` 下放置数据库定义与 DAO（如 `journal_database.dart`、`journal_dao.dart`、`page_dao.dart`、`block_dao.dart`）；Repository 实现位于 `features/journal/data/repositories/`，对外暴露 `JournalRepository` 接口，定义于 `features/journal/domain/repositories/journal_repository.dart`。
- **表名**：`journals`、`journal_pages`、`journal_blocks`；主键均为 `id`，索引建议：`journal_pages(journal_id)`、`journal_blocks(page_id)`、按需 `journal_blocks(page_id, order_index)` 以优化按页按序拉取。
- **迁移**：初始 schema 为 1；后续增列或增表时递增 version 并在 `MigrationStrategy` 中编写 step，保证升级不丢数据。

---

## 7. 与 P1 工具结果的转换

- **插入块**：从工具页「插入到当前手帐」或手帐内调用工具时，将 `DiceResult`/`PoemSlipResult`/`DivinationResult` 的 `toJson()` 转为 JSON 字符串写入 `Block.payload`，`Block.type` 取结果的 `type` 字段（`dice`/`poem_slip`/`divination`）。
- **读取块**：根据 `Block.type` 将 `payload` 解析为对应模型：`DiceResult.fromJson()`、`PoemSlipResult.fromJson()`、`DivinationResult.fromJson()`；若 type 未知则按文本或占位展示，不抛错以便向前兼容。

---

## 8. 与产品约定的对应

- 手帐默认标题、页面默认展示（N/Sum）、列表形式与展示信息、插入入口与块展示等均已定稿，见 [p2_deliverables](../project/p2_deliverables.md)。

---

*本文档对应 [p2_deliverables](../project/p2_deliverables.md) 中「数据模型」项。*
