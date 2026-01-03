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
  String get startGame => '게임 시작';

  @override
  String get newGame => '새 게임';

  @override
  String get biddingPhase => '비딩 단계';

  @override
  String currentBidder(String name) {
    return '현재 비딩: $name';
  }

  @override
  String get noBidYet => '아직 비딩 없음';

  @override
  String highestBid(String bid) {
    return '최고 비딩: $bid';
  }

  @override
  String get bid => '비딩';

  @override
  String get bidButton => '비딩하기';

  @override
  String get pass => '패스';

  @override
  String get tricks => '트릭 수';

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
}
