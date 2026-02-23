# P3 开发任务拆解与测试用例

本文档将 [P3 手帐增强](project/p3_deliverables.md) 拆解为可执行的开发任务，并为每条任务撰写对应的测试用例。测试类型包括：**单元测试（Unit）**、**Widget 测试（Widget）**、**集成测试（Integration）**。实现时可将用例落地到 `test/` 下对应文件。

---

## 任务与测试索引

| 任务编号 | 开发内容概要 | 测试类型 | 测试文件建议 |
|----------|--------------|----------|--------------|
| P3-1 | 文本块富文本 payload 与 Markdown 子集解析/渲染 | Unit + Widget | `test/features/journal/domain/rich_text_parser_test.dart`、块展示 Widget 测试 |
| P3-2 | 解读块（interpretation）数据模型与 CRUD | Unit | `test/features/journal/domain/interpretation_block_test.dart`、journal_repository_test 扩展 |
| P3-3 | 手帐内解读入口与解读块展示/编辑 | Widget | `test/features/journal/presentation/journal_interpretation_test.dart` |
| P3-4 | 装饰模型与 drift 表、DecorationRepository | Unit | `test/features/journal/data/local/decoration_database_test.dart`、decoration_repository_test.dart |
| P3-5 | 装饰选择器与页上添加/拖拽/缩放/删除 | Widget + Integration | `test/features/journal/presentation/journal_decoration_test.dart`、integration_test 可选 |
| P3-6 | 内页主题（PageTheme）配置与手帐/页应用 | Unit + Widget | `test/features/journal/domain/page_theme_test.dart`、详情页主题应用 Widget 测试 |
| P3-7 | 单页导出为 PNG、整本导出为 PDF/PNG | Unit + Widget | `test/features/journal/domain/export_service_test.dart`、导出入口 Widget 测试 |
| P3-8 | 导出内容含块、装饰与内页背景 | Unit + Integration | export_service_test、导出结果像素/结构校验（可选） |

---

## P3-1：文本块富文本 payload 与 Markdown 子集解析/渲染

**开发内容**  
- 文本块 payload 保持 P2 兼容：`{"content": "..."}` 为纯文本；可选 `{"content": "...", "format": "markdown"}` 为富文本。  
- 实现 Markdown 子集解析（**加粗**、*斜体*、`行内代码`），或使用 `flutter_markdown` 渲染；解析/渲染逻辑可放在 `features/journal/` 或 `shared/widgets/`。  
- 阅读视图与编辑视图中，文本块根据 payload 是否有 `format: "markdown"` 决定按纯文本还是富文本展示。  

参考 [rich_text_interpretation_spec](../technical/rich_text_interpretation_spec.md)。

**验收**  
P2 已有纯文本块仍正常显示；新写入的带 `format: "markdown"` 的块能正确渲染加粗/斜体/代码。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P3-1-U1 | Unit | 纯文本 payload（仅 content）解析为纯文本，无格式 | 传入 `{"content": "hello"}`, 断言解析结果无 markdown 标记。 |
| P3-1-U2 | Unit | payload 含 format: "markdown" 时解析为富文本；**b** 被识别为加粗 | 传入 content 含 `**b**`，断言解析/渲染结果包含加粗语义或对应 widget。 |
| P3-1-U3 | Unit | 富文本 content 长度上限或转义不导致崩溃 | 超长 content 或含特殊字符，解析不抛错。 |
| P3-1-W1 | Widget | 文本块展示：纯文本 payload 显示为单段文本 | mock 一块 type=text、payload 仅 content，find 文本内容。 |
| P3-1-W2 | Widget | 文本块展示：markdown payload 时显示富文本（如加粗） | mock 一块 content 含 `**x**`、format markdown，find 含加粗样式或 RichText。 |

---

## P3-2：解读块（interpretation）数据模型与 CRUD

**开发内容**  
- 新增块类型 `interpretation`，payload 为 `{"targetBlockId": "uuid", "content": "解读内容", "format": "markdown"}`；与 [rich_text_interpretation_spec](../technical/rich_text_interpretation_spec.md) 一致。  
- JournalRepository 或 BlockEditor 提供：`addInterpretationBlock(pageId, targetBlockId, content)`、`updateBlock(blockId, payload)`（用于更新解读 content）、删除解读块。  
- 同一页内 interpretation 块通过 targetBlockId 关联到工具块；展示时按 orderIndex 排列，解读块挂到对应工具块下显示。  

**验收**  
可插入、更新、删除 interpretation 块；按 pageId 查询块时包含 interpretation 块且 payload 解析正确。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P3-2-U1 | Unit | 创建 interpretation 块，payload 含 targetBlockId、content | addInterpretationBlock 后 getBlocks 得到 type=interpretation，payload 解析出 targetBlockId 与 content。 |
| P3-2-U2 | Unit | 更新解读块 content，fromJson/toJson 往返一致 | updateBlock 更新 interpretation 的 content，读出后与更新值一致。 |
| P3-2-U3 | Unit | 删除解读块后该页块列表不再包含该块 | deleteBlock(interpretationBlockId)，getBlocks 不包含该 id。 |
| P3-2-U4 | Unit | interpretation 块与 dice/poem_slip/divination 块同页时可正确关联 | 插入 dice 块再插入 targetBlockId 指向该 dice 的 interpretation 块，按 orderIndex 取块时顺序正确。 |

---

## P3-3：手帐内解读入口与解读块展示/编辑

**开发内容**  
- 手帐阅读/编辑视图中，工具块（dice/poem_slip/divination）下方展示其解读（若有）；**解读入口**位置见 [p3_deliverables](project/p3_deliverables.md)（技术默认：块下方可展开的「解读」区域或「写解读」按钮）。  
- 无解读时显示「添加解读」等入口（l10n 待产品填写）；有解读时可进入编辑（内联或弹窗）。  
- 新增解读时调用 addInterpretationBlock；编辑时调用 updateBlock。  

**验收**  
打开含工具块的手帐页，可见解读区域或入口；添加/编辑解读后持久化并再次进入可见。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P3-3-W1 | Widget | 工具块下方无解读时显示「添加解读」或等价入口 | mock 一页含 dice 块、无 interpretation 块，find 添加解读按钮或文案。 |
| P3-3-W2 | Widget | 工具块下方有解读时显示解读内容 | mock 该页含对应 interpretation 块，find 解读 content 文案。 |
| P3-3-W3 | Widget | 点击添加解读并输入内容提交后，块列表多一条 interpretation 块（或通过 repository 验证） | 编辑态点击添加解读，输入「测试解读」提交，验证该页块中含 interpretation 且 content 为「测试解读」。 |
| P3-3-W4 | Widget | 编辑已有解读后保存，再次打开显示更新后内容 | 已有解读块，进入编辑并修改内容保存，重新加载页，find 更新后文案。 |

---

## P3-4：装饰模型与 drift 表、DecorationRepository

**开发内容**  
- 按 [decoration_spec](../technical/decoration_spec.md) 实现 `Decoration` 模型（id, pageId, kind, resourceId, x, y, width, height, rotationDegrees, zIndex, createdAt）。  
- drift 表 `journal_decorations`，主键 id，索引 page_id；删页时级联删除。  
- DecorationRepository：getDecorationsByPageId(pageId)、addDecoration(decoration)、updateDecoration(decoration)、deleteDecoration(id)。  

**验收**  
可增删改查装饰；按 pageId 查询返回该页所有装饰；删页后该页装饰不可见。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P3-4-U1 | Unit | addDecoration 后 getDecorationsByPageId 得到该条 | addDecoration(pageId, sticker)，get 得到一条 kind=sticker。 |
| P3-4-U2 | Unit | updateDecoration 更新 x/y/width/height 后读出一致 | update 位置与尺寸，get 得到更新后值。 |
| P3-4-U3 | Unit | deleteDecoration 后 get 不再包含该 id | delete(id)，getDecorationsByPageId 不包含该 id。 |
| P3-4-U4 | Unit | 删页后该页装饰均不可见（级联或应用层删除） | 删除 page，再 getDecorationsByPageId(该 pageId) 为空或抛。 |
| P3-4-U5 | Unit | Decoration toJson/fromJson 或与 drift 行互转正确 | 构造 Decoration，写入后读出，关键字段一致。 |

---

## P3-5：装饰选择器与页上添加/拖拽/缩放/删除

**开发内容**  
- 手帐编辑态下提供装饰入口（如工具栏「贴纸」「胶带」），打开选择器；选择素材后在当前页添加一条装饰（默认位置与尺寸）。  
- 页上装饰可拖拽移动、缩放（捏合或控制点）、删除（长按或选中删除）；操作后调用 DecorationRepository 持久化。  
- 内置素材路径按 [decoration_spec](../technical/decoration_spec.md)（如 `assets/decorations/stickers/sticker_01.png`）。  

**验收**  
可从选择器添加贴纸/胶带到当前页；拖拽、缩放、删除后保存，再次进入该页装饰状态正确。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P3-5-W1 | Widget | 编辑态下存在装饰入口（贴纸/胶带或统一「装饰」按钮） | pumpWidget 手帐详情编辑态，find 装饰相关按钮。 |
| P3-5-W2 | Widget | 选择贴纸并添加到页后，该页装饰数+1 且画布上可见 | mock 选择器选 sticker_01，触发添加，验证 getDecorationsByPageId 多一条且 kind=sticker。 |
| P3-5-W3 | Widget | 装饰可拖拽，松手后 updateDecoration 被调用（或通过状态验证位置变化） | 添加装饰后拖拽，验证新 x/y 已保存。 |
| P3-5-W4 | Widget | 删除装饰后画布上该装饰消失且 DB 中已删 | 添加装饰后触发删除，find 该装饰不再存在，getDecorationsByPageId 少一条。 |
| P3-5-I1 | Integration | 进手帐编辑 → 添加贴纸 → 退出再进入 → 贴纸仍在 | 打开手帐进入编辑，添加一枚贴纸，返回列表再进入该手帐该页，find 贴纸仍显示。 |

---

## P3-6：内页主题（PageTheme）配置与手帐/页应用

**开发内容**  
- 定义 PageTheme（id, backgroundType, backgroundColor/backgroundImagePath, showGrid, gridLineColor, gridSpacing, padding）；内置 2～3 种（如 parchment、grid、plain），见 [journal_visual_export_spec](../technical/journal_visual_export_spec.md)。  
- Journal 表增加可选 `page_theme_id`；手帐阅读/编辑页根据该字段取主题，绘制背景与网格后再绘制块与装饰。  
- 若产品支持「每页不同主题」，Page 表增加可选 `page_theme_id` 覆盖手帐级。  

**验收**  
手帐有 pageThemeId 时，打开该手帐可见对应背景与网格（若 showGrid 为 true）；切换主题后视觉变化正确。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P3-6-U1 | Unit | PageTheme 常量 parchment/grid/plain 存在且 id 正确 | 取内置主题列表，断言含上述 id。 |
| P3-6-U2 | Unit | Journal 带 page_theme_id 时 getTheme 返回对应主题 | mock Journal pageThemeId=grid，getTheme 返回 showGrid=true 的主题。 |
| P3-6-W1 | Widget | 手帐详情页应用内页主题时展示背景（或背景色） | pumpWidget 手帐详情且 journal 设了 pageThemeId，find 对应背景 Container 或 DecoratedBox。 |
| P3-6-W2 | Widget | 主题为 grid 时可见网格线（或占位） | pageTheme showGrid=true，find 网格相关绘制或至少无报错。 |

---

## P3-7：单页导出为 PNG、整本导出为 PDF/PNG

**开发内容**  
- 单页导出：对当前页使用 RepaintBoundary + toImage(pixelRatio: 2.0) 得到 PNG，保存到应用目录或系统相册/分享；入口见 [p3_deliverables](project/p3_deliverables.md)（技术默认：手帐详情 AppBar 菜单「导出本页」）。  
- 整本导出：遍历该手帐所有页，每页渲染为图后合并为 PDF（使用 `pdf` 包）或生成多张 PNG；入口「导出整本」。  
- ExportService 或等价逻辑位于 `features/journal/domain/` 或 `data/`，可注入便于测试。  

**验收**  
点击导出本页得到一张 PNG；点击导出整本得到 PDF 或多张图；文件可打开且内容与当前视图一致（见 P3-8）。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P3-7-U1 | Unit | ExportService 单页导出返回 Image 或 bytes 非空 | mock 一页块列表与主题，调用 exportPageAsImage，断言返回非空。 |
| P3-7-U2 | Unit | ExportService 整本导出返回 PDF bytes 或多张 Image 列表非空 | mock 手帐含 2 页，exportJournalAsPdf 或 exportJournalAsImages，断言页数=2 或 bytes 非空。 |
| P3-7-W1 | Widget | 手帐详情 AppBar 菜单含「导出本页」「导出整本」或等价 l10n | pumpWidget 手帐详情，打开 AppBar 菜单，find 导出相关项。 |
| P3-7-W2 | Widget | 点击导出本页后不崩溃且可得到结果（或 mock 保存成功） | tap 导出本页，pump，无异常；可选验证 ExportService 被调用。 |

---

## P3-8：导出内容含块、装饰与内页背景

**开发内容**  
- 导出时渲染顺序：内页背景（含网格）→ 块与装饰按 zIndex/orderIndex 混合绘制；与 [journal_visual_export_spec](../technical/journal_visual_export_spec.md) 一致。  
- 单页导出包含：当前页所有块（含 interpretation）+ 当前页所有装饰 + 当前内页主题背景。  

**验收**  
导出的 PNG/PDF 中可见块内容、装饰与背景；无缺漏或错位。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P3-8-U1 | Unit | 导出单页时传入的「页数据」包含块列表与装饰列表，且与 getBlocks/getDecorations 一致 | 调用 exportPage 时传入的 blocks 与 decorations 来自同一 pageId，数量一致。 |
| P3-8-I1 | Integration | 一页含 1 文本块 + 1 贴纸，导出后打开 PNG 可识别或像素非空（可选） | 添加文本块与贴纸，导出本页，断言生成文件存在且大小合理；可选解码图片检查尺寸。 |

---

## 测试文件目录建议

```
test/
├── features/
│   └── journal/
│       ├── domain/
│       │   ├── rich_text_parser_test.dart      # P3-1
│       │   ├── interpretation_block_test.dart  # P3-2
│       │   ├── page_theme_test.dart            # P3-6
│       │   └── export_service_test.dart       # P3-7, P3-8
│       ├── data/
│       │   └── local/
│       │       └── decoration_database_test.dart  # P3-4（若 drift 单测）
│       ├── data/repositories/
│       │   └── decoration_repository_test.dart    # P3-4
│       └── presentation/
│           ├── journal_interpretation_test.dart   # P3-3
│           ├── journal_decoration_test.dart       # P3-5
│           └── journal_detail_screen_test.dart    # P3-6 主题、P3-7 导出入口 扩展
integration_test/
└── journal_export_flow_test.dart                  # P3-5-I1、P3-8-I1 可选
```

---

## 与 P3 交付清单的对应

| [p3_deliverables](project/p3_deliverables.md) 交付项 | 本文档任务 | 验收测试 |
|------------------------------------------------------|------------|----------|
| 富文本/解读书写 | P3-1、P3-2、P3-3 | P3-1-U1～U3/W1～W2，P3-2-U1～U4，P3-3-W1～W4 |
| 装饰系统 | P3-4、P3-5 | P3-4-U1～U5，P3-5-W1～W4、I1 |
| 视觉与主题 | P3-6 | P3-6-U1/U2，P3-6-W1/W2 |
| 导出 | P3-7、P3-8 | P3-7-U1/U2/W1/W2，P3-8-U1、I1 |

---

*本文档随 P3 实现可增补具体测试代码片段或更新文件路径。*
