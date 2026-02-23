// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Lord of Idea';

  @override
  String get navHome => 'Home';

  @override
  String get navTools => 'Tools';

  @override
  String get navJournal => 'Journal';

  @override
  String get navMarket => 'Market';

  @override
  String get navMe => 'Me';

  @override
  String get settings => 'Settings';

  @override
  String get theme => 'Theme';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeSystem => 'System';

  @override
  String get language => 'Language';

  @override
  String get languageZh => 'Chinese';

  @override
  String get languageEn => 'English';

  @override
  String get toolDice => 'Dice';

  @override
  String get toolPoemSlip => 'Poem Slip';

  @override
  String get toolTarot => 'Tarot';

  @override
  String get invalidDice => 'Invalid dice expression';

  @override
  String get diceExpressionLabel => 'Expression';

  @override
  String get diceExpressionHint => 'e.g. 2d6+3, d20';

  @override
  String get diceRoll => 'Roll';

  @override
  String get diceDiscard => 'Discard';

  @override
  String get diceReRoll => 'Re-roll';

  @override
  String get diceSaveAndCopy => 'Save & Copy';

  @override
  String get diceCountZeroError => 'Count cannot be 0';

  @override
  String get diceCountOverMaxError => 'Count cannot exceed 20';

  @override
  String get diceConfirm => 'Confirm';

  @override
  String get diceExpression => 'Expression';

  @override
  String get diceTotal => 'Total';

  @override
  String get diceHistory => 'History';

  @override
  String get diceCopy => 'Copy';

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
  String get poemSlipDraw => 'Draw';

  @override
  String get poemSlipDrawing => 'Drawing…';

  @override
  String get poemSlipDrawAgain => 'Draw again';

  @override
  String get poemSlipCopy => 'Copy';

  @override
  String get poemSlipLibrary => 'Library';

  @override
  String get poemSlipLibraryMazu => 'Mazu Oracle';

  @override
  String poemSlipHeader(String libraryName, String number) {
    return '$libraryName No. $number';
  }

  @override
  String get tarotDraw => 'Draw card';

  @override
  String get tarotDrawing => 'Drawing…';

  @override
  String get tarotCopy => 'Copy';

  @override
  String get tarotUpright => 'Upright';

  @override
  String get tarotReversed => 'Reversed';

  @override
  String get tarotDeckRws => 'Rider-Waite-Smith';

  @override
  String get tarotModeWithReplacement => 'With replacement';

  @override
  String get tarotModeWithoutReplacement => 'Without replacement';

  @override
  String get tarotDeckExhausted => 'Deck exhausted, reshuffled';
}
