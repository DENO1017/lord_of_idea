# 规范与质量、工具链

本文档约定 P0 阶段的代码规范、格式化、静态检查与可选 pre-commit，确保新人可一键跑起项目并与 [p0_deliverables](../project/p0_deliverables.md) 中「规范与质量」项对应。

---

## 1. Lint 与静态分析

| 项 | 说明 | 决策 |
|----|------|--------|
| 规则集 | 使用 `flutter_lints`，配置在根目录 `analysis_options.yaml` | **flutter_lints** 版本 **^6.0.0**（与 pubspec 一致）；`include: package:flutter_lints/flutter.yaml` |
| 额外规则 | 需关闭或开启的规则 | P0 沿用 flutter_lints 默认，不在 `analysis_options.yaml` 中增删规则；后续若有需要可在 `linter.rules` 下添加（如 `avoid_print: false`、`prefer_single_quotes: true`） |

**验收**：在项目根目录执行 **`flutter analyze`**（或 `dart analyze`），无错误即通过。

---

## 2. 格式化

| 项 | 说明 | 决策 |
|----|------|--------|
| 工具 | Dart 官方 `dart format` | 本地格式化：**`dart format lib/ test/`**；CI 校验可用 **`dart format --set-exit-if-changed lib/ test/`**（有未格式化文件则失败） |
| 格式化范围 | 仅源码与测试 | **`lib/`、`test/`**（不格式化生成代码与第三方目录） |
| 行宽 | 默认 80 字符 | **80**（不修改，与 Dart 惯例一致） |

**验收**：执行 `dart format lib/ test/` 后无变更（或 CI 中 `--set-exit-if-changed` 不失败）。

---

## 3. Pre-commit（可选）

| 项 | 说明 | 决策 |
|----|------|--------|
| 是否启用 | 是 / 否 | **P0 不启用**（降低新人上手成本；CI 可单独做 format/analyze 校验） |
| 工具 | Git hooks 或脚本 | 后续若启用，建议 **`scripts/pre_commit.sh`** 或 **husky** + 脚本，便于跨平台 |
| 执行的步骤 | format、analyze 等 | 建议步骤：**1. `dart format lib/ test/`；2. `flutter analyze`**（可不含 test，以加快提交反馈） |
| 脚本或配置位置 | 脚本/ hook 位置 | 若启用：**`scripts/pre_commit.sh`**（可被 `.husky/pre-commit` 或 Git `core.hooksPath` 调用） |

---

## 4. 测试（P0 最低要求）

| 项 | 说明 | 决策 |
|----|------|--------|
| 是否要求 P0 有自动化测试 | 至少保留默认测试通过 | **是**；P0 至少保证 **`flutter test`** 通过（可为默认生成的测试），后续按模块补充用例 |
| 测试目录 | `test/` | 默认 **`test/`** |
| 运行命令 | 统一命令 | **`flutter test`**（与 README 一致；等价于 `dart test`） |

---

## 5. README 要求

README 中需包含以下内容，便于新人一键跑起项目（具体文案见 [README](../../README.md)）：

| 内容 | 状态 |
|------|------|
| 项目简介与文档索引 | **已落实**：含项目简介及指向 [项目概览](../project/project_overview.md)、架构、项目管理、P0 交付清单的链接 |
| 环境要求 | **已落实**：Flutter SDK 建议 3.22+（与 Dart ^3.11.0 兼容），iOS 需 macOS + Xcode，编辑器建议 |
| 安装依赖 | **已落实**：`flutter pub get` |
| 运行 | **已落实**：`flutter run`；指定设备示例（chrome / windows / macos）及 `flutter devices` |
| 构建 | **已落实**：`flutter build apk/ios/web/windows` 及 Flutter 构建文档链接 |
| 测试 | **已落实**：`flutter test` |
| 代码规范 | **已落实**：`flutter analyze`、`dart format lib/ test/`，并链接至本文档 |

---

## 6. 已决策内容汇总

- **Lint**：`flutter_lints: ^6.0.0`，`analysis_options.yaml` 使用 `include: package:flutter_lints/flutter.yaml`；分析命令 **`flutter analyze`**。
- **格式化**：**`dart format lib/ test/`**，行宽 80；CI 可用 `dart format --set-exit-if-changed lib/ test/`。
- **Pre-commit**：P0 不启用；后续可增加 `scripts/pre_commit.sh`（format + analyze）或 husky。
- **测试**：P0 要求 `flutter test` 通过；测试目录 `test/`，命令 **`flutter test`**。
- **README**：已包含环境要求、安装/运行/构建/测试命令及代码规范链接，与本文档一致。

实现时与仓库内 `analysis_options.yaml`、`pubspec.yaml` 及 [README](../../README.md) 保持一致。

---

*对应 [p0_deliverables](../project/p0_deliverables.md) 中「规范与质量」项。*
