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
}
