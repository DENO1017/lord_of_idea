---
name: flutter-development
description: Guides Flutter and Dart development using MCP tools for analysis, formatting, testing, dependency management, and running apps. Use when developing Flutter/Dart code, running tests, fixing analysis errors, adding packages, or debugging a running Flutter application.
---

# Flutter 开发

在 Flutter/Dart 项目中开发时，**优先使用本项目的 Dart/Flutter MCP 工具**（user-dart），而不是在终端直接执行 shell 命令。使用 MCP 可保证与 IDE/分析器行为一致，并便于获取运行中应用与符号信息。

## 使用 MCP 前的准备

多数 MCP 工具要求先指定**项目根**（roots）。在调用 `analyze_files`、`dart_format`、`run_tests`、`pub` 等前：

1. 使用 **add_roots** 添加当前项目根目录（例如工作区根路径）。
2. 若客户端未正确设置 Roots，可让用户为 `dart mcp-server` 加上 `--force-roots-fallback`，再通过工具管理 roots。

之后所有需要 `root` 的工具都传入已添加的根路径。

---

## 代码质量与规范

### 分析

- **analyze_files**：分析指定路径或整个项目的错误。修改代码后可用其验证无新问题。
- **dart_fix**：在给定根下执行 `dart fix --apply`，自动修复可修复的 lint/问题。
- **dart_format**：在给定根下执行格式化（与 `dart format lib/ test/` 一致）。本项目约定只格式化 `lib/`、`test/`，行宽 80。

**验收**：分析无错误；格式化后无变更（CI 可用 `dart format --set-exit-if-changed lib/ test/`）。

### 符号与文档

- **resolve_workspace_symbol**：按名称在工程中查找符号，校验存在性或纠正拼写。
- **hover**：获取某文件某光标位置的悬停信息（文档、类型等）。
- **signature_help**：获取某位置 API 的签名帮助。

---

## 依赖与包

- **pub**：在项目根下执行 pub 命令，如 `dart pub get`、`flutter pub add <package>`。添加依赖后应执行一次 `pub get`。
- **pub_dev_search**：在 pub.dev 按关键词搜索包，返回下载量、描述、topics 等。支持高级语法（如 `topic:`, `dependency:`, `sdk:flutter`）。
- **read_package_uris**：读取 `package:` 或 `package-root:` URI（依赖包内文件路径）。

---

## 测试

- **run_tests**：以面向 Agent 的方式运行 Dart/Flutter 测试。**始终优先使用此工具**，不要用 `dart test` 或 `flutter test` 的 shell 命令。
- 测试目录为 `test/`；P0 要求 `flutter test` 通过，对应 MCP 即对项目根调用 `run_tests`。

---

## 运行中应用（需 DTD）

与运行中 Flutter 应用交互前，需先连接 **Dart Tooling Daemon (DTD)**：

1. **connect_dart_tooling_daemon**：连接 DTD。URI 从“Copy DTD Uri to clipboard”等途径获取，不要编造。断线后需重新向用户索取新 URI。
2. 连接成功后可使用：
   - **get_runtime_errors**：获取当前运行时错误。
   - **get_widget_tree** / **get_selected_widget**：获取控件树或当前选中控件。
   - **get_active_location**：获取编辑器当前光标位置。
   - **hot_reload** / **hot_restart**：热重载 / 热重启。

启动应用：

- **list_devices**：列出可用设备，供用户选择或传给 launch_app。
- **launch_app**：传入项目 `root` 与 `device`（及可选的 `target`），启动应用并返回 DTD URI 与进程 ID。
- **list_running_apps**：列出由 launch_app 启动的进程与 DTD URI。
- **stop_app**：结束由 launch_app 启动的进程。
- **get_app_logs**：获取由 launch_app 启动的某进程的日志。

需要用户在 UI 上选控件时，使用 **set_widget_selection_mode** 开启控件选择模式；使用 Flutter Driver 时不必开启。

---

## 项目约定（本仓库）

- **目录结构**：`lib/main.dart`、`lib/app.dart`；`lib/core/`（di、router、theme、l10n）；`lib/features/`（按功能，含 data/domain/presentation）；`lib/shared/`（跨功能共享）。详见 [reference.md](reference.md)。
- **命名**：文件 snake_case，类/类型 PascalCase，路由路径与 routes_spec 一致。
- **Lint**：`flutter_lints` ^6.0.0，`analysis_options.yaml` 使用 `include: package:flutter_lints/flutter.yaml`；验收命令 **flutter analyze**（或通过 MCP **analyze_files**）。
- **格式化**：**dart format lib/ test/**，行宽 80。
- **测试**：**flutter test**，对应 MCP **run_tests**；测试用例组织见 `docs/development/p0_tasks_and_tests.md`。
- **状态与 DI**：Riverpod；根 Widget 用 ProviderScope；路由、设置、本地存储在 core/di 与 core/router 中注册，见 state_and_di_spec、routes_spec。

开发新功能或改代码时，遵循上述结构与命名，并在修改后通过 MCP 做 analyze、format、run_tests 以保持规范与质量。

---

## 常用工作流

以下工作流已整理为 Cursor Command，可在对话中用 **/命令名** 直接触发：

| 命令 | 用途 |
|------|------|
| `/flutter-task-dev` | 按任务编号开发：输入 P0-N，查找任务 → 实现 → 写测试 → 自检与 run_tests |
| `/flutter-post-edit-check` | 修改代码后自检（format → analyze → dart_fix → run_tests） |
| `/flutter-add-dependency` | 查找并添加依赖（pub_dev_search → pub → analyze → run_tests） |
| `/flutter-debug-running-app` | 调试运行中应用（连接 DTD → get_runtime_errors / get_widget_tree → hot_reload） |

---

**修改代码后自检：**

1. add_roots（若尚未添加）。
2. dart_format（root = 项目根）。
3. analyze_files（若仅部分路径可传 paths）。
4. 若有可自动修复项，dart_fix。
5. run_tests。

**查找并添加依赖：**

1. pub_dev_search（query = 功能关键词或 topic）。
2. pub（root = 项目根，如 `flutter pub add <package>`）。
3. 必要时再次 analyze_files、run_tests。

**调试运行中应用（如布局/运行时错误）：**

1. 确保应用已通过 launch_app 启动（或用户已提供 DTD URI）。
2. connect_dart_tooling_daemon（使用用户提供的 DTD URI）。
3. get_runtime_errors 或 get_widget_tree / get_selected_widget 获取上下文。
4. 修改代码后 hot_reload 或 hot_restart，再根据需要重复 get_runtime_errors / get_widget_tree。

---

## 更多参考

- 项目代码结构、路由、状态与 DI、主题与 l10n：见 [reference.md](reference.md)。
- P0 任务与测试用例拆解：`docs/development/p0_tasks_and_tests.md`。
- 规范与工具链：`docs/development/quality_and_tooling.md`。
