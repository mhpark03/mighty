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
  String get noGiruda => 'No Trump';

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
  String get confirm => 'Confirm';

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
  String get scoreFormula => '(Points-Contract) + (Points-Min)×2';

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
}
