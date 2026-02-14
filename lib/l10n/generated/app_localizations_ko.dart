// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '마이티';

  @override
  String get gameSubtitle => '한국의 전통 트릭테이킹 카드 게임';

  @override
  String get startGame => '게임 시작하기';

  @override
  String get newGame => '새 게임';

  @override
  String get biddingPhase => '배팅 단계';

  @override
  String currentBidder(String name) {
    return '현재 배팅: $name';
  }

  @override
  String get noBidYet => '아직 배팅 없음';

  @override
  String highestBid(String bid) {
    return '최고 배팅: $bid';
  }

  @override
  String get bid => '배팅';

  @override
  String get bidButton => '배팅하기';

  @override
  String get pass => '패스';

  @override
  String get tricks => '목표 점수';

  @override
  String get giruda => '기루다';

  @override
  String get noGiruda => '노기루다';

  @override
  String get spade => '스페이드';

  @override
  String get diamond => '다이아몬드';

  @override
  String get heart => '하트';

  @override
  String get club => '클럽';

  @override
  String get spadeName => '스페이드';

  @override
  String get diamondName => '다이아';

  @override
  String get heartName => '하트';

  @override
  String get clubName => '클로버';

  @override
  String get selectKitty => '키티 선택';

  @override
  String selectKittyDesc(int count) {
    return '버릴 카드 3장을 선택하세요 (선택됨: $count/3)';
  }

  @override
  String get receivedKitty => '받은 카드:';

  @override
  String get myCards => '내 카드:';

  @override
  String get changeGiruda => '기루다 변경 (선택사항):';

  @override
  String get confirm => '확인';

  @override
  String get declareFriend => '프렌드 선언';

  @override
  String get friendDeclarationType => '프렌드 선언 방식:';

  @override
  String get byCard => '카드로 지정';

  @override
  String get firstTrickFriend => '초구 프렌드';

  @override
  String get firstTrickFriendDesc => '첫 트릭을 따는 사람';

  @override
  String get nthTrickFriend => 'N번째 트릭 프렌드';

  @override
  String get noFriend => '노프렌드';

  @override
  String get noFriendDesc => '혼자 플레이';

  @override
  String get declare => '선언';

  @override
  String get suit => '무늬:';

  @override
  String get rank => '숫자:';

  @override
  String selectedCard(String card) {
    return '선택한 카드: $card';
  }

  @override
  String get trickNumber => '트릭 번호:';

  @override
  String get playCard => '카드를 내세요';

  @override
  String get yourTurn => '당신의 차례입니다';

  @override
  String playerTurn(String name) {
    return '$name의 차례';
  }

  @override
  String get contract => '계약';

  @override
  String get trick => '트릭';

  @override
  String get friend => '프렌드';

  @override
  String get declarer => '주공';

  @override
  String cards(int count) {
    return '카드: $count';
  }

  @override
  String get aiSelectingKitty => 'AI가 키티를 선택하고 있습니다...';

  @override
  String get aiDeclaringFriend => 'AI가 프렌드를 선언하고 있습니다...';

  @override
  String get declarerTeamWins => '주공 팀 승리!';

  @override
  String get defenderTeamWins => '수비 팀 승리!';

  @override
  String get declarerTeam => '주공 팀';

  @override
  String get defenderTeam => '수비 팀';

  @override
  String get fullPoints => '풀';

  @override
  String declarerTeamPoints(int points) {
    return '주공 팀: $points점';
  }

  @override
  String defenderTeamPoints(int points) {
    return '수비 팀: $points점';
  }

  @override
  String targetPoints(int points) {
    return '목표: $points점';
  }

  @override
  String get score => '점수';

  @override
  String points(int points) {
    return '$points점';
  }

  @override
  String get player => '플레이어';

  @override
  String get you => '당신';

  @override
  String get bidding => '배팅 중...';

  @override
  String get waiting => '대기';

  @override
  String get otherPlayerTurn => '다른 플레이어 차례입니다';

  @override
  String get yourCards => '당신의 카드';

  @override
  String get biddingTurn => '배팅 차례';

  @override
  String bidWithAmount(int amount) {
    return '배팅 $amount';
  }

  @override
  String trickComplete(int number) {
    return '트릭 $number 완료';
  }

  @override
  String winnerAnnouncement(String name, String team) {
    return '$name 승리! ($team)';
  }

  @override
  String get attackTeam => '공격팀';

  @override
  String get defenseTeam => '방어팀';

  @override
  String get nextTrick => '다음 트릭';

  @override
  String get friendNone => '없음';

  @override
  String get firstTrick => '첫트릭';

  @override
  String get selectCardHint => '카드를 선택하세요 ↓';

  @override
  String get previousTrick => '이전 트릭';

  @override
  String get winShort => '승';

  @override
  String get leadPlayer => '선공';

  @override
  String get leadPlayerHint => '👆 선공입니다!';

  @override
  String get selectCardBelow => '아래에서 카드를 선택하세요';

  @override
  String get leadPlayerSelectCard => '👆 선공입니다! 카드를 선택하세요';

  @override
  String jokerCallAnnouncement(String suit) {
    return '조커 콜! $suit';
  }

  @override
  String get wonCards => '획득:';

  @override
  String get jokerCallTitle => '조커 콜';

  @override
  String jokerCallQuestion(String suit) {
    return '$suit 조커 콜을 선언하시겠습니까?';
  }

  @override
  String get no => '아니오';

  @override
  String jokerCallButton(String suit) {
    return '$suit 조커 콜!';
  }

  @override
  String get jokerLeadSuitTitle => '조커 선공';

  @override
  String get jokerLeadSuitQuestion => '다른 플레이어가 따라야 할 무늬를 선택하세요';

  @override
  String get allPassedTitle => '모두 패스';

  @override
  String get allPassedMessage => '모든 플레이어가 패스했습니다.\n새 게임을 시작합니다.';

  @override
  String get girudaChangeWarning => '기루다 변경 시 목표 +2 증가';

  @override
  String get keep => '유지';

  @override
  String get aiRecommendation => 'AI 추천';

  @override
  String get discardCards => '버릴 카드:';

  @override
  String get goalPlus2 => '(목표 +2)';

  @override
  String get applyRecommendation => '추천 적용';

  @override
  String nthTrickShort(int n) {
    return '$n트릭';
  }

  @override
  String get recommendedFriend => '추천 프렌드:';

  @override
  String get joker => '조커';

  @override
  String get mighty => '마이티';

  @override
  String get recommendNoFriend => '노프렌드 추천';

  @override
  String get reasonHasMighty => '마이티 보유';

  @override
  String get reasonHasJoker => '조커 보유';

  @override
  String get reasonNeedMighty => '마이티 필요';

  @override
  String get reasonNeedJoker => '조커 필요';

  @override
  String get reasonNeedGirudaAce => '기루다 A 필요';

  @override
  String get reasonNeedGirudaKing => '기루다 K 필요';

  @override
  String get reasonStrongHand => '강한 핸드';

  @override
  String get continueGame => '이어하기';

  @override
  String get exitGame => '게임 종료';

  @override
  String get exitGameConfirm => '게임을 종료하시겠습니까?\n현재 게임은 자동 저장됩니다.';

  @override
  String get cancel => '취소';

  @override
  String get exit => '종료';

  @override
  String get savedGame => '저장된 게임';

  @override
  String get noSavedGame => '저장된 게임이 없습니다';

  @override
  String get recommendedCard => '추천 카드';

  @override
  String get showRecommendation => '추천 보기';

  @override
  String get playerStats => '플레이어 통계';

  @override
  String get winLoss => '승/패';

  @override
  String get totalScore => '총점';

  @override
  String get win => '승';

  @override
  String get loss => '패';

  @override
  String get resetStats => '초기화';

  @override
  String get resetStatsConfirm => '광고를 시청하면 모든 통계가 초기화됩니다.\n계속하시겠습니까?';

  @override
  String get exitApp => '앱 종료';

  @override
  String get exitAppConfirm => '앱을 종료하시겠습니까?';

  @override
  String get gameGuide => '게임 방법';

  @override
  String get guideOverview => '게임 개요';

  @override
  String get guideOverviewText =>
      '마이티는 5명이 즐기는 트릭테이킹 카드 게임입니다. 주공(1명)과 프렌드(1명)가 팀을 이루어 수비팀(3명)과 대결합니다.';

  @override
  String get guideBidding => '배팅';

  @override
  String get guideBiddingText =>
      '• 각 플레이어는 자신이 획득할 점수 카드 수를 선언합니다\n• 가장 높은 배팅을 한 플레이어가 주공이 됩니다\n• 주공은 기루다(으뜸패)를 정합니다';

  @override
  String get guideSpecialCards => '특수 카드';

  @override
  String get guideSpecialCardsText =>
      '• 마이티: 스페이드 A (가장 강한 카드)\n• 조커: 두 번째로 강한 카드\n• 기루다: 주공이 정한 으뜸패 무늬';

  @override
  String get guideFriend => '프렌드';

  @override
  String get guideFriendText =>
      '• 주공은 특정 카드를 가진 사람을 프렌드로 지정합니다\n• 프렌드는 자신이 프렌드인지 숨길 수 있습니다\n• 조커콜: 특정 무늬의 3을 가진 사람을 프렌드로 지정';

  @override
  String get guideScoring => '점수 계산';

  @override
  String get guideScoringText =>
      '• 점수 카드: A, K, Q, J, 10 (각 1점, 총 20점)\n• 주공팀이 목표 점수 이상 획득하면 승리\n• 승리팀은 +점수, 패배팀은 -점수';

  @override
  String get guideTips => '게임 팁';

  @override
  String get guideTipsText =>
      '• 마이티와 조커는 항상 강력합니다\n• 기루다 카드를 잘 활용하세요\n• 프렌드의 정체를 파악하는 것이 중요합니다';

  @override
  String get close => '닫기';

  @override
  String get dealMiss => '딜 미스';

  @override
  String get dealMissTitle => '딜 미스 선언';

  @override
  String get dealMissConfirm => '딜 미스를 선언하시겠습니까?\n패를 공개하고 새로 시작합니다.';

  @override
  String dealMissAnnouncement(String name) {
    return '$name 딜 미스 선언!';
  }

  @override
  String get dealMissNewGame => '딜 미스로 게임을 다시 시작합니다.';

  @override
  String get aiPlayer1 => '민준';

  @override
  String get aiPlayer2 => '서연';

  @override
  String get aiPlayer3 => '지호';

  @override
  String get aiPlayer4 => '수빈';

  @override
  String get scoreCalcWin => '점수 계산 (승리)';

  @override
  String get scoreCalcLose => '점수 계산 (패배)';

  @override
  String get scoreFormula => '(득점-공약+1) + (득점-최소)×2';

  @override
  String get scoreFormulaLose => '-(공약 - 득점)';

  @override
  String get scoreMultipliers => '주공 ×2, 프렌드 ×1, 야당 ×(-1)';

  @override
  String get scoreMultipliersNoFriend => '주공 ×3, 야당 ×(-1)';

  @override
  String get multiplierRun => '런 ×2';

  @override
  String get multiplierNoGiruda => '노기루다 ×2';

  @override
  String get multiplierNoFriend => '노프렌드 ×2';

  @override
  String get multiplierBackRun => '백런 ×2';

  @override
  String get multiplierLabel => '배수';

  @override
  String get selectGame => '게임 선택';

  @override
  String get sevenCardTitle => '세븐 포커';

  @override
  String get sevenCardSubtitle => '7장 카드 포커 게임';

  @override
  String get sevenCardRules => '게임 규칙';

  @override
  String get sevenCardRulesText =>
      '• 각 플레이어는 7장의 카드를 받습니다\n• 처음 3장은 비공개, 나머지 4장은 공개\n• 베팅 라운드를 거쳐 최종 5장으로 족보를 만듭니다\n• 가장 높은 족보를 가진 플레이어가 승리';

  @override
  String get pot => '팟';

  @override
  String get currentBet => '현재 베팅';

  @override
  String get betting => '라운드';

  @override
  String get chips => '칩';

  @override
  String get bet => '베팅';

  @override
  String get fold => '다이';

  @override
  String get call => '콜';

  @override
  String get raise => '레이즈';

  @override
  String get check => '체크';

  @override
  String get allIn => '올인';

  @override
  String get folded => '다이';

  @override
  String get wins => '승리';

  @override
  String get gameEnd => '게임 종료';

  @override
  String get hiLoTitle => '하이로우';

  @override
  String get hiLoSubtitle => '하이/로우 스플릿 포커';

  @override
  String get hi => '하이';

  @override
  String get lo => '로우';

  @override
  String get swing => '스윙';

  @override
  String get selectHiLo => '하이/로우 선택';

  @override
  String get selectHiLoDesc => '하이, 로우, 또는 스윙을 선택하세요';

  @override
  String get hiWinner => '하이 승자';

  @override
  String get loWinner => '로우 승자';

  @override
  String get swingSuccess => '스윙 성공!';

  @override
  String get swingFailed => '스윙 실패';

  @override
  String get hiPot => '하이 팟';

  @override
  String get loPot => '로우 팟';

  @override
  String get noLowHand => '로우 없음';

  @override
  String get bestLow => '베스트 로우';

  @override
  String get waitingForHiLo => '선택 대기 중...';

  @override
  String get selectedHi => '하이 선택';

  @override
  String get selectedLo => '로우 선택';

  @override
  String get selectedSwing => '스윙 선택';

  @override
  String get showdownTitle => '선언 현황';

  @override
  String get showdownDesc => '각 플레이어의 선택을 확인하세요';

  @override
  String get viewResults => '결과 보기';

  @override
  String get finalResults => '최종 결과';

  @override
  String get sevenCardGuideOverview => '게임 개요';

  @override
  String get sevenCardGuideOverviewText =>
      '세븐 포커는 5명이 즐기는 포커 게임입니다. 7장의 카드 중 5장으로 가장 높은 족보를 만들어 승리하세요.';

  @override
  String get sevenCardGuideDealing => '카드 배분';

  @override
  String get sevenCardGuideDealingText =>
      '• 처음에 4장을 받습니다 (3장 비공개, 1장 공개)\n• 베팅 후 한 장씩 공개 카드를 받습니다\n• 최종 7장 중 5장으로 족보를 만듭니다';

  @override
  String get sevenCardGuideBetting => '베팅 규칙';

  @override
  String get sevenCardGuideBettingText =>
      '• 체크: 베팅 없이 넘기기\n• 콜: 현재 베팅에 맞추기\n• 레이즈: 베팅 금액 올리기\n• 다이: 게임 포기\n• 올인: 모든 칩 베팅';

  @override
  String get sevenCardGuideHands => '족보 순위';

  @override
  String get sevenCardGuideHandsText =>
      '1. 로열 스트레이트 플러시\n2. 백 스트레이트 플러시\n3. 스트레이트 플러시\n4. 포카드\n5. 풀하우스\n6. 플러시\n7. 마운틴 (A-K-Q-J-10)\n8. 백스트레이트 (A-2-3-4-5)\n9. 스트레이트\n10. 트리플\n11. 투페어\n12. 원페어\n13. 하이카드';

  @override
  String get sevenCardGuideTips => '게임 팁';

  @override
  String get sevenCardGuideTipsText =>
      '• 공개 카드로 상대방 족보를 예측하세요\n• 강한 핸드가 아니면 과도한 베팅을 피하세요\n• 블러핑도 전략입니다';

  @override
  String get sevenCardGuideBonus => '보너스 핸드';

  @override
  String get sevenCardGuideBonusText =>
      '• 로열 스트레이트 플러시: 500칩\n• 백 스트레이트 플러시: 300칩\n• 스트레이트 플러시: 200칩\n• 포카드: 100칩\n\n보너스 핸드 달성 시 다른 모든 플레이어에게 보너스를 받습니다!';

  @override
  String get hiLoGuideOverview => '게임 개요';

  @override
  String get hiLoGuideOverviewText =>
      '하이로우는 세븐 포커의 변형으로, 팟이 하이(높은 족보)와 로우(낮은 족보) 승자에게 나뉩니다.';

  @override
  String get hiLoGuideDealing => '카드 배분';

  @override
  String get hiLoGuideDealingText =>
      '• 세븐 포커와 동일한 방식으로 진행\n• 7장의 카드 중 5장으로 족보를 만듭니다\n• 마지막 베팅 후 하이/로우/스윙 선택';

  @override
  String get hiLoGuideHiLo => '하이/로우 선택';

  @override
  String get hiLoGuideHiLoText =>
      '• 하이: 가장 높은 족보로 경쟁\n• 로우: 가장 낮은 족보로 경쟁\n• 스윙: 하이와 로우 모두 도전\n\n팟의 50%는 하이 승자, 50%는 로우 승자가 가져갑니다.';

  @override
  String get hiLoGuideLow => '로우 족보';

  @override
  String get hiLoGuideLowText =>
      '• 스트레이트/플러시 없는 핸드만 로우 자격\n• 낮을수록 좋음 (A가 가장 낮음)\n• 최강 로우: A-2-3-4-6\n• 페어가 없는 핸드가 유리';

  @override
  String get hiLoGuideSwing => '스윙 규칙';

  @override
  String get hiLoGuideSwingText =>
      '• 7장을 두 개의 5장 핸드로 나눕니다\n• 하이와 로우 모두 1등해야 성공\n• 성공 시 전체 팟 획득\n• 실패 시 해당 부분은 다른 승자에게';

  @override
  String get hiLoGuideTips => '게임 팁';

  @override
  String get hiLoGuideTipsText =>
      '• A-2-3-4 같은 낮은 카드는 로우에 유리\n• 스윙은 위험하지만 성공 시 큰 보상\n• 상대 카드를 보고 전략을 세우세요';

  @override
  String get hiLoGuideBonus => '보너스 핸드';

  @override
  String get hiLoGuideBonusText =>
      '• 로열 스트레이트 플러시: 500칩\n• 백 스트레이트 플러시: 300칩\n• 스트레이트 플러시: 200칩\n• 포카드: 100칩\n\n보너스 핸드 달성 시 자동으로 전체 팟을 획득합니다!';

  @override
  String get hulaTitle => '훌라';

  @override
  String get hulaSubtitle => '4인용 러미 카드 게임';

  @override
  String get heartsTitle => '하트';

  @override
  String get heartsSubtitle => '4인 트릭 테이킹 게임';

  @override
  String get handRoyalStraightFlush => '로열 스트레이트 플러시';

  @override
  String get handBackStraightFlush => '백스트레이트 플러시';

  @override
  String get handStraightFlush => '스트레이트 플러시';

  @override
  String get handFourOfAKind => '포카드';

  @override
  String get handFullHouse => '풀하우스';

  @override
  String get handFlush => '플러시';

  @override
  String get handMountain => '마운틴';

  @override
  String get handBackStraight => '백스트레이트';

  @override
  String get handStraight => '스트레이트';

  @override
  String get handTriple => '트리플';

  @override
  String get handTwoPair => '투페어';

  @override
  String get handOnePair => '원페어';

  @override
  String get handHighCard => '하이카드';

  @override
  String highCardTop(String rank) {
    return '$rank탑';
  }

  @override
  String get noLow => 'No Low';

  @override
  String get betPing => '삥';

  @override
  String get betCheck => '체크';

  @override
  String get betCall => '콜';

  @override
  String get betDdadang => '따당';

  @override
  String get betQuarter => '쿼터';

  @override
  String get betHalf => '하프';

  @override
  String get betFull => '풀';

  @override
  String get betDie => '다이';

  @override
  String get selectOpenCard => '공개할 카드를 선택하세요';

  @override
  String get selectOpenCardDesc => '선택한 카드가 상대에게 공개됩니다';

  @override
  String get aiSelectingCard => 'AI가 카드를 선택하고 있습니다...';

  @override
  String nthCard(int n) {
    return '$n번째 카드';
  }

  @override
  String secondsCount(int n) {
    return '$n초';
  }

  @override
  String totalBetAmount(int amount) {
    return '총: $amount';
  }

  @override
  String bettingAmount(int amount) {
    return '베팅: $amount';
  }

  @override
  String get bonusHand => '보너스 핸드!';

  @override
  String get bonus => '보너스';

  @override
  String get total => '총';

  @override
  String otherPlayersLose(int amount) {
    return '다른 플레이어: 각 -$amount';
  }

  @override
  String get thisGame => '이번 게임';

  @override
  String get cumulative => '누적';

  @override
  String get foldedSection => '다이';

  @override
  String get hiLoHi => '하이';

  @override
  String get hiLoLo => '로우';

  @override
  String get hiLoSwing => '스윙';

  @override
  String roundComplete(int n) {
    return '라운드 $n 완료!';
  }

  @override
  String get cardDistribution5 => '5번째 카드가 배분됩니다.';

  @override
  String get cardDistribution6 => '6번째 카드가 배분됩니다.';

  @override
  String get cardDistribution7 => '마지막 7번째 카드가 배분됩니다.';

  @override
  String get goodLuck => 'GOOD LUCK!';

  @override
  String cardCount(int count) {
    return '$count장';
  }

  @override
  String get suitSpade => '스페이드';

  @override
  String get suitDiamond => '다이아몬드';

  @override
  String get suitHeart => '하트';

  @override
  String get suitClub => '클럽';

  @override
  String cardOwner(String card) {
    return '$card 소유자';
  }

  @override
  String trickWinner(int n) {
    return '$n번째 트릭 획득자';
  }

  @override
  String get hint => '힌트';

  @override
  String get hintOff => '힌트 OFF';

  @override
  String get hintDialogContent => '광고를 시청하면 힌트가 활성화됩니다.\n계속하시겠습니까?';

  @override
  String get newGameDialogContent => '광고를 시청하면 새 게임을 시작합니다.\n계속하시겠습니까?';

  @override
  String get watchAd => '광고 보기';

  @override
  String jokerLead(String suit) {
    return '조커 선공: $suit';
  }

  @override
  String get gameSelection => '게임 선택';

  @override
  String get onecardTitle => '원카드';

  @override
  String get onecardSubtitle => '4인 대전';

  @override
  String get gameRules => '게임 규칙';

  @override
  String get heartsGuideGoal => '목표';

  @override
  String get heartsGuideGoalText => '하트 카드와 스페이드 퀸을 피해 가장 낮은 점수를 얻는 것이 목표입니다.';

  @override
  String get heartsGuideHow => '진행 방법';

  @override
  String get heartsGuideHowText =>
      '• 4명이 플레이하며 각자 13장씩 받습니다\n• 게임 시작 시 3장을 왼쪽 플레이어에게 전달\n• 클럽 2를 가진 플레이어가 먼저 시작\n• 13트릭을 진행하며 점수 카드를 피합니다';

  @override
  String get heartsGuideScoring => '점수 계산';

  @override
  String get heartsGuideScoringText =>
      '• 하트 카드: 각 1점 (총 13점)\n• 스페이드 퀸 (♠Q): 13점\n• 총점: 26점\n• 낮은 점수가 승리!';

  @override
  String get heartsGuideBreaking => '하트 브레이킹';

  @override
  String get heartsGuideBreakingText =>
      '첫 트릭에서는 하트를 낼 수 없습니다.\n하트가 한 번 나온 후에야 하트로 시작할 수 있습니다.';

  @override
  String get heartsGuideShootMoon => '슈팅 더 문';

  @override
  String get heartsGuideShootMoonText =>
      '한 플레이어가 모든 하트와 스페이드 퀸을 획득하면:\n• 그 플레이어: 0점\n• 다른 플레이어: 각 26점';

  @override
  String get heartsGuideTips => '전략 팁';

  @override
  String get heartsGuideTipsText =>
      '• 높은 카드는 일찍 버리세요\n• 스페이드 퀸을 조심하세요\n• 상대방에게 점수 카드를 먹이세요';

  @override
  String get allScoreCardsUsed => '모든 점수 카드 소진! 게임 종료';

  @override
  String passLeftCount(int count) {
    return '왼쪽으로 패스 ($count/3)';
  }

  @override
  String get cardPass => '카드 패스';

  @override
  String trickProgress(int current) {
    return '트릭 $current/13';
  }

  @override
  String get heartBroken => '하트 브레이킹';

  @override
  String get passRecommend => '패스 추천';

  @override
  String get recommend => '추천';

  @override
  String get selectCardsToPassLeft => '왼쪽으로 보낼 카드 3장을 선택하세요';

  @override
  String playerNameWins(String name) {
    return '$name 승리';
  }

  @override
  String playerStartsWithClub2(String name) {
    return '$name가 클럽 2로 시작합니다';
  }

  @override
  String playerWonTrick(String name, int points) {
    return '$name 트릭 획득! (+$points점)';
  }

  @override
  String playerShootMoonSuccess(String name) {
    return '$name 슈팅 더 문 성공!';
  }

  @override
  String get hintActivated => '힌트가 활성화되었습니다!';

  @override
  String get myTurn => '내 차례';

  @override
  String get start => '시작';

  @override
  String get counterClockwise => '반시계';

  @override
  String get clockwise => '시계';

  @override
  String get blackJoker => '흑백 조커';

  @override
  String get colorJoker => '컬러 조커';

  @override
  String get oneCardCall => '원카드!';

  @override
  String oneCardCallTimer(int seconds) {
    return '원카드 ($seconds초)';
  }

  @override
  String get selectSuit => '무늬를 선택하세요';

  @override
  String get discardedCards => '버린 카드';

  @override
  String get meld => '등록';

  @override
  String get discard => '버리기';

  @override
  String get stop => '스톱';

  @override
  String get handCards => '손패';

  @override
  String get cannotPlayCard => '이 카드는 낼 수 없습니다';

  @override
  String get drawCard => '카드를 뽑으세요';

  @override
  String get discardOrMeld => '카드를 버리거나 등록하세요';

  @override
  String get noCards => '카드가 없습니다';

  @override
  String get thankYouSelectMethod => '땡큐 방법을 선택하세요';

  @override
  String thankYouMeldSolo(String suit) {
    return '땡큐! ${suit}7 단독 등록';
  }

  @override
  String thankYouMeldMyMeld(String card) {
    return '땡큐! $card 내 멜드에 붙이기';
  }

  @override
  String thankYouMeldAiMeld(String card, String aiName) {
    return '땡큐! $card $aiName 멜드에 붙이기';
  }

  @override
  String get addedToMeld => '멜드에 추가됨';

  @override
  String get noMeldToAttach => '붙일 멜드가 없습니다';

  @override
  String get invalidCombination => '유효하지 않은 조합입니다';

  @override
  String get drawCardFirst => '먼저 카드를 뽑으세요';

  @override
  String get selectCardToDiscard => '버릴 카드를 선택하세요';

  @override
  String get hulaWin => '훌라로 승리! (x2)';

  @override
  String get continue_ => '이어하기';

  @override
  String attackReceived(int count) {
    return '공격으로 $count장을 받았습니다';
  }

  @override
  String get cardDrawn => '카드를 뽑았습니다';

  @override
  String bankrupt(int count) {
    return '파산! ($count장 보유)';
  }

  @override
  String get restart => '다시 시작';

  @override
  String get goal => '목표';

  @override
  String get howToPlay => '진행 방법';

  @override
  String get attackCards => '공격 카드';

  @override
  String get defense => '방어';

  @override
  String get specialCards => '특수 카드';

  @override
  String get tips => '게임 팁';

  @override
  String get winRate => '승률';

  @override
  String get onecardGuideGoal => '목표';

  @override
  String get onecardGuideGoalText => '손에 든 카드를 가장 먼저 모두 내려놓는 것이 목표입니다.';

  @override
  String get onecardGuidePlay => '카드 내기';

  @override
  String get onecardGuidePlayText => '이전에 낸 카드와 같은 무늬 또는 같은 숫자의 카드를 낼 수 있습니다.';

  @override
  String get onecardGuideAttack => '공격 카드';

  @override
  String get onecardGuideAttackText =>
      '• 2: +2장 공격\n• A: +3장 공격 (♠A는 +5장)\n• 조커: +5장(흑백) / +7장(컬러)';

  @override
  String get onecardGuideSpecial => '특수 카드';

  @override
  String get onecardGuideSpecialText =>
      '• J: 다음 순서 건너뛰기\n• Q: 방향 반대\n• K: 2턴 건너뛰기\n• 7: 무늬 변경';

  @override
  String get onecardGuideJokerDefense => '조커 방어';

  @override
  String get onecardGuideJokerDefenseText => '조커로 공격받으면 조커로만 방어할 수 있습니다.';

  @override
  String get onecardGuideOnecard => '원카드!';

  @override
  String get onecardGuideOnecardText =>
      '손패가 1장 남으면 \"원카드!\" 버튼을 눌러야 합니다.\n누르지 않으면 패널티로 2장을 받습니다.';

  @override
  String get onecardGuideBankrupt => '파산';

  @override
  String get onecardGuideBankruptText =>
      '손패가 20장 이상이 되면 파산! 가장 적은 카드를 가진 플레이어가 승리합니다.';

  @override
  String get hulaGuideGoal => '목표';

  @override
  String get hulaGuideGoalText => '손패의 카드를 모두 등록하거나 버려서 가장 먼저 없애는 것이 목표입니다.';

  @override
  String get hulaGuideHow => '진행 방법';

  @override
  String get hulaGuideHowText =>
      '매 턴마다 덱 또는 버린 더미에서 카드 1장을 뽑고, 등록 또는 버리기를 합니다.';

  @override
  String get hulaGuideMelds => '멜드 종류';

  @override
  String get hulaGuideMeldsText =>
      '• Run: 같은 무늬의 연속된 숫자 3장 이상 (예: ♠3-4-5)\n• Group: 같은 숫자 다른 무늬 3장 이상 (예: ♠7-♥7-♦7)';

  @override
  String get hulaGuideSeven => '7의 특수 규칙';

  @override
  String get hulaGuideSevenText => '7은 단독으로 등록할 수 있습니다.';

  @override
  String get hulaGuideThankYou => '땡큐';

  @override
  String get hulaGuideThankYouText =>
      '버린 더미에서 7을 뽑으면 \"땡큐\"를 외치고 특별한 등록을 할 수 있습니다.';

  @override
  String get hulaGuideStop => '스톱';

  @override
  String get hulaGuideStopText =>
      '언제든 스톱을 외쳐 게임을 끝낼 수 있습니다.\n남은 카드 점수가 가장 적은 사람이 승리합니다.';

  @override
  String get hulaGuideCardPoints => '카드 점수';

  @override
  String get hulaGuideCardPointsText => 'A=1점, 2~9=숫자점, J=10점, Q=11점, K=12점';

  @override
  String get hulaGuideScoring => '점수 계산';

  @override
  String get hulaGuideScoringText =>
      '• 승자: 다른 플레이어 손패와의 차이 합계를 획득\n• 패자: 승자와의 손패 차이만큼 감점\n• 훌라(등록 없이 승리): 점수 2배';

  @override
  String get hulaGuideStopPenalty => '스톱 실패 페널티';

  @override
  String get hulaGuideStopPenaltyText =>
      '스톱을 외쳤지만 최저 점수가 아닌 경우:\n• 승자가 받을 점수 전부를 스톱한 사람이 부담\n• 다른 플레이어는 감점 없음';

  @override
  String attackTotalCards(int power, int total) {
    return '+$power! (총 $total장 공격)';
  }

  @override
  String get skipNextTurnMessage => 'J! 다음 턴 건너뛰기';

  @override
  String get reverseDirectionMessage => 'Q! 방향 반대';

  @override
  String get skipTwoTurnsMessage => 'K! 2턴 건너뛰기';

  @override
  String changeSuitMessage(String suit) {
    return '7! 무늬 변경: $suit';
  }

  @override
  String playerPlayedCard(String name) {
    return '$name이(가) 카드를 냈습니다';
  }

  @override
  String onecardWithPlayers(int count) {
    return '원카드 (${count}P)';
  }

  @override
  String get blackWhiteJoker => '흑백 조커';

  @override
  String get clockwiseDirection => '시계';

  @override
  String get counterClockwiseDirection => '반시계';

  @override
  String aiTurnCountdown(String name, int seconds) {
    return '$name ($seconds)';
  }

  @override
  String aiTurn(String name) {
    return '$name 차례';
  }

  @override
  String get cannotPlayThisCard => '이 카드는 낼 수 없습니다';

  @override
  String bankruptWithCards(int count) {
    return '파산! ($count장 보유)';
  }

  @override
  String get gameRulesTitle => '게임 규칙';

  @override
  String get goalText =>
      '손에 든 카드를 가장 먼저 모두 내려놓는 사람이 승리합니다.\n마지막 카드를 내기 전 \"원카드\"를 외쳐야 합니다.';

  @override
  String get howToPlayText =>
      '같은 무늬 또는 같은 숫자의 카드를 낼 수 있습니다.\n낼 수 있는 카드가 없으면 덱에서 카드를 뽑습니다.';

  @override
  String get defenseText =>
      '공격을 받으면 같은 공격 카드로 막을 수 있습니다.\n막으면 공격이 누적되어 다음 사람에게 넘어갑니다.';

  @override
  String get gameTips => '게임 팁';

  @override
  String get drawCardMessage => '카드를 뽑으세요';

  @override
  String get discardOrMeldMessage => '카드를 버리거나 등록하세요';

  @override
  String get noCardsMessage => '카드가 없습니다';

  @override
  String thankYouSolo(String suit) {
    return '땡큐! ${suit}7 단독 등록';
  }

  @override
  String thankYouAddToMine(String card) {
    return '땡큐! $card 내 멜드에 붙이기';
  }

  @override
  String thankYouAddToAi(String card, String aiName) {
    return '땡큐! $card $aiName 멜드에 붙이기';
  }

  @override
  String thankYouDesc(String desc) {
    return '땡큐! $desc';
  }

  @override
  String get drawFirstMessage => '먼저 카드를 뽑으세요';

  @override
  String get hulaWinBonus => '훌라로 승리! (x2)';

  @override
  String get handColumn => '손패';

  @override
  String get scoreColumn => '점수';

  @override
  String get cumulativeColumn => '누적';

  @override
  String hulaWithPlayers(int count) {
    return '훌라 ($count인)';
  }

  @override
  String hintOnOff(String status) {
    return '힌트 $status';
  }

  @override
  String get emptyDiscardPile => '버린 카드\n없음';

  @override
  String get meldButton => '등록';

  @override
  String get discardButton => '버리기';

  @override
  String get stopButton => '스톱';

  @override
  String get thankYouMeld => '땡큐 멜드';

  @override
  String get meldTypes => '멜드 종류';

  @override
  String get ok => '확인';

  @override
  String aiThankYouDraw(String aiName, String card) {
    return '$aiName 땡큐! $card';
  }

  @override
  String aiDrawsCard(String aiName) {
    return '$aiName이 카드를 뽑음';
  }

  @override
  String aiRegistersSeven(String aiName, String type) {
    return '$aiName: 7 $type 등록';
  }

  @override
  String aiRegistersMeld(String aiName, String meldType, String cards) {
    return '$aiName: $meldType 등록 $cards';
  }

  @override
  String aiAttachesToMeld(String aiName, String card) {
    return '$aiName: $card 멜드에 붙임';
  }

  @override
  String aiAttachesToPlayerMeld(String aiName, String card) {
    return '$aiName: $card 플레이어 멜드에 붙임';
  }

  @override
  String aiAttachesToOtherAiMeld(String aiName, String card, String targetAi) {
    return '$aiName: $card $targetAi 멜드에 붙임';
  }

  @override
  String aiDiscards(String aiName, String card) {
    return '$aiName: $card 버림';
  }

  @override
  String get group => '그룹';

  @override
  String get solo => '단독';

  @override
  String get victory => '승리!';

  @override
  String get defeat => '패배';

  @override
  String drewCardWithCard(String card) {
    return '$card을 뽑았습니다';
  }

  @override
  String playerDiscards(String card) {
    return '$card 버림';
  }

  @override
  String get inPossession => '(보유중)';

  @override
  String get fourPlayerGame => '4인 대전';

  @override
  String meldCount(int count) {
    return '$count개 멜드';
  }

  @override
  String get cannotPlayFirstTrickDeclarerGiruda => '첫 트릭에서 주공은 기루다로 선공할 수 없습니다';

  @override
  String get cannotPlayFirstTrickJoker => '첫 트릭에서는 조커를 낼 수 없습니다';

  @override
  String get cannotPlayLastTrickJoker => '마지막 트릭에서는 조커를 낼 수 없습니다';

  @override
  String get cannotPlayLastTrickJokerHasLeadSuit => '선공 무늬가 있으면 조커를 낼 수 없습니다';

  @override
  String get mustPlayJokerCall => '조커 콜! 조커를 내야 합니다';

  @override
  String mustFollowSuit(String suit) {
    return '$suit 무늬를 내야 합니다';
  }

  @override
  String get fullDeclarationWarning => '풀 선언 시 공약이 20으로 올라갑니다';

  @override
  String get watchAiGame => 'AI 대전 관전';

  @override
  String get demoMode => '데모 모드';

  @override
  String get stopDemo => '관전 종료';

  @override
  String get pauseDemo => '일시정지';

  @override
  String get resumeDemo => '재개';

  @override
  String get nextGameAuto => '다음 게임';

  @override
  String bidExplanation(String name, String suit, int strength) {
    return '$name: 최적 기루다 $suit, 예상 강도 $strength';
  }

  @override
  String bidExplanationBid(String name, String suit, int tricks, int strength) {
    return '$name: $suit $tricks 배팅 (강도 $strength)';
  }

  @override
  String get passReasonNoSuit => '기루다 후보 없음 (4장 이상 무늬 없음)';

  @override
  String get passReasonNoHighCard => '기루다 A/K 없음';

  @override
  String passReasonWeakHand(int strength, int needed) {
    return '핸드 강도 부족 (강도 $strength, 필요 $needed)';
  }

  @override
  String get kittySummaryTitle => '키티 선택 결과';

  @override
  String get kittyReceivedCards => '바닥에서 받은 카드';

  @override
  String get kittyDiscardCards => '버릴 카드';

  @override
  String get discardReasonCutSuit => '적은 무늬 정리 → 컷 가능';

  @override
  String get discardReasonNonGirudaLow => '비기루다 낮은 카드';

  @override
  String get discardReasonLowValue => '낮은 가치 카드';

  @override
  String get discardReasonLeastUseful => '가장 불필요한 카드';

  @override
  String get bidSummaryTitle => '배팅 결과';

  @override
  String get bidSummaryScoreTitle => '예상 점수 (주공 기준)';

  @override
  String get bidSummaryWinMin => '승리 시 (최소 득점)';

  @override
  String get bidSummaryWinMax => '승리 시 (풀 - 20점)';

  @override
  String get bidSummaryLose => '패배 시 (0점 획득)';

  @override
  String get bidSummaryMultipliers => '주공 ×2, 프렌드 ×1, 야당 ×(-1)';
}
