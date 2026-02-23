# 主壳与底部导航规格

本文档约定应用主页面结构：底部五个页签及其对应功能与路由，与 [路由规格](../technical/routes_spec.md) 一致。

---

## 1. 主壳结构

- **主页面**：应用最下方为**底部导航栏**，固定显示五个页签按钮。
- **页签顺序**（从左到右）：**首页**、**工具**、**手账**、**市集**、**我的**。
- **内容区**：当前选中页签对应的页面在上方全屏展示；切换页签时切换内容，不保留各 tab 内子页的独立栈（或按实现需要采用 ShellRoute 保留每 tab 内栈）。

---

## 2. 各页签说明与路由

| 页签 | 路由 | 说明 | 详细规格 |
|------|------|------|----------|
| **首页** | `/home` | 社区功能：查看他人分享的手账与动态，支持互动与收藏 | [首页（社区）规格](home_screen_spec.md) |
| **工具** | `/tools` | 骰子、诗签等工具入口，按钮形式排布 | [P1 交付](../project/p1_deliverables.md)、[路由规格](../technical/routes_spec.md) |
| **手账** | `/journal` | 手账列表：本地手账与共享手账均在此，按时间顺序、卡片网格排布 | [P2 交付](../project/p2_deliverables.md)、[手账数据模型](../technical/journal_data_models_spec.md) |
| **市集** | `/market` | 市集功能（占位，具体能力待产品后续定义） | — |
| **我的** | `/me` 或 `/settings` | 个人中心，主要为各类设置入口 | [设置与国际化规格](../technical/settings_and_l10n_spec.md) |

- 实现时底部导航栏使用 l10n key：`navHome`、`navTools`、`navJournal`、`navMarket`、`navMe`（若与现有 key 不一致，以本文档与 l10n 约定为准）。
- 根路径 `/` 重定向至 `/home`，见 [路由规格](../technical/routes_spec.md)。

---

## 3. 实现要点

- **Shell 与路由**：主壳对应 go_router 的 ShellRoute（或等价结构），子路由为 `/home`、`/tools`、`/journal`、`/market`、`/me`（或 `/settings`）；深链应能打开对应 tab 并高亮正确页签。
- **占位页**：P0 阶段五个页签均需有可导航的占位页；市集、首页社区等具体内容按阶段在对应交付文档中实现。
- **命名约定**：页面类使用 `*Screen` 后缀，如 `HomeScreen`、`ToolsScreen`、`JournalListScreen`、`MarketScreen`、`MeScreen`（或 `SettingsScreen` 兼作「我的」页）。

---

## 4. 与阶段的关系

| 阶段 | 主壳与页签 |
|------|------------|
| P0 | 底部 5 页签可切换，各对应占位页与路由 |
| P1 | 工具页实现骰子/诗签/占卜入口（按钮排布） |
| P2 | 手账页实现手账列表（本地+共享、按时间、卡片网格） |
| P4+ | 首页社区、市集等可逐步实现或占位 |

---

*本文档为产品与设计约定，实现时与 [routes_spec](../technical/routes_spec.md)、各阶段交付文档保持一致。*
