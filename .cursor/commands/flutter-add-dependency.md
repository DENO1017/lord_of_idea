# Flutter 查找并添加依赖

执行「查找并添加依赖」工作流。优先使用 Dart/Flutter MCP 工具（user-dart）。

**步骤（按顺序）：**

1. **pub_dev_search** — 用功能关键词或 topic 在 pub.dev 搜索（如 `query` 可为 "chart"、"state management" 或 `topic:widgets`）。根据下载量、描述、license 等帮用户选合适包。
2. **pub** — 在项目根执行添加依赖（如 `flutter pub add <package_name>`）；需要时先 **add_roots** 添加项目根。
3. **analyze_files** — 添加依赖后分析一次，确认无冲突或新问题。
4. **run_tests** — 用 MCP 的 run_tests 跑一遍测试，确保未破坏现有用例。

若用户未指定包名，先完成步骤 1 并给出 1～3 个推荐后再执行步骤 2。

**参考**：`.cursor/skills/flutter-development/SKILL.md` 中的「依赖与包」与「常用工作流」。
