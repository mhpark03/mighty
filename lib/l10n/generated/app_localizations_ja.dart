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
  String get tricks => '目標点数';

  @override
  String get giruda => '切り札';

  @override
  String get noGiruda => 'ノーギルダ';

  @override
  String get spade => 'スペード';

  @override
  String get diamond => 'ダイヤ';

  @override
  String get heart => 'ハート';

  @override
  String get club => 'クラブ';

  @override
  String get spadeName => 'スペード';

  @override
  String get diamondName => 'ダイヤ';

  @override
  String get heartName => 'ハート';

  @override
  String get clubName => 'クラブ';

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
  String get declarerTeam => '宣言者チーム';

  @override
  String get defenderTeam => '守備チーム';

  @override
  String get fullPoints => 'フル';

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
  String get score => '得点';

  @override
  String points(int points) {
    return '$points点';
  }

  @override
  String get player => 'プレイヤー';

  @override
  String get you => 'あなた';

  @override
  String get bidding => 'ビッド中...';

  @override
  String get waiting => '待機';

  @override
  String get otherPlayerTurn => '他のプレイヤーの番です';

  @override
  String get yourCards => 'あなたのカード';

  @override
  String get biddingTurn => 'ビッドの番';

  @override
  String bidWithAmount(int amount) {
    return 'ビッド $amount';
  }

  @override
  String trickComplete(int number) {
    return 'トリック $number 完了';
  }

  @override
  String winnerAnnouncement(String name, String team) {
    return '$name 勝利! ($team)';
  }

  @override
  String get attackTeam => '攻撃';

  @override
  String get defenseTeam => '守備';

  @override
  String get nextTrick => '次のトリック';

  @override
  String get friendNone => 'なし';

  @override
  String get firstTrick => '初トリック';

  @override
  String get selectCardHint => 'カードを選んでください ↓';

  @override
  String get previousTrick => '前のトリック';

  @override
  String get winShort => '勝';

  @override
  String get leadPlayer => 'リード';

  @override
  String get leadPlayerHint => '👆 あなたがリードです!';

  @override
  String get selectCardBelow => '下からカードを選んでください';

  @override
  String get leadPlayerSelectCard => '👆 リードです! カードを選んでください';

  @override
  String jokerCallAnnouncement(String suit) {
    return 'ジョーカーコール! $suit';
  }

  @override
  String get wonCards => '獲得:';

  @override
  String get jokerCallTitle => 'ジョーカーコール';

  @override
  String jokerCallQuestion(String suit) {
    return '$suit ジョーカーコールを宣言しますか?';
  }

  @override
  String get no => 'いいえ';

  @override
  String jokerCallButton(String suit) {
    return '$suit ジョーカーコール!';
  }

  @override
  String get jokerLeadSuitTitle => 'ジョーカーリード';

  @override
  String get jokerLeadSuitQuestion => '他のプレイヤーが従うスートを選んでください';

  @override
  String get allPassedTitle => '全員パス';

  @override
  String get allPassedMessage => '全員がパスしました。\n新しいゲームを開始します。';

  @override
  String get girudaChangeWarning => '切り札変更時: 目標+2';

  @override
  String get keep => '維持';

  @override
  String get aiRecommendation => 'AIおすすめ';

  @override
  String get discardCards => '捨てるカード:';

  @override
  String get goalPlus2 => '(目標+2)';

  @override
  String get applyRecommendation => '適用';

  @override
  String nthTrickShort(int n) {
    return '$nトリック';
  }

  @override
  String get recommendedFriend => 'おすすめ:';

  @override
  String get joker => 'ジョーカー';

  @override
  String get mighty => 'マイティ';

  @override
  String get recommendNoFriend => 'ノーフレンドおすすめ';

  @override
  String get reasonHasMighty => 'マイティ所持';

  @override
  String get reasonHasJoker => 'ジョーカー所持';

  @override
  String get reasonNeedMighty => 'マイティ必要';

  @override
  String get reasonNeedJoker => 'ジョーカー必要';

  @override
  String get reasonNeedGirudaAce => '切り札A必要';

  @override
  String get reasonNeedGirudaKing => '切り札K必要';

  @override
  String get reasonStrongHand => '強い手札';

  @override
  String get continueGame => '続ける';

  @override
  String get exitGame => 'ゲーム終了';

  @override
  String get exitGameConfirm => 'ゲームを終了しますか?\n現在のゲームは保存されます。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get exit => '終了';

  @override
  String get savedGame => '保存されたゲーム';

  @override
  String get noSavedGame => '保存されたゲームがありません';

  @override
  String get recommendedCard => 'おすすめ';

  @override
  String get showRecommendation => 'ヒント表示';

  @override
  String get playerStats => 'プレイヤー統計';

  @override
  String get winLoss => '勝/敗';

  @override
  String get totalScore => '合計';

  @override
  String get win => '勝';

  @override
  String get loss => '敗';

  @override
  String get resetStats => 'リセット';

  @override
  String get resetStatsConfirm => '広告を視聴すると、すべての統計がリセットされます。\n続行しますか?';

  @override
  String get exitApp => 'アプリ終了';

  @override
  String get exitAppConfirm => 'アプリを終了しますか?';

  @override
  String get gameGuide => '遊び方';

  @override
  String get guideOverview => 'ゲーム概要';

  @override
  String get guideOverviewText =>
      'マイティは5人で遊ぶトリックテイキングカードゲームです。宣言者(1人)とフレンド(1人)がチームを組み、守備チーム(3人)と対戦します。';

  @override
  String get guideBidding => 'ビッディング';

  @override
  String get guideBiddingText =>
      '• 各プレイヤーは獲得する得点カードの数を宣言します\n• 最高ビッドのプレイヤーが宣言者になります\n• 宣言者は切り札を決めます';

  @override
  String get guideSpecialCards => '特殊カード';

  @override
  String get guideSpecialCardsText =>
      '• マイティ: スペードのA (最強のカード)\n• ジョーカー: 2番目に強いカード\n• 切り札: 宣言者が選んだスート';

  @override
  String get guideFriend => 'フレンド';

  @override
  String get guideFriendText =>
      '• 宣言者は特定のカードを持つ人をフレンドに指定します\n• フレンドは正体を隠すことができます\n• ジョーカーコール: 特定の3を持つ人をフレンドに指定';

  @override
  String get guideScoring => 'スコア計算';

  @override
  String get guideScoringText =>
      '• 得点カード: A, K, Q, J, 10 (各1点、合計20点)\n• 宣言者チームが目標点数以上で勝利\n• 勝者は+点、敗者は-点';

  @override
  String get guideTips => 'ゲームのコツ';

  @override
  String get guideTipsText =>
      '• マイティとジョーカーは常に強力です\n• 切り札を上手く使いましょう\n• フレンドの正体を見抜くことが重要です';

  @override
  String get close => '閉じる';

  @override
  String get dealMiss => 'ディールミス';

  @override
  String get dealMissTitle => 'ディールミス宣言';

  @override
  String get dealMissConfirm => 'ディールミスを宣言しますか?\n手札を公開して新しく始めます。';

  @override
  String dealMissAnnouncement(String name) {
    return '$name ディールミス宣言!';
  }

  @override
  String get dealMissNewGame => 'ディールミスでゲームを再開します。';

  @override
  String get aiPlayer1 => '太郎';

  @override
  String get aiPlayer2 => '花子';

  @override
  String get aiPlayer3 => '健太';

  @override
  String get aiPlayer4 => '美咲';

  @override
  String get scoreCalcWin => 'スコア計算 (勝利)';

  @override
  String get scoreCalcLose => 'スコア計算 (敗北)';

  @override
  String get scoreFormula => '(得点-契約+1) + (得点-最小)×2';

  @override
  String get scoreFormulaLose => '-(契約 - 得点)';

  @override
  String get scoreMultipliers => '宣言者 ×2, フレンド ×1, 守備 ×(-1)';

  @override
  String get multiplierRun => 'ラン ×2';

  @override
  String get multiplierNoGiruda => 'ノートランプ ×2';

  @override
  String get multiplierNoFriend => 'ノーフレンド ×2';

  @override
  String get multiplierBackRun => 'バックラン ×2';

  @override
  String get multiplierLabel => '倍率';

  @override
  String get selectGame => 'ゲーム選択';

  @override
  String get sevenCardTitle => 'セブンポーカー';

  @override
  String get sevenCardSubtitle => '7枚カードポーカーゲーム';

  @override
  String get sevenCardRules => 'ゲームルール';

  @override
  String get sevenCardRulesText =>
      '• 各プレイヤーは7枚のカードを受け取ります\n• 最初の3枚は非公開、残り4枚は公開\n• ベッティングラウンドを経て最終5枚で役を作ります\n• 最も高い役を持つプレイヤーが勝利';

  @override
  String get pot => 'ポット';

  @override
  String get currentBet => '現在のベット';

  @override
  String get betting => 'ラウンド';

  @override
  String get chips => 'チップ';

  @override
  String get bet => 'ベット';

  @override
  String get fold => 'ダイ';

  @override
  String get call => 'コール';

  @override
  String get raise => 'レイズ';

  @override
  String get check => 'チェック';

  @override
  String get allIn => 'オールイン';

  @override
  String get folded => 'ダイ';

  @override
  String get wins => '勝利';

  @override
  String get gameEnd => 'ゲーム終了';

  @override
  String get hiLoTitle => 'ハイロー';

  @override
  String get hiLoSubtitle => 'ハイ/ロースプリットポーカー';

  @override
  String get hi => 'ハイ';

  @override
  String get lo => 'ロー';

  @override
  String get swing => 'スイング';

  @override
  String get selectHiLo => 'ハイ/ロー選択';

  @override
  String get selectHiLoDesc => 'ハイ、ロー、またはスイングを選択';

  @override
  String get hiWinner => 'ハイ勝者';

  @override
  String get loWinner => 'ロー勝者';

  @override
  String get swingSuccess => 'スイング成功！';

  @override
  String get swingFailed => 'スイング失敗';

  @override
  String get hiPot => 'ハイポット';

  @override
  String get loPot => 'ローポット';

  @override
  String get noLowHand => 'ローなし';

  @override
  String get bestLow => 'ベストロー';

  @override
  String get waitingForHiLo => '選択待ち...';

  @override
  String get selectedHi => 'ハイ選択';

  @override
  String get selectedLo => 'ロー選択';

  @override
  String get selectedSwing => 'スイング選択';

  @override
  String get showdownTitle => '宣言状況';

  @override
  String get showdownDesc => '各プレイヤーの選択を確認してください';

  @override
  String get viewResults => '結果を見る';

  @override
  String get finalResults => '最終結果';

  @override
  String get sevenCardGuideOverview => 'ゲーム概要';

  @override
  String get sevenCardGuideOverviewText =>
      'セブンカードポーカーは5人でプレイするポーカーゲームです。7枚のカードから5枚で最高の役を作って勝利しましょう。';

  @override
  String get sevenCardGuideDealing => 'カード配布';

  @override
  String get sevenCardGuideDealingText =>
      '• 最初に4枚を受け取ります（3枚伏せ、1枚オープン）\n• ベッティング後に1枚ずつオープンカードを受け取ります\n• 最終的に7枚から5枚で役を作ります';

  @override
  String get sevenCardGuideBetting => 'ベッティングルール';

  @override
  String get sevenCardGuideBettingText =>
      '• チェック: ベットなしでパス\n• コール: 現在のベットに合わせる\n• レイズ: ベット額を上げる\n• ダイ: ゲームを降りる\n• オールイン: 全チップをベット';

  @override
  String get sevenCardGuideHands => '役のランキング';

  @override
  String get sevenCardGuideHandsText =>
      '1. ロイヤルストレートフラッシュ\n2. バックストレートフラッシュ\n3. ストレートフラッシュ\n4. フォーカード\n5. フルハウス\n6. フラッシュ\n7. マウンテン (A-K-Q-J-10)\n8. バックストレート (A-2-3-4-5)\n9. ストレート\n10. スリーカード\n11. ツーペア\n12. ワンペア\n13. ハイカード';

  @override
  String get sevenCardGuideTips => 'ゲームのコツ';

  @override
  String get sevenCardGuideTipsText =>
      '• オープンカードから相手の役を予測しましょう\n• 強い手でなければ過度なベットを避けましょう\n• ブラフも戦略です';

  @override
  String get sevenCardGuideBonus => 'ボーナスハンド';

  @override
  String get sevenCardGuideBonusText =>
      '• ロイヤルストレートフラッシュ: 500チップ\n• バックストレートフラッシュ: 300チップ\n• ストレートフラッシュ: 200チップ\n• フォーカード: 100チップ\n\nボーナスハンド達成時、他の全プレイヤーからボーナスを獲得！';

  @override
  String get hiLoGuideOverview => 'ゲーム概要';

  @override
  String get hiLoGuideOverviewText =>
      'ハイローはセブンカードポーカーの変形で、ポットがハイ（高い役）とロー（低い役）の勝者に分けられます。';

  @override
  String get hiLoGuideDealing => 'カード配布';

  @override
  String get hiLoGuideDealingText =>
      '• セブンカードポーカーと同じ方式で進行\n• 7枚のカードから5枚で役を作ります\n• 最後のベット後にハイ/ロー/スイングを選択';

  @override
  String get hiLoGuideHiLo => 'ハイ/ロー選択';

  @override
  String get hiLoGuideHiLoText =>
      '• ハイ: 最高の役で競争\n• ロー: 最低の役で競争\n• スイング: ハイとロー両方に挑戦\n\nポットの50%はハイ勝者、50%はロー勝者が獲得。';

  @override
  String get hiLoGuideLow => 'ロー役のルール';

  @override
  String get hiLoGuideLowText =>
      '• ストレート/フラッシュのない手のみ資格あり\n• 低いほど良い（Aが最低）\n• 最強ロー: A-2-3-4-6\n• ペアなしの手が有利';

  @override
  String get hiLoGuideSwing => 'スイングルール';

  @override
  String get hiLoGuideSwingText =>
      '• 7枚を2つの5枚の手に分けます\n• ハイとロー両方で1位になる必要があります\n• 成功: ポット全体を獲得\n• 失敗: その部分は他の勝者へ';

  @override
  String get hiLoGuideTips => 'ゲームのコツ';

  @override
  String get hiLoGuideTipsText =>
      '• A-2-3-4のような低いカードはローに有利\n• スイングはリスクがありますが成功すれば大きな報酬\n• 相手のカードを見て戦略を立てましょう';

  @override
  String get hiLoGuideBonus => 'ボーナスハンド';

  @override
  String get hiLoGuideBonusText =>
      '• ロイヤルストレートフラッシュ: 500チップ\n• バックストレートフラッシュ: 300チップ\n• ストレートフラッシュ: 200チップ\n• フォーカード: 100チップ\n\nボーナスハンド達成時、自動的にポット全体を獲得！';

  @override
  String get hulaTitle => 'フラ';

  @override
  String get hulaSubtitle => '4人用ラミーカードゲーム';

  @override
  String get heartsTitle => 'ハーツ';

  @override
  String get heartsSubtitle => '4人トリックテイキングゲーム';

  @override
  String get handRoyalStraightFlush => 'ロイヤルストレートフラッシュ';

  @override
  String get handBackStraightFlush => 'バックストレートフラッシュ';

  @override
  String get handStraightFlush => 'ストレートフラッシュ';

  @override
  String get handFourOfAKind => 'フォーカード';

  @override
  String get handFullHouse => 'フルハウス';

  @override
  String get handFlush => 'フラッシュ';

  @override
  String get handMountain => 'マウンテン';

  @override
  String get handBackStraight => 'バックストレート';

  @override
  String get handStraight => 'ストレート';

  @override
  String get handTriple => 'スリーカード';

  @override
  String get handTwoPair => 'ツーペア';

  @override
  String get handOnePair => 'ワンペア';

  @override
  String get handHighCard => 'ハイカード';

  @override
  String highCardTop(String rank) {
    return '$rankトップ';
  }

  @override
  String get noLow => 'ローなし';

  @override
  String get betPing => 'ピン';

  @override
  String get betCheck => 'チェック';

  @override
  String get betCall => 'コール';

  @override
  String get betDdadang => 'ダブル';

  @override
  String get betQuarter => 'クォーター';

  @override
  String get betHalf => 'ハーフ';

  @override
  String get betFull => 'フル';

  @override
  String get betDie => 'ダイ';

  @override
  String get selectOpenCard => '公開するカードを選んでください';

  @override
  String get selectOpenCardDesc => '選んだカードが相手に公開されます';

  @override
  String get aiSelectingCard => 'AIがカードを選んでいます...';

  @override
  String nthCard(int n) {
    return '$n枚目のカード';
  }

  @override
  String secondsCount(int n) {
    return '$n秒';
  }

  @override
  String totalBetAmount(int amount) {
    return '合計: $amount';
  }

  @override
  String bettingAmount(int amount) {
    return 'ベット: $amount';
  }

  @override
  String get bonusHand => 'ボーナスハンド！';

  @override
  String get bonus => 'ボーナス';

  @override
  String get total => '合計';

  @override
  String otherPlayersLose(int amount) {
    return '他のプレイヤー: 各 -$amount';
  }

  @override
  String get thisGame => '今回のゲーム';

  @override
  String get cumulative => '累計';

  @override
  String get foldedSection => 'ダイ';

  @override
  String get hiLoHi => 'ハイ';

  @override
  String get hiLoLo => 'ロー';

  @override
  String get hiLoSwing => 'スイング';

  @override
  String roundComplete(int n) {
    return 'ラウンド $n 完了！';
  }

  @override
  String get cardDistribution5 => '5枚目のカードが配られます。';

  @override
  String get cardDistribution6 => '6枚目のカードが配られます。';

  @override
  String get cardDistribution7 => '最後の7枚目のカードが配られます。';

  @override
  String get goodLuck => 'グッドラック！';

  @override
  String cardCount(int count) {
    return '$count枚';
  }

  @override
  String get suitSpade => 'スペード';

  @override
  String get suitDiamond => 'ダイヤ';

  @override
  String get suitHeart => 'ハート';

  @override
  String get suitClub => 'クラブ';

  @override
  String cardOwner(String card) {
    return '$card所有者';
  }

  @override
  String trickWinner(int n) {
    return '$n番目のトリック獲得者';
  }

  @override
  String get hint => 'ヒント';

  @override
  String get hintOff => 'ヒント OFF';

  @override
  String get hintDialogContent => '広告を見るとヒントが有効になります。\n続けますか？';

  @override
  String get newGameDialogContent => '広告を見ると新しいゲームを開始します。\n続けますか？';

  @override
  String get watchAd => '広告を見る';

  @override
  String jokerLead(String suit) {
    return 'ジョーカー先攻: $suit';
  }

  @override
  String get gameSelection => 'ゲーム選択';

  @override
  String get onecardTitle => 'ワンカード';

  @override
  String get onecardSubtitle => '4人対戦';

  @override
  String get gameRules => 'ゲームルール';

  @override
  String get heartsGuideGoal => '目標';

  @override
  String get heartsGuideGoalText => 'ハートカードとスペードのクイーンを避けて最低得点を目指します。';

  @override
  String get heartsGuideHow => '遊び方';

  @override
  String get heartsGuideHowText =>
      '• 4人でプレイし、各自13枚を受け取ります\n• ゲーム開始時に3枚を左のプレイヤーに渡します\n• クラブの2を持つプレイヤーが最初に開始\n• 13トリックを行い、得点カードを避けます';

  @override
  String get heartsGuideScoring => '得点計算';

  @override
  String get heartsGuideScoringText =>
      '• ハートカード: 各1点 (計13点)\n• スペードのクイーン (♠Q): 13点\n• 合計: 26点\n• 低い得点が勝利！';

  @override
  String get heartsGuideBreaking => 'ハートブレイク';

  @override
  String get heartsGuideBreakingText =>
      '最初のトリックではハートを出せません。\nハートが一度出た後にハートでリードできます。';

  @override
  String get heartsGuideShootMoon => 'シューティング・ザ・ムーン';

  @override
  String get heartsGuideShootMoonText =>
      '一人のプレイヤーが全てのハートとスペードのクイーンを獲得すると:\n• そのプレイヤー: 0点\n• 他のプレイヤー: 各26点';

  @override
  String get heartsGuideTips => '戦略のコツ';

  @override
  String get heartsGuideTipsText =>
      '• 高いカードは早く捨てましょう\n• スペードのクイーンに注意\n• 相手に得点カードを取らせましょう';

  @override
  String get allScoreCardsUsed => '全得点カード消化！ゲーム終了';

  @override
  String passLeftCount(int count) {
    return '左へパス ($count/3)';
  }

  @override
  String get cardPass => 'カードパス';

  @override
  String trickProgress(int current) {
    return 'トリック $current/13';
  }

  @override
  String get heartBroken => 'ハートブレイク';

  @override
  String get passRecommend => 'パス推奨';

  @override
  String get recommend => '推奨';

  @override
  String get selectCardsToPassLeft => '左に渡す3枚を選択';

  @override
  String playerNameWins(String name) {
    return '$name 勝利';
  }

  @override
  String playerStartsWithClub2(String name) {
    return '$nameがクラブ2で開始';
  }

  @override
  String playerWonTrick(String name, int points) {
    return '$nameがトリック獲得！(+$points点)';
  }

  @override
  String playerShootMoonSuccess(String name) {
    return '$nameがシュートザムーン成功！';
  }

  @override
  String get hintActivated => 'ヒントが有効になりました！';

  @override
  String get myTurn => '自分の番';

  @override
  String get start => '開始';

  @override
  String get counterClockwise => '反時計';

  @override
  String get clockwise => '時計';

  @override
  String get blackJoker => '白黒ジョーカー';

  @override
  String get colorJoker => 'カラージョーカー';

  @override
  String get oneCardCall => 'ワンカード！';

  @override
  String oneCardCallTimer(int seconds) {
    return 'ワンカード ($seconds秒)';
  }

  @override
  String get selectSuit => 'スートを選択してください';

  @override
  String get discardedCards => '捨て札';

  @override
  String get meld => 'メルド';

  @override
  String get discard => '捨てる';

  @override
  String get stop => 'ストップ';

  @override
  String get handCards => '手札';

  @override
  String get cannotPlayCard => 'このカードは出せません';

  @override
  String get drawCard => 'カードを引いてください';

  @override
  String get discardOrMeld => 'カードを捨てるかメルドしてください';

  @override
  String get noCards => 'カードがありません';

  @override
  String get thankYouSelectMethod => 'サンキュー方法を選択';

  @override
  String thankYouMeldSolo(String suit) {
    return 'サンキュー！ ${suit}7 単独メルド';
  }

  @override
  String thankYouMeldMyMeld(String card) {
    return 'サンキュー！ $card を自分のメルドに追加';
  }

  @override
  String thankYouMeldAiMeld(String card, String aiName) {
    return 'サンキュー！ $card を $aiName のメルドに追加';
  }

  @override
  String get addedToMeld => 'メルドに追加しました';

  @override
  String get noMeldToAttach => '追加できるメルドがありません';

  @override
  String get invalidCombination => '無効な組み合わせです';

  @override
  String get drawCardFirst => '先にカードを引いてください';

  @override
  String get selectCardToDiscard => '捨てるカードを選択してください';

  @override
  String get hulaWin => 'フラ勝利！ (x2)';

  @override
  String get continue_ => '続ける';

  @override
  String attackReceived(int count) {
    return '攻撃で$count枚受け取りました';
  }

  @override
  String get cardDrawn => 'カードを引きました';

  @override
  String bankrupt(int count) {
    return '破産！ ($count枚所持)';
  }

  @override
  String get restart => '再スタート';

  @override
  String get goal => '目標';

  @override
  String get howToPlay => '遊び方';

  @override
  String get attackCards => '攻撃カード';

  @override
  String get defense => '防御';

  @override
  String get specialCards => '特殊カード';

  @override
  String get tips => 'コツ';

  @override
  String get winRate => '勝率';

  @override
  String get onecardGuideGoal => '目標';

  @override
  String get onecardGuideGoalText => '手札を最初に全て出し切ることが目標です。';

  @override
  String get onecardGuidePlay => 'カードの出し方';

  @override
  String get onecardGuidePlayText => '前に出されたカードと同じスートまたは同じ数字のカードを出せます。';

  @override
  String get onecardGuideAttack => '攻撃カード';

  @override
  String get onecardGuideAttackText =>
      '• 2: +2枚攻撃\n• A: +3枚攻撃 (♠Aは+5枚)\n• ジョーカー: +5枚(白黒) / +7枚(カラー)';

  @override
  String get onecardGuideSpecial => '特殊カード';

  @override
  String get onecardGuideSpecialText =>
      '• J: 次の順番をスキップ\n• Q: 方向逆転\n• K: 2ターンスキップ\n• 7: スート変更';

  @override
  String get onecardGuideJokerDefense => 'ジョーカー防御';

  @override
  String get onecardGuideJokerDefenseText => 'ジョーカーで攻撃されたらジョーカーでのみ防御できます。';

  @override
  String get onecardGuideOnecard => 'ワンカード!';

  @override
  String get onecardGuideOnecardText =>
      '手札が1枚残ったら「ワンカード!」ボタンを押す必要があります。\n押さないとペナルティで2枚を受け取ります。';

  @override
  String get onecardGuideBankrupt => '破産';

  @override
  String get onecardGuideBankruptText => '手札が20枚以上になると破産！最少カードのプレイヤーが勝利します。';

  @override
  String get hulaGuideGoal => '目標';

  @override
  String get hulaGuideGoalText => '手札のカードを全て登録または捨てて最初になくすことが目標です。';

  @override
  String get hulaGuideHow => '遊び方';

  @override
  String get hulaGuideHowText => '毎ターン、デッキまたは捨て札からカードを1枚引き、登録または捨てます。';

  @override
  String get hulaGuideMelds => 'メルドの種類';

  @override
  String get hulaGuideMeldsText =>
      '• ラン: 同じスートの連続した数字3枚以上 (例: ♠3-4-5)\n• グループ: 同じ数字で異なるスート3枚以上 (例: ♠7-♥7-♦7)';

  @override
  String get hulaGuideSeven => '7の特別ルール';

  @override
  String get hulaGuideSevenText => '7は単独で登録できます。';

  @override
  String get hulaGuideThankYou => 'サンキュー';

  @override
  String get hulaGuideThankYouText => '捨て札から7を引くと「サンキュー」を宣言し、特別な登録ができます。';

  @override
  String get hulaGuideStop => 'ストップ';

  @override
  String get hulaGuideStopText =>
      'いつでもストップを宣言してゲームを終了できます。\n残りカードの点数が最も低い人が勝利します。';

  @override
  String get hulaGuideCardPoints => 'カード点数';

  @override
  String get hulaGuideCardPointsText => 'A=1点, 2~9=数字点, J=10点, Q=11点, K=12点';

  @override
  String get hulaGuideScoring => '得点計算';

  @override
  String get hulaGuideScoringText =>
      '• 勝者: 他プレイヤーとの手札差の合計を獲得\n• 敗者: 勝者との手札差だけ減点\n• フラ(登録なしで勝利): 点数2倍';

  @override
  String get hulaGuideStopPenalty => 'ストップ失敗ペナルティ';

  @override
  String get hulaGuideStopPenaltyText =>
      'ストップを宣言したが最低点でない場合:\n• 勝者が受ける点数を全てストップした人が負担\n• 他のプレイヤーは減点なし';

  @override
  String attackTotalCards(int power, int total) {
    return '+$power! (計$total枚攻撃)';
  }

  @override
  String get skipNextTurnMessage => 'J! 次のターンをスキップ';

  @override
  String get reverseDirectionMessage => 'Q! 方向反転';

  @override
  String get skipTwoTurnsMessage => 'K! 2ターンスキップ';

  @override
  String changeSuitMessage(String suit) {
    return '7! スート変更: $suit';
  }

  @override
  String playerPlayedCard(String name) {
    return '$nameがカードを出しました';
  }

  @override
  String onecardWithPlayers(int count) {
    return 'ワンカード (${count}P)';
  }

  @override
  String get blackWhiteJoker => '白黒ジョーカー';

  @override
  String get clockwiseDirection => '時計回り';

  @override
  String get counterClockwiseDirection => '反時計回り';

  @override
  String aiTurnCountdown(String name, int seconds) {
    return '$name ($seconds)';
  }

  @override
  String aiTurn(String name) {
    return '$nameの番';
  }

  @override
  String get cannotPlayThisCard => 'このカードは出せません';

  @override
  String bankruptWithCards(int count) {
    return '破産! ($count枚所持)';
  }

  @override
  String get gameRulesTitle => 'ゲームルール';

  @override
  String get goalText => '手札を全て出した人が勝利です。\n最後のカードを出す前に「ワンカード」を宣言する必要があります。';

  @override
  String get howToPlayText => '同じスートまたは同じ数字のカードを出せます。\n出せるカードがない場合はデッキから引きます。';

  @override
  String get defenseText => '攻撃されたら同じ攻撃カードで防御できます。\n防御すると攻撃が次の人に累積されます。';

  @override
  String get gameTips => 'ゲームのヒント';

  @override
  String get drawCardMessage => 'カードを引いてください';

  @override
  String get discardOrMeldMessage => 'カードを捨てるか登録してください';

  @override
  String get noCardsMessage => 'カードがありません';

  @override
  String thankYouSolo(String suit) {
    return 'サンキュー! ${suit}7 単独登録';
  }

  @override
  String thankYouAddToMine(String card) {
    return 'サンキュー! $card 自分のメルドに追加';
  }

  @override
  String thankYouAddToAi(String card, String aiName) {
    return 'サンキュー! $card $aiNameのメルドに追加';
  }

  @override
  String thankYouDesc(String desc) {
    return 'サンキュー! $desc';
  }

  @override
  String get drawFirstMessage => '先にカードを引いてください';

  @override
  String get hulaWinBonus => 'フラ勝利! (x2)';

  @override
  String get handColumn => '手札';

  @override
  String get scoreColumn => '得点';

  @override
  String get cumulativeColumn => '累計';

  @override
  String hulaWithPlayers(int count) {
    return 'フラ ($count人)';
  }

  @override
  String hintOnOff(String status) {
    return 'ヒント $status';
  }

  @override
  String get meldButton => '登録';

  @override
  String get discardButton => '捨てる';

  @override
  String get stopButton => 'ストップ';

  @override
  String get thankYouMeld => 'サンキューメルド';

  @override
  String get meldTypes => 'メルドの種類';

  @override
  String get ok => '確認';

  @override
  String aiThankYouDraw(String aiName, String card) {
    return '$aiName サンキュー! $card';
  }

  @override
  String aiDrawsCard(String aiName) {
    return '$aiNameがカードを引く';
  }

  @override
  String aiRegistersSeven(String aiName, String type) {
    return '$aiName: 7 $type登録';
  }

  @override
  String aiRegistersMeld(String aiName, String meldType, String cards) {
    return '$aiName: $meldType登録 $cards';
  }

  @override
  String aiAttachesToMeld(String aiName, String card) {
    return '$aiName: $cardをメルドに追加';
  }

  @override
  String aiAttachesToPlayerMeld(String aiName, String card) {
    return '$aiName: $cardをプレイヤーメルドに追加';
  }

  @override
  String aiAttachesToOtherAiMeld(String aiName, String card, String targetAi) {
    return '$aiName: $cardを$targetAiメルドに追加';
  }

  @override
  String aiDiscards(String aiName, String card) {
    return '$aiName: $cardを捨てる';
  }

  @override
  String get group => 'グループ';

  @override
  String get solo => '単独';

  @override
  String get victory => '勝利!';

  @override
  String get defeat => '敗北';
}
