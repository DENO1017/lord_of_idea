# 设置与国际化规格

本文档约定 P0 阶段的基础设置（主题、语言等）持久化方式、key 约定，以及国际化（l10n）支持的语言与文案占位，与 [架构指南](../project/architecture_guide.md) 一致。

---

## 1. 持久化存储

**技术选型**：使用 **SharedPreferences**（与 [state_and_di_spec](state_and_di_spec.md) 中 `LocalStorageService` 封装一致；键值配置场景足够，无需引入 Hive）。  
**依赖**：`shared_preferences: ^2.2.2`（与 Dart 3.11 兼容；由 `LocalStorageService` 内部使用，不在业务层直接依赖）。

---

## 2. 设置项与 Key 列表

以下 key 用于从本地存储读写（`LocalStorageService` / `AppSettingsNotifier` 使用），统一加前缀避免冲突。

| 设置项 | 存储 key | 类型 | 默认值 | 说明 |
|--------|----------|------|--------|------|
| 主题模式 | `lord_of_idea.theme_mode` | String：`'light'` / `'dark'` / `'system'` | `'system'` | 与 Material `ThemeMode` 对应 |
| 语言/地区 | `lord_of_idea.locale_language_code` | String：如 `'zh'`、`'en'`；空字符串表示跟随系统 | `''`（跟随系统） | 仅存 languageCode，Locale 构造为 `Locale(code)` |
| 首次启动标记（可选） | `lord_of_idea.first_launch_done` | bool | false | 用于引导页等，P0 可不读 |

**key 前缀**：**`lord_of_idea.`**（与包名一致，避免与系统或其他 key 冲突；新增设置项继续用此前缀）。

---

## 3. 国际化（l10n）

### 3.1 支持的语言/地区

| 语言 | Locale | arb 文件名 | 说明 |
|------|--------|-------------|------|
| 简体中文 | `Locale('zh')` | `app_zh.arb` | 支持 |
| 英文 | `Locale('en')` | `app_en.arb` | 支持 |

**支持列表**：P0 支持 **`[Locale('zh'), Locale('en')]`**（即 `['zh', 'en']`）；`supportedLocales` 与 arb 一一对应，新增语言时增加对应 `app_<locale>.arb` 并在 `l10n.yaml` 中配置。

### 3.2 文案 key 与占位（P0 必现文案）

以下为 P0 必现文案，在 arb 中定义；生成类为 `AppLocalizations`（Flutter 默认），使用方式 `AppLocalizations.of(context)!.***` 或 `context.l10n.***`（若启用 `generate: true` 的扩展）。

| 用途 | key | 默认值（中文 app_zh.arb） | 默认值（英文 app_en.arb） |
|------|-----|---------------------------|----------------------------|
| 应用名称 | `appTitle` | 灵感之主 | Lord of Idea |
| 首页 | `navHome` | 首页 | Home |
| 工具 | `navTools` | 工具 | Tools |
| 手帐 | `navJournal` | 手帐 | Journal |
| 市集 | `navMarket` | 市集 | Market |
| 我的 | `navMe` | 我的 | Me |
| 设置 | `settings` | 设置 | Settings |
| 主题 | `theme` | 主题 | Theme |
| 浅色 / 深色 / 跟随系统 | `themeLight` / `themeDark` / `themeSystem` | 浅色 / 深色 / 跟随系统 | Light / Dark / System |
| 语言 | `language` | 语言 | Language |

**arb 与生成配置**：使用 `flutter_localizations`（SDK） + `flutter gen-l10n`；**arb 目录**：**`lib/l10n`**；在项目根目录配置 `l10n.yaml`：`arb-dir: lib/l10n`、`template-arb-file: app_en.arb`（或 `app_zh.arb` 以中文为模板），生成代码输出到 `.dart_tool/flutter_gen/gen_l10n`（默认），供 `MaterialApp` 的 `localizationsDelegates` 与 `supportedLocales` 使用。

---

## 4. 实现位置

- **读取/写入设置**：在 `core/di/` 下通过 **`AppSettingsNotifier`**（见 [state_and_di_spec](state_and_di_spec.md)）读写上述 key；内部依赖 `LocalStorageService`（即 `lord_of_idea.*` key）。
- **应用层**：`MaterialApp`（或 `MaterialApp.router`）的 `locale`、`supportedLocales`、`localizationsDelegates`、`themeMode` 从 **`ref.watch(appSettingsProvider)`** 读取；设置页调用 `ref.read(appSettingsProvider.notifier).setThemeMode(...)` / `setLocale(...)` 写回存储并更新 Notifier 状态。
- **设置变更后通知 app**：通过 **Riverpod** 完成。`AppSettingsNotifier` 更新状态后，所有 `ref.watch(appSettingsProvider)` 的 Widget（如包裹 `MaterialApp` 的根或 `app.dart` 中的 `ConsumerWidget`）会自动重建，无需额外 InheritedWidget 或 setState；设置页修改后即全局生效。

---

## 5. 已决策内容汇总

- **持久化**：SharedPreferences；`shared_preferences: ^2.2.2`；由 `LocalStorageService` 封装。
- **key 前缀**：`lord_of_idea.`；设置项 key：`theme_mode`、`locale_language_code`、`first_launch_done`（全名带前缀）。
- **主题/语言默认值**：主题 `'system'`，语言 `''`（跟随系统）。
- **语言与 arb**：支持 `zh`、`en`；arb 目录 `lib/l10n`，文件 `app_zh.arb`、`app_en.arb`；l10n 生成类 `AppLocalizations`。
- **P0 文案 key**：`appTitle`、`navHome`、`navTools`、`navJournal`、`navMarket`、`navMe`、`settings`、`theme`、`themeLight`/`themeDark`/`themeSystem`、`language`（见 §3.2 表）。
- **设置变更通知**：Riverpod `appSettingsProvider`；设置页改 Notifier，根/App 层 `ref.watch(appSettingsProvider)` 自动重建。

实现时与 `core/di/`、`lib/l10n/` 及设置页保持一致。

---

*对应 [p0_deliverables](../project/p0_deliverables.md) 中「基础设置」项。*
