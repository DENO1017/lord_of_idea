import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lord_of_idea/features/divination/domain/divination_service_provider.dart';
import 'package:lord_of_idea/features/divination/domain/services/divination_service.dart';
import 'package:lord_of_idea/l10n/app_localizations.dart';
import 'package:lord_of_idea/shared/models/divination_result.dart';

/// 牌面图路径规则（规格 §5）：assets/tarot/images/{cardId}.png
String tarotCardImagePath(String cardId) => 'assets/tarot/images/$cardId.png';

/// 简易占卜（单张塔罗）页：抽牌模式（放回/不放回）、抽牌、牌面图、释义、复制。路由 /tools/tarot。
class TarotScreen extends ConsumerStatefulWidget {
  const TarotScreen({super.key});

  @override
  ConsumerState<TarotScreen> createState() => _TarotScreenState();
}

class _TarotScreenState extends ConsumerState<TarotScreen> {
  List<TarotCard>? _deck;
  bool _deckLoading = true;
  String? _deckError;
  DivinationResult? _lastResult;
  bool _drawing = false;

  /// 放回 = true，不放回 = false（规格 §4）。
  bool _withReplacement = true;

  /// 不放回模式下剩余牌（抽完则重新洗牌）。
  List<TarotCard> _remainingCards = [];

  Future<void> _loadDeck() async {
    setState(() {
      _deckError = null;
      _deckLoading = true;
    });
    try {
      final service = ref.read(divinationServiceProvider);
      final deck = await service.loadDeck(kDefaultTarotDeckAsset);
      if (mounted) {
        setState(() {
          _deck = deck;
          _remainingCards = List.from(deck);
          _deckLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _deckError = e.toString();
          _deckLoading = false;
        });
      }
    }
  }

  void _onDraw() {
    final deck = _deck;
    if (deck == null || deck.isEmpty || _drawing) return;
    setState(() => _drawing = true);
    List<TarotCard> drawFrom = _withReplacement ? deck : _remainingCards;
    if (drawFrom.isEmpty) {
      drawFrom = List.from(deck);
      _remainingCards = List.from(deck);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.tarotDeckExhausted),
          ),
        );
      }
    }
    try {
      final service = ref.read(divinationServiceProvider);
      final result = service.drawOne(drawFrom, kDefaultDeckId);
      if (mounted) {
        setState(() {
          _lastResult = result;
          _drawing = false;
          if (!_withReplacement) {
            _remainingCards = List.from(drawFrom)
              ..removeWhere((c) => c.cardId == result.cardId);
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _drawing = false);
    }
  }

  /// 复制格式（规格 §5）：{cardId}_{0|1}:{cardName} 正位/逆位
  void _copyResult(DivinationResult result) {
    final l10n = AppLocalizations.of(context)!;
    final orientation = result.reversed
        ? l10n.tarotReversed
        : l10n.tarotUpright;
    final num = result.reversed ? 1 : 0;
    final text = '${result.cardId}_$num:${result.cardName} $orientation';
    Clipboard.setData(ClipboardData(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_deck == null && _deckError == null && _deckLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDeck());
    }
    final canDraw =
        _deck != null &&
        _deck!.isNotEmpty &&
        !_deckLoading &&
        _deckError == null &&
        !_drawing;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.toolTarot)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (_deckLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_deckError != null)
              Card(
                key: const Key('tarot_deck_error_card'),
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_deckError!),
                ),
              )
            else ...[
              Text(
                l10n.tarotDeckRws,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              SegmentedButton<bool>(
                key: const Key('tarot_mode_selector'),
                segments: [
                  ButtonSegment(
                    value: true,
                    label: Text(l10n.tarotModeWithReplacement),
                  ),
                  ButtonSegment(
                    value: false,
                    label: Text(l10n.tarotModeWithoutReplacement),
                  ),
                ],
                selected: {_withReplacement},
                onSelectionChanged: (Set<bool> selected) {
                  setState(() => _withReplacement = selected.first);
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('tarot_draw_button'),
                onPressed: canDraw ? _onDraw : null,
                icon: _drawing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.style),
                label: Text(_drawing ? l10n.tarotDrawing : l10n.tarotDraw),
              ),
              const SizedBox(height: 24),
              if (_lastResult != null) _buildResult(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResult(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final result = _lastResult!;
    final orientationText = result.reversed
        ? l10n.tarotReversed
        : l10n.tarotUpright;
    final imagePath = tarotCardImagePath(result.cardId);
    return Card(
      key: const Key('tarot_result_card'),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Image.asset(
                imagePath,
                key: const Key('tarot_card_image'),
                width: 160,
                height: 280,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => Container(
                  width: 160,
                  height: 280,
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.style,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              result.cardName,
              key: const Key('tarot_card_name'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              orientationText,
              key: Key(
                'tarot_orientation_${result.reversed ? 'reversed' : 'upright'}',
              ),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            SelectableText(result.meaning, key: const Key('tarot_meaning')),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              key: const Key('tarot_copy_button'),
              onPressed: () => _copyResult(result),
              icon: const Icon(Icons.copy, size: 18),
              label: Text(l10n.tarotCopy),
            ),
          ],
        ),
      ),
    );
  }
}
