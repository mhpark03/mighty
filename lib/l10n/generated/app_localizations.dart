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
/// import 'generated/app_localizations.dart';
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
  /// **'게임 시작하기'**
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

  /// No description provided for @spadeName.
  ///
  /// In ko, this message translates to:
  /// **'스페이드'**
  String get spadeName;

  /// No description provided for @diamondName.
  ///
  /// In ko, this message translates to:
  /// **'다이아'**
  String get diamondName;

  /// No description provided for @heartName.
  ///
  /// In ko, this message translates to:
  /// **'하트'**
  String get heartName;

  /// No description provided for @clubName.
  ///
  /// In ko, this message translates to:
  /// **'클로버'**
  String get clubName;

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

  /// No description provided for @you.
  ///
  /// In ko, this message translates to:
  /// **'당신'**
  String get you;

  /// No description provided for @bidding.
  ///
  /// In ko, this message translates to:
  /// **'비딩 중...'**
  String get bidding;

  /// No description provided for @waiting.
  ///
  /// In ko, this message translates to:
  /// **'대기'**
  String get waiting;

  /// No description provided for @otherPlayerTurn.
  ///
  /// In ko, this message translates to:
  /// **'다른 플레이어 차례입니다'**
  String get otherPlayerTurn;

  /// No description provided for @yourCards.
  ///
  /// In ko, this message translates to:
  /// **'당신의 카드'**
  String get yourCards;

  /// No description provided for @biddingTurn.
  ///
  /// In ko, this message translates to:
  /// **'비딩 차례'**
  String get biddingTurn;

  /// No description provided for @bidWithAmount.
  ///
  /// In ko, this message translates to:
  /// **'비딩 {amount}'**
  String bidWithAmount(int amount);

  /// No description provided for @trickComplete.
  ///
  /// In ko, this message translates to:
  /// **'트릭 {number} 완료'**
  String trickComplete(int number);

  /// No description provided for @winnerAnnouncement.
  ///
  /// In ko, this message translates to:
  /// **'{name} 승리! ({team})'**
  String winnerAnnouncement(String name, String team);

  /// No description provided for @attackTeam.
  ///
  /// In ko, this message translates to:
  /// **'공격팀'**
  String get attackTeam;

  /// No description provided for @defenseTeam.
  ///
  /// In ko, this message translates to:
  /// **'방어팀'**
  String get defenseTeam;

  /// No description provided for @nextTrick.
  ///
  /// In ko, this message translates to:
  /// **'다음 트릭'**
  String get nextTrick;

  /// No description provided for @friendNone.
  ///
  /// In ko, this message translates to:
  /// **'없음'**
  String get friendNone;

  /// No description provided for @firstTrick.
  ///
  /// In ko, this message translates to:
  /// **'첫트릭'**
  String get firstTrick;

  /// No description provided for @selectCardHint.
  ///
  /// In ko, this message translates to:
  /// **'카드를 선택하세요 ↓'**
  String get selectCardHint;

  /// No description provided for @previousTrick.
  ///
  /// In ko, this message translates to:
  /// **'이전 트릭'**
  String get previousTrick;

  /// No description provided for @winShort.
  ///
  /// In ko, this message translates to:
  /// **'승'**
  String get winShort;

  /// No description provided for @leadPlayer.
  ///
  /// In ko, this message translates to:
  /// **'선공'**
  String get leadPlayer;

  /// No description provided for @leadPlayerHint.
  ///
  /// In ko, this message translates to:
  /// **'👆 선공입니다!'**
  String get leadPlayerHint;

  /// No description provided for @selectCardBelow.
  ///
  /// In ko, this message translates to:
  /// **'아래에서 카드를 선택하세요'**
  String get selectCardBelow;

  /// No description provided for @leadPlayerSelectCard.
  ///
  /// In ko, this message translates to:
  /// **'👆 선공입니다! 카드를 선택하세요'**
  String get leadPlayerSelectCard;

  /// No description provided for @jokerCallAnnouncement.
  ///
  /// In ko, this message translates to:
  /// **'조커 콜! {suit}'**
  String jokerCallAnnouncement(String suit);

  /// No description provided for @wonCards.
  ///
  /// In ko, this message translates to:
  /// **'획득:'**
  String get wonCards;

  /// No description provided for @jokerCallTitle.
  ///
  /// In ko, this message translates to:
  /// **'조커 콜'**
  String get jokerCallTitle;

  /// No description provided for @jokerCallQuestion.
  ///
  /// In ko, this message translates to:
  /// **'{suit} 조커 콜을 선언하시겠습니까?'**
  String jokerCallQuestion(String suit);

  /// No description provided for @no.
  ///
  /// In ko, this message translates to:
  /// **'아니오'**
  String get no;

  /// No description provided for @jokerCallButton.
  ///
  /// In ko, this message translates to:
  /// **'{suit} 조커 콜!'**
  String jokerCallButton(String suit);

  /// No description provided for @allPassedTitle.
  ///
  /// In ko, this message translates to:
  /// **'모두 패스'**
  String get allPassedTitle;

  /// No description provided for @allPassedMessage.
  ///
  /// In ko, this message translates to:
  /// **'모든 플레이어가 패스했습니다.\n새 게임을 시작합니다.'**
  String get allPassedMessage;

  /// No description provided for @girudaChangeWarning.
  ///
  /// In ko, this message translates to:
  /// **'기루다 변경 시 목표 +2 증가'**
  String get girudaChangeWarning;

  /// No description provided for @keep.
  ///
  /// In ko, this message translates to:
  /// **'유지'**
  String get keep;

  /// No description provided for @aiRecommendation.
  ///
  /// In ko, this message translates to:
  /// **'AI 추천'**
  String get aiRecommendation;

  /// No description provided for @discardCards.
  ///
  /// In ko, this message translates to:
  /// **'버릴 카드:'**
  String get discardCards;

  /// No description provided for @goalPlus2.
  ///
  /// In ko, this message translates to:
  /// **'(목표 +2)'**
  String get goalPlus2;

  /// No description provided for @applyRecommendation.
  ///
  /// In ko, this message translates to:
  /// **'추천 적용'**
  String get applyRecommendation;

  /// No description provided for @nthTrickShort.
  ///
  /// In ko, this message translates to:
  /// **'{n}트릭'**
  String nthTrickShort(int n);

  /// No description provided for @recommendedFriend.
  ///
  /// In ko, this message translates to:
  /// **'추천 프렌드:'**
  String get recommendedFriend;

  /// No description provided for @joker.
  ///
  /// In ko, this message translates to:
  /// **'조커'**
  String get joker;

  /// No description provided for @mighty.
  ///
  /// In ko, this message translates to:
  /// **'마이티'**
  String get mighty;

  /// No description provided for @recommendNoFriend.
  ///
  /// In ko, this message translates to:
  /// **'노프렌드 추천'**
  String get recommendNoFriend;

  /// No description provided for @reasonHasMighty.
  ///
  /// In ko, this message translates to:
  /// **'마이티 보유'**
  String get reasonHasMighty;

  /// No description provided for @reasonHasJoker.
  ///
  /// In ko, this message translates to:
  /// **'조커 보유'**
  String get reasonHasJoker;

  /// No description provided for @reasonNeedMighty.
  ///
  /// In ko, this message translates to:
  /// **'마이티 필요'**
  String get reasonNeedMighty;

  /// No description provided for @reasonNeedJoker.
  ///
  /// In ko, this message translates to:
  /// **'조커 필요'**
  String get reasonNeedJoker;

  /// No description provided for @reasonNeedGirudaAce.
  ///
  /// In ko, this message translates to:
  /// **'기루다 A 필요'**
  String get reasonNeedGirudaAce;

  /// No description provided for @reasonNeedGirudaKing.
  ///
  /// In ko, this message translates to:
  /// **'기루다 K 필요'**
  String get reasonNeedGirudaKing;

  /// No description provided for @reasonStrongHand.
  ///
  /// In ko, this message translates to:
  /// **'강한 핸드'**
  String get reasonStrongHand;

  /// No description provided for @continueGame.
  ///
  /// In ko, this message translates to:
  /// **'이어하기'**
  String get continueGame;

  /// No description provided for @exitGame.
  ///
  /// In ko, this message translates to:
  /// **'게임 종료'**
  String get exitGame;

  /// No description provided for @exitGameConfirm.
  ///
  /// In ko, this message translates to:
  /// **'게임을 종료하시겠습니까?\n현재 게임은 자동 저장됩니다.'**
  String get exitGameConfirm;

  /// No description provided for @cancel.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In ko, this message translates to:
  /// **'종료'**
  String get exit;

  /// No description provided for @savedGame.
  ///
  /// In ko, this message translates to:
  /// **'저장된 게임'**
  String get savedGame;

  /// No description provided for @noSavedGame.
  ///
  /// In ko, this message translates to:
  /// **'저장된 게임이 없습니다'**
  String get noSavedGame;

  /// No description provided for @recommendedCard.
  ///
  /// In ko, this message translates to:
  /// **'추천 카드'**
  String get recommendedCard;

  /// No description provided for @showRecommendation.
  ///
  /// In ko, this message translates to:
  /// **'추천 보기'**
  String get showRecommendation;

  /// No description provided for @playerStats.
  ///
  /// In ko, this message translates to:
  /// **'플레이어 통계'**
  String get playerStats;

  /// No description provided for @winLoss.
  ///
  /// In ko, this message translates to:
  /// **'승/패'**
  String get winLoss;

  /// No description provided for @totalScore.
  ///
  /// In ko, this message translates to:
  /// **'총점'**
  String get totalScore;

  /// No description provided for @win.
  ///
  /// In ko, this message translates to:
  /// **'승'**
  String get win;

  /// No description provided for @loss.
  ///
  /// In ko, this message translates to:
  /// **'패'**
  String get loss;

  /// No description provided for @resetStats.
  ///
  /// In ko, this message translates to:
  /// **'초기화'**
  String get resetStats;

  /// No description provided for @resetStatsConfirm.
  ///
  /// In ko, this message translates to:
  /// **'광고를 시청하면 모든 통계가 초기화됩니다.\n계속하시겠습니까?'**
  String get resetStatsConfirm;

  /// No description provided for @exitApp.
  ///
  /// In ko, this message translates to:
  /// **'앱 종료'**
  String get exitApp;

  /// No description provided for @exitAppConfirm.
  ///
  /// In ko, this message translates to:
  /// **'앱을 종료하시겠습니까?'**
  String get exitAppConfirm;

  /// No description provided for @gameGuide.
  ///
  /// In ko, this message translates to:
  /// **'게임 방법'**
  String get gameGuide;

  /// No description provided for @guideOverview.
  ///
  /// In ko, this message translates to:
  /// **'게임 개요'**
  String get guideOverview;

  /// No description provided for @guideOverviewText.
  ///
  /// In ko, this message translates to:
  /// **'마이티는 5명이 즐기는 트릭테이킹 카드 게임입니다. 주공(1명)과 프렌드(1명)가 팀을 이루어 수비팀(3명)과 대결합니다.'**
  String get guideOverviewText;

  /// No description provided for @guideBidding.
  ///
  /// In ko, this message translates to:
  /// **'비딩'**
  String get guideBidding;

  /// No description provided for @guideBiddingText.
  ///
  /// In ko, this message translates to:
  /// **'• 각 플레이어는 자신이 획득할 점수 카드 수를 선언합니다\n• 가장 높은 비딩을 한 플레이어가 주공이 됩니다\n• 주공은 기루다(으뜸패)를 정합니다'**
  String get guideBiddingText;

  /// No description provided for @guideSpecialCards.
  ///
  /// In ko, this message translates to:
  /// **'특수 카드'**
  String get guideSpecialCards;

  /// No description provided for @guideSpecialCardsText.
  ///
  /// In ko, this message translates to:
  /// **'• 마이티: 스페이드 A (가장 강한 카드)\n• 조커: 두 번째로 강한 카드\n• 기루다: 주공이 정한 으뜸패 무늬'**
  String get guideSpecialCardsText;

  /// No description provided for @guideFriend.
  ///
  /// In ko, this message translates to:
  /// **'프렌드'**
  String get guideFriend;

  /// No description provided for @guideFriendText.
  ///
  /// In ko, this message translates to:
  /// **'• 주공은 특정 카드를 가진 사람을 프렌드로 지정합니다\n• 프렌드는 자신이 프렌드인지 숨길 수 있습니다\n• 조커콜: 특정 무늬의 3을 가진 사람을 프렌드로 지정'**
  String get guideFriendText;

  /// No description provided for @guideScoring.
  ///
  /// In ko, this message translates to:
  /// **'점수 계산'**
  String get guideScoring;

  /// No description provided for @guideScoringText.
  ///
  /// In ko, this message translates to:
  /// **'• 점수 카드: A, K, Q, J, 10 (각 1점, 총 20점)\n• 주공팀이 목표 점수 이상 획득하면 승리\n• 승리팀은 +점수, 패배팀은 -점수'**
  String get guideScoringText;

  /// No description provided for @guideTips.
  ///
  /// In ko, this message translates to:
  /// **'게임 팁'**
  String get guideTips;

  /// No description provided for @guideTipsText.
  ///
  /// In ko, this message translates to:
  /// **'• 마이티와 조커는 항상 강력합니다\n• 기루다 카드를 잘 활용하세요\n• 프렌드의 정체를 파악하는 것이 중요합니다'**
  String get guideTipsText;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;
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
