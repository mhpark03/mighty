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
  String get tricks => 'Tricks';

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
}
