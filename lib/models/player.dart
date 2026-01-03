import 'card.dart';

enum PlayerType {
  human,
  ai,
}

enum Team {
  declarer,
  defender,
  unknown,
}

class Player {
  final int id;
  final String name;
  final PlayerType type;
  final List<PlayingCard> hand;
  final List<PlayingCard> wonCards;
  Team team;
  bool isDeclarer;
  bool isFriend;

  Player({
    required this.id,
    required this.name,
    this.type = PlayerType.ai,
    List<PlayingCard>? hand,
    List<PlayingCard>? wonCards,
    this.team = Team.unknown,
    this.isDeclarer = false,
    this.isFriend = false,
  })  : hand = hand ?? [],
        wonCards = wonCards ?? [];

  void addCard(PlayingCard card) {
    hand.add(card);
  }

  void addCards(List<PlayingCard> cards) {
    hand.addAll(cards);
  }

  void removeCard(PlayingCard card) {
    hand.remove(card);
  }

  void sortHand() {
    hand.sort((a, b) {
      if (a.isJoker) return -1;
      if (b.isJoker) return 1;
      if (a.suit != b.suit) {
        return a.suit!.index.compareTo(b.suit!.index);
      }
      return b.rankValue.compareTo(a.rankValue);
    });
  }

  bool hasCard(PlayingCard card) {
    return hand.contains(card);
  }

  bool hasSuit(Suit suit) {
    return hand.any((card) => !card.isJoker && card.suit == suit);
  }

  List<PlayingCard> getCardsOfSuit(Suit suit) {
    return hand.where((card) => !card.isJoker && card.suit == suit).toList();
  }

  int get pointsWon {
    return wonCards.where((card) => card.isPointCard).length;
  }

  void clearHand() {
    hand.clear();
  }

  void clearWonCards() {
    wonCards.clear();
  }

  void reset() {
    clearHand();
    clearWonCards();
    team = Team.unknown;
    isDeclarer = false;
    isFriend = false;
  }

  @override
  String toString() => name;
}
