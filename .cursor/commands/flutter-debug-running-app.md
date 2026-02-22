# Flutter 调试运行中应用

执行「调试运行中应用」工作流（如布局溢出、运行时错误）。需先连接 Dart Tooling Daemon (DTD)；优先使用 Dart/Flutter MCP 工具（user-dart）。

**步骤：**

1. **确认应用已启动**
   - 若未启动：用 **list_devices** 列出设备，再用 **launch_app**（传入项目 `root` 与 `device`）启动，获得 DTD URI 与进程 ID。
   - 若已启动：请用户提供 DTD URI（如通过「Copy DTD Uri to clipboard」），不要编造 URI。断线重连时也需新 URI。

2. **connect_dart_tooling_daemon** — 使用用户提供的 DTD URI 连接。

3. **获取运行时上下文**
   - **get_runtime_errors** — 取当前运行时错误。
   - **get_widget_tree** 或 **get_selected_widget** — 需要分析布局时获取控件树或当前选中控件（需用户选控件时先 **set_widget_selection_mode** 开启选择模式）。

4. **修改代码后**
   - **hot_reload** 或 **hot_restart**（全局 const 变更或需重置状态时用 hot_restart）。
   - 再次 **get_runtime_errors** / **get_widget_tree** 确认是否解决。

5. **收尾**（可选）
   - **stop_app** — 结束由 launch_app 启动的进程。
   - **get_app_logs** — 需要时获取该进程日志。

**参考**：`.cursor/skills/flutter-development/SKILL.md` 中的「运行中应用（需 DTD）」与「常用工作流」。
