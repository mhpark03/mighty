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
  String name;
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

  // 딜 미스 선언 가능 여부 확인
  // 조건: 점수 카드가 없거나, 조커 1장 + 점수 카드 1장만 있을 때
  bool get canDeclareDealMiss {
    final pointCards = hand.where((c) => c.isPointCard).toList();
    final hasJoker = hand.any((c) => c.isJoker);

    // 점수 카드가 없으면 딜 미스 가능
    if (pointCards.isEmpty) {
      return true;
    }

    // 조커가 있고 점수 카드가 정확히 1장이면 딜 미스 가능
    if (hasJoker && pointCards.length == 1) {
      return true;
    }

    return false;
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

  // JSON 직렬화
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.index,
    'hand': hand.map((c) => c.toJson()).toList(),
    'wonCards': wonCards.map((c) => c.toJson()).toList(),
    'team': team.index,
    'isDeclarer': isDeclarer,
    'isFriend': isFriend,
  };

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'],
      name: json['name'],
      type: PlayerType.values[json['type']],
      hand: (json['hand'] as List).map((c) => PlayingCard.fromJson(c)).toList(),
      wonCards: (json['wonCards'] as List).map((c) => PlayingCard.fromJson(c)).toList(),
      team: Team.values[json['team']],
      isDeclarer: json['isDeclarer'],
      isFriend: json['isFriend'],
    );
  }
}
