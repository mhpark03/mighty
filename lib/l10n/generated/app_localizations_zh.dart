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
}
