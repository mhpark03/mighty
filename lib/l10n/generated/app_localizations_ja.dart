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
  String get score => 'スコア';

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
  String get scoreFormula => '(得点-契約) + (得点-最小)×2';

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
}
