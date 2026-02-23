# P0 基础架设：交付清单与文档索引

本文档对应 [project_manager](project_manager.md) 中的 **P0：基础架设**，列出每项交付内容、验收标准、相关文档位置，以及**需要填写或决策的内容**。

---

## 交付项与文档映射

| P0 交付项 | 验收标准 | 对应文档 | 需填写/决策项 |
|-----------|----------|----------|----------------|
| 应用入口与壳 | 启动即见统一主题，可切换主题 | [主题规范](../design/theme_spec.md) | 色板、字体、主题名称与数量 |
| 路由 | 可导航到各占位页 | [路由规格](../technical/routes_spec.md) | 守卫、重定向、占位页组件名 |
| 目录结构 | 新代码有明确归属 | [代码结构规范](../development/code_structure.md) | 各层/模块的命名与职责说明 |
| 状态管理与 DI | 任意页可通过 DI 获取服务 | [状态与 DI 规格](../technical/state_and_di_spec.md) | 选型（Riverpod/Bloc）、Provider 列表 |
| 基础设置 | 重启后语言/主题保持 | [设置与国际化规格](../technical/settings_and_l10n_spec.md) | 持久化 key、支持语言列表、文案 key |
| 规范与质量 | 新人可一键跑起项目 | [质量与工具链](../development/quality_and_tooling.md)、[README](../../README.md) | 环境要求、运行/构建命令、pre-commit 脚本 |

**任务拆解与测试用例**：见 [P0 开发任务拆解与测试用例](../development/p0_tasks_and_tests.md)，内含每条开发任务对应的单元/Widget/集成测试用例及测试文件建议。

---

## 需要填写的内容汇总（填写状态）

以下为各文档中原「需填写」项的集中列表；**当前已全部在对应文档中填写或定稿**。

### 主题与入口 — ✅ 已填写

- 主色、次要色、背景色、错误色等色值 → 见 `docs/design/theme_spec.md`（复古中世纪色板）。
- 正文字体、标题字体及备用字体 → 见 `theme_spec.md`（Cinzel、Cormorant Garamond）。
- 主题数量与名称 → [浅色, 深色, 跟随系统]。

### 路由 — ✅ 已填写

- 守卫与重定向逻辑 → 见 `docs/technical/routes_spec.md`（根路径→/home，无效 journal id→/journal，P0 不启用登录守卫）。
- 占位页组件名 → HomeScreen、ToolsScreen、JournalListScreen、JournalDetailScreen、MarketScreen、MeScreen（或 SettingsScreen 兼作「我的」）、SharedJournalScreen；主壳底部五页签见 [主壳规格](../design/main_shell_spec.md)。

### 状态与 DI — ✅ 已填写

- 状态管理选型 → Riverpod（见 `docs/technical/state_and_di_spec.md`）。
- core 注册的 Provider/服务 → appRouterProvider、appSettingsProvider、localStorageProvider（及实现类约定）。

### 设置与国际化 — ✅ 已填写

- 持久化 key 列表 → `lord_of_idea.theme_mode`、`lord_of_idea.locale_language_code` 等（见 `docs/technical/settings_and_l10n_spec.md`）。
- 支持语言/地区 → zh、en；arb 目录 `lib/l10n`。
- 占位文案 key 与默认值 → appTitle、navHome、navTools、navJournal、settings、theme、themeLight/Dark/System、language。

### 质量与 README — ✅ 已填写

- 环境与版本 → README：Flutter 3.22+（Dart ^3.11），iOS 需 macOS + Xcode。
- 运行与构建命令 → `flutter pub get`、`flutter run`、`flutter build xxx`、`flutter test`。
- Pre-commit → P0 不启用（见 `docs/development/quality_and_tooling.md`）。

### 代码结构 — ✅ 已填写

- 目录职责与占位页、shared 约定 → 见 `docs/development/code_structure.md`（已定稿汇总在 §6）。

---

## P0 完成检查

- [x] `main.dart` / `app.dart` 接入主题与路由，启动无报错。
- [x] 按 `code_structure` 建立 `core/`、`features/`、`shared/` 及子目录。（注：`shared/` 尚未建目录，规范允许 P0 留空；建议补建空目录以便归属明确。）
- [x] 状态管理/DI 已选定并在 core 注册，至少一个占位页能通过 DI 获取服务。
- [x] 主题、语言设置可持久化，重启后生效。
- [x] README 中运行与构建说明可被新人执行通过。
- [x] **所有「需填写」项已在对应文档中填写或定稿**（主题、路由、状态与 DI、设置与 l10n、质量与 README、代码结构均已落实）。

---

*本文档随 P0 推进更新勾选与需填写汇总。*
