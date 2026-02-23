# 路由规格

本文档约定 P0 阶段使用的路由路径、参数及占位页，与 [架构指南](../project/architecture_guide.md)、[主壳与底部导航规格](../design/main_shell_spec.md) 一致。

---

## 1. 主壳与底部五页签

主页面最下方为五个页签：**首页**、**工具**、**手账**、**市集**、**我的**。各页签对应路由见下表，详细说明见 [主壳规格](../design/main_shell_spec.md)。

| 页签 | 路径 | 占位页/组件 |
|------|------|-------------|
| 首页 | `/home` | `HomeScreen` |
| 工具 | `/tools` | `ToolsScreen` |
| 手账 | `/journal` | `JournalListScreen` |
| 市集 | `/market` | `MarketScreen` |
| 我的 | `/me` | `MeScreen`（或 `SettingsScreen` 兼作「我的」页） |

---

## 2. 路由表（完整）

| 路径 | 说明 | 参数 | 占位页/组件 | 备注 |
|------|------|------|-------------|--------|
| `/` | 根入口 | — | 重定向到 `/home`，无单独组件 | 见 §3 重定向 |
| `/home` | 首页（社区） | — | `HomeScreen` | 见 [首页规格](../design/home_screen_spec.md) |
| `/tools` | 工具聚合页（骰子、诗签、占卜入口） | — | `ToolsScreen` | P1 前可为占位 |
| `/journal` | 手帐列表（本地+共享，按时间） | — | `JournalListScreen` | P2 前可为占位 |
| `/journal/:id` | 指定手帐（阅读/编辑） | `id` | `JournalDetailScreen` | P2 前可为占位 |
| `/journal/:id/page/:pageId` | 指定手帐的指定页 | `id`, `pageId` | `JournalDetailScreen`（同上一路由，根据有无 `pageId` 区分） | P2 起使用 |
| `/market` | 市集 | — | `MarketScreen` | P0 占位，具体能力待定 |
| `/me` | 我的（设置等） | — | `MeScreen` 或 `SettingsScreen` | P0 建议实现；设置项见 settings_and_l10n_spec |
| `/shared-journal/:id` | 共享手帐（P4） | `id` | `SharedJournalScreen` | P0 可为占位或暂不注册 |
| `/settings` | 设置（主题、语言等） | — | `SettingsScreen` | 若「我的」单独为 MeScreen，可保留本路由供深链或内嵌 |

**P2 手帐路由说明**：P2 阶段实现手帐核心后，`/journal`、`/journal/:id`、`/journal/:id/page/:pageId` 对应 `JournalListScreen`、`JournalDetailScreen`；无效 `journal/:id` 时重定向到 `/journal`。详见 [p2_deliverables](../project/p2_deliverables.md)、[p2_tasks_and_tests](../development/p2_tasks_and_tests.md)。

**说明**：`/:id` 表示路径参数，在 go_router 中对应 `path: 'journal/:id'` 与 `extra.pathParameters['id']`（或等价用法）。

### P1 工具子路由（工具先行阶段）

| 路径 | 说明 | 占位页/组件 | 备注 |
|------|------|-------------|--------|
| `/tools/dice` | 骰子工具页 | `DiceScreen` | 见 [dice_spec](dice_spec.md) |
| `/tools/poem-slip` | 诗签工具页 | `PoemSlipScreen` | 见 [poem_slip_spec](poem_slip_spec.md) |
| `/tools/tarot` | 简易占卜（单张塔罗）页 | `TarotScreen` | 见 [simple_divination_spec](simple_divination_spec.md) |

- 实现时可在 `/tools` 下配置子路由（ShellRoute 或 children），使从 ToolsScreen 可导航至上述子页并保留返回。
- 与 [p1_deliverables](../project/p1_deliverables.md) 中「工具入口与路由」一致；产品侧若调整路径或 Screen 名，请同步更新本文档与各 spec。

---

## 3. 重定向与守卫

| 场景 | 行为 | 决策 |
|------|------|--------|
| 未登录访问需登录页 | 重定向到登录或首页 | **P0 不启用**；登录与守卫留待后续迭代，届时再定登录路径（如 `/login`） |
| 访问不存在的 `journal/:id` | 404 或重定向到 `/journal` | **重定向到 `/journal`**（实现简单、体验一致，后续可改为 404 页） |
| 根路径 `/` | 重定向到 `/home` 或直接渲染首页 | **重定向到 `/home`**（单一首页入口，便于深链与后续扩展） |

**守卫实现位置**：在 **go_router 的 `redirect` 回调**中集中实现；逻辑增多时可拆为 `lib/core/router/redirect_handlers.dart` 由 `redirect` 调用，保持一处入口、易维护。

---

## 4. 实现位置与依赖

- **定义位置**：`lib/core/router/`（如 `app_router.dart` 或 `routes.dart`）。
- **依赖**：需注入到 `MaterialApp.router(routerConfig: ...)`；若使用 go_router，添加依赖：`go_router: ^14.0.0`（与当前 Dart 3.11 兼容，按语义化版本可接受小版本升级）。

---

## 5. 占位页要求

P0 阶段每个路由至少对应一个可导航的页面，页面内容可为：

- 居中标题 + 路由路径文案（便于验收导航是否正确）。
- **命名约定**：页面类统一使用 **`*Screen` 后缀**（如 `HomeScreen`、`JournalListScreen`）；P0 占位内容在对应 Screen 内实现，后续替换为正式 UI 时无需改路由。

---

## 6. 已决策内容汇总

- **主壳与五页签**：底部导航五个页签为首页、工具、手账、市集、我的；对应路由 `/home`、`/tools`、`/journal`、`/market`、`/me`；见 [主壳规格](../design/main_shell_spec.md)。
- **组件/页面名称**：见 §1、§2（`HomeScreen`、`ToolsScreen`、`JournalListScreen`、`JournalDetailScreen`、`MarketScreen`、`MeScreen` 或 `SettingsScreen`、`SharedJournalScreen`）。
- **重定向与守卫**：P0 不启用登录守卫；根路径 `/` → `/home`；无效 `journal/:id` → `/journal`；守卫在 go_router `redirect` 中实现，可拆出 `redirect_handlers.dart`。
- **go_router 版本**：`^14.0.0`。
- **占位页命名**：`*Screen` 后缀，占位内容在 Screen 内实现。

实现时与 `lib/core/router/` 保持一致。

---

*对应 [p0_deliverables](../project/p0_deliverables.md) 中「路由」项。*
