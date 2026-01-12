import 'dart:math';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';

class AIPlayer {
  // 이미 플레이된 모든 카드 가져오기
  List<PlayingCard> _getPlayedCards(GameState state) {
    List<PlayingCard> playedCards = [];

    // 완료된 트릭에서 카드 수집
    for (final trick in state.tricks) {
      playedCards.addAll(trick.cards);
    }

    // 현재 트릭에서 이미 나온 카드 수집
    if (state.currentTrick != null) {
      playedCards.addAll(state.currentTrick!.cards);
    }

    return playedCards;
  }

  // 특정 무늬에서 플레이된 카드 가져오기
  List<PlayingCard> _getPlayedCardsOfSuit(GameState state, Suit suit) {
    return _getPlayedCards(state)
        .where((c) => !c.isJoker && c.suit == suit)
        .toList();
  }

  // 오픈된 기루다 수 계산
  int _getPlayedGirudaCount(GameState state) {
    if (state.giruda == null) return 0;
    return _getPlayedCardsOfSuit(state, state.giruda!).length;
  }

  // 남은 기루다 수 계산 (전체 13장 - 오픈된 수 - 내 손에 있는 수)
  int _getRemainingGirudaCount(GameState state, Player player) {
    if (state.giruda == null) return 0;
    final playedCount = _getPlayedGirudaCount(state);
    final myCount = player.hand.where((c) =>
        !c.isJoker && c.suit == state.giruda).length;
    return 13 - playedCount - myCount;
  }

  // 기루다가 초반인지 확인 (상대가 가진 기루다가 7장 초과)
  bool _isEarlyGirudaPhase(GameState state, Player player) {
    final remaining = _getRemainingGirudaCount(state, player);
    return remaining > 7;
  }

  // 기루다가 후반인지 확인 (상대가 가진 기루다가 7장 이하)
  bool _isLateGirudaPhase(GameState state, Player player) {
    final remaining = _getRemainingGirudaCount(state, player);
    return remaining <= 7;
  }

  // 컷된 무늬 목록 가져오기 (기루다로 다른 무늬가 이겨진 경우)
  Set<Suit> _getCutSuits(GameState state) {
    Set<Suit> cutSuits = {};
    if (state.giruda == null) return cutSuits;

    for (final trick in state.tricks) {
      if (trick.leadSuit == null || trick.winnerId == null) continue;

      // 리드 무늬가 기루다가 아닌 경우
      if (trick.leadSuit != state.giruda) {
        // 이긴 카드 찾기
        int winnerIndex = trick.playerOrder.indexOf(trick.winnerId!);
        if (winnerIndex >= 0 && winnerIndex < trick.cards.length) {
          PlayingCard winningCard = trick.cards[winnerIndex];
          // 이긴 카드가 기루다이고 마이티/조커가 아닌 경우 = 컷
          if (!winningCard.isJoker && !winningCard.isMighty &&
              winningCard.suit == state.giruda) {
            cutSuits.add(trick.leadSuit!);
          }
        }
      }
    }
    return cutSuits;
  }

  // 특정 무늬가 컷된 적이 있는지 확인
  bool _wasSuitCut(GameState state, Suit suit) {
    return _getCutSuits(state).contains(suit);
  }

  // 주공이 특정 무늬가 없는지 확인 (컷한 이력으로 판단)
  Set<Suit> _getDeclarerVoidSuits(GameState state) {
    Set<Suit> voidSuits = {};
    if (state.declarerId == null || state.giruda == null) return voidSuits;

    for (final trick in state.tricks) {
      if (trick.leadSuit == null) continue;
      Suit leadSuit = trick.leadSuit!;

      // 주공이 리드 무늬가 아닌 카드를 낸 경우 = 해당 무늬가 없음
      int declarerIndex = trick.playerOrder.indexOf(state.declarerId!);
      if (declarerIndex >= 0 && declarerIndex < trick.cards.length) {
        PlayingCard card = trick.cards[declarerIndex];
        if (!card.isJoker) {
          // 리드 무늬와 다른 무늬를 냈으면 리드 무늬가 없는 것
          if (card.suit != leadSuit) {
            voidSuits.add(leadSuit);
          }
        }
      }
    }
    return voidSuits;
  }

  // 카드의 실효 가치 계산 (오픈된 카드 고려)
  // A가 오픈되면 K가 가장 높은 카드가 됨 -> K의 가치 = A의 가치
  int _getEffectiveCardValue(PlayingCard card, GameState state) {
    if (card.isJoker || card.isMighty) {
      return 100; // 조커/마이티는 최고 가치
    }

    final suit = card.suit!;
    final playedCardsOfSuit = _getPlayedCardsOfSuit(state, suit);

    // 해당 무늬에서 이 카드보다 높은 카드 중 이미 나온 카드 수 계산
    int higherCardsPlayed = 0;

    // A(14), K(13), Q(12), J(11), 10(10) ... 순서
    for (int rankValue = 14; rankValue > card.rankValue; rankValue--) {
      Rank rank = _rankFromValue(rankValue);
      bool isPlayed = playedCardsOfSuit.any((c) => c.rank == rank);
      if (isPlayed) {
        higherCardsPlayed++;
      }
    }

    // 실효 가치 = 원래 가치 + 나간 상위 카드 수
    // 예: A가 나갔으면 K의 실효 가치 = 13 + 1 = 14 (A와 동급)
    return card.rankValue + higherCardsPlayed;
  }

  // rankValue로 Rank 찾기
  Rank _rankFromValue(int value) {
    switch (value) {
      case 14: return Rank.ace;
      case 13: return Rank.king;
      case 12: return Rank.queen;
      case 11: return Rank.jack;
      case 10: return Rank.ten;
      case 9: return Rank.nine;
      case 8: return Rank.eight;
      case 7: return Rank.seven;
      case 6: return Rank.six;
      case 5: return Rank.five;
      case 4: return Rank.four;
      case 3: return Rank.three;
      default: return Rank.two;
    }
  }

  // 해당 무늬에서 현재 가장 높은 카드인지 확인
  bool _isHighestRemainingCard(PlayingCard card, GameState state, List<PlayingCard> hand) {
    if (card.isJoker || card.isMighty) return true;

    final suit = card.suit!;
    final playedCardsOfSuit = _getPlayedCardsOfSuit(state, suit);

    // 이 카드보다 높은 카드가 있는지 확인 (플레이되지 않은 카드 중)
    for (int rankValue = 14; rankValue > card.rankValue; rankValue--) {
      Rank rank = _rankFromValue(rankValue);

      // 이미 플레이된 카드는 스킵
      bool isPlayed = playedCardsOfSuit.any((c) => c.rank == rank);
      if (isPlayed) continue;

      // 내 손에 있는 카드는 스킵
      bool inMyHand = hand.any((c) => !c.isJoker && c.suit == suit && c.rank == rank);
      if (inMyHand) continue;

      // 마이티 체크 (마이티가 나갔거나 내 손에 있으면 스킵)
      final mightyCard = state.mighty;
      if (!mightyCard.isJoker && mightyCard.suit == suit && mightyCard.rank == rank) {
        bool mightyPlayed = _getPlayedCards(state).any((c) => c.isMighty);
        bool mightyInHand = hand.any((c) => c.isMighty);
        if (mightyPlayed || mightyInHand) continue;
      }

      // 아직 나오지 않은 더 높은 카드가 있음
      return false;
    }

    return true;
  }

  Bid decideBid(Player player, GameState state) {
    final hand = player.hand;

    // 1. 먼저 최적의 기루다를 선택
    Suit? bestSuit = findBestSuit(hand);

    // 2. 선택된 기루다를 기준으로 핸드 강도 계산
    int strength = evaluateHandStrength(hand, bestSuit);

    // 3. 배팅 결정 - 순서대로 1씩 증가하며 배팅
    int bidAmount;
    if (state.currentBid == null) {
      // 첫 배팅은 13부터 시작
      bidAmount = 13;
    } else {
      // 현재 최고 배팅 + 1로 배팅
      bidAmount = state.currentBid!.tricks + 1;
    }

    // 배팅할 금액이 자신의 강도보다 높으면 패스
    if (bidAmount > strength || strength < 13) {
      return Bid.pass(player.id);
    }

    // 최대 20까지만 배팅 가능
    bidAmount = min(bidAmount, 20);

    return Bid(
      playerId: player.id,
      suit: bestSuit,
      tricks: bidAmount,
    );
  }

  // Public method for debugging
  int evaluateHandStrength(List<PlayingCard> hand, Suit? giruda) {
    int strength = 0;

    // 마이티 판별 (기루다가 스페이드면 다이아A, 아니면 스페이드A)
    final mightySuit = (giruda == Suit.spade) ? Suit.diamond : Suit.spade;
    final mighty = PlayingCard(suit: mightySuit, rank: Rank.ace);
    bool hasMighty = hand.any((c) => c.suit == mighty.suit && c.rank == mighty.rank);

    // 조커 보유 확인
    bool hasJoker = hand.any((c) => c.isJoker);

    // === 1. 기루다 카드 평가 (가장 중요) ===
    if (giruda != null) {
      final girudaCards = hand.where((c) => !c.isJoker && c.suit == giruda).toList();

      bool hasGirudaAce = girudaCards.any((c) => c.rank == Rank.ace);
      bool hasGirudaKing = girudaCards.any((c) => c.rank == Rank.king);
      bool hasGirudaQueen = girudaCards.any((c) => c.rank == Rank.queen);
      bool hasGirudaJack = girudaCards.any((c) => c.rank == Rank.jack);
      bool hasGirudaTen = girudaCards.any((c) => c.rank == Rank.ten);

      // 기루다 고위 카드는 거의 확실한 트릭
      if (hasGirudaAce) strength += 2;  // 기루다 A는 매우 강력
      if (hasGirudaKing) strength += 2; // 기루다 K
      if (hasGirudaQueen) strength += 1; // 기루다 Q
      if (hasGirudaJack) strength += 1;  // 기루다 J
      if (hasGirudaTen) strength += 1;   // 기루다 10

      // 기루다 장수 보너스 (낮은 기루다도 컷으로 사용 가능)
      if (girudaCards.length >= 4) {
        strength += girudaCards.length - 3;
      }
    }

    // === 2. 마이티 (확실한 1트릭) ===
    if (hasMighty) strength += 2;

    // === 3. 조커 (거의 확실한 1트릭, 첫 트릭 제외) ===
    if (hasJoker) strength += 2;

    // === 3-1. 마이티 + 조커/A 조합 보너스 (프렌드 지정 가능성) ===
    if (hasMighty) {
      // 마이티 + 조커: 매우 강력한 조합
      if (hasJoker) {
        strength += 2;
      }
      // 마이티 + 다른 에이스: 프렌드로 지정되어 협력 가능
      int aceCount = hand.where((c) =>
          c.rank == Rank.ace &&
          !(c.suit == mightySuit && c.rank == Rank.ace) &&  // 마이티 제외
          !c.isJoker
      ).length;
      if (aceCount >= 1) {
        strength += aceCount;  // 에이스 개당 +1
      }
    }

    // === 4. 초구 최상위 카드 평가 (주공은 초구에 기루다 선공 불가) ===
    // 초구에 주공이 선공하므로, 비기루다 최상위 카드가 매우 중요
    int firstTrickTopCards = 0;  // 초구에서 이길 수 있는 최상위 카드 수

    for (final suit in Suit.values) {
      if (suit == giruda) continue; // 기루다는 초구 선공 불가

      final suitCards = hand.where((c) => !c.isJoker && c.suit == suit).toList();
      if (suitCards.isEmpty) continue;

      // 마이티가 아닌 에이스 (초구 최상위 카드)
      bool hasAce = suitCards.any((c) =>
          c.rank == Rank.ace && !(c.suit == mightySuit && c.rank == Rank.ace));
      bool hasKing = suitCards.any((c) => c.rank == Rank.king);

      // 비기루다 A는 초구에서 확실한 트릭 (마이티 제외)
      if (hasAce) {
        firstTrickTopCards++;
        strength += 1; // A로 1트릭
      }

      // A-K 연속이면 2트릭 가능성
      if (hasAce && hasKing) {
        strength += 1; // 추가 +1
      } else if (hasKing && suitCards.length >= 3) {
        // K가 있고 그 무늬가 3장 이상이면 A가 나간 후 K로 트릭 가능성
        strength += 1;
      }
    }

    // === 4-1. 선공 탈환 카드 평가 ===
    // 초구 패배 시 선공을 되찾을 수 있는 카드들
    int leadRegainCards = 0;
    if (hasMighty) leadRegainCards++;  // 마이티
    if (hasJoker) leadRegainCards++;   // 조커
    if (giruda != null) {
      final girudaCards = hand.where((c) => !c.isJoker && c.suit == giruda).toList();
      // 기루다 A, K는 컷으로 선공 탈환 가능
      if (girudaCards.any((c) => c.rank == Rank.ace)) leadRegainCards++;
      if (girudaCards.any((c) => c.rank == Rank.king)) leadRegainCards++;
    }

    // 초구 최상위 카드 보너스/페널티
    if (firstTrickTopCards >= 2) {
      // 초구 최상위 카드가 2개 이상이면 보너스 (안정적인 초구 승리)
      strength += 1;
    } else if (firstTrickTopCards == 0) {
      // 초구 최상위 카드가 없으면 선공 탈환 카드 수에 따라 페널티
      if (leadRegainCards >= 3) {
        // 탈환 카드 3개 이상: 작은 페널티 (회복 가능)
        strength -= 1;
      } else if (leadRegainCards >= 2) {
        // 탈환 카드 2개: 중간 페널티
        strength -= 2;
      } else {
        // 탈환 카드 1개 이하: 큰 페널티 (회복 어려움)
        strength -= 3;
      }
    } else if (firstTrickTopCards == 1 && leadRegainCards < 2) {
      // 초구 카드 1개 + 탈환 카드 부족: 약간의 페널티
      strength -= 1;
    }

    // === 5. 기본 점수 ===
    strength += 7;

    return strength;
  }

  // Public method for debugging
  Suit? findBestSuit(List<PlayingCard> hand) {
    Map<Suit, int> suitStrength = {};

    for (final suit in Suit.values) {
      int strength = 0;
      final suitCards = hand.where((c) => !c.isJoker && c.suit == suit).toList();

      // 같은 무늬가 4장 이상이어야 기루다 후보 (3장 이하는 제외)
      if (suitCards.length <= 3) {
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

  // 무늬별 최상위 카드 보유 여부 확인 (A 또는 실효가치 14+)
  Set<Suit> _getSuitsWithTopCards(List<PlayingCard> hand, GameState state) {
    Set<Suit> topSuits = {};
    for (final suit in Suit.values) {
      final suitCards = hand.where((c) => !c.isJoker && !c.isMighty && c.suit == suit).toList();
      if (suitCards.isEmpty) continue;
      // A가 있거나 실효가치 14+ 카드가 있으면 최상위 카드 보유
      bool hasTopCard = suitCards.any((c) =>
          c.rank == Rank.ace || _getEffectiveCardValue(c, state) >= 14);
      if (hasTopCard) {
        topSuits.add(suit);
      }
    }
    return topSuits;
  }

  // 비기루다 중 낮은 카드 선택 (최상위 카드가 없는 무늬 우선)
  PlayingCard? _selectCardToDiscard(List<PlayingCard> cards, Player player, GameState state, {bool allowPointCards = false}) {
    if (cards.isEmpty) return null;

    final topSuits = _getSuitsWithTopCards(player.hand, state);

    // 최상위 카드가 없는 무늬의 카드들 우선
    final noTopSuitCards = cards.where((c) =>
        c.suit != null && !topSuits.contains(c.suit)).toList();

    List<PlayingCard> targetCards;
    if (noTopSuitCards.isNotEmpty) {
      targetCards = noTopSuitCards;
    } else {
      targetCards = cards;
    }

    // 점수 카드가 아닌 카드 우선
    final nonPointCards = targetCards.where((c) => !c.isPointCard).toList();
    if (nonPointCards.isNotEmpty) {
      nonPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
      return nonPointCards.first;
    }

    // 이길 확률이 낮은 점수카드 확인 (A/K가 오픈되었거나 본인이 없는 무늬의 J/Q/10)
    final lowWinProbPointCards = targetCards.where((c) =>
        c.isPointCard && _isLowWinProbabilityPointCard(c, player, state)).toList();
    if (lowWinProbPointCards.isNotEmpty) {
      lowWinProbPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
      return lowWinProbPointCards.first;
    }

    // 점수 카드 허용 시
    if (allowPointCards) {
      targetCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
      return targetCards.first;
    }

    // 점수 카드만 남으면 가장 낮은 카드
    cards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
    return cards.first;
  }

  // 이길 확률이 낮은 점수카드인지 확인
  // A/K가 오픈되었거나 본인이 없는 무늬의 J/Q/10
  bool _isLowWinProbabilityPointCard(PlayingCard card, Player player, GameState state) {
    if (!card.isPointCard) return false;
    if (card.rank == Rank.ace || card.rank == Rank.king) return false;
    if (card.suit == null) return false;

    final suit = card.suit!;
    final playedCards = _getPlayedCards(state);

    // 해당 무늬의 A가 본인 손에 있거나 아직 플레이되지 않음
    bool hasAceInHand = player.hand.any((c) => c.suit == suit && c.rank == Rank.ace);
    bool aceNotPlayed = !playedCards.any((c) => c.suit == suit && c.rank == Rank.ace);
    bool aceAvailable = hasAceInHand || aceNotPlayed;

    // 해당 무늬의 K가 본인 손에 있거나 아직 플레이되지 않음
    bool hasKingInHand = player.hand.any((c) => c.suit == suit && c.rank == Rank.king);
    bool kingNotPlayed = !playedCards.any((c) => c.suit == suit && c.rank == Rank.king);
    bool kingAvailable = hasKingInHand || kingNotPlayed;

    // A/K 둘 다 없으면 (오픈되었고 본인이 없음) 이길 확률 낮음
    if (!hasAceInHand && !aceNotPlayed && !hasKingInHand && !kingNotPlayed) {
      return true;
    }

    // A가 오픈되었고 본인이 K도 없으면 Q/J/10은 이길 확률 낮음
    if (!aceAvailable && !hasKingInHand) {
      return true;
    }

    return false;
  }

  List<PlayingCard> selectKittyCards(Player player, GameState state) {
    final hand = List<PlayingCard>.from(player.hand);

    // 조커 보유 확인
    bool hasJoker = hand.any((c) => c.isJoker);
    final jokerCallCard = state.jokerCall;

    // 각 무늬별 카드 수 계산 (기루다 제외)
    Map<Suit, int> suitCount = {};
    for (final suit in Suit.values) {
      if (suit == state.giruda) continue;
      suitCount[suit] = hand.where((c) => !c.isJoker && c.suit == suit).length;
    }

    // 최상위 카드가 있는 무늬 (버리기 우선순위 낮춤)
    final topSuits = _getSuitsWithTopCards(hand, state);

    hand.sort((a, b) {
      // 1. 조커/마이티는 절대 버리지 않음
      if (a.isJoker || a.isMighty) return 1;
      if (b.isJoker || b.isMighty) return -1;

      // 2. 조커가 있으면 조커콜 카드 우선 버림
      if (hasJoker) {
        bool aIsJokerCall = a.suit == jokerCallCard.suit && a.rank == jokerCallCard.rank;
        bool bIsJokerCall = b.suit == jokerCallCard.suit && b.rank == jokerCallCard.rank;
        if (aIsJokerCall && !bIsJokerCall) return -1;
        if (!aIsJokerCall && bIsJokerCall) return 1;
      }

      // 3. 기루다는 버리지 않음
      if (state.giruda != null) {
        if (a.suit == state.giruda && b.suit != state.giruda) return 1;
        if (a.suit != state.giruda && b.suit == state.giruda) return -1;
      }

      // 4. 점수 카드는 버리지 않음
      if (a.isPointCard && !b.isPointCard) return 1;
      if (!a.isPointCard && b.isPointCard) return -1;

      // 5. 최상위 카드가 있는 무늬는 버리기 우선순위 낮춤
      bool aHasTop = a.suit != null && topSuits.contains(a.suit);
      bool bHasTop = b.suit != null && topSuits.contains(b.suit);
      if (aHasTop && !bHasTop) return 1;
      if (!aHasTop && bHasTop) return -1;

      // 6. 카드 수가 적은 무늬 우선 버림 (컷 가능성 높임)
      int aCount = suitCount[a.suit] ?? 0;
      int bCount = suitCount[b.suit] ?? 0;
      if (aCount != bCount) {
        return aCount.compareTo(bCount); // 적은 쪽이 앞으로
      }

      return a.rankValue.compareTo(b.rankValue);
    });

    return hand.take(3).toList();
  }

  /// AI가 키티를 받은 후 기루다 변경 여부 결정
  /// 13장 카드로 계산하고, 목표 달성 가능 여부를 고려
  Suit? decideGirudaChange(Player player, GameState state, List<PlayingCard> kitty) {
    // 13장 카드 (hand + kitty)
    final allCards = [...player.hand, ...kitty];

    final targetTricks = state.currentBid?.tricks ?? 13;

    // 현재 기루다로의 강도
    final currentStrength = evaluateHandStrength(allCards, state.giruda);

    // 최적의 기루다 찾기
    final bestSuit = findBestSuit(allCards);
    final bestStrength = evaluateHandStrength(allCards, bestSuit);

    // 노기루다 강도
    final noGirudaStrength = evaluateHandStrength(allCards, null);

    // 기루다 변경 시 목표 +2 증가
    final newTargetTricks = targetTricks + 2;

    // 변경 조건:
    // 1. 새 기루다 강도가 새 목표(+2) 이상이어야 함
    // 2. 새 기루다 강도가 현재 기루다 강도보다 높아야 함
    // 3. 현재 기루다로는 목표 달성이 어렵거나, 새 기루다가 훨씬 유리한 경우

    // 현재 기루다로 목표 달성 가능 여부
    bool currentCanAchieve = currentStrength >= targetTricks;

    // 새 기루다로 새 목표(+2) 달성 가능 여부
    bool newCanAchieve = bestStrength >= newTargetTricks;

    // 노기루다로 새 목표(+2) 달성 가능 여부
    bool noGirudaCanAchieve = noGirudaStrength >= newTargetTricks;

    // 기루다 변경 결정
    if (bestSuit != state.giruda && newCanAchieve) {
      // 현재 기루다로 목표 달성 어렵고, 새 기루다로는 가능한 경우
      if (!currentCanAchieve) {
        return bestSuit;
      }
      // 새 기루다가 현재보다 3점 이상 강한 경우 (충분한 이득)
      if (bestStrength >= currentStrength + 3) {
        return bestSuit;
      }
    }

    // 노기루다 고려
    if (state.giruda != null && noGirudaCanAchieve) {
      if (!currentCanAchieve) {
        return null; // 노기루다
      }
      if (noGirudaStrength >= currentStrength + 3) {
        return null; // 노기루다
      }
    }

    // 변경하지 않음 (기존 기루다 유지)
    return state.giruda;
  }

  /// 최종 기루다를 기준으로 버릴 카드 선택
  List<PlayingCard> selectKittyCardsWithGiruda(Player player, GameState state, List<PlayingCard> kitty, Suit? finalGiruda) {
    final hand = [...player.hand, ...kitty];

    // 조커 보유 확인
    bool hasJoker = hand.any((c) => c.isJoker);
    final jokerCallCard = state.jokerCall;

    // 각 무늬별 카드 수 계산 (최종 기루다 제외)
    Map<Suit, int> suitCount = {};
    for (final suit in Suit.values) {
      if (suit == finalGiruda) continue;
      suitCount[suit] = hand.where((c) => !c.isJoker && c.suit == suit).length;
    }

    // 최상위 카드가 있는 무늬 (버리기 우선순위 낮춤)
    final topSuits = _getSuitsWithTopCards(hand, state);

    hand.sort((a, b) {
      // 1. 조커/마이티는 절대 버리지 않음
      if (a.isJoker || a.isMighty) return 1;
      if (b.isJoker || b.isMighty) return -1;

      // 2. 조커가 있으면 조커콜 카드 우선 버림
      if (hasJoker) {
        bool aIsJokerCall = a.suit == jokerCallCard.suit && a.rank == jokerCallCard.rank;
        bool bIsJokerCall = b.suit == jokerCallCard.suit && b.rank == jokerCallCard.rank;
        if (aIsJokerCall && !bIsJokerCall) return -1;
        if (!aIsJokerCall && bIsJokerCall) return 1;
      }

      // 3. 최종 기루다는 버리지 않음
      if (finalGiruda != null) {
        if (a.suit == finalGiruda && b.suit != finalGiruda) return 1;
        if (a.suit != finalGiruda && b.suit == finalGiruda) return -1;
      }

      // 4. 점수 카드는 버리지 않음
      if (a.isPointCard && !b.isPointCard) return 1;
      if (!a.isPointCard && b.isPointCard) return -1;

      // 5. 최상위 카드가 있는 무늬는 버리기 우선순위 낮춤
      bool aHasTop = a.suit != null && topSuits.contains(a.suit);
      bool bHasTop = b.suit != null && topSuits.contains(b.suit);
      if (aHasTop && !bHasTop) return 1;
      if (!aHasTop && bHasTop) return -1;

      // 6. 카드 수가 적은 무늬 우선 버림 (컷 가능성 높임)
      int aCount = suitCount[a.suit] ?? 0;
      int bCount = suitCount[b.suit] ?? 0;
      if (aCount != bCount) {
        return aCount.compareTo(bCount); // 적은 쪽이 앞으로
      }

      return a.rankValue.compareTo(b.rankValue);
    });

    return hand.take(3).toList();
  }

  // 손에 특정 카드가 있는지 확인하는 헬퍼 함수
  bool _handContainsCard(List<PlayingCard> hand, Suit? suit, Rank rank) {
    return hand.any((c) => c.suit == suit && c.rank == rank);
  }

  bool _handContainsJoker(List<PlayingCard> hand) {
    return hand.any((c) => c.isJoker);
  }

  bool _handContainsMighty(List<PlayingCard> hand, PlayingCard mighty) {
    return hand.any((c) => c.suit == mighty.suit && c.rank == mighty.rank);
  }

  /// 노프렌드 선언 여부 판단 (선공 유지/탈환 확률과 예상 점수 기반)
  bool _shouldDeclareNoFriend(
    List<PlayingCard> hand,
    GameState state,
    bool hasMighty,
    bool hasJoker,
    bool hasGirudaAce,
    bool hasGirudaKing,
    int nonGirudaAceCount,
    int kingCount,
  ) {
    final targetTricks = state.currentBid?.tricks ?? 13;

    // === 1. 선공 유지 카드 수 계산 ===
    // 마이티, 조커, 기루다 A/K, 비기루다 A, 실효가치 14+ 카드
    int leadKeepingCards = 0;

    if (hasMighty) leadKeepingCards++;
    if (hasJoker) leadKeepingCards++;
    if (hasGirudaAce) leadKeepingCards++;
    if (hasGirudaKing) leadKeepingCards++;
    leadKeepingCards += nonGirudaAceCount;

    // 기루다 Q 이상 카드 수 (A, K 제외)
    if (state.giruda != null) {
      int girudaHighCount = hand.where((c) =>
          !c.isJoker && !c.isMighty &&
          c.suit == state.giruda &&
          c.rank != Rank.ace && c.rank != Rank.king &&
          c.rankValue >= 12  // Q 이상
      ).length;
      leadKeepingCards += girudaHighCount;
    }

    // === 2. 선공 탈환 카드 수 계산 ===
    // 마이티는 조커 이외 모든 카드를 이김
    // 조커는 마이티 이외 모든 카드를 이김
    int leadRecoveryCards = 0;
    if (hasMighty) leadRecoveryCards++;
    if (hasJoker) leadRecoveryCards++;
    // 기루다 A/K도 컷으로 탈환 가능
    if (hasGirudaAce) leadRecoveryCards++;
    if (hasGirudaKing) leadRecoveryCards++;

    // === 3. 상대가 선공을 빼앗을 수 있는 횟수 예측 ===
    // 상대 4명이 가질 수 있는 최상위 카드 예측
    int opponentTopCards = 0;

    // 마이티가 없으면 상대가 가지고 있음
    if (!hasMighty) opponentTopCards++;
    // 조커가 없으면 상대가 가지고 있음
    if (!hasJoker) opponentTopCards++;
    // 기루다 A가 없으면 상대가 가지고 있을 수 있음
    if (!hasGirudaAce && state.giruda != null) {
      // 마이티가 기루다 A가 아닌 경우에만
      if (!(state.mighty.suit == state.giruda && state.mighty.rank == Rank.ace)) {
        opponentTopCards++;
      }
    }
    // 기루다 K가 없으면 상대가 가지고 있을 수 있음
    if (!hasGirudaKing && state.giruda != null) opponentTopCards++;
    // 비기루다 A (본인이 없는 것)
    opponentTopCards += (maxNonMightyAces(state) - nonGirudaAceCount);

    // === 4. 빼앗길 때 손실될 점수 카드 예측 ===
    // 선공을 빼앗기면 평균 1-2점 손실 (트릭당 점수 카드 평균 2장)
    // 탈환 전까지 빼앗길 트릭 수 = opponentTopCards - leadRecoveryCards (최소 0)
    int tricksLostBeforeRecovery = (opponentTopCards - leadRecoveryCards).clamp(0, 10);
    int estimatedPointsLost = tricksLostBeforeRecovery * 2; // 트릭당 2점 손실 가정

    // === 5. 예상 획득 점수 계산 ===
    // 키티 점수 (평균 3점)
    int kittyPoints = state.kitty.where((c) => c.isPointCard).length;

    // 선공 유지 트릭에서 획득할 점수 (트릭당 평균 2점)
    int pointsFromLeadKeeping = leadKeepingCards * 2;

    // 총 예상 점수
    int estimatedPoints = kittyPoints + pointsFromLeadKeeping - estimatedPointsLost;

    // === 6. 노프렌드 판단 ===
    // 목표 점수 + 여유(2점)보다 예상 점수가 높으면 노프렌드
    int margin = 2;

    // 추가 조건: 마이티와 조커 모두 있어야 함
    bool hasStrongCard = hasMighty && hasJoker;

    // 추가 조건: 선공 유지 카드가 5장 이상이어야 함
    bool hasEnoughLeadCards = leadKeepingCards >= 5;

    // 추가 조건: 탈환 카드가 2장 이상이어야 함
    bool hasEnoughRecoveryCards = leadRecoveryCards >= 2;

    if (hasStrongCard && hasEnoughLeadCards && hasEnoughRecoveryCards &&
        estimatedPoints >= targetTricks + margin) {
      return true;
    }

    return false;
  }

  int maxNonMightyAces(GameState state) {
    return (state.mighty.rank == Rank.ace) ? 3 : 4;
  }

  FriendDeclaration declareFriend(Player player, GameState state) {
    final hand = player.hand;

    bool hasMighty = _handContainsMighty(hand, state.mighty);
    bool hasJoker = _handContainsJoker(hand);

    // 기루다 A 보유 확인
    bool hasGirudaAce = false;
    if (state.giruda != null) {
      // 기루다 A가 마이티가 아닌 경우에만 체크
      if (!(state.mighty.suit == state.giruda && state.mighty.rank == Rank.ace)) {
        hasGirudaAce = _handContainsCard(hand, state.giruda, Rank.ace);
      }
    }

    // 기루다 외 A 보유 확인
    int nonGirudaAceCount = 0;
    for (final suit in Suit.values) {
      if (suit == state.giruda) continue;
      // 마이티가 아닌 경우에만 체크
      if (!(state.mighty.suit == suit && state.mighty.rank == Rank.ace)) {
        if (_handContainsCard(hand, suit, Rank.ace)) {
          nonGirudaAceCount++;
        }
      }
    }

    // 조커 콜 카드 보유 확인
    final jokerCallCard = state.jokerCall;
    bool hasJokerCallCard = jokerCallCard.rank != null &&
        _handContainsCard(hand, jokerCallCard.suit, jokerCallCard.rank!);

    // 기루다 K 보유 확인
    bool hasGirudaKing = false;
    if (state.giruda != null) {
      hasGirudaKing = _handContainsCard(hand, state.giruda, Rank.king);
    }

    // === 노 프렌드 조건 체크 ===

    // 조건 1: 마이티 + 조커 + 기루다 A + 기루다 K + 기루다 외 A 1개 이상 → 노 프렌드
    if (hasMighty && hasJoker && hasGirudaAce && hasGirudaKing && nonGirudaAceCount >= 1) {
      return FriendDeclaration.noFriend();
    }

    // K 카드 개수 확인
    int kingCount = hand.where((c) => !c.isJoker && c.rank == Rank.king).length;

    // 조건 2: 마이티 + 모든 A + 조커 콜 카드 + K 2장 이상 → 노 프렌드
    int totalAces = (hasGirudaAce ? 1 : 0) + nonGirudaAceCount;
    // 마이티가 A인 경우 제외하고 3장의 A가 있으면 모든 A 보유
    int maxNonMightyAces = (state.mighty.rank == Rank.ace) ? 3 : 4;
    if (hasMighty && totalAces == maxNonMightyAces && hasJokerCallCard && kingCount >= 2) {
      return FriendDeclaration.noFriend();
    }

    // 조건 3: 선공 유지/탈환 확률과 예상 점수 기반 노프렌드 판단
    if (_shouldDeclareNoFriend(hand, state, hasMighty, hasJoker, hasGirudaAce, hasGirudaKing, nonGirudaAceCount, kingCount)) {
      return FriendDeclaration.noFriend();
    }

    // === 일반 프렌드 선택 (본인이 없는 카드만 선택) ===

    // 1. 마이티가 없으면 마이티 소유자를 프렌드로
    if (!hasMighty) {
      return FriendDeclaration.byCard(state.mighty);
    }

    // 2. 조커가 없으면 조커 소유자를 프렌드로
    if (!hasJoker) {
      return FriendDeclaration.byCard(PlayingCard.joker());
    }

    // 3. 기루다 A-K 체크 (본인이 없는 카드만)
    if (state.giruda != null) {
      // 기루다 A (마이티가 아닌 경우)
      if (!(state.mighty.suit == state.giruda && state.mighty.rank == Rank.ace)) {
        if (!_handContainsCard(hand, state.giruda, Rank.ace)) {
          return FriendDeclaration.byCard(PlayingCard(suit: state.giruda!, rank: Rank.ace));
        }
      }
      // 기루다 K
      if (!_handContainsCard(hand, state.giruda, Rank.king)) {
        return FriendDeclaration.byCard(PlayingCard(suit: state.giruda!, rank: Rank.king));
      }
    }

    // 4. 기루다 외 에이스 체크 (본인이 없는 카드만)
    for (final suit in Suit.values) {
      if (suit == state.giruda) continue;
      // 마이티가 아닌 경우에만
      if (!(state.mighty.suit == suit && state.mighty.rank == Rank.ace)) {
        if (!_handContainsCard(hand, suit, Rank.ace)) {
          return FriendDeclaration.byCard(PlayingCard(suit: suit, rank: Rank.ace));
        }
      }
    }

    // 5. 기루다 Q-J-10 체크 (본인이 없는 카드만)
    if (state.giruda != null) {
      final girudaMidRanks = [Rank.queen, Rank.jack, Rank.ten];
      for (final rank in girudaMidRanks) {
        if (!_handContainsCard(hand, state.giruda, rank)) {
          return FriendDeclaration.byCard(PlayingCard(suit: state.giruda!, rank: rank));
        }
      }
    }

    // 6. 마이티, 조커, 기루다 고위카드, 모든 에이스를 가지고 있으면 노프렌드
    return FriendDeclaration.noFriend();
  }

  // 조커 콜 결정 (선공 시에만 호출)
  // 조커 콜 카드(♣3 또는 ♠3)를 가지고 있을 때만 조커 콜 가능
  Suit? decideJokerCall(Player player, GameState state) {
    // 첫 트릭에서는 조커 콜 불가
    if (state.currentTrickNumber <= 1) return null;

    // 선공이 아니면 조커 콜 불가
    if (state.currentTrick == null || state.currentTrick!.cards.isNotEmpty) {
      return null;
    }

    // 조커가 이미 플레이된 경우 조커 콜 불가
    if (state.isJokerPlayed) return null;

    // 조커 콜 카드 확인
    final jokerCallCard = state.jokerCall;
    bool hasJokerCallCard = player.hand.any((c) =>
        c.suit == jokerCallCard.suit && c.rank == jokerCallCard.rank);
    if (!hasJokerCallCard) return null;

    // 조커를 가지고 있으면 조커 콜 안 함
    bool hasJoker = player.hand.any((c) => c.isJoker);
    if (hasJoker) return null;

    // 팀별 조커콜 정책
    bool isDefenseTeam = _isPlayerOnDefenseTeam(player, state);

    if (isDefenseTeam) {
      // 수비팀: 조커가 공격팀에 있을 확률이 높으므로 적극적으로 조커콜 (80%)
      if (Random().nextDouble() > 0.8) return null;
    } else {
      // 공격팀 (주공 또는 프렌드)
      if (player.isDeclarer) {
        // 주공: 조커 프렌드인 경우 조커콜 안 함
        final friendCard = state.friendDeclaration?.card;
        if (friendCard != null && friendCard.isJoker) {
          return null;
        }
        // 그 외에는 50% 확률로 조커콜 (수비팀이 조커를 가지고 있을 수 있음)
        if (Random().nextDouble() > 0.5) return null;
      } else {
        // 프렌드: 같은 팀(주공 또는 다른 프렌드)이 조커를 가지고 있을 수 있으므로 조커콜 안 함
        return null;
      }
    }

    // 조커 콜 카드의 무늬로 콜
    return jokerCallCard.suit;
  }

  // AI가 조커 콜 카드를 낼지 결정
  bool shouldPlayJokerCallCard(Player player, GameState state) {
    final jokerCallCard = state.jokerCall;
    bool hasJokerCallCard = player.hand.any((c) =>
        c.suit == jokerCallCard.suit && c.rank == jokerCallCard.rank);

    if (!hasJokerCallCard) return false;
    if (state.currentTrickNumber <= 1) return false;

    // 조커가 이미 플레이된 경우 조커 콜 의미 없음
    if (state.isJokerPlayed) return false;

    // 조커를 가지고 있으면 조커 콜 안 함
    bool hasJoker = player.hand.any((c) => c.isJoker);
    if (hasJoker) return false;

    // 팀별 조커콜 정책
    bool isDefenseTeam = _isPlayerOnDefenseTeam(player, state);

    if (isDefenseTeam) {
      // 수비팀: 조커가 공격팀에 있을 확률이 높으므로 적극적으로 조커콜 (80%)
      return Random().nextDouble() < 0.8;
    } else {
      // 공격팀 (주공 또는 프렌드)
      if (player.isDeclarer) {
        // 주공: 조커 프렌드인 경우 조커콜 안 함
        final friendCard = state.friendDeclaration?.card;
        if (friendCard != null && friendCard.isJoker) {
          return false;
        }
        // 그 외에는 50% 확률로 조커콜
        return Random().nextDouble() < 0.5;
      } else {
        // 프렌드: 같은 팀이 조커를 가지고 있을 수 있으므로 조커콜 안 함
        return false;
      }
    }
  }

  /// 조커 선공 시 부를 무늬 결정
  /// 공격팀:
  ///   - 조커가 프렌드 카드이고 초반(기루다 많이 남음): 기루다 호출 (주공의 낮은 기루다 제거)
  ///   - 후반(기루다 많이 나감): 차상위 카드를 가진 무늬 호출 (주공의 컷 방지)
  /// 수비팀: 공격팀의 기루다를 줄이기 위해 기루다 (남은 기루다 수 고려)
  Suit selectJokerLeadSuit(Player player, GameState state) {
    bool isDefenseTeam = _isPlayerOnDefenseTeam(player, state);
    final playedCards = _getPlayedCards(state);
    final playedGirudaCount = _getPlayedGirudaCount(state);

    if (isDefenseTeam) {
      // === 수비팀 조커 선공: 기루다 우선 고려 ===
      if (state.giruda != null) {
        // 남은 기루다 수 추정 (공격팀이 가진)
        final remainingGiruda = _getRemainingGirudaCount(state, player);

        // 공격팀이 기루다를 2장 이상 가지고 있을 것으로 추정되면 기루다 콜
        if (remainingGiruda >= 2) {
          return state.giruda!;
        }
      }

      // 기루다가 없거나 공격팀 기루다가 적으면, 공격팀이 없을 것 같은 무늬 선택
      return _selectSuitAttackTeamLacks(player, state, playedCards);
    } else {
      // === 공격팀 조커 선공 ===

      // 조커가 프렌드 카드인지 확인
      bool jokerIsFriendCard = state.friendDeclaration?.card?.isJoker ?? false;

      if (state.giruda != null) {
        // 조건 0: 약한 기루다만 남았을 때 기루다 콜하여 상대 기루다 소진
        final myGirudaCards = player.hand.where((c) =>
            !c.isJoker && !c.isMighty && c.suit == state.giruda).toList();

        if (myGirudaCards.isNotEmpty) {
          myGirudaCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
          final myHighestGiruda = myGirudaCards.first;
          final opponentGiruda = _getRemainingGirudaCount(state, player);

          // 내 최고 기루다가 J 이하이고 상대 기루다가 남아있으면 기루다 콜
          if (myHighestGiruda.rankValue <= 11 && opponentGiruda >= 2) {
            final playedGirudaCards = playedCards.where((c) =>
                !c.isJoker && c.suit == state.giruda).toList();

            int highGirudaRemaining = 0;
            for (final rank in [Rank.ace, Rank.king, Rank.queen]) {
              bool played = playedGirudaCards.any((c) => c.rank == rank);
              bool inMyHand = myGirudaCards.any((c) => c.rank == rank);
              if (!played && !inMyHand) {
                highGirudaRemaining++;
              }
            }

            if (highGirudaRemaining >= 2) {
              return state.giruda!;
            }
          }
        }

        // 조건 1: 조커가 프렌드 카드이고 초반(상대 기루다 7장 초과)이면 기루다 호출
        // → 주공의 낮은 기루다를 제거하여 기루다 정리
        if (jokerIsFriendCard && _isEarlyGirudaPhase(state, player)) {
          return state.giruda!;
        }

        // 조건 2: 후반(상대 기루다 7장 이하)이면 주공이 컷으로 기루다 사용할 확률 높음
        // → 기루다 호출하지 않고, 차상위 카드를 가진 무늬 호출
        if (_isLateGirudaPhase(state, player)) {
          return _selectSuitWithSecondHighestCard(player, state, playedCards);
        }
      }

      // 기본: 차상위 카드를 가진 무늬 호출 (최상위는 선공 유지용으로 아낌)
      return _selectSuitWithSecondHighestCard(player, state, playedCards);
    }
  }

  /// 차상위 카드를 가진 무늬 선택 (공격팀용)
  /// 최상위 카드는 선공 유지용으로 아끼고, 차상위로 트릭을 따기 위함
  Suit _selectSuitWithSecondHighestCard(Player player, GameState state, List<PlayingCard> playedCards) {
    Map<Suit, int> suitScore = {};

    for (final suit in Suit.values) {
      if (suit == state.giruda) continue; // 기루다는 제외

      int score = 0;

      // 내가 가진 해당 무늬 카드들
      final myCards = player.hand.where((c) =>
          !c.isJoker && !c.isMighty && c.suit == suit).toList();

      if (myCards.isEmpty) {
        suitScore[suit] = -100; // 카드가 없으면 제외
        continue;
      }

      // 각 카드의 실효 가치 계산
      myCards.sort((a, b) =>
          _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));

      // 최상위 카드의 실효 가치
      final highestValue = _getEffectiveCardValue(myCards.first, state);

      // 최상위 카드가 현재 가장 높은 카드(14)가 아니면 점수 감소
      // (다른 사람이 더 높은 카드 가지고 있을 수 있음)
      if (highestValue < 14) {
        score -= 5;
      }

      // 차상위 카드가 있으면 점수 증가
      if (myCards.length >= 2) {
        final secondValue = _getEffectiveCardValue(myCards[1], state);
        // 차상위 카드 가치가 높을수록 좋음
        score += secondValue;

        // 차상위 카드가 실효 가치 12(Q급) 이상이면 보너스
        if (secondValue >= 12) {
          score += 5;
        }
      } else {
        // 카드가 1장뿐이면 점수 감소
        score -= 3;
      }

      // 해당 무늬가 많이 나왔으면 상대가 없을 확률 높음 → 점수 증가
      final playedCount = playedCards.where((c) =>
          !c.isJoker && c.suit == suit).length;
      score += playedCount;

      suitScore[suit] = score;
    }

    // 가장 점수가 높은 무늬 선택
    Suit bestSuit = Suit.spade;
    int bestScore = -100;
    for (final entry in suitScore.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestSuit = entry.key;
      }
    }

    return bestSuit;
  }

  /// 공격팀이 없을 것 같은 무늬 선택 (수비팀용)
  Suit _selectSuitAttackTeamLacks(Player player, GameState state, List<PlayingCard> playedCards) {
    // 각 무늬별로 공격팀이 가지고 있을 확률 계산
    Map<Suit, int> suitScore = {};

    for (final suit in Suit.values) {
      if (suit == state.giruda) continue; // 기루다는 제외

      // 해당 무늬에서 나온 카드 수
      final playedCount = playedCards.where((c) =>
          !c.isJoker && c.suit == suit).length;

      // 내가 가진 카드 수
      final myCount = player.hand.where((c) =>
          !c.isJoker && c.suit == suit).length;

      // 남은 카드 수 (공격팀이 가질 수 있는 최대)
      final remaining = 13 - playedCount - myCount;

      // 많이 나온 무늬일수록 공격팀이 없을 확률 높음
      suitScore[suit] = playedCount - remaining;
    }

    // 가장 점수가 높은 무늬 (공격팀이 없을 확률 높은 무늬)
    Suit bestSuit = Suit.spade;
    int bestScore = -100;
    for (final entry in suitScore.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestSuit = entry.key;
      }
    }

    return bestSuit;
  }

  /// 주공이 낮은 카드를 가지고 있을 무늬 선택 (공격팀용)
  Suit _selectSuitDeclarerHasLowCards(Player player, GameState state, List<PlayingCard> playedCards) {
    // 각 무늬별로 점수 계산
    // 높은 카드(A, K, Q)가 많이 나온 무늬 = 주공이 낮은 카드만 가지고 있을 확률 높음
    Map<Suit, int> suitScore = {};

    for (final suit in Suit.values) {
      if (suit == state.giruda) continue; // 기루다는 제외 (기루다는 주공이 높은 카드 많음)

      int score = 0;

      // 해당 무늬의 높은 카드가 나왔는지 확인
      final playedOfSuit = playedCards.where((c) =>
          !c.isJoker && c.suit == suit).toList();

      // A가 나왔으면 +3
      if (playedOfSuit.any((c) => c.rank == Rank.ace)) score += 3;
      // K가 나왔으면 +2
      if (playedOfSuit.any((c) => c.rank == Rank.king)) score += 2;
      // Q가 나왔으면 +1
      if (playedOfSuit.any((c) => c.rank == Rank.queen)) score += 1;

      // 내가 해당 무늬의 높은 카드를 가지고 있으면 +
      final myCards = player.hand.where((c) =>
          !c.isJoker && c.suit == suit).toList();
      if (myCards.any((c) => c.rank == Rank.ace)) score += 3;
      if (myCards.any((c) => c.rank == Rank.king)) score += 2;
      if (myCards.any((c) => c.rank == Rank.queen)) score += 1;

      // 해당 무늬 카드가 많이 남아있으면 - (주공이 높은 카드 가질 수 있음)
      final playedCount = playedOfSuit.length;
      final myCount = myCards.length;
      final remaining = 13 - playedCount - myCount;
      score -= remaining ~/ 3;

      suitScore[suit] = score;
    }

    // 가장 점수가 높은 무늬 선택
    Suit bestSuit = Suit.spade;
    int bestScore = -100;
    for (final entry in suitScore.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestSuit = entry.key;
      }
    }

    return bestSuit;
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

    // 트릭 9에서 조커가 있으면 조커 사용 (마지막 트릭에는 사용 불가)
    if (state.currentTrickNumber == 9) {
      final joker = playableCards.where((c) => c.isJoker).toList();
      if (joker.isNotEmpty) {
        return joker.first;
      }
    }

    if (state.currentTrick == null || state.currentTrick!.cards.isEmpty) {
      return _selectLeadCard(playableCards, player, state);
    } else {
      return _selectFollowCard(playableCards, player, state);
    }
  }

  PlayingCard _selectLeadCard(
      List<PlayingCard> playableCards, Player player, GameState state) {

    // 방어팀인지 확인
    bool isDefenseTeam = _isPlayerOnDefenseTeam(player, state);

    if (isDefenseTeam && state.giruda != null) {
      // === 방어팀 선공 전략 ===
      // 기루다를 아끼고, 다른 무늬의 높은 카드를 낸다
      // (주공이 높은 기루다를 많이 가지고 있을 가능성이 높으므로)
      // 오픈된 카드를 고려하여 현재 가장 높은 카드를 선택

      // 기루다가 아닌 카드들
      final nonGirudaCards = playableCards.where((c) =>
          !c.isJoker && !c.isMighty && c.suit != state.giruda).toList();

      if (nonGirudaCards.isNotEmpty) {
        // 현재 가장 높은 카드인 것들을 찾기 (오픈된 카드 고려)
        final highestRemainingCards = nonGirudaCards.where((c) =>
            _isHighestRemainingCard(c, state, player.hand)).toList();

        if (highestRemainingCards.isNotEmpty) {
          // 가장 높은 실효 가치 카드 선택
          highestRemainingCards.sort((a, b) =>
              _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
          return highestRemainingCards.first;
        }

        // 높은 실효 가치 순으로 정렬 (오픈된 카드 고려)
        nonGirudaCards.sort((a, b) =>
            _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));

        // 실효 가치가 A(14) 이상인 카드가 있으면 선택 (= 현재 가장 높은 카드)
        final effectiveHighCards = nonGirudaCards.where((c) =>
            _getEffectiveCardValue(c, state) >= 14).toList();
        if (effectiveHighCards.isNotEmpty) {
          return effectiveHighCards.first;
        }

        // 이길 확률이 낮으면 높은 카드로 리드하지 않음
        // 대신 낮은 카드를 버리거나, 이길 확률이 낮은 점수카드를 버림

        // 1. 비점수카드 중 낮은 카드로 리드 (안전한 선택)
        final nonPointCards = nonGirudaCards.where((c) => !c.isPointCard).toList();
        if (nonPointCards.isNotEmpty) {
          nonPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return nonPointCards.first;
        }

        // 2. 이길 확률이 낮은 점수카드 리드 (A/K가 오픈된 J/Q/10)
        final lowProbPointCards = nonGirudaCards.where((c) =>
            c.isPointCard && _isLowWinProbabilityPointCard(c, player, state)).toList();
        if (lowProbPointCards.isNotEmpty) {
          lowProbPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return lowProbPointCards.first;
        }

        // 3. 이길 가능성 있는 점수카드는 보존하고 싶지만 다른 카드가 없으면 낮은 것
        nonGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        return nonGirudaCards.first;
      }

      // 기루다만 남은 경우, 가장 낮은 기루다를 낸다
      final girudaCards = playableCards.where((c) =>
          !c.isJoker && !c.isMighty && c.suit == state.giruda).toList();
      if (girudaCards.isNotEmpty) {
        girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        return girudaCards.first;
      }
    }

    // === 프렌드 선공 전략: 주공에게 선공 넘기기 ===
    // 프렌드가 공개되고, 내가 프렌드이고, 주공이 아닌 경우
    bool iAmFriend = state.friendRevealed && player.isFriend &&
        state.declarerId != null && player.id != state.declarerId;

    if (iAmFriend && state.giruda != null) {
      // === 프렌드가 최상위 카드로 선공 유지 가능하면 우선 사용 ===
      final remainingGiruda = _getRemainingGirudaCount(state, player);
      final cutSuits = _getCutSuits(state);

      // 실효가치 14+ 최상위 카드가 있으면 우선 사용 (마이티/조커보다 먼저)
      // 마이티/조커는 점수 카드가 많을 때 사용하는 것이 유리
      final topCards = playableCards.where((c) {
        if (c.isJoker || c.isMighty) return false;
        // 컷된 무늬는 제외 (상대 기루다 없으면 허용)
        if (remainingGiruda > 0 && c.suit != null && cutSuits.contains(c.suit)) {
          return false;
        }
        return _getEffectiveCardValue(c, state) >= 14;
      }).toList();

      if (topCards.isNotEmpty) {
        // 가장 높은 실효가치 카드 선택
        topCards.sort((a, b) =>
            _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
        return topCards.first;
      }

      // 최상위 카드가 없을 때만 마이티/조커 사용 (후반전, 점수 카드 확보용)
      // 마이티가 있으면 마이티 사용 (7트릭 이후, 점수 카드 확보 가능성 높을 때)
      if (state.currentTrickNumber >= 7) {
        final mighty = playableCards.where((c) => c.isMighty).toList();
        if (mighty.isNotEmpty) {
          return mighty.first;
        }
      }

      // 조커가 있으면 조커 사용 (7트릭 이후, 마지막 트릭 제외)
      if (state.currentTrickNumber >= 7 && state.currentTrickNumber < 10) {
        final joker = playableCards.where((c) => c.isJoker).toList();
        if (joker.isNotEmpty) {
          return joker.first;
        }
      }

      // === 최상위 카드가 없으면 주공에게 선공 넘기기 ===

      // 전략 1: 주공이 없는 무늬로 선공 (주공이 기루다로 컷 가능)
      Set<Suit> declarerVoidSuits = _getDeclarerVoidSuits(state);
      if (declarerVoidSuits.isNotEmpty) {
        for (Suit voidSuit in declarerVoidSuits) {
          final voidSuitCards = playableCards.where((c) =>
              !c.isJoker && !c.isMighty && c.suit == voidSuit).toList();
          if (voidSuitCards.isNotEmpty) {
            // 낮은 카드로 선공하여 주공이 기루다로 컷하게 함
            voidSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return voidSuitCards.first;
          }
        }
      }

      // 전략 2: 낮은 기루다로 선공 (주공이 높은 기루다로 이김)
      final myGirudaCards = playableCards.where((c) =>
          !c.isJoker && !c.isMighty && c.suit == state.giruda).toList();
      if (myGirudaCards.isNotEmpty) {
        // 내 기루다 중 가장 낮은 것
        myGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        // 10 이하의 낮은 기루다만 사용 (높은 기루다는 아낌)
        final lowGiruda = myGirudaCards.where((c) => c.rankValue <= 10).toList();
        if (lowGiruda.isNotEmpty) {
          return lowGiruda.first;
        }
      }

      // 전략 3: 비기루다 중 낮은 카드로 선공 (수비팀이 이길 가능성, 주공이 다음 기회에)
      final nonGirudaCards = playableCards.where((c) =>
          !c.isJoker && !c.isMighty && c.suit != state.giruda).toList();
      if (nonGirudaCards.isNotEmpty) {
        nonGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        // 컷되지 않은 무늬 우선
        final cutSuits = _getCutSuits(state);
        final nonCutCards = nonGirudaCards.where((c) =>
            c.suit != null && !cutSuits.contains(c.suit)).toList();
        if (nonCutCards.isNotEmpty) {
          return nonCutCards.first;
        }
        return nonGirudaCards.first;
      }
    }

    // === 주공 초구 프렌드 호출 전략 ===
    // 초구에서 승리 확률이 낮고 마이티 무늬의 낮은 카드가 있으면
    // 그 카드를 내서 프렌드(마이티 보유자)를 바로 호출
    if (state.currentTrickNumber == 1 && player.isDeclarer && state.giruda != null) {
      // 프렌드 선언이 마이티인지 확인
      bool friendIsMighty = state.friendDeclaration?.card != null &&
          state.friendDeclaration!.card == state.mighty;

      if (friendIsMighty) {
        // 초구 승리 가능한 카드가 있는지 확인 (비기루다 A)
        final mightySuit = state.mighty.suit!;
        bool hasFirstTrickWinner = playableCards.any((c) =>
            !c.isJoker && !c.isMighty &&
            c.suit != state.giruda &&  // 기루다는 초구에 낼 수 없음
            c.rank == Rank.ace &&
            c.suit != mightySuit);  // 마이티 무늬 A는 초간에 질 수 있음

        // 초구 승리 카드가 없으면 마이티 무늬의 낮은 카드로 프렌드 호출
        if (!hasFirstTrickWinner) {
          final mightySuitCards = playableCards.where((c) =>
              !c.isJoker && !c.isMighty &&
              c.suit == mightySuit).toList();

          if (mightySuitCards.isNotEmpty) {
            // 가장 낮은 카드 선택 (마이티가 확실히 이김)
            mightySuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            // 10 이하의 낮은 카드만 사용 (높은 카드는 아낌)
            final lowCards = mightySuitCards.where((c) => c.rankValue <= 10).toList();
            if (lowCards.isNotEmpty) {
              return lowCards.first;
            }
          }
        }
      }
    }

    // === 주공팀 또는 노기루다 선공 전략 ===

    // === 초반에 조커로 기루다 콜하여 상대 기루다 정리 ===
    // 초반(트릭 2-5)에 기루다가 적게 나왔고 상대 기루다가 많으면 조커로 기루다 콜
    if (state.giruda != null && state.currentTrickNumber >= 2 && state.currentTrickNumber <= 5) {
      bool isAttackTeam = !_isPlayerOnDefenseTeam(player, state);

      if (isAttackTeam) {
        final joker = playableCards.where((c) => c.isJoker).toList();

        if (joker.isNotEmpty) {
          // 지금까지 나온 기루다 수 계산
          final playedGirudaCards = _getPlayedCards(state).where((c) =>
              !c.isJoker && c.suit == state.giruda).toList();
          final playedGirudaCount = playedGirudaCards.length;

          // 상대에게 남은 기루다 추정
          final opponentGiruda = _getRemainingGirudaCount(state, player);

          // 기루다가 적게 나왔고(3장 이하) 상대 기루다가 많이 남아있으면(4장 이상)
          // 조커로 기루다 콜하여 상대 기루다 소진
          if (playedGirudaCount <= 3 && opponentGiruda >= 4) {
            return joker.first;
          }
        }
      }
    }

    // === 약한 기루다만 남았을 때 조커로 기루다 콜 ===
    // 기루다로 선공을 유지하다가 약한 기루다만 남으면 조커로 기루다 콜하여 상대 기루다 소진
    if (state.giruda != null && state.currentTrickNumber > 1 && state.currentTrickNumber < 10) {
      bool isAttackTeam = !_isPlayerOnDefenseTeam(player, state);

      if (isAttackTeam) {
        final joker = playableCards.where((c) => c.isJoker).toList();

        if (joker.isNotEmpty) {
          // 내 기루다 카드들
          final myGirudaCards = player.hand.where((c) =>
              !c.isJoker && !c.isMighty && c.suit == state.giruda).toList();

          if (myGirudaCards.isNotEmpty) {
            // 내 기루다 중 최고 랭크
            myGirudaCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
            final myHighestGiruda = myGirudaCards.first;

            // 상대에게 남은 기루다 추정
            final opponentGiruda = _getRemainingGirudaCount(state, player);

            // 내 최고 기루다가 약하고 (J=11 이하), 상대 기루다가 남아있으면
            // 조커로 기루다 콜하여 상대 기루다 소진시키기
            if (myHighestGiruda.rankValue <= 11 && opponentGiruda >= 2) {
              // 상대의 높은 기루다가 남아있는지 확인
              final playedGirudaCards = _getPlayedCards(state).where((c) =>
                  !c.isJoker && c.suit == state.giruda).toList();

              // A, K, Q 중 안 나온 기루다 수 계산
              int highGirudaRemaining = 0;
              for (final rank in [Rank.ace, Rank.king, Rank.queen]) {
                bool played = playedGirudaCards.any((c) => c.rank == rank);
                bool inMyHand = myGirudaCards.any((c) => c.rank == rank);
                if (!played && !inMyHand) {
                  highGirudaRemaining++;
                }
              }

              // 상대에게 높은 기루다(A,K,Q)가 2장 이상 남아있으면 조커로 기루다 콜
              if (highGirudaRemaining >= 2) {
                return joker.first;
              }
            }
          }
        }
      }
    }

    // 상대에게 남은 기루다가 없으면 최상위 카드 우선 (컷 당할 위험 없음)
    // 마이티/조커는 점수 카드가 많을 때 사용하는 것이 유리하므로 나중에 사용
    if (state.giruda != null) {
      final opponentGiruda = _getRemainingGirudaCount(state, player);

      if (opponentGiruda == 0) {
        // 상대 기루다 없음 → 최상위 카드 우선, 마이티/조커는 나중에
        // 최상위 카드 (실효 가치 14 이상) 우선 사용
        final highestCards = playableCards.where((c) =>
            !c.isJoker && !c.isMighty &&
            _getEffectiveCardValue(c, state) >= 14).toList();
        if (highestCards.isNotEmpty) {
          // 비기루다 최상위 우선 (기루다는 아껴둠)
          final nonGirudaHighest = highestCards.where((c) =>
              c.suit != state.giruda).toList();
          if (nonGirudaHighest.isNotEmpty) {
            return nonGirudaHighest.first;
          }
          return highestCards.first;
        }

        // 최상위 카드가 없을 때만 조커/마이티 사용 (후반전)
        // 조커 사용 (7트릭 이후, 마지막 트릭 제외)
        if (state.currentTrickNumber >= 7 && state.currentTrickNumber < 10) {
          final joker = playableCards.where((c) => c.isJoker).toList();
          if (joker.isNotEmpty) {
            return joker.first;
          }
        }

        // 마이티 사용 (7트릭 이후)
        if (state.currentTrickNumber >= 7) {
          final mighty = playableCards.where((c) => c.isMighty).toList();
          if (mighty.isNotEmpty) {
            return mighty.first;
          }
        }
      }
    }

    // 오픈된 카드를 고려하여 실효 가치가 높은 카드 선택
    playableCards.sort((a, b) {
      if (a.isMighty) return -1;
      if (b.isMighty) return 1;

      if (state.giruda != null) {
        if (a.suit == state.giruda && b.suit != state.giruda) return -1;
        if (a.suit != state.giruda && b.suit == state.giruda) return 1;
      }

      // 실효 가치 기준으로 정렬 (오픈된 카드 고려)
      return _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state));
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
    final currentWinnerId = _findCurrentWinnerId(state);

    // === 프렌드 카드 사용 로직 ===
    // 프렌드 카드를 가지고 있고, 아직 공개되지 않은 경우
    if (!state.friendRevealed && state.friendDeclaration?.card != null) {
      final friendCard = state.friendDeclaration!.card!;
      bool hasFriendCard = playableCards.any((c) =>
          c.suit == friendCard.suit && c.rank == friendCard.rank);

      if (hasFriendCard) {
        // 주공이 위험한 상황인지 확인
        bool declarerInDanger = _isDeclarerInDanger(state, currentWinnerId);

        // 조건 1: 주공이 두 번째 순서에서 낮은 카드를 냈을 때 (신호)
        if (_declarerPlayedLowAsSecond(state)) {
          // 프렌드 카드로 이길 수 있으면 사용
          if (currentWinningCard != null &&
              state.isCardStronger(friendCard, currentWinningCard, leadSuit, false)) {
            return friendCard;
          }
        }

        // 조건 2: 주공팀이 위기 상황일 때 프렌드 카드로 구출
        // (언제든지 수비팀이 이기고 있으면 프렌드 카드 사용)
        if (declarerInDanger) {
          // 프렌드 카드로 이길 수 있는지 확인
          if (currentWinningCard != null &&
              state.isCardStronger(friendCard, currentWinningCard, leadSuit, false)) {
            return friendCard;
          }
        }
      }
    }

    // === 팀 구분 ===
    bool isDefenseTeam = _isPlayerOnDefenseTeam(player, state);
    bool defenseWinning = _isDefenseTeamWinning(state, currentWinnerId, player);
    bool isAttackTeam = !isDefenseTeam;

    // === 같은 팀이 이기고 있을 때 낮은 카드 버리기 ===
    // 팀원이 이기고 있으면 높은 카드를 낭비하지 않고 낮은 카드를 버린다
    // ※ 조커/마이티 전략보다 먼저 체크해야 함
    bool myTeamWinning = (isAttackTeam && !defenseWinning) || (isDefenseTeam && defenseWinning);

    // 마지막 순서인지 확인 (4장이 이미 나온 경우)
    bool isLastPlayer = state.currentTrick != null &&
        state.currentTrick!.cards.length == 4;

    if (myTeamWinning && currentWinningCard != null) {
      // 이기고 있는 카드가 최상위 카드인지 확인
      bool winningCardIsTop = false;

      // 마지막 순서이면 무조건 팀이 이김 (더 이상 뒤집힐 수 없음)
      if (isLastPlayer) {
        winningCardIsTop = true;
      } else if (currentWinningCard.isMighty) {
        winningCardIsTop = true;
      } else if (currentWinningCard.isJoker) {
        // 조커는 마이티만 이길 수 있음
        bool mightyPlayed = _getPlayedCards(state).any((c) => c.isMighty);
        bool mightyInMyHand = player.hand.any((c) => c.isMighty);
        winningCardIsTop = mightyPlayed || mightyInMyHand ||
            !playableCards.any((c) => c.isMighty);
      } else {
        // 일반 카드: 더 높은 카드가 나올 수 있는지 확인
        final playedCards = _getPlayedCards(state);

        // 현재 이기는 카드를 이길 수 있는 카드들이 모두 내 손에 있거나 오픈되었는지 확인
        bool canBeBeaten = false;

        // 1. 마이티 체크 (마이티가 남아있으면 뒤집힐 수 있음)
        bool mightyInMyHand = player.hand.any((c) => c.isMighty);
        bool mightyPlayed = playedCards.any((c) => c.isMighty);
        if (!mightyInMyHand && !mightyPlayed) {
          canBeBeaten = true;
        }

        // 2. 조커 체크 (조커가 남아있으면 뒤집힐 수 있음)
        if (!canBeBeaten) {
          bool jokerInMyHand = player.hand.any((c) => c.isJoker);
          bool jokerPlayed = playedCards.any((c) => c.isJoker);
          if (!jokerInMyHand && !jokerPlayed) {
            canBeBeaten = true;
          }
        }

        // 3. 기루다 또는 리드 무늬의 더 높은 카드 체크
        if (!canBeBeaten && currentWinningCard.suit != null) {
          Suit winningSuit = currentWinningCard.suit!;
          int winningRankValue = currentWinningCard.rankValue;

          // 기루다가 아닌 경우, 기루다로 컷될 수 있음
          if (winningSuit != state.giruda && state.giruda != null) {
            // 기루다가 남아있는지 확인
            bool anyGirudaRemaining = false;
            for (final rank in Rank.values) {
              final girudaCard = PlayingCard(suit: state.giruda, rank: rank);
              bool inMyHand = player.hand.any((c) =>
                  c.suit == state.giruda && c.rank == rank);
              bool alreadyPlayed = playedCards.any((c) =>
                  c.suit == state.giruda && c.rank == rank);
              if (!inMyHand && !alreadyPlayed) {
                anyGirudaRemaining = true;
                break;
              }
            }
            if (anyGirudaRemaining) {
              canBeBeaten = true;
            }
          }

          // 같은 무늬의 더 높은 카드 체크
          if (!canBeBeaten) {
            for (final rank in Rank.values) {
              int rankValue = rank.index + 2;
              if (rankValue > winningRankValue) {
                bool inMyHand = player.hand.any((c) =>
                    c.suit == winningSuit && c.rank == rank);
                bool alreadyPlayed = playedCards.any((c) =>
                    c.suit == winningSuit && c.rank == rank);
                if (!inMyHand && !alreadyPlayed) {
                  canBeBeaten = true;
                  break;
                }
              }
            }
          }
        }

        winningCardIsTop = !canBeBeaten;
      }

      // 팀원이 최상위 카드로 이기고 있으면 낮은 카드 버리기
      if (winningCardIsTop) {
        // 리드 무늬가 있으면 리드 무늬 중 낮은 카드
        final suitCards = playableCards.where((c) =>
            !c.isJoker && !c.isMighty && c.suit == leadSuit).toList();
        if (suitCards.isNotEmpty) {
          suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));

          // 수비팀이 확실히 이기고 있으면 점수 카드 우선 (더 많은 점수 획득)
          // 단, 나중에 이길 가능성이 있는 점수카드는 보존
          if (isDefenseTeam && defenseWinning) {
            // 이길 확률이 낮은 점수카드 우선 (A/K가 오픈된 J/Q/10 등)
            final lowProbPointCards = suitCards.where((c) =>
                c.isPointCard && _isLowWinProbabilityPointCard(c, player, state)).toList();
            if (lowProbPointCards.isNotEmpty) {
              lowProbPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return lowProbPointCards.first;
            }
            // 이길 가능성 있는 점수카드는 보존하고 비점수카드 버리기
            final nonPointSuitCards = suitCards.where((c) => !c.isPointCard).toList();
            if (nonPointSuitCards.isNotEmpty) {
              nonPointSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return nonPointSuitCards.first;
            }
            // 점수카드만 있으면 낮은 것 버리기 (어쩔 수 없음)
            return suitCards.first;
          }

          // 공격팀은 점수 카드가 아닌 낮은 카드 우선
          final nonPointSuitCards = suitCards.where((c) => !c.isPointCard).toList();
          if (nonPointSuitCards.isNotEmpty) {
            return nonPointSuitCards.first;
          }
          // 점수 카드만 있으면 낮은 것
          return suitCards.first;
        }

        // 리드 무늬가 없으면 비기루다 중 낮은 카드 버리기 (최상위 카드 무늬 보호)
        final nonGirudaCards = playableCards.where((c) =>
            !c.isJoker && !c.isMighty && c.suit != state.giruda).toList();

        // 수비팀이 확실히 이기고 있으면 점수 카드 우선 (더 많은 점수 획득)
        // 단, 나중에 이길 가능성이 있는 점수카드는 보존
        if (isDefenseTeam && defenseWinning && nonGirudaCards.isNotEmpty) {
          // 이길 확률이 낮은 점수카드 우선
          final lowProbPointCards = nonGirudaCards.where((c) =>
              c.isPointCard && _isLowWinProbabilityPointCard(c, player, state)).toList();
          if (lowProbPointCards.isNotEmpty) {
            lowProbPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return lowProbPointCards.first;
          }
        }

        final discardCard = _selectCardToDiscard(nonGirudaCards, player, state);
        if (discardCard != null) {
          return discardCard;
        }

        // 기루다만 있으면 낮은 기루다
        final girudaCards = playableCards.where((c) =>
            !c.isJoker && !c.isMighty && c.suit == state.giruda).toList();
        if (girudaCards.isNotEmpty) {
          // 수비팀이 확실히 이기고 있으면 이길 확률 낮은 점수 카드 우선
          if (isDefenseTeam && defenseWinning) {
            final lowProbPointGirudaCards = girudaCards.where((c) =>
                c.isPointCard && _isLowWinProbabilityPointCard(c, player, state)).toList();
            if (lowProbPointGirudaCards.isNotEmpty) {
              lowProbPointGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return lowProbPointGirudaCards.first;
            }
          }
          girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return girudaCards.first;
        }

        // 조커/마이티만 남았어도 팀이 이기고 있으므로 아무거나 내기
        // (조커/마이티 낭비 방지 - 아래 전략 섹션 도달 방지)
        final anyCard = playableCards.where((c) => !c.isJoker && !c.isMighty).toList();
        if (anyCard.isNotEmpty) {
          anyCard.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return anyCard.first;
        }
        // 정말 조커/마이티만 있으면 마이티보다 조커 우선 (마이티는 더 강함)
        final jokerOnly = playableCards.where((c) => c.isJoker).toList();
        if (jokerOnly.isNotEmpty) {
          return jokerOnly.first;
        }
        // 마이티만 남은 경우
        return playableCards.first;
      } else {
        // === 공격팀: 팀원이 이기고 있지만 확실하지 않을 때 보조하기 ===
        // 팀원(프렌드/주공)의 카드가 뒤집힐 수 있으니 더 강한 카드로 확실히 가져가기
        // 단, 기루다로 "간을 치는" 것은 방지 (팀원이 리드 무늬로 이기고 있을 때)
        if (isAttackTeam) {
          // 팀원이 리드 무늬로 이기고 있으면, 리드 무늬 내에서만 보조
          // (기루다로 오버컷하면 "간을 치는" 것이므로 방지)
          bool teammateWinningWithLeadSuit = currentWinningCard != null &&
              !currentWinningCard.isJoker && !currentWinningCard.isMighty &&
              currentWinningCard.suit == leadSuit;

          if (teammateWinningWithLeadSuit) {
            // 리드 무늬 중 남은 최강 카드 계산 (상대가 낼 수 있는 최강)
            final playedCards = _getPlayedCards(state);
            PlayingCard? highestRemainingLeadSuit;

            for (int rankVal = 14; rankVal >= 2; rankVal--) {
              final rank = Rank.values[rankVal - 2];
              final leadCard = PlayingCard(suit: leadSuit, rank: rank);
              bool inMyHand = player.hand.any((c) =>
                  c.suit == leadSuit && c.rank == rank);
              bool alreadyPlayed = playedCards.any((c) =>
                  c.suit == leadSuit && c.rank == rank);
              if (!inMyHand && !alreadyPlayed) {
                highestRemainingLeadSuit = leadCard;
                break;
              }
            }

            // 리드 무늬 중 오픈된 카드 수 계산 (플레이된 카드 + 내 손)
            int openedLeadSuitCount = playedCards.where((c) => c.suit == leadSuit).length +
                player.hand.where((c) => c.suit == leadSuit).length;
            // 현재 트릭에서 나온 리드 무늬 카드도 포함
            int trickLeadSuitCount = state.currentTrick!.cards
                .where((c) => c.suit == leadSuit).length;
            openedLeadSuitCount += trickLeadSuitCount;
            int remainingLeadSuitCount = 13 - openedLeadSuitCount;

            // 뒤에 남은 플레이어 수 (현재 플레이어는 아직 안 냈으므로 +1 하지 않음)
            int remainingPlayers = 5 - state.currentTrick!.cards.length - 1;

            // 남은 리드 무늬가 남은 플레이어 수보다 적으면 기루다 컷 가능성 있음
            // (누군가는 리드 무늬가 없어서 기루다로 컷할 수 있음)
            bool girudaCutPossible = remainingPlayers > 0 &&
                remainingLeadSuitCount < remainingPlayers;

            // 팀원이 확실히 이기는지 확인
            // 1. 기루다 컷 가능성이 없고
            // 2. 상대가 낼 수 있는 리드 무늬 최강보다 팀원 카드가 높으면 확실히 이김
            bool teammateWinningSecurely = !girudaCutPossible &&
                (highestRemainingLeadSuit == null ||
                 currentWinningCard.rankValue > highestRemainingLeadSuit.rankValue);

            if (teammateWinningSecurely) {
              // 팀원이 확실히 이기면 낮은 카드 버리기
              final suitCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMighty && c.suit == leadSuit).toList();
              if (suitCards.isNotEmpty) {
                suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                final nonPointCards = suitCards.where((c) => !c.isPointCard).toList();
                if (nonPointCards.isNotEmpty) {
                  return nonPointCards.first;
                }
                return suitCards.first;
              }
              // 리드 무늬가 없으면 비기루다 중 낮은 카드
              final nonGirudaCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMighty && c.suit != state.giruda).toList();
              if (nonGirudaCards.isNotEmpty) {
                nonGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                final nonPointCards = nonGirudaCards.where((c) => !c.isPointCard).toList();
                if (nonPointCards.isNotEmpty) {
                  return nonPointCards.first;
                }
                return nonGirudaCards.first;
              }
              // 기루다만 있으면 낮은 기루다
              final girudaCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMighty && c.suit == state.giruda).toList();
              if (girudaCards.isNotEmpty) {
                girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return girudaCards.first;
              }
            } else {
              // 팀원이 역전될 수 있으면 리드 무늬 내에서 보조
              // 상대 최강보다 높은 리드 무늬 카드 찾기
              final strongerLeadSuitCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMighty && c.suit == leadSuit &&
                  c.rankValue > highestRemainingLeadSuit!.rankValue).toList();

              if (strongerLeadSuitCards.isNotEmpty) {
                // 이길 수 있는 카드 중 가장 낮은 것 선택
                strongerLeadSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return strongerLeadSuitCards.first;
              }

              // 팀원이 약한 카드를 냈고 리드 무늬로 이길 수 없을 때
              // 조커나 마이티로 트릭을 가져오기
              if (currentWinningCard.rankValue <= 7) {
                // 마이티가 있으면 사용 (조커보다 강함)
                final mighty = playableCards.where((c) => c.isMighty).toList();
                if (mighty.isNotEmpty) {
                  return mighty.first;
                }
                // 조커가 있으면 사용 (조커콜 상태가 아닐 때만)
                bool jokerCalled = state.currentTrick?.jokerCall == JokerCallType.jokerCall;
                if (!jokerCalled) {
                  final joker = playableCards.where((c) => c.isJoker).toList();
                  if (joker.isNotEmpty) {
                    return joker.first;
                  }
                }
              }

              // 리드 무늬로 도울 수 없으면 낮은 카드 버리기 (기루다로 컷하지 않음)
              final suitCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMighty && c.suit == leadSuit).toList();
              if (suitCards.isNotEmpty) {
                suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                final nonPointCards = suitCards.where((c) => !c.isPointCard).toList();
                if (nonPointCards.isNotEmpty) {
                  return nonPointCards.first;
                }
                return suitCards.first;
              }
              // 리드 무늬가 없어도 기루다로 컷하지 않고 낮은 카드 버리기
              final nonGirudaCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMighty && c.suit != state.giruda).toList();
              if (nonGirudaCards.isNotEmpty) {
                nonGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                final nonPointCards = nonGirudaCards.where((c) => !c.isPointCard).toList();
                if (nonPointCards.isNotEmpty) {
                  return nonPointCards.first;
                }
                return nonGirudaCards.first;
              }
              // 기루다만 있으면 낮은 기루다 (어쩔 수 없음)
              final girudaCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMighty && c.suit == state.giruda).toList();
              if (girudaCards.isNotEmpty) {
                girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return girudaCards.first;
              }
            }
          }
        }
      }
    }

    // === 상대팀 조커에 대한 마이티 대응 ===
    // 상대팀이 조커로 이기려 할 때 점수 카드 2장 이상이면 마이티로 선공 탈환
    if (currentWinningCard != null && currentWinningCard.isJoker) {
      // 상대팀이 조커로 이기고 있는지 확인
      bool opponentWinningWithJoker = (isAttackTeam && defenseWinning) ||
          (isDefenseTeam && !defenseWinning);

      if (opponentWinningWithJoker) {
        // 현재 트릭의 점수 카드 수 계산
        int pointCardsInTrick = state.currentTrick!.cards
            .where((c) => c.isPointCard || c.isJoker).length;

        // 점수 카드 2장 이상이고 마이티가 있으면 마이티 사용
        if (pointCardsInTrick >= 2) {
          final mighty = playableCards.where((c) => c.isMighty).toList();
          if (mighty.isNotEmpty) {
            return mighty.first;
          }
        }
      }
    }

    // === 공격팀 조커로 점수 카드 수집 전략 ===
    // 점수 카드가 3장 이상 쌓였을 때 조커로 가져오기
    // 단, 같은 팀이 확실히 이기고 있으면 조커 낭비하지 않음
    if (isAttackTeam && state.currentTrickNumber > 1 && state.currentTrickNumber < 10) {
      final joker = playableCards.where((c) => c.isJoker).toList();
      if (joker.isNotEmpty) {
        // 현재 트릭의 점수 카드 수 계산
        int pointCardsInTrick = state.currentTrick!.cards
            .where((c) => c.isPointCard || c.isJoker).length;

        // 점수 카드 3장 이상이고, 현재 이기고 있는 카드가 마이티가 아니면 조커 사용
        if (pointCardsInTrick >= 3) {
          if (currentWinningCard == null || !currentWinningCard.isMighty) {
            // 조커콜 상태가 아닐 때만 사용
            bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
            if (!jokerCalled) {
              // 같은 팀이 확실히 이기고 있는지 확인
              bool teamWinningSecurely = false;
              if (!defenseWinning && currentWinningCard != null) {
                // 공격팀이 이기고 있을 때, 이기는 카드가 최상위인지 확인
                if (currentWinningCard.isMighty) {
                  teamWinningSecurely = true;
                } else if (currentWinningCard.isJoker) {
                  teamWinningSecurely = true;
                } else {
                  // 실효 가치 14 이상(A급)이면 확실히 이김
                  int effectiveValue = _getEffectiveCardValue(currentWinningCard, state);
                  if (effectiveValue >= 14) {
                    teamWinningSecurely = true;
                  }
                }
              }
              // 같은 팀이 확실히 이기고 있지 않을 때만 조커 사용
              if (!teamWinningSecurely) {
                return joker.first;
              }
            }
          }
        }
      }
    }

    // === 공격팀 후반전 조커 전략 사용 ===
    // 후반전(트릭 7 이후)에 상대 기루다가 소진되었으면 조커로 선공 확보
    if (isAttackTeam && state.currentTrickNumber >= 7 && state.currentTrickNumber < 10) {
      final joker = playableCards.where((c) => c.isJoker).toList();
      if (joker.isNotEmpty) {
        final remainingGiruda = _getRemainingGirudaCount(state, player);
        // 상대 기루다가 3장 이하로 남았고, 조커로 이길 수 있으면 사용
        if (remainingGiruda <= 3) {
          if (currentWinningCard == null || !currentWinningCard.isMighty) {
            bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
            if (!jokerCalled) {
              // 같은 팀이 확실히 이기고 있는지 확인
              bool teamWinningSecurely = false;
              if (!defenseWinning && currentWinningCard != null) {
                if (currentWinningCard.isMighty || currentWinningCard.isJoker) {
                  teamWinningSecurely = true;
                } else {
                  int effectiveValue = _getEffectiveCardValue(currentWinningCard, state);
                  if (effectiveValue >= 14) {
                    teamWinningSecurely = true;
                  }
                }
              }
              // 우리 팀이 확실히 이기고 있지 않을 때만 조커 사용
              if (!teamWinningSecurely && defenseWinning) {
                return joker.first;
              }
            }
          }
        }
      }
    }

    // === 공격팀 선공권 탈환 전략 ===
    // 공격팀(주공/프렌드)이 선공권을 잃었을 때 마이티/조커로 선공권을 되찾는다
    // 선공권이 있어야 자신이 가진 높은 무늬로 공격하여 이길 가능성이 높아진다
    if (isAttackTeam && defenseWinning) {
      // 공격팀인데 수비팀이 이기고 있으면 마이티/조커로 선공권 탈환 시도
      bool hasJoker = player.hand.any((c) => c.isJoker);
      bool hasMighty = playableCards.any((c) => c.isMighty);

      // 마이티 무늬 확인 (기루다가 스페이드면 다이아, 아니면 스페이드)
      Suit mightySuit = state.giruda == Suit.spade ? Suit.diamond : Suit.spade;

      // 컷된 무늬와 남은 기루다 확인
      final cutSuits = _getCutSuits(state);
      final remainingGiruda = _getRemainingGirudaCount(state, player);

      // 마이티 대신 사용할 수 있는 최상위 카드 찾기
      // (실효가치 14+ 또는 마이티와 같은 무늬의 K)
      // 단, 컷된 무늬는 제외 (상대 기루다 0이면 모든 무늬 허용)
      final topCardsInstead = playableCards.where((c) {
        if (c.isMighty || c.isJoker) return false;
        // 컷된 무늬는 우선순위 낮춤 (상대 기루다 없으면 허용)
        if (remainingGiruda > 0 && c.suit != null && cutSuits.contains(c.suit)) {
          return false;
        }
        // 마이티와 같은 무늬의 K (마이티가 A이므로 K가 최상위)
        if (c.suit == mightySuit && c.rank == Rank.king) return true;
        // 실효가치 14 이상
        return _getEffectiveCardValue(c, state) >= 14;
      }).toList();

      // 최상위 카드가 있고 현재 이기는 카드를 이길 수 있으면 최상위 카드 우선
      if (topCardsInstead.isNotEmpty && currentWinningCard != null) {
        // 현재 이기는 카드가 조커/마이티가 아니면 최상위 카드로 이길 수 있음
        if (!currentWinningCard.isJoker && !currentWinningCard.isMighty) {
          // 가장 높은 실효가치 카드 선택
          topCardsInstead.sort((a, b) =>
              _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
          final topCard = topCardsInstead.first;
          // 현재 이기는 카드보다 강하면 사용
          if (state.isCardStronger(topCard, currentWinningCard, leadSuit, false)) {
            return topCard;
          }
        }
      }

      // 마이티로 선공권 탈환 (첫 트릭 제외)
      // 단, 조커가 있으면 조커를 먼저 사용하고 마이티는 상대 조커 대응용으로 아낌
      if (state.currentTrickNumber > 1 && hasMighty) {
        final mighty = playableCards.where((c) => c.isMighty).toList();
        // 현재 이기고 있는 카드가 조커가 아니면 마이티 사용
        if (currentWinningCard != null && !currentWinningCard.isJoker) {
          // 조커가 없거나, 점수 카드가 3장 이상일 때만 마이티 사용
          int pointCardsInTrick = state.currentTrick!.cards
              .where((c) => c.isPointCard || c.isJoker).length;
          if (!hasJoker || pointCardsInTrick >= 3) {
            return mighty.first;
          }
        }
      }

      // 조커로 선공권 탈환 (첫 트릭 및 마지막 트릭 제외)
      if (state.currentTrickNumber > 1 && state.currentTrickNumber < 10) {
        final joker = playableCards.where((c) => c.isJoker).toList();
        if (joker.isNotEmpty) {
          // 현재 이기고 있는 카드가 마이티가 아니면 조커 사용
          if (currentWinningCard != null && !currentWinningCard.isMighty) {
            // 조커콜 상태가 아닐 때만 사용
            bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
            if (!jokerCalled) {
              // 선공권 탈환 후 유지할 최상위 카드가 있는지 확인
              // 최상위 카드 없으면 점수 많을 때 사용하는 게 나음
              bool hasTopCards = player.hand.any((c) =>
                  c.isMighty ||
                  (!c.isJoker && _getEffectiveCardValue(c, state) >= 14));
              if (hasTopCards) {
                return joker.first;
              }
            }
          }
        }
      }
    }

    // === 공격팀 마이티로 점수 카드 수집 전략 ===
    // 조커가 없고 점수 카드가 많을 때 마이티로 수집
    if (isAttackTeam && state.currentTrickNumber > 1) {
      final mighty = playableCards.where((c) => c.isMighty).toList();
      if (mighty.isNotEmpty) {
        bool hasJoker = player.hand.any((c) => c.isJoker);
        int pointCardsInTrick = state.currentTrick!.cards
            .where((c) => c.isPointCard || c.isJoker).length;

        // 조커가 없고 점수 카드 3장 이상이면 마이티 사용
        // 또는 점수 카드 4장 이상이면 조커 유무와 관계없이 마이티 사용
        if ((!hasJoker && pointCardsInTrick >= 3) || pointCardsInTrick >= 4) {
          // 같은 팀이 확실히 이기고 있지 않을 때만
          bool teamWinningSecurely = false;
          if (!defenseWinning && currentWinningCard != null) {
            if (currentWinningCard.isMighty || currentWinningCard.isJoker) {
              teamWinningSecurely = true;
            } else {
              int effectiveValue = _getEffectiveCardValue(currentWinningCard, state);
              if (effectiveValue >= 14) {
                teamWinningSecurely = true;
              }
            }
          }
          if (!teamWinningSecurely) {
            // 마이티 대신 최상위 카드로 이길 수 있으면 최상위 카드 우선
            Suit mightySuit = state.giruda == Suit.spade ? Suit.diamond : Suit.spade;
            final cutSuits = _getCutSuits(state);
            final remainingGiruda = _getRemainingGirudaCount(state, player);

            final topCardsInstead = playableCards.where((c) {
              if (c.isMighty || c.isJoker) return false;
              // 컷된 무늬는 우선순위 낮춤 (상대 기루다 없으면 허용)
              if (remainingGiruda > 0 && c.suit != null && cutSuits.contains(c.suit)) {
                return false;
              }
              if (c.suit == mightySuit && c.rank == Rank.king) return true;
              return _getEffectiveCardValue(c, state) >= 14;
            }).toList();

            if (topCardsInstead.isNotEmpty && currentWinningCard != null &&
                !currentWinningCard.isJoker && !currentWinningCard.isMighty) {
              // 마지막 순서인지 확인
              bool isLastPlayer = state.currentTrick != null &&
                  state.currentTrick!.cards.length == 4;
              if (isLastPlayer) {
                // 마지막 순서: 이길 수 있는 최소의 카드 선택
                topCardsInstead.sort((a, b) =>
                    _getEffectiveCardValue(a, state).compareTo(_getEffectiveCardValue(b, state)));
              } else {
                // 중간 순서: 확실하게 이기기 위해 강한 카드
                topCardsInstead.sort((a, b) =>
                    _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
              }
              for (final topCard in topCardsInstead) {
                if (state.isCardStronger(topCard, currentWinningCard, leadSuit, false)) {
                  return topCard;
                }
              }
            }
            return mighty.first;
          }
        }
      }
    }

    // === 공격팀 후반전 마이티 전략 ===
    // 후반전(트릭 8 이후)에 마이티를 사용하여 확실한 승리 확보
    if (isAttackTeam && state.currentTrickNumber >= 8) {
      final mighty = playableCards.where((c) => c.isMighty).toList();
      if (mighty.isNotEmpty) {
        // 같은 팀이 확실히 이기고 있으면 마이티 사용 안 함
        bool teamWinningSecurely = false;
        if (!defenseWinning && currentWinningCard != null) {
          if (currentWinningCard.isMighty || currentWinningCard.isJoker) {
            teamWinningSecurely = true;
          } else {
            int effectiveValue = _getEffectiveCardValue(currentWinningCard, state);
            if (effectiveValue >= 14) {
              teamWinningSecurely = true;
            }
          }
        }

        if (!teamWinningSecurely) {
          // 수비팀이 이기고 있으면 마이티 사용
          if (defenseWinning) {
            // 마이티 대신 최상위 카드로 이길 수 있으면 최상위 카드 우선
            Suit mightySuit = state.giruda == Suit.spade ? Suit.diamond : Suit.spade;
            final cutSuits = _getCutSuits(state);
            final remainingGiruda = _getRemainingGirudaCount(state, player);

            final topCardsInstead = playableCards.where((c) {
              if (c.isMighty || c.isJoker) return false;
              // 컷된 무늬는 우선순위 낮춤 (상대 기루다 없으면 허용)
              if (remainingGiruda > 0 && c.suit != null && cutSuits.contains(c.suit)) {
                return false;
              }
              if (c.suit == mightySuit && c.rank == Rank.king) return true;
              return _getEffectiveCardValue(c, state) >= 14;
            }).toList();

            if (topCardsInstead.isNotEmpty && currentWinningCard != null &&
                !currentWinningCard.isJoker && !currentWinningCard.isMighty) {
              // 마지막 순서인지 확인
              bool isLastPlayer = state.currentTrick != null &&
                  state.currentTrick!.cards.length == 4;
              if (isLastPlayer) {
                // 마지막 순서: 이길 수 있는 최소의 카드 선택
                topCardsInstead.sort((a, b) =>
                    _getEffectiveCardValue(a, state).compareTo(_getEffectiveCardValue(b, state)));
              } else {
                // 중간 순서: 확실하게 이기기 위해 강한 카드
                topCardsInstead.sort((a, b) =>
                    _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
              }
              for (final topCard in topCardsInstead) {
                if (state.isCardStronger(topCard, currentWinningCard, leadSuit, false)) {
                  return topCard;
                }
              }
            }
            return mighty.first;
          }
        }
      }
    }

    // === 수비팀 조커로 점수 카드 탈취 전략 ===
    // 공격팀이 점수 카드를 많이 가져갈 때 조커로 뺏기
    if (isDefenseTeam && state.currentTrickNumber > 1 && state.currentTrickNumber < 10) {
      final joker = playableCards.where((c) => c.isJoker).toList();
      if (joker.isNotEmpty) {
        // 현재 트릭의 점수 카드 수 계산
        int pointCardsInTrick = state.currentTrick!.cards
            .where((c) => c.isPointCard || c.isJoker).length;

        // 점수 카드 2장 이상이고 공격팀이 이기고 있을 때 조커 사용
        if (pointCardsInTrick >= 2 && !defenseWinning) {
          if (currentWinningCard == null || !currentWinningCard.isMighty) {
            bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
            if (!jokerCalled) {
              return joker.first;
            }
          }
        }
      }
    }

    // === 수비팀 선공권 탈환 전략 ===
    // 공격팀이 이기고 있을 때 조커로 선공권 뺏기
    if (isDefenseTeam && !defenseWinning) {
      // 조커로 선공권 탈환 (첫 트릭 및 마지막 트릭 제외)
      if (state.currentTrickNumber > 1 && state.currentTrickNumber < 10) {
        final joker = playableCards.where((c) => c.isJoker).toList();
        if (joker.isNotEmpty) {
          // 현재 이기고 있는 카드가 마이티가 아니면 조커 사용
          if (currentWinningCard != null && !currentWinningCard.isMighty) {
            bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
            if (!jokerCalled) {
              // 선공권 탈환 후 유지할 최상위 카드가 있는지 확인
              // 최상위 카드 없으면 점수 많을 때 사용하는 게 나음
              bool hasTopCards = player.hand.any((c) =>
                  c.isMighty ||
                  (!c.isJoker && _getEffectiveCardValue(c, state) >= 14));
              if (hasTopCards) {
                return joker.first;
              }
            }
          }
        }
      }
    }

    // === 수비팀 후반전 조커 전략 ===
    // 후반전(트릭 7 이후)에 공격팀 기루다가 소진되었으면 조커로 점수 확보
    if (isDefenseTeam && state.currentTrickNumber >= 7 && state.currentTrickNumber < 10) {
      final joker = playableCards.where((c) => c.isJoker).toList();
      if (joker.isNotEmpty) {
        final remainingGiruda = _getRemainingGirudaCount(state, player);
        // 상대(공격팀) 기루다가 3장 이하로 남았고, 조커로 이길 수 있으면 사용
        if (remainingGiruda <= 3) {
          if (currentWinningCard == null || !currentWinningCard.isMighty) {
            bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
            if (!jokerCalled) {
              // 같은 팀이 확실히 이기고 있는지 확인
              bool teamWinningSecurely = false;
              if (defenseWinning && currentWinningCard != null) {
                if (currentWinningCard.isMighty || currentWinningCard.isJoker) {
                  teamWinningSecurely = true;
                } else {
                  int effectiveValue = _getEffectiveCardValue(currentWinningCard, state);
                  if (effectiveValue >= 14) {
                    teamWinningSecurely = true;
                  }
                }
              }
              // 공격팀이 이기고 있을 때만 조커 사용
              if (!teamWinningSecurely && !defenseWinning) {
                return joker.first;
              }
            }
          }
        }
      }
    }

    // === 수비팀 마이티로 점수 카드 탈취 전략 ===
    // 공격팀이 점수 카드를 많이 가져갈 때 마이티로 뺏기
    if (isDefenseTeam && state.currentTrickNumber > 1) {
      final mighty = playableCards.where((c) => c.isMighty).toList();
      if (mighty.isNotEmpty) {
        int pointCardsInTrick = state.currentTrick!.cards
            .where((c) => c.isPointCard || c.isJoker).length;

        // 점수 카드 3장 이상이고 공격팀이 이기고 있을 때 마이티 사용
        // 조커가 없거나 점수 4장 이상이면 마이티 사용
        bool hasJoker = player.hand.any((c) => c.isJoker);
        if ((!hasJoker && pointCardsInTrick >= 3) || pointCardsInTrick >= 4) {
          if (!defenseWinning) {
            // 현재 이기는 카드가 조커가 아니면 마이티 사용
            if (currentWinningCard == null || !currentWinningCard.isJoker) {
              return mighty.first;
            }
          }
        }
      }
    }

    // === 수비팀 선공권 탈환 전략 (마이티) ===
    // 공격팀이 이기고 있을 때 마이티로 선공권 뺏기
    if (isDefenseTeam && !defenseWinning && state.currentTrickNumber > 1) {
      final mighty = playableCards.where((c) => c.isMighty).toList();
      if (mighty.isNotEmpty) {
        // 현재 이기고 있는 카드가 조커가 아니면 마이티 사용
        if (currentWinningCard != null && !currentWinningCard.isJoker) {
          // 조커가 있으면 조커 먼저, 마이티는 상대 조커 대응용으로 아낌
          bool hasJoker = player.hand.any((c) => c.isJoker);
          int pointCardsInTrick = state.currentTrick!.cards
              .where((c) => c.isPointCard || c.isJoker).length;
          // 조커가 없거나 점수 카드 3장 이상이면 마이티 사용
          if (!hasJoker || pointCardsInTrick >= 3) {
            // 선공권 탈환 후 유지할 최상위 카드가 있는지 확인
            bool hasTopCards = player.hand.any((c) =>
                !c.isMighty && !c.isJoker &&
                _getEffectiveCardValue(c, state) >= 14);
            if (hasTopCards) {
              return mighty.first;
            }
          }
        }
      }
    }

    // === 수비팀 후반전 마이티 전략 ===
    // 후반전(트릭 8 이후)에 마이티를 사용하여 점수 확보
    if (isDefenseTeam && state.currentTrickNumber >= 8) {
      final mighty = playableCards.where((c) => c.isMighty).toList();
      if (mighty.isNotEmpty) {
        // 같은 팀이 확실히 이기고 있으면 마이티 사용 안 함
        bool teamWinningSecurely = false;
        if (defenseWinning && currentWinningCard != null) {
          if (currentWinningCard.isMighty || currentWinningCard.isJoker) {
            teamWinningSecurely = true;
          } else {
            int effectiveValue = _getEffectiveCardValue(currentWinningCard, state);
            if (effectiveValue >= 14) {
              teamWinningSecurely = true;
            }
          }
        }
        if (!teamWinningSecurely) {
          // 공격팀이 이기고 있으면 마이티 사용
          if (!defenseWinning) {
            // 현재 이기는 카드가 조커가 아니면 마이티 사용
            if (currentWinningCard == null || !currentWinningCard.isJoker) {
              return mighty.first;
            }
          }
        }
      }
    }

    // === 공격팀 카드 아끼기 전략 ===
    // 주공팀이 높은 기루다로 이길 확률이 높으면 낮은 카드를 우선 버린다
    bool attackTeamWinning = isAttackTeam && !defenseWinning;

    if (isAttackTeam && attackTeamWinning) {
      // 공격팀이 이기고 있으면 낮은 카드를 버려서 강한 카드 아끼기

      // 높은 기루다 보유 확인 (실효 가치 기준: 현재 가장 높은 카드인지 확인)
      bool hasHighGiruda = false;
      if (state.giruda != null) {
        // 기루다 중 실효 가치가 A(14) 이상인 카드 = 현재 가장 높은 카드
        hasHighGiruda = player.hand.any((c) =>
            !c.isJoker && !c.isMighty && c.suit == state.giruda &&
            _getEffectiveCardValue(c, state) >= 14);
      }

      // 마이티/조커 보유 확인
      bool hasMightyOrJoker = player.hand.any((c) => c.isMighty || c.isJoker);

      // 강한 카드가 있으면 낮은 카드 우선 버리기
      if (hasHighGiruda || hasMightyOrJoker) {
        // 리드 무늬가 있으면 리드 무늬 중 낮은 카드
        final suitCards = playableCards.where((c) =>
            !c.isJoker && !c.isMighty && c.suit == leadSuit).toList();
        if (suitCards.isNotEmpty) {
          suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          // 점수 카드가 아닌 낮은 카드 우선
          final nonPointSuitCards = suitCards.where((c) => !c.isPointCard).toList();
          if (nonPointSuitCards.isNotEmpty) {
            return nonPointSuitCards.first;
          }
          return suitCards.first;
        }

        // 리드 무늬가 없으면 비기루다 중 낮은 카드 버리기 (최상위 카드 무늬 보호)
        final nonGirudaCards2 = playableCards.where((c) =>
            !c.isJoker && !c.isMighty && c.suit != state.giruda).toList();
        final discardCard2 = _selectCardToDiscard(nonGirudaCards2, player, state);
        if (discardCard2 != null) {
          return discardCard2;
        }
      }
    }

    // === 수비팀 점수 카드 전략 ===
    // 프렌드가 공개되고, 내가 수비팀이고, 수비팀이 이길 확률이 높으면 점수 카드를 낸다
    if (isDefenseTeam && defenseWinning) {
      // 수비팀이 이기고 있으면 점수 카드(10/J/Q)를 낸다
      final pointCards = playableCards.where((c) =>
          !c.isJoker && !c.isMighty && c.isPointCard &&
          (c.rank == Rank.ten || c.rank == Rank.jack || c.rank == Rank.queen)
      ).toList();

      if (pointCards.isNotEmpty) {
        // 점수 카드 중 가장 낮은 것부터 (10 < J < Q)
        pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        return pointCards.first;
      }
    }

    // === 기존 로직 ===
    final suitCards =
        playableCards.where((c) => !c.isJoker && c.suit == leadSuit).toList();

    if (suitCards.isNotEmpty) {
      // 마지막 순서인지 확인 (5명 중 5번째 = 4장이 이미 나온 상태)
      bool isLastPlayer = state.currentTrick != null &&
          state.currentTrick!.cards.length == 4;

      if (isLastPlayer) {
        // 마지막 순서: 이길 수 있는 최소의 카드 선택
        suitCards.sort((a, b) => _getEffectiveCardValue(a, state).compareTo(_getEffectiveCardValue(b, state))); // 오름차순
        for (final card in suitCards) {
          if (currentWinningCard != null &&
              state.isCardStronger(card, currentWinningCard, leadSuit, false)) {
            return card;
          }
        }
      } else {
        // 중간 순서: 확실하게 이길 수 있는 강한 카드 선택
        suitCards.sort((a, b) => _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state))); // 내림차순
        for (final card in suitCards) {
          if (currentWinningCard != null &&
              state.isCardStronger(card, currentWinningCard, leadSuit, false)) {
            return card;
          }
        }
      }

      // 수비팀이고 수비팀이 이기고 있으면 점수 카드 우선
      if (isDefenseTeam && defenseWinning) {
        final suitPointCards = suitCards.where((c) => c.isPointCard).toList();
        if (suitPointCards.isNotEmpty) {
          suitPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return suitPointCards.first;
        }
      }

      // 상대팀이 이기고 있으면 점수 카드를 피하고 낮은 카드 버리기
      bool opponentWinning = (isDefenseTeam && !defenseWinning) || (isAttackTeam && defenseWinning);
      if (opponentWinning) {
        // 점수 카드가 아닌 카드 중 가장 낮은 카드
        final nonPointSuitCards = suitCards.where((c) => !c.isPointCard).toList();
        if (nonPointSuitCards.isNotEmpty) {
          nonPointSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return nonPointSuitCards.first;
        }
        // 점수 카드만 있으면 가장 낮은 점수 카드 (어쩔 수 없음)
        suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        return suitCards.first;
      }

      return suitCards.last;
    }

    // === 컷(기루다로 자르기) 전략 ===
    if (state.giruda != null) {
      final girudaCards =
          playableCards.where((c) => !c.isJoker && c.suit == state.giruda).toList();

      if (girudaCards.isNotEmpty) {
        // 내 팀이 이기고 있는지 확인
        bool myTeamWinning = (isAttackTeam && !defenseWinning) || (isDefenseTeam && defenseWinning);

        if (myTeamWinning) {
          // 내 팀이 이기고 있으면 컷하지 않고 낮은 카드 버리기
          // 비기루다 중 낮은 카드 버리기 (최상위 카드 무늬 보호)
          final nonGirudaCards3 = playableCards.where((c) =>
              !c.isJoker && !c.isMighty && c.suit != state.giruda).toList();
          bool allowPoint = isDefenseTeam && defenseWinning;
          final discardCard3 = _selectCardToDiscard(nonGirudaCards3, player, state, allowPointCards: allowPoint);
          if (discardCard3 != null) {
            return discardCard3;
          }
          // 비기루다가 없으면 가장 낮은 기루다
          girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return girudaCards.first;
        } else {
          // 내 팀이 지고 있으면 이길 수 있는 최소의 기루다로 컷
          girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue)); // 낮은 순

          // 현재 이기고 있는 카드를 이길 수 있는 가장 낮은 기루다 찾기
          for (final girudaCard in girudaCards) {
            if (currentWinningCard != null &&
                state.isCardStronger(girudaCard, currentWinningCard, leadSuit, false)) {
              return girudaCard;
            }
          }

          // 이길 수 없으면 낮은 카드 버리기 (최상위 카드 무늬 보호)
          final nonGirudaCards4 = playableCards.where((c) =>
              !c.isJoker && !c.isMighty && c.suit != state.giruda).toList();
          final discardCard4 = _selectCardToDiscard(nonGirudaCards4, player, state);
          if (discardCard4 != null) {
            return discardCard4;
          }
          // 기루다만 있으면 가장 낮은 기루다
          return girudaCards.first;
        }
      }
    }

    // 수비팀이 이기고 있으면 점수 카드 우선
    if (isDefenseTeam && defenseWinning) {
      final pointCards = playableCards.where((c) => c.isPointCard && !c.isMighty).toList();
      if (pointCards.isNotEmpty) {
        pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        return pointCards.first;
      }
    }

    // 마이티가 이기고 있으면 조커를 내지 않음 (조커는 마이티를 이길 수 없음)
    bool mightyWinning = currentWinningCard != null && currentWinningCard.isMighty;

    // 조커/마이티 제외하고 낮은 카드 버리기
    final nonSpecialNonPointCards = playableCards.where((c) =>
        !c.isPointCard && !c.isJoker && !c.isMighty).toList();
    if (nonSpecialNonPointCards.isNotEmpty) {
      nonSpecialNonPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
      return nonSpecialNonPointCards.first;
    }

    // 조커/마이티 제외하고 점수 카드 버리기
    final nonSpecialCards = playableCards.where((c) =>
        !c.isJoker && !c.isMighty).toList();
    if (nonSpecialCards.isNotEmpty) {
      nonSpecialCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
      return nonSpecialCards.first;
    }

    // 조커/마이티만 남은 경우
    // 마이티가 이기고 있으면 조커를 내지 않고 마이티를 냄 (조커 보존)
    if (mightyWinning) {
      final mighty = playableCards.where((c) => c.isMighty).toList();
      if (mighty.isNotEmpty) {
        return mighty.first;
      }
    }

    // 그 외에는 조커 우선 (마이티는 더 강하므로 아끼기)
    final joker = playableCards.where((c) => c.isJoker).toList();
    if (joker.isNotEmpty) {
      return joker.first;
    }

    return playableCards.first;
  }

  // 현재 트릭에서 이기고 있는 플레이어 ID 찾기
  int? _findCurrentWinnerId(GameState state) {
    if (state.currentTrick == null || state.currentTrick!.cards.isEmpty) {
      return null;
    }

    int winnerIndex = 0;
    PlayingCard? winning;
    final leadSuit = state.currentTrick!.leadSuit;

    for (int i = 0; i < state.currentTrick!.cards.length; i++) {
      final card = state.currentTrick!.cards[i];
      if (winning == null) {
        winning = card;
        winnerIndex = i;
      } else if (state.isCardStronger(card, winning, leadSuit, false)) {
        winning = card;
        winnerIndex = i;
      }
    }

    return state.currentTrick!.playerOrder[winnerIndex];
  }

  // 주공이 위험한 상황인지 확인
  bool _isDeclarerInDanger(GameState state, int? currentWinnerId) {
    if (currentWinnerId == null) return false;

    // 현재 이기고 있는 사람이 수비팀인지 확인
    final winner = state.players[currentWinnerId];

    // 주공이나 이미 공개된 프렌드가 이기고 있으면 위험하지 않음
    if (winner.isDeclarer) return false;
    if (state.friendRevealed && winner.isFriend) return false;

    // 수비팀이 이기고 있으면 주공 위험
    return true;
  }

  // 주공이 두 번째 순서에서 낮은 카드를 냈는지 확인 (프렌드에게 신호)
  bool _declarerPlayedLowAsSecond(GameState state) {
    if (state.currentTrick == null) return false;
    if (state.currentTrick!.cards.length < 2) return false;

    // 두 번째로 낸 플레이어가 주공인지 확인
    if (state.currentTrick!.playerOrder.length < 2) return false;
    int secondPlayerId = state.currentTrick!.playerOrder[1];
    if (secondPlayerId != state.declarerId) return false;

    // 주공이 낸 카드 (두 번째 카드)
    final declarerCard = state.currentTrick!.cards[1];

    // 낮은 카드인지 확인 (9 이하, 점수 카드 아님, 조커/마이티 아님)
    if (declarerCard.isJoker || declarerCard.isMighty) return false;
    if (declarerCard.isPointCard) return false;

    // 낮은 카드 (2-9)를 냈으면 신호로 판단
    return declarerCard.rankValue <= 9;
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

  // 플레이어가 수비팀인지 확인
  bool _isPlayerOnDefenseTeam(Player player, GameState state) {
    // 주공이면 수비팀 아님
    if (player.isDeclarer) return false;

    // 프렌드가 공개되었고 프렌드이면 수비팀 아님
    if (state.friendRevealed && player.isFriend) return false;

    // 프렌드가 아직 공개되지 않은 경우, 자신이 프렌드 카드를 가지고 있는지 확인
    if (!state.friendRevealed && state.friendDeclaration?.card != null) {
      final friendCard = state.friendDeclaration!.card!;
      bool hasFriendCard;
      if (friendCard.isJoker) {
        // 조커 프렌드인 경우
        hasFriendCard = player.hand.any((c) => c.isJoker);
      } else {
        hasFriendCard = player.hand.any((c) =>
            c.suit == friendCard.suit && c.rank == friendCard.rank);
      }
      if (hasFriendCard) return false; // 프렌드 카드를 가지고 있으면 주공팀
    }

    // 그 외에는 수비팀
    return true;
  }

  // 수비팀이 현재 트릭에서 이기고 있는지 확인
  // player: 현재 판단하는 플레이어 (자신이 프렌드인지 알 수 있음)
  bool _isDefenseTeamWinning(GameState state, int? currentWinnerId, Player player) {
    if (currentWinnerId == null) return false;

    final winner = state.players[currentWinnerId];

    // 주공이 이기고 있으면 수비팀이 이기는 것 아님
    if (winner.isDeclarer) return false;

    // 프렌드가 공개되고 프렌드가 이기고 있으면 수비팀이 이기는 것 아님
    if (state.friendRevealed && winner.isFriend) return false;

    // 프렌드가 아직 공개되지 않은 경우
    if (!state.friendRevealed) {
      // 현재 플레이어가 프렌드 카드를 가지고 있으면 자신이 프렌드임을 알고 있음
      // 이 경우 이기고 있는 사람이 자신이 아니면 수비팀이 이기는 것
      if (state.friendDeclaration?.card != null) {
        final friendCard = state.friendDeclaration!.card!;
        bool iAmFriend;
        if (friendCard.isJoker) {
          iAmFriend = player.hand.any((c) => c.isJoker);
        } else {
          iAmFriend = player.hand.any((c) =>
              c.suit == friendCard.suit && c.rank == friendCard.rank);
        }

        if (iAmFriend) {
          // 내가 프렌드인데, 이기고 있는 사람이 나도 아니고 주공도 아니면 수비팀이 이기는 것
          if (winner.id != player.id && !winner.isDeclarer) {
            return true;
          }
          return false; // 내가 또는 주공이 이기고 있으므로 공격팀이 이기는 것
        }
      }

      // 내가 프렌드가 아니면 보수적으로 판단
      // 주공인 경우: 현재 트릭에서 프렌드 카드가 나왔는지 확인
      if (player.isDeclarer && state.friendDeclaration?.card != null) {
        final friendCard = state.friendDeclaration!.card!;
        // 현재 트릭에서 프렌드 카드를 낸 플레이어 찾기
        int? friendPlayerId;
        if (state.currentTrick != null) {
          for (int i = 0; i < state.currentTrick!.cards.length; i++) {
            final card = state.currentTrick!.cards[i];
            bool isFriendCard;
            if (friendCard.isJoker) {
              isFriendCard = card.isJoker;
            } else {
              isFriendCard = card.suit == friendCard.suit && card.rank == friendCard.rank;
            }
            if (isFriendCard) {
              // 트릭의 i번째 카드를 낸 플레이어 ID 계산
              final leaderId = state.currentTrick!.leadPlayerId;
              friendPlayerId = (leaderId + i) % state.players.length;
              break;
            }
          }
        }

        if (friendPlayerId != null) {
          // 프렌드가 이 트릭에 참여함 - 프렌드가 이기고 있으면 공격팀이 이기는 것
          if (winner.id == friendPlayerId) {
            return false; // 프렌드가 이기고 있으므로 공격팀이 이기는 것
          }
          return true; // 프렌드가 참여했지만 이기지 않음 - 수비팀이 이기는 것
        }

        // 프렌드 카드가 아직 안 나옴 - 수비팀이 이기고 있다고 판단
        return true;
      } else if (player.isDeclarer) {
        // 노프렌드인 경우
        return true; // 주공 자신이 아니면 수비팀이 이기는 것
      }

      // 수비팀인 경우: 이기고 있는 사람이 주공이 아니고 자신도 아니면
      // 프렌드일 가능성과 수비팀일 가능성이 있음 -> 보수적으로 true로 판단
      // (수비팀끼리 협력해야 하므로)
      if (winner.id != player.id) {
        return true;
      }
      return false;
    }

    // 수비팀이 이기고 있음
    return true;
  }
}
