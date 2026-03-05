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
  String get guideIntro => '1. 游戏介绍';

  @override
  String get guideIntroText =>
      'Mighty是一款5人吃墩纸牌游戏。\n使用包含小丑的53张牌，每位玩家分10张，3张作为底牌（猫咪）。\n\n庄家（1人）和朋友（1人）组成进攻队，其余3人为防守队。庄家队获得不低于叫牌分数即获胜。';

  @override
  String get guideGameFlow => '2. 游戏流程';

  @override
  String get guideGameFlowText =>
      '① 发牌 → ② 叫牌 → ③ 底牌交换 → ④ 朋友宣言 → ⑤ 打牌 → ⑥ 计分\n\n各阶段按顺序进行。若所有玩家都放弃，则重新发牌。';

  @override
  String get guideBidding => '3. 叫牌';

  @override
  String get guideBiddingText =>
      '宣布自己能获得的得分牌数。\n\n• 最低叫牌: 13分（得分牌共20张）\n• 同时宣布王牌花色\n• 无王牌: 不设王牌（同分数时优先于有王牌叫牌）\n• 叫牌最高者成为庄家\n\n💡 手中有Mighty、小丑、王牌A时可以高叫。';

  @override
  String get guideKitty => '4. 底牌交换';

  @override
  String get guideKittyText =>
      '庄家取走3张底牌，从13张中弃掉3张。\n\n• 弃掉弱牌以强化手牌\n• 可以更换王牌花色（叫牌+2）\n• 也可以弃掉得分牌，但可能有利于防守队';

  @override
  String get guideFriend => '5. 朋友宣言';

  @override
  String get guideFriendText =>
      '庄家指定自己的队友（朋友）。\n\n• 牌友: 持有特定牌的人（例: 持有♠A的人）\n• 首墩朋友: 赢得第一墩的人\n• 无朋友: 单独作战（分数×2）\n\n朋友在打出指定牌之前身份不会暴露。防守队需要推理谁是朋友。';

  @override
  String get guideSpecialCards => '6. 特殊牌';

  @override
  String get guideSpecialCardsText =>
      '♠A Mighty\n最强的牌。任何牌都无法击败它。\n但小丑召唤时必须打出，如果王牌是♠则♦A是Mighty。\n\n🃏 小丑 (Joker)\nMighty之后最强的牌。\n领出时可以指定花色，首墩无效力。\n被小丑召唤时必须打出小丑。\n\n王牌\n庄家指定花色的牌。\n在非王牌花色中打出王牌可以\"切牌\"赢得该墩。';

  @override
  String get guideJokerCall => '7. 小丑召唤';

  @override
  String get guideJokerCallText =>
      '领出玩家打出特定花色的牌并宣布\"小丑召唤\"时，持有小丑的玩家必须打出小丑。\n\n• 首墩不能小丑召唤\n• 小丑召唤时小丑变为最弱的牌\n• 防守队使对方小丑失效的核心策略';

  @override
  String get guideTrickPlay => '8. 吃墩玩法';

  @override
  String get guideTrickPlayText =>
      '进行10轮吃墩。\n\n• 领出玩家打出一张牌\n• 其他玩家必须跟同花色的牌（跟牌）\n• 如果没有该花色可以打任意牌\n• 打出最强牌的玩家赢得该墩并成为下一轮领出者\n\n牌力顺序:\nMighty > 小丑 > 王牌(A~2) > 领出花色(A~2)';

  @override
  String get guideScoring => '9. 得分牌';

  @override
  String get guideScoringText =>
      '得分牌: A, K, Q, J, 10（每花色5张×4花色＝20张）\n每张得分牌值1分，由赢墩玩家获得。\n\n示例: 如果一墩中出了♠A、♠K、♥3、♦7、♣2\n→ 2张得分牌（♠A、♠K）＝赢墩者获得2分';

  @override
  String get guideWinLose => '10. 胜负与计分';

  @override
  String get guideWinLoseText =>
      '庄家队获得不低于叫牌的分数即获胜。\n\n胜利时基本分:\n•（获得分数 - 叫牌）+ 1 + 额外奖励\n• 全胜（赢得全部10墩）: 奖励分\n• 无朋友: 分数×2\n• 无王牌: 分数×2\n\n失败时:\n• 庄家扣（防守队人数×基本分）分\n• 反全胜（防守全赢）: 额外扣分';

  @override
  String get guideTips => '11. 策略技巧';

  @override
  String get guideTipsText =>
      '庄家策略:\n• 有Mighty/小丑/王牌A时积极叫牌\n• 早期消耗对手王牌防止切牌\n• 与朋友合作收集得分牌\n\n防守策略:\n• 尽快识别朋友身份\n• 用小丑召唤使对方小丑失效\n• 注意不让庄家队获得得分牌\n• 用王牌切牌抓对方非王牌A';

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
    return '$card 持有者';
  }

  @override
  String trickWinner(int n) {
    return '第$n墩赢家';
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
  String get kittyScoreChange => '预期分数变化';

  @override
  String get kittyBeforeExchange => '交换前';

  @override
  String get kittyAfterExchange => '交换后';

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
  String get kittySummaryTitle => '底牌选择结果';

  @override
  String get kittyReceivedCards => '从底牌获得的牌';

  @override
  String get kittyDiscardCards => '丢弃的牌';

  @override
  String get kittyFinalHand => '最终手牌 (10张)';

  @override
  String get girudaComparisonTitle => '王牌比较（13张）';

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
  String bidSummaryEstMinDescDynamic(String friend) {
    return '朋友($friend)仅基本贡献，可能在底牌中';
  }

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
  String get firstTrickMighty => '用Mighty领出，确保获得首墩';

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

  @override
  String bidInfoGirudaKeys(String keys) {
    return '王牌 $keys';
  }

  @override
  String bidInfoFriend(String card) {
    return '朋友: $card';
  }

  @override
  String bidInfoHasBoth(String card1, String card2) {
    return '持有 $card1·$card2';
  }

  @override
  String bidInfoHasCard(String card) {
    return '持有 $card';
  }

  @override
  String bidInfoFirstTrickAces(String aces) {
    return '首墩 $aces';
  }

  @override
  String get jokerOwner => '小丑持有者';

  @override
  String get friendBadge => '搭档';

  @override
  String get kittyLabel => '底牌 ';

  @override
  String kittyPointsWithFriend(int points) {
    return ' $points分 (搭档底牌)';
  }

  @override
  String kittyPoints(int points) {
    return ' $points分';
  }

  @override
  String friendWithName(String name) {
    return '搭档 $name ';
  }

  @override
  String adjustedPointsRange(int min, int max) {
    return '→ 调整 $min~$max分';
  }

  @override
  String get hasAceNote => ' (有A)';

  @override
  String strategyFirstTrickAceLead(String card) {
    return '首墩: 出$card确保赢墩';
  }

  @override
  String get strategyFirstTrickPassFriendWin => '首墩: 出短花色低牌让搭档赢墩（搭档获得首墩）';

  @override
  String strategyFirstTrickKingLead(String card) {
    return '首墩: 出$card尝试赢墩';
  }

  @override
  String get strategyFirstTrickPassFriend => '首墩: 出短花色低牌将首攻权交给搭档';

  @override
  String get strategyPassToMightyFriend => '出短花色低牌将首攻权交给搭档（Mighty）';

  @override
  String get strategyPassToJokerFriend => '出短花色低牌将首攻权交给搭档（Joker）';

  @override
  String strategyPassTrumpToFriend(
    String passCard,
    String friendCard,
    String rank,
  ) {
    return '出$passCard将首攻权交给搭档($friendCard) → 防止$rank单打';
  }

  @override
  String strategyPassSuitToFriend(String card, String friendCard) {
    return '出$card将首攻权交给搭档($friendCard)';
  }

  @override
  String get strategySourceFriend => '搭档赢墩后，';

  @override
  String get strategySourceReclaim => '夺回首攻权后，';

  @override
  String strategyTrumpDominate(String source, String cards) {
    return '$source用$cards压制 → 消耗防守方将牌';
  }

  @override
  String strategyTrumpExhaust(String source, String cards) {
    return '$source用$cards消耗防守方将牌';
  }

  @override
  String strategyTrumpMidDraw(String suit) {
    return '用$suit中等将牌逼出防守方高将牌';
  }

  @override
  String strategyJokerCallSuits(String suits) {
    return '消耗防守方将牌后，对弱花色($suits)叫Joker';
  }

  @override
  String get strategyJokerCallWeak => '消耗防守方将牌后，对弱花色叫Joker';

  @override
  String get strategyJokerOptimal => '在最佳时机使用Joker赢墩';

  @override
  String get strategyMightyTiming => '第9墩使用Mighty → 确保第10墩首攻权';

  @override
  String strategyVoidTrumpCut(String suits) {
    return '$suits缺门 → 对手首攻时用将牌切入夺墩';
  }

  @override
  String strategyTrumpExhaustCheckK(String cards) {
    return '出$cards → 将牌最高攻击，确认K消耗';
  }

  @override
  String get strategyJokerAfterFriend => '朋友合流后出王牌 → 得分';

  @override
  String strategyJokerCallGiruda(String suit) {
    return 'K未消耗时王牌: 叫$suit → 引出K';
  }

  @override
  String strategyLowGirudaFriendLure(String card) {
    return '出$card → 让出牌权引诱朋友';
  }

  @override
  String strategyGirudaQReclaim(String card) {
    return '出$card → 夺回出牌权';
  }

  @override
  String strategyHighCardAttack(String cards) {
    return '出$cards → 追加得分攻击';
  }

  @override
  String get trickDetails => '墩详情';

  @override
  String get trickColumnGainLoss => '得失';

  @override
  String get trickColumnGiruda => '将牌';

  @override
  String get trickColumnEvent => '事件';

  @override
  String get trickLegendLead => '首攻';

  @override
  String get trickLegendWinner => '赢家';

  @override
  String get trickEventLastCard => '最后一张牌';

  @override
  String get trickEventLastAttackTopCardWin => '攻方最高牌获胜';

  @override
  String get trickEventLastTrickGiruda => '将牌最后一墩';

  @override
  String get trickEventLastTrickMighty => 'Mighty最后一墩';

  @override
  String trickEventLastTrickTopByExhaust(String card) {
    return '花色消耗 → $card 最高牌首攻';
  }

  @override
  String get trickEventGameVictory => '进攻胜利确定';

  @override
  String get trickEventGameRunVictory => '进攻全胜(Run)大胜确定';

  @override
  String get trickEventGameDefeat => '进攻败北确定';

  @override
  String get trickEventSummaryRun => '总评: 全胜Run 大胜';

  @override
  String trickEventSummaryBackRun(int bid) {
    return '总评: 全败BackRun 0/$bid分 完败';
  }

  @override
  String trickEventSummaryBigWin(int wins, int losses, int points, int bid) {
    return '总评: $wins胜$losses败 $points/$bid分 大胜';
  }

  @override
  String trickEventSummaryWin(int wins, int losses, int points, int bid) {
    return '总评: $wins胜$losses败 $points/$bid分 胜利';
  }

  @override
  String trickEventSummaryNarrowLoss(
    int wins,
    int losses,
    int points,
    int bid,
  ) {
    return '总评: $wins胜$losses败 $points/$bid分 惜败';
  }

  @override
  String trickEventSummaryBigLoss(int wins, int losses, int points, int bid) {
    return '总评: $wins胜$losses败 $points/$bid分 大败';
  }

  @override
  String get summaryJokerCounter => '小丑反击';

  @override
  String get summaryJokerUse => '小丑发挥';

  @override
  String get summaryWasteExploit => '弃牌攻略成功';

  @override
  String get summaryTrumpDominate => '将牌掌控';

  @override
  String get summaryFriendContrib => '朋友活跃';

  @override
  String get summaryLateDefense => '后半防御成功';

  @override
  String get summaryDefenseCut => '守方将牌切入';

  @override
  String get summaryMightyImpact => 'Mighty发挥';

  @override
  String get summaryJokerMightyNoExtra => '小丑/至尊追加得分不足';

  @override
  String get summaryJokerMightyLost => '小丑/至尊仍得分不足';

  @override
  String get summaryDefenseHighValueBlock => '守方拦截高分墩，攻方得分不足';

  @override
  String get summaryEarlyLeadLostLate => '前期失去先手，夺回延迟，小丑/至尊效果受限';

  @override
  String get summaryLateLeadLostGirudaExhaust => '将牌/盟友过早耗尽，后期失去先手';

  @override
  String get summaryEarlyCutMightyExtract => '早期切牌+至尊被迫出牌致命损失';

  @override
  String get summaryNineWinWasteFail => '总评 : 9墩善战，弃牌处理失败未能完成横扫';

  @override
  String get summaryNineWinRunMiss => '总评 : 9墩善战 / 横扫差一墩';

  @override
  String get summaryNineWinFirstTrickCut => '总评 : 9墩善战 / 首墩将牌截断(低概率)差一墩横扫';

  @override
  String get summaryDefenseJokerGirudaCounter => '防守小丑攻势 → 将牌反击';

  @override
  String summaryNarrative(String events, String result) {
    return '总评 : $events → $result';
  }

  @override
  String get summaryResultBigWin => '攻方大胜';

  @override
  String get summaryResultMinGoal => '最低目标达成';

  @override
  String get summaryResultWin => '攻方成功';

  @override
  String get summaryResultNarrowLoss => '守方胜利';

  @override
  String get summaryResultBigLoss => '守方大胜';

  @override
  String get summaryAnd => '与';

  @override
  String summaryFallback(
    int wins,
    int losses,
    int points,
    int bid,
    String result,
  ) {
    return '总评 : $wins胜$losses负 → $points/$bid分 $result';
  }

  @override
  String get trickEventLastCardDefenseWin => '守方高牌防御';

  @override
  String get trickEventLastDefenseTopProtectFail => '守方最高牌保护防御但防守失败';

  @override
  String get trickEventLastCardAttackWin => '攻方得分获取';

  @override
  String get trickEventJokerLead => 'Joker首攻';

  @override
  String trickEventJokerLeadSuit(String suit) {
    return 'Joker首攻 ($suit)';
  }

  @override
  String get trickEventJokerGirudaExhaust => '诱导守方消耗将牌';

  @override
  String get trickEventMightyLead => 'Mighty首攻';

  @override
  String get trickEventTopGirudaLead => '将牌最高首攻';

  @override
  String get trickEventTopGirudaLeadOpponentExhausted =>
      '对方无将牌 → 出非将牌攻略，将牌留作切入用';

  @override
  String get trickEventMidGirudaMightyBait => '中位将牌诱导Mighty';

  @override
  String trickEventMidGirudaMightyBaitForTop(String topCard) {
    return '为$topCard最高位确保用低位将牌诱导Mighty';
  }

  @override
  String get trickEventMidGirudaPassLead => '中位将牌让先';

  @override
  String get trickEventFriendAttackDeclarerReOvertake =>
      '朋友进攻 → 防守逆转尝试 → 庄家再逆转（幸运）';

  @override
  String trickEventGirudaDepletionFail(String card) {
    return '$card 清除失败';
  }

  @override
  String get trickEventDefenderGirudaWin => '守方将牌胜';

  @override
  String get trickEventMidGirudaLead => '中位将牌首攻';

  @override
  String get trickEventMidGirudaExhaust => '将牌消耗诱导';

  @override
  String get trickEventSoleGirudaLeadMaintain => '进攻独占将牌，保持先手';

  @override
  String get trickEventTopNonGirudaLead => '非将牌最高首攻';

  @override
  String get trickEventDefenseTopCardDefend => '守方最高牌得分防御';

  @override
  String get trickEventDefenseHighCardDefend => '守方高牌得分防御';

  @override
  String get trickEventJokerAttackReclaim => '小丑夺回攻击方先手';

  @override
  String get trickEventMightyAttackReclaim => '王牌夺回攻击方先手';

  @override
  String get trickEventAttackReclaim => '攻击方夺回先手';

  @override
  String get trickEventDefenseTopDeclarerCutDefense =>
      '守方最高首攻 → 庄家将牌切 → 守方高将牌防御';

  @override
  String get trickEventDefenseTopDeclarerCutTeamDefense =>
      '守方最高首攻 → 庄家将牌切 → 守方团队将牌防御';

  @override
  String get trickEventDefenseLeadAttackCut => '守方非将牌最高出牌 → 进攻将牌切入夺先';

  @override
  String trickEventDefenseTopAttackCutPointsFailed(int count) {
    return '守方最高首攻 → 庄家将牌切 $count分防御失败';
  }

  @override
  String get trickEventAttackLeadDefenseCut => '进攻非将牌最高出牌 → 守方将牌切入';

  @override
  String get trickEventTopNonGirudaLeadDefended => '非将牌出牌 → 守方高牌防御';

  @override
  String get trickEventFirstTrickTopAttack => '首墩 非将牌最高出牌';

  @override
  String get trickEventFirstTrickTopTeamRescue => '首墩 非将牌最高 → 队友逆转';

  @override
  String get trickEventFirstTrickTopAttackFailed => '首墩 非将牌最高出牌 失败';

  @override
  String get trickEventFirstTrickMightyBait => '首墩缺牌 / Mighty搭档诱导';

  @override
  String get trickEventFirstTrickFriendBait => '首墩缺牌弃牌 → 幸好盟友获胜';

  @override
  String get trickEventFirstTrickWaste => '首墩缺牌 / 弃牌';

  @override
  String get trickEventAttackFailed => '攻击失败 → 败于守方高牌';

  @override
  String trickEventAttackFailedWithTop(String topCard) {
    return '攻击 ($topCard 最高) 失败 → 败于守方';
  }

  @override
  String get trickEventWaste => '弃牌让先手';

  @override
  String get trickEventWasteAttackFailed => '弃牌攻击失败';

  @override
  String get trickEventPreExchange => '先手交换 (保留王牌)';

  @override
  String get trickEventPreExchangeKept => '先手交换 (保留王牌) → 先手维持';

  @override
  String get trickEventFriendPassLeadFailed => '传递先手失败';

  @override
  String get trickEventDefenseLead => '防守先攻';

  @override
  String trickEventWasteWithTop(String topCard) {
    return '弃牌 ($topCard 最高)';
  }

  @override
  String get trickEventWasteDeclarerReclaim => '弃牌 → 庄家夺回先手';

  @override
  String trickEventWasteDeclarerReclaimWithTop(String topCard) {
    return '弃牌 ($topCard 最高) → 庄家夺回先手';
  }

  @override
  String get trickEventFriendWasteDeclarerCutDefenseOvercut =>
      '朋友垫牌 → 庄家将牌切 → 守方高将牌逆转';

  @override
  String trickEventFriendWasteDeclarerCutDefenseOvercutPoints(int count) {
    return '朋友垫牌 → 庄家将牌切 → 守方高将牌逆转 防御$count分';
  }

  @override
  String get trickEventFriendWasteDeclarerHighDefenseReversal =>
      '盟友垫牌 → 庄家高牌 → 防守逆转';

  @override
  String get trickEventDefenseWasteAttackReverseDefenseCut =>
      '防守垫牌 → 进攻逆转 → 防守切牌再逆转';

  @override
  String get trickEventFriendLeadDefenseBeatDeclarerCut =>
      '朋友先攻 → 守方逆转 → 庄家将牌再逆转';

  @override
  String get trickEventDeclarerFriendLure => '朋友诱导';

  @override
  String get trickEventDeclarerFriendLureFailed => '朋友诱导失败';

  @override
  String trickEventFriendLureGirudaExhaust(String card) {
    return '守方将牌$card消耗成功';
  }

  @override
  String get trickEventWasteFriendRescue => '弃牌 → 朋友救场!';

  @override
  String trickEventWasteFriendRescueWithTop(String topCard) {
    return '弃牌 ($topCard 最高) → 朋友救场!';
  }

  @override
  String get trickEventFriendMightyReclaim => '弃牌 → 朋友用至尊夺回先手';

  @override
  String trickEventFriendMightyReclaimWithTop(String topCard) {
    return '弃牌 ($topCard 最高) → 朋友用至尊夺回先手';
  }

  @override
  String get trickEventAttackGirudaCut => '攻方将牌切入';

  @override
  String trickEventAttackGirudaCutCount(int count) {
    return '攻方将牌切入 $count次';
  }

  @override
  String get trickEventSameTeamGirudaCut => '同队将牌切入（不可避免）';

  @override
  String get trickEventDefenseGirudaCut => '守方将牌切入';

  @override
  String trickEventDefenseGirudaCutCount(int count) {
    return '守方将牌切入 $count次';
  }

  @override
  String get trickEventDefenseCutAttackOvercut => '守方首次切入 → 攻方高阶将牌反切';

  @override
  String get trickEventAttackCutDefenseOvercut => '攻方首次切入 → 守方高阶将牌防御';

  @override
  String get trickEventAttackNoGirudaDefenseHas => '进攻方将牌耗尽 / 仅守方持有将牌';

  @override
  String get trickEventNonGirudaExhaust => '非将牌消耗';

  @override
  String get trickEventJokerCallDeclared => '小丑召唤宣言';

  @override
  String get trickEventJokerCallAllyJoker => '己方小丑献出';

  @override
  String get trickEventJokerCallEnemyJoker => '对方小丑消耗';

  @override
  String get trickEventGirudaKExhaustSuccess => 'K消耗成功';

  @override
  String get trickEventGirudaKQExhaustSuccess => 'K/Q同时消耗 大成功';

  @override
  String get trickEventDefenseJokerRunBlock => '守方Joker阻止全胜';

  @override
  String get trickEventDefenseJokerCounterattack => 'Mighty消失 → 守方小丑反击';

  @override
  String get trickEventDefenseMightyExhaust => '防守逼出Mighty成功';

  @override
  String get trickEventDefenseMightySuitBait => 'Mighty花色出牌 (Mighty诱导)';

  @override
  String get trickEventDefenseMightySuitBaitSuccess =>
      'Mighty花色出牌 / Mighty诱导成功';

  @override
  String get trickEventDefenseMightySuitBaitFailed =>
      'Mighty花色出牌 / Mighty诱导失败 (攻击方夺回先手)';

  @override
  String trickEventDefenseMightyExhaustPoints(int count) {
    return '防守逼出Mighty，流失$count分';
  }

  @override
  String trickEventJokerAfterFriend(String suit) {
    return '朋友合流后王牌 ($suit) → 得分';
  }

  @override
  String get trickEventJokerAfterFriendGeneral => '朋友合流后王牌 → 得分';

  @override
  String get trickEventGirudaQReclaimSuccess => '将牌Q → 夺回出牌权成功';

  @override
  String get trickEventGirudaQReclaimFail => '将牌Q夺回失败，防守胜';

  @override
  String get trickEventHighCardAttack => '非将牌最高先攻';

  @override
  String get trickEventHighCardAttackFailed => '高牌攻击失败';

  @override
  String trickResultAttack(int count) {
    return '→ 攻方 +$count';
  }

  @override
  String trickResultDefense(int count) {
    return '→ 守方 +$count';
  }

  @override
  String get trickResultNoScore => '→ 无得分';

  @override
  String get trickMightyAppeared => 'Mighty出现';

  @override
  String get trickJokerAppeared => '小丑出现';

  @override
  String get trickFriendJoined => '朋友合流';

  @override
  String get trickEventFriendTopCardWin => '朋友最高牌胜利';

  @override
  String get trickEventFriendGirudaKDeclarerA => '朋友王牌K胜利，庄家持有A，攻击队王牌掌控';

  @override
  String trickEventFriendTrickContribution(int count) {
    return '朋友助攻$count墩攻击成功';
  }

  @override
  String trickEventJokerSkipNoPoints(String name) {
    return '$name: Joker保有，无得分墩跳过';
  }

  @override
  String trickEventGirudaAceHeldMightyGuard(String name) {
    return '$name: 王牌A保有，警惕Mighty未使用';
  }

  @override
  String trickEventGirudaAceHeld(String name) {
    return '$name: 王牌A保有，未使用';
  }

  @override
  String estimatedMinWins(int count) {
    return '→ 预计$count胜以上';
  }

  @override
  String stepFirstAce(String card) {
    return '用$card保持首墩先手';
  }

  @override
  String stepFirstKing(String card) {
    return '用$card保持首墩先手（至尊花色最高）';
  }

  @override
  String get stepFirstMighty => '用至尊确保首墩先手';

  @override
  String get stepFirstJoker => '用王牌确保首墩先手';

  @override
  String stepJokerCallExhaust(String card) {
    return '首墩成功后用$card叫王牌 → 消耗小丑';
  }

  @override
  String stepGirudaAce(String card) {
    return '用$card进行将牌攻击';
  }

  @override
  String stepGirudaAceCheckK(String card) {
    return '用$card进行将牌攻击（确认K消耗）';
  }

  @override
  String stepGirudaKing(String card) {
    return '用$card追加将牌攻击';
  }

  @override
  String stepJokerCallGiruda(String suit) {
    return 'K未消耗时，用王牌叫$suit引出K';
  }

  @override
  String get stepJokerAfterFriend => '朋友合流后用王牌得分';

  @override
  String get stepFriendMightyJoin => '至尊朋友 → 首墩合流';

  @override
  String get stepFriendJokerJoin => '王牌朋友 → 将牌引领时自然合流';

  @override
  String stepLowGirudaFriendLure(
    String highCards,
    String card,
    String mightyCard,
  ) {
    return '$highCards未出现时，用$card引诱至尊($mightyCard)同时进行将牌攻击';
  }

  @override
  String stepGirudaQReclaim(String card) {
    return '用$card夺回出牌权';
  }

  @override
  String stepGirudaLeadFriend(String friendCard) {
    return '将牌引领引出$friendCard';
  }

  @override
  String stepJokerCallFriend(String friendCard) {
    return '$friendCard未出现时，用王牌叫将牌引诱朋友';
  }

  @override
  String stepLureWithGiruda(String card, String friendCard) {
    return '仍未出现时，用$card引诱朋友($friendCard)';
  }

  @override
  String stepSuitLeadFriend(String card, String friendCard) {
    return '用$card引领引诱朋友($friendCard)';
  }

  @override
  String stepJokerCall(String suits) {
    return '用王牌叫$suits确保得分牌';
  }

  @override
  String get stepJokerOptimal => '在最佳时机使用王牌获得分数';

  @override
  String stepHighCardAttack(String cards) {
    return '用$cards获得额外分数';
  }

  @override
  String get stepMightyTiming => '将牌消耗后使用至尊确保赢墩';

  @override
  String stepVoidCut(String suits) {
    return '利用$suits缺门进行将牌切入得分';
  }

  @override
  String get stepEndgameScoring => '通过间（カン）尽量获得更多分数';

  @override
  String get breakdownLowCards => '低牌';

  @override
  String breakdownGirudaPart(
    String suit,
    String top,
    int count,
    String tricks,
  ) {
    return '$suit$top($count张) $tricks墩';
  }

  @override
  String breakdownMightyJokerPart(String tricks) {
    return '王牌+小丑 $tricks墩';
  }

  @override
  String breakdownMightyPart(String tricks) {
    return '王牌 $tricks墩';
  }

  @override
  String breakdownJokerPart(String tricks) {
    return '小丑 $tricks墩';
  }

  @override
  String breakdownAcePart(String suit, String tricks) {
    return '${suit}A $tricks墩';
  }

  @override
  String breakdownFriendMightyPart(String suit, String tricks) {
    return '盟友(${suit}A) $tricks墩';
  }

  @override
  String breakdownFriendJokerPart(String tricks) {
    return '盟友(小丑) $tricks墩';
  }

  @override
  String suitChangeRecommend(String suit, int diff) {
    return '$suit +$diff分 (变更罚分 +2)';
  }

  @override
  String suitKeepRecommend(String suit, int diff) {
    return '$suit +$diff分 (考虑罚分后维持更合适)';
  }
}
