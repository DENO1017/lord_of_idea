# Flutter 开发技能 — 项目参考

本文件为 [SKILL.md](SKILL.md) 的补充，汇总本仓库中与 Flutter 开发相关的文档路径与要点。Agent 仅在需要更细粒度约定时查阅此处。

---

## 代码结构

- **规范**：`docs/development/code_structure.md`
- **要点**：
  - `lib/main.dart` 仅做 bootstrap（runApp + ProviderScope + MyApp）。
  - `lib/app.dart`：MaterialApp.router、主题、路由、locale、supportedLocales、localizationsDelegates；themeMode/locale 来自 `appSettingsProvider`。
  - `lib/core/`：di（Provider 定义）、router（GoRoute）、theme（AppTheme light/dark）、l10n。
  - `lib/features/`：按功能分模块，每模块可有 data/domain/presentation；P0 占位页与路由对应（ToolsScreen、JournalListScreen、JournalDetailScreen、SharedJournalScreen、SettingsScreen）。
  - `lib/shared/`：models、widgets、services（P0 部分为空或占位）。
  - 文件 snake_case，类 PascalCase，路由路径小写、连字符，与 routes_spec 一致。

---

## 路由

- **规范**：`docs/technical/routes_spec.md`
- **路径**：`/` → 重定向 `/home`；`/home`、`/tools`、`/journal`、`/journal/:id`、`/journal/:id/page/:pageId`、`/shared-journal/:id`、`/settings`。
- **实现位置**：`lib/core/router/`；redirect 集中在一处（可拆到 redirect_handlers.dart）。

---

## 状态与依赖注入

- **规范**：`docs/technical/state_and_di_spec.md`
- **要点**：Riverpod 即 DI；ProviderScope 包裹根；core 中注册 appRouterProvider、appSettingsProvider（AppSettingsNotifier）、localStorageProvider（LocalStorageService）；设置持久化依赖 LocalStorageService。

---

## 主题与国际化

- **主题**：`docs/design/theme_spec.md`（若存在）；实现于 `lib/core/theme/`，提供 lightTheme、darkTheme。
- **国际化**：`docs/technical/settings_and_l10n_spec.md`；实现于 `lib/core/l10n/`，arb 或生成代码。

---

## 规范与质量

- **规范**：`docs/development/quality_and_tooling.md`
- **要点**：flutter_lints ^6.0.0；`flutter analyze`；`dart format lib/ test/` 行宽 80；测试 `flutter test`，目录 `test/`；README 含环境、pub get、run、build、test、analyze/format 说明。

---

## P0 任务与测试

- **文档**：`docs/development/p0_tasks_and_tests.md`
- **内容**：P0-1～P0-10 任务拆解及对应 Unit/Widget/Integration 测试用例与建议测试文件路径（如 `test/app_test.dart`、`test/core/theme/app_theme_test.dart`、`test/core/router/app_router_test.dart` 等）。

开发时若需确认某模块的职责、路由或测试组织，可优先查阅上述对应文档。
