import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
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
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ko, this message translates to:
  /// **'마이티'**
  String get appTitle;

  /// No description provided for @gameSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'한국의 전통 트릭테이킹 카드 게임'**
  String get gameSubtitle;

  /// No description provided for @startGame.
  ///
  /// In ko, this message translates to:
  /// **'게임 시작'**
  String get startGame;

  /// No description provided for @newGame.
  ///
  /// In ko, this message translates to:
  /// **'새 게임'**
  String get newGame;

  /// No description provided for @biddingPhase.
  ///
  /// In ko, this message translates to:
  /// **'비딩 단계'**
  String get biddingPhase;

  /// No description provided for @currentBidder.
  ///
  /// In ko, this message translates to:
  /// **'현재 비딩: {name}'**
  String currentBidder(String name);

  /// No description provided for @noBidYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 비딩 없음'**
  String get noBidYet;

  /// No description provided for @highestBid.
  ///
  /// In ko, this message translates to:
  /// **'최고 비딩: {bid}'**
  String highestBid(String bid);

  /// No description provided for @bid.
  ///
  /// In ko, this message translates to:
  /// **'비딩'**
  String get bid;

  /// No description provided for @bidButton.
  ///
  /// In ko, this message translates to:
  /// **'비딩하기'**
  String get bidButton;

  /// No description provided for @pass.
  ///
  /// In ko, this message translates to:
  /// **'패스'**
  String get pass;

  /// No description provided for @tricks.
  ///
  /// In ko, this message translates to:
  /// **'트릭 수'**
  String get tricks;

  /// No description provided for @giruda.
  ///
  /// In ko, this message translates to:
  /// **'기루다'**
  String get giruda;

  /// No description provided for @noGiruda.
  ///
  /// In ko, this message translates to:
  /// **'노기루다'**
  String get noGiruda;

  /// No description provided for @spade.
  ///
  /// In ko, this message translates to:
  /// **'스페이드'**
  String get spade;

  /// No description provided for @diamond.
  ///
  /// In ko, this message translates to:
  /// **'다이아몬드'**
  String get diamond;

  /// No description provided for @heart.
  ///
  /// In ko, this message translates to:
  /// **'하트'**
  String get heart;

  /// No description provided for @club.
  ///
  /// In ko, this message translates to:
  /// **'클럽'**
  String get club;

  /// No description provided for @selectKitty.
  ///
  /// In ko, this message translates to:
  /// **'키티 선택'**
  String get selectKitty;

  /// No description provided for @selectKittyDesc.
  ///
  /// In ko, this message translates to:
  /// **'버릴 카드 3장을 선택하세요 (선택됨: {count}/3)'**
  String selectKittyDesc(int count);

  /// No description provided for @receivedKitty.
  ///
  /// In ko, this message translates to:
  /// **'받은 키티:'**
  String get receivedKitty;

  /// No description provided for @myCards.
  ///
  /// In ko, this message translates to:
  /// **'내 카드:'**
  String get myCards;

  /// No description provided for @changeGiruda.
  ///
  /// In ko, this message translates to:
  /// **'기루다 변경 (선택사항):'**
  String get changeGiruda;

  /// No description provided for @confirm.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get confirm;

  /// No description provided for @declareFriend.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 선언'**
  String get declareFriend;

  /// No description provided for @friendDeclarationType.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 선언 방식:'**
  String get friendDeclarationType;

  /// No description provided for @byCard.
  ///
  /// In ko, this message translates to:
  /// **'카드로 지정'**
  String get byCard;

  /// No description provided for @firstTrickFriend.
  ///
  /// In ko, this message translates to:
  /// **'초구 프렌드'**
  String get firstTrickFriend;

  /// No description provided for @firstTrickFriendDesc.
  ///
  /// In ko, this message translates to:
  /// **'첫 트릭을 따는 사람'**
  String get firstTrickFriendDesc;

  /// No description provided for @nthTrickFriend.
  ///
  /// In ko, this message translates to:
  /// **'N번째 트릭 프렌드'**
  String get nthTrickFriend;

  /// No description provided for @noFriend.
  ///
  /// In ko, this message translates to:
  /// **'노프렌드'**
  String get noFriend;

  /// No description provided for @noFriendDesc.
  ///
  /// In ko, this message translates to:
  /// **'혼자 플레이'**
  String get noFriendDesc;

  /// No description provided for @declare.
  ///
  /// In ko, this message translates to:
  /// **'선언'**
  String get declare;

  /// No description provided for @suit.
  ///
  /// In ko, this message translates to:
  /// **'무늬:'**
  String get suit;

  /// No description provided for @rank.
  ///
  /// In ko, this message translates to:
  /// **'숫자:'**
  String get rank;

  /// No description provided for @selectedCard.
  ///
  /// In ko, this message translates to:
  /// **'선택한 카드: {card}'**
  String selectedCard(String card);

  /// No description provided for @trickNumber.
  ///
  /// In ko, this message translates to:
  /// **'트릭 번호:'**
  String get trickNumber;

  /// No description provided for @playCard.
  ///
  /// In ko, this message translates to:
  /// **'카드를 내세요'**
  String get playCard;

  /// No description provided for @yourTurn.
  ///
  /// In ko, this message translates to:
  /// **'당신의 차례입니다'**
  String get yourTurn;

  /// No description provided for @playerTurn.
  ///
  /// In ko, this message translates to:
  /// **'{name}의 차례'**
  String playerTurn(String name);

  /// No description provided for @contract.
  ///
  /// In ko, this message translates to:
  /// **'계약'**
  String get contract;

  /// No description provided for @trick.
  ///
  /// In ko, this message translates to:
  /// **'트릭'**
  String get trick;

  /// No description provided for @friend.
  ///
  /// In ko, this message translates to:
  /// **'프렌드'**
  String get friend;

  /// No description provided for @declarer.
  ///
  /// In ko, this message translates to:
  /// **'주공'**
  String get declarer;

  /// No description provided for @cards.
  ///
  /// In ko, this message translates to:
  /// **'카드: {count}'**
  String cards(int count);

  /// No description provided for @aiSelectingKitty.
  ///
  /// In ko, this message translates to:
  /// **'AI가 키티를 선택하고 있습니다...'**
  String get aiSelectingKitty;

  /// No description provided for @aiDeclaringFriend.
  ///
  /// In ko, this message translates to:
  /// **'AI가 프렌드를 선언하고 있습니다...'**
  String get aiDeclaringFriend;

  /// No description provided for @declarerTeamWins.
  ///
  /// In ko, this message translates to:
  /// **'주공 팀 승리!'**
  String get declarerTeamWins;

  /// No description provided for @defenderTeamWins.
  ///
  /// In ko, this message translates to:
  /// **'수비 팀 승리!'**
  String get defenderTeamWins;

  /// No description provided for @declarerTeamPoints.
  ///
  /// In ko, this message translates to:
  /// **'주공 팀: {points}점'**
  String declarerTeamPoints(int points);

  /// No description provided for @defenderTeamPoints.
  ///
  /// In ko, this message translates to:
  /// **'수비 팀: {points}점'**
  String defenderTeamPoints(int points);

  /// No description provided for @targetPoints.
  ///
  /// In ko, this message translates to:
  /// **'목표: {points}점'**
  String targetPoints(int points);

  /// No description provided for @score.
  ///
  /// In ko, this message translates to:
  /// **'점수'**
  String get score;

  /// No description provided for @points.
  ///
  /// In ko, this message translates to:
  /// **'{points}점'**
  String points(int points);

  /// No description provided for @player.
  ///
  /// In ko, this message translates to:
  /// **'플레이어'**
  String get player;
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
      <String>['en', 'ja', 'ko', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
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
