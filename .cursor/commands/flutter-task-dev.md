# Flutter 按任务编号开发

根据用户提供的 **任务编号**（如 `P0-1`、`P1-2`、`P2-3`）完成开发：查找任务内容 → 实现 → 编写/补全测试 → 代码自检与运行测试。优先使用 Dart/Flutter MCP 工具（user-dart）。

**任务编号格式**：**P\<阶段\>-\<任务\>**。前一个数字为开发阶段（P0、P1、P2…），后一个数字为该阶段内的具体任务编号（1、2、3…）。例如：`P0-1`、`P1-2`、`P2-3`。

---

## 1. 解析任务编号

- 用户会输入任务编号，格式为 **P\<阶段\>-\<任务\>**，例如：`P0-1`、`P1-2`、`P2-3`。
- 解析出 **阶段**（phase，如 0、1、2）与 **任务号**（task，如 1、2、3）。
- 若用户未输入或格式无法解析（如缺少 `P`、没有 `-`），主动询问：「请提供任务编号，例如 P0-1 或 P1-2」。

---

## 2. 查找任务内容

- **任务文档路径**：按阶段对应文件 `docs/development/p\<阶段\>_tasks_and_tests.md`。  
  - 例如：P0-1 → `docs/development/p0_tasks_and_tests.md`；P1-2 → `docs/development/p1_tasks_and_tests.md`；P2-3 → `docs/development/p2_tasks_and_tests.md`。
- 若该文件不存在，告知用户：「阶段 P\<阶段\> 的任务文档尚未创建（缺少 `docs/development/p\<阶段\>_tasks_and_tests.md`）」，并停止后续步骤。
- 在对应文档中定位以 **「## P\<阶段\>-\<任务\>：」** 开头的章节（与用户输入完全一致），例如 `## P1-2：`、`## P2-3：`。
- 阅读该章节中的：
  - **开发内容**：要实现的代码与文件位置。
  - **验收**：完成标准。
  - **对应测试用例**：表格中的编号、类型（Unit/Widget/Integration）、描述、断言/步骤。
- 文档开头的「任务与测试索引」表可用来确认该任务的概要与建议测试文件路径（如 `test/app_test.dart`、`test/core/theme/app_theme_test.dart`）。

---

## 3. 实现开发内容

- 严格按「开发内容」与项目约定实现，遵循：
  - `docs/development/code_structure.md`（目录、命名）；
  - `docs/technical/routes_spec.md`、`docs/technical/state_and_di_spec.md`、`docs/technical/settings_and_l10n_spec.md` 等（若任务涉及）。
- 涉及主题时参考 `docs/design/theme_spec.md`（若存在）。
- 新建或修改的文件放在文档与 code_structure 约定的路径下；命名：文件 snake_case，类 PascalCase。

---

## 4. 编写或补全测试

- 按该任务「对应测试用例」表格逐条落实：
  - 将用例落到「测试文件建议」列给出的路径（如 `test/core/theme/app_theme_test.dart`）；
  - Unit 测试：断言与步骤按表格描述编写；
  - Widget 测试：pumpWidget / pumpApp、find、expect 按表格执行；
  - Integration 测试：按文档说明放在 `integration_test/` 并实现步骤。
- 若测试文件不存在则创建；若已存在则补充或修改用例，确保表格中列出的用例均有对应测试并通过。

---

## 5. 代码自检与测试

按「修改代码后自检」工作流执行（与 `/flutter-post-edit-check` 一致），全部使用 MCP：

1. **add_roots** — 若尚未添加，添加当前项目根。
2. **dart_format** — 对项目根执行格式化（`lib/`、`test/`）。
3. **analyze_files** — 分析本次修改涉及路径或整个项目。
4. **dart_fix** — 若有可自动修复项，对项目根执行一次。
5. **run_tests** — 使用 MCP 的 run_tests，不执行 `flutter test` / `dart test`。

任一步失败则修复后从该步重新执行，直至全部通过。

---

## 6. 收尾

- 对照该任务的「验收」条款，确认均已满足。
- 向用户简要汇报：任务编号、完成项（实现 + 测试）、自检与测试结果（通过/失败及处理情况）。

**参考**：任务与测试细节以各阶段的 `docs/development/p{阶段}_tasks_and_tests.md`（如 p0、p1、p2）为准；自检流程见 `.cursor/skills/flutter-development/SKILL.md` 与 `.cursor/commands/flutter-post-edit-check.md`。
