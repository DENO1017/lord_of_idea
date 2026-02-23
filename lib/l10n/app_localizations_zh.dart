// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '灵感之主';

  @override
  String get navHome => '首页';

  @override
  String get navTools => '工具';

  @override
  String get navJournal => '手帐';

  @override
  String get navMarket => '市集';

  @override
  String get navMe => '我的';

  @override
  String get settings => '设置';

  @override
  String get theme => '主题';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get language => '语言';

  @override
  String get languageZh => '中文';

  @override
  String get languageEn => '英文';

  @override
  String get toolDice => '骰子';

  @override
  String get toolPoemSlip => '诗签';

  @override
  String get toolTarot => '占卜';

  @override
  String get invalidDice => '无效的骰子表达式';

  @override
  String get diceExpressionLabel => '表达式';

  @override
  String get diceExpressionHint => '例如 2d6+3、d20';

  @override
  String get diceRoll => '掷骰';

  @override
  String get diceDiscard => '舍弃';

  @override
  String get diceReRoll => '重 Roll';

  @override
  String get diceSaveAndCopy => '保存并复制';

  @override
  String get diceCountZeroError => '数量不能为 0';

  @override
  String get diceCountOverMaxError => '数量不能超过 20';

  @override
  String get diceConfirm => '确定';

  @override
  String get diceExpression => '表达式';

  @override
  String get diceTotal => '总计';

  @override
  String get diceHistory => '历史';

  @override
  String get diceCopy => '复制';

  @override
  String get diceQuickD4 => 'd4';

  @override
  String get diceQuickD6 => 'd6';

  @override
  String get diceQuickD8 => 'd8';

  @override
  String get diceQuickD10 => 'd10';

  @override
  String get diceQuickD12 => 'd12';

  @override
  String get diceQuickD20 => 'd20';

  @override
  String get diceQuickD100 => 'd100';

  @override
  String get poemSlipDraw => '抽签';

  @override
  String get poemSlipDrawing => '抽签中…';

  @override
  String get poemSlipDrawAgain => '再抽一次';

  @override
  String get poemSlipCopy => '复制';

  @override
  String get poemSlipLibrary => '诗签库';

  @override
  String get poemSlipLibraryMazu => '妈祖灵签';

  @override
  String poemSlipHeader(String libraryName, String number) {
    return '$libraryName 第 $number 签';
  }

  @override
  String get tarotDraw => '抽牌';

  @override
  String get tarotDrawing => '抽牌中…';

  @override
  String get tarotCopy => '复制';

  @override
  String get tarotUpright => '正位';

  @override
  String get tarotReversed => '逆位';

  @override
  String get tarotDeckRws => '韦特塔罗';

  @override
  String get tarotModeWithReplacement => '放回';

  @override
  String get tarotModeWithoutReplacement => '不放回';

  @override
  String get tarotDeckExhausted => '牌组已抽完，已重新洗牌';
}
