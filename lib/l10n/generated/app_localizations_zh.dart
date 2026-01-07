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
  String get tricks => '目标分数';

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
  String get spadeName => '黑桃';

  @override
  String get diamondName => '方块';

  @override
  String get heartName => '红心';

  @override
  String get clubName => '梅花';

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
  String get declarerTeam => '庄家队';

  @override
  String get defenderTeam => '防守队';

  @override
  String get fullPoints => '满分';

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
  String get you => '你';

  @override
  String get bidding => '叫牌中...';

  @override
  String get waiting => '等待';

  @override
  String get otherPlayerTurn => '其他玩家的回合';

  @override
  String get yourCards => '你的牌';

  @override
  String get biddingTurn => '叫牌轮';

  @override
  String bidWithAmount(int amount) {
    return '叫牌 $amount';
  }

  @override
  String trickComplete(int number) {
    return '第 $number 墩完成';
  }

  @override
  String winnerAnnouncement(String name, String team) {
    return '$name 获胜! ($team)';
  }

  @override
  String get attackTeam => '进攻';

  @override
  String get defenseTeam => '防守';

  @override
  String get nextTrick => '下一墩';

  @override
  String get friendNone => '无';

  @override
  String get firstTrick => '首墩';

  @override
  String get selectCardHint => '选择一张牌 ↓';

  @override
  String get previousTrick => '上一墩';

  @override
  String get winShort => '胜';

  @override
  String get leadPlayer => '领先';

  @override
  String get leadPlayerHint => '👆 你领先!';

  @override
  String get selectCardBelow => '请从下方选择一张牌';

  @override
  String get leadPlayerSelectCard => '👆 你领先! 选择一张牌';

  @override
  String jokerCallAnnouncement(String suit) {
    return '小丑召唤! $suit';
  }

  @override
  String get wonCards => '获得:';

  @override
  String get jokerCallTitle => '小丑召唤';

  @override
  String jokerCallQuestion(String suit) {
    return '宣布 $suit 小丑召唤?';
  }

  @override
  String get no => '否';

  @override
  String jokerCallButton(String suit) {
    return '$suit 小丑召唤!';
  }

  @override
  String get jokerLeadSuitTitle => '小丑领先';

  @override
  String get jokerLeadSuitQuestion => '选择其他玩家必须跟随的花色';

  @override
  String get allPassedTitle => '全部过牌';

  @override
  String get allPassedMessage => '所有玩家都过牌了。\n开始新游戏。';

  @override
  String get girudaChangeWarning => '更改王牌: 目标+2';

  @override
  String get keep => '保持';

  @override
  String get aiRecommendation => 'AI推荐';

  @override
  String get discardCards => '弃牌:';

  @override
  String get goalPlus2 => '(目标+2)';

  @override
  String get applyRecommendation => '应用';

  @override
  String nthTrickShort(int n) {
    return '第$n墩';
  }

  @override
  String get recommendedFriend => '推荐:';

  @override
  String get joker => '小丑';

  @override
  String get mighty => '王牌';

  @override
  String get recommendNoFriend => '推荐无朋友';

  @override
  String get reasonHasMighty => '持有王牌';

  @override
  String get reasonHasJoker => '持有小丑';

  @override
  String get reasonNeedMighty => '需要王牌';

  @override
  String get reasonNeedJoker => '需要小丑';

  @override
  String get reasonNeedGirudaAce => '需要王牌A';

  @override
  String get reasonNeedGirudaKing => '需要王牌K';

  @override
  String get reasonStrongHand => '强手牌';

  @override
  String get continueGame => '继续';

  @override
  String get exitGame => '退出游戏';

  @override
  String get exitGameConfirm => '退出游戏?\n当前游戏将被保存。';

  @override
  String get cancel => '取消';

  @override
  String get exit => '退出';

  @override
  String get savedGame => '已保存的游戏';

  @override
  String get noSavedGame => '没有已保存的游戏';

  @override
  String get recommendedCard => '推荐';

  @override
  String get showRecommendation => '显示提示';

  @override
  String get playerStats => '玩家统计';

  @override
  String get winLoss => '胜/负';

  @override
  String get totalScore => '总分';

  @override
  String get win => '胜';

  @override
  String get loss => '负';

  @override
  String get resetStats => '重置';

  @override
  String get resetStatsConfirm => '观看广告后，所有统计数据将被重置。\n继续吗?';

  @override
  String get exitApp => '退出应用';

  @override
  String get exitAppConfirm => '退出应用?';

  @override
  String get gameGuide => '游戏方法';

  @override
  String get guideOverview => '游戏概述';

  @override
  String get guideOverviewText => 'Mighty是一款5人吃墩纸牌游戏。庄家(1人)和朋友(1人)组队对抗防守队(3人)。';

  @override
  String get guideBidding => '叫牌';

  @override
  String get guideBiddingText => '• 每位玩家宣布将赢得的得分牌数\n• 叫牌最高者成为庄家\n• 庄家选择王牌花色';

  @override
  String get guideSpecialCards => '特殊牌';

  @override
  String get guideSpecialCardsText =>
      '• Mighty: 黑桃A (最强的牌)\n• 小丑: 第二强的牌\n• 王牌: 庄家选择的花色';

  @override
  String get guideFriend => '朋友';

  @override
  String get guideFriendText =>
      '• 庄家指定持有特定牌的人为朋友\n• 朋友可以隐藏身份\n• 小丑召唤: 指定持有特定3的人为朋友';

  @override
  String get guideScoring => '计分';

  @override
  String get guideScoringText =>
      '• 得分牌: A, K, Q, J, 10 (各1分，共20分)\n• 庄家队达到目标分数即获胜\n• 胜者得+分，败者得-分';

  @override
  String get guideTips => '游戏技巧';

  @override
  String get guideTipsText => '• Mighty和小丑始终很强\n• 善用王牌\n• 识别朋友身份很重要';

  @override
  String get close => '关闭';

  @override
  String get dealMiss => '发牌失误';

  @override
  String get dealMissTitle => '宣布发牌失误';

  @override
  String get dealMissConfirm => '宣布发牌失误?\n将公开手牌并重新开始。';

  @override
  String dealMissAnnouncement(String name) {
    return '$name 宣布发牌失误!';
  }

  @override
  String get dealMissNewGame => '因发牌失误重新开始游戏。';

  @override
  String get aiPlayer1 => '小明';

  @override
  String get aiPlayer2 => '小红';

  @override
  String get aiPlayer3 => '小刚';

  @override
  String get aiPlayer4 => '小美';

  @override
  String get scoreCalcWin => '分数计算 (胜利)';

  @override
  String get scoreCalcLose => '分数计算 (失败)';

  @override
  String get scoreFormula => '(得分-契约) + (得分-最小)×2';

  @override
  String get scoreFormulaLose => '-(契约 - 得分)';

  @override
  String get scoreMultipliers => '庄家 ×2, 朋友 ×1, 防守 ×(-1)';

  @override
  String get multiplierRun => '满贯 ×2';

  @override
  String get multiplierNoGiruda => '无将 ×2';

  @override
  String get multiplierNoFriend => '无朋友 ×2';

  @override
  String get multiplierBackRun => '反满贯 ×2';

  @override
  String get multiplierLabel => '倍数';

  @override
  String get selectGame => '选择游戏';

  @override
  String get sevenCardTitle => '七张扑克';

  @override
  String get sevenCardSubtitle => '7张牌扑克游戏';

  @override
  String get sevenCardRules => '游戏规则';

  @override
  String get sevenCardRulesText =>
      '• 每位玩家获得7张牌\n• 前3张为暗牌，其余4张为明牌\n• 通过下注回合，用最佳5张牌决胜负\n• 牌型最大的玩家获胜';

  @override
  String get pot => '底池';

  @override
  String get currentBet => '当前下注';

  @override
  String get betting => '回合';

  @override
  String get chips => '筹码';

  @override
  String get bet => '下注';

  @override
  String get fold => '弃牌';

  @override
  String get call => '跟注';

  @override
  String get raise => '加注';

  @override
  String get check => '过牌';

  @override
  String get allIn => '全押';

  @override
  String get folded => '弃牌';

  @override
  String get wins => '获胜';

  @override
  String get gameEnd => '游戏结束';

  @override
  String get hiLoTitle => '高低';

  @override
  String get hiLoSubtitle => '高/低分池扑克';

  @override
  String get hi => '高';

  @override
  String get lo => '低';

  @override
  String get swing => '双向';

  @override
  String get selectHiLo => '选择高/低';

  @override
  String get selectHiLoDesc => '选择高、低或双向';

  @override
  String get hiWinner => '高牌赢家';

  @override
  String get loWinner => '低牌赢家';

  @override
  String get swingSuccess => '双向成功！';

  @override
  String get swingFailed => '双向失败';

  @override
  String get hiPot => '高牌底池';

  @override
  String get loPot => '低牌底池';

  @override
  String get noLowHand => '无低牌';

  @override
  String get bestLow => '最佳低牌';

  @override
  String get waitingForHiLo => '等待选择...';

  @override
  String get selectedHi => '已选高';

  @override
  String get selectedLo => '已选低';

  @override
  String get selectedSwing => '已选双向';

  @override
  String get showdownTitle => '声明状况';

  @override
  String get showdownDesc => '确认各玩家的选择';

  @override
  String get viewResults => '查看结果';

  @override
  String get finalResults => '最终结果';

  @override
  String get sevenCardGuideOverview => '游戏概述';

  @override
  String get sevenCardGuideOverviewText => '七张扑克是5人扑克游戏。用7张牌中的5张组成最好的牌型来获胜。';

  @override
  String get sevenCardGuideDealing => '发牌';

  @override
  String get sevenCardGuideDealingText =>
      '• 首先收到4张牌（3张暗牌，1张明牌）\n• 每轮下注后收到一张明牌\n• 最终用7张中的5张组成牌型';

  @override
  String get sevenCardGuideBetting => '下注规则';

  @override
  String get sevenCardGuideBettingText =>
      '• 过牌: 不下注跳过\n• 跟注: 匹配当前下注\n• 加注: 提高下注金额\n• 弃牌: 放弃本局\n• 全押: 下注所有筹码';

  @override
  String get sevenCardGuideHands => '牌型排名';

  @override
  String get sevenCardGuideHandsText =>
      '1. 皇家同花顺\n2. 反向同花顺\n3. 同花顺\n4. 四条\n5. 葫芦\n6. 同花\n7. 山 (A-K-Q-J-10)\n8. 反向顺子 (A-2-3-4-5)\n9. 顺子\n10. 三条\n11. 两对\n12. 一对\n13. 高牌';

  @override
  String get sevenCardGuideTips => '游戏技巧';

  @override
  String get sevenCardGuideTipsText =>
      '• 从明牌预测对手的牌型\n• 没有强牌时避免过度下注\n• 虚张声势也是策略';

  @override
  String get sevenCardGuideBonus => '奖励牌型';

  @override
  String get sevenCardGuideBonusText =>
      '• 皇家同花顺: 500筹码\n• 反向同花顺: 300筹码\n• 同花顺: 200筹码\n• 四条: 100筹码\n\n达成奖励牌型时，从所有其他玩家获得奖励！';

  @override
  String get hiLoGuideOverview => '游戏概述';

  @override
  String get hiLoGuideOverviewText => '高低是七张扑克的变体，底池分给高牌（最高牌型）和低牌（最低牌型）赢家。';

  @override
  String get hiLoGuideDealing => '发牌';

  @override
  String get hiLoGuideDealingText =>
      '• 与七张扑克相同的方式进行\n• 用7张牌中的5张组成牌型\n• 最后下注后选择高/低/双向';

  @override
  String get hiLoGuideHiLo => '高/低选择';

  @override
  String get hiLoGuideHiLoText =>
      '• 高: 用最高牌型竞争\n• 低: 用最低牌型竞争\n• 双向: 同时挑战高和低\n\n底池的50%归高牌赢家，50%归低牌赢家。';

  @override
  String get hiLoGuideLow => '低牌规则';

  @override
  String get hiLoGuideLowText =>
      '• 只有没有顺子/同花的牌才有资格\n• 越低越好（A最低）\n• 最强低牌: A-2-3-4-6\n• 没有对子的牌更有利';

  @override
  String get hiLoGuideSwing => '双向规则';

  @override
  String get hiLoGuideSwingText =>
      '• 将7张牌分成两个5张的牌\n• 必须同时赢得高和低才能成功\n• 成功: 赢得整个底池\n• 失败: 该部分归其他赢家';

  @override
  String get hiLoGuideTips => '游戏技巧';

  @override
  String get hiLoGuideTipsText =>
      '• A-2-3-4这样的低牌对低牌有利\n• 双向有风险但成功则回报丰厚\n• 观察对手的牌制定策略';

  @override
  String get hiLoGuideBonus => '奖励牌型';

  @override
  String get hiLoGuideBonusText =>
      '• 皇家同花顺: 500筹码\n• 反向同花顺: 300筹码\n• 同花顺: 200筹码\n• 四条: 100筹码\n\n达成奖励牌型时，自动赢得整个底池！';
}
