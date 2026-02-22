# 项目进度审查（Project Review）

执行一次完整的**项目进度审查**：获取开发阶段计划与项目内容 → 使用 MCP 运行测试 → 评估开发进度 → 获取当前日期并更新相关文档。优先使用 Dart/Flutter MCP 工具（user-dart）运行测试，不要直接用 shell 执行 `flutter test`。

---

## 1. 获取开发阶段计划与项目内容

- **阶段计划与排期**：阅读 `docs/project/project_manager.md`，掌握 P0–P5 阶段总览、各阶段目标、建议周期与依赖关系。
- **当前阶段交付清单**：根据项目当前阶段（通常为 P0 或文档中标注的阶段），阅读对应交付文档：
  - P0 → `docs/project/p0_deliverables.md`
  - 若存在 P1/P2 等 → `docs/project/p1_deliverables.md` 等（如有）。
- **任务与测试定义**：阅读当前阶段的开发任务与测试用例文档，例如：
  - P0 → `docs/development/p0_tasks_and_tests.md`
  - 其他阶段 → `docs/development/p<阶段>_tasks_and_tests.md`。
- **项目内容速览**：快速查看 `lib/` 目录结构、`README.md`、以及与本阶段相关的核心文件（如 `lib/main.dart`、`lib/app.dart`、`lib/core/`、各 feature 的 presentation 等），确认已实现内容与文档的对应关系。

---

## 2. 使用 MCP 运行测试

- **前置**：若尚未添加项目根，先使用 user-dart 的 **add_roots** 添加当前工作区根目录。
- **运行测试**：使用 user-dart 的 **run_tests** 对项目根执行测试。**不要**在终端执行 `flutter test` 或 `dart test`。
- 记录测试结果：通过数、失败数、失败用例名称与错误信息（若有）。若有失败，在「评估进度」中说明对进度的影响。

---

## 3. 评估项目开发进度

- **对照交付清单**：将当前阶段交付项（如 p0_deliverables 中的表格与「P0 完成检查」）与代码、配置、文档逐一对照，标出：已完成、进行中、未开始。
- **对照任务与测试**：将 `p*_tasks_and_tests.md` 中的任务（如 P0-1～P0-10）与实现情况、测试用例是否落地与通过情况对应，给出简要结论（例如：P0-1～P0-3 已实现且测试通过，P0-4 目录已建待路由覆盖，P0-5 进行中等）。
- **测试结果汇总**：结合 MCP run_tests 的结果，说明当前测试通过率及是否满足「本阶段测试全部通过」的验收要求。
- **风险与阻塞**：若存在与 `project_manager.md` 中「风险与缓冲」相关的现象，或发现新的阻塞点，简要记录。

---

## 4. 获取当前日期并更新相关文档

- **当前日期**：以执行审查时的日期为准（如 2025-02-22），用于写入文档。
- **建议更新的文档**（按需修改，避免无意义改动）：
  - **`docs/project/project_manager.md`**：在文末「最后更新」或 §11 文档与迭代 中，更新为本次审查日期，并可加一句「最近一次 Project Review：YYYY-MM-DD，结论：…」的简要说明（若文档中无该句可新增一行）。
  - **当前阶段交付文档**（如 `docs/project/p0_deliverables.md`）：若「完成检查」清单中有可勾选项因本次审查确认已完成，则更新勾选；若「需填写/决策」有变化，则更新对应段落。
  - **可选**：若项目有统一的「审查记录」或「进度周报」文档（如 `docs/project/review_log.md`），则追加一条记录：日期、阶段、测试结果摘要、进度结论、待办项。

若某文档不存在（如 review_log），不必新建，仅在汇报中说明「未发现审查记录文档，未创建」。

---

## 5. 收尾与汇报

- 向用户提交一份简洁的**审查报告**，包含：
  - 审查日期
  - 当前阶段与参考文档
  - 测试结果（MCP run_tests：通过/失败及数量）
  - 进度评估摘要（已完成项、进行中、未开始；与交付清单/任务表的符合度）
  - 已更新的文档列表
  - 建议的下一步（如：补齐某任务测试、更新某交付项勾选等）

**参考**：阶段计划与排期见 `docs/project/project_manager.md`；任务与测试见 `docs/development/p*_tasks_and_tests.md`；MCP 测试流程见 `.cursor/skills/flutter-development/SKILL.md` 与 `.cursor/commands/flutter-post-edit-check.md`。
