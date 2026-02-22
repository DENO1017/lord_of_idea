# 代码结构规范

本文档约定 P0 阶段建立的目录结构、命名与职责，与 [架构指南](../project/architecture_guide.md) 一致。开发时新代码应放入下表对应位置。

---

## 1. 根目录与 lib 结构

```
lib/
├── main.dart              # 入口，仅 bootstrap（runApp 等）
├── app.dart               # MaterialApp/CupertinoApp、主题、路由、本地化
├── core/                  # 横切能力（见下）
├── features/              # 按功能划分的模块（见下）
└── shared/                # 跨功能共享（见下）
```

---

## 2. core/ 横切能力

| 目录 | 职责 | 约定 |
|------|------|-------------|
| `core/di/` | 依赖注入注册（Provider 定义、Bloc 注册等） | 已定稿，具体 Provider 列表见 [state_and_di_spec](../technical/state_and_di_spec.md) |
| `core/router/` | 路由表、GoRoute 定义、重定向与守卫 | 已定稿，路由路径与守卫见 [routes_spec](../technical/routes_spec.md) |
| `core/theme/` | ThemeData、ColorScheme、TextTheme、多主题切换逻辑 | 已定稿，色板与字体见 [theme_spec](../design/theme_spec.md) |
| `core/l10n/` | 国际化：arb 或生成代码的引用、Locale 解析 | 已定稿，支持语言与 key 见 [settings_and_l10n_spec](../technical/settings_and_l10n_spec.md) |
| `core/utils/` | 通用工具函数（日期、字符串、校验等） | **P0 暂不放置**；后续按需添加（如 `date_utils.dart`、`string_utils.dart`） |

---

## 3. features/ 功能模块

每个 feature 内按 **data / domain / presentation** 划分子目录（可选：P0 仅建空目录或占位文件）。

| 模块 | 路径 | 说明 | P0 占位页（与路由对应） |
|------|------|------|--------------------------|
| 占卜与随机工具 | `features/divination/` | 塔罗、骰子、诗签；P1 起实现 | 入口在 `/tools`，占位页：`ToolsScreen`（可放在本 feature 或 core 占位） |
| 电子手帐 | `features/journal/` | 手帐 CRUD、页与块；P2 起实现 | `JournalListScreen`（`/journal`）、`JournalDetailScreen`（`/journal/:id`） |
| 共享手帐与跑团 | `features/shared_journal/` | 共享、权限、模板；P4 起实现 | `SharedJournalScreen`（`/shared-journal/:id`）；P0 可为占位 |

**子目录约定**（每个 feature 下）：

- `data/`：Repository 实现、本地/远程数据源、DTO。
- `domain/`：实体、用例、业务规则。
- `presentation/`：页面（screens）、Widget、状态管理（ViewModel/Bloc 等）。

---

## 4. shared/ 跨功能共享

| 目录 | 职责 | 约定 |
|------|------|--------|
| `shared/models/` | 手帐、页面、块、装饰等被多 feature 引用的模型 | P2 起补充：`Journal`、`JournalPage`、`Block`（及子类型如 `TextBlock`、`DiceResultBlock`）等；P0 可留空目录 |
| `shared/widgets/` | 通用 UI 组件（按钮、卡片、空状态等） | **P0 暂不提供**；后续按需添加（如 `AppCard`、`EmptyState`） |
| `shared/services/` | 加密、导出、文件等通用服务 | **P0 无**；P3+ 按需（如导出 PDF、备份） |

---

## 5. 命名约定（需遵守）

- **文件**：snake_case（如 `journal_list_screen.dart`）。
- **类/类型**：PascalCase（如 `JournalListScreen`）。
- **目录**：snake_case，与 feature 或能力对应（如 `shared_journal`、`theme`）。
- **路由路径**：小写、连字符可选，与 [routes_spec](../technical/routes_spec.md) 一致。

---

## 6. 已定稿内容汇总（P0）

- **core**：di/router/theme/l10n 见对应规格文档；utils P0 暂不放置。
- **features**：占位页与路由对应——ToolsScreen、JournalListScreen、JournalDetailScreen、SharedJournalScreen（见 [routes_spec](../technical/routes_spec.md)）。
- **shared/models**：P2 起补充 Journal、JournalPage、Block 等；P0 可留空。
- **shared/widgets**：P0 暂不提供。
- **shared/services**：P0 无。

---

*与 [p0_deliverables](../project/p0_deliverables.md) 配合使用。*
