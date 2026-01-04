// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'マイティ';

  @override
  String get gameSubtitle => '韓国の伝統トリックテイキングカードゲーム';

  @override
  String get startGame => 'ゲーム開始';

  @override
  String get newGame => '新しいゲーム';

  @override
  String get biddingPhase => 'ビッディング段階';

  @override
  String currentBidder(String name) {
    return '現在のビッダー: $name';
  }

  @override
  String get noBidYet => 'まだビッドなし';

  @override
  String highestBid(String bid) {
    return '最高ビッド: $bid';
  }

  @override
  String get bid => 'ビッド';

  @override
  String get bidButton => 'ビッドする';

  @override
  String get pass => 'パス';

  @override
  String get tricks => 'トリック数';

  @override
  String get giruda => '切り札';

  @override
  String get noGiruda => 'ノートランプ';

  @override
  String get spade => 'スペード';

  @override
  String get diamond => 'ダイヤ';

  @override
  String get heart => 'ハート';

  @override
  String get club => 'クラブ';

  @override
  String get spadeName => '스페이드';

  @override
  String get diamondName => '다이아';

  @override
  String get heartName => '하트';

  @override
  String get clubName => '클로버';

  @override
  String get selectKitty => 'キティ選択';

  @override
  String selectKittyDesc(int count) {
    return '捨てるカード3枚を選択 (選択済み: $count/3)';
  }

  @override
  String get receivedKitty => '受け取ったキティ:';

  @override
  String get myCards => '手札:';

  @override
  String get changeGiruda => '切り札変更 (任意):';

  @override
  String get confirm => '確認';

  @override
  String get declareFriend => 'フレンド宣言';

  @override
  String get friendDeclarationType => 'フレンド宣言方式:';

  @override
  String get byCard => 'カードで指定';

  @override
  String get firstTrickFriend => '初回トリックフレンド';

  @override
  String get firstTrickFriendDesc => '最初のトリックを取った人';

  @override
  String get nthTrickFriend => 'N回目トリックフレンド';

  @override
  String get noFriend => 'ノーフレンド';

  @override
  String get noFriendDesc => '一人でプレイ';

  @override
  String get declare => '宣言';

  @override
  String get suit => 'スート:';

  @override
  String get rank => 'ランク:';

  @override
  String selectedCard(String card) {
    return '選択したカード: $card';
  }

  @override
  String get trickNumber => 'トリック番号:';

  @override
  String get playCard => 'カードを出してください';

  @override
  String get yourTurn => 'あなたの番です';

  @override
  String playerTurn(String name) {
    return '$nameの番';
  }

  @override
  String get contract => '契約';

  @override
  String get trick => 'トリック';

  @override
  String get friend => 'フレンド';

  @override
  String get declarer => '宣言者';

  @override
  String cards(int count) {
    return 'カード: $count';
  }

  @override
  String get aiSelectingKitty => 'AIがキティを選択中...';

  @override
  String get aiDeclaringFriend => 'AIがフレンドを宣言中...';

  @override
  String get declarerTeamWins => '宣言者チームの勝利！';

  @override
  String get defenderTeamWins => '守備チームの勝利！';

  @override
  String declarerTeamPoints(int points) {
    return '宣言者チーム: $points点';
  }

  @override
  String defenderTeamPoints(int points) {
    return '守備チーム: $points点';
  }

  @override
  String targetPoints(int points) {
    return '目標: $points点';
  }

  @override
  String get score => 'スコア';

  @override
  String points(int points) {
    return '$points点';
  }

  @override
  String get player => 'プレイヤー';

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
}
