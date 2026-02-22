# 状态管理与依赖注入规格

本文档约定 P0 阶段的状态管理选型、DI 方式及在 core 中需注册的 Provider/服务，与 [架构指南](../project/architecture_guide.md) 一致。

---

## 1. 状态管理选型

| 方案 | 说明 | 决策 |
|------|------|--------|
| Riverpod | 推荐与 go_router 搭配；Provider 即 DI | **采用** |
| Bloc | 事件驱动，适合复杂流程 | 不采用（保持单一方案，便于统一 DI） |

**决策**：最终采用 **Riverpod**（与架构指南一致，与 go_router 搭配成熟，Provider 即 DI，后续可用 Notifier/AsyncNotifier 扩展）。  
**依赖**：`flutter_riverpod: ^2.5.0`（与 Dart 3.11 兼容，按 ^ 可接受小版本升级）。

---

## 2. 依赖注入方式

- **Riverpod 即 DI**：所有可注入服务（路由、设置、本地存储、后续 Repository）均通过 `Provider` / `FutureProvider` / `NotifierProvider` 等暴露；在 `core/di/` 定义 core 级 Provider，各 feature 内可定义本模块 Provider；**根 Widget 使用 ProviderScope 包裹**。
- Bloc 的 DI 方式：不适用（已选 Riverpod）。

---

## 3. 需在 core 中注册的 Provider/服务（P0）

以下为 P0 阶段建议注册的项及约定名称。

| 类型 | 提供物名称/用途 | 实现类或 Provider 名 | 备注 |
|------|------------------|------------------------------|------|
| 路由 | GoRouter 实例 | `appRouterProvider` → 返回 `GoRouter(...)` | 供 `MaterialApp.router` 使用；定义在 `core/router/` |
| 主题/设置 | 主题模式、语言等读取与写入 | `appSettingsProvider`（NotifierProvider），Notifier 类：`AppSettingsNotifier`；内部依赖 `LocalStorageService` 持久化 | 供设置页与 `app.dart` 使用；定义在 `core/di/` 或 `core/settings/` |
| 本地存储 | 键值存储（SharedPreferences 封装） | `localStorageProvider` → 返回 `LocalStorageService`（封装 `SharedPreferences`，提供 get/set 等）；底层依赖 `shared_preferences` | 供设置持久化使用；`AppSettingsNotifier` 依赖此 Provider |

**可选（P0 可不实现）**：

| 类型 | 提供物名称/用途 | 决策 |
|------|------------------|--------|
| 手帐 Repository | 手帐 CRUD（P2 起） | P0 不注册；P2 在 `features/journal/` 内增加 `journalRepositoryProvider` 等 |
| 用户/认证 | 登录态（P4 起） | P0 不注册；P4 再增加认证相关 Provider |

---

## 4. 实现位置

- **Provider 定义**：路由相关放在 `core/router/`（如 `app_router.dart` 内或同目录 `app_router_provider.dart`）；设置与本地存储放在 `core/di/`（如 `app_settings_provider.dart`、`local_storage_provider.dart`），便于 core 层统一维护。
- **根包裹**：在 **`main.dart`** 中使用 `ProviderScope` 包裹根 Widget：`runApp(ProviderScope(child: MyApp()))`，保证全局可读 Provider；`MaterialApp.router` 的 `routerConfig` 在 `MyApp` 内通过 `ref.watch(appRouterProvider)` 获取（即 `MyApp` 为 `ConsumerWidget` 或在其子层使用 `Consumer`/`ref.watch`）。

---

## 5. 验收

- 在任意一个占位页（如设置页）通过 DI 获取「设置」或「本地存储」并成功读写一次（如主题模式），即视为 P0 DI 验收通过。
- **验收用页面与 Provider**：**设置页 `SettingsScreen`**；调用 **`appSettingsProvider`**（或 `ref.watch(appSettingsProvider)` / `ref.read(appSettingsProvider.notifier)`）读写主题模式（或语言），并确认重启应用后设置保持。

---

## 6. 已决策内容汇总

- **状态管理**：Riverpod；`flutter_riverpod: ^2.5.0`。
- **DI 方式**：Riverpod Provider 即 DI，无单独 get_it/Bloc 注入。
- **core 注册**：`appRouterProvider`（路由）、`appSettingsProvider` + `AppSettingsNotifier`（设置）、`localStorageProvider` + `LocalStorageService`（本地存储）；手帐/认证 P0 不注册。
- **根包裹**：`main.dart` 中 `ProviderScope` 包裹 `MyApp`。
- **验收**：`SettingsScreen` 通过 `appSettingsProvider` 读写主题（或语言），重启后持久化生效即通过。

---

*对应 [p0_deliverables](../project/p0_deliverables.md) 中「状态管理与 DI」项。*
