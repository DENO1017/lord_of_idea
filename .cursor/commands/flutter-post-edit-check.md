# Flutter 修改代码后自检

执行「修改代码后自检」工作流。优先使用 Dart/Flutter MCP 工具（user-dart），不要直接用 shell。

**步骤（按顺序）：**

1. **add_roots** — 若尚未添加项目根，先添加当前工作区根目录。
2. **dart_format** — 对项目根执行格式化（本项目约定 `lib/`、`test/`，行宽 80）。
3. **analyze_files** — 分析项目或本次修改涉及的路径；可只传 `paths` 限定范围。
4. **dart_fix** — 若有可自动修复的 lint/问题，对项目根执行一次。
5. **run_tests** — 用 MCP 的 run_tests 运行测试，不要执行 `flutter test` 或 `dart test`。

若某步报错，先解决再继续下一步。全部通过即自检完成。

**参考**：`.cursor/skills/flutter-development/SKILL.md` 中的「代码质量与规范」与「常用工作流」。
