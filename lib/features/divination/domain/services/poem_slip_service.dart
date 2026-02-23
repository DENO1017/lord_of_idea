import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:lord_of_idea/shared/models/poem_slip_result.dart';

/// 默认诗签库 ID（妈祖灵签），见 [poem_slip_spec](../../../../docs/technical/poem_slip_spec.md)。
const String kDefaultPoemSlipLibraryId = 'poem_slip_mazu';

/// 诗签库内单条签条（从 JSON 解析）。
class PoemSlipEntry {
  const PoemSlipEntry({
    required this.slipId,
    required this.content,
    this.extra,
  });

  final String slipId;
  final String content;
  final Map<String, dynamic>? extra;

  factory PoemSlipEntry.fromJson(Map<String, dynamic> json) {
    return PoemSlipEntry(
      slipId: json['slipId'] as String,
      content: json['content'] as String,
      extra: json['extra'] != null
          ? Map<String, dynamic>.from(json['extra'] as Map)
          : null,
    );
  }
}

/// 诗签库加载与抽签服务。随机源可注入便于测试。
class PoemSlipService {
  PoemSlipService({Random? random, AssetBundle? bundle})
    : _random = random ?? Random(),
      _bundle = bundle ?? rootBundle;

  final Random _random;
  final AssetBundle _bundle;

  static String _assetPath(String libraryId) =>
      'assets/poem_slips/$libraryId.json';

  /// 根据 [libraryId] 加载诗签库，返回签条列表。
  /// 路径约定：`assets/poem_slips/{libraryId}.json`。
  Future<List<PoemSlipEntry>> loadLibrary(String libraryId) async {
    final path = _assetPath(libraryId);
    final jsonString = await _bundle.loadString(path);
    final list = json.decode(jsonString) as List<dynamic>;
    return list
        .map((e) => PoemSlipEntry.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// 从指定库中随机抽一条，返回 [PoemSlipResult]。
  Future<PoemSlipResult> draw(String libraryId) async {
    final slips = await loadLibrary(libraryId);
    if (slips.isEmpty) {
      throw StateError('诗签库为空: $libraryId');
    }
    final index = _random.nextInt(slips.length);
    final slip = slips[index];
    final createdAt = DateTime.now().toUtc();
    return PoemSlipResult(
      createdAt: createdAt,
      libraryId: libraryId,
      slipId: slip.slipId,
      content: slip.content,
      extra: slip.extra,
    );
  }
}
