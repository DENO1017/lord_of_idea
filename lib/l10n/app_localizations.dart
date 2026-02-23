import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Lord of Idea'**
  String get appTitle;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navTools.
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navTools;

  /// No description provided for @navJournal.
  ///
  /// In en, this message translates to:
  /// **'Journal'**
  String get navJournal;

  /// No description provided for @navMarket.
  ///
  /// In en, this message translates to:
  /// **'Market'**
  String get navMarket;

  /// No description provided for @navMe.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get navMe;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageZh.
  ///
  /// In en, this message translates to:
  /// **'Chinese'**
  String get languageZh;

  /// No description provided for @languageEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEn;

  /// No description provided for @toolDice.
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get toolDice;

  /// No description provided for @toolPoemSlip.
  ///
  /// In en, this message translates to:
  /// **'Poem Slip'**
  String get toolPoemSlip;

  /// No description provided for @toolTarot.
  ///
  /// In en, this message translates to:
  /// **'Tarot'**
  String get toolTarot;

  /// No description provided for @invalidDice.
  ///
  /// In en, this message translates to:
  /// **'Invalid dice expression'**
  String get invalidDice;

  /// No description provided for @diceExpressionLabel.
  ///
  /// In en, this message translates to:
  /// **'Expression'**
  String get diceExpressionLabel;

  /// No description provided for @diceExpressionHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 2d6+3, d20'**
  String get diceExpressionHint;

  /// No description provided for @diceRoll.
  ///
  /// In en, this message translates to:
  /// **'Roll'**
  String get diceRoll;

  /// No description provided for @diceDiscard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get diceDiscard;

  /// No description provided for @diceReRoll.
  ///
  /// In en, this message translates to:
  /// **'Re-roll'**
  String get diceReRoll;

  /// No description provided for @diceSaveAndCopy.
  ///
  /// In en, this message translates to:
  /// **'Save & Copy'**
  String get diceSaveAndCopy;

  /// No description provided for @diceCountZeroError.
  ///
  /// In en, this message translates to:
  /// **'Count cannot be 0'**
  String get diceCountZeroError;

  /// No description provided for @diceCountOverMaxError.
  ///
  /// In en, this message translates to:
  /// **'Count cannot exceed 20'**
  String get diceCountOverMaxError;

  /// No description provided for @diceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get diceConfirm;

  /// No description provided for @diceExpression.
  ///
  /// In en, this message translates to:
  /// **'Expression'**
  String get diceExpression;

  /// No description provided for @diceTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get diceTotal;

  /// No description provided for @diceHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get diceHistory;

  /// No description provided for @diceCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get diceCopy;

  /// No description provided for @diceQuickD4.
  ///
  /// In en, this message translates to:
  /// **'d4'**
  String get diceQuickD4;

  /// No description provided for @diceQuickD6.
  ///
  /// In en, this message translates to:
  /// **'d6'**
  String get diceQuickD6;

  /// No description provided for @diceQuickD8.
  ///
  /// In en, this message translates to:
  /// **'d8'**
  String get diceQuickD8;

  /// No description provided for @diceQuickD10.
  ///
  /// In en, this message translates to:
  /// **'d10'**
  String get diceQuickD10;

  /// No description provided for @diceQuickD12.
  ///
  /// In en, this message translates to:
  /// **'d12'**
  String get diceQuickD12;

  /// No description provided for @diceQuickD20.
  ///
  /// In en, this message translates to:
  /// **'d20'**
  String get diceQuickD20;

  /// No description provided for @diceQuickD100.
  ///
  /// In en, this message translates to:
  /// **'d100'**
  String get diceQuickD100;

  /// No description provided for @poemSlipDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get poemSlipDraw;

  /// No description provided for @poemSlipDrawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing…'**
  String get poemSlipDrawing;

  /// No description provided for @poemSlipDrawAgain.
  ///
  /// In en, this message translates to:
  /// **'Draw again'**
  String get poemSlipDrawAgain;

  /// No description provided for @poemSlipCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get poemSlipCopy;

  /// No description provided for @poemSlipLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get poemSlipLibrary;

  /// No description provided for @poemSlipLibraryMazu.
  ///
  /// In en, this message translates to:
  /// **'Mazu Oracle'**
  String get poemSlipLibraryMazu;

  /// No description provided for @poemSlipHeader.
  ///
  /// In en, this message translates to:
  /// **'{libraryName} No. {number}'**
  String poemSlipHeader(String libraryName, String number);

  /// No description provided for @tarotDraw.
  ///
  /// In en, this message translates to:
  /// **'Draw card'**
  String get tarotDraw;

  /// No description provided for @tarotDrawing.
  ///
  /// In en, this message translates to:
  /// **'Drawing…'**
  String get tarotDrawing;

  /// No description provided for @tarotCopy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get tarotCopy;

  /// No description provided for @tarotUpright.
  ///
  /// In en, this message translates to:
  /// **'Upright'**
  String get tarotUpright;

  /// No description provided for @tarotReversed.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get tarotReversed;

  /// No description provided for @tarotDeckRws.
  ///
  /// In en, this message translates to:
  /// **'Rider-Waite-Smith'**
  String get tarotDeckRws;

  /// No description provided for @tarotModeWithReplacement.
  ///
  /// In en, this message translates to:
  /// **'With replacement'**
  String get tarotModeWithReplacement;

  /// No description provided for @tarotModeWithoutReplacement.
  ///
  /// In en, this message translates to:
  /// **'Without replacement'**
  String get tarotModeWithoutReplacement;

  /// No description provided for @tarotDeckExhausted.
  ///
  /// In en, this message translates to:
  /// **'Deck exhausted, reshuffled'**
  String get tarotDeckExhausted;

  /// No description provided for @createJournal.
  ///
  /// In en, this message translates to:
  /// **'Create journal'**
  String get createJournal;

  /// No description provided for @journalDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Untitled journal'**
  String get journalDefaultTitle;

  /// No description provided for @journalDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this journal? This cannot be undone.'**
  String get journalDeleteConfirm;

  /// No description provided for @journalDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete journal'**
  String get journalDeleteTitle;

  /// No description provided for @journalAddBlock.
  ///
  /// In en, this message translates to:
  /// **'Add block'**
  String get journalAddBlock;

  /// No description provided for @journalEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get journalEdit;

  /// No description provided for @journalRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get journalRead;

  /// No description provided for @journalToolFromHistory.
  ///
  /// In en, this message translates to:
  /// **'From history'**
  String get journalToolFromHistory;

  /// No description provided for @journalToolUseLive.
  ///
  /// In en, this message translates to:
  /// **'Use now'**
  String get journalToolUseLive;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
