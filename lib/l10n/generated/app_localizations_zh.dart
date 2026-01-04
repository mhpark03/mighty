// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Mighty';

  @override
  String get gameSubtitle => '韩国传统吃墩纸牌游戏';

  @override
  String get startGame => '开始游戏';

  @override
  String get newGame => '新游戏';

  @override
  String get biddingPhase => '叫牌阶段';

  @override
  String currentBidder(String name) {
    return '当前叫牌: $name';
  }

  @override
  String get noBidYet => '暂无叫牌';

  @override
  String highestBid(String bid) {
    return '最高叫牌: $bid';
  }

  @override
  String get bid => '叫牌';

  @override
  String get bidButton => '叫牌';

  @override
  String get pass => '过牌';

  @override
  String get tricks => '墩数';

  @override
  String get giruda => '王牌';

  @override
  String get noGiruda => '无王牌';

  @override
  String get spade => '黑桃';

  @override
  String get diamond => '方块';

  @override
  String get heart => '红心';

  @override
  String get club => '梅花';

  @override
  String get spadeName => '스페이드';

  @override
  String get diamondName => '다이아';

  @override
  String get heartName => '하트';

  @override
  String get clubName => '클로버';

  @override
  String get selectKitty => '选择底牌';

  @override
  String selectKittyDesc(int count) {
    return '选择3张要弃掉的牌 (已选: $count/3)';
  }

  @override
  String get receivedKitty => '收到的底牌:';

  @override
  String get myCards => '我的牌:';

  @override
  String get changeGiruda => '更改王牌 (可选):';

  @override
  String get confirm => '确认';

  @override
  String get declareFriend => '宣布朋友';

  @override
  String get friendDeclarationType => '朋友宣布方式:';

  @override
  String get byCard => '按牌指定';

  @override
  String get firstTrickFriend => '首墩朋友';

  @override
  String get firstTrickFriendDesc => '赢得第一墩的人';

  @override
  String get nthTrickFriend => '第N墩朋友';

  @override
  String get noFriend => '无朋友';

  @override
  String get noFriendDesc => '单独游戏';

  @override
  String get declare => '宣布';

  @override
  String get suit => '花色:';

  @override
  String get rank => '点数:';

  @override
  String selectedCard(String card) {
    return '选择的牌: $card';
  }

  @override
  String get trickNumber => '墩数:';

  @override
  String get playCard => '请出牌';

  @override
  String get yourTurn => '轮到你了';

  @override
  String playerTurn(String name) {
    return '$name的回合';
  }

  @override
  String get contract => '合约';

  @override
  String get trick => '墩';

  @override
  String get friend => '朋友';

  @override
  String get declarer => '庄家';

  @override
  String cards(int count) {
    return '牌: $count';
  }

  @override
  String get aiSelectingKitty => 'AI正在选择底牌...';

  @override
  String get aiDeclaringFriend => 'AI正在宣布朋友...';

  @override
  String get declarerTeamWins => '庄家队获胜！';

  @override
  String get defenderTeamWins => '防守队获胜！';

  @override
  String declarerTeamPoints(int points) {
    return '庄家队: $points分';
  }

  @override
  String defenderTeamPoints(int points) {
    return '防守队: $points分';
  }

  @override
  String targetPoints(int points) {
    return '目标: $points分';
  }

  @override
  String get score => '分数';

  @override
  String points(int points) {
    return '$points分';
  }

  @override
  String get player => '玩家';

  @override
  String get you => '당신';

  @override
  String get bidding => '비딩 중...';

  @override
  String get waiting => '대기';

  @override
  String get otherPlayerTurn => '다른 플레이어 차례입니다';

  @override
  String get yourCards => '당신의 카드';

  @override
  String get biddingTurn => '비딩 차례';

  @override
  String bidWithAmount(int amount) {
    return '비딩 $amount';
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
}
