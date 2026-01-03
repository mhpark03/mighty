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
}
