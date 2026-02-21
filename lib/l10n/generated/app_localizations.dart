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
  /// **'배팅 단계'**
  String get biddingPhase;

  /// No description provided for @currentBidder.
  ///
  /// In ko, this message translates to:
  /// **'현재 배팅: {name}'**
  String currentBidder(String name);

  /// No description provided for @noBidYet.
  ///
  /// In ko, this message translates to:
  /// **'아직 배팅 없음'**
  String get noBidYet;

  /// No description provided for @highestBid.
  ///
  /// In ko, this message translates to:
  /// **'최고 배팅: {bid}'**
  String highestBid(String bid);

  /// No description provided for @bid.
  ///
  /// In ko, this message translates to:
  /// **'배팅'**
  String get bid;

  /// No description provided for @bidButton.
  ///
  /// In ko, this message translates to:
  /// **'배팅하기'**
  String get bidButton;

  /// No description provided for @pass.
  ///
  /// In ko, this message translates to:
  /// **'패스'**
  String get pass;

  /// No description provided for @tricks.
  ///
  /// In ko, this message translates to:
  /// **'목표 점수'**
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
  /// **'받은 카드:'**
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

  /// No description provided for @declarerTeam.
  ///
  /// In ko, this message translates to:
  /// **'주공 팀'**
  String get declarerTeam;

  /// No description provided for @defenderTeam.
  ///
  /// In ko, this message translates to:
  /// **'수비 팀'**
  String get defenderTeam;

  /// No description provided for @fullPoints.
  ///
  /// In ko, this message translates to:
  /// **'풀'**
  String get fullPoints;

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
  /// **'배팅 중...'**
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
  /// **'배팅 차례'**
  String get biddingTurn;

  /// No description provided for @bidWithAmount.
  ///
  /// In ko, this message translates to:
  /// **'배팅 {amount}'**
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

  /// No description provided for @jokerLeadSuitTitle.
  ///
  /// In ko, this message translates to:
  /// **'조커 선공'**
  String get jokerLeadSuitTitle;

  /// No description provided for @jokerLeadSuitQuestion.
  ///
  /// In ko, this message translates to:
  /// **'다른 플레이어가 따라야 할 무늬를 선택하세요'**
  String get jokerLeadSuitQuestion;

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

  /// No description provided for @guideIntro.
  ///
  /// In ko, this message translates to:
  /// **'1. 게임 소개'**
  String get guideIntro;

  /// No description provided for @guideIntroText.
  ///
  /// In ko, this message translates to:
  /// **'마이티는 5명이 즐기는 트릭테이킹 카드 게임입니다.\n조커를 포함한 53장의 카드를 사용하며, 각 플레이어에게 10장씩 나누고 3장은 바닥패(키티)로 남깁니다.\n\n주공(1명)과 프렌드(1명)가 공격팀, 나머지 3명이 수비팀이 됩니다. 주공팀이 공약한 점수 이상을 획득하면 승리합니다.'**
  String get guideIntroText;

  /// No description provided for @guideGameFlow.
  ///
  /// In ko, this message translates to:
  /// **'2. 게임 진행 순서'**
  String get guideGameFlow;

  /// No description provided for @guideGameFlowText.
  ///
  /// In ko, this message translates to:
  /// **'① 카드 분배 → ② 비딩 → ③ 바닥패 교환 → ④ 프렌드 선언 → ⑤ 카드 플레이 → ⑥ 점수 계산\n\n각 단계는 순서대로 진행됩니다. 모든 플레이어가 패스하면 카드를 다시 나눕니다.'**
  String get guideGameFlowText;

  /// No description provided for @guideBidding.
  ///
  /// In ko, this message translates to:
  /// **'3. 비딩 (배팅)'**
  String get guideBidding;

  /// No description provided for @guideBiddingText.
  ///
  /// In ko, this message translates to:
  /// **'자신이 획득할 수 있는 점수 카드 수를 선언합니다.\n\n• 최소 공약: 13점 (점수카드 총 20장 중)\n• 기루다(으뜸패) 무늬를 함께 선언\n• 노기루다: 기루다 없이 선언 (같은 숫자로 기루다 선언보다 우선)\n• 가장 높은 공약을 한 플레이어가 주공이 됩니다\n\n💡 손에 마이티, 조커, 기루다 A가 있으면 높은 공약이 가능합니다.'**
  String get guideBiddingText;

  /// No description provided for @guideKitty.
  ///
  /// In ko, this message translates to:
  /// **'4. 바닥패 교환'**
  String get guideKitty;

  /// No description provided for @guideKittyText.
  ///
  /// In ko, this message translates to:
  /// **'주공은 바닥패 3장을 가져와 13장 중 3장을 버립니다.\n\n• 약한 카드를 버려 핸드를 강화합니다\n• 기루다를 변경할 수 있습니다 (공약 +2 추가)\n• 점수 카드를 버릴 수도 있지만 수비팀에게 유리해질 수 있습니다'**
  String get guideKittyText;

  /// No description provided for @guideFriend.
  ///
  /// In ko, this message translates to:
  /// **'5. 프렌드 선언'**
  String get guideFriend;

  /// No description provided for @guideFriendText.
  ///
  /// In ko, this message translates to:
  /// **'주공이 자신의 팀원(프렌드)을 지정합니다.\n\n• 카드 프렌드: 특정 카드 소유자 (예: ♠A 가진 사람)\n• 초구 프렌드: 첫 번째 트릭을 이기는 사람\n• 노프렌드: 혼자서 (점수 ×2)\n\n프렌드는 해당 카드를 낼 때까지 정체가 드러나지 않습니다. 수비팀은 누가 프렌드인지 추리해야 합니다.'**
  String get guideFriendText;

  /// No description provided for @guideSpecialCards.
  ///
  /// In ko, this message translates to:
  /// **'6. 특수 카드'**
  String get guideSpecialCards;

  /// No description provided for @guideSpecialCardsText.
  ///
  /// In ko, this message translates to:
  /// **'♠A 마이티 (Mighty)\n가장 강한 카드입니다. 어떤 카드도 이길 수 없습니다.\n단, 조커콜 시 반드시 내야 하고, 기루다가 ♠이면 ♦A가 마이티입니다.\n\n🃏 조커 (Joker)\n마이티 다음으로 강한 카드입니다.\n선공 시 무늬를 지정할 수 있고, 초구에는 효력이 없습니다.\n조커콜을 당하면 반드시 조커를 내야 합니다.\n\n기루다 (으뜸패)\n주공이 정한 무늬의 카드입니다.\n비기루다 무늬에서 기루다를 내면 \"컷\"으로 트릭을 이깁니다.'**
  String get guideSpecialCardsText;

  /// No description provided for @guideJokerCall.
  ///
  /// In ko, this message translates to:
  /// **'7. 조커콜'**
  String get guideJokerCall;

  /// No description provided for @guideJokerCallText.
  ///
  /// In ko, this message translates to:
  /// **'선공 플레이어가 특정 무늬의 카드를 내면서 \"조커콜\"을 선언하면, 조커를 가진 플레이어는 반드시 조커를 내야 합니다.\n\n• 초구에는 조커콜 불가\n• 조커콜 시 조커는 가장 약한 카드가 됩니다\n• 수비팀이 상대 조커를 무력화하는 핵심 전략입니다'**
  String get guideJokerCallText;

  /// No description provided for @guideTrickPlay.
  ///
  /// In ko, this message translates to:
  /// **'8. 트릭 플레이'**
  String get guideTrickPlay;

  /// No description provided for @guideTrickPlayText.
  ///
  /// In ko, this message translates to:
  /// **'10번의 트릭(라운드)을 진행합니다.\n\n• 선공 플레이어가 카드 한 장을 냅니다\n• 나머지 플레이어는 같은 무늬의 카드를 내야 합니다 (팔로우)\n• 해당 무늬가 없으면 아무 카드나 낼 수 있습니다\n• 가장 강한 카드를 낸 플레이어가 트릭을 이기고 다음 선공이 됩니다\n\n카드 강도 순서:\n마이티 > 조커 > 기루다(A~2) > 선공 무늬(A~2)'**
  String get guideTrickPlayText;

  /// No description provided for @guideScoring.
  ///
  /// In ko, this message translates to:
  /// **'9. 점수 카드'**
  String get guideScoring;

  /// No description provided for @guideScoringText.
  ///
  /// In ko, this message translates to:
  /// **'점수 카드: A, K, Q, J, 10 (각 무늬 5장 × 4무늬 = 20장)\n각 점수 카드는 1점이며, 트릭에서 이긴 플레이어가 가져갑니다.\n\n예시: 트릭에 ♠A, ♠K, ♥3, ♦7, ♣2가 나왔다면\n→ 점수 카드 2장 (♠A, ♠K) = 2점을 트릭 승자가 획득'**
  String get guideScoringText;

  /// No description provided for @guideWinLose.
  ///
  /// In ko, this message translates to:
  /// **'10. 승패 및 점수 계산'**
  String get guideWinLose;

  /// No description provided for @guideWinLoseText.
  ///
  /// In ko, this message translates to:
  /// **'주공팀이 공약 이상의 점수를 획득하면 승리합니다.\n\n승리 시 기본 점수:\n• (획득 점수 - 공약) + 1 + 추가 보너스\n• 런(10트릭 전부 승리): 보너스 점수\n• 노프렌드: 점수 ×2\n• 노기루다: 점수 ×2\n\n패배 시:\n• 주공은 (수비팀 인원 × 기본 점수)만큼 감점\n• 백런(수비 전승): 추가 감점'**
  String get guideWinLoseText;

  /// No description provided for @guideTips.
  ///
  /// In ko, this message translates to:
  /// **'11. 전략 팁'**
  String get guideTips;

  /// No description provided for @guideTipsText.
  ///
  /// In ko, this message translates to:
  /// **'주공 전략:\n• 마이티/조커/기루다A가 있으면 적극적으로 비딩하세요\n• 초반에 기루다를 소진시켜 상대 컷을 방지하세요\n• 프렌드와 협력하여 점수 카드를 모으세요\n\n수비 전략:\n• 프렌드의 정체를 빨리 파악하세요\n• 조커콜로 상대 조커를 무력화하세요\n• 점수 카드를 주공팀에게 주지 않도록 주의하세요\n• 기루다 컷으로 상대 비기루다 A를 잡으세요'**
  String get guideTipsText;

  /// No description provided for @close.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get close;

  /// No description provided for @dealMiss.
  ///
  /// In ko, this message translates to:
  /// **'딜 미스'**
  String get dealMiss;

  /// No description provided for @dealMissTitle.
  ///
  /// In ko, this message translates to:
  /// **'딜 미스 선언'**
  String get dealMissTitle;

  /// No description provided for @dealMissConfirm.
  ///
  /// In ko, this message translates to:
  /// **'딜 미스를 선언하시겠습니까?\n패를 공개하고 새로 시작합니다.'**
  String get dealMissConfirm;

  /// No description provided for @dealMissAnnouncement.
  ///
  /// In ko, this message translates to:
  /// **'{name} 딜 미스 선언!'**
  String dealMissAnnouncement(String name);

  /// No description provided for @dealMissNewGame.
  ///
  /// In ko, this message translates to:
  /// **'딜 미스로 게임을 다시 시작합니다.'**
  String get dealMissNewGame;

  /// No description provided for @aiPlayer1.
  ///
  /// In ko, this message translates to:
  /// **'민준'**
  String get aiPlayer1;

  /// No description provided for @aiPlayer2.
  ///
  /// In ko, this message translates to:
  /// **'서연'**
  String get aiPlayer2;

  /// No description provided for @aiPlayer3.
  ///
  /// In ko, this message translates to:
  /// **'지호'**
  String get aiPlayer3;

  /// No description provided for @aiPlayer4.
  ///
  /// In ko, this message translates to:
  /// **'수빈'**
  String get aiPlayer4;

  /// No description provided for @scoreCalcWin.
  ///
  /// In ko, this message translates to:
  /// **'점수 계산 (승리)'**
  String get scoreCalcWin;

  /// No description provided for @scoreCalcLose.
  ///
  /// In ko, this message translates to:
  /// **'점수 계산 (패배)'**
  String get scoreCalcLose;

  /// No description provided for @scoreFormula.
  ///
  /// In ko, this message translates to:
  /// **'(득점-공약+1) + (득점-최소)×2'**
  String get scoreFormula;

  /// No description provided for @scoreFormulaLose.
  ///
  /// In ko, this message translates to:
  /// **'-(공약 - 득점)'**
  String get scoreFormulaLose;

  /// No description provided for @scoreMultipliers.
  ///
  /// In ko, this message translates to:
  /// **'주공 ×2, 프렌드 ×1, 야당 ×(-1)'**
  String get scoreMultipliers;

  /// No description provided for @scoreMultipliersNoFriend.
  ///
  /// In ko, this message translates to:
  /// **'주공 ×3, 야당 ×(-1)'**
  String get scoreMultipliersNoFriend;

  /// No description provided for @multiplierRun.
  ///
  /// In ko, this message translates to:
  /// **'런 ×2'**
  String get multiplierRun;

  /// No description provided for @multiplierNoGiruda.
  ///
  /// In ko, this message translates to:
  /// **'노기루다 ×2'**
  String get multiplierNoGiruda;

  /// No description provided for @multiplierNoFriend.
  ///
  /// In ko, this message translates to:
  /// **'노프렌드 ×2'**
  String get multiplierNoFriend;

  /// No description provided for @multiplierBackRun.
  ///
  /// In ko, this message translates to:
  /// **'백런 ×2'**
  String get multiplierBackRun;

  /// No description provided for @multiplierLabel.
  ///
  /// In ko, this message translates to:
  /// **'배수'**
  String get multiplierLabel;

  /// No description provided for @selectGame.
  ///
  /// In ko, this message translates to:
  /// **'게임 선택'**
  String get selectGame;

  /// No description provided for @sevenCardTitle.
  ///
  /// In ko, this message translates to:
  /// **'세븐 포커'**
  String get sevenCardTitle;

  /// No description provided for @sevenCardSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'7장 카드 포커 게임'**
  String get sevenCardSubtitle;

  /// No description provided for @sevenCardRules.
  ///
  /// In ko, this message translates to:
  /// **'게임 규칙'**
  String get sevenCardRules;

  /// No description provided for @sevenCardRulesText.
  ///
  /// In ko, this message translates to:
  /// **'• 각 플레이어는 7장의 카드를 받습니다\n• 처음 3장은 비공개, 나머지 4장은 공개\n• 베팅 라운드를 거쳐 최종 5장으로 족보를 만듭니다\n• 가장 높은 족보를 가진 플레이어가 승리'**
  String get sevenCardRulesText;

  /// No description provided for @pot.
  ///
  /// In ko, this message translates to:
  /// **'팟'**
  String get pot;

  /// No description provided for @currentBet.
  ///
  /// In ko, this message translates to:
  /// **'현재 베팅'**
  String get currentBet;

  /// No description provided for @betting.
  ///
  /// In ko, this message translates to:
  /// **'라운드'**
  String get betting;

  /// No description provided for @chips.
  ///
  /// In ko, this message translates to:
  /// **'칩'**
  String get chips;

  /// No description provided for @bet.
  ///
  /// In ko, this message translates to:
  /// **'베팅'**
  String get bet;

  /// No description provided for @fold.
  ///
  /// In ko, this message translates to:
  /// **'다이'**
  String get fold;

  /// No description provided for @call.
  ///
  /// In ko, this message translates to:
  /// **'콜'**
  String get call;

  /// No description provided for @raise.
  ///
  /// In ko, this message translates to:
  /// **'레이즈'**
  String get raise;

  /// No description provided for @check.
  ///
  /// In ko, this message translates to:
  /// **'체크'**
  String get check;

  /// No description provided for @allIn.
  ///
  /// In ko, this message translates to:
  /// **'올인'**
  String get allIn;

  /// No description provided for @folded.
  ///
  /// In ko, this message translates to:
  /// **'다이'**
  String get folded;

  /// No description provided for @wins.
  ///
  /// In ko, this message translates to:
  /// **'승리'**
  String get wins;

  /// No description provided for @gameEnd.
  ///
  /// In ko, this message translates to:
  /// **'게임 종료'**
  String get gameEnd;

  /// No description provided for @hiLoTitle.
  ///
  /// In ko, this message translates to:
  /// **'하이로우'**
  String get hiLoTitle;

  /// No description provided for @hiLoSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'하이/로우 스플릿 포커'**
  String get hiLoSubtitle;

  /// No description provided for @hi.
  ///
  /// In ko, this message translates to:
  /// **'하이'**
  String get hi;

  /// No description provided for @lo.
  ///
  /// In ko, this message translates to:
  /// **'로우'**
  String get lo;

  /// No description provided for @swing.
  ///
  /// In ko, this message translates to:
  /// **'스윙'**
  String get swing;

  /// No description provided for @selectHiLo.
  ///
  /// In ko, this message translates to:
  /// **'하이/로우 선택'**
  String get selectHiLo;

  /// No description provided for @selectHiLoDesc.
  ///
  /// In ko, this message translates to:
  /// **'하이, 로우, 또는 스윙을 선택하세요'**
  String get selectHiLoDesc;

  /// No description provided for @hiWinner.
  ///
  /// In ko, this message translates to:
  /// **'하이 승자'**
  String get hiWinner;

  /// No description provided for @loWinner.
  ///
  /// In ko, this message translates to:
  /// **'로우 승자'**
  String get loWinner;

  /// No description provided for @swingSuccess.
  ///
  /// In ko, this message translates to:
  /// **'스윙 성공!'**
  String get swingSuccess;

  /// No description provided for @swingFailed.
  ///
  /// In ko, this message translates to:
  /// **'스윙 실패'**
  String get swingFailed;

  /// No description provided for @hiPot.
  ///
  /// In ko, this message translates to:
  /// **'하이 팟'**
  String get hiPot;

  /// No description provided for @loPot.
  ///
  /// In ko, this message translates to:
  /// **'로우 팟'**
  String get loPot;

  /// No description provided for @noLowHand.
  ///
  /// In ko, this message translates to:
  /// **'로우 없음'**
  String get noLowHand;

  /// No description provided for @bestLow.
  ///
  /// In ko, this message translates to:
  /// **'베스트 로우'**
  String get bestLow;

  /// No description provided for @waitingForHiLo.
  ///
  /// In ko, this message translates to:
  /// **'선택 대기 중...'**
  String get waitingForHiLo;

  /// No description provided for @selectedHi.
  ///
  /// In ko, this message translates to:
  /// **'하이 선택'**
  String get selectedHi;

  /// No description provided for @selectedLo.
  ///
  /// In ko, this message translates to:
  /// **'로우 선택'**
  String get selectedLo;

  /// No description provided for @selectedSwing.
  ///
  /// In ko, this message translates to:
  /// **'스윙 선택'**
  String get selectedSwing;

  /// No description provided for @showdownTitle.
  ///
  /// In ko, this message translates to:
  /// **'선언 현황'**
  String get showdownTitle;

  /// No description provided for @showdownDesc.
  ///
  /// In ko, this message translates to:
  /// **'각 플레이어의 선택을 확인하세요'**
  String get showdownDesc;

  /// No description provided for @viewResults.
  ///
  /// In ko, this message translates to:
  /// **'결과 보기'**
  String get viewResults;

  /// No description provided for @finalResults.
  ///
  /// In ko, this message translates to:
  /// **'최종 결과'**
  String get finalResults;

  /// No description provided for @sevenCardGuideOverview.
  ///
  /// In ko, this message translates to:
  /// **'게임 개요'**
  String get sevenCardGuideOverview;

  /// No description provided for @sevenCardGuideOverviewText.
  ///
  /// In ko, this message translates to:
  /// **'세븐 포커는 5명이 즐기는 포커 게임입니다. 7장의 카드 중 5장으로 가장 높은 족보를 만들어 승리하세요.'**
  String get sevenCardGuideOverviewText;

  /// No description provided for @sevenCardGuideDealing.
  ///
  /// In ko, this message translates to:
  /// **'카드 배분'**
  String get sevenCardGuideDealing;

  /// No description provided for @sevenCardGuideDealingText.
  ///
  /// In ko, this message translates to:
  /// **'• 처음에 4장을 받습니다 (3장 비공개, 1장 공개)\n• 베팅 후 한 장씩 공개 카드를 받습니다\n• 최종 7장 중 5장으로 족보를 만듭니다'**
  String get sevenCardGuideDealingText;

  /// No description provided for @sevenCardGuideBetting.
  ///
  /// In ko, this message translates to:
  /// **'베팅 규칙'**
  String get sevenCardGuideBetting;

  /// No description provided for @sevenCardGuideBettingText.
  ///
  /// In ko, this message translates to:
  /// **'• 체크: 베팅 없이 넘기기\n• 콜: 현재 베팅에 맞추기\n• 레이즈: 베팅 금액 올리기\n• 다이: 게임 포기\n• 올인: 모든 칩 베팅'**
  String get sevenCardGuideBettingText;

  /// No description provided for @sevenCardGuideHands.
  ///
  /// In ko, this message translates to:
  /// **'족보 순위'**
  String get sevenCardGuideHands;

  /// No description provided for @sevenCardGuideHandsText.
  ///
  /// In ko, this message translates to:
  /// **'1. 로열 스트레이트 플러시\n2. 백 스트레이트 플러시\n3. 스트레이트 플러시\n4. 포카드\n5. 풀하우스\n6. 플러시\n7. 마운틴 (A-K-Q-J-10)\n8. 백스트레이트 (A-2-3-4-5)\n9. 스트레이트\n10. 트리플\n11. 투페어\n12. 원페어\n13. 하이카드'**
  String get sevenCardGuideHandsText;

  /// No description provided for @sevenCardGuideTips.
  ///
  /// In ko, this message translates to:
  /// **'게임 팁'**
  String get sevenCardGuideTips;

  /// No description provided for @sevenCardGuideTipsText.
  ///
  /// In ko, this message translates to:
  /// **'• 공개 카드로 상대방 족보를 예측하세요\n• 강한 핸드가 아니면 과도한 베팅을 피하세요\n• 블러핑도 전략입니다'**
  String get sevenCardGuideTipsText;

  /// No description provided for @sevenCardGuideBonus.
  ///
  /// In ko, this message translates to:
  /// **'보너스 핸드'**
  String get sevenCardGuideBonus;

  /// No description provided for @sevenCardGuideBonusText.
  ///
  /// In ko, this message translates to:
  /// **'• 로열 스트레이트 플러시: 500칩\n• 백 스트레이트 플러시: 300칩\n• 스트레이트 플러시: 200칩\n• 포카드: 100칩\n\n보너스 핸드 달성 시 다른 모든 플레이어에게 보너스를 받습니다!'**
  String get sevenCardGuideBonusText;

  /// No description provided for @hiLoGuideOverview.
  ///
  /// In ko, this message translates to:
  /// **'게임 개요'**
  String get hiLoGuideOverview;

  /// No description provided for @hiLoGuideOverviewText.
  ///
  /// In ko, this message translates to:
  /// **'하이로우는 세븐 포커의 변형으로, 팟이 하이(높은 족보)와 로우(낮은 족보) 승자에게 나뉩니다.'**
  String get hiLoGuideOverviewText;

  /// No description provided for @hiLoGuideDealing.
  ///
  /// In ko, this message translates to:
  /// **'카드 배분'**
  String get hiLoGuideDealing;

  /// No description provided for @hiLoGuideDealingText.
  ///
  /// In ko, this message translates to:
  /// **'• 세븐 포커와 동일한 방식으로 진행\n• 7장의 카드 중 5장으로 족보를 만듭니다\n• 마지막 베팅 후 하이/로우/스윙 선택'**
  String get hiLoGuideDealingText;

  /// No description provided for @hiLoGuideHiLo.
  ///
  /// In ko, this message translates to:
  /// **'하이/로우 선택'**
  String get hiLoGuideHiLo;

  /// No description provided for @hiLoGuideHiLoText.
  ///
  /// In ko, this message translates to:
  /// **'• 하이: 가장 높은 족보로 경쟁\n• 로우: 가장 낮은 족보로 경쟁\n• 스윙: 하이와 로우 모두 도전\n\n팟의 50%는 하이 승자, 50%는 로우 승자가 가져갑니다.'**
  String get hiLoGuideHiLoText;

  /// No description provided for @hiLoGuideLow.
  ///
  /// In ko, this message translates to:
  /// **'로우 족보'**
  String get hiLoGuideLow;

  /// No description provided for @hiLoGuideLowText.
  ///
  /// In ko, this message translates to:
  /// **'• 스트레이트/플러시 없는 핸드만 로우 자격\n• 낮을수록 좋음 (A가 가장 낮음)\n• 최강 로우: A-2-3-4-6\n• 페어가 없는 핸드가 유리'**
  String get hiLoGuideLowText;

  /// No description provided for @hiLoGuideSwing.
  ///
  /// In ko, this message translates to:
  /// **'스윙 규칙'**
  String get hiLoGuideSwing;

  /// No description provided for @hiLoGuideSwingText.
  ///
  /// In ko, this message translates to:
  /// **'• 7장을 두 개의 5장 핸드로 나눕니다\n• 하이와 로우 모두 1등해야 성공\n• 성공 시 전체 팟 획득\n• 실패 시 해당 부분은 다른 승자에게'**
  String get hiLoGuideSwingText;

  /// No description provided for @hiLoGuideTips.
  ///
  /// In ko, this message translates to:
  /// **'게임 팁'**
  String get hiLoGuideTips;

  /// No description provided for @hiLoGuideTipsText.
  ///
  /// In ko, this message translates to:
  /// **'• A-2-3-4 같은 낮은 카드는 로우에 유리\n• 스윙은 위험하지만 성공 시 큰 보상\n• 상대 카드를 보고 전략을 세우세요'**
  String get hiLoGuideTipsText;

  /// No description provided for @hiLoGuideBonus.
  ///
  /// In ko, this message translates to:
  /// **'보너스 핸드'**
  String get hiLoGuideBonus;

  /// No description provided for @hiLoGuideBonusText.
  ///
  /// In ko, this message translates to:
  /// **'• 로열 스트레이트 플러시: 500칩\n• 백 스트레이트 플러시: 300칩\n• 스트레이트 플러시: 200칩\n• 포카드: 100칩\n\n보너스 핸드 달성 시 자동으로 전체 팟을 획득합니다!'**
  String get hiLoGuideBonusText;

  /// No description provided for @hulaTitle.
  ///
  /// In ko, this message translates to:
  /// **'훌라'**
  String get hulaTitle;

  /// No description provided for @hulaSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'4인용 러미 카드 게임'**
  String get hulaSubtitle;

  /// No description provided for @heartsTitle.
  ///
  /// In ko, this message translates to:
  /// **'하트'**
  String get heartsTitle;

  /// No description provided for @heartsSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'4인 트릭 테이킹 게임'**
  String get heartsSubtitle;

  /// No description provided for @handRoyalStraightFlush.
  ///
  /// In ko, this message translates to:
  /// **'로열 스트레이트 플러시'**
  String get handRoyalStraightFlush;

  /// No description provided for @handBackStraightFlush.
  ///
  /// In ko, this message translates to:
  /// **'백스트레이트 플러시'**
  String get handBackStraightFlush;

  /// No description provided for @handStraightFlush.
  ///
  /// In ko, this message translates to:
  /// **'스트레이트 플러시'**
  String get handStraightFlush;

  /// No description provided for @handFourOfAKind.
  ///
  /// In ko, this message translates to:
  /// **'포카드'**
  String get handFourOfAKind;

  /// No description provided for @handFullHouse.
  ///
  /// In ko, this message translates to:
  /// **'풀하우스'**
  String get handFullHouse;

  /// No description provided for @handFlush.
  ///
  /// In ko, this message translates to:
  /// **'플러시'**
  String get handFlush;

  /// No description provided for @handMountain.
  ///
  /// In ko, this message translates to:
  /// **'마운틴'**
  String get handMountain;

  /// No description provided for @handBackStraight.
  ///
  /// In ko, this message translates to:
  /// **'백스트레이트'**
  String get handBackStraight;

  /// No description provided for @handStraight.
  ///
  /// In ko, this message translates to:
  /// **'스트레이트'**
  String get handStraight;

  /// No description provided for @handTriple.
  ///
  /// In ko, this message translates to:
  /// **'트리플'**
  String get handTriple;

  /// No description provided for @handTwoPair.
  ///
  /// In ko, this message translates to:
  /// **'투페어'**
  String get handTwoPair;

  /// No description provided for @handOnePair.
  ///
  /// In ko, this message translates to:
  /// **'원페어'**
  String get handOnePair;

  /// No description provided for @handHighCard.
  ///
  /// In ko, this message translates to:
  /// **'하이카드'**
  String get handHighCard;

  /// No description provided for @highCardTop.
  ///
  /// In ko, this message translates to:
  /// **'{rank}탑'**
  String highCardTop(String rank);

  /// No description provided for @noLow.
  ///
  /// In ko, this message translates to:
  /// **'No Low'**
  String get noLow;

  /// No description provided for @betPing.
  ///
  /// In ko, this message translates to:
  /// **'삥'**
  String get betPing;

  /// No description provided for @betCheck.
  ///
  /// In ko, this message translates to:
  /// **'체크'**
  String get betCheck;

  /// No description provided for @betCall.
  ///
  /// In ko, this message translates to:
  /// **'콜'**
  String get betCall;

  /// No description provided for @betDdadang.
  ///
  /// In ko, this message translates to:
  /// **'따당'**
  String get betDdadang;

  /// No description provided for @betQuarter.
  ///
  /// In ko, this message translates to:
  /// **'쿼터'**
  String get betQuarter;

  /// No description provided for @betHalf.
  ///
  /// In ko, this message translates to:
  /// **'하프'**
  String get betHalf;

  /// No description provided for @betFull.
  ///
  /// In ko, this message translates to:
  /// **'풀'**
  String get betFull;

  /// No description provided for @betDie.
  ///
  /// In ko, this message translates to:
  /// **'다이'**
  String get betDie;

  /// No description provided for @selectOpenCard.
  ///
  /// In ko, this message translates to:
  /// **'공개할 카드를 선택하세요'**
  String get selectOpenCard;

  /// No description provided for @selectOpenCardDesc.
  ///
  /// In ko, this message translates to:
  /// **'선택한 카드가 상대에게 공개됩니다'**
  String get selectOpenCardDesc;

  /// No description provided for @aiSelectingCard.
  ///
  /// In ko, this message translates to:
  /// **'AI가 카드를 선택하고 있습니다...'**
  String get aiSelectingCard;

  /// No description provided for @nthCard.
  ///
  /// In ko, this message translates to:
  /// **'{n}번째 카드'**
  String nthCard(int n);

  /// No description provided for @secondsCount.
  ///
  /// In ko, this message translates to:
  /// **'{n}초'**
  String secondsCount(int n);

  /// No description provided for @totalBetAmount.
  ///
  /// In ko, this message translates to:
  /// **'총: {amount}'**
  String totalBetAmount(int amount);

  /// No description provided for @bettingAmount.
  ///
  /// In ko, this message translates to:
  /// **'베팅: {amount}'**
  String bettingAmount(int amount);

  /// No description provided for @bonusHand.
  ///
  /// In ko, this message translates to:
  /// **'보너스 핸드!'**
  String get bonusHand;

  /// No description provided for @bonus.
  ///
  /// In ko, this message translates to:
  /// **'보너스'**
  String get bonus;

  /// No description provided for @total.
  ///
  /// In ko, this message translates to:
  /// **'총'**
  String get total;

  /// No description provided for @otherPlayersLose.
  ///
  /// In ko, this message translates to:
  /// **'다른 플레이어: 각 -{amount}'**
  String otherPlayersLose(int amount);

  /// No description provided for @thisGame.
  ///
  /// In ko, this message translates to:
  /// **'이번 게임'**
  String get thisGame;

  /// No description provided for @cumulative.
  ///
  /// In ko, this message translates to:
  /// **'누적'**
  String get cumulative;

  /// No description provided for @foldedSection.
  ///
  /// In ko, this message translates to:
  /// **'다이'**
  String get foldedSection;

  /// No description provided for @hiLoHi.
  ///
  /// In ko, this message translates to:
  /// **'하이'**
  String get hiLoHi;

  /// No description provided for @hiLoLo.
  ///
  /// In ko, this message translates to:
  /// **'로우'**
  String get hiLoLo;

  /// No description provided for @hiLoSwing.
  ///
  /// In ko, this message translates to:
  /// **'스윙'**
  String get hiLoSwing;

  /// No description provided for @roundComplete.
  ///
  /// In ko, this message translates to:
  /// **'라운드 {n} 완료!'**
  String roundComplete(int n);

  /// No description provided for @cardDistribution5.
  ///
  /// In ko, this message translates to:
  /// **'5번째 카드가 배분됩니다.'**
  String get cardDistribution5;

  /// No description provided for @cardDistribution6.
  ///
  /// In ko, this message translates to:
  /// **'6번째 카드가 배분됩니다.'**
  String get cardDistribution6;

  /// No description provided for @cardDistribution7.
  ///
  /// In ko, this message translates to:
  /// **'마지막 7번째 카드가 배분됩니다.'**
  String get cardDistribution7;

  /// No description provided for @goodLuck.
  ///
  /// In ko, this message translates to:
  /// **'GOOD LUCK!'**
  String get goodLuck;

  /// No description provided for @cardCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}장'**
  String cardCount(int count);

  /// No description provided for @suitSpade.
  ///
  /// In ko, this message translates to:
  /// **'스페이드'**
  String get suitSpade;

  /// No description provided for @suitDiamond.
  ///
  /// In ko, this message translates to:
  /// **'다이아몬드'**
  String get suitDiamond;

  /// No description provided for @suitHeart.
  ///
  /// In ko, this message translates to:
  /// **'하트'**
  String get suitHeart;

  /// No description provided for @suitClub.
  ///
  /// In ko, this message translates to:
  /// **'클럽'**
  String get suitClub;

  /// No description provided for @cardOwner.
  ///
  /// In ko, this message translates to:
  /// **'{card} 소유자'**
  String cardOwner(String card);

  /// No description provided for @trickWinner.
  ///
  /// In ko, this message translates to:
  /// **'{n}트릭 승자'**
  String trickWinner(int n);

  /// No description provided for @hint.
  ///
  /// In ko, this message translates to:
  /// **'힌트'**
  String get hint;

  /// No description provided for @hintOff.
  ///
  /// In ko, this message translates to:
  /// **'힌트 OFF'**
  String get hintOff;

  /// No description provided for @hintDialogContent.
  ///
  /// In ko, this message translates to:
  /// **'광고를 시청하면 힌트가 활성화됩니다.\n계속하시겠습니까?'**
  String get hintDialogContent;

  /// No description provided for @newGameDialogContent.
  ///
  /// In ko, this message translates to:
  /// **'광고를 시청하면 새 게임을 시작합니다.\n계속하시겠습니까?'**
  String get newGameDialogContent;

  /// No description provided for @watchAd.
  ///
  /// In ko, this message translates to:
  /// **'광고 보기'**
  String get watchAd;

  /// No description provided for @jokerLead.
  ///
  /// In ko, this message translates to:
  /// **'조커 선공: {suit}'**
  String jokerLead(String suit);

  /// No description provided for @gameSelection.
  ///
  /// In ko, this message translates to:
  /// **'게임 선택'**
  String get gameSelection;

  /// No description provided for @onecardTitle.
  ///
  /// In ko, this message translates to:
  /// **'원카드'**
  String get onecardTitle;

  /// No description provided for @onecardSubtitle.
  ///
  /// In ko, this message translates to:
  /// **'4인 대전'**
  String get onecardSubtitle;

  /// No description provided for @gameRules.
  ///
  /// In ko, this message translates to:
  /// **'게임 규칙'**
  String get gameRules;

  /// No description provided for @heartsGuideGoal.
  ///
  /// In ko, this message translates to:
  /// **'목표'**
  String get heartsGuideGoal;

  /// No description provided for @heartsGuideGoalText.
  ///
  /// In ko, this message translates to:
  /// **'하트 카드와 스페이드 퀸을 피해 가장 낮은 점수를 얻는 것이 목표입니다.'**
  String get heartsGuideGoalText;

  /// No description provided for @heartsGuideHow.
  ///
  /// In ko, this message translates to:
  /// **'진행 방법'**
  String get heartsGuideHow;

  /// No description provided for @heartsGuideHowText.
  ///
  /// In ko, this message translates to:
  /// **'• 4명이 플레이하며 각자 13장씩 받습니다\n• 게임 시작 시 3장을 왼쪽 플레이어에게 전달\n• 클럽 2를 가진 플레이어가 먼저 시작\n• 13트릭을 진행하며 점수 카드를 피합니다'**
  String get heartsGuideHowText;

  /// No description provided for @heartsGuideScoring.
  ///
  /// In ko, this message translates to:
  /// **'점수 계산'**
  String get heartsGuideScoring;

  /// No description provided for @heartsGuideScoringText.
  ///
  /// In ko, this message translates to:
  /// **'• 하트 카드: 각 1점 (총 13점)\n• 스페이드 퀸 (♠Q): 13점\n• 총점: 26점\n• 낮은 점수가 승리!'**
  String get heartsGuideScoringText;

  /// No description provided for @heartsGuideBreaking.
  ///
  /// In ko, this message translates to:
  /// **'하트 브레이킹'**
  String get heartsGuideBreaking;

  /// No description provided for @heartsGuideBreakingText.
  ///
  /// In ko, this message translates to:
  /// **'첫 트릭에서는 하트를 낼 수 없습니다.\n하트가 한 번 나온 후에야 하트로 시작할 수 있습니다.'**
  String get heartsGuideBreakingText;

  /// No description provided for @heartsGuideShootMoon.
  ///
  /// In ko, this message translates to:
  /// **'슈팅 더 문'**
  String get heartsGuideShootMoon;

  /// No description provided for @heartsGuideShootMoonText.
  ///
  /// In ko, this message translates to:
  /// **'한 플레이어가 모든 하트와 스페이드 퀸을 획득하면:\n• 그 플레이어: 0점\n• 다른 플레이어: 각 26점'**
  String get heartsGuideShootMoonText;

  /// No description provided for @heartsGuideTips.
  ///
  /// In ko, this message translates to:
  /// **'전략 팁'**
  String get heartsGuideTips;

  /// No description provided for @heartsGuideTipsText.
  ///
  /// In ko, this message translates to:
  /// **'• 높은 카드는 일찍 버리세요\n• 스페이드 퀸을 조심하세요\n• 상대방에게 점수 카드를 먹이세요'**
  String get heartsGuideTipsText;

  /// No description provided for @allScoreCardsUsed.
  ///
  /// In ko, this message translates to:
  /// **'모든 점수 카드 소진! 게임 종료'**
  String get allScoreCardsUsed;

  /// No description provided for @passLeftCount.
  ///
  /// In ko, this message translates to:
  /// **'왼쪽으로 패스 ({count}/3)'**
  String passLeftCount(int count);

  /// No description provided for @cardPass.
  ///
  /// In ko, this message translates to:
  /// **'카드 패스'**
  String get cardPass;

  /// No description provided for @trickProgress.
  ///
  /// In ko, this message translates to:
  /// **'트릭 {current}/13'**
  String trickProgress(int current);

  /// No description provided for @heartBroken.
  ///
  /// In ko, this message translates to:
  /// **'하트 브레이킹'**
  String get heartBroken;

  /// No description provided for @passRecommend.
  ///
  /// In ko, this message translates to:
  /// **'패스 추천'**
  String get passRecommend;

  /// No description provided for @recommend.
  ///
  /// In ko, this message translates to:
  /// **'추천'**
  String get recommend;

  /// No description provided for @selectCardsToPassLeft.
  ///
  /// In ko, this message translates to:
  /// **'왼쪽으로 보낼 카드 3장을 선택하세요'**
  String get selectCardsToPassLeft;

  /// No description provided for @playerNameWins.
  ///
  /// In ko, this message translates to:
  /// **'{name} 승리'**
  String playerNameWins(String name);

  /// No description provided for @playerStartsWithClub2.
  ///
  /// In ko, this message translates to:
  /// **'{name}가 클럽 2로 시작합니다'**
  String playerStartsWithClub2(String name);

  /// No description provided for @playerWonTrick.
  ///
  /// In ko, this message translates to:
  /// **'{name} 트릭 획득! (+{points}점)'**
  String playerWonTrick(String name, int points);

  /// No description provided for @playerShootMoonSuccess.
  ///
  /// In ko, this message translates to:
  /// **'{name} 슈팅 더 문 성공!'**
  String playerShootMoonSuccess(String name);

  /// No description provided for @hintActivated.
  ///
  /// In ko, this message translates to:
  /// **'힌트가 활성화되었습니다!'**
  String get hintActivated;

  /// No description provided for @myTurn.
  ///
  /// In ko, this message translates to:
  /// **'내 차례'**
  String get myTurn;

  /// No description provided for @start.
  ///
  /// In ko, this message translates to:
  /// **'시작'**
  String get start;

  /// No description provided for @counterClockwise.
  ///
  /// In ko, this message translates to:
  /// **'반시계'**
  String get counterClockwise;

  /// No description provided for @clockwise.
  ///
  /// In ko, this message translates to:
  /// **'시계'**
  String get clockwise;

  /// No description provided for @blackJoker.
  ///
  /// In ko, this message translates to:
  /// **'흑백 조커'**
  String get blackJoker;

  /// No description provided for @colorJoker.
  ///
  /// In ko, this message translates to:
  /// **'컬러 조커'**
  String get colorJoker;

  /// No description provided for @oneCardCall.
  ///
  /// In ko, this message translates to:
  /// **'원카드!'**
  String get oneCardCall;

  /// No description provided for @oneCardCallTimer.
  ///
  /// In ko, this message translates to:
  /// **'원카드 ({seconds}초)'**
  String oneCardCallTimer(int seconds);

  /// No description provided for @selectSuit.
  ///
  /// In ko, this message translates to:
  /// **'무늬를 선택하세요'**
  String get selectSuit;

  /// No description provided for @discardedCards.
  ///
  /// In ko, this message translates to:
  /// **'버린 카드'**
  String get discardedCards;

  /// No description provided for @meld.
  ///
  /// In ko, this message translates to:
  /// **'등록'**
  String get meld;

  /// No description provided for @discard.
  ///
  /// In ko, this message translates to:
  /// **'버리기'**
  String get discard;

  /// No description provided for @stop.
  ///
  /// In ko, this message translates to:
  /// **'스톱'**
  String get stop;

  /// No description provided for @handCards.
  ///
  /// In ko, this message translates to:
  /// **'손패'**
  String get handCards;

  /// No description provided for @cannotPlayCard.
  ///
  /// In ko, this message translates to:
  /// **'이 카드는 낼 수 없습니다'**
  String get cannotPlayCard;

  /// No description provided for @drawCard.
  ///
  /// In ko, this message translates to:
  /// **'카드를 뽑으세요'**
  String get drawCard;

  /// No description provided for @discardOrMeld.
  ///
  /// In ko, this message translates to:
  /// **'카드를 버리거나 등록하세요'**
  String get discardOrMeld;

  /// No description provided for @noCards.
  ///
  /// In ko, this message translates to:
  /// **'카드가 없습니다'**
  String get noCards;

  /// No description provided for @thankYouSelectMethod.
  ///
  /// In ko, this message translates to:
  /// **'땡큐 방법을 선택하세요'**
  String get thankYouSelectMethod;

  /// No description provided for @thankYouMeldSolo.
  ///
  /// In ko, this message translates to:
  /// **'땡큐! {suit}7 단독 등록'**
  String thankYouMeldSolo(String suit);

  /// No description provided for @thankYouMeldMyMeld.
  ///
  /// In ko, this message translates to:
  /// **'땡큐! {card} 내 멜드에 붙이기'**
  String thankYouMeldMyMeld(String card);

  /// No description provided for @thankYouMeldAiMeld.
  ///
  /// In ko, this message translates to:
  /// **'땡큐! {card} {aiName} 멜드에 붙이기'**
  String thankYouMeldAiMeld(String card, String aiName);

  /// No description provided for @addedToMeld.
  ///
  /// In ko, this message translates to:
  /// **'멜드에 추가됨'**
  String get addedToMeld;

  /// No description provided for @noMeldToAttach.
  ///
  /// In ko, this message translates to:
  /// **'붙일 멜드가 없습니다'**
  String get noMeldToAttach;

  /// No description provided for @invalidCombination.
  ///
  /// In ko, this message translates to:
  /// **'유효하지 않은 조합입니다'**
  String get invalidCombination;

  /// No description provided for @drawCardFirst.
  ///
  /// In ko, this message translates to:
  /// **'먼저 카드를 뽑으세요'**
  String get drawCardFirst;

  /// No description provided for @selectCardToDiscard.
  ///
  /// In ko, this message translates to:
  /// **'버릴 카드를 선택하세요'**
  String get selectCardToDiscard;

  /// No description provided for @hulaWin.
  ///
  /// In ko, this message translates to:
  /// **'훌라로 승리! (x2)'**
  String get hulaWin;

  /// No description provided for @continue_.
  ///
  /// In ko, this message translates to:
  /// **'이어하기'**
  String get continue_;

  /// No description provided for @attackReceived.
  ///
  /// In ko, this message translates to:
  /// **'공격으로 {count}장을 받았습니다'**
  String attackReceived(int count);

  /// No description provided for @cardDrawn.
  ///
  /// In ko, this message translates to:
  /// **'카드를 뽑았습니다'**
  String get cardDrawn;

  /// No description provided for @bankrupt.
  ///
  /// In ko, this message translates to:
  /// **'파산! ({count}장 보유)'**
  String bankrupt(int count);

  /// No description provided for @restart.
  ///
  /// In ko, this message translates to:
  /// **'다시 시작'**
  String get restart;

  /// No description provided for @goal.
  ///
  /// In ko, this message translates to:
  /// **'목표'**
  String get goal;

  /// No description provided for @howToPlay.
  ///
  /// In ko, this message translates to:
  /// **'진행 방법'**
  String get howToPlay;

  /// No description provided for @attackCards.
  ///
  /// In ko, this message translates to:
  /// **'공격 카드'**
  String get attackCards;

  /// No description provided for @defense.
  ///
  /// In ko, this message translates to:
  /// **'방어'**
  String get defense;

  /// No description provided for @specialCards.
  ///
  /// In ko, this message translates to:
  /// **'특수 카드'**
  String get specialCards;

  /// No description provided for @tips.
  ///
  /// In ko, this message translates to:
  /// **'게임 팁'**
  String get tips;

  /// No description provided for @winRate.
  ///
  /// In ko, this message translates to:
  /// **'승률'**
  String get winRate;

  /// No description provided for @onecardGuideGoal.
  ///
  /// In ko, this message translates to:
  /// **'목표'**
  String get onecardGuideGoal;

  /// No description provided for @onecardGuideGoalText.
  ///
  /// In ko, this message translates to:
  /// **'손에 든 카드를 가장 먼저 모두 내려놓는 것이 목표입니다.'**
  String get onecardGuideGoalText;

  /// No description provided for @onecardGuidePlay.
  ///
  /// In ko, this message translates to:
  /// **'카드 내기'**
  String get onecardGuidePlay;

  /// No description provided for @onecardGuidePlayText.
  ///
  /// In ko, this message translates to:
  /// **'이전에 낸 카드와 같은 무늬 또는 같은 숫자의 카드를 낼 수 있습니다.'**
  String get onecardGuidePlayText;

  /// No description provided for @onecardGuideAttack.
  ///
  /// In ko, this message translates to:
  /// **'공격 카드'**
  String get onecardGuideAttack;

  /// No description provided for @onecardGuideAttackText.
  ///
  /// In ko, this message translates to:
  /// **'• 2: +2장 공격\n• A: +3장 공격 (♠A는 +5장)\n• 조커: +5장(흑백) / +7장(컬러)'**
  String get onecardGuideAttackText;

  /// No description provided for @onecardGuideSpecial.
  ///
  /// In ko, this message translates to:
  /// **'특수 카드'**
  String get onecardGuideSpecial;

  /// No description provided for @onecardGuideSpecialText.
  ///
  /// In ko, this message translates to:
  /// **'• J: 다음 순서 건너뛰기\n• Q: 방향 반대\n• K: 2턴 건너뛰기\n• 7: 무늬 변경'**
  String get onecardGuideSpecialText;

  /// No description provided for @onecardGuideJokerDefense.
  ///
  /// In ko, this message translates to:
  /// **'조커 방어'**
  String get onecardGuideJokerDefense;

  /// No description provided for @onecardGuideJokerDefenseText.
  ///
  /// In ko, this message translates to:
  /// **'조커로 공격받으면 조커로만 방어할 수 있습니다.'**
  String get onecardGuideJokerDefenseText;

  /// No description provided for @onecardGuideOnecard.
  ///
  /// In ko, this message translates to:
  /// **'원카드!'**
  String get onecardGuideOnecard;

  /// No description provided for @onecardGuideOnecardText.
  ///
  /// In ko, this message translates to:
  /// **'손패가 1장 남으면 \"원카드!\" 버튼을 눌러야 합니다.\n누르지 않으면 패널티로 2장을 받습니다.'**
  String get onecardGuideOnecardText;

  /// No description provided for @onecardGuideBankrupt.
  ///
  /// In ko, this message translates to:
  /// **'파산'**
  String get onecardGuideBankrupt;

  /// No description provided for @onecardGuideBankruptText.
  ///
  /// In ko, this message translates to:
  /// **'손패가 20장 이상이 되면 파산! 가장 적은 카드를 가진 플레이어가 승리합니다.'**
  String get onecardGuideBankruptText;

  /// No description provided for @hulaGuideGoal.
  ///
  /// In ko, this message translates to:
  /// **'목표'**
  String get hulaGuideGoal;

  /// No description provided for @hulaGuideGoalText.
  ///
  /// In ko, this message translates to:
  /// **'손패의 카드를 모두 등록하거나 버려서 가장 먼저 없애는 것이 목표입니다.'**
  String get hulaGuideGoalText;

  /// No description provided for @hulaGuideHow.
  ///
  /// In ko, this message translates to:
  /// **'진행 방법'**
  String get hulaGuideHow;

  /// No description provided for @hulaGuideHowText.
  ///
  /// In ko, this message translates to:
  /// **'매 턴마다 덱 또는 버린 더미에서 카드 1장을 뽑고, 등록 또는 버리기를 합니다.'**
  String get hulaGuideHowText;

  /// No description provided for @hulaGuideMelds.
  ///
  /// In ko, this message translates to:
  /// **'멜드 종류'**
  String get hulaGuideMelds;

  /// No description provided for @hulaGuideMeldsText.
  ///
  /// In ko, this message translates to:
  /// **'• Run: 같은 무늬의 연속된 숫자 3장 이상 (예: ♠3-4-5)\n• Group: 같은 숫자 다른 무늬 3장 이상 (예: ♠7-♥7-♦7)'**
  String get hulaGuideMeldsText;

  /// No description provided for @hulaGuideSeven.
  ///
  /// In ko, this message translates to:
  /// **'7의 특수 규칙'**
  String get hulaGuideSeven;

  /// No description provided for @hulaGuideSevenText.
  ///
  /// In ko, this message translates to:
  /// **'7은 단독으로 등록할 수 있습니다.'**
  String get hulaGuideSevenText;

  /// No description provided for @hulaGuideThankYou.
  ///
  /// In ko, this message translates to:
  /// **'땡큐'**
  String get hulaGuideThankYou;

  /// No description provided for @hulaGuideThankYouText.
  ///
  /// In ko, this message translates to:
  /// **'버린 더미에서 7을 뽑으면 \"땡큐\"를 외치고 특별한 등록을 할 수 있습니다.'**
  String get hulaGuideThankYouText;

  /// No description provided for @hulaGuideStop.
  ///
  /// In ko, this message translates to:
  /// **'스톱'**
  String get hulaGuideStop;

  /// No description provided for @hulaGuideStopText.
  ///
  /// In ko, this message translates to:
  /// **'언제든 스톱을 외쳐 게임을 끝낼 수 있습니다.\n남은 카드 점수가 가장 적은 사람이 승리합니다.'**
  String get hulaGuideStopText;

  /// No description provided for @hulaGuideCardPoints.
  ///
  /// In ko, this message translates to:
  /// **'카드 점수'**
  String get hulaGuideCardPoints;

  /// No description provided for @hulaGuideCardPointsText.
  ///
  /// In ko, this message translates to:
  /// **'A=1점, 2~9=숫자점, J=10점, Q=11점, K=12점'**
  String get hulaGuideCardPointsText;

  /// No description provided for @hulaGuideScoring.
  ///
  /// In ko, this message translates to:
  /// **'점수 계산'**
  String get hulaGuideScoring;

  /// No description provided for @hulaGuideScoringText.
  ///
  /// In ko, this message translates to:
  /// **'• 승자: 다른 플레이어 손패와의 차이 합계를 획득\n• 패자: 승자와의 손패 차이만큼 감점\n• 훌라(등록 없이 승리): 점수 2배'**
  String get hulaGuideScoringText;

  /// No description provided for @hulaGuideStopPenalty.
  ///
  /// In ko, this message translates to:
  /// **'스톱 실패 페널티'**
  String get hulaGuideStopPenalty;

  /// No description provided for @hulaGuideStopPenaltyText.
  ///
  /// In ko, this message translates to:
  /// **'스톱을 외쳤지만 최저 점수가 아닌 경우:\n• 승자가 받을 점수 전부를 스톱한 사람이 부담\n• 다른 플레이어는 감점 없음'**
  String get hulaGuideStopPenaltyText;

  /// No description provided for @attackTotalCards.
  ///
  /// In ko, this message translates to:
  /// **'+{power}! (총 {total}장 공격)'**
  String attackTotalCards(int power, int total);

  /// No description provided for @skipNextTurnMessage.
  ///
  /// In ko, this message translates to:
  /// **'J! 다음 턴 건너뛰기'**
  String get skipNextTurnMessage;

  /// No description provided for @reverseDirectionMessage.
  ///
  /// In ko, this message translates to:
  /// **'Q! 방향 반대'**
  String get reverseDirectionMessage;

  /// No description provided for @skipTwoTurnsMessage.
  ///
  /// In ko, this message translates to:
  /// **'K! 2턴 건너뛰기'**
  String get skipTwoTurnsMessage;

  /// No description provided for @changeSuitMessage.
  ///
  /// In ko, this message translates to:
  /// **'7! 무늬 변경: {suit}'**
  String changeSuitMessage(String suit);

  /// No description provided for @playerPlayedCard.
  ///
  /// In ko, this message translates to:
  /// **'{name}이(가) 카드를 냈습니다'**
  String playerPlayedCard(String name);

  /// No description provided for @onecardWithPlayers.
  ///
  /// In ko, this message translates to:
  /// **'원카드 ({count}P)'**
  String onecardWithPlayers(int count);

  /// No description provided for @blackWhiteJoker.
  ///
  /// In ko, this message translates to:
  /// **'흑백 조커'**
  String get blackWhiteJoker;

  /// No description provided for @clockwiseDirection.
  ///
  /// In ko, this message translates to:
  /// **'시계'**
  String get clockwiseDirection;

  /// No description provided for @counterClockwiseDirection.
  ///
  /// In ko, this message translates to:
  /// **'반시계'**
  String get counterClockwiseDirection;

  /// No description provided for @aiTurnCountdown.
  ///
  /// In ko, this message translates to:
  /// **'{name} ({seconds})'**
  String aiTurnCountdown(String name, int seconds);

  /// No description provided for @aiTurn.
  ///
  /// In ko, this message translates to:
  /// **'{name} 차례'**
  String aiTurn(String name);

  /// No description provided for @cannotPlayThisCard.
  ///
  /// In ko, this message translates to:
  /// **'이 카드는 낼 수 없습니다'**
  String get cannotPlayThisCard;

  /// No description provided for @bankruptWithCards.
  ///
  /// In ko, this message translates to:
  /// **'파산! ({count}장 보유)'**
  String bankruptWithCards(int count);

  /// No description provided for @gameRulesTitle.
  ///
  /// In ko, this message translates to:
  /// **'게임 규칙'**
  String get gameRulesTitle;

  /// No description provided for @goalText.
  ///
  /// In ko, this message translates to:
  /// **'손에 든 카드를 가장 먼저 모두 내려놓는 사람이 승리합니다.\n마지막 카드를 내기 전 \"원카드\"를 외쳐야 합니다.'**
  String get goalText;

  /// No description provided for @howToPlayText.
  ///
  /// In ko, this message translates to:
  /// **'같은 무늬 또는 같은 숫자의 카드를 낼 수 있습니다.\n낼 수 있는 카드가 없으면 덱에서 카드를 뽑습니다.'**
  String get howToPlayText;

  /// No description provided for @defenseText.
  ///
  /// In ko, this message translates to:
  /// **'공격을 받으면 같은 공격 카드로 막을 수 있습니다.\n막으면 공격이 누적되어 다음 사람에게 넘어갑니다.'**
  String get defenseText;

  /// No description provided for @gameTips.
  ///
  /// In ko, this message translates to:
  /// **'게임 팁'**
  String get gameTips;

  /// No description provided for @drawCardMessage.
  ///
  /// In ko, this message translates to:
  /// **'카드를 뽑으세요'**
  String get drawCardMessage;

  /// No description provided for @discardOrMeldMessage.
  ///
  /// In ko, this message translates to:
  /// **'카드를 버리거나 등록하세요'**
  String get discardOrMeldMessage;

  /// No description provided for @noCardsMessage.
  ///
  /// In ko, this message translates to:
  /// **'카드가 없습니다'**
  String get noCardsMessage;

  /// No description provided for @thankYouSolo.
  ///
  /// In ko, this message translates to:
  /// **'땡큐! {suit}7 단독 등록'**
  String thankYouSolo(String suit);

  /// No description provided for @thankYouAddToMine.
  ///
  /// In ko, this message translates to:
  /// **'땡큐! {card} 내 멜드에 붙이기'**
  String thankYouAddToMine(String card);

  /// No description provided for @thankYouAddToAi.
  ///
  /// In ko, this message translates to:
  /// **'땡큐! {card} {aiName} 멜드에 붙이기'**
  String thankYouAddToAi(String card, String aiName);

  /// No description provided for @thankYouDesc.
  ///
  /// In ko, this message translates to:
  /// **'땡큐! {desc}'**
  String thankYouDesc(String desc);

  /// No description provided for @drawFirstMessage.
  ///
  /// In ko, this message translates to:
  /// **'먼저 카드를 뽑으세요'**
  String get drawFirstMessage;

  /// No description provided for @hulaWinBonus.
  ///
  /// In ko, this message translates to:
  /// **'훌라로 승리! (x2)'**
  String get hulaWinBonus;

  /// No description provided for @handColumn.
  ///
  /// In ko, this message translates to:
  /// **'손패'**
  String get handColumn;

  /// No description provided for @scoreColumn.
  ///
  /// In ko, this message translates to:
  /// **'점수'**
  String get scoreColumn;

  /// No description provided for @cumulativeColumn.
  ///
  /// In ko, this message translates to:
  /// **'누적'**
  String get cumulativeColumn;

  /// No description provided for @hulaWithPlayers.
  ///
  /// In ko, this message translates to:
  /// **'훌라 ({count}인)'**
  String hulaWithPlayers(int count);

  /// No description provided for @hintOnOff.
  ///
  /// In ko, this message translates to:
  /// **'힌트 {status}'**
  String hintOnOff(String status);

  /// No description provided for @emptyDiscardPile.
  ///
  /// In ko, this message translates to:
  /// **'버린 카드\n없음'**
  String get emptyDiscardPile;

  /// No description provided for @meldButton.
  ///
  /// In ko, this message translates to:
  /// **'등록'**
  String get meldButton;

  /// No description provided for @discardButton.
  ///
  /// In ko, this message translates to:
  /// **'버리기'**
  String get discardButton;

  /// No description provided for @stopButton.
  ///
  /// In ko, this message translates to:
  /// **'스톱'**
  String get stopButton;

  /// No description provided for @thankYouMeld.
  ///
  /// In ko, this message translates to:
  /// **'땡큐 멜드'**
  String get thankYouMeld;

  /// No description provided for @meldTypes.
  ///
  /// In ko, this message translates to:
  /// **'멜드 종류'**
  String get meldTypes;

  /// No description provided for @ok.
  ///
  /// In ko, this message translates to:
  /// **'확인'**
  String get ok;

  /// No description provided for @aiThankYouDraw.
  ///
  /// In ko, this message translates to:
  /// **'{aiName} 땡큐! {card}'**
  String aiThankYouDraw(String aiName, String card);

  /// No description provided for @aiDrawsCard.
  ///
  /// In ko, this message translates to:
  /// **'{aiName}이 카드를 뽑음'**
  String aiDrawsCard(String aiName);

  /// No description provided for @aiRegistersSeven.
  ///
  /// In ko, this message translates to:
  /// **'{aiName}: 7 {type} 등록'**
  String aiRegistersSeven(String aiName, String type);

  /// No description provided for @aiRegistersMeld.
  ///
  /// In ko, this message translates to:
  /// **'{aiName}: {meldType} 등록 {cards}'**
  String aiRegistersMeld(String aiName, String meldType, String cards);

  /// No description provided for @aiAttachesToMeld.
  ///
  /// In ko, this message translates to:
  /// **'{aiName}: {card} 멜드에 붙임'**
  String aiAttachesToMeld(String aiName, String card);

  /// No description provided for @aiAttachesToPlayerMeld.
  ///
  /// In ko, this message translates to:
  /// **'{aiName}: {card} 플레이어 멜드에 붙임'**
  String aiAttachesToPlayerMeld(String aiName, String card);

  /// No description provided for @aiAttachesToOtherAiMeld.
  ///
  /// In ko, this message translates to:
  /// **'{aiName}: {card} {targetAi} 멜드에 붙임'**
  String aiAttachesToOtherAiMeld(String aiName, String card, String targetAi);

  /// No description provided for @aiDiscards.
  ///
  /// In ko, this message translates to:
  /// **'{aiName}: {card} 버림'**
  String aiDiscards(String aiName, String card);

  /// No description provided for @group.
  ///
  /// In ko, this message translates to:
  /// **'그룹'**
  String get group;

  /// No description provided for @solo.
  ///
  /// In ko, this message translates to:
  /// **'단독'**
  String get solo;

  /// No description provided for @victory.
  ///
  /// In ko, this message translates to:
  /// **'승리!'**
  String get victory;

  /// No description provided for @defeat.
  ///
  /// In ko, this message translates to:
  /// **'패배'**
  String get defeat;

  /// No description provided for @drewCardWithCard.
  ///
  /// In ko, this message translates to:
  /// **'{card}을 뽑았습니다'**
  String drewCardWithCard(String card);

  /// No description provided for @playerDiscards.
  ///
  /// In ko, this message translates to:
  /// **'{card} 버림'**
  String playerDiscards(String card);

  /// No description provided for @inPossession.
  ///
  /// In ko, this message translates to:
  /// **'(보유중)'**
  String get inPossession;

  /// No description provided for @fourPlayerGame.
  ///
  /// In ko, this message translates to:
  /// **'4인 대전'**
  String get fourPlayerGame;

  /// No description provided for @meldCount.
  ///
  /// In ko, this message translates to:
  /// **'{count}개 멜드'**
  String meldCount(int count);

  /// No description provided for @cannotPlayFirstTrickDeclarerGiruda.
  ///
  /// In ko, this message translates to:
  /// **'첫 트릭에서 주공은 기루다로 선공할 수 없습니다'**
  String get cannotPlayFirstTrickDeclarerGiruda;

  /// No description provided for @cannotPlayFirstTrickJoker.
  ///
  /// In ko, this message translates to:
  /// **'첫 트릭에서는 조커를 낼 수 없습니다'**
  String get cannotPlayFirstTrickJoker;

  /// No description provided for @cannotPlayLastTrickJoker.
  ///
  /// In ko, this message translates to:
  /// **'마지막 트릭에서는 조커를 낼 수 없습니다'**
  String get cannotPlayLastTrickJoker;

  /// No description provided for @cannotPlayLastTrickJokerHasLeadSuit.
  ///
  /// In ko, this message translates to:
  /// **'선공 무늬가 있으면 조커를 낼 수 없습니다'**
  String get cannotPlayLastTrickJokerHasLeadSuit;

  /// No description provided for @mustPlayJokerCall.
  ///
  /// In ko, this message translates to:
  /// **'조커 콜! 조커를 내야 합니다'**
  String get mustPlayJokerCall;

  /// No description provided for @mustFollowSuit.
  ///
  /// In ko, this message translates to:
  /// **'{suit} 무늬를 내야 합니다'**
  String mustFollowSuit(String suit);

  /// No description provided for @fullDeclarationWarning.
  ///
  /// In ko, this message translates to:
  /// **'풀 선언 시 공약이 20으로 올라갑니다'**
  String get fullDeclarationWarning;

  /// No description provided for @watchAiGame.
  ///
  /// In ko, this message translates to:
  /// **'마이티 배우기'**
  String get watchAiGame;

  /// No description provided for @demoMode.
  ///
  /// In ko, this message translates to:
  /// **'데모 모드'**
  String get demoMode;

  /// No description provided for @stopDemo.
  ///
  /// In ko, this message translates to:
  /// **'관전 종료'**
  String get stopDemo;

  /// No description provided for @pauseDemo.
  ///
  /// In ko, this message translates to:
  /// **'일시정지'**
  String get pauseDemo;

  /// No description provided for @resumeDemo.
  ///
  /// In ko, this message translates to:
  /// **'재개'**
  String get resumeDemo;

  /// No description provided for @nextGameAuto.
  ///
  /// In ko, this message translates to:
  /// **'다음 게임'**
  String get nextGameAuto;

  /// No description provided for @bidExplanation.
  ///
  /// In ko, this message translates to:
  /// **'{name}: 최적 기루다 {suit}, 예상 강도 {strength}'**
  String bidExplanation(String name, String suit, int strength);

  /// No description provided for @bidExplanationBid.
  ///
  /// In ko, this message translates to:
  /// **'{name}: {suit} {tricks} 배팅 (강도 {strength})'**
  String bidExplanationBid(String name, String suit, int tricks, int strength);

  /// No description provided for @passReasonNoSuit.
  ///
  /// In ko, this message translates to:
  /// **'기루다 후보 없음 (4장 이상 무늬 없음)'**
  String get passReasonNoSuit;

  /// No description provided for @passReasonNoHighCard.
  ///
  /// In ko, this message translates to:
  /// **'기루다 A/K 없음'**
  String get passReasonNoHighCard;

  /// No description provided for @passReasonWeakHand.
  ///
  /// In ko, this message translates to:
  /// **'핸드 강도 부족 (강도 {strength}, 필요 {needed})'**
  String passReasonWeakHand(int strength, int needed);

  /// No description provided for @passReasonPowerWeak.
  ///
  /// In ko, this message translates to:
  /// **'파워 카드 부족 (마이티/조커/에이스 5개 미만)'**
  String get passReasonPowerWeak;

  /// No description provided for @passReasonLowPoints.
  ///
  /// In ko, this message translates to:
  /// **'적정 {optimal}점 < 최소 13점'**
  String passReasonLowPoints(int optimal);

  /// No description provided for @passReasonOutbid.
  ///
  /// In ko, this message translates to:
  /// **'적정 {optimal}점 < 필요 {needed}점'**
  String passReasonOutbid(int optimal, int needed);

  /// No description provided for @estimatedRange.
  ///
  /// In ko, this message translates to:
  /// **'예상 {min}~{max}점'**
  String estimatedRange(int min, int max);

  /// No description provided for @optimalScore.
  ///
  /// In ko, this message translates to:
  /// **'적정 {optimal}점'**
  String optimalScore(int optimal);

  /// No description provided for @friendExpected.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 예상'**
  String get friendExpected;

  /// No description provided for @friendCardMighty.
  ///
  /// In ko, this message translates to:
  /// **'마이티'**
  String get friendCardMighty;

  /// No description provided for @friendCardJoker.
  ///
  /// In ko, this message translates to:
  /// **'조커'**
  String get friendCardJoker;

  /// No description provided for @friendHeldBy.
  ///
  /// In ko, this message translates to:
  /// **'{name} 보유'**
  String friendHeldBy(String name);

  /// No description provided for @friendInKitty.
  ///
  /// In ko, this message translates to:
  /// **'키티에 있을 수 있음'**
  String get friendInKitty;

  /// No description provided for @friendJokerNote.
  ///
  /// In ko, this message translates to:
  /// **'초구 사용 불가'**
  String get friendJokerNote;

  /// No description provided for @kittySummaryTitle.
  ///
  /// In ko, this message translates to:
  /// **'키티 선택 결과'**
  String get kittySummaryTitle;

  /// No description provided for @kittyReceivedCards.
  ///
  /// In ko, this message translates to:
  /// **'바닥에서 받은 카드'**
  String get kittyReceivedCards;

  /// No description provided for @kittyDiscardCards.
  ///
  /// In ko, this message translates to:
  /// **'버릴 카드'**
  String get kittyDiscardCards;

  /// No description provided for @kittyFinalHand.
  ///
  /// In ko, this message translates to:
  /// **'최종 보유 카드 (10장)'**
  String get kittyFinalHand;

  /// No description provided for @girudaComparisonTitle.
  ///
  /// In ko, this message translates to:
  /// **'기루다 비교 (13장)'**
  String get girudaComparisonTitle;

  /// No description provided for @discardReasonCutSuit.
  ///
  /// In ko, this message translates to:
  /// **'적은 무늬 정리 → 컷 가능'**
  String get discardReasonCutSuit;

  /// No description provided for @discardReasonNonGirudaLow.
  ///
  /// In ko, this message translates to:
  /// **'비기루다 낮은 카드'**
  String get discardReasonNonGirudaLow;

  /// No description provided for @discardReasonLowValue.
  ///
  /// In ko, this message translates to:
  /// **'낮은 가치 카드'**
  String get discardReasonLowValue;

  /// No description provided for @discardReasonLeastUseful.
  ///
  /// In ko, this message translates to:
  /// **'가장 불필요한 카드'**
  String get discardReasonLeastUseful;

  /// No description provided for @friendSummaryTitle.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 선언 결과'**
  String get friendSummaryTitle;

  /// No description provided for @friendReasonNoFriendStrong.
  ///
  /// In ko, this message translates to:
  /// **'강한 핸드로 혼자서 충분히 이길 수 있음'**
  String get friendReasonNoFriendStrong;

  /// No description provided for @friendReasonFirstTrick.
  ///
  /// In ko, this message translates to:
  /// **'첫 트릭 승자를 프렌드로 지정'**
  String get friendReasonFirstTrick;

  /// No description provided for @friendReasonNthTrick.
  ///
  /// In ko, this message translates to:
  /// **'특정 트릭 승자를 프렌드로 지정'**
  String get friendReasonNthTrick;

  /// No description provided for @friendReasonNeedMighty.
  ///
  /// In ko, this message translates to:
  /// **'마이티가 없어서 마이티 소유자가 필요'**
  String get friendReasonNeedMighty;

  /// No description provided for @friendReasonNeedJoker.
  ///
  /// In ko, this message translates to:
  /// **'조커가 없어서 조커 소유자가 필요'**
  String get friendReasonNeedJoker;

  /// No description provided for @friendReasonNeedGirudaAce.
  ///
  /// In ko, this message translates to:
  /// **'기루다 A가 없어서 보유자가 필요'**
  String get friendReasonNeedGirudaAce;

  /// No description provided for @friendReasonNeedGirudaKing.
  ///
  /// In ko, this message translates to:
  /// **'기루다 K가 없어서 보유자가 필요'**
  String get friendReasonNeedGirudaKing;

  /// No description provided for @friendReasonNeedGirudaMid.
  ///
  /// In ko, this message translates to:
  /// **'기루다 중간 카드 보유자가 필요'**
  String get friendReasonNeedGirudaMid;

  /// No description provided for @friendReasonNeedAce.
  ///
  /// In ko, this message translates to:
  /// **'에이스 보유자를 프렌드로 지정'**
  String get friendReasonNeedAce;

  /// No description provided for @friendReasonNeedStrongCard.
  ///
  /// In ko, this message translates to:
  /// **'강한 카드 보유자를 프렌드로 지정'**
  String get friendReasonNeedStrongCard;

  /// No description provided for @friendReasonNoFriendAll.
  ///
  /// In ko, this message translates to:
  /// **'모든 핵심 카드를 보유하여 노프렌드 선언'**
  String get friendReasonNoFriendAll;

  /// No description provided for @bidSummaryTitle.
  ///
  /// In ko, this message translates to:
  /// **'배팅 결과'**
  String get bidSummaryTitle;

  /// No description provided for @bidSummaryEstimatedRange.
  ///
  /// In ko, this message translates to:
  /// **'예상 득점 범위 (주공 기준)'**
  String get bidSummaryEstimatedRange;

  /// No description provided for @bidSummaryEstMax.
  ///
  /// In ko, this message translates to:
  /// **'최대 ({points}점)'**
  String bidSummaryEstMax(int points);

  /// No description provided for @bidSummaryEstMaxDesc.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 포함, 선 유지 시'**
  String get bidSummaryEstMaxDesc;

  /// No description provided for @bidSummaryEstMin.
  ///
  /// In ko, this message translates to:
  /// **'최소 ({points}점)'**
  String bidSummaryEstMin(int points);

  /// No description provided for @bidSummaryEstMinDesc.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 도움 없이 (조커콜 등)'**
  String get bidSummaryEstMinDesc;

  /// No description provided for @bidSummaryEstMinDescDynamic.
  ///
  /// In ko, this message translates to:
  /// **'프렌드({friend}) 기본 기여만, 바닥패 가능'**
  String bidSummaryEstMinDescDynamic(String friend);

  /// No description provided for @bidSummaryMultipliers.
  ///
  /// In ko, this message translates to:
  /// **'주공 ×2, 프렌드 ×1, 야당 ×(-1)'**
  String get bidSummaryMultipliers;

  /// No description provided for @firstTrickStrategy.
  ///
  /// In ko, this message translates to:
  /// **'초구 전략'**
  String get firstTrickStrategy;

  /// No description provided for @scoreStrategy.
  ///
  /// In ko, this message translates to:
  /// **'점수 획득 전략'**
  String get scoreStrategy;

  /// No description provided for @firstTrickAce.
  ///
  /// In ko, this message translates to:
  /// **'비기루다 A로 선공하여 확실한 트릭 획득'**
  String get firstTrickAce;

  /// No description provided for @firstTrickKing.
  ///
  /// In ko, this message translates to:
  /// **'비기루다 K로 선공하여 트릭 획득 시도'**
  String get firstTrickKing;

  /// No description provided for @firstTrickGiveUp.
  ///
  /// In ko, this message translates to:
  /// **'강한 선공 카드 없음, 낮은 카드로 정보 수집'**
  String get firstTrickGiveUp;

  /// No description provided for @strategyMighty.
  ///
  /// In ko, this message translates to:
  /// **'마이티로 확실한 트릭 1개 보장'**
  String get strategyMighty;

  /// No description provided for @strategyJoker.
  ///
  /// In ko, this message translates to:
  /// **'조커로 원하는 타이밍에 트릭 획득 가능'**
  String get strategyJoker;

  /// No description provided for @strategyGirudaDominant.
  ///
  /// In ko, this message translates to:
  /// **'기루다 5장 이상으로 기루다 지배력 확보'**
  String get strategyGirudaDominant;

  /// No description provided for @strategyGirudaSupport.
  ///
  /// In ko, this message translates to:
  /// **'기루다 3장 이상으로 기루다 지원 가능'**
  String get strategyGirudaSupport;

  /// No description provided for @strategyMultiAce.
  ///
  /// In ko, this message translates to:
  /// **'여러 에이스 보유로 다수 트릭 획득 가능'**
  String get strategyMultiAce;

  /// No description provided for @strategySingleAce.
  ///
  /// In ko, this message translates to:
  /// **'에이스 1장으로 추가 트릭 기회'**
  String get strategySingleAce;

  /// No description provided for @strategyCut.
  ///
  /// In ko, this message translates to:
  /// **'짧은 무늬로 기루다 컷 가능'**
  String get strategyCut;

  /// No description provided for @bidInfoGirudaKeys.
  ///
  /// In ko, this message translates to:
  /// **'기루다 {keys}'**
  String bidInfoGirudaKeys(String keys);

  /// No description provided for @bidInfoFriend.
  ///
  /// In ko, this message translates to:
  /// **'프렌드: {card}'**
  String bidInfoFriend(String card);

  /// No description provided for @bidInfoHasBoth.
  ///
  /// In ko, this message translates to:
  /// **'{card1}·{card2} 보유'**
  String bidInfoHasBoth(String card1, String card2);

  /// No description provided for @bidInfoHasCard.
  ///
  /// In ko, this message translates to:
  /// **'{card} 보유'**
  String bidInfoHasCard(String card);

  /// No description provided for @bidInfoFirstTrickAces.
  ///
  /// In ko, this message translates to:
  /// **'초구 {aces}'**
  String bidInfoFirstTrickAces(String aces);

  /// No description provided for @jokerOwner.
  ///
  /// In ko, this message translates to:
  /// **'조커 소유자'**
  String get jokerOwner;

  /// No description provided for @friendBadge.
  ///
  /// In ko, this message translates to:
  /// **'프렌드'**
  String get friendBadge;

  /// No description provided for @kittyLabel.
  ///
  /// In ko, this message translates to:
  /// **'바닥패 '**
  String get kittyLabel;

  /// No description provided for @kittyPointsWithFriend.
  ///
  /// In ko, this message translates to:
  /// **' {points}점 (프렌드 바닥패)'**
  String kittyPointsWithFriend(int points);

  /// No description provided for @kittyPoints.
  ///
  /// In ko, this message translates to:
  /// **' {points}점'**
  String kittyPoints(int points);

  /// No description provided for @friendWithName.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 {name} '**
  String friendWithName(String name);

  /// No description provided for @adjustedPointsRange.
  ///
  /// In ko, this message translates to:
  /// **'→ 조정 {min}~{max}점'**
  String adjustedPointsRange(int min, int max);

  /// No description provided for @hasAceNote.
  ///
  /// In ko, this message translates to:
  /// **' (A 보유)'**
  String get hasAceNote;

  /// No description provided for @strategyFirstTrickAceLead.
  ///
  /// In ko, this message translates to:
  /// **'초구: {card} 선공으로 확실한 트릭 획득'**
  String strategyFirstTrickAceLead(String card);

  /// No description provided for @strategyFirstTrickPassFriendWin.
  ///
  /// In ko, this message translates to:
  /// **'초구: 짧은 무늬 낮은 카드로 선 넘기기 (프렌드가 트릭 획득)'**
  String get strategyFirstTrickPassFriendWin;

  /// No description provided for @strategyFirstTrickKingLead.
  ///
  /// In ko, this message translates to:
  /// **'초구: {card} 선공으로 트릭 획득 시도'**
  String strategyFirstTrickKingLead(String card);

  /// No description provided for @strategyFirstTrickPassFriend.
  ///
  /// In ko, this message translates to:
  /// **'초구: 짧은 무늬 낮은 카드로 프렌드에게 선 넘기기'**
  String get strategyFirstTrickPassFriend;

  /// No description provided for @strategyPassToMightyFriend.
  ///
  /// In ko, this message translates to:
  /// **'짧은 무늬 낮은 카드로 프렌드에게 선 넘기기 (마이티)'**
  String get strategyPassToMightyFriend;

  /// No description provided for @strategyPassToJokerFriend.
  ///
  /// In ko, this message translates to:
  /// **'짧은 무늬 낮은 카드로 프렌드에게 선 넘기기 (조커)'**
  String get strategyPassToJokerFriend;

  /// No description provided for @strategyPassTrumpToFriend.
  ///
  /// In ko, this message translates to:
  /// **'{passCard} 선공으로 프렌드({friendCard})에게 선 넘기기 → {rank} 단독 방지'**
  String strategyPassTrumpToFriend(
    String passCard,
    String friendCard,
    String rank,
  );

  /// No description provided for @strategyPassSuitToFriend.
  ///
  /// In ko, this message translates to:
  /// **'{card} 선공으로 프렌드({friendCard})에게 선 넘기기'**
  String strategyPassSuitToFriend(String card, String friendCard);

  /// No description provided for @strategySourceFriend.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 트릭 후,'**
  String get strategySourceFriend;

  /// No description provided for @strategySourceReclaim.
  ///
  /// In ko, this message translates to:
  /// **'선 회수 후,'**
  String get strategySourceReclaim;

  /// No description provided for @strategyTrumpDominate.
  ///
  /// In ko, this message translates to:
  /// **'{source} {cards}로 지배 → 수비 기루다 소진'**
  String strategyTrumpDominate(String source, String cards);

  /// No description provided for @strategyTrumpExhaust.
  ///
  /// In ko, this message translates to:
  /// **'{source} {cards}로 수비 기루다 소진'**
  String strategyTrumpExhaust(String source, String cards);

  /// No description provided for @strategyTrumpMidDraw.
  ///
  /// In ko, this message translates to:
  /// **'{suit} 중간 기루다로 수비측 높은 기루다 유도'**
  String strategyTrumpMidDraw(String suit);

  /// No description provided for @strategyJokerCallSuits.
  ///
  /// In ko, this message translates to:
  /// **'수비 기루다 소진 후, 약한 무늬({suits})에 조커 콜'**
  String strategyJokerCallSuits(String suits);

  /// No description provided for @strategyJokerCallWeak.
  ///
  /// In ko, this message translates to:
  /// **'수비 기루다 소진 후, 약한 무늬에 조커 콜'**
  String get strategyJokerCallWeak;

  /// No description provided for @strategyJokerOptimal.
  ///
  /// In ko, this message translates to:
  /// **'최적 타이밍에 조커로 트릭 획득'**
  String get strategyJokerOptimal;

  /// No description provided for @strategyMightyTiming.
  ///
  /// In ko, this message translates to:
  /// **'9번째 트릭에 마이티 사용 → 10번째 트릭 선 확보'**
  String get strategyMightyTiming;

  /// No description provided for @strategyVoidTrumpCut.
  ///
  /// In ko, this message translates to:
  /// **'{suits} 보이드 → 상대 선공 시 기루다 컷으로 트릭 회수'**
  String strategyVoidTrumpCut(String suits);

  /// No description provided for @strategyTrumpExhaustCheckK.
  ///
  /// In ko, this message translates to:
  /// **'{cards} 선출 → 기루다 최상위 공격, K 소진 확인'**
  String strategyTrumpExhaustCheckK(String cards);

  /// No description provided for @strategyJokerAfterFriend.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 합류 후 조커 선출 → 점수 획득'**
  String get strategyJokerAfterFriend;

  /// No description provided for @strategyJokerCallGiruda.
  ///
  /// In ko, this message translates to:
  /// **'K 미소진 시 조커: {suit} 호출 → K 유도'**
  String strategyJokerCallGiruda(String suit);

  /// No description provided for @strategyLowGirudaFriendLure.
  ///
  /// In ko, this message translates to:
  /// **'{card} 선출 → 프렌드에게 선 양보하여 유도'**
  String strategyLowGirudaFriendLure(String card);

  /// No description provided for @strategyGirudaQReclaim.
  ///
  /// In ko, this message translates to:
  /// **'{card} 선출 → 선 탈환'**
  String strategyGirudaQReclaim(String card);

  /// No description provided for @strategyHighCardAttack.
  ///
  /// In ko, this message translates to:
  /// **'{cards} 선출 → 추가 점수 공격'**
  String strategyHighCardAttack(String cards);

  /// No description provided for @trickDetails.
  ///
  /// In ko, this message translates to:
  /// **'트릭 상세'**
  String get trickDetails;

  /// No description provided for @trickColumnGainLoss.
  ///
  /// In ko, this message translates to:
  /// **'득실'**
  String get trickColumnGainLoss;

  /// No description provided for @trickColumnGiruda.
  ///
  /// In ko, this message translates to:
  /// **'기루다'**
  String get trickColumnGiruda;

  /// No description provided for @trickColumnEvent.
  ///
  /// In ko, this message translates to:
  /// **'이벤트'**
  String get trickColumnEvent;

  /// No description provided for @trickLegendLead.
  ///
  /// In ko, this message translates to:
  /// **'선공'**
  String get trickLegendLead;

  /// No description provided for @trickLegendWinner.
  ///
  /// In ko, this message translates to:
  /// **'승자'**
  String get trickLegendWinner;

  /// No description provided for @trickEventLastCard.
  ///
  /// In ko, this message translates to:
  /// **'마지막 카드'**
  String get trickEventLastCard;

  /// No description provided for @trickEventLastCardDefenseWin.
  ///
  /// In ko, this message translates to:
  /// **'수비 상위 카드 {count}점 방어'**
  String trickEventLastCardDefenseWin(int count);

  /// No description provided for @trickEventLastCardAttackWin.
  ///
  /// In ko, this message translates to:
  /// **'공격 {count}점 획득'**
  String trickEventLastCardAttackWin(int count);

  /// No description provided for @trickEventLastCardLeadFailed.
  ///
  /// In ko, this message translates to:
  /// **'{name} 선공 실패, {count}점 놓침'**
  String trickEventLastCardLeadFailed(String name, int count);

  /// No description provided for @trickEventJokerLead.
  ///
  /// In ko, this message translates to:
  /// **'조커 선공'**
  String get trickEventJokerLead;

  /// No description provided for @trickEventJokerLeadSuit.
  ///
  /// In ko, this message translates to:
  /// **'조커 선공 ({suit})'**
  String trickEventJokerLeadSuit(String suit);

  /// No description provided for @trickEventJokerGirudaExhaust.
  ///
  /// In ko, this message translates to:
  /// **'수비팀 기루다 소진 유도'**
  String get trickEventJokerGirudaExhaust;

  /// No description provided for @trickEventMightyLead.
  ///
  /// In ko, this message translates to:
  /// **'마이티 선공'**
  String get trickEventMightyLead;

  /// No description provided for @trickEventTopGirudaLead.
  ///
  /// In ko, this message translates to:
  /// **'기루다 최상위 선공'**
  String get trickEventTopGirudaLead;

  /// No description provided for @trickEventMidGirudaMightyBait.
  ///
  /// In ko, this message translates to:
  /// **'기루다 중간으로 마이티 유도'**
  String get trickEventMidGirudaMightyBait;

  /// No description provided for @trickEventMidGirudaMightyBaitForA.
  ///
  /// In ko, this message translates to:
  /// **'A 최상위 확보 위해 저액 기루다로 마이티 유도'**
  String get trickEventMidGirudaMightyBaitForA;

  /// No description provided for @trickEventMidGirudaMightyBaitForQ.
  ///
  /// In ko, this message translates to:
  /// **'Q 공격 위해 저액 기루다로 마이티 유도'**
  String get trickEventMidGirudaMightyBaitForQ;

  /// No description provided for @trickEventMidGirudaPassLead.
  ///
  /// In ko, this message translates to:
  /// **'기루다 중간으로 선 넘김'**
  String get trickEventMidGirudaPassLead;

  /// No description provided for @trickEventDefenderGirudaWin.
  ///
  /// In ko, this message translates to:
  /// **'수비팀 기루다 승리'**
  String get trickEventDefenderGirudaWin;

  /// No description provided for @trickEventMidGirudaLead.
  ///
  /// In ko, this message translates to:
  /// **'기루다 중간 선공'**
  String get trickEventMidGirudaLead;

  /// No description provided for @trickEventTopNonGirudaLead.
  ///
  /// In ko, this message translates to:
  /// **'비기루다 최상위 선공'**
  String get trickEventTopNonGirudaLead;

  /// No description provided for @trickEventDefenseTopCardDefend.
  ///
  /// In ko, this message translates to:
  /// **'수비 최상위 카드 점수 방어'**
  String get trickEventDefenseTopCardDefend;

  /// No description provided for @trickEventDefenseLeadAttackCut.
  ///
  /// In ko, this message translates to:
  /// **'수비 비기루다 공격 → 기루다 컷 선 탈환'**
  String get trickEventDefenseLeadAttackCut;

  /// No description provided for @trickEventFirstTrickFriendBait.
  ///
  /// In ko, this message translates to:
  /// **'초구 부재 / 물패로 프렌드 유도'**
  String get trickEventFirstTrickFriendBait;

  /// No description provided for @trickEventFirstTrickWaste.
  ///
  /// In ko, this message translates to:
  /// **'초구 부재 / 물패 처리'**
  String get trickEventFirstTrickWaste;

  /// No description provided for @trickEventAttackFailed.
  ///
  /// In ko, this message translates to:
  /// **'공격 실패 → 수비 상위 카드에 패배'**
  String get trickEventAttackFailed;

  /// No description provided for @trickEventAttackFailedWithTop.
  ///
  /// In ko, this message translates to:
  /// **'공격 ({topCard} 최상위) 실패 → 수비에 패배'**
  String trickEventAttackFailedWithTop(String topCard);

  /// No description provided for @trickEventWaste.
  ///
  /// In ko, this message translates to:
  /// **'물패 처리'**
  String get trickEventWaste;

  /// No description provided for @trickEventWasteWithTop.
  ///
  /// In ko, this message translates to:
  /// **'물패 ({topCard} 최상위)'**
  String trickEventWasteWithTop(String topCard);

  /// No description provided for @trickEventWasteDeclarerReclaim.
  ///
  /// In ko, this message translates to:
  /// **'물패 → 주공 선 탈환'**
  String get trickEventWasteDeclarerReclaim;

  /// No description provided for @trickEventWasteDeclarerReclaimWithTop.
  ///
  /// In ko, this message translates to:
  /// **'물패 ({topCard} 최상위) → 주공 선 탈환'**
  String trickEventWasteDeclarerReclaimWithTop(String topCard);

  /// No description provided for @trickEventWasteFriendRescue.
  ///
  /// In ko, this message translates to:
  /// **'물패 → 프렌드 기사회생!'**
  String get trickEventWasteFriendRescue;

  /// No description provided for @trickEventWasteFriendRescueWithTop.
  ///
  /// In ko, this message translates to:
  /// **'물패 ({topCard} 최상위) → 프렌드 기사회생!'**
  String trickEventWasteFriendRescueWithTop(String topCard);

  /// No description provided for @trickEventAttackGirudaCut.
  ///
  /// In ko, this message translates to:
  /// **'공격 기루다 컷'**
  String get trickEventAttackGirudaCut;

  /// No description provided for @trickEventDefenseGirudaCut.
  ///
  /// In ko, this message translates to:
  /// **'수비 기루다 컷'**
  String get trickEventDefenseGirudaCut;

  /// No description provided for @trickEventNonGirudaExhaust.
  ///
  /// In ko, this message translates to:
  /// **'비기루다 소진'**
  String get trickEventNonGirudaExhaust;

  /// No description provided for @trickEventGirudaKExhaustSuccess.
  ///
  /// In ko, this message translates to:
  /// **'K 소진 성공'**
  String get trickEventGirudaKExhaustSuccess;

  /// No description provided for @trickEventDefenseJokerCounterattack.
  ///
  /// In ko, this message translates to:
  /// **'마이티 소멸 → 수비 조커 반격'**
  String get trickEventDefenseJokerCounterattack;

  /// No description provided for @trickEventDefenseMightyExhaust.
  ///
  /// In ko, this message translates to:
  /// **'수비 마이티 소진 유도 성공'**
  String get trickEventDefenseMightyExhaust;

  /// No description provided for @trickEventDefenseMightyExhaustPoints.
  ///
  /// In ko, this message translates to:
  /// **'수비 마이티 유도, {count}점 유출'**
  String trickEventDefenseMightyExhaustPoints(int count);

  /// No description provided for @trickEventJokerAfterFriend.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 합류 후 조커 ({suit}) → 점수 획득'**
  String trickEventJokerAfterFriend(String suit);

  /// No description provided for @trickEventJokerAfterFriendGeneral.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 합류 후 조커 → 점수 획득'**
  String get trickEventJokerAfterFriendGeneral;

  /// No description provided for @trickEventGirudaQReclaimSuccess.
  ///
  /// In ko, this message translates to:
  /// **'기루다 Q → 선 탈환 성공'**
  String get trickEventGirudaQReclaimSuccess;

  /// No description provided for @trickEventGirudaQReclaimFail.
  ///
  /// In ko, this message translates to:
  /// **'기루다 Q 선 탈환 실패, 수비 승리'**
  String get trickEventGirudaQReclaimFail;

  /// No description provided for @trickEventHighCardAttack.
  ///
  /// In ko, this message translates to:
  /// **'추가 점수 공격'**
  String get trickEventHighCardAttack;

  /// No description provided for @trickResultAttack.
  ///
  /// In ko, this message translates to:
  /// **'→ 공격 +{count}'**
  String trickResultAttack(int count);

  /// No description provided for @trickResultDefense.
  ///
  /// In ko, this message translates to:
  /// **'→ 수비 +{count}'**
  String trickResultDefense(int count);

  /// No description provided for @trickResultNoScore.
  ///
  /// In ko, this message translates to:
  /// **'→ 무득점'**
  String get trickResultNoScore;

  /// No description provided for @trickMightyAppeared.
  ///
  /// In ko, this message translates to:
  /// **'마이티 출현'**
  String get trickMightyAppeared;

  /// No description provided for @trickFriendJoined.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 합류'**
  String get trickFriendJoined;

  /// No description provided for @trickEventFriendTopCardWin.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 최상위 카드 승리'**
  String get trickEventFriendTopCardWin;

  /// No description provided for @trickEventFriendGirudaKDeclarerA.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 기루다 K 승리, 주공 A 보유 공격팀 기루다 장악'**
  String get trickEventFriendGirudaKDeclarerA;

  /// No description provided for @trickEventFriendTrickContribution.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 도움 {count}트릭 공격 성공'**
  String trickEventFriendTrickContribution(int count);

  /// No description provided for @trickEventJokerSkipNoPoints.
  ///
  /// In ko, this message translates to:
  /// **'{name}: 조커 보유, 무득점 트릭 스킵'**
  String trickEventJokerSkipNoPoints(String name);

  /// No description provided for @trickEventGirudaAceHeldMightyGuard.
  ///
  /// In ko, this message translates to:
  /// **'{name}: 기루다 A 보유, 마이티 경계로 미사용'**
  String trickEventGirudaAceHeldMightyGuard(String name);

  /// No description provided for @trickEventGirudaAceHeld.
  ///
  /// In ko, this message translates to:
  /// **'{name}: 기루다 A 보유, 미사용'**
  String trickEventGirudaAceHeld(String name);

  /// No description provided for @estimatedMinWins.
  ///
  /// In ko, this message translates to:
  /// **'→ {count}승 이상 예상'**
  String estimatedMinWins(int count);

  /// No description provided for @stepFirstAce.
  ///
  /// In ko, this message translates to:
  /// **'{card}로 초구 선 유지'**
  String stepFirstAce(String card);

  /// No description provided for @stepFirstKing.
  ///
  /// In ko, this message translates to:
  /// **'{card}로 초구 선 유지 (마이티 무늬 최상위)'**
  String stepFirstKing(String card);

  /// No description provided for @stepFirstMighty.
  ///
  /// In ko, this message translates to:
  /// **'마이티로 초구 선 확보'**
  String get stepFirstMighty;

  /// No description provided for @stepFirstJoker.
  ///
  /// In ko, this message translates to:
  /// **'조커로 초구 선 확보'**
  String get stepFirstJoker;

  /// No description provided for @stepGirudaAce.
  ///
  /// In ko, this message translates to:
  /// **'{card}로 기루다 공격'**
  String stepGirudaAce(String card);

  /// No description provided for @stepGirudaAceCheckK.
  ///
  /// In ko, this message translates to:
  /// **'{card}로 기루다 공격 (K 소진 확인)'**
  String stepGirudaAceCheckK(String card);

  /// No description provided for @stepGirudaKing.
  ///
  /// In ko, this message translates to:
  /// **'{card}로 기루다 추가 공격'**
  String stepGirudaKing(String card);

  /// No description provided for @stepJokerCallGiruda.
  ///
  /// In ko, this message translates to:
  /// **'K 미소진 시 조커로 {suit} 호출하여 K 유도'**
  String stepJokerCallGiruda(String suit);

  /// No description provided for @stepJokerAfterFriend.
  ///
  /// In ko, this message translates to:
  /// **'프렌드 합류 후 조커로 점수 획득'**
  String get stepJokerAfterFriend;

  /// No description provided for @stepFriendMightyJoin.
  ///
  /// In ko, this message translates to:
  /// **'마이티 프렌드 → 초구에서 합류'**
  String get stepFriendMightyJoin;

  /// No description provided for @stepFriendJokerJoin.
  ///
  /// In ko, this message translates to:
  /// **'조커 프렌드 → 기루다 리드 시 자연 합류'**
  String get stepFriendJokerJoin;

  /// No description provided for @stepLowGirudaFriendLure.
  ///
  /// In ko, this message translates to:
  /// **'{highCards} 미출현 시 {card}로 마이티({mightyCard}) 유도하면서 기루다 공격'**
  String stepLowGirudaFriendLure(
    String highCards,
    String card,
    String mightyCard,
  );

  /// No description provided for @stepGirudaQReclaim.
  ///
  /// In ko, this message translates to:
  /// **'{card}로 선 탈환'**
  String stepGirudaQReclaim(String card);

  /// No description provided for @stepGirudaLeadFriend.
  ///
  /// In ko, this message translates to:
  /// **'기루다 리드로 {friendCard} 유도'**
  String stepGirudaLeadFriend(String friendCard);

  /// No description provided for @stepJokerCallFriend.
  ///
  /// In ko, this message translates to:
  /// **'{friendCard} 미출현 시 조커로 기루다 호출하여 프렌드 유도'**
  String stepJokerCallFriend(String friendCard);

  /// No description provided for @stepLureWithGiruda.
  ///
  /// In ko, this message translates to:
  /// **'그래도 미출현 시 {card}로 프렌드({friendCard}) 유도'**
  String stepLureWithGiruda(String card, String friendCard);

  /// No description provided for @stepSuitLeadFriend.
  ///
  /// In ko, this message translates to:
  /// **'{card}로 리드하여 프렌드({friendCard}) 유도'**
  String stepSuitLeadFriend(String card, String friendCard);

  /// No description provided for @stepJokerCall.
  ///
  /// In ko, this message translates to:
  /// **'조커로 {suits} 호출하여 점수 카드 확보'**
  String stepJokerCall(String suits);

  /// No description provided for @stepJokerOptimal.
  ///
  /// In ko, this message translates to:
  /// **'조커를 최적 타이밍에 사용하여 점수 획득'**
  String get stepJokerOptimal;

  /// No description provided for @stepHighCardAttack.
  ///
  /// In ko, this message translates to:
  /// **'{cards}로 추가 점수 획득'**
  String stepHighCardAttack(String cards);

  /// No description provided for @stepMightyTiming.
  ///
  /// In ko, this message translates to:
  /// **'마이티를 기루다 소진 후 사용하여 확실한 트릭 확보'**
  String get stepMightyTiming;

  /// No description provided for @stepVoidCut.
  ///
  /// In ko, this message translates to:
  /// **'{suits} 보이드를 활용하여 기루다 컷으로 점수 획득'**
  String stepVoidCut(String suits);

  /// No description provided for @stepEndgameScoring.
  ///
  /// In ko, this message translates to:
  /// **'간(間)을 통해 최대한 많은 점수 획득 시도'**
  String get stepEndgameScoring;
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
