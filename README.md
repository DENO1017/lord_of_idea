# 灵感之主（Lord of Idea）

集成了占卜、骰子、诗签等创意辅助工具的电子手帐应用，支持跑团与故事创作。项目说明见 [项目概览](docs/project/project_overview.md)。

---

## 环境要求

- **Flutter SDK**：与 `pubspec.yaml` 中 `environment.sdk: ^3.11.0` 兼容，建议 **Flutter 3.22+**（含 Dart 3.11）。
- **其他**：无强制要求；若需构建 iOS，须在 **macOS** 上安装 **Xcode**。编辑器可用 VS Code 或 Android Studio（含 Flutter 插件）。

---

## 安装依赖

在项目根目录执行：

```bash
flutter pub get
```

---

## 运行

```bash
flutter run
```

- **指定设备**：如 `flutter run -d chrome`（Web）、`flutter run -d windows`（Windows）、`flutter run -d macos`；可用 `flutter devices` 查看可用设备。

---

## 构建

按目标平台选用：

```bash
# Android
flutter build apk

# iOS（需在 macOS 上）
flutter build ios

# Web
flutter build web

# Windows
flutter build windows
```

更多参数见 [Flutter 构建文档](https://docs.flutter.dev/deployment)。

---

## 测试

```bash
flutter test
```

---

## 代码规范

- **静态分析**：`flutter analyze`（或 `dart analyze`）
- **格式化**：`dart format lib/ test/`

详见 [规范与工具链](docs/development/quality_and_tooling.md)。

---

## 文档索引

- [项目概览](docs/project/project_overview.md)
- [架构指南](docs/project/architecture_guide.md)
- [项目管理与排期](docs/project/project_manager.md)
- [P0 交付清单](docs/project/p0_deliverables.md)
