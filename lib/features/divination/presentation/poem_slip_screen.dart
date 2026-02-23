import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/features/divination/domain/poem_slip_service_provider.dart';
import 'package:lord_of_idea/features/divination/domain/services/poem_slip_service.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:lord_of_idea/shared/models/poem_slip_result.dart';

/// P1 预置诗签库列表（规格 §2：至少 1 套默认）。
const List<String> kPoemSlipLibraryIds = [kDefaultPoemSlipLibraryId];

/// 诗签工具页：选库（下拉）、抽签、再抽一次、复制。路由 /tools/poem-slip。
class PoemSlipScreen extends ConsumerStatefulWidget {
  const PoemSlipScreen({super.key});

  @override
  ConsumerState<PoemSlipScreen> createState() => _PoemSlipScreenState();
}

class _PoemSlipScreenState extends ConsumerState<PoemSlipScreen> {
  PoemSlipResult? _lastResult;
  bool _loading = false;
  String? _error;
  String _libraryId = kDefaultPoemSlipLibraryId;

  Future<void> _onDraw() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    try {
      final service = ref.read(poemSlipServiceProvider);
      final result = await service.draw(_libraryId);
      if (mounted) {
        setState(() {
          _lastResult = result;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _copyResult(PoemSlipResult result) {
    Clipboard.setData(ClipboardData(text: result.content));
  }

  String _libraryDisplayName(String libraryId) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return libraryId;
    switch (libraryId) {
      case kDefaultPoemSlipLibraryId:
        return l10n.poemSlipLibraryMazu;
      default:
        return libraryId;
    }
  }

  /// 从 slipId 解析签号用于展示（如 slip_011 → 11），避免直接裸露 id。
  static String _slipNumberForDisplay(String slipId) {
    if (slipId.isEmpty) return '';
    final lastUnderscore = slipId.lastIndexOf('_');
    if (lastUnderscore < 0 || lastUnderscore == slipId.length - 1) {
      return slipId;
    }
    final suffix = slipId.substring(lastUnderscore + 1);
    final num = int.tryParse(suffix);
    return num != null ? num.toString() : slipId;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.toolPoemSlip)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              l10n.poemSlipLibrary,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              key: const Key('poem_slip_library_dropdown'),
              initialValue: _libraryId,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              items: kPoemSlipLibraryIds
                  .map(
                    (id) => DropdownMenuItem(
                      value: id,
                      child: Text(_libraryDisplayName(id)),
                    ),
                  )
                  .toList(),
              onChanged: _loading
                  ? null
                  : (v) {
                      if (v != null) setState(() => _libraryId = v);
                    },
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('poem_slip_draw_button'),
              onPressed: _loading ? null : _onDraw,
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.menu_book),
              label: Text(_loading ? l10n.poemSlipDrawing : l10n.poemSlipDraw),
            ),
            const SizedBox(height: 24),
            if (_error != null) _buildError(context),
            if (_lastResult != null && _error == null) _buildResult(context),
          ],
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context) {
    return Card(
      key: const Key('poem_slip_error_card'),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(padding: const EdgeInsets.all(16.0), child: Text(_error!)),
    );
  }

  Widget _buildResult(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = _lastResult!;
    final libraryName = _libraryDisplayName(result.libraryId);
    final slipNumber = _slipNumberForDisplay(result.slipId);
    final headerText = slipNumber.isEmpty
        ? libraryName
        : l10n.poemSlipHeader(libraryName, slipNumber);
    return Card(
      key: const Key('poem_slip_result_card'),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (headerText.isNotEmpty)
              Text(
                headerText,
                key: const Key('poem_slip_header'),
                style: Theme.of(context).textTheme.titleSmall,
              ),
            const SizedBox(height: 8),
            SelectableText(result.content, key: const Key('poem_slip_content')),
            const SizedBox(height: 12),
            Row(
              children: [
                FilledButton.icon(
                  key: const Key('poem_slip_draw_again_button'),
                  onPressed: _loading ? null : _onDraw,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(l10n.poemSlipDrawAgain),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  key: const Key('poem_slip_copy_button'),
                  onPressed: () => _copyResult(result),
                  icon: const Icon(Icons.copy, size: 18),
                  label: Text(l10n.poemSlipCopy),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
