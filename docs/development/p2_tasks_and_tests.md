# P2 开发任务拆解与测试用例

本文档将 [P2 手帐核心](project/p2_deliverables.md) 拆解为可执行的开发任务，并为每条任务撰写对应的测试用例。测试类型包括：**单元测试（Unit）**、**Widget 测试（Widget）**、**集成测试（Integration）**。实现时可将用例落地到 `test/` 下对应文件。

---

## 任务与测试索引

| 任务编号 | 开发内容概要 | 测试类型 | 测试文件建议 |
|----------|--------------|----------|--------------|
| P2-1 | 手帐/页面/块数据模型与 drift 表定义、迁移 | Unit | `test/features/journal/data/local/journal_database_test.dart`、`test/shared/models/journal_models_test.dart` |
| P2-2 | JournalRepository 与手帐/页/块 CRUD | Unit | `test/features/journal/domain/repositories/journal_repository_test.dart` |
| P2-3 | 手帐列表页（JournalListScreen）与创建/删除 | Widget | `test/features/journal/presentation/journal_list_screen_test.dart` |
| P2-4 | 手帐详情/阅读视图（按页展示块、块类型展示） | Widget + Unit | `test/features/journal/presentation/journal_detail_screen_test.dart`、块解析单元测试 |
| P2-5 | 块编辑（添加文本块、插入工具结果、块排序） | Unit + Widget | `test/features/journal/domain/block_editor_test.dart`、详情页内块编辑 Widget 测试 |
| P2-6 | 手帐编辑态工具栏调用工具并插入（历史选择/现场使用） | Widget + Integration | `test/features/journal/presentation/journal_toolbar_insert_test.dart`、`integration_test/journal_insert_flow_test.dart` |
| P2-7 | 路由 /journal、/journal/:id、/journal/:id/page/:pageId 与守卫 | Widget / Unit | `test/core/router/app_router_test.dart`（扩展） |
| P2-8 | 手帐列表数据范围（本地+共享）与按时间排序 | Unit + Widget | `test/features/journal/domain/repositories/journal_repository_test.dart`、`journal_list_screen_test.dart` |

---

## P2-1：手帐/页面/块数据模型与 drift 表

**开发内容**  
- 按 [journal_data_models_spec](../technical/journal_data_models_spec.md) 实现实体：`Journal`、`JournalPage`、`JournalBlock`，位于 `shared/models/`（或 `features/journal/domain/entities/`）。  
- drift 表：`journals`、`journal_pages`、`journal_blocks`，主键 id，索引 journalId/pageId；初始 schema version 1，迁移策略可设为 `MigrationStrategy.dontCreateThenMigrate` 或按需。  
- 块 payload 存储为 TEXT（JSON 字符串）；从 DB 读出行后能还原为带 type 与 payload 的 Block 模型。

**验收**  
可插入/查询手帐、页、块；块 type 与 payload 与 P1 工具结果 toJson 一致时可正确写入与读出。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P2-1-U1 | Unit | Journal 含 id、title、createdAt、updatedAt；toJson/fromJson 往返 | 构造 Journal，toJson 后 fromJson，关键字段一致。 |
| P2-1-U2 | Unit | JournalPage 含 journalId、orderIndex；同 journalId 下 orderIndex 唯一语义 | 构造 Page，写入 DAO 后按 journalId 查询得到且 order 正确。 |
| P2-1-U3 | Unit | JournalBlock 含 pageId、type、orderIndex、payload；type 为 text 时 payload 为 {"content":"..."} | 构造 text 块与 dice 块，写入后读出，type 与 payload 解析正确。 |
| P2-1-U4 | Unit | 块 payload 为 DiceResult.toJson() 时，读出并解析为 DiceResult 与写入前一致 | 用 P1 DiceResult 写入块，从 DB 读出 payload 再 DiceResult.fromJson，字段一致。 |
| P2-1-U5 | Unit | drift 迁移：创建库后插入一条手帐、一页、一块，重启后仍可查询 | 内存或文件 DB，插入后关闭再打开，查询到相同数据。 |

---

## P2-2：JournalRepository 与手帐/页/块 CRUD

**开发内容**  
- 定义 `JournalRepository` 接口（如 `getAllJournals`、`getJournalById`、`createJournal`、`updateJournal`、`deleteJournal`；页与块的 CRUD 同理），位于 `features/journal/domain/repositories/journal_repository.dart`。  
- 实现类使用 drift DAO，位于 `features/journal/data/repositories/journal_repository_impl.dart`。  
- 手帐创建时自动创建第一页（orderIndex 0）；删手帐时级联删页与块（或由 DB 外键 + 级联删除保证）。

**验收**  
通过 Repository 完成手帐/页/块的全套 CRUD；列表按 updatedAt 或 createdAt 排序；页按 orderIndex 排序；块按 orderIndex 排序。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P2-2-U1 | Unit | createJournal 返回新 Journal 且 DB 中可查；默认带一页 | createJournal，getJournalById 得到该手帐，getPages 得到 1 页且 orderIndex=0。 |
| P2-2-U2 | Unit | updateJournal 更新 title/updatedAt | updateJournal(title: '新标题')，再 get 得到新标题且 updatedAt 已更新。 |
| P2-2-U3 | Unit | deleteJournal 后 getJournalById 为空或抛；其页与块均不可见 | deleteJournal(id)，getJournalById 返回 null 或抛，getBlocks(pageId) 为空。 |
| P2-2-U4 | Unit | addPage 在指定手帐下追加页，orderIndex 递增 | addPage(journalId)，两次 addPage，得到两页 orderIndex 0、1。 |
| P2-2-U5 | Unit | addBlock 在指定页追加块；reorderBlocks 可更新块顺序 | addBlock(pageId, block)，再 addBlock，两块 order 0、1；reorderBlocks 后顺序改变。 |

---

## P2-3：手帐列表页（JournalListScreen）与创建/删除

**开发内容**  
- 实现 `JournalListScreen`：使用 **卡片网格** 展示手帐，每项展示 **封面** 与 **标题**；支持「创建手账」按钮（l10n key `createJournal`）、点击进入手帐详情、删除手帐（含确认）。  
- 路由 `/journal` 解析为 JournalListScreen；列表数据来自 JournalRepository（通过 Provider）。  
- **空状态**：无手帐时仅展示「创建手账」按钮（l10n `createJournal`），不展示长段占位文案。  
- **创建手帐**：点击创建后先弹输入框输入标题，确认后再创建并进入该手帐首页；未输入时使用 l10n `journalDefaultTitle`（如「未命名手账」）。详见 [p2_deliverables](project/p2_deliverables.md)。

**验收**  
从主导航进入 /journal 可见手帐卡片网格（封面+标题）；空状态仅显示创建按钮；可先输入标题再创建手帐并进入；可删除手帐（确认后消失）。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P2-3-W1 | Widget | JournalListScreen 含「创建手账」按钮（createJournal）与网格区域 | pumpWidget（提供 Repository mock），find 创建按钮与网格/列表。 |
| P2-3-W2 | Widget | 列表为空时仅展示创建按钮，无长段占位文案 | mock 空列表，find 创建按钮，不依赖 journalListEmpty 长文案。 |
| P2-3-W3 | Widget | 列表有数据时以卡片形式展示封面与标题 | mock 1 条手帐，find 该手帐标题及封面展示。 |
| P2-3-W4 | Widget | 点击手帐项跳转至 /journal/:id | tap 第一项，验证 router 当前路径为 /journal/{id}。 |
| P2-3-W5 | Widget | 路由 /journal 解析为 JournalListScreen | go('/journal')，find.byType(JournalListScreen)。 |
| P2-3-W6 | Widget | 点击创建后先弹标题输入框，确认后创建并进入手帐 | tap 创建，find 输入框；输入标题确认后，验证进入 /journal/{新id}。 |

---

## P2-4：手帐详情/阅读视图（按页展示块、块类型展示）

**开发内容**  
- 实现 `JournalDetailScreen`：支持按页切换，**页签展示为「N/Sum」**（如 7/10 表示当前第 7 页共 10 页）；当前页展示块列表。块按 type 渲染：text 为纯文本，dice/poem_slip 为技术默认（表达式+结果/全文），**占卜块仅展示牌图且正逆位正确**；**空页不显示占位文案**。  
- 路由 `/journal/:id`、`/journal/:id/page/:pageId`；无效 id 时重定向到 `/journal`（见 [routes_spec](../technical/routes_spec.md)）。  
- 块列表从 Repository 按 pageId 拉取，按 orderIndex 排序。详见 [p2_deliverables](project/p2_deliverables.md)。

**验收**  
打开手帐可切换页，页签为 N/Sum 形式；每页块按顺序展示；文本/骰子/诗签块按技术默认；占卜块仅牌图且正逆正确；空页无占位文案。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P2-4-W1 | Widget | JournalDetailScreen 展示当前页的块列表 | mock 一页两块（text + dice），pumpWidget，find 文本内容与骰子相关展示。 |
| P2-4-W2 | Widget | 页签展示为 N/Sum 形式，切换页签后展示对应页的块 | 两页，find 页签含「1/2」等；切换后 find 对应块内容。 |
| P2-4-W3 | Widget | 占卜块仅展示牌图（正逆正确）；空页无占位文案 | mock 一页含 divination 块，find 牌图无牌名/释义；空页不 find journalPageEmpty。 |
| P2-4-W4 | Widget | 路由 /journal/:id 解析为 JournalDetailScreen 且 id 传入 | go('/journal/abc')，find JournalDetailScreen，验证传入 id=abc。 |
| P2-4-W5 | Widget | 无效 journal id 时重定向到 /journal | go('/journal/invalid-id')，pump，验证当前路径为 /journal 或 find JournalListScreen。 |
| P2-4-U1 | Unit | 块 payload 解析：type=dice 时 DiceResult.fromJson(payload) 不抛 | 给定合法 dice payload 字符串，解析得到 DiceResult。 |

---

## P2-5：块编辑（添加文本块、插入工具结果、块排序）

**开发内容**  
- 手帐 **编辑模式** 下：**横版** 在 **右侧**、**竖版** 在 **上侧** 显示工具栏；工具栏内提供骰子/诗签/占卜入口，支持 (1) 从工具历史选择结果插入 (2) 现场使用工具后直接插入当前页。另支持添加文本块、块长按拖拽或上移/下移排序。  
- 添加文本块：「添加块」→ 弹输入框或内联输入 → 提交后 appendBlock。  
- 插入工具结果：将 DiceResult/PoemSlipResult/DivinationResult.toJson() 作为 payload，type 取对应字符串，写入 Block 并刷新列表。  
- **独立工具页**（如 /tools/dice）**不提供**「插入到手帐」功能，仅手帐编辑态工具栏提供。详见 [p2_deliverables](project/p2_deliverables.md)。

**验收**  
编辑态下横版右侧/竖版上侧有工具栏；可从工具栏调用工具（历史或现场）并插入块；可添加文本块与调整块顺序并持久化。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P2-5-U1 | Unit | appendTextBlock(pageId, content) 在页尾追加 type=text 的块 | 调用 appendTextBlock，getBlocks 得到新块，payload 含 content。 |
| P2-5-U2 | Unit | insertToolResultBlock(pageId, DiceResult) 写入 type=dice、payload=toJson() | insert 后读出块，type 为 dice，DiceResult.fromJson(payload) 与原文一致。 |
| P2-5-W1 | Widget | 详情页有「添加文本块」或「添加块」入口 | pumpWidget JournalDetailScreen（编辑模式），find 添加块按钮。 |
| P2-5-W2 | Widget | 添加文本块后列表中可见新块内容 | 触发添加并输入「测试」，pump，find 包含「测试」。 |
| P2-5-W3 | Widget | 块支持拖拽或上移/下移后顺序改变（可选验证持久化） | 两块的详情页，拖拽或点下移，pump，顺序与之前不同；或重新进入页验证顺序已保存。 |

---

## P2-6：手帐编辑态工具栏调用工具并插入（历史选择/现场使用）

**开发内容**  
- **仅在手帐编辑模式**下，横版右侧/竖版上侧工具栏提供骰子、诗签、占卜入口。用户可：(1) 从**工具历史**选择已有结果插入当前页；(2) **现场使用工具**（弹窗或内联）得到结果后直接插入。  
- 插入逻辑：在当前页追加块，payload 为工具结果 toJson()，type 为 dice/poem_slip/divination。  
- **独立工具页**（/tools/dice、/tools/poem-slip、/tools/tarot）**不提供**插入到手帐的按钮。详见 [p2_deliverables](project/p2_deliverables.md)。

**验收**  
手帐编辑态下可见工具栏及工具入口；可从历史选择结果插入或现场调用工具插入；独立工具页无插入手帐入口。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P2-6-W1 | Widget | 手帐编辑态下横版显示右侧工具栏（或竖版上侧），含骰子/诗签/占卜入口 | 进入手帐编辑，根据横竖屏 find 工具栏及工具按钮。 |
| P2-6-W2 | Widget | 从工具栏选择历史结果插入后，当前页块数+1 且为对应类型块 | mock 工具历史有一条骰子结果，在编辑态选该结果插入，验证该页多一块 type=dice。 |
| P2-6-W3 | Widget | 从工具栏现场调用工具（如掷骰）得到结果插入后，当前页块数+1 | 编辑态点骰子入口，掷骰后插入，验证该页多一块 type=dice。 |
| P2-6-W4 | Widget | 独立工具页（如 /tools/dice）无「插入手帐」按钮 | pumpWidget DiceScreen，不应 find 插入手帐相关按钮。 |
| P2-6-I1 | Integration | 进手帐编辑 → 工具栏调用骰子并插入 → 当前页可见骰子块 | 打开手帐进入编辑，通过工具栏掷骰并插入，find 该页骰子块展示。 |

---

## P2-7：路由与守卫

**开发内容**  
- 在 go_router 中确保 `/journal`、`/journal/:id`、`/journal/:id/page/:pageId` 已注册并解析到 JournalListScreen、JournalDetailScreen（见 [routes_spec](../technical/routes_spec.md)）。  
- 守卫：访问不存在的 `journal/:id` 时重定向到 `/journal`；可选 `journal/:id/page/:pageId` 中 pageId 无效时跳转到该手帐第一页。

**验收**  
深链可打开指定手帐、指定页；无效 id 不崩溃并重定向到列表。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P2-7-W1 | Widget | go('/journal') 显示 JournalListScreen | go('/journal')，find.byType(JournalListScreen)。 |
| P2-7-W2 | Widget | go('/journal/xyz') 显示 JournalDetailScreen 且 id=xyz | go('/journal/xyz')，find JournalDetailScreen，验证 id。 |
| P2-7-W3 | Widget | go('/journal/xyz/page/pid') 显示详情且 pageId=pid | go('/journal/xyz/page/pid')，验证详情页接收 pageId 并展示对应页。 |
| P2-7-W4 | Widget | 不存在的 journal id 重定向到 /journal | mock 无 id=bad 的手帐，go('/journal/bad')，验证重定向到 /journal。 |

---

## P2-8：手帐列表数据范围（本地+共享）与按时间排序

**开发内容**  
- 手帐列表页（JournalListScreen）数据来源包含 **本地手账** 与 **共享手账**，二者均在同一列表中展示（见 [p2_deliverables](project/p2_deliverables.md)、[主壳规格](../design/main_shell_spec.md)）。  
- 列表 **按时间顺序** 排布（如按最后修改时间 `updatedAt` 或创建时间 `createdAt` 倒序）；Repository 的 `getAllJournals`（或等价接口）返回合并后的列表并已排序。  
- 若 P2 阶段共享手帐数据尚未接入，可先仅展示本地手帐，接口预留「本地+共享」合并与排序语义，待 P4 接入共享数据后填充。

**验收**  
手账页内展示的手帐列表为本地+共享（或仅本地时接口已支持合并）；列表按时间倒序；卡片网格展示不变。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P2-8-U1 | Unit | getAllJournals（或列表查询接口）返回结果按时间字段倒序 | mock 或插入多条手帐（不同 updatedAt），调用列表接口，断言顺序为时间倒序。 |
| P2-8-U2 | Unit | 列表数据来源包含本地手帐；若已实现共享手帐数据源，合并后去重且排序一致 | 本地 2 条、共享 1 条（或 mock），列表含 3 条且按时间排序；或仅本地时返回 2 条且排序正确。 |
| P2-8-W1 | Widget | JournalListScreen 展示的列表按时间顺序（最新在前） | mock Repository 返回有序列表 [A(新), B(旧)]，pumpWidget，find 第一张卡片为 A 的标题。 |

---

## 测试文件目录建议

```
test/
├── shared/
│   └── models/
│       └── journal_models_test.dart       # P2-1：Journal / JournalPage / JournalBlock 模型
├── features/
│   └── journal/
│       ├── data/
│       │   └── local/
│       │       └── journal_database_test.dart   # P2-1：drift 表与迁移
│       ├── domain/
│       │   ├── repositories/
│       │   │   └── journal_repository_test.dart # P2-2
│       │   └── block_editor_test.dart           # P2-5 部分
│       └── presentation/
│           ├── journal_list_screen_test.dart    # P2-3
│           ├── journal_detail_screen_test.dart  # P2-4、P2-5 部分
│           └── journal_toolbar_insert_test.dart # P2-6：编辑态工具栏插入
├── core/
│   └── router/
│       └── app_router_test.dart           # P2-7 扩展
integration_test/
└── journal_insert_flow_test.dart          # P2-6-I1
```

---

## 与 P2 交付清单的对应

| [p2_deliverables](project/p2_deliverables.md) 交付项 | 本文档任务 | 验收测试 |
|-----------------------------------------------------|------------|----------|
| 数据模型 | P2-1 | P2-1-U1～U5 |
| 手帐 CRUD | P2-2、P2-3 | P2-2-U1～U5，P2-3-W1～W6 |
| 手帐列表（本地+共享、按时间） | P2-8 | P2-8-U1/U2，P2-8-W1 |
| 块编辑 | P2-5、P2-6 | P2-5-U1/U2，P2-5-W1～W3，P2-6-W1～W4、I1 |
| 基础展示 | P2-4 | P2-4-W1～W5，P2-4-U1 |
| 路由与导航 | P2-7 | P2-7-W1～W4 |

---

*本文档随 P2 实现可增补具体测试代码片段或更新文件路径。*
