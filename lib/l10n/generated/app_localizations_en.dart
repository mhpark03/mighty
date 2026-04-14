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
  String get receivedKitty => 'Received Cards:';

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
  String get guideIntro => '1. Introduction';

  @override
  String get guideIntroText =>
      'Mighty is a trick-taking card game for 5 players.\nIt uses 53 cards including a Joker. Each player gets 10 cards, and 3 cards remain as the kitty.\n\nThe Declarer (1) and Friend (1) form the attack team, while the remaining 3 are the defense team. The Declarer\'s team wins by scoring at least their bid.';

  @override
  String get guideGameFlow => '2. Game Flow';

  @override
  String get guideGameFlowText =>
      '① Deal Cards → ② Bidding → ③ Kitty Exchange → ④ Friend Declaration → ⑤ Card Play → ⑥ Scoring\n\nEach phase proceeds in order. If all players pass, cards are redealt.';

  @override
  String get guideBidding => '3. Bidding';

  @override
  String get guideBiddingText =>
      'Declare how many point cards you can win.\n\n• Minimum bid: 13 points (out of 20 total point cards)\n• Declare the trump suit (Giruda) along with your bid\n• No Trump: Bid without a trump suit (takes priority over same-number trump bids)\n• The highest bidder becomes the Declarer\n\n💡 Having Mighty, Joker, or Ace of trump enables higher bids.';

  @override
  String get guideKitty => '4. Kitty Exchange';

  @override
  String get guideKittyText =>
      'The Declarer takes the 3 kitty cards and discards 3 from their 13 cards.\n\n• Discard weak cards to strengthen your hand\n• You can change the trump suit (+2 added to bid)\n• You can discard point cards, but it may benefit the defense';

  @override
  String get guideFriend => '5. Friend Declaration';

  @override
  String get guideFriendText =>
      'The Declarer designates their teammate (Friend).\n\n• Card Friend: Owner of a specific card (e.g., holder of ♠A)\n• First Trick Friend: Winner of the first trick\n• No Friend: Play alone (score ×2)\n\nThe Friend\'s identity is hidden until they play the designated card. The defense must deduce who the Friend is.';

  @override
  String get guideSpecialCards => '6. Special Cards';

  @override
  String get guideSpecialCardsText =>
      '♠A Mighty\nThe strongest card. No other card can beat it.\nMust be played when Joker Call is declared. If trump is ♠, then ♦A is Mighty.\n\n🃏 Joker\nThe second strongest card.\nWhen leading, you can designate any suit. Has no power in the first trick.\nMust be played when targeted by Joker Call.\n\nTrump (Giruda)\nCards of the suit chosen by the Declarer.\nPlaying a trump on a non-trump lead \"cuts\" to win the trick.';

  @override
  String get guideJokerCall => '7. Joker Call';

  @override
  String get guideJokerCallText =>
      'When the lead player plays a card and declares \"Joker Call\", the Joker holder must play the Joker.\n\n• Cannot Joker Call on the first trick\n• Joker becomes the weakest card when called\n• A key strategy for the defense to neutralize the opponent\'s Joker';

  @override
  String get guideTrickPlay => '8. Trick Play';

  @override
  String get guideTrickPlayText =>
      'Play 10 tricks (rounds).\n\n• The lead player plays one card\n• Other players must follow suit (play the same suit)\n• If you don\'t have that suit, you can play any card\n• The player with the strongest card wins the trick and leads next\n\nCard strength order:\nMighty > Joker > Trump (A~2) > Lead suit (A~2)';

  @override
  String get guideScoring => '9. Point Cards';

  @override
  String get guideScoringText =>
      'Point cards: A, K, Q, J, 10 (5 per suit × 4 suits = 20 cards)\nEach point card is worth 1 point, collected by the trick winner.\n\nExample: If ♠A, ♠K, ♥3, ♦7, ♣2 are played in a trick\n→ 2 point cards (♠A, ♠K) = 2 points for the trick winner';

  @override
  String get guideWinLose => '10. Win/Loss & Scoring';

  @override
  String get guideWinLoseText =>
      'The Declarer\'s team wins by scoring at least their bid.\n\nBase score on win:\n• (Points scored - Bid) + 1 + bonuses\n• Run (winning all 10 tricks): Bonus points\n• No Friend: Score ×2\n• No Trump: Score ×2\n\nOn loss:\n• Declarer loses (Defenders × base score) points\n• Back Run (defense wins all): Extra penalty';

  @override
  String get guideTips => '11. Strategy Tips';

  @override
  String get guideTipsText =>
      'Declarer strategy:\n• Bid aggressively with Mighty/Joker/Trump Ace\n• Exhaust opponents\' trumps early to prevent cuts\n• Cooperate with Friend to collect point cards\n\nDefense strategy:\n• Identify the Friend quickly\n• Use Joker Call to neutralize the opponent\'s Joker\n• Prevent the Declarer team from collecting point cards\n• Use trump cuts to capture opponent\'s non-trump Aces';

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
  String get scoreMultipliersNoFriend => 'Declarer ×3, Defense ×(-1)';

  @override
  String get multiplierRun => 'Run ×2';

  @override
  String get multiplierNoGiruda => 'No Trump ×2';

  @override
  String get multiplierNoFriend => 'No Friend ×2';

  @override
  String get multiplierBackRun => 'Back Run ×2';

  @override
  String get multiplierFullRun => 'Full Run ×2';

  @override
  String get multiplierLabel => 'Multiplier';

  @override
  String get selectGame => 'Select Game';

  @override
  String get hulaTitle => 'Hula';

  @override
  String get hulaSubtitle => '4-Player Rummy Card Game';

  @override
  String get heartsTitle => 'Hearts';

  @override
  String get heartsSubtitle => '4-Player Trick-Taking Game';

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
  String get emptyDiscardPile => 'No\nDiscards';

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

  @override
  String get cannotPlayFirstTrickDeclarerGiruda =>
      'Declarer cannot lead with trump on the first trick';

  @override
  String get cannotPlayFirstTrickJoker =>
      'Cannot play Joker on the first trick';

  @override
  String get cannotPlayLastTrickJoker => 'Cannot play Joker on the last trick';

  @override
  String get cannotPlayLastTrickJokerHasLeadSuit =>
      'Cannot play Joker when you have the lead suit';

  @override
  String get mustPlayJokerCall => 'Joker Call! You must play the Joker';

  @override
  String mustFollowSuit(String suit) {
    return 'You must follow $suit';
  }

  @override
  String get fullDeclarationWarning =>
      'Declaring Full raises the contract to 20';

  @override
  String get watchAiGame => 'Learn Mighty';

  @override
  String get demoMode => 'Demo Mode';

  @override
  String get stopDemo => 'Stop Demo';

  @override
  String get pauseDemo => 'Pause';

  @override
  String get resumeDemo => 'Resume';

  @override
  String get nextGameAuto => 'Next Game';

  @override
  String bidExplanation(String name, String suit, int strength) {
    return '$name: Best trump $suit, Strength $strength';
  }

  @override
  String bidExplanationBid(String name, String suit, int tricks, int strength) {
    return '$name: $suit $tricks bid (Strength $strength)';
  }

  @override
  String get passReasonNoSuit => 'No trump candidate (no suit with 4+ cards)';

  @override
  String get passReasonNoHighCard => 'No trump A/K';

  @override
  String passReasonWeakHand(int strength, int needed) {
    return 'Weak hand (strength $strength, need $needed)';
  }

  @override
  String get passReasonPowerWeak =>
      'Not enough power cards (Mighty/Joker/Aces < 5)';

  @override
  String passReasonLowPoints(int optimal) {
    return 'Opt. ${optimal}pts < min 13pts';
  }

  @override
  String passReasonOutbid(int optimal, int needed) {
    return 'Opt. ${optimal}pts < need ${needed}pts';
  }

  @override
  String estimatedRange(int min, int max) {
    return 'Est. $min~${max}pts';
  }

  @override
  String optimalScore(int optimal) {
    return 'Opt. ${optimal}pts';
  }

  @override
  String get kittyScoreChange => 'Expected Score Change';

  @override
  String get kittyBeforeExchange => 'Before';

  @override
  String get kittyAfterExchange => 'After';

  @override
  String get friendExpected => 'Expected friend';

  @override
  String get friendCardMighty => 'Mighty';

  @override
  String get friendCardJoker => 'Joker';

  @override
  String friendHeldBy(String name) {
    return 'held by $name';
  }

  @override
  String get friendInKitty => 'may be in kitty';

  @override
  String get friendJokerNote => 'cannot play 1st trick';

  @override
  String get kittySummaryTitle => 'Kitty Selection Result';

  @override
  String get kittyReceivedCards => 'Cards from Kitty';

  @override
  String get kittyDiscardCards => 'Discarded Cards';

  @override
  String get kittyFinalHand => 'Final Hand (10 cards)';

  @override
  String get girudaComparisonTitle => 'Giruda Comparison (13 cards)';

  @override
  String get discardReasonCutSuit => 'Clear short suit → enable cut';

  @override
  String get discardReasonNonGirudaLow => 'Non-trump low card';

  @override
  String get discardReasonLowValue => 'Low value card';

  @override
  String get discardReasonLeastUseful => 'Least useful card';

  @override
  String get friendSummaryTitle => 'Friend Declaration';

  @override
  String get friendReasonNoFriendStrong => 'Strong hand, can win alone';

  @override
  String get friendReasonFirstTrick => 'First trick winner as friend';

  @override
  String get friendReasonNthTrick => 'Specific trick winner as friend';

  @override
  String get friendReasonNeedMighty => 'Need Mighty card owner as ally';

  @override
  String get friendReasonNeedJoker => 'Need Joker owner as ally';

  @override
  String get friendReasonNeedGirudaAce => 'Need trump Ace owner as ally';

  @override
  String get friendReasonNeedGirudaKing => 'Need trump King owner as ally';

  @override
  String get friendReasonNeedGirudaMid => 'Need trump mid-card owner as ally';

  @override
  String get friendReasonNeedAce => 'Ace owner designated as friend';

  @override
  String get friendReasonNeedStrongCard =>
      'Strong card owner designated as friend';

  @override
  String get friendReasonNoFriendAll => 'Holds all key cards, no friend needed';

  @override
  String get bidSummaryTitle => 'Bidding Result';

  @override
  String get bidSummaryEstimatedRange => 'Estimated Points (Declarer)';

  @override
  String bidSummaryEstMax(int points) {
    return 'Max ($points pts)';
  }

  @override
  String get bidSummaryEstMaxDesc => 'With friend, maintaining lead';

  @override
  String bidSummaryEstMin(int points) {
    return 'Min ($points pts)';
  }

  @override
  String get bidSummaryEstMinDesc => 'Without friend help (joker called, etc.)';

  @override
  String bidSummaryEstMinDescDynamic(String friend) {
    return 'Friend ($friend) basic only, may be in kitty';
  }

  @override
  String get bidSummaryMultipliers => 'Declarer ×2, Friend ×1, Defender ×(-1)';

  @override
  String get firstTrickStrategy => 'First Trick Strategy';

  @override
  String get scoreStrategy => 'Scoring Strategy';

  @override
  String get firstTrickAce => 'Lead with non-trump Ace for a guaranteed trick';

  @override
  String get firstTrickKing =>
      'Lead with non-trump King to attempt a trick win';

  @override
  String get firstTrickMighty =>
      'Lead with Mighty for a guaranteed first trick';

  @override
  String get firstTrickGiveUp => 'No strong lead card, play low to gather info';

  @override
  String get strategyMighty => 'Mighty guarantees one trick';

  @override
  String get strategyJoker => 'Joker allows winning a trick at any time';

  @override
  String get strategyGirudaDominant => '5+ trump cards ensure trump dominance';

  @override
  String get strategyGirudaSupport => '3+ trump cards provide trump support';

  @override
  String get strategyMultiAce => 'Multiple Aces enable winning several tricks';

  @override
  String get strategySingleAce => 'One Ace provides an extra trick opportunity';

  @override
  String get strategyCut => 'Short suit enables trump cut';

  @override
  String bidInfoGirudaKeys(String keys) {
    return 'Trump $keys';
  }

  @override
  String bidInfoFriend(String card) {
    return 'Friend: $card';
  }

  @override
  String bidInfoHasBoth(String card1, String card2) {
    return 'Has $card1·$card2';
  }

  @override
  String bidInfoHasCard(String card) {
    return 'Has $card';
  }

  @override
  String bidInfoFirstTrickAces(String aces) {
    return '1st trick $aces';
  }

  @override
  String get jokerOwner => 'Joker Owner';

  @override
  String get friendBadge => 'Friend';

  @override
  String get kittyLabel => 'Kitty ';

  @override
  String kittyPointsWithFriend(int points) {
    return ' ${points}pts (friend kitty)';
  }

  @override
  String kittyPoints(int points) {
    return ' ${points}pts';
  }

  @override
  String friendWithName(String name) {
    return 'Friend $name ';
  }

  @override
  String adjustedPointsRange(int min, int max) {
    return '→ Adj. $min~${max}pts';
  }

  @override
  String get hasAceNote => ' (Has Ace)';

  @override
  String strategyFirstTrickAceLead(String card) {
    return '1st trick: Lead $card for a guaranteed trick win';
  }

  @override
  String get strategyFirstTrickPassFriendWin =>
      '1st trick: Lead low in a short suit to pass lead to friend (friend wins trick)';

  @override
  String strategyFirstTrickKingLead(String card) {
    return '1st trick: Lead $card to attempt a trick win';
  }

  @override
  String get strategyFirstTrickPassFriend =>
      '1st trick: Lead low in a short suit to pass lead to friend';

  @override
  String get strategyPassToMightyFriend =>
      'Lead low in a short suit to pass lead to friend (Mighty)';

  @override
  String get strategyPassToJokerFriend =>
      'Lead low in a short suit to pass lead to friend (Joker)';

  @override
  String strategyPassTrumpToFriend(
    String passCard,
    String friendCard,
    String rank,
  ) {
    return 'Lead $passCard to pass to friend ($friendCard) → prevent $rank solo';
  }

  @override
  String strategyPassSuitToFriend(String card, String friendCard) {
    return 'Lead $card to pass to friend ($friendCard)';
  }

  @override
  String get strategySourceFriend => 'After friend trick,';

  @override
  String get strategySourceReclaim => 'After reclaiming lead,';

  @override
  String strategyTrumpDominate(String source, String cards) {
    return '$source dominate with $cards → exhaust defenders\' trumps';
  }

  @override
  String strategyTrumpExhaust(String source, String cards) {
    return '$source use $cards to exhaust defenders\' trumps';
  }

  @override
  String strategyTrumpMidDraw(String suit) {
    return 'Use $suit mid-trumps to draw out defenders\' high trumps';
  }

  @override
  String strategyJokerCallSuits(String suits) {
    return 'After exhausting defenders\' trumps, call Joker on weak suit ($suits)';
  }

  @override
  String get strategyJokerCallWeak =>
      'After exhausting defenders\' trumps, call Joker on a weak suit';

  @override
  String get strategyJokerOptimal =>
      'Use Joker to win a trick at the optimal timing';

  @override
  String get strategyMightyTiming =>
      'Play Mighty on trick 9 → secure lead for trick 10';

  @override
  String strategyVoidTrumpCut(String suits) {
    return '$suits void → trump cut to reclaim tricks when opponents lead';
  }

  @override
  String strategyTrumpExhaustCheckK(String cards) {
    return 'Lead $cards → top trump attack, check K exhaustion';
  }

  @override
  String get strategyJokerAfterFriend =>
      'After friend joins, lead Joker → score points';

  @override
  String strategyJokerCallGiruda(String suit) {
    return 'If K not exhausted, Joker: call $suit → draw out K';
  }

  @override
  String strategyLowGirudaFriendLure(String card) {
    return 'Lead $card → yield lead to lure friend';
  }

  @override
  String strategyGirudaQReclaim(String card) {
    return 'Lead $card → reclaim lead';
  }

  @override
  String strategyHighCardAttack(String cards) {
    return 'Lead $cards → additional score attack';
  }

  @override
  String get trickDetails => 'Trick Details';

  @override
  String get trickColumnGainLoss => 'Gain/\nLoss';

  @override
  String get trickColumnGiruda => 'Trump';

  @override
  String get trickColumnEvent => 'Event';

  @override
  String get trickLegendLead => 'Lead';

  @override
  String get trickLegendWinner => 'Winner';

  @override
  String get trickEventLastCard => 'Last card';

  @override
  String get trickEventLastAttackTopCardWin => 'Attack wins with top card';

  @override
  String get trickEventLastTrickGiruda => 'Trump last trick';

  @override
  String get trickEventLastTrickMighty => 'Mighty last trick';

  @override
  String trickEventLastTrickTopByExhaust(String card) {
    return 'Suit exhausted → $card top card lead';
  }

  @override
  String get trickEventGameVictory => 'Attack victory';

  @override
  String get trickEventGameRunVictory => 'Attack run (sweep) victory!';

  @override
  String get trickEventGameDefeat => 'Attack defeat';

  @override
  String get trickEventSummaryRun => 'Review: Sweep run, dominant win';

  @override
  String trickEventSummaryBackRun(int bid) {
    return 'Review: Swept back-run 0/${bid}pts, shutout';
  }

  @override
  String trickEventSummaryBigWin(int wins, int losses, int points, int bid) {
    return 'Review: ${wins}W${losses}L $points/${bid}pts, dominant win';
  }

  @override
  String trickEventSummaryWin(int wins, int losses, int points, int bid) {
    return 'Review: ${wins}W${losses}L $points/${bid}pts, victory';
  }

  @override
  String trickEventSummaryNarrowLoss(
    int wins,
    int losses,
    int points,
    int bid,
  ) {
    return 'Review: ${wins}W${losses}L $points/${bid}pts, narrow loss';
  }

  @override
  String trickEventSummaryBigLoss(int wins, int losses, int points, int bid) {
    return 'Review: ${wins}W${losses}L $points/${bid}pts, big loss';
  }

  @override
  String get summaryJokerCounter => 'Joker counter';

  @override
  String get summaryJokerUse => 'Joker play';

  @override
  String get summaryWasteExploit => 'Waste exploit success';

  @override
  String get summaryTrumpDominate => 'Trump domination';

  @override
  String get summaryFriendContrib => 'Friend MVP';

  @override
  String get summaryLateDefense => 'Late-game defense';

  @override
  String get summaryDefenseCut => 'Defense trump cuts';

  @override
  String get summaryMightyImpact => 'Mighty impact';

  @override
  String get summaryJokerMightyNoExtra => 'Joker/Mighty extra score shortage';

  @override
  String get summaryJokerMightyLost => 'Joker/Mighty score failure';

  @override
  String get summaryDefenseHighValueBlock =>
      'Defense blocked high-value tricks, attack score insufficient';

  @override
  String get summaryEarlyLeadLostLate =>
      'Early lead loss delayed reclaim, limited Joker/Mighty impact';

  @override
  String get summaryLateLeadLostGirudaExhaust =>
      'Early trump/friend exhaustion, lost lead in late game';

  @override
  String get summaryEarlyCutMightyExtract =>
      'Early cut + mighty forced out critical loss';

  @override
  String get summaryNineWinWasteFail =>
      'Review: 9 tricks secured, run missed due to failed dump handling';

  @override
  String get summaryNineWinRunMiss =>
      'Review: 9 tricks secured / run missed by 1 trick';

  @override
  String get summaryNineWinFirstTrickCut =>
      'Review: 9 tricks secured / run missed by 1 trick due to unlucky first-trick trump cut';

  @override
  String get summaryDefenseJokerGirudaCounter =>
      'Defense joker assault → trump counterattack';

  @override
  String summaryNarrative(String events, String result) {
    return 'Review: $events → $result';
  }

  @override
  String get summaryResultBigWin => 'attack dominant win';

  @override
  String get summaryResultMinGoal => 'minimum goal achieved';

  @override
  String get summaryResultWin => 'attack success';

  @override
  String get summaryResultNarrowLoss => 'defense wins';

  @override
  String get summaryResultBigLoss => 'defense dominates';

  @override
  String get summaryAnd => ' & ';

  @override
  String summaryFallback(
    int wins,
    int losses,
    int points,
    int bid,
    String result,
  ) {
    return 'Review: ${wins}W${losses}L → $points/${bid}pts $result';
  }

  @override
  String get trickEventLastCardDefenseWin => 'Defense higher card guard';

  @override
  String get trickEventLastDefenseTopProtectFail =>
      'Defense top card saved but defense failed';

  @override
  String get trickEventLastCardAttackWin => 'Attack points gained';

  @override
  String get trickEventJokerLead => 'Joker lead';

  @override
  String trickEventJokerLeadSuit(String suit) {
    return 'Joker lead ($suit)';
  }

  @override
  String get trickEventJokerGirudaExhaust => 'Forcing defenders to spend trump';

  @override
  String get trickEventMightyLead => 'Mighty lead';

  @override
  String get trickEventTopGirudaLead => 'Top trump lead';

  @override
  String get trickEventTopGirudaLeadOpponentExhausted =>
      'Opponents out of trumps → lead non-trump, save trump for cutting';

  @override
  String get trickEventMidGirudaMightyBait => 'Mid trump to bait Mighty';

  @override
  String trickEventMidGirudaMightyBaitForTop(String topCard) {
    return 'Low trump to bait Mighty, securing $topCard dominance';
  }

  @override
  String get trickEventMidGirudaPassLead => 'Mid trump to pass lead';

  @override
  String get trickEventFriendAttackDeclarerReOvertake =>
      'Friend attacks → Defense overtake attempt → Declarer re-overtakes (lucky)';

  @override
  String trickEventGirudaDepletionFail(String card) {
    return 'Failed to flush $card';
  }

  @override
  String get trickEventDefenderGirudaWin => 'Defender trump win';

  @override
  String get trickEventMidGirudaLead => 'Mid trump lead';

  @override
  String get trickEventMidGirudaExhaust => 'Trump exhaustion play';

  @override
  String get trickEventSoleGirudaLeadMaintain =>
      'Attack sole trump holder, lead maintained';

  @override
  String get trickEventTopNonGirudaLead => 'Top non-trump lead';

  @override
  String get trickEventDefenseTopCardDefend => 'Defense top card point guard';

  @override
  String get trickEventDefenseHighCardDefend => 'Defense high card point guard';

  @override
  String get trickEventJokerAttackReclaim => 'Joker reclaimed lead for attack';

  @override
  String get trickEventMightyAttackReclaim =>
      'Mighty reclaimed lead for attack';

  @override
  String get trickEventAttackReclaim => 'Attack reclaimed lead';

  @override
  String get trickEventDefenseTopDeclarerCutDefense =>
      'Defense top lead → Declarer trump cut → Defense higher trump guard';

  @override
  String get trickEventDefenseTopDeclarerCutTeamDefense =>
      'Defense top lead → Declarer trump cut → Defense team trump guard';

  @override
  String get trickEventDefenseLeadAttackCut =>
      'Defense non-trump top lead → Attack trump cut reclaim';

  @override
  String trickEventDefenseTopAttackCutPointsFailed(int count) {
    return 'Defense top lead → Declarer trump cut, ${count}pts defense failed';
  }

  @override
  String get trickEventAttackLeadDefenseCut =>
      'Attack non-trump top lead → Defense trump cut';

  @override
  String get trickEventTopNonGirudaLeadDefended =>
      'Non-trump lead → defense higher card';

  @override
  String get trickEventFirstTrickTopAttack => '1st trick top non-trump lead';

  @override
  String get trickEventFirstTrickTopTeamRescue =>
      '1st trick top non-trump → team rescue';

  @override
  String get trickEventFirstTrickTopAttackFailed =>
      '1st trick top non-trump lead failed';

  @override
  String get trickEventFirstTrickMightyBait =>
      'No lead in 1st trick / Mighty friend bait';

  @override
  String get trickEventFirstTrickFriendBait =>
      'No 1st trick card, waste → Fortunately friend wins';

  @override
  String get trickEventFirstTrickWaste => 'No lead in 1st trick / Waste';

  @override
  String get trickEventAttackFailed =>
      'Attack failed → lost to higher defense card';

  @override
  String trickEventAttackFailedWithTop(String topCard) {
    return 'Attack ($topCard top) failed → lost to defense';
  }

  @override
  String get trickEventWaste => 'Passing lead with waste';

  @override
  String get trickEventWasteAttackFailed => 'Waste attack failed';

  @override
  String get trickEventPreExchange => 'Lead exchange (preserve trump)';

  @override
  String get trickEventPreExchangeKept =>
      'Lead exchange (preserve trump) → lead kept';

  @override
  String get trickEventFriendPassLeadFailed => 'Lead pass failed';

  @override
  String get trickEventDefenseLead => 'Defense lead';

  @override
  String trickEventWasteWithTop(String topCard) {
    return 'Waste ($topCard is top)';
  }

  @override
  String get trickEventWasteDeclarerReclaim => 'Waste → Declarer reclaim';

  @override
  String trickEventWasteDeclarerReclaimWithTop(String topCard) {
    return 'Waste ($topCard top) → Declarer reclaim';
  }

  @override
  String get trickEventFriendWasteDeclarerCutDefenseOvercut =>
      'Friend waste → Declarer trump cut → Defense higher trump reversal';

  @override
  String trickEventFriendWasteDeclarerCutDefenseOvercutPoints(int count) {
    return 'Friend waste → Declarer trump cut → Defense higher trump reversal, ${count}pts defended';
  }

  @override
  String get trickEventFriendWasteDeclarerHighDefenseReversal =>
      'Friend waste → Declarer high card → Defense reversal';

  @override
  String get trickEventDefenseWasteAttackReverseDefenseCut =>
      'Defense waste → Attack reversal → Defense cut re-reversal';

  @override
  String get trickEventFriendLeadDefenseBeatDeclarerCut =>
      'Friend lead → Defense beats → Declarer trump cut reversal';

  @override
  String get trickEventDeclarerFriendLure => 'Friend lure';

  @override
  String get trickEventDeclarerFriendLureFailed => 'Friend lure failed';

  @override
  String trickEventFriendLureGirudaExhaust(String card) {
    return 'Defense trump $card exhausted';
  }

  @override
  String get trickEventWasteFriendRescue => 'Waste → Friend rescue!';

  @override
  String trickEventWasteFriendRescueWithTop(String topCard) {
    return 'Waste ($topCard top) → Friend rescue!';
  }

  @override
  String get trickEventFriendMightyReclaim =>
      'Waste → Friend reclaims lead with Mighty';

  @override
  String trickEventFriendMightyReclaimWithTop(String topCard) {
    return 'Waste ($topCard top) → Friend reclaims lead with Mighty';
  }

  @override
  String get trickEventAttackGirudaCut => 'Attack trump cut';

  @override
  String trickEventAttackGirudaCutCount(int count) {
    return 'Attack trump cut x$count';
  }

  @override
  String get trickEventSameTeamGirudaCut => 'Same-team trump cut (forced)';

  @override
  String get trickEventDefenseGirudaCut => 'Defense trump cut';

  @override
  String trickEventDefenseGirudaCutCount(int count) {
    return 'Defense trump cut x$count';
  }

  @override
  String get trickEventDefenseCutAttackOvercut =>
      'Defense 1st cut → Attack higher trump overcut';

  @override
  String get trickEventAttackCutDefenseOvercut =>
      'Attack 1st cut → Defense higher trump defense';

  @override
  String get trickEventAttackNoGirudaDefenseHas =>
      'Attack out of trump / Defense still has trump';

  @override
  String get trickEventNonGirudaExhaust => 'Non-trump exhausted';

  @override
  String get trickEventJokerCallDeclared => 'Joker Call';

  @override
  String get trickEventJokerCallAllyJoker => 'Ally Joker sacrificed';

  @override
  String get trickEventJokerCallEnemyJoker => 'Enemy Joker exhausted';

  @override
  String get trickEventGirudaKExhaustSuccess => 'K exhausted';

  @override
  String get trickEventGirudaKQExhaustSuccess => 'K/Q both exhausted!';

  @override
  String get trickEventDefenseJokerRunBlock => 'Defense Joker blocks run';

  @override
  String get trickEventDefenseJokerCounterattack =>
      'Mighty gone → Defense Joker counterattack';

  @override
  String get trickEventDefenseMightyExhaust => 'Defense mighty exhaust success';

  @override
  String get trickEventDefenseMightySuitBait =>
      'Mighty suit lead (mighty bait)';

  @override
  String get trickEventDefenseMightySuitBaitSuccess =>
      'Mighty suit lead / mighty bait success';

  @override
  String get trickEventDefenseMightySuitBaitFailed =>
      'Mighty suit lead / mighty bait failed (attack reclaimed)';

  @override
  String trickEventDefenseMightyExhaustPoints(int count) {
    return 'Defense mighty exhaust, ${count}pts lost';
  }

  @override
  String trickEventJokerAfterFriend(String suit) {
    return 'Joker after friend joined ($suit) → score';
  }

  @override
  String get trickEventJokerAfterFriendGeneral =>
      'Joker after friend joined → score';

  @override
  String get trickEventGirudaQReclaimSuccess => 'Trump Q → lead reclaimed';

  @override
  String get trickEventGirudaQReclaimFail =>
      'Trump Q reclaim failed, defense wins';

  @override
  String get trickEventHighCardAttack => 'Top non-trump lead';

  @override
  String get trickEventHighCardAttackFailed =>
      'Non-trump lead → defense won with higher card';

  @override
  String trickResultAttack(int count) {
    return '→ Attack +$count';
  }

  @override
  String trickResultDefense(int count) {
    return '→ Defense +$count';
  }

  @override
  String get trickResultNoScore => '→ No score';

  @override
  String get trickMightyAppeared => 'Mighty appeared';

  @override
  String get trickJokerAppeared => 'Joker appeared';

  @override
  String get trickFriendJoined => 'Friend joined';

  @override
  String get trickEventFriendTopCardWin => 'Friend top card win';

  @override
  String get trickEventFriendGirudaKDeclarerA =>
      'Friend giruda K win, declarer has A - attack giruda dominance';

  @override
  String trickEventFriendTrickContribution(int count) {
    return 'Friend helped $count attack tricks';
  }

  @override
  String trickEventJokerSkipNoPoints(String name) {
    return '$name: held Joker, skipped (no points)';
  }

  @override
  String trickEventGirudaAceHeldMightyGuard(String name) {
    return '$name: held trump A, guarding against Mighty';
  }

  @override
  String trickEventGirudaAceHeld(String name) {
    return '$name: held trump A, not played';
  }

  @override
  String get adviceFirstTrickLowLead =>
      '💡 Lead with an Ace or Mighty on the first trick to secure initiative';

  @override
  String get adviceLowLeadPointLoss =>
      '💡 Leading with a card that can\'t win gives points to defense';

  @override
  String get adviceAceBeatenByJoker =>
      '💡 Leading an Ace is risky when the defense Joker hasn\'t been played yet';

  @override
  String get advicePointCardToDefense =>
      '💡 Play non-point cards when defense is winning the trick';

  @override
  String get adviceMightyHighPointLoss =>
      '💡 When Mighty appears, minimize point cards in the trick';

  @override
  String get kittyTipTitle => '💡 Kitty Exchange Tips';

  @override
  String get kittyTipCreateVoid =>
      'Void a suit to cut with giruda and steal tricks';

  @override
  String get kittyTipKeepGiruda =>
      'Keep giruda (trump) cards whenever possible';

  @override
  String get kittyTipKeepTopCards =>
      'Keep suits where you hold the top card (e.g. Ace)';

  @override
  String get kittyTipDiscardLowSingles =>
      'Discard low cards from short suits first';

  @override
  String get kittyTipKeepMightySuitK =>
      'Without Mighty, keep Mighty-suit K — it can beat Mighty';

  @override
  String get friendTipTitle => '💡 Friend Declaration Tips';

  @override
  String get friendTipMighty =>
      'Mighty friend: makes the strongest card your ally';

  @override
  String get friendTipJoker =>
      'Joker friend: makes the second strongest card your ally';

  @override
  String get friendTipNoFriend =>
      'If you hold both Mighty and Joker, consider No Friend';

  @override
  String get friendTipWhoIsFriend =>
      'The player holding the declared card becomes your ally';

  @override
  String estimatedMinWins(int count) {
    return '→ $count+ wins expected';
  }

  @override
  String stepFirstAce(String card) {
    return 'Lead $card to maintain initiative on first trick';
  }

  @override
  String stepFirstKing(String card) {
    return 'Lead $card to maintain initiative (highest in Mighty suit)';
  }

  @override
  String get stepFirstMighty => 'Lead Mighty to secure first trick';

  @override
  String get stepFirstJoker => 'Lead Joker to secure first trick';

  @override
  String stepJokerCallExhaust(String card) {
    return 'After first trick, lead $card for Joker Call → exhaust Joker';
  }

  @override
  String stepGirudaAce(String card) {
    return 'Attack with $card as trump';
  }

  @override
  String stepGirudaAceCheckK(String card) {
    return 'Attack with $card as trump (check K exhaustion)';
  }

  @override
  String stepGirudaKing(String card) {
    return 'Additional trump attack with $card';
  }

  @override
  String stepJokerCallGiruda(String suit) {
    return 'If K not exhausted, call $suit with Joker to draw out K';
  }

  @override
  String get stepJokerAfterFriend =>
      'Score points with Joker after friend joins';

  @override
  String get stepFriendMightyJoin => 'Mighty friend joins on first trick';

  @override
  String get stepFriendJokerJoin =>
      'Joker friend naturally joins on trump lead';

  @override
  String stepLowGirudaFriendLure(
    String highCards,
    String card,
    String mightyCard,
  ) {
    return 'If $highCards not appeared, lure Mighty($mightyCard) with $card while attacking trump';
  }

  @override
  String stepGirudaQReclaim(String card) {
    return 'Reclaim lead with $card';
  }

  @override
  String stepGirudaLeadFriend(String friendCard) {
    return 'Lead trump to draw out $friendCard';
  }

  @override
  String stepJokerCallFriend(String friendCard) {
    return 'If $friendCard not appeared, call trump with Joker to lure friend';
  }

  @override
  String stepLureWithGiruda(String card, String friendCard) {
    return 'Still not appeared, lead $card to lure friend($friendCard)';
  }

  @override
  String stepSuitLeadFriend(String card, String friendCard) {
    return 'Lead $card to lure friend($friendCard)';
  }

  @override
  String stepJokerCall(String suits) {
    return 'Call $suits with Joker to secure point cards';
  }

  @override
  String get stepJokerOptimal => 'Use Joker at optimal timing to score points';

  @override
  String stepHighCardAttack(String cards) {
    return 'Score additional points with $cards';
  }

  @override
  String get stepMightyTiming =>
      'Use Mighty after trump exhaustion to secure trick';

  @override
  String stepVoidCut(String suits) {
    return 'Use $suits void for trump cut scoring';
  }

  @override
  String get stepEndgameScoring =>
      'Maximize point collection through endgame play';

  @override
  String get breakdownLowCards => 'low';

  @override
  String breakdownGirudaPart(
    String suit,
    String top,
    int count,
    String tricks,
  ) {
    return '$suit$top($count cards) $tricks tricks';
  }

  @override
  String breakdownMightyJokerPart(String tricks) {
    return 'Mighty+Joker $tricks tricks';
  }

  @override
  String breakdownMightyPart(String tricks) {
    return 'Mighty $tricks trick';
  }

  @override
  String breakdownJokerPart(String tricks) {
    return 'Joker $tricks trick';
  }

  @override
  String breakdownAcePart(String suit, String tricks) {
    return '${suit}A $tricks trick';
  }

  @override
  String breakdownFriendMightyPart(String suit, String tricks) {
    return 'Friend(${suit}A) $tricks trick';
  }

  @override
  String breakdownFriendJokerPart(String tricks) {
    return 'Friend(Joker) $tricks trick';
  }

  @override
  String suitChangeRecommend(String suit, int diff) {
    return '$suit +$diff pts (penalty +2 on change)';
  }

  @override
  String suitKeepRecommend(String suit, int diff) {
    return '$suit +$diff pts (keep is better considering penalty)';
  }

  @override
  String cardCount(int count) {
    return '$count cards';
  }
}
