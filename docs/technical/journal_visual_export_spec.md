# 手帐视觉与导出规格（P3）

本文档约定 P3 阶段「手帐增强」中**手帐内页视觉样式**与**单页/整本导出**的技术方案。与 [project_manager P3](../project/project_manager.md)、[主题规范](../design/theme_spec.md)、[p3_deliverables](../project/p3_deliverables.md) 一致。

---

## 1. 设计原则

- **与 app 主题协调**：内页色板、线色使用 [theme_spec](../design/theme_spec.md) 的语义色（如 outline、surfaceVariant、background），保证风格统一。
- **可扩展**：内页主题以 ID 枚举（如 `parchment`、`grid`、`plain`），后续可加更多主题或用户自定义背景图。
- **导出即所见**：导出内容与阅读视图一致（块 + 装饰 + 内页背景），分辨率与 DPI 可配置。

---

## 2. 手帐内页主题（PageTheme）

**作用**：阅读/编辑时，手帐页的背景与分区线样式。

| 字段/ID | 说明 | 技术默认 |
|---------|------|----------|
| id | 主题唯一 ID | `parchment`、`grid`、`plain` |
| backgroundType | 背景类型 | `color` \| `texture` |
| backgroundColor | 背景色（backgroundType=color） | 使用 theme_spec 的 surface/background |
| backgroundImagePath | 背景图路径（backgroundType=texture） | 如 `assets/journal_themes/parchment_bg.png` |
| showGrid | 是否显示网格/横线 | `parchment`: false, `grid`: true, `plain`: false |
| gridLineColor | 线色 | theme 的 outline 或 surfaceVariant |
| gridSpacing | 网格间距（pt） | 24.0 |
| padding | 页内容边距（pt） | 16.0 |

**归属**：可挂在 **手帐级别**（Journal）或 **页级别**（Page）。技术默认：**手帐级别**，即一本手帐选用一个内页主题，该手帐下所有页共用；若产品需要「每页不同主题」可在 Page 上增加可选 `pageThemeId` 覆盖。

**实现位置**：  
- 配置：`lib/core/theme/` 或 `lib/features/journal/domain/` 下 `page_theme.dart`，内置 2～3 种主题常量；  
- 应用：手帐阅读/编辑页根据 `Journal.pageThemeId`（或 Page 覆盖）取主题，绘制背景与网格后再绘制块与装饰。

**手帐/页表扩展**（与 [journal_data_models_spec](journal_data_models_spec.md) 衔接）：

- Journal 表增加可选列 `page_theme_id`（TEXT，默认 `parchment` 或 null）；  
- 若支持每页不同主题，Page 表增加可选列 `page_theme_id`。

---

## 3. 导出范围与格式

**范围**：

- **单页导出**：当前页（块 + 装饰 + 内页背景），不含其他页。  
- **整本导出**：多页按 orderIndex 顺序合并；每页渲染同单页，再拼接为多页图或 PDF。

**格式**（技术默认，产品可定稿调整）：

| 格式 | 说明 | 实现要点 |
|------|------|----------|
| PNG | 单页或每页一图 | 使用 Flutter 的 `RepaintBoundary` + `toImage()` 或 `RenderRepaintBoundary.toImage()`，像素比 2.0 或 3.0 以获清晰图；可配置 maxWidth/maxHeight 限制尺寸 |
| PDF（整本） | 多页合并为一个 PDF | 使用 `pdf` 包（如 `pdf` + `printing`）或 `syncfusion_flutter_pdf`；每页渲染为一张图后写入 PDF 页，或直接绘制 PDF 图形（文字、图片） |

**分辨率**：逻辑尺寸与阅读视图一致（或按设备像素比放大）；导出 PNG 时建议 2x～3x 以兼顾清晰度与文件大小。具体数值（如 1242pt 宽）可由产品定。

**实现位置**：  
- 单页截图：在 `JournalDetailScreen` 或单独 ExportService 中，对当前页内容用 `GlobalKey` 绑定 `RepaintBoundary`，调用 `toImage(pixelRatio: 2.0)` 等；  
- 整本 PDF：遍历页，每页渲染为 Image 或 Widget 转 Image，再写入 `pdf` 包生成的 Document；  
- 入口：手帐详情 AppBar 菜单「导出本页」「导出整本」，见 [p3_deliverables](../project/p3_deliverables.md)。

---

## 4. 导出内容与顺序

- **层级顺序**：与阅读视图一致——先画内页背景（含网格），再按块 orderIndex 与装饰 zIndex 混合排序绘制（块与装饰可共用同一 z 空间，如块 0、装饰 1、块 2… 或按 zIndex 统一排序）。  
- **内容**：当前页所有块（含 text、dice、poem_slip、divination、interpretation）+ 该页所有装饰；不包含其他页。  
- **封面**：若整本导出含「封面页」，可使用 Journal.coverPath 或第一页缩略图；产品可定是否包含封面页。

---

## 5. 需要产品填写的内容（汇总）

- **内页样式**：种类数、是否跟随 app 主题、网格线开关与样式。  
- **导出入口**：单页/整本入口位置、是否区分「导出为图片」「导出为 PDF」。  
- **导出格式优先级**：首版必须 PNG/PDF 或两者。  
- **导出相关 l10n**。  

详见 [p3_deliverables § 视觉与主题、§ 导出](../project/p3_deliverables.md)。

---

*本文档对应 [p3_deliverables](../project/p3_deliverables.md) 中「视觉与主题」「导出」项。*
