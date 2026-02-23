/// 工具结果基类。骰子、诗签、占卜等结果均继承此类。
/// 序列化时顶层包含 [type]、[createdAt]，便于反序列化时按 type 分发。
abstract class ToolResult {
  const ToolResult({required this.createdAt});

  /// 结果类型：`dice` | `poem_slip` | `divination`
  String get type;

  /// 生成时间（序列化为 ISO8601 UTC 字符串）
  final DateTime createdAt;

  /// 可逆序列化；子类实现需在顶层包含 [type]、[createdAt]。
  Map<String, dynamic> toJson();
}
