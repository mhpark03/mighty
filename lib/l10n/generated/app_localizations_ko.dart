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
  String get receivedKitty => '받은 키티:';

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
}
