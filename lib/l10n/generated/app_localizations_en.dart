// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Mighty';

  @override
  String get gameSubtitle => 'Korean Traditional Trick-Taking Card Game';

  @override
  String get startGame => 'Start Game';

  @override
  String get newGame => 'New Game';

  @override
  String get biddingPhase => 'Bidding Phase';

  @override
  String currentBidder(String name) {
    return 'Current Bidder: $name';
  }

  @override
  String get noBidYet => 'No bid yet';

  @override
  String highestBid(String bid) {
    return 'Highest Bid: $bid';
  }

  @override
  String get bid => 'Bid';

  @override
  String get bidButton => 'Place Bid';

  @override
  String get pass => 'Pass';

  @override
  String get tricks => 'Target Score';

  @override
  String get giruda => 'Trump';

  @override
  String get noGiruda => 'No Giruda';

  @override
  String get spade => 'Spade';

  @override
  String get diamond => 'Diamond';

  @override
  String get heart => 'Heart';

  @override
  String get club => 'Club';

  @override
  String get spadeName => 'Spade';

  @override
  String get diamondName => 'Diamond';

  @override
  String get heartName => 'Heart';

  @override
  String get clubName => 'Club';

  @override
  String get selectKitty => 'Select Kitty';

  @override
  String selectKittyDesc(int count) {
    return 'Select 3 cards to discard (Selected: $count/3)';
  }

  @override
  String get receivedKitty => 'Received Kitty:';

  @override
  String get myCards => 'My Cards:';

  @override
  String get changeGiruda => 'Change Trump (Optional):';

  @override
  String get confirm => 'OK';

  @override
  String get declareFriend => 'Declare Friend';

  @override
  String get friendDeclarationType => 'Friend Declaration Type:';

  @override
  String get byCard => 'By Card';

  @override
  String get firstTrickFriend => 'First Trick Friend';

  @override
  String get firstTrickFriendDesc => 'Winner of the first trick';

  @override
  String get nthTrickFriend => 'Nth Trick Friend';

  @override
  String get noFriend => 'No Friend';

  @override
  String get noFriendDesc => 'Play alone';

  @override
  String get declare => 'Declare';

  @override
  String get suit => 'Suit:';

  @override
  String get rank => 'Rank:';

  @override
  String selectedCard(String card) {
    return 'Selected Card: $card';
  }

  @override
  String get trickNumber => 'Trick Number:';

  @override
  String get playCard => 'Play a card';

  @override
  String get yourTurn => 'Your turn';

  @override
  String playerTurn(String name) {
    return '$name\'s turn';
  }

  @override
  String get contract => 'Contract';

  @override
  String get trick => 'Trick';

  @override
  String get friend => 'Friend';

  @override
  String get declarer => 'Declarer';

  @override
  String cards(int count) {
    return 'Cards: $count';
  }

  @override
  String get aiSelectingKitty => 'AI is selecting kitty...';

  @override
  String get aiDeclaringFriend => 'AI is declaring friend...';

  @override
  String get declarerTeamWins => 'Declarer Team Wins!';

  @override
  String get defenderTeamWins => 'Defender Team Wins!';

  @override
  String get declarerTeam => 'Declarer Team';

  @override
  String get defenderTeam => 'Defender Team';

  @override
  String get fullPoints => 'Full';

  @override
  String declarerTeamPoints(int points) {
    return 'Declarer Team: $points pts';
  }

  @override
  String defenderTeamPoints(int points) {
    return 'Defender Team: $points pts';
  }

  @override
  String targetPoints(int points) {
    return 'Target: $points pts';
  }

  @override
  String get score => 'Score';

  @override
  String points(int points) {
    return '$points pts';
  }

  @override
  String get player => 'Player';

  @override
  String get you => 'You';

  @override
  String get bidding => 'Bidding...';

  @override
  String get waiting => 'Waiting';

  @override
  String get otherPlayerTurn => 'Other player\'s turn';

  @override
  String get yourCards => 'Your Cards';

  @override
  String get biddingTurn => 'Your Bid';

  @override
  String bidWithAmount(int amount) {
    return 'Bid $amount';
  }

  @override
  String trickComplete(int number) {
    return 'Trick $number Complete';
  }

  @override
  String winnerAnnouncement(String name, String team) {
    return '$name Wins! ($team)';
  }

  @override
  String get attackTeam => 'Attack';

  @override
  String get defenseTeam => 'Defense';

  @override
  String get nextTrick => 'Next Trick';

  @override
  String get friendNone => 'None';

  @override
  String get firstTrick => '1st Trick';

  @override
  String get selectCardHint => 'Select a card ↓';

  @override
  String get previousTrick => 'Previous Trick';

  @override
  String get winShort => 'Win';

  @override
  String get leadPlayer => 'Lead';

  @override
  String get leadPlayerHint => '👆 You lead!';

  @override
  String get selectCardBelow => 'Select a card below';

  @override
  String get leadPlayerSelectCard => '👆 You lead! Select a card';

  @override
  String jokerCallAnnouncement(String suit) {
    return 'Joker Call! $suit';
  }

  @override
  String get wonCards => 'Won:';

  @override
  String get jokerCallTitle => 'Joker Call';

  @override
  String jokerCallQuestion(String suit) {
    return 'Declare $suit Joker Call?';
  }

  @override
  String get no => 'No';

  @override
  String jokerCallButton(String suit) {
    return '$suit Joker Call!';
  }

  @override
  String get jokerLeadSuitTitle => 'Joker Lead';

  @override
  String get jokerLeadSuitQuestion => 'Select the suit others must follow';

  @override
  String get allPassedTitle => 'All Passed';

  @override
  String get allPassedMessage => 'All players passed.\nStarting new game.';

  @override
  String get girudaChangeWarning => 'Changing trump: goal +2';

  @override
  String get keep => 'Keep';

  @override
  String get aiRecommendation => 'AI Recommendation';

  @override
  String get discardCards => 'Discard:';

  @override
  String get goalPlus2 => '(Goal +2)';

  @override
  String get applyRecommendation => 'Apply';

  @override
  String nthTrickShort(int n) {
    return 'Trick $n';
  }

  @override
  String get recommendedFriend => 'Recommended:';

  @override
  String get joker => 'Joker';

  @override
  String get mighty => 'Mighty';

  @override
  String get recommendNoFriend => 'No Friend recommended';

  @override
  String get reasonHasMighty => 'Has Mighty';

  @override
  String get reasonHasJoker => 'Has Joker';

  @override
  String get reasonNeedMighty => 'Need Mighty';

  @override
  String get reasonNeedJoker => 'Need Joker';

  @override
  String get reasonNeedGirudaAce => 'Need Trump Ace';

  @override
  String get reasonNeedGirudaKing => 'Need Trump King';

  @override
  String get reasonStrongHand => 'Strong hand';

  @override
  String get continueGame => 'Continue';

  @override
  String get exitGame => 'Exit Game';

  @override
  String get exitGameConfirm => 'Exit the game?\nCurrent game will be saved.';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Exit';

  @override
  String get savedGame => 'Saved Game';

  @override
  String get noSavedGame => 'No saved game';

  @override
  String get recommendedCard => 'Recommended';

  @override
  String get showRecommendation => 'Show Hint';

  @override
  String get playerStats => 'Player Statistics';

  @override
  String get winLoss => 'W/L';

  @override
  String get totalScore => 'Score';

  @override
  String get win => 'W';

  @override
  String get loss => 'L';

  @override
  String get resetStats => 'Reset';

  @override
  String get resetStatsConfirm =>
      'Watch an ad to reset all statistics.\nContinue?';

  @override
  String get exitApp => 'Exit App';

  @override
  String get exitAppConfirm => 'Exit the app?';

  @override
  String get gameGuide => 'How to Play';

  @override
  String get guideOverview => 'Overview';

  @override
  String get guideOverviewText =>
      'Mighty is a trick-taking card game for 5 players. The Declarer (1) and Friend (1) team up against the Defenders (3).';

  @override
  String get guideBidding => 'Bidding';

  @override
  String get guideBiddingText =>
      '• Each player declares how many point cards they will win\n• The highest bidder becomes the Declarer\n• The Declarer chooses the trump suit (Giruda)';

  @override
  String get guideSpecialCards => 'Special Cards';

  @override
  String get guideSpecialCardsText =>
      '• Mighty: Ace of Spades (strongest card)\n• Joker: Second strongest card\n• Trump: The suit chosen by the Declarer';

  @override
  String get guideFriend => 'Friend';

  @override
  String get guideFriendText =>
      '• The Declarer designates someone with a specific card as Friend\n• The Friend can hide their identity\n• Joker Call: Designate the holder of a specific 3 as Friend';

  @override
  String get guideScoring => 'Scoring';

  @override
  String get guideScoringText =>
      '• Point cards: A, K, Q, J, 10 (1 point each, 20 total)\n• Declarer team wins if they reach the target score\n• Winners get + points, losers get - points';

  @override
  String get guideTips => 'Tips';

  @override
  String get guideTipsText =>
      '• Mighty and Joker are always powerful\n• Use trump cards wisely\n• Identifying the Friend is crucial';

  @override
  String get close => 'Close';

  @override
  String get dealMiss => 'Deal Miss';

  @override
  String get dealMissTitle => 'Declare Deal Miss';

  @override
  String get dealMissConfirm =>
      'Declare deal miss?\nYour hand will be revealed and a new game will start.';

  @override
  String dealMissAnnouncement(String name) {
    return '$name declared Deal Miss!';
  }

  @override
  String get dealMissNewGame => 'Restarting game due to deal miss.';

  @override
  String get aiPlayer1 => 'Alex';

  @override
  String get aiPlayer2 => 'Emma';

  @override
  String get aiPlayer3 => 'James';

  @override
  String get aiPlayer4 => 'Sophia';

  @override
  String get scoreCalcWin => 'Score Calculation (Win)';

  @override
  String get scoreCalcLose => 'Score Calculation (Lose)';

  @override
  String get scoreFormula => '(Points-Contract+1) + (Points-Min)×2';

  @override
  String get scoreFormulaLose => '-(Contract - Points)';

  @override
  String get scoreMultipliers => 'Declarer ×2, Friend ×1, Defense ×(-1)';

  @override
  String get multiplierRun => 'Run ×2';

  @override
  String get multiplierNoGiruda => 'No Trump ×2';

  @override
  String get multiplierNoFriend => 'No Friend ×2';

  @override
  String get multiplierBackRun => 'Back Run ×2';

  @override
  String get multiplierLabel => 'Multiplier';

  @override
  String get selectGame => 'Select Game';

  @override
  String get sevenCardTitle => 'Seven Poker';

  @override
  String get sevenCardSubtitle => '7-Card Poker Game';

  @override
  String get sevenCardRules => 'Game Rules';

  @override
  String get sevenCardRulesText =>
      '• Each player receives 7 cards\n• First 3 cards are hidden, remaining 4 are shown\n• Betting rounds determine the winner with best 5 cards\n• Player with the highest hand wins';

  @override
  String get pot => 'Pot';

  @override
  String get currentBet => 'Current Bet';

  @override
  String get betting => 'Round';

  @override
  String get chips => 'Chips';

  @override
  String get bet => 'Bet';

  @override
  String get fold => 'Die';

  @override
  String get call => 'Call';

  @override
  String get raise => 'Raise';

  @override
  String get check => 'Check';

  @override
  String get allIn => 'All In';

  @override
  String get folded => 'Die';

  @override
  String get wins => 'Wins';

  @override
  String get gameEnd => 'Game End';

  @override
  String get hiLoTitle => 'Hi-Lo';

  @override
  String get hiLoSubtitle => 'Hi/Lo Split Poker';

  @override
  String get hi => 'Hi';

  @override
  String get lo => 'Lo';

  @override
  String get swing => 'Swing';

  @override
  String get selectHiLo => 'Select Hi/Lo';

  @override
  String get selectHiLoDesc => 'Choose Hi, Lo, or Swing';

  @override
  String get hiWinner => 'Hi Winner';

  @override
  String get loWinner => 'Lo Winner';

  @override
  String get swingSuccess => 'Swing Success!';

  @override
  String get swingFailed => 'Swing Failed';

  @override
  String get hiPot => 'Hi Pot';

  @override
  String get loPot => 'Lo Pot';

  @override
  String get noLowHand => 'No Low';

  @override
  String get bestLow => 'Best Low';

  @override
  String get waitingForHiLo => 'Waiting for selection...';

  @override
  String get selectedHi => 'Selected Hi';

  @override
  String get selectedLo => 'Selected Lo';

  @override
  String get selectedSwing => 'Selected Swing';

  @override
  String get showdownTitle => 'Declaration Status';

  @override
  String get showdownDesc => 'Check each player\'s choice';

  @override
  String get viewResults => 'View Results';

  @override
  String get finalResults => 'Final Results';

  @override
  String get sevenCardGuideOverview => 'Game Overview';

  @override
  String get sevenCardGuideOverviewText =>
      'Seven Card Poker is a poker game for 5 players. Create the best hand using 5 of your 7 cards to win.';

  @override
  String get sevenCardGuideDealing => 'Card Dealing';

  @override
  String get sevenCardGuideDealingText =>
      '• Initially receive 4 cards (3 hidden, 1 open)\n• Receive one open card after each betting round\n• Make a hand with 5 of your final 7 cards';

  @override
  String get sevenCardGuideBetting => 'Betting Rules';

  @override
  String get sevenCardGuideBettingText =>
      '• Check: Pass without betting\n• Call: Match current bet\n• Raise: Increase bet amount\n• Fold: Give up the hand\n• All In: Bet all chips';

  @override
  String get sevenCardGuideHands => 'Hand Rankings';

  @override
  String get sevenCardGuideHandsText =>
      '1. Royal Straight Flush\n2. Back Straight Flush\n3. Straight Flush\n4. Four of a Kind\n5. Full House\n6. Flush\n7. Mountain (A-K-Q-J-10)\n8. Back Straight (A-2-3-4-5)\n9. Straight\n10. Three of a Kind\n11. Two Pair\n12. One Pair\n13. High Card';

  @override
  String get sevenCardGuideTips => 'Game Tips';

  @override
  String get sevenCardGuideTipsText =>
      '• Predict opponent hands from open cards\n• Avoid excessive betting without strong hands\n• Bluffing is also a strategy';

  @override
  String get sevenCardGuideBonus => 'Bonus Hands';

  @override
  String get sevenCardGuideBonusText =>
      '• Royal Straight Flush: 500 chips\n• Back Straight Flush: 300 chips\n• Straight Flush: 200 chips\n• Four of a Kind: 100 chips\n\nBonus hands earn bonus from all other players!';

  @override
  String get hiLoGuideOverview => 'Game Overview';

  @override
  String get hiLoGuideOverviewText =>
      'Hi-Lo is a variation of Seven Card Poker where the pot is split between the highest and lowest hand.';

  @override
  String get hiLoGuideDealing => 'Card Dealing';

  @override
  String get hiLoGuideDealingText =>
      '• Same dealing as Seven Card Poker\n• Make a hand with 5 of your 7 cards\n• Choose Hi/Lo/Swing after final betting';

  @override
  String get hiLoGuideHiLo => 'Hi/Lo Selection';

  @override
  String get hiLoGuideHiLoText =>
      '• Hi: Compete with highest hand\n• Lo: Compete with lowest hand\n• Swing: Challenge both Hi and Lo\n\n50% of pot goes to Hi winner, 50% to Lo winner.';

  @override
  String get hiLoGuideLow => 'Low Hand Rules';

  @override
  String get hiLoGuideLowText =>
      '• Only hands without straights/flushes qualify\n• Lower is better (A is lowest)\n• Best low: A-2-3-4-6\n• No pair hands are advantageous';

  @override
  String get hiLoGuideSwing => 'Swing Rules';

  @override
  String get hiLoGuideSwingText =>
      '• Split 7 cards into two 5-card hands\n• Must win both Hi and Lo to succeed\n• Success: Win entire pot\n• Failure: That portion goes to other winner';

  @override
  String get hiLoGuideTips => 'Game Tips';

  @override
  String get hiLoGuideTipsText =>
      '• Low cards like A-2-3-4 favor Lo\n• Swing is risky but rewarding if successful\n• Observe opponent cards for strategy';

  @override
  String get hiLoGuideBonus => 'Bonus Hands';

  @override
  String get hiLoGuideBonusText =>
      '• Royal Straight Flush: 500 chips\n• Back Straight Flush: 300 chips\n• Straight Flush: 200 chips\n• Four of a Kind: 100 chips\n\nBonus hands automatically win the entire pot!';

  @override
  String get hulaTitle => 'Hula';

  @override
  String get hulaSubtitle => '4-Player Rummy Card Game';

  @override
  String get heartsTitle => 'Hearts';

  @override
  String get heartsSubtitle => '4-Player Trick-Taking Game';

  @override
  String get handRoyalStraightFlush => 'Royal Straight Flush';

  @override
  String get handBackStraightFlush => 'Back Straight Flush';

  @override
  String get handStraightFlush => 'Straight Flush';

  @override
  String get handFourOfAKind => 'Four of a Kind';

  @override
  String get handFullHouse => 'Full House';

  @override
  String get handFlush => 'Flush';

  @override
  String get handMountain => 'Mountain';

  @override
  String get handBackStraight => 'Back Straight';

  @override
  String get handStraight => 'Straight';

  @override
  String get handTriple => 'Three of a Kind';

  @override
  String get handTwoPair => 'Two Pair';

  @override
  String get handOnePair => 'One Pair';

  @override
  String get handHighCard => 'High Card';

  @override
  String highCardTop(String rank) {
    return '$rank High';
  }

  @override
  String get noLow => 'No Low';

  @override
  String get betPing => 'Ping';

  @override
  String get betCheck => 'Check';

  @override
  String get betCall => 'Call';

  @override
  String get betDdadang => 'Double';

  @override
  String get betQuarter => 'Quarter';

  @override
  String get betHalf => 'Half';

  @override
  String get betFull => 'Full';

  @override
  String get betDie => 'Fold';

  @override
  String get selectOpenCard => 'Select a card to reveal';

  @override
  String get selectOpenCardDesc =>
      'The selected card will be shown to opponents';

  @override
  String get aiSelectingCard => 'AI is selecting a card...';

  @override
  String nthCard(int n) {
    return 'Card #$n';
  }

  @override
  String secondsCount(int n) {
    return '${n}s';
  }

  @override
  String totalBetAmount(int amount) {
    return 'Total: $amount';
  }

  @override
  String bettingAmount(int amount) {
    return 'Bet: $amount';
  }

  @override
  String get bonusHand => 'Bonus Hand!';

  @override
  String get bonus => 'Bonus';

  @override
  String get total => 'Total';

  @override
  String otherPlayersLose(int amount) {
    return 'Other players: -$amount each';
  }

  @override
  String get thisGame => 'This Game';

  @override
  String get cumulative => 'Total';

  @override
  String get foldedSection => 'Folded';

  @override
  String get hiLoHi => 'Hi';

  @override
  String get hiLoLo => 'Lo';

  @override
  String get hiLoSwing => 'Swing';

  @override
  String roundComplete(int n) {
    return 'Round $n Complete!';
  }

  @override
  String get cardDistribution5 => 'The 5th card is being dealt.';

  @override
  String get cardDistribution6 => 'The 6th card is being dealt.';

  @override
  String get cardDistribution7 => 'The final 7th card is being dealt.';

  @override
  String get goodLuck => 'GOOD LUCK!';

  @override
  String cardCount(int count) {
    return '$count cards';
  }

  @override
  String get suitSpade => 'Spade';

  @override
  String get suitDiamond => 'Diamond';

  @override
  String get suitHeart => 'Heart';

  @override
  String get suitClub => 'Club';

  @override
  String cardOwner(String card) {
    return '$card Owner';
  }

  @override
  String trickWinner(int n) {
    return 'Trick $n Winner';
  }

  @override
  String get hint => 'Hint';

  @override
  String get hintOff => 'Hint OFF';

  @override
  String get hintDialogContent => 'Watch an ad to enable hints.\nContinue?';

  @override
  String get newGameDialogContent =>
      'Watch an ad to start a new game.\nContinue?';

  @override
  String get watchAd => 'Watch Ad';

  @override
  String jokerLead(String suit) {
    return 'Joker lead: $suit';
  }

  @override
  String get gameSelection => 'Game Selection';

  @override
  String get onecardTitle => 'One Card';

  @override
  String get onecardSubtitle => '4-Player Game';

  @override
  String get gameRules => 'Game Rules';

  @override
  String get heartsGuideGoal => 'Goal';

  @override
  String get heartsGuideGoalText =>
      'The goal is to get the lowest score by avoiding heart cards and the Queen of Spades.';

  @override
  String get heartsGuideHow => 'How to Play';

  @override
  String get heartsGuideHowText =>
      '• 4 players, each receives 13 cards\n• Pass 3 cards to the left at game start\n• Player with Club 2 starts first\n• Play 13 tricks while avoiding point cards';

  @override
  String get heartsGuideScoring => 'Scoring';

  @override
  String get heartsGuideScoringText =>
      '• Heart cards: 1 point each (13 total)\n• Queen of Spades (♠Q): 13 points\n• Total: 26 points\n• Lowest score wins!';

  @override
  String get heartsGuideBreaking => 'Heart Breaking';

  @override
  String get heartsGuideBreakingText =>
      'Hearts cannot be played on the first trick.\nHearts can only lead after hearts have been broken.';

  @override
  String get heartsGuideShootMoon => 'Shooting the Moon';

  @override
  String get heartsGuideShootMoonText =>
      'If one player takes all hearts and the Queen of Spades:\n• That player: 0 points\n• Other players: 26 points each';

  @override
  String get heartsGuideTips => 'Strategy Tips';

  @override
  String get heartsGuideTipsText =>
      '• Get rid of high cards early\n• Watch out for the Queen of Spades\n• Try to give point cards to opponents';

  @override
  String get allScoreCardsUsed => 'All point cards used! Game over';

  @override
  String passLeftCount(int count) {
    return 'Pass left ($count/3)';
  }

  @override
  String get cardPass => 'Card Pass';

  @override
  String trickProgress(int current) {
    return 'Trick $current/13';
  }

  @override
  String get heartBroken => 'Heart Breaking';

  @override
  String get passRecommend => 'Pass Recommend';

  @override
  String get recommend => 'Recommend';

  @override
  String get selectCardsToPassLeft => 'Select 3 cards to pass left';

  @override
  String playerNameWins(String name) {
    return '$name wins';
  }

  @override
  String playerStartsWithClub2(String name) {
    return '$name starts with Club 2';
  }

  @override
  String playerWonTrick(String name, int points) {
    return '$name won the trick! (+$points points)';
  }

  @override
  String playerShootMoonSuccess(String name) {
    return '$name shot the moon!';
  }

  @override
  String get hintActivated => 'Hint activated!';

  @override
  String get myTurn => 'My Turn';

  @override
  String get start => 'Start';

  @override
  String get counterClockwise => 'CCW';

  @override
  String get clockwise => 'CW';

  @override
  String get blackJoker => 'B&W Joker';

  @override
  String get colorJoker => 'Color Joker';

  @override
  String get oneCardCall => 'One Card!';

  @override
  String oneCardCallTimer(int seconds) {
    return 'One Card (${seconds}s)';
  }

  @override
  String get selectSuit => 'Select a suit';

  @override
  String get discardedCards => 'Discarded cards';

  @override
  String get meld => 'Meld';

  @override
  String get discard => 'Discard';

  @override
  String get stop => 'Stop';

  @override
  String get handCards => 'Hand';

  @override
  String get cannotPlayCard => 'Cannot play this card';

  @override
  String get drawCard => 'Draw a card';

  @override
  String get discardOrMeld => 'Discard or meld a card';

  @override
  String get noCards => 'No cards';

  @override
  String get thankYouSelectMethod => 'Select Thank You method';

  @override
  String thankYouMeldSolo(String suit) {
    return 'Thank You! Meld ${suit}7 solo';
  }

  @override
  String thankYouMeldMyMeld(String card) {
    return 'Thank You! Add $card to my meld';
  }

  @override
  String thankYouMeldAiMeld(String card, String aiName) {
    return 'Thank You! Add $card to $aiName\'s meld';
  }

  @override
  String get addedToMeld => 'Added to meld';

  @override
  String get noMeldToAttach => 'No meld to attach';

  @override
  String get invalidCombination => 'Invalid combination';

  @override
  String get drawCardFirst => 'Draw a card first';

  @override
  String get selectCardToDiscard => 'Select a card to discard';

  @override
  String get hulaWin => 'Hula win! (x2)';

  @override
  String get continue_ => 'Continue';

  @override
  String attackReceived(int count) {
    return 'Received $count cards from attack';
  }

  @override
  String get cardDrawn => 'Card drawn';

  @override
  String bankrupt(int count) {
    return 'Bankrupt! ($count cards)';
  }

  @override
  String get restart => 'Restart';

  @override
  String get goal => 'Goal';

  @override
  String get howToPlay => 'How to Play';

  @override
  String get attackCards => 'Attack Cards';

  @override
  String get defense => 'Defense';

  @override
  String get specialCards => 'Special Cards';

  @override
  String get tips => 'Tips';

  @override
  String get winRate => 'Win Rate';

  @override
  String get onecardGuideGoal => 'Goal';

  @override
  String get onecardGuideGoalText => 'Be the first to play all your cards.';

  @override
  String get onecardGuidePlay => 'Playing Cards';

  @override
  String get onecardGuidePlayText =>
      'You can play a card with the same suit or number as the previous card.';

  @override
  String get onecardGuideAttack => 'Attack Cards';

  @override
  String get onecardGuideAttackText =>
      '• 2: +2 cards attack\n• A: +3 cards attack (♠A is +5)\n• Joker: +5(B&W) / +7(Color)';

  @override
  String get onecardGuideSpecial => 'Special Cards';

  @override
  String get onecardGuideSpecialText =>
      '• J: Skip next player\n• Q: Reverse direction\n• K: Skip 2 turns\n• 7: Change suit';

  @override
  String get onecardGuideJokerDefense => 'Joker Defense';

  @override
  String get onecardGuideJokerDefenseText =>
      'When attacked by a Joker, you can only defend with a Joker.';

  @override
  String get onecardGuideOnecard => 'One Card!';

  @override
  String get onecardGuideOnecardText =>
      'When you have 1 card left, you must press the \"One Card!\" button.\nIf you don\'t, you receive 2 penalty cards.';

  @override
  String get onecardGuideBankrupt => 'Bankruptcy';

  @override
  String get onecardGuideBankruptText =>
      'If you have 20+ cards, you\'re bankrupt! The player with fewest cards wins.';

  @override
  String get hulaGuideGoal => 'Goal';

  @override
  String get hulaGuideGoalText =>
      'Be the first to get rid of all cards in your hand by melding or discarding.';

  @override
  String get hulaGuideHow => 'How to Play';

  @override
  String get hulaGuideHowText =>
      'Each turn, draw a card from the deck or discard pile, then meld or discard.';

  @override
  String get hulaGuideMelds => 'Meld Types';

  @override
  String get hulaGuideMeldsText =>
      '• Run: 3+ consecutive cards of same suit (e.g., ♠3-4-5)\n• Group: 3+ same number different suits (e.g., ♠7-♥7-♦7)';

  @override
  String get hulaGuideSeven => 'Special Rule for 7';

  @override
  String get hulaGuideSevenText => 'A 7 can be melded on its own.';

  @override
  String get hulaGuideThankYou => 'Thank You';

  @override
  String get hulaGuideThankYouText =>
      'If you draw a 7 from the discard pile, you can call \"Thank You\" and make a special meld.';

  @override
  String get hulaGuideStop => 'Stop';

  @override
  String get hulaGuideStopText =>
      'You can call Stop anytime to end the game.\nThe player with the lowest card points wins.';

  @override
  String get hulaGuideCardPoints => 'Card Points';

  @override
  String get hulaGuideCardPointsText =>
      'A=1pt, 2~9=face value, J=10pts, Q=11pts, K=12pts';

  @override
  String get hulaGuideScoring => 'Scoring';

  @override
  String get hulaGuideScoringText =>
      '• Winner: Gets sum of point differences from other players\n• Loser: Loses points based on difference with winner\n• Hula (win without melding): Double points';

  @override
  String get hulaGuideStopPenalty => 'Stop Failure Penalty';

  @override
  String get hulaGuideStopPenaltyText =>
      'If you call Stop but don\'t have the lowest score:\n• The stopper pays all points the winner would receive\n• Other players lose no points';

  @override
  String attackTotalCards(int power, int total) {
    return '+$power! ($total cards attack)';
  }

  @override
  String get skipNextTurnMessage => 'J! Skip next turn';

  @override
  String get reverseDirectionMessage => 'Q! Reverse direction';

  @override
  String get skipTwoTurnsMessage => 'K! Skip 2 turns';

  @override
  String changeSuitMessage(String suit) {
    return '7! Change suit: $suit';
  }

  @override
  String playerPlayedCard(String name) {
    return '$name played a card';
  }

  @override
  String onecardWithPlayers(int count) {
    return 'One Card (${count}P)';
  }

  @override
  String get blackWhiteJoker => 'B&W Joker';

  @override
  String get clockwiseDirection => 'Clockwise';

  @override
  String get counterClockwiseDirection => 'Counter-clockwise';

  @override
  String aiTurnCountdown(String name, int seconds) {
    return '$name ($seconds)';
  }

  @override
  String aiTurn(String name) {
    return '$name\'s turn';
  }

  @override
  String get cannotPlayThisCard => 'This card cannot be played';

  @override
  String bankruptWithCards(int count) {
    return 'Bankrupt! ($count cards)';
  }

  @override
  String get gameRulesTitle => 'Game Rules';

  @override
  String get goalText =>
      'Be the first to play all your cards.\nYou must call \"One Card\" before playing your last card.';

  @override
  String get howToPlayText =>
      'Play a card with the same suit or number.\nIf you can\'t play, draw from the deck.';

  @override
  String get defenseText =>
      'When attacked, defend with the same attack card.\nDefending stacks the attack to the next player.';

  @override
  String get gameTips => 'Game Tips';

  @override
  String get drawCardMessage => 'Draw a card';

  @override
  String get discardOrMeldMessage => 'Discard or meld a card';

  @override
  String get noCardsMessage => 'No cards';

  @override
  String thankYouSolo(String suit) {
    return 'Thank You! ${suit}7 solo meld';
  }

  @override
  String thankYouAddToMine(String card) {
    return 'Thank You! Add $card to my meld';
  }

  @override
  String thankYouAddToAi(String card, String aiName) {
    return 'Thank You! Add $card to $aiName\'s meld';
  }

  @override
  String thankYouDesc(String desc) {
    return 'Thank You! $desc';
  }

  @override
  String get drawFirstMessage => 'Draw a card first';

  @override
  String get hulaWinBonus => 'Hula win! (x2)';

  @override
  String get handColumn => 'Hand';

  @override
  String get scoreColumn => 'Score';

  @override
  String get cumulativeColumn => 'Total';

  @override
  String hulaWithPlayers(int count) {
    return 'Hula (${count}P)';
  }

  @override
  String hintOnOff(String status) {
    return 'Hint $status';
  }

  @override
  String get meldButton => 'Meld';

  @override
  String get discardButton => 'Discard';

  @override
  String get stopButton => 'Stop';

  @override
  String get thankYouMeld => 'Thank You Meld';

  @override
  String get meldTypes => 'Meld Types';

  @override
  String get ok => 'OK';

  @override
  String aiThankYouDraw(String aiName, String card) {
    return '$aiName Thank You! $card';
  }

  @override
  String aiDrawsCard(String aiName) {
    return '$aiName draws a card';
  }

  @override
  String aiRegistersSeven(String aiName, String type) {
    return '$aiName: Registers 7 $type';
  }

  @override
  String aiRegistersMeld(String aiName, String meldType, String cards) {
    return '$aiName: Registers $meldType $cards';
  }

  @override
  String aiAttachesToMeld(String aiName, String card) {
    return '$aiName: Attaches $card to meld';
  }

  @override
  String aiAttachesToPlayerMeld(String aiName, String card) {
    return '$aiName: Attaches $card to player meld';
  }

  @override
  String aiAttachesToOtherAiMeld(String aiName, String card, String targetAi) {
    return '$aiName: Attaches $card to $targetAi meld';
  }

  @override
  String aiDiscards(String aiName, String card) {
    return '$aiName: Discards $card';
  }

  @override
  String get group => 'Group';

  @override
  String get solo => 'Solo';

  @override
  String get victory => 'Victory!';

  @override
  String get defeat => 'Defeat';

  @override
  String drewCardWithCard(String card) {
    return 'Drew $card';
  }

  @override
  String playerDiscards(String card) {
    return '$card discarded';
  }

  @override
  String get inPossession => '(Owned)';

  @override
  String get fourPlayerGame => '4 Players';

  @override
  String meldCount(int count) {
    return '$count melds';
  }
}
