# P0 开发任务拆解与测试用例

本文档将 [P0 基础架设](project/p0_deliverables.md) 拆解为可执行的开发任务，并为每条任务撰写对应的测试用例。测试类型包括：**单元测试（Unit）**、**Widget 测试（Widget）**、**集成测试（Integration）**。实现时可将用例落地到 `test/` 下对应文件。

---

## 任务与测试索引

| 任务编号 | 开发内容概要 | 测试类型 | 测试文件建议 |
|----------|--------------|----------|--------------|
| P0-1 | 应用入口与壳（main、app、主题） | Widget | `test/app_test.dart` |
| P0-2 | 主题（core/theme 色板与多主题） | Unit + Widget | `test/core/theme/app_theme_test.dart` |
| P0-3 | 路由（go_router、redirect、占位页） | Unit + Widget | `test/core/router/app_router_test.dart`、`test/..._screen_test.dart` |
| P0-4 | 目录结构与占位 Screen | — | 无独立测试，由 P0-3 路由测试覆盖 |
| P0-5 | 本地存储（LocalStorageService） | Unit | `test/core/di/local_storage_test.dart` |
| P0-6 | 设置状态（AppSettingsNotifier） | Unit | `test/core/di/app_settings_test.dart` |
| P0-7 | DI 注册与 ProviderScope | Widget | `test/app_test.dart`、`test/.../settings_screen_test.dart` |
| P0-8 | 国际化（l10n、arb、locale） | Unit + Widget | `test/core/l10n_test.dart`、Widget 内文案断言 |
| P0-9 | 设置页（SettingsScreen）与持久化 | Widget + Integration | `test/features/.../settings_screen_test.dart`、`integration_test/app_test.dart` |
| P0-10 | 规范与质量（analyze、format、README） | — | 人工/CI 验收 |

---

## P0-1：应用入口与壳

**开发内容**  
- `main.dart`：仅做 `runApp(ProviderScope(child: MyApp()))`，无业务逻辑。  
- `app.dart`：定义 `MyApp`（ConsumerWidget 或 StatelessWidget），使用 `MaterialApp.router`，传入 `routerConfig`（来自 `ref.read(appRouterProvider)`）、`theme`、`darkTheme`、`themeMode`、`locale`、`supportedLocales`、`localizationsDelegates`；`themeMode` 与 `locale` 从 `ref.watch(appSettingsProvider)` 读取。

**验收**  
启动应用无报错，可见统一主题与导航。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P0-1-W1 | Widget | MyApp 在 ProviderScope 下能完成 build，不抛异常 | `pumpWidget(ProviderScope(child: MyApp()))`，不 expect throw。 |
| P0-1-W2 | Widget | MaterialApp 存在且使用 router 配置 |  find.byType(MaterialApp)，并验证 routerConfig 非 null（或通过 Key 找到 MaterialApp）。 |

---

## P0-2：主题（core/theme）

**开发内容**  
- 在 `lib/core/theme/` 下实现 `AppTheme`（或等价命名），提供 `lightTheme`、`darkTheme`，色板、字体、间距与圆角符合 [theme_spec](../design/theme_spec.md)。  
- 浅色/深色 ColorScheme 与 theme_spec 中色值一致（至少 primary、surface、background 等关键色）。

**验收**  
启动后界面为复古中世纪风格；切换深色后色板切换正确。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P0-2-U1 | Unit | lightTheme 的 colorScheme.primary 为 #6B2D3C | 对 `AppTheme.lightTheme.colorScheme.primary` 做色值相等断言（如 `Color(0xFF6B2D3C)`）。 |
| P0-2-U2 | Unit | darkTheme 的 surface 为 #2C2620 | 对 `AppTheme.darkTheme.colorScheme.surface` 做色值相等断言。 |
| P0-2-U3 | Unit | lightTheme 的 textTheme 存在且 headlineLarge 非 null | 断言 `theme.textTheme.headlineLarge != null`（可选：字号 28）。 |
| P0-2-W1 | Widget | 使用 light 主题时，子 Widget 能获得该 ThemeData | pumpWidget 使用 `MaterialApp(theme: AppTheme.lightTheme, ...)`，子组件内 `Theme.of(context)` 的 colorScheme.primary 与 P0-2-U1 一致。 |

---

## P0-3：路由（go_router、redirect、占位页）

**开发内容**  
- 引入 go_router，在 `lib/core/router/` 定义路由表：`/`、`/home`、`/tools`、`/journal`、`/journal/:id`、`/journal/:id/page/:pageId`、`/shared-journal/:id`、`/settings`；对应组件见 [routes_spec](../technical/routes_spec.md)。  
- 实现 redirect：`/` → `/home`；无效或缺失的 `journal/:id` 可重定向到 `/journal`（具体规则见 routes_spec）。  
- 通过 `appRouterProvider` 提供 GoRouter 实例；各占位 Screen 至少存在且可被路由解析。

**验收**  
访问 `/` 跳转到 `/home`；访问 `/settings` 显示设置页；访问 `/journal/xxx` 时若需重定向则到 `/journal`。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P0-3-U1 | Unit | redirect：当 location 为 `/` 时返回 `/home` | 使用 GoRouter 的 redirect 回调或单独 redirect 函数，传入 state 的 location 为 `/`，期望返回 `/home`。 |
| P0-3-U2 | Unit | redirect：当 location 为 `/journal` 时不变 | 传入 `/journal`，期望返回 null 或原 location（不重定向）。 |
| P0-3-U3 | Unit | 路由表包含 `/home`、`/settings`、`/journal`、`/journal/:id` | 对 GoRouter 的 configuration 或 routes 做存在性检查（依 go_router API）。 |
| P0-3-W1 | Widget | 导航到 `/home` 后可见 HomeScreen | pumpApp 使用 appRouterProvider 的 router，执行 `router.go('/home')`，pump，find.byType(HomeScreen)。 |
| P0-3-W2 | Widget | 导航到 `/settings` 后可见 SettingsScreen | 同上，`router.go('/settings')`，find.byType(SettingsScreen)。 |
| P0-3-W3 | Widget | 初始 location 为 `/` 时，redirect 后最终显示 HomeScreen | 使用 router 且 initialLocation 为 `/`，pump 后应显示 HomeScreen（或 location 为 `/home`）。 |
| P0-3-W4 | Widget | 各占位 Screen 能 build 且包含可识别内容 | 对 HomeScreen、ToolsScreen、JournalListScreen、JournalDetailScreen、SharedJournalScreen、SettingsScreen 分别 pumpWidget（提供必要 Provider），find 标题或关键文案。 |

---

## P0-4：目录结构与占位 Screen

**开发内容**  
- 按 [code_structure](code_structure.md) 建立目录：`core/di`、`core/router`、`core/theme`、`core/l10n`、`core/utils`；`features/divination`、`features/journal`、`features/shared_journal`（各含 `data/domain/presentation`）；`shared/models`、`shared/widgets`、`shared/services`。  
- 各占位 Screen 放在对应 feature 的 `presentation/` 或约定位置，命名：`HomeScreen`、`ToolsScreen`、`JournalListScreen`、`JournalDetailScreen`、`SharedJournalScreen`、`SettingsScreen`。

**验收**  
新代码可明确归属；路由能解析到上述 Screen。

**测试**  
由 P0-3 路由与 Screen 的 Widget 测试覆盖；无需单独测试「目录存在」。

---

## P0-5：本地存储（LocalStorageService）

**开发内容**  
- 实现 `LocalStorageService`，封装 `SharedPreferences`，提供至少：`getString(String key)`、`setString(String key, String value)`、`getBool`/`setBool`（用于 first_launch_done）；key 使用前缀 `lord_of_idea.`。  
- 在测试中使用 `SharedPreferences.setMockInitialValues({})` 或等价方式，避免依赖真实磁盘。

**验收**  
设置写入后，通过同一 Service 读回一致；重启应用（或重新获取 Service）后仍可读回。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P0-5-U1 | Unit | setString 后 getString 返回相同值 | 使用 mock SharedPreferences，setString('lord_of_idea.theme_mode', 'dark')，getString 得 'dark'。 |
| P0-5-U2 | Unit | 未设置过的 key 返回 null 或默认值 | getString('lord_of_idea.unknown') 为 null；或 getString 返回可选的默认值。 |
| P0-5-U3 | Unit | setBool / getBool 行为一致 | setBool('lord_of_idea.first_launch_done', true)，getBool 得 true。 |
| P0-5-U4 | Unit | key 使用约定前缀 | 实现中使用的 key 包含 `lord_of_idea.`（可在测试里通过 mock 的调用参数或实际 key 列表断言）。 |

---

## P0-6：设置状态（AppSettingsNotifier）

**开发内容**  
- 实现 `AppSettingsNotifier`，依赖 `LocalStorageService`（通过 `localStorageProvider` 注入）；状态包含：`themeMode`（ThemeMode）、`locale`（Locale? 或 languageCode）。  
- 提供 `setThemeMode(ThemeMode)`、`setLocale(Locale?)`（或 setLanguageCode），写入 LocalStorageService 并更新状态。  
- 初始化时从 LocalStorageService 读取 key：`lord_of_idea.theme_mode`、`lord_of_idea.locale_language_code`，映射为 ThemeMode 与 Locale。

**验收**  
设置页修改主题/语言后，App 主题与语言立即更新；重启后仍为上次设置。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P0-6-U1 | Unit | 初始状态：无持久化时 themeMode 为 system，locale 为 null 或空 | 使用 mock LocalStorage（空 map），创建 AppSettingsNotifier 并 init，读取 state.themeMode == ThemeMode.system。 |
| P0-6-U2 | Unit | setThemeMode(ThemeMode.dark) 后 state 为 dark，且写入存储 | mock LocalStorage，调用 notifier.setThemeMode(ThemeMode.dark)，断言 state.themeMode == dark，且 mock 收到 setString('lord_of_idea.theme_mode', 'dark')。 |
| P0-6-U3 | Unit | 从持久化恢复：存储中为 'dark' 时，state.themeMode 为 dark | mock 初始值为 {'lord_of_idea.theme_mode': 'dark'}，notifier 初始化后 state.themeMode == ThemeMode.dark。 |
| P0-6-U4 | Unit | setLocale 写入 lord_of_idea.locale_language_code 并从 state 读回 | setLocale(Locale('zh'))，state 的 locale 或 languageCode 为 'zh'，mock 收到 'lord_of_idea.locale_language_code' -> 'zh'。 |

---

## P0-7：DI 注册与 ProviderScope

**开发内容**  
- 在 `core/di/` 定义 `localStorageProvider`、`appSettingsProvider`（NotifierProvider<AppSettingsNotifier>）；在 `core/router/` 定义 `appRouterProvider`。  
- `main.dart` 使用 `ProviderScope` 包裹 `MyApp`；`MyApp` 内通过 `ref.read(appRouterProvider)`、`ref.watch(appSettingsProvider)` 获取路由与设置。

**验收**  
任意页通过 `ref.read(appSettingsProvider)` / `ref.watch(appSettingsProvider)` 可读写设置；`ref.read(appRouterProvider)` 得到同一 GoRouter 实例。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P0-7-W1 | Widget | 在 ProviderScope 内，子 Widget 能通过 Consumer 读取 appSettingsProvider | pumpWidget(ProviderScope(child: Consumer(builder: (_, ref, __) { final s = ref.watch(appSettingsProvider); return Text('${s.themeMode}'); })))，find.text 包含 'system' 或等价。 |
| P0-7-W2 | Widget | appRouterProvider 与 MaterialApp.router 使用的 router 一致 | 在测试中 ref.read(appRouterProvider) 与 MaterialApp 的 routerConfig 指向同一实例（或 go('/settings') 后界面为 SettingsScreen）。 |

---

## P0-8：国际化（l10n）

**开发内容**  
- 配置 `l10n.yaml`：`arb-dir: lib/l10n`，`template-arb-file: app_zh.arb` 或 `app_en.arb`。  
- 提供 `app_zh.arb`、`app_en.arb`，包含 P0 必现 key：`appTitle`、`navHome`、`navTools`、`navJournal`、`settings`、`theme`、`themeLight`、`themeDark`、`themeSystem`、`language`。  
- `MaterialApp` 的 `supportedLocales` 含 `Locale('zh')`、`Locale('en')`，`localizationsDelegates` 含生成类委托；`locale` 从 `appSettingsProvider` 来。

**验收**  
切换语言后，设置页与导航文案切换为对应语言；重启后语言保持。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P0-8-U1 | Unit | 生成类 AppLocalizations 存在且可实例化 | 对 `AppLocalizations.of(context)` 或生成的 `context.l10n` 做非 null 断言（需 BuildContext）。 |
| P0-8-W1 | Widget | locale 为 zh 时，某处显示中文文案（如「设置」） | pumpWidget MaterialApp(locale: Locale('zh'), localizationsDelegates: [...], supportedLocales: [...], home: ... 使用 l10n.settings)，find.text('设置')。 |
| P0-8-W2 | Widget | locale 为 en 时，同一 key 显示英文（如 "Settings"） | 同上，locale: Locale('en')，find.text('Settings')。 |

---

## P0-9：设置页（SettingsScreen）与持久化

**开发内容**  
- 实现 `SettingsScreen`：展示主题选项（浅色/深色/跟随系统）、语言选项（中文/英文/跟随系统）；选择后调用 `ref.read(appSettingsProvider.notifier).setThemeMode(...)` / `setLocale(...)`。  
- 依赖 `appSettingsProvider`；无需直接依赖 LocalStorageService（由 Notifier 内部使用）。

**验收**  
在设置页切换主题后，整 app 主题立即变化；切换语言后文案变化；重启应用后主题与语言保持。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P0-9-W1 | Widget | SettingsScreen 含有「主题」「语言」或等价文案 | pumpWidget 提供 ProviderScope + appSettingsProvider，进入 SettingsScreen，find.text 包含 theme/language 对应文案。 |
| P0-9-W2 | Widget | 点击「深色」后，上层 Theme 变为 dark | 使用 ProviderScope + 含 App 的子树，先进入设置页，tap 深色选项，pump，验证 Theme.of(context).brightness == Brightness.dark（或 colorScheme 为 dark）。 |
| P0-9-W3 | Widget | 点击语言「中文」后，某处文案为中文 | 同上，tap 中文，pump，find.text('设置') 或等价。 |
| P0-9-I1 | Integration | 从启动到打开设置页、切换主题，无崩溃且界面正确 | 启动 app → 导航到 /settings → 切换主题 → 验证主题变化（可选：重启后再次验证持久化）。 |

---

## P0-10：规范与质量

**开发内容**  
- `analysis_options.yaml` 包含 `include: package:flutter_lints/flutter.yaml`。  
- README 已含环境要求、`flutter pub get`、`flutter run`、`flutter build`、`flutter test` 及文档索引。  
- 执行 `dart format lib/ test/`、`flutter analyze` 无错误。

**验收**  
新人按 README 可跑起项目；CI 可跑 format + analyze。

### 对应测试用例

| 编号 | 类型 | 描述 | 断言/步骤 |
|------|------|------|-----------|
| P0-10-C1 | 人工/CI | `flutter analyze` 通过 | 在 CI 或本地执行，exit code 0。 |
| P0-10-C2 | 人工/CI | `dart format --set-exit-if-changed lib/ test/` 通过 | 未格式化时 exit code 非 0；format 后通过。 |
| P0-10-C3 | 人工 | README 包含运行与构建说明 | 检查 README 是否包含 flutter run、flutter build、flutter test。 |

---

## 测试文件目录建议

```
test/
├── app_test.dart                    # P0-1：MyApp、ProviderScope
├── core/
│   ├── theme/
│   │   └── app_theme_test.dart      # P0-2：主题色板与 ThemeData
│   ├── router/
│   │   └── app_router_test.dart     # P0-3：redirect、路由表、导航
│   └── di/
│       ├── local_storage_test.dart  # P0-5：LocalStorageService
│       └── app_settings_test.dart   # P0-6：AppSettingsNotifier
├── features/
│   ├── home/
│   │   └── home_screen_test.dart    # P0-3-W4：HomeScreen
│   ├── settings/                     # 或 core/settings
│   │   └── settings_screen_test.dart # P0-7、P0-9：SettingsScreen
│   └── ...                           # 其他 Screen 占位测试
├── l10n_test.dart                    # P0-8：可选，若需单独测生成类
└── widget_test.dart                  # 保留默认或改为 smoke test
integration_test/
└── app_test.dart                     # P0-9-I1：启动→设置→切换主题
```

---

## 与 P0 交付清单的对应

| [p0_deliverables](project/p0_deliverables.md) 交付项 | 本文档任务 | 验收测试 |
|-----------------------------------------------------|------------|----------|
| 应用入口与壳 | P0-1、P0-2 | P0-1-W1/W2，P0-2-U1/U2/U3/W1 |
| 路由 | P0-3、P0-4 | P0-3-U1/U2/U3，P0-3-W1～W4 |
| 目录结构 | P0-4 | 由 P0-3 覆盖 |
| 状态管理与 DI | P0-5、P0-6、P0-7 | P0-5-U1～U4，P0-6-U1～U4，P0-7-W1/W2 |
| 基础设置 | P0-8、P0-9 | P0-8-U1/W1/W2，P0-9-W1/W2/W3，P0-9-I1 |
| 规范与质量 | P0-10 | P0-10-C1/C2/C3 |

---

*本文档随 P0 实现可增补具体测试代码片段或更新文件路径。*
