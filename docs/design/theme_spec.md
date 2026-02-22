# 主题规范

本文档约定 P0 阶段应用主题：色板、字体、间距及多主题策略，供 `app.dart` 与 `core/theme/` 实现使用。

---

## 0. 美术方向

**整体风格**：**复古中世纪（Retro Medieval）**

应用视觉上应传达中世纪手抄本、石砌城堡与羊皮纸的质感：主色采用酒红/深褐与金属感金棕，背景以暖色羊皮纸/石灰色为主；字体选用带古典衬线的显示字体与易读正文体；圆角适度偏小以贴近石板、木框的硬朗感。装饰元素可参考纹章、花体边框与粗线分割。

---

## 1. 色板（ColorScheme / 语义色）

以下色值贴合复古中世纪风格（暖酒红、金棕、羊皮纸、深褐）。

| 用途 | 变量/语义名 | 色值 | 备注 |
|------|-------------|------|------|
| 主色（Primary） | primary | `#6B2D3C` | 酒红，用于主要按钮、选中态、纹章强调 |
| 主色容器 | primaryContainer | `#E8D5D0` | 浅玫瑰/羊皮纸上的主色块 |
| 次要色（Secondary） | secondary | `#8B7355` | 金棕/古铜，次要按钮、标签、金属感 |
| 次要色容器 | secondaryContainer | `#F5E6C8` | 淡金/奶油 |
| 背景 | background / surface | `#F4E9DC` | 羊皮纸色页面背景 |
| 表面/卡片 | surface | `#EDE4D8` | 略深的羊皮纸，卡片、抽屉等 |
| 错误 | error | `#722F37` | 深酒红，错误提示、危险操作 |
| 错误容器 | errorContainer | `#F5D5D5` | 浅红 |
| 轮廓/边框 | outline | `#6B5B4F` | 深褐灰，边框、分割线 |
| 表面变体 | surfaceVariant | `#DDD0C0` | 浅褐，可选区分块 |

**说明**：若使用 Material 3，可基于 `ColorScheme.fromSeed(seedColor: Color(0xFF6B2D3C))` 生成后再按上表覆盖；种子色：`#6B2D3C`。

---

## 2. 字体（Typography）

复古中世纪风格：大标题与标题使用衬线显示字体，正文使用易读衬线体。

| 用途 | 样式名 | 取值 | 备注 |
|------|--------|------|------|
| 大标题 | displayLarge / headlineLarge | 字号：28，字重：Bold (700)，字体族：Cinzel | 如首页标题、章节首字 |
| 标题 | titleLarge / titleMedium | 字号：20 / 18，字重：Medium (500)，字体族：Cinzel | 页面标题、卡片标题 |
| 正文 | bodyLarge / bodyMedium | 字号：16 / 14，字重：Regular (400)，字体族：Cormorant Garamond | 正文、列表项 |
| 辅助/说明 | bodySmall / labelSmall | 字号：12，字重：Regular，字体族：Cormorant Garamond | 说明、时间戳 |

**字体族**：  
- **显示/标题**：`GoogleFonts.cinzel()`（Cinzel）— 古典罗马衬线，适合大标题与标题。  
- **正文与辅助**：`GoogleFonts.cormorantGaramond()`（Cormorant Garamond）— 易读衬线，适合长文。  
- 若使用本地字体，可在 `pubspec.yaml` 的 `fonts` 下添加对应 `.ttf`/`.otf` 路径（如 `assets/fonts/Cinzel-Regular.ttf`）；P0 建议优先用 `google_fonts` 包在线加载上述两款。

---

## 3. 间距与圆角

复古中世纪风格：以 8 为基准倍数，圆角偏小以贴近石板/木框的硬朗感。

| 名称 | 建议变量名 | 取值 | 用途 |
|------|------------|------|------|
| 基础间距单位 | spacingUnit | `8.0` | 4、8、12、16、24… 的基准 |
| 页面边距 | pagePadding | `24.0` | 页面左右/上下边距 |
| 卡片圆角 | cardRadius | `8.0` | 卡片、对话框圆角（略方更贴中世纪） |
| 按钮圆角 | buttonRadius | `6.0` | 按钮圆角 |

---

## 4. 多主题

| 主题名称 | 说明 | 色板约定 |
|----------|------|----------|
| 浅色（light） | 默认浅色 | 使用第 1 节色板即可，无需额外覆盖。 |
| 深色（dark） | 深色模式 | background: `#1C1916`，surface: `#2C2620`，primary: `#C9A9A0`，secondary: `#B8A088`，outline: `#6B5B4F`，onBackground/onSurface: `#EDE4D8`；保持复古中世纪暖褐基调。 |
| 跟随系统 | ThemeMode.system | 无需额外色值，使用上述 light/dark 定义。 |

**决策**：P0 提供的主题列表：**[浅色, 深色, 跟随系统]**；用户可在设置中切换，并持久化到本地。

---

## 5. 实现位置

- **定义**：`lib/core/theme/` 下（如 `app_theme.dart` 或 `app_color_scheme.dart`）。
- **使用**：在 `app.dart` 的 `ThemeData(theme: ..., darkTheme: ...)` 中引用；主题模式由设置持久化并传入 `MaterialApp.themeMode`。

---

## 6. 规范汇总（已按复古中世纪风格填写）

- **色板**：primary `#6B2D3C`、secondary `#8B7355`、surface `#EDE4D8`、background `#F4E9DC`、error `#722F37` 等；seedColor 可选 `#6B2D3C`。
- **字体**：displayLarge/headlineLarge 用 Cinzel 28pt Bold；title 用 Cinzel 18–20pt Medium；body/bodySmall 用 Cormorant Garamond 14–16pt/12pt；可选 `google_fonts` 或本地字体路径。
- **间距与圆角**：spacingUnit `8.0`、pagePadding `24.0`、cardRadius `8.0`、buttonRadius `6.0`。
- **多主题**：浅色使用第 1 节色板；深色使用第 4 节深色色板；P0 主题列表为 [浅色, 深色, 跟随系统]。

实现时请保持本文档与 `lib/core/theme/`、`app.dart` 中的主题配置一致。

---

*对应 [p0_deliverables](../project/p0_deliverables.md) 中「应用入口与壳」。*
