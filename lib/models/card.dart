enum Suit {
  spade,
  diamond,
  heart,
  club,
}

enum Rank {
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
  ace,
}

class PlayingCard {
  final Suit? suit;
  final Rank? rank;
  final bool isJoker;

  const PlayingCard({
    this.suit,
    this.rank,
    this.isJoker = false,
  });

  factory PlayingCard.joker() => const PlayingCard(isJoker: true);

  bool get isMighty => suit == Suit.spade && rank == Rank.ace;

  bool get isPointCard {
    if (isJoker) return false;
    return rank == Rank.ace ||
        rank == Rank.king ||
        rank == Rank.queen ||
        rank == Rank.jack ||
        rank == Rank.ten;
  }

  int get pointValue {
    if (!isPointCard) return 0;
    return 1;
  }

  int get rankValue {
    if (isJoker) return 15;
    switch (rank!) {
      case Rank.two:
        return 2;
      case Rank.three:
        return 3;
      case Rank.four:
        return 4;
      case Rank.five:
        return 5;
      case Rank.six:
        return 6;
      case Rank.seven:
        return 7;
      case Rank.eight:
        return 8;
      case Rank.nine:
        return 9;
      case Rank.ten:
        return 10;
      case Rank.jack:
        return 11;
      case Rank.queen:
        return 12;
      case Rank.king:
        return 13;
      case Rank.ace:
        return 14;
    }
  }

  String get suitSymbol {
    if (isJoker) return '🃏';
    switch (suit!) {
      case Suit.spade:
        return '♠';
      case Suit.diamond:
        return '♦';
      case Suit.heart:
        return '♥';
      case Suit.club:
        return '♣';
    }
  }

  String get rankSymbol {
    if (isJoker) return 'Joker';
    switch (rank!) {
      case Rank.two:
        return '2';
      case Rank.three:
        return '3';
      case Rank.four:
        return '4';
      case Rank.five:
        return '5';
      case Rank.six:
        return '6';
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
      case Rank.ten:
        return '10';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
      case Rank.ace:
        return 'A';
    }
  }

  bool get isRed => suit == Suit.diamond || suit == Suit.heart;
  bool get isBlack => suit == Suit.spade || suit == Suit.club;

  @override
  String toString() {
    if (isJoker) return 'Joker';
    return '$suitSymbol$rankSymbol';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayingCard &&
        other.suit == suit &&
        other.rank == rank &&
        other.isJoker == isJoker;
  }

  @override
  int get hashCode => Object.hash(suit, rank, isJoker);
}

class Deck {
  final List<PlayingCard> cards = [];

  Deck() {
    _initializeDeck();
  }

  void _initializeDeck() {
    cards.clear();
    for (final suit in Suit.values) {
      for (final rank in Rank.values) {
        cards.add(PlayingCard(suit: suit, rank: rank));
      }
    }
    cards.add(PlayingCard.joker());
  }

  void shuffle() {
    cards.shuffle();
  }

  void reset() {
    _initializeDeck();
  }

  List<List<PlayingCard>> deal({int players = 5, int cardsPerPlayer = 10}) {
    shuffle();
    final hands = List.generate(players, (_) => <PlayingCard>[]);

    for (int i = 0; i < cardsPerPlayer * players; i++) {
      hands[i % players].add(cards[i]);
    }

    return hands;
  }

  List<PlayingCard> getKitty(int cardsDealt) {
    return cards.sublist(cardsDealt);
  }
}
