# 装饰系统规格（P3）

本文档约定 P3 阶段「手帐增强」中**贴纸、胶带等装饰**的数据模型、存储方式、与页/块的关联及交互边界。与 [project_manager P3](../project/project_manager.md)、[手帐数据模型](journal_data_models_spec.md)、[p3_deliverables](../project/p3_deliverables.md) 一致。

---

## 1. 设计原则

- **页级归属**：装饰归属**页面**（pageId），不直接归属块；同一页内装饰与块一起渲染、一起导出，顺序用 zIndex 控制。
- **易扩展**：装饰类型用字符串枚举（如 `sticker`、`tape`），新增类型仅增枚举与素材路径规则，不破坏现有数据。
- **内置优先**：首版使用**内置素材**（assets）；预留「用户图片」扩展（如 resourceType: "user", resourceId: 本地路径）。

---

## 2. 装饰类型（DecorationKind）

| 类型值 | 说明 | 素材形态 |
|--------|------|----------|
| sticker | 贴纸 | 单张图片，透明底 PNG 推荐 |
| tape | 胶带 | 条带图片，可平铺或拉伸 |

**扩展**：后续可增加 `stamp`（印章）、`frame`（边框）等，在枚举与素材目录中追加即可。

---

## 3. 装饰实例（Decoration）— 页上的一条记录

每条记录表示「某一页上的一个装饰实例」：类型、素材 ID、位置、尺寸、旋转等。

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | String | 是 | 本地唯一 ID（UUID/nanoid） |
| pageId | String | 是 | 所属页面 ID，外键 |
| kind | String | 是 | `sticker` \| `tape` |
| resourceId | String | 是 | 素材标识；内置素材如 `sticker_01`、`tape_02`，对应 assets 路径见 §5 |
| x | double | 是 | 相对页左上角 x（逻辑单位，如 pt），导出时按比例换算 |
| y | double | 是 | 相对页左上角 y |
| width | double | 是 | 显示宽度（逻辑单位） |
| height | double | 是 | 显示高度；胶带可为窄条 |
| rotationDegrees | double | 否 | 旋转角度，默认 0 |
| zIndex | int | 否 | 层级，默认 0；数值大在上层 |
| createdAt | DateTime | 是 | 创建时间，ISO8601 UTC |

**约束**：同一 `pageId` 下 `id` 唯一；位置与尺寸为逻辑值，与「页画布」坐标系一致（例如与阅读视图同比例）。

**实现位置**：  
- 模型：`shared/models/decoration.dart` 或 `features/journal/domain/entities/decoration.dart`；  
- 存储：独立表 `journal_decorations`（drift），主键 `id`，索引 `page_id`；删页时级联删除该页装饰。

---

## 4. 交互边界（技术默认，产品可覆盖）

- **添加**：从装饰选择器（按 kind 筛选）选一个素材，在当前页画布上点击或拖入，生成默认尺寸并写入表。  
- **拖拽**：可拖拽移动，更新 x、y 并持久化。  
- **缩放**：捏合或拖拽控制点更新 width、height。  
- **旋转**：可选双指旋转或按钮，更新 rotationDegrees。  
- **删除**：长按或选中后删除按钮，从表删除。  
- **层级**：同一页内用 zIndex 排序；产品可提供「置于顶层/底层」或拖拽排序 zIndex。

具体 UI（选择器样式、默认尺寸、是否支持多选）见 [p3_deliverables § 装饰系统](../project/p3_deliverables.md#装饰系统--待产品填写)。

---

## 5. 内置素材路径与 ID 规则

**目录约定**（易理解、易扩展）：

- 贴纸：`assets/decorations/stickers/{resourceId}.png`  
  示例：`sticker_01` → `assets/decorations/stickers/sticker_01.png`
- 胶带：`assets/decorations/tapes/{resourceId}.png`  
  示例：`tape_01` → `assets/decorations/tapes/tape_01.png`

**resourceId 命名**：小写字母 + 数字 + 下划线，如 `sticker_01`、`tape_flower`。首版可内置 5～10 个贴纸、5～10 个胶带，具体数量与分类由产品定，见 [p3_deliverables](../project/p3_deliverables.md)。

**扩展**：若支持用户图片，可增加 `resourceType: "user"`，`resourceId` 为本地文件 path 或相对应用目录路径；表结构可增加 `resourceType` 列，默认 `"builtin"`。

---

## 6. 与手帐数据模型的衔接

- **不修改块表**：装饰独立表 `journal_decorations`，与 `journal_blocks` 并列，同属 `journal_pages` 下。  
- **迁移**：drift schema version 递增，新增 `journal_decorations` 表及索引 `page_id`；删页时外键级联或应用层删除该页所有装饰。  
- **导出**：渲染单页时先画背景与分区线，再按 zIndex 绘制块与装饰（块与装饰可交错按 zIndex 排序），见 [journal_visual_export_spec](journal_visual_export_spec.md)。

---

## 7. 需要产品填写的内容（汇总）

- 装饰**类型与命名**、l10n key。  
- **素材来源**（仅内置 / 支持用户图）。  
- **与页/块关联方式**（当前为页级；若需块级再扩展）。  
- **默认素材数量与分类**。  

详见 [p3_deliverables § 装饰系统](../project/p3_deliverables.md#装饰系统--待产品填写)。

---

*本文档对应 [p3_deliverables](../project/p3_deliverables.md) 中「装饰系统」项。*
