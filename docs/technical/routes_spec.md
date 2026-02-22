# 路由规格

本文档约定 P0 阶段使用的路由路径、参数及占位页，与 [架构指南](../project/architecture_guide.md) 中 go_router 建议一致。

---

## 1. 路由表

| 路径 | 说明 | 参数 | 占位页/组件 | 备注 |
|------|------|------|-------------|--------|
| `/` | 首页/入口 | — | 重定向到 `/home`，无单独组件 | 见 §2 重定向 |
| `/home` | 首页 | — | `HomeScreen` | |
| `/tools` | 工具聚合页（骰子、诗签、占卜入口） | — | `ToolsScreen` | P1 前可为占位 |
| `/journal` | 手帐列表 | — | `JournalListScreen` | P2 前可为占位 |
| `/journal/:id` | 指定手帐（阅读/编辑） | `id` | `JournalDetailScreen` | P2 前可为占位 |
| `/journal/:id/page/:pageId` | 指定手帐的指定页 | `id`, `pageId` | `JournalDetailScreen`（同上一路由，根据有无 `pageId` 区分） | P2 起使用 |
| `/shared-journal/:id` | 共享手帐（P4） | `id` | `SharedJournalScreen` | P0 可为占位或暂不注册 |
| `/settings` | 设置（主题、语言等） | — | `SettingsScreen` | P0 建议实现 |

**说明**：`/:id` 表示路径参数，在 go_router 中对应 `path: 'journal/:id'` 与 `extra.pathParameters['id']`（或等价用法）。

---

## 2. 重定向与守卫

| 场景 | 行为 | 决策 |
|------|------|--------|
| 未登录访问需登录页 | 重定向到登录或首页 | **P0 不启用**；登录与守卫留待后续迭代，届时再定登录路径（如 `/login`） |
| 访问不存在的 `journal/:id` | 404 或重定向到 `/journal` | **重定向到 `/journal`**（实现简单、体验一致，后续可改为 404 页） |
| 根路径 `/` | 重定向到 `/home` 或直接渲染首页 | **重定向到 `/home`**（单一首页入口，便于深链与后续扩展） |

**守卫实现位置**：在 **go_router 的 `redirect` 回调**中集中实现；逻辑增多时可拆为 `lib/core/router/redirect_handlers.dart` 由 `redirect` 调用，保持一处入口、易维护。

---

## 3. 实现位置与依赖

- **定义位置**：`lib/core/router/`（如 `app_router.dart` 或 `routes.dart`）。
- **依赖**：需注入到 `MaterialApp.router(routerConfig: ...)`；若使用 go_router，添加依赖：`go_router: ^14.0.0`（与当前 Dart 3.11 兼容，按语义化版本可接受小版本升级）。

---

## 4. 占位页要求

P0 阶段每个路由至少对应一个可导航的页面，页面内容可为：

- 居中标题 + 路由路径文案（便于验收导航是否正确）。
- **命名约定**：页面类统一使用 **`*Screen` 后缀**（如 `HomeScreen`、`JournalListScreen`）；P0 占位内容在对应 Screen 内实现，后续替换为正式 UI 时无需改路由。

---

## 5. 已决策内容汇总

- **组件/页面名称**：见 §1 路由表（`HomeScreen`、`ToolsScreen`、`JournalListScreen`、`JournalDetailScreen`、`SharedJournalScreen`、`SettingsScreen`）。
- **重定向与守卫**：P0 不启用登录守卫；根路径 `/` → `/home`；无效 `journal/:id` → `/journal`；守卫在 go_router `redirect` 中实现，可拆出 `redirect_handlers.dart`。
- **go_router 版本**：`^14.0.0`。
- **占位页命名**：`*Screen` 后缀，占位内容在 Screen 内实现。

实现时与 `lib/core/router/` 保持一致。

---

*对应 [p0_deliverables](../project/p0_deliverables.md) 中「路由」项。*
