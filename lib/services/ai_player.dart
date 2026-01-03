import 'dart:math';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';

class AIPlayer {
  Bid decideBid(Player player, GameState state) {
    final hand = player.hand;
    int strength = _evaluateHandStrength(hand, state);

    if (state.currentBid != null) {
      if (strength < state.currentBid!.tricks + 1) {
        return Bid.pass(player.id);
      }
    }

    if (strength < 13) {
      return Bid.pass(player.id);
    }

    Suit? bestSuit = _findBestSuit(hand);
    int bidAmount = min(strength, 20);

    if (state.currentBid != null) {
      bidAmount = max(bidAmount, state.currentBid!.tricks + 1);
    }

    return Bid(
      playerId: player.id,
      suit: bestSuit,
      tricks: bidAmount,
    );
  }

  int _evaluateHandStrength(List<PlayingCard> hand, GameState state) {
    int strength = 0;

    bool hasMighty = hand.any((c) => c.isMighty);
    bool hasJoker = hand.any((c) => c.isJoker);

    // 마이티와 조커는 확실한 트릭
    if (hasMighty) strength += 3;
    if (hasJoker) strength += 2;

    // 각 무늬별로 고위 카드 평가
    for (final suit in Suit.values) {
      final suitCards = hand.where((c) => !c.isJoker && c.suit == suit).toList();
      if (suitCards.isEmpty) continue;

      // 해당 무늬의 A, K, Q, J 보유 확인
      bool hasAce = suitCards.any((c) => c.rank == Rank.ace && !c.isMighty);
      bool hasKing = suitCards.any((c) => c.rank == Rank.king);
      bool hasQueen = suitCards.any((c) => c.rank == Rank.queen);
      bool hasJack = suitCards.any((c) => c.rank == Rank.jack);

      int highCards = 0;
      if (hasAce) highCards++;
      if (hasKing) highCards++;
      if (hasQueen) highCards++;
      if (hasJack) highCards++;

      // 고위 카드 개수에 따른 점수
      if (highCards >= 3) {
        // A-K-Q 또는 A-K-J 등 3장 이상이면 강력
        strength += highCards + 2;
      } else if (highCards == 2) {
        // A-K, A-Q 등 2장이면 좋음
        strength += 2;
      } else if (hasAce || hasKing) {
        // A 또는 K 1장만 있으면 약간의 점수
        strength += 1;
      }

      // 같은 무늬 장수 보너스 (고위 카드가 있을 때만)
      if (highCards >= 2 && suitCards.length >= 5) {
        strength += suitCards.length - 4;
      }
    }

    // 기본 점수 추가 (최소한의 베이스)
    strength += 8;

    return strength;
  }

  Suit? _findBestSuit(List<PlayingCard> hand) {
    Map<Suit, int> suitStrength = {};

    for (final suit in Suit.values) {
      int strength = 0;
      final suitCards = hand.where((c) => !c.isJoker && c.suit == suit).toList();

      if (suitCards.isEmpty) {
        suitStrength[suit] = 0;
        continue;
      }

      // 고위 카드 확인
      bool hasAce = suitCards.any((c) => c.rank == Rank.ace && !c.isMighty);
      bool hasKing = suitCards.any((c) => c.rank == Rank.king);
      bool hasQueen = suitCards.any((c) => c.rank == Rank.queen);
      bool hasJack = suitCards.any((c) => c.rank == Rank.jack);

      // 고위 카드에 높은 가중치
      if (hasAce) strength += 10;
      if (hasKing) strength += 8;
      if (hasQueen) strength += 6;
      if (hasJack) strength += 4;

      // 장수 보너스 (고위 카드가 있을 때 더 가치 있음)
      int highCardCount = (hasAce ? 1 : 0) + (hasKing ? 1 : 0) +
                          (hasQueen ? 1 : 0) + (hasJack ? 1 : 0);
      if (highCardCount >= 2) {
        strength += suitCards.length * 3;
      } else {
        strength += suitCards.length;
      }

      suitStrength[suit] = strength;
    }

    Suit? bestSuit;
    int maxStrength = 0;

    for (final entry in suitStrength.entries) {
      if (entry.value > maxStrength) {
        maxStrength = entry.value;
        bestSuit = entry.key;
      }
    }

    return bestSuit;
  }

  List<PlayingCard> selectKittyCards(Player player, GameState state) {
    final hand = List<PlayingCard>.from(player.hand);
    hand.sort((a, b) {
      if (a.isJoker || a.isMighty) return 1;
      if (b.isJoker || b.isMighty) return -1;

      if (state.giruda != null) {
        if (a.suit == state.giruda && b.suit != state.giruda) return 1;
        if (a.suit != state.giruda && b.suit == state.giruda) return -1;
      }

      if (a.isPointCard && !b.isPointCard) return 1;
      if (!a.isPointCard && b.isPointCard) return -1;

      return a.rankValue.compareTo(b.rankValue);
    });

    return hand.take(3).toList();
  }

  FriendDeclaration declareFriend(Player player, GameState state) {
    final hand = player.hand;

    bool hasMighty = hand.any((c) => c.isMighty);
    if (!hasMighty) {
      return FriendDeclaration.byCard(state.mighty);
    }

    bool hasJoker = hand.any((c) => c.isJoker);
    if (!hasJoker) {
      return FriendDeclaration.byCard(PlayingCard.joker());
    }

    for (final suit in Suit.values) {
      final ace = PlayingCard(suit: suit, rank: Rank.ace);
      if (!hand.contains(ace) && ace != state.mighty) {
        return FriendDeclaration.byCard(ace);
      }
    }

    return FriendDeclaration.firstTrickWinner();
  }

  PlayingCard selectCard(Player player, GameState state) {
    final playableCards = player.hand
        .where((card) => state.canPlayCard(card, player))
        .toList();

    if (playableCards.isEmpty) {
      return player.hand.first;
    }

    if (playableCards.length == 1) {
      return playableCards.first;
    }

    if (state.currentTrick == null || state.currentTrick!.cards.isEmpty) {
      return _selectLeadCard(playableCards, player, state);
    } else {
      return _selectFollowCard(playableCards, player, state);
    }
  }

  PlayingCard _selectLeadCard(
      List<PlayingCard> playableCards, Player player, GameState state) {
    playableCards.sort((a, b) {
      if (a.isMighty) return -1;
      if (b.isMighty) return 1;

      if (state.giruda != null) {
        if (a.suit == state.giruda && b.suit != state.giruda) return -1;
        if (a.suit != state.giruda && b.suit == state.giruda) return 1;
      }

      return b.rankValue.compareTo(a.rankValue);
    });

    if (state.currentTrickNumber > 1) {
      final nonJokerMighty =
          playableCards.where((c) => !c.isJoker && !c.isMighty).toList();
      if (nonJokerMighty.isNotEmpty) {
        return nonJokerMighty.first;
      }
    }

    return playableCards.first;
  }

  PlayingCard _selectFollowCard(
      List<PlayingCard> playableCards, Player player, GameState state) {
    final leadSuit = state.currentTrick!.leadSuit;
    final currentWinningCard = _findCurrentWinningCard(state);

    final suitCards =
        playableCards.where((c) => !c.isJoker && c.suit == leadSuit).toList();

    if (suitCards.isNotEmpty) {
      suitCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));

      for (final card in suitCards) {
        if (currentWinningCard != null &&
            state.isCardStronger(card, currentWinningCard, leadSuit, false)) {
          return card;
        }
      }

      return suitCards.last;
    }

    if (state.giruda != null) {
      final girudaCards =
          playableCards.where((c) => !c.isJoker && c.suit == state.giruda).toList();

      if (girudaCards.isNotEmpty) {
        girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));

        bool worthTrumping = state.currentTrick!.cards.any((c) => c.isPointCard);
        if (worthTrumping) {
          return girudaCards.first;
        }
      }
    }

    final nonPointCards = playableCards.where((c) => !c.isPointCard).toList();
    if (nonPointCards.isNotEmpty) {
      nonPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
      return nonPointCards.first;
    }

    playableCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
    return playableCards.first;
  }

  PlayingCard? _findCurrentWinningCard(GameState state) {
    if (state.currentTrick == null || state.currentTrick!.cards.isEmpty) {
      return null;
    }

    PlayingCard? winning;
    final leadSuit = state.currentTrick!.leadSuit;

    for (final card in state.currentTrick!.cards) {
      if (winning == null) {
        winning = card;
      } else if (state.isCardStronger(card, winning, leadSuit, false)) {
        winning = card;
      }
    }

    return winning;
  }
}
