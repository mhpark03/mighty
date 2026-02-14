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
  String get receivedKitty => '收到的牌:';

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
  String get firstTrickFriend => '首轮朋友';

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
  String get scoreFormula => '(得分-契约+1) + (得分-最小)×2';

  @override
  String get scoreFormulaLose => '-(契约 - 得分)';

  @override
  String get scoreMultipliers => '庄家 ×2, 朋友 ×1, 防守 ×(-1)';

  @override
  String get scoreMultipliersNoFriend => '庄家 ×3, 防守 ×(-1)';

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

  @override
  String get hulaTitle => '胡拉';

  @override
  String get hulaSubtitle => '4人拉米纸牌游戏';

  @override
  String get heartsTitle => '红心大战';

  @override
  String get heartsSubtitle => '4人吃墩游戏';

  @override
  String get handRoyalStraightFlush => '皇家同花顺';

  @override
  String get handBackStraightFlush => '反向同花顺';

  @override
  String get handStraightFlush => '同花顺';

  @override
  String get handFourOfAKind => '四条';

  @override
  String get handFullHouse => '葫芦';

  @override
  String get handFlush => '同花';

  @override
  String get handMountain => '山';

  @override
  String get handBackStraight => '反向顺子';

  @override
  String get handStraight => '顺子';

  @override
  String get handTriple => '三条';

  @override
  String get handTwoPair => '两对';

  @override
  String get handOnePair => '一对';

  @override
  String get handHighCard => '高牌';

  @override
  String highCardTop(String rank) {
    return '$rank高';
  }

  @override
  String get noLow => '无低牌';

  @override
  String get betPing => '平';

  @override
  String get betCheck => '过牌';

  @override
  String get betCall => '跟注';

  @override
  String get betDdadang => '加倍';

  @override
  String get betQuarter => '四分之一';

  @override
  String get betHalf => '一半';

  @override
  String get betFull => '全部';

  @override
  String get betDie => '弃牌';

  @override
  String get selectOpenCard => '选择要公开的牌';

  @override
  String get selectOpenCardDesc => '选中的牌将向对手公开';

  @override
  String get aiSelectingCard => 'AI正在选择牌...';

  @override
  String nthCard(int n) {
    return '第$n张牌';
  }

  @override
  String secondsCount(int n) {
    return '$n秒';
  }

  @override
  String totalBetAmount(int amount) {
    return '总计: $amount';
  }

  @override
  String bettingAmount(int amount) {
    return '下注: $amount';
  }

  @override
  String get bonusHand => '奖励牌型！';

  @override
  String get bonus => '奖励';

  @override
  String get total => '总计';

  @override
  String otherPlayersLose(int amount) {
    return '其他玩家: 各 -$amount';
  }

  @override
  String get thisGame => '本局';

  @override
  String get cumulative => '累计';

  @override
  String get foldedSection => '弃牌';

  @override
  String get hiLoHi => '高';

  @override
  String get hiLoLo => '低';

  @override
  String get hiLoSwing => '双向';

  @override
  String roundComplete(int n) {
    return '第 $n 轮完成！';
  }

  @override
  String get cardDistribution5 => '正在发第5张牌。';

  @override
  String get cardDistribution6 => '正在发第6张牌。';

  @override
  String get cardDistribution7 => '正在发最后第7张牌。';

  @override
  String get goodLuck => '祝好运！';

  @override
  String cardCount(int count) {
    return '$count张';
  }

  @override
  String get suitSpade => '黑桃';

  @override
  String get suitDiamond => '方块';

  @override
  String get suitHeart => '红心';

  @override
  String get suitClub => '梅花';

  @override
  String cardOwner(String card) {
    return '$card持有者';
  }

  @override
  String trickWinner(int n) {
    return '第$n轮获胜者';
  }

  @override
  String get hint => '提示';

  @override
  String get hintOff => '提示 关闭';

  @override
  String get hintDialogContent => '观看广告即可启用提示。\n继续吗？';

  @override
  String get newGameDialogContent => '观看广告即可开始新游戏。\n继续吗？';

  @override
  String get watchAd => '观看广告';

  @override
  String jokerLead(String suit) {
    return '小丑先攻: $suit';
  }

  @override
  String get gameSelection => '游戏选择';

  @override
  String get onecardTitle => '单牌';

  @override
  String get onecardSubtitle => '4人对战';

  @override
  String get gameRules => '游戏规则';

  @override
  String get heartsGuideGoal => '目标';

  @override
  String get heartsGuideGoalText => '目标是避开红心牌和黑桃皇后，获得最低分数。';

  @override
  String get heartsGuideHow => '玩法';

  @override
  String get heartsGuideHowText =>
      '• 4人游戏，每人13张牌\n• 游戏开始时向左传3张牌\n• 持有梅花2的玩家先出\n• 进行13轮，避开得分牌';

  @override
  String get heartsGuideScoring => '计分';

  @override
  String get heartsGuideScoringText =>
      '• 红心牌: 每张1分 (共13分)\n• 黑桃皇后 (♠Q): 13分\n• 总分: 26分\n• 低分获胜！';

  @override
  String get heartsGuideBreaking => '红心破冰';

  @override
  String get heartsGuideBreakingText => '第一轮不能出红心。\n红心被出过后才能用红心领出。';

  @override
  String get heartsGuideShootMoon => '射月';

  @override
  String get heartsGuideShootMoonText =>
      '如果一位玩家获得所有红心和黑桃皇后:\n• 该玩家: 0分\n• 其他玩家: 各26分';

  @override
  String get heartsGuideTips => '策略提示';

  @override
  String get heartsGuideTipsText => '• 尽早打出大牌\n• 小心黑桃皇后\n• 把得分牌给对手';

  @override
  String get allScoreCardsUsed => '所有得分牌用完！游戏结束';

  @override
  String passLeftCount(int count) {
    return '向左传 ($count/3)';
  }

  @override
  String get cardPass => '传牌';

  @override
  String trickProgress(int current) {
    return '轮次 $current/13';
  }

  @override
  String get heartBroken => '红心破冰';

  @override
  String get passRecommend => '推荐传牌';

  @override
  String get recommend => '推荐';

  @override
  String get selectCardsToPassLeft => '选择3张牌向左传';

  @override
  String playerNameWins(String name) {
    return '$name 获胜';
  }

  @override
  String playerStartsWithClub2(String name) {
    return '$name以梅花2开始';
  }

  @override
  String playerWonTrick(String name, int points) {
    return '$name赢得本轮！(+$points分)';
  }

  @override
  String playerShootMoonSuccess(String name) {
    return '$name全收成功！';
  }

  @override
  String get hintActivated => '提示已激活！';

  @override
  String get myTurn => '我的回合';

  @override
  String get start => '开始';

  @override
  String get counterClockwise => '逆时针';

  @override
  String get clockwise => '顺时针';

  @override
  String get blackJoker => '黑白小丑';

  @override
  String get colorJoker => '彩色小丑';

  @override
  String get oneCardCall => '单张！';

  @override
  String oneCardCallTimer(int seconds) {
    return '单张 ($seconds秒)';
  }

  @override
  String get selectSuit => '请选择花色';

  @override
  String get discardedCards => '弃牌';

  @override
  String get meld => '组合';

  @override
  String get discard => '弃牌';

  @override
  String get stop => '停止';

  @override
  String get handCards => '手牌';

  @override
  String get cannotPlayCard => '不能出这张牌';

  @override
  String get drawCard => '请抽牌';

  @override
  String get discardOrMeld => '请弃牌或组合';

  @override
  String get noCards => '没有牌';

  @override
  String get thankYouSelectMethod => '选择谢谢方式';

  @override
  String thankYouMeldSolo(String suit) {
    return '谢谢！ ${suit}7 单独组合';
  }

  @override
  String thankYouMeldMyMeld(String card) {
    return '谢谢！ 将 $card 加入我的组合';
  }

  @override
  String thankYouMeldAiMeld(String card, String aiName) {
    return '谢谢！ 将 $card 加入 $aiName 的组合';
  }

  @override
  String get addedToMeld => '已添加到组合';

  @override
  String get noMeldToAttach => '没有可添加的组合';

  @override
  String get invalidCombination => '无效的组合';

  @override
  String get drawCardFirst => '请先抽牌';

  @override
  String get selectCardToDiscard => '请选择要弃的牌';

  @override
  String get hulaWin => 'Hula胜利！ (x2)';

  @override
  String get continue_ => '继续';

  @override
  String attackReceived(int count) {
    return '受到攻击，抽了$count张牌';
  }

  @override
  String get cardDrawn => '抽了牌';

  @override
  String bankrupt(int count) {
    return '破产！ ($count张牌)';
  }

  @override
  String get restart => '重新开始';

  @override
  String get goal => '目标';

  @override
  String get howToPlay => '玩法';

  @override
  String get attackCards => '攻击牌';

  @override
  String get defense => '防御';

  @override
  String get specialCards => '特殊牌';

  @override
  String get tips => '提示';

  @override
  String get winRate => '胜率';

  @override
  String get onecardGuideGoal => '目标';

  @override
  String get onecardGuideGoalText => '最先出完手中所有牌即为胜利。';

  @override
  String get onecardGuidePlay => '出牌';

  @override
  String get onecardGuidePlayText => '可以出与前一张牌相同花色或相同数字的牌。';

  @override
  String get onecardGuideAttack => '攻击牌';

  @override
  String get onecardGuideAttackText =>
      '• 2: +2张攻击\n• A: +3张攻击 (♠A为+5张)\n• 小丑: +5张(黑白) / +7张(彩色)';

  @override
  String get onecardGuideSpecial => '特殊牌';

  @override
  String get onecardGuideSpecialText =>
      '• J: 跳过下一位\n• Q: 反转方向\n• K: 跳过2回合\n• 7: 更换花色';

  @override
  String get onecardGuideJokerDefense => '小丑防御';

  @override
  String get onecardGuideJokerDefenseText => '被小丑攻击时，只能用小丑防御。';

  @override
  String get onecardGuideOnecard => '单牌!';

  @override
  String get onecardGuideOnecardText => '剩1张牌时必须按\"单牌!\"按钮。\n不按的话将受到2张罚牌。';

  @override
  String get onecardGuideBankrupt => '破产';

  @override
  String get onecardGuideBankruptText => '手牌达到20张以上就破产！牌最少的玩家获胜。';

  @override
  String get hulaGuideGoal => '目标';

  @override
  String get hulaGuideGoalText => '最先通过组合或弃牌清空手牌即为胜利。';

  @override
  String get hulaGuideHow => '玩法';

  @override
  String get hulaGuideHowText => '每回合从牌堆或弃牌堆抽一张牌，然后组合或弃牌。';

  @override
  String get hulaGuideMelds => '组合类型';

  @override
  String get hulaGuideMeldsText =>
      '• 顺子: 同花色连续3张以上 (例: ♠3-4-5)\n• 刻子: 相同数字不同花色3张以上 (例: ♠7-♥7-♦7)';

  @override
  String get hulaGuideSeven => '7的特殊规则';

  @override
  String get hulaGuideSevenText => '7可以单独组合。';

  @override
  String get hulaGuideThankYou => '谢谢';

  @override
  String get hulaGuideThankYouText => '从弃牌堆抽到7时可以喊\"谢谢\"并进行特殊组合。';

  @override
  String get hulaGuideStop => '停止';

  @override
  String get hulaGuideStopText => '可以随时喊停止结束游戏。\n剩余牌点数最低的玩家获胜。';

  @override
  String get hulaGuideCardPoints => '牌点数';

  @override
  String get hulaGuideCardPointsText => 'A=1分, 2~9=面值, J=10分, Q=11分, K=12分';

  @override
  String get hulaGuideScoring => '计分';

  @override
  String get hulaGuideScoringText =>
      '• 赢家: 获得与其他玩家手牌差值总和\n• 输家: 扣除与赢家的手牌差值\n• 胡拉(无组合获胜): 双倍得分';

  @override
  String get hulaGuideStopPenalty => '停止失败惩罚';

  @override
  String get hulaGuideStopPenaltyText =>
      '喊停止但不是最低分时:\n• 喊停止的人承担赢家应得的全部分数\n• 其他玩家不扣分';

  @override
  String attackTotalCards(int power, int total) {
    return '+$power! (共$total张攻击)';
  }

  @override
  String get skipNextTurnMessage => 'J! 跳过下一回合';

  @override
  String get reverseDirectionMessage => 'Q! 反转方向';

  @override
  String get skipTwoTurnsMessage => 'K! 跳过2回合';

  @override
  String changeSuitMessage(String suit) {
    return '7! 更换花色: $suit';
  }

  @override
  String playerPlayedCard(String name) {
    return '$name出了一张牌';
  }

  @override
  String onecardWithPlayers(int count) {
    return '单卡 (${count}P)';
  }

  @override
  String get blackWhiteJoker => '黑白小丑';

  @override
  String get clockwiseDirection => '顺时针';

  @override
  String get counterClockwiseDirection => '逆时针';

  @override
  String aiTurnCountdown(String name, int seconds) {
    return '$name ($seconds)';
  }

  @override
  String aiTurn(String name) {
    return '$name的回合';
  }

  @override
  String get cannotPlayThisCard => '这张牌无法出';

  @override
  String bankruptWithCards(int count) {
    return '破产! ($count张)';
  }

  @override
  String get gameRulesTitle => '游戏规则';

  @override
  String get goalText => '最先出完所有手牌的玩家获胜。\n出最后一张牌前必须喊\"单卡\"。';

  @override
  String get howToPlayText => '可以出相同花色或相同数字的牌。\n没有可出的牌时从牌堆抽牌。';

  @override
  String get defenseText => '被攻击时可以用相同的攻击牌防御。\n防御后攻击会累积给下一位玩家。';

  @override
  String get gameTips => '游戏提示';

  @override
  String get drawCardMessage => '请抽一张牌';

  @override
  String get discardOrMeldMessage => '请弃牌或组合';

  @override
  String get noCardsMessage => '没有牌';

  @override
  String thankYouSolo(String suit) {
    return '谢谢! ${suit}7 单独组合';
  }

  @override
  String thankYouAddToMine(String card) {
    return '谢谢! $card 添加到我的组合';
  }

  @override
  String thankYouAddToAi(String card, String aiName) {
    return '谢谢! $card 添加到$aiName的组合';
  }

  @override
  String thankYouDesc(String desc) {
    return '谢谢! $desc';
  }

  @override
  String get drawFirstMessage => '请先抽牌';

  @override
  String get hulaWinBonus => '胡拉获胜! (x2)';

  @override
  String get handColumn => '手牌';

  @override
  String get scoreColumn => '得分';

  @override
  String get cumulativeColumn => '累计';

  @override
  String hulaWithPlayers(int count) {
    return '胡拉 ($count人)';
  }

  @override
  String hintOnOff(String status) {
    return '提示 $status';
  }

  @override
  String get emptyDiscardPile => '无\n弃牌';

  @override
  String get meldButton => '组合';

  @override
  String get discardButton => '弃牌';

  @override
  String get stopButton => '停止';

  @override
  String get thankYouMeld => '谢谢组合';

  @override
  String get meldTypes => '组合类型';

  @override
  String get ok => '确定';

  @override
  String aiThankYouDraw(String aiName, String card) {
    return '$aiName 谢谢! $card';
  }

  @override
  String aiDrawsCard(String aiName) {
    return '$aiName抽牌';
  }

  @override
  String aiRegistersSeven(String aiName, String type) {
    return '$aiName: 7 $type登记';
  }

  @override
  String aiRegistersMeld(String aiName, String meldType, String cards) {
    return '$aiName: $meldType登记 $cards';
  }

  @override
  String aiAttachesToMeld(String aiName, String card) {
    return '$aiName: $card加入组合';
  }

  @override
  String aiAttachesToPlayerMeld(String aiName, String card) {
    return '$aiName: $card加入玩家组合';
  }

  @override
  String aiAttachesToOtherAiMeld(String aiName, String card, String targetAi) {
    return '$aiName: $card加入$targetAi组合';
  }

  @override
  String aiDiscards(String aiName, String card) {
    return '$aiName: 弃$card';
  }

  @override
  String get group => '组';

  @override
  String get solo => '单独';

  @override
  String get victory => '胜利!';

  @override
  String get defeat => '失败';

  @override
  String drewCardWithCard(String card) {
    return '抽到$card';
  }

  @override
  String playerDiscards(String card) {
    return '弃$card';
  }

  @override
  String get inPossession => '（已拥有）';

  @override
  String get fourPlayerGame => '4人对战';

  @override
  String meldCount(int count) {
    return '$count组';
  }

  @override
  String get cannotPlayFirstTrickDeclarerGiruda => '第一轮庄家不能用王牌先出';

  @override
  String get cannotPlayFirstTrickJoker => '第一轮不能出小丑';

  @override
  String get cannotPlayLastTrickJoker => '最后一轮不能出小丑';

  @override
  String get cannotPlayLastTrickJokerHasLeadSuit => '有首出花色时不能出小丑';

  @override
  String get mustPlayJokerCall => '小丑呼叫！你必须出小丑';

  @override
  String mustFollowSuit(String suit) {
    return '你必须出$suit花色';
  }

  @override
  String get fullDeclarationWarning => '宣布满分后合约将提升至20';

  @override
  String get watchAiGame => '学习Mighty';

  @override
  String get demoMode => '演示模式';

  @override
  String get stopDemo => '停止观战';

  @override
  String get pauseDemo => '暂停';

  @override
  String get resumeDemo => '继续';

  @override
  String get nextGameAuto => '下一局';

  @override
  String bidExplanation(String name, String suit, int strength) {
    return '$name: 最佳王牌 $suit，强度 $strength';
  }

  @override
  String bidExplanationBid(String name, String suit, int tricks, int strength) {
    return '$name: $suit $tricks 叫牌 (强度 $strength)';
  }

  @override
  String get passReasonNoSuit => '无王牌候选 (无4张以上花色)';

  @override
  String get passReasonNoHighCard => '无王牌A/K';

  @override
  String passReasonWeakHand(int strength, int needed) {
    return '牌力不足 (强度 $strength，需要 $needed)';
  }

  @override
  String get passReasonPowerWeak => '力量牌不足（Mighty/Joker/A不到5张）';

  @override
  String passReasonLowPoints(int optimal) {
    return '适当 $optimal分 < 最低 13分';
  }

  @override
  String passReasonOutbid(int optimal, int needed) {
    return '适当 $optimal分 < 需要 $needed分';
  }

  @override
  String estimatedRange(int min, int max) {
    return '预计 $min~$max分';
  }

  @override
  String optimalScore(int optimal) {
    return '适当 $optimal分';
  }

  @override
  String get friendExpected => '预计朋友';

  @override
  String get friendCardMighty => 'Mighty';

  @override
  String get friendCardJoker => 'Joker';

  @override
  String friendHeldBy(String name) {
    return '$name 持有';
  }

  @override
  String get friendInKitty => '可能在底牌中';

  @override
  String get friendJokerNote => '首轮不可使用';

  @override
  String get trickLead => '先攻';

  @override
  String get trickIntentJoker => '用Joker确保赢墩';

  @override
  String get trickIntentMighty => '用Mighty确保赢墩';

  @override
  String get trickIntentGiruda => '出王牌消耗对手王牌';

  @override
  String get trickIntentAce => '用A保持先手确保赢墩';

  @override
  String get trickIntentHighCard => '用高牌挑战赢墩';

  @override
  String get trickIntentLowCard => '用低牌试探/牺牲';

  @override
  String get trickIntentMidCard => '用中牌挑战赢墩';

  @override
  String trickResultBigWin(int count) {
    return '先攻胜利！获得$count张分数牌';
  }

  @override
  String trickResultWin(int count) {
    return '先攻胜利，获得$count张分数牌';
  }

  @override
  String get trickResultWinNoPoint => '先攻胜利，无分数牌';

  @override
  String get trickLostToJoker => '被Joker夺走';

  @override
  String get trickLostToMighty => '被Mighty夺走';

  @override
  String get trickLostToCut => '被王牌切走';

  @override
  String get trickLostToHigher => '被更高的牌夺走';

  @override
  String trickPointCards(int count) {
    return '$count张分数牌';
  }

  @override
  String get kittySummaryTitle => '底牌选择结果';

  @override
  String get kittyReceivedCards => '从底牌获得的牌';

  @override
  String get kittyDiscardCards => '丢弃的牌';

  @override
  String get kittyFinalHand => '最终手牌 (10张)';

  @override
  String get discardReasonCutSuit => '整理少花色 → 可切牌';

  @override
  String get discardReasonNonGirudaLow => '非王牌低牌';

  @override
  String get discardReasonLowValue => '低价值牌';

  @override
  String get discardReasonLeastUseful => '最不需要的牌';

  @override
  String get friendSummaryTitle => '朋友宣言结果';

  @override
  String get friendReasonNoFriendStrong => '手牌强力，可以独自获胜';

  @override
  String get friendReasonFirstTrick => '指定第一墩赢家为朋友';

  @override
  String get friendReasonNthTrick => '指定特定墩赢家为朋友';

  @override
  String get friendReasonNeedMighty => '没有Mighty，需要持有者为盟友';

  @override
  String get friendReasonNeedJoker => '没有Joker，需要持有者为盟友';

  @override
  String get friendReasonNeedGirudaAce => '没有王牌A，需要持有者为盟友';

  @override
  String get friendReasonNeedGirudaKing => '没有王牌K，需要持有者为盟友';

  @override
  String get friendReasonNeedGirudaMid => '需要王牌中间牌持有者为盟友';

  @override
  String get friendReasonNeedAce => '指定A持有者为朋友';

  @override
  String get friendReasonNeedStrongCard => '指定强牌持有者为朋友';

  @override
  String get friendReasonNoFriendAll => '拥有所有关键牌，无需朋友';

  @override
  String get bidSummaryTitle => '竞标结果';

  @override
  String get bidSummaryEstimatedRange => '预计得分范围 (庄家基准)';

  @override
  String bidSummaryEstMax(int points) {
    return '最大 ($points分)';
  }

  @override
  String get bidSummaryEstMaxDesc => '含朋友，保持先手时';

  @override
  String bidSummaryEstMin(int points) {
    return '最小 ($points分)';
  }

  @override
  String get bidSummaryEstMinDesc => '无朋友帮助（Joker Call等）';

  @override
  String get bidSummaryMultipliers => '庄家 ×2、朋友 ×1、防守 ×(-1)';

  @override
  String get firstTrickStrategy => '首墩策略';

  @override
  String get scoreStrategy => '得分策略';

  @override
  String get firstTrickAce => '用非王牌A领出，确保获得一墩';

  @override
  String get firstTrickKing => '用非王牌K领出，尝试获得一墩';

  @override
  String get firstTrickGiveUp => '没有强力领出牌，出小牌收集信息';

  @override
  String get strategyMighty => 'Mighty保证获得一墩';

  @override
  String get strategyJoker => 'Joker可在任意时机获得一墩';

  @override
  String get strategyGirudaDominant => '5张以上王牌确保王牌支配力';

  @override
  String get strategyGirudaSupport => '3张以上王牌提供王牌支援';

  @override
  String get strategyMultiAce => '多张A可获得多墩';

  @override
  String get strategySingleAce => '1张A提供额外获墩机会';

  @override
  String get strategyCut => '短花色可用王牌切牌';
}
