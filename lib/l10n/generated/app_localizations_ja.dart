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
  String get receivedKitty => '受け取ったカード:';

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
  String get guideIntro => '1. ゲーム紹介';

  @override
  String get guideIntroText =>
      'マイティは5人で遊ぶトリックテイキングカードゲームです。\nジョーカーを含む53枚のカードを使い、各プレイヤーに10枚ずつ配り、3枚はキティ(場札)として残します。\n\n宣言者(1人)とフレンド(1人)が攻撃チーム、残り3人が守備チームとなります。宣言者チームが公約以上の点数を獲得すれば勝利です。';

  @override
  String get guideGameFlow => '2. ゲーム進行順序';

  @override
  String get guideGameFlowText =>
      '① カード配布 → ② ビッディング → ③ キティ交換 → ④ フレンド宣言 → ⑤ カードプレイ → ⑥ 点数計算\n\n各段階は順番に進行します。全プレイヤーがパスした場合、カードを再配布します。';

  @override
  String get guideBidding => '3. ビッディング';

  @override
  String get guideBiddingText =>
      '獲得できる得点カードの数を宣言します。\n\n• 最低公約: 13点（得点カード全20枚中）\n• 切り札のスートも一緒に宣言\n• ノートランプ: 切り札なしで宣言（同じ数字の切り札宣言より優先）\n• 最も高い公約をしたプレイヤーが宣言者になります\n\n💡 マイティ、ジョーカー、切り札Aがあれば高い公約が可能です。';

  @override
  String get guideKitty => '4. キティ交換';

  @override
  String get guideKittyText =>
      '宣言者はキティの3枚を取り、13枚から3枚を捨てます。\n\n• 弱いカードを捨てて手札を強化します\n• 切り札を変更できます（公約+2追加）\n• 得点カードを捨てることもできますが、守備チームに有利になる可能性があります';

  @override
  String get guideFriend => '5. フレンド宣言';

  @override
  String get guideFriendText =>
      '宣言者がチームメイト（フレンド）を指定します。\n\n• カードフレンド: 特定カードの所有者（例: ♠Aを持つ人）\n• 初手フレンド: 最初のトリックに勝つ人\n• ノーフレンド: 一人で（点数×2）\n\nフレンドは該当カードを出すまで正体が明かされません。守備チームは誰がフレンドか推理する必要があります。';

  @override
  String get guideSpecialCards => '6. 特殊カード';

  @override
  String get guideSpecialCardsText =>
      '♠A マイティ (Mighty)\n最強のカードです。どのカードにも勝ちます。\nただし、ジョーカーコール時は必ず出さなければならず、切り札が♠の場合は♦Aがマイティです。\n\n🃏 ジョーカー (Joker)\nマイティの次に強いカードです。\nリード時にスートを指定でき、初手では効力がありません。\nジョーカーコールされたら必ずジョーカーを出さなければなりません。\n\n切り札\n宣言者が決めたスートのカードです。\n非切り札のスートで切り札を出すと「カット」でトリックに勝ちます。';

  @override
  String get guideJokerCall => '7. ジョーカーコール';

  @override
  String get guideJokerCallText =>
      'リードプレイヤーが特定スートのカードを出しながら「ジョーカーコール」を宣言すると、ジョーカーを持つプレイヤーは必ずジョーカーを出さなければなりません。\n\n• 初手ではジョーカーコール不可\n• ジョーカーコール時、ジョーカーは最も弱いカードになります\n• 守備チームが相手のジョーカーを無力化する核心戦略です';

  @override
  String get guideTrickPlay => '8. トリックプレイ';

  @override
  String get guideTrickPlayText =>
      '10回のトリック（ラウンド）を行います。\n\n• リードプレイヤーがカード1枚を出します\n• 他のプレイヤーは同じスートのカードを出さなければなりません（フォロー）\n• そのスートがなければ任意のカードを出せます\n• 最も強いカードを出したプレイヤーがトリックに勝ち、次のリードになります\n\nカードの強さ順序:\nマイティ > ジョーカー > 切り札(A~2) > リードスート(A~2)';

  @override
  String get guideScoring => '9. 得点カード';

  @override
  String get guideScoringText =>
      '得点カード: A, K, Q, J, 10（各スート5枚×4スート＝20枚）\n各得点カードは1点で、トリックに勝ったプレイヤーが獲得します。\n\n例: トリックに♠A、♠K、♥3、♦7、♣2が出た場合\n→ 得点カード2枚（♠A、♠K）＝ 2点をトリック勝者が獲得';

  @override
  String get guideWinLose => '10. 勝敗と得点計算';

  @override
  String get guideWinLoseText =>
      '宣言者チームが公約以上の点数を獲得すれば勝利です。\n\n勝利時の基本点数:\n• （獲得点数 - 公約）+ 1 + 追加ボーナス\n• ラン（10トリック全勝利）: ボーナス点数\n• ノーフレンド: 点数×2\n• ノートランプ: 点数×2\n\n敗北時:\n• 宣言者は（守備チーム人数×基本点数）分減点\n• バックラン（守備全勝）: 追加減点';

  @override
  String get guideTips => '11. 戦略のコツ';

  @override
  String get guideTipsText =>
      '宣言者の戦略:\n• マイティ/ジョーカー/切り札Aがあれば積極的にビッディングしましょう\n• 序盤に切り札を消耗させて相手のカットを防ぎましょう\n• フレンドと協力して得点カードを集めましょう\n\n守備の戦略:\n• フレンドの正体を早く見抜きましょう\n• ジョーカーコールで相手のジョーカーを無力化しましょう\n• 得点カードを宣言者チームに渡さないよう注意しましょう\n• 切り札カットで相手の非切り札Aを捕まえましょう';

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
  String get scoreMultipliersNoFriend => '宣言者 ×3, 守備 ×(-1)';

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
    return '$card 所有者';
  }

  @override
  String trickWinner(int n) {
    return 'トリック$n 勝者';
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
  String get emptyDiscardPile => '捨て札\nなし';

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

  @override
  String drewCardWithCard(String card) {
    return '$cardを引きました';
  }

  @override
  String playerDiscards(String card) {
    return '$cardを捨てる';
  }

  @override
  String get inPossession => '（所持中）';

  @override
  String get fourPlayerGame => '4人対戦';

  @override
  String meldCount(int count) {
    return '$countメルド';
  }

  @override
  String get cannotPlayFirstTrickDeclarerGiruda => '最初のトリックでは、主公は切り札でリードできません';

  @override
  String get cannotPlayFirstTrickJoker => '最初のトリックではジョーカーを出せません';

  @override
  String get cannotPlayLastTrickJoker => '最後のトリックではジョーカーを出せません';

  @override
  String get cannotPlayLastTrickJokerHasLeadSuit => 'リードスートがある場合、ジョーカーを出せません';

  @override
  String get mustPlayJokerCall => 'ジョーカーコール！ジョーカーを出さなければなりません';

  @override
  String mustFollowSuit(String suit) {
    return '$suitのスートを出さなければなりません';
  }

  @override
  String get fullDeclarationWarning => 'フル宣言で契約が20に上がります';

  @override
  String get watchAiGame => 'マイティを学ぶ';

  @override
  String get demoMode => 'デモモード';

  @override
  String get stopDemo => '観戦終了';

  @override
  String get pauseDemo => '一時停止';

  @override
  String get resumeDemo => '再開';

  @override
  String get nextGameAuto => '次のゲーム';

  @override
  String bidExplanation(String name, String suit, int strength) {
    return '$name: 最適切り札 $suit、強度 $strength';
  }

  @override
  String bidExplanationBid(String name, String suit, int tricks, int strength) {
    return '$name: $suit $tricks ビッド (強度 $strength)';
  }

  @override
  String get passReasonNoSuit => '切り札候補なし (4枚以上のスートなし)';

  @override
  String get passReasonNoHighCard => '切り札A/Kなし';

  @override
  String passReasonWeakHand(int strength, int needed) {
    return 'ハンド強度不足 (強度 $strength、必要 $needed)';
  }

  @override
  String get passReasonPowerWeak => 'パワーカード不足（マイティ/ジョーカー/エース5枚未満）';

  @override
  String passReasonLowPoints(int optimal) {
    return '適正 $optimal点 < 最低 13点';
  }

  @override
  String passReasonOutbid(int optimal, int needed) {
    return '適正 $optimal点 < 必要 $needed点';
  }

  @override
  String estimatedRange(int min, int max) {
    return '予想 $min~$max点';
  }

  @override
  String optimalScore(int optimal) {
    return '適正 $optimal点';
  }

  @override
  String get friendExpected => 'フレンド予想';

  @override
  String get friendCardMighty => 'マイティ';

  @override
  String get friendCardJoker => 'ジョーカー';

  @override
  String friendHeldBy(String name) {
    return '$name が保有';
  }

  @override
  String get friendInKitty => 'キティにある可能性';

  @override
  String get friendJokerNote => '初手使用不可';

  @override
  String get trickLead => 'リード';

  @override
  String get trickIntentJoker => 'ジョーカーで確実にトリック獲得';

  @override
  String get trickIntentMighty => 'マイティで確実にトリック獲得';

  @override
  String get trickIntentGiruda => '切り札リードで相手の切り札を消耗させる';

  @override
  String get trickIntentAce => 'エースでリードを維持しトリック獲得';

  @override
  String get trickIntentHighCard => '高位カードでトリック挑戦';

  @override
  String get trickIntentLowCard => '低いカードで探索/犠牲';

  @override
  String get trickIntentMidCard => '中位カードでトリック挑戦';

  @override
  String trickResultBigWin(int count) {
    return 'リード勝利！得点カード$count枚獲得';
  }

  @override
  String trickResultWin(int count) {
    return 'リード勝利、得点カード$count枚獲得';
  }

  @override
  String get trickResultWinNoPoint => 'リード勝利、得点カードなし';

  @override
  String get trickLostToJoker => 'ジョーカーに奪われた';

  @override
  String get trickLostToMighty => 'マイティに奪われた';

  @override
  String get trickLostToCut => '切り札カットで奪われた';

  @override
  String get trickLostToHigher => 'より高いカードに奪われた';

  @override
  String trickPointCards(int count) {
    return '得点カード$count枚';
  }

  @override
  String get kittySummaryTitle => 'キティ選択結果';

  @override
  String get kittyReceivedCards => 'キティから受け取ったカード';

  @override
  String get kittyDiscardCards => '捨てるカード';

  @override
  String get kittyFinalHand => '最終手札 (10枚)';

  @override
  String get girudaComparisonTitle => '切り札比較（13枚）';

  @override
  String get discardReasonCutSuit => '少ないスート整理 → カット可能';

  @override
  String get discardReasonNonGirudaLow => '非切り札の低いカード';

  @override
  String get discardReasonLowValue => '低い価値のカード';

  @override
  String get discardReasonLeastUseful => '最も不要なカード';

  @override
  String get friendSummaryTitle => 'フレンド宣言結果';

  @override
  String get friendReasonNoFriendStrong => '強いハンドで一人で勝てる';

  @override
  String get friendReasonFirstTrick => '最初のトリック勝者をフレンドに指定';

  @override
  String get friendReasonNthTrick => '特定トリック勝者をフレンドに指定';

  @override
  String get friendReasonNeedMighty => 'マイティがないため所有者が必要';

  @override
  String get friendReasonNeedJoker => 'ジョーカーがないため所有者が必要';

  @override
  String get friendReasonNeedGirudaAce => '切り札Aがないため所有者が必要';

  @override
  String get friendReasonNeedGirudaKing => '切り札Kがないため所有者が必要';

  @override
  String get friendReasonNeedGirudaMid => '切り札中間カード所有者が必要';

  @override
  String get friendReasonNeedAce => 'エース所有者をフレンドに指定';

  @override
  String get friendReasonNeedStrongCard => '強いカード所有者をフレンドに指定';

  @override
  String get friendReasonNoFriendAll => '全ての重要カードを所有、ノーフレンド宣言';

  @override
  String get bidSummaryTitle => '入札結果';

  @override
  String get bidSummaryEstimatedRange => '予想得点範囲 (宣言者基準)';

  @override
  String bidSummaryEstMax(int points) {
    return '最大 ($points点)';
  }

  @override
  String get bidSummaryEstMaxDesc => 'フレンド含む、リード維持時';

  @override
  String bidSummaryEstMin(int points) {
    return '最小 ($points点)';
  }

  @override
  String get bidSummaryEstMinDesc => 'フレンドの助けなし（ジョーカーコール等）';

  @override
  String bidSummaryEstMinDescDynamic(String friend) {
    return 'フレンド($friend)基本のみ、キティの可能性あり';
  }

  @override
  String get bidSummaryMultipliers => '宣言者 ×2、フレンド ×1、守備 ×(-1)';

  @override
  String get firstTrickStrategy => '初手戦略';

  @override
  String get scoreStrategy => '得点戦略';

  @override
  String get firstTrickAce => '非切り札Aでリードし確実にトリック獲得';

  @override
  String get firstTrickKing => '非切り札Kでリードしトリック獲得を試みる';

  @override
  String get firstTrickGiveUp => '強いリードカードなし、低いカードで情報収集';

  @override
  String get strategyMighty => 'マイティで確実に1トリック確保';

  @override
  String get strategyJoker => 'ジョーカーで好きなタイミングでトリック獲得可能';

  @override
  String get strategyGirudaDominant => '切り札5枚以上で切り札支配力確保';

  @override
  String get strategyGirudaSupport => '切り札3枚以上で切り札サポート可能';

  @override
  String get strategyMultiAce => '複数エースで多くのトリック獲得可能';

  @override
  String get strategySingleAce => 'エース1枚で追加トリックの機会';

  @override
  String get strategyCut => '短いスートで切り札カット可能';

  @override
  String bidInfoGirudaKeys(String keys) {
    return '切り札 $keys';
  }

  @override
  String bidInfoFriend(String card) {
    return 'フレンド: $card';
  }

  @override
  String bidInfoHasBoth(String card1, String card2) {
    return '$card1·$card2 所持';
  }

  @override
  String bidInfoHasCard(String card) {
    return '$card 所持';
  }

  @override
  String bidInfoFirstTrickAces(String aces) {
    return '初手 $aces';
  }

  @override
  String get jokerOwner => 'ジョーカー所有者';

  @override
  String get friendBadge => 'フレンド';

  @override
  String get kittyLabel => '場札 ';

  @override
  String kittyPointsWithFriend(int points) {
    return ' $points点 (フレンド場札)';
  }

  @override
  String kittyPoints(int points) {
    return ' $points点';
  }

  @override
  String friendWithName(String name) {
    return 'フレンド $name ';
  }

  @override
  String adjustedPointsRange(int min, int max) {
    return '→ 調整 $min~$max点';
  }

  @override
  String get hasAceNote => ' (A所有)';

  @override
  String strategyFirstTrickAceLead(String card) {
    return '初手: $cardリードで確実なトリック獲得';
  }

  @override
  String get strategyFirstTrickPassFriendWin =>
      '初手: 短いスートの低カードでフレンドにリード譲渡（フレンドがトリック獲得）';

  @override
  String strategyFirstTrickKingLead(String card) {
    return '初手: $cardリードでトリック獲得を試みる';
  }

  @override
  String get strategyFirstTrickPassFriend => '初手: 短いスートの低カードでフレンドにリード譲渡';

  @override
  String get strategyPassToMightyFriend => '短いスートの低カードでフレンドにリード譲渡（マイティ）';

  @override
  String get strategyPassToJokerFriend => '短いスートの低カードでフレンドにリード譲渡（ジョーカー）';

  @override
  String strategyPassTrumpToFriend(
    String passCard,
    String friendCard,
    String rank,
  ) {
    return '$passCardリードでフレンド($friendCard)にリード譲渡 → $rank単独を防止';
  }

  @override
  String strategyPassSuitToFriend(String card, String friendCard) {
    return '$cardリードでフレンド($friendCard)にリード譲渡';
  }

  @override
  String get strategySourceFriend => 'フレンドトリック後、';

  @override
  String get strategySourceReclaim => 'リード奪還後、';

  @override
  String strategyTrumpDominate(String source, String cards) {
    return '$source $cardsで支配 → 守備側の切り札を消耗';
  }

  @override
  String strategyTrumpExhaust(String source, String cards) {
    return '$source $cardsで守備側の切り札を消耗';
  }

  @override
  String strategyTrumpMidDraw(String suit) {
    return '$suit中間切り札で守備側の高い切り札を引き出す';
  }

  @override
  String strategyJokerCallSuits(String suits) {
    return '守備側の切り札消耗後、弱いスート($suits)でジョーカーコール';
  }

  @override
  String get strategyJokerCallWeak => '守備側の切り札消耗後、弱いスートでジョーカーコール';

  @override
  String get strategyJokerOptimal => '最適なタイミングでジョーカーを使用してトリック獲得';

  @override
  String get strategyMightyTiming => '9トリック目にマイティ使用 → 10トリック目のリード確保';

  @override
  String strategyVoidTrumpCut(String suits) {
    return '$suitsボイド → 相手リード時に切り札カットでトリック回収';
  }

  @override
  String strategyTrumpExhaustCheckK(String cards) {
    return '$cards出し → 切り札最上位攻撃、K消耗確認';
  }

  @override
  String get strategyJokerAfterFriend => 'フレンド合流後ジョーカー出し → 得点獲得';

  @override
  String strategyJokerCallGiruda(String suit) {
    return 'K未消耗時ジョーカー: $suitコール → K誘引';
  }

  @override
  String strategyLowGirudaFriendLure(String card) {
    return '$card出し → フレンドにリード譲渡して誘引';
  }

  @override
  String strategyGirudaQReclaim(String card) {
    return '$card出し → リード奪還';
  }

  @override
  String strategyHighCardAttack(String cards) {
    return '$cards出し → 追加得点攻撃';
  }

  @override
  String get trickDetails => 'トリック詳細';

  @override
  String get trickColumnGainLoss => '得失';

  @override
  String get trickColumnGiruda => '切り札';

  @override
  String get trickColumnEvent => 'イベント';

  @override
  String get trickLegendLead => '先攻';

  @override
  String get trickLegendWinner => '勝者';

  @override
  String get trickEventLastCard => '最後のカード';

  @override
  String get trickEventJokerLead => 'ジョーカーリード';

  @override
  String trickEventJokerLeadSuit(String suit) {
    return 'ジョーカーリード ($suit)';
  }

  @override
  String get trickEventJokerGirudaExhaust => '守備側の切り札消耗を誘導';

  @override
  String get trickEventMightyLead => 'マイティリード';

  @override
  String get trickEventTopGirudaLead => '切り札最上位リード';

  @override
  String get trickEventMidGirudaMightyBait => '切り札中位でマイティ誘導';

  @override
  String get trickEventMidGirudaPassLead => '切り札中位でリード譲渡';

  @override
  String get trickEventDefenderGirudaWin => '守備側切り札勝利';

  @override
  String get trickEventMidGirudaLead => '切り札中位リード';

  @override
  String get trickEventTopNonGirudaLead => '非切り札最上位リード';

  @override
  String get trickEventFirstTrickFriendBait => '初トリック不在 / フレンド誘導';

  @override
  String get trickEventFirstTrickWaste => '初トリック不在 / 捨て札';

  @override
  String get trickEventWaste => '捨て札';

  @override
  String get trickEventAttackGirudaCut => '攻撃切り札カット';

  @override
  String get trickEventDefenseGirudaCut => '守備切り札カット';

  @override
  String get trickEventNonGirudaExhaust => '非切り札消耗';

  @override
  String estimatedMinWins(int count) {
    return '→ $count勝以上予想';
  }
}
