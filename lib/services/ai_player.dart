import 'dart:math';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';

class BidEvaluation {
  final Suit? bestGiruda;
  final int minPoints;
  final int maxPoints;
  final int optimalPoints;
  final int girudaCount;

  BidEvaluation({
    this.bestGiruda,
    required this.minPoints,
    required this.maxPoints,
    required this.optimalPoints,
    required this.girudaCount,
  });
}

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

  // 특정 무늬의 잔여 점수카드 수 (내 손과 이미 플레이된 카드 제외)
  // 마이티 미출 시 해당 무늬 리드의 점수카드 노출 위험도를 측정
  int _countRemainingPointCardsInSuit(Suit suit, GameState state, List<PlayingCard> myHand) {
    final playedCards = _getPlayedCards(state);
    const pointRanks = [Rank.ace, Rank.king, Rank.queen, Rank.jack, Rank.ten];
    int count = 0;
    for (final rank in pointRanks) {
      bool played = playedCards.any((c) => !c.isJoker && c.suit == suit && c.rank == rank);
      bool inMyHand = myHand.any((c) => !c.isJoker && c.suit == suit && c.rank == rank);
      if (!played && !inMyHand) {
        count++;
      }
    }
    return count;
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
          if (!winningCard.isJoker && !winningCard.isMightyWith(state.giruda) &&
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

  // 기루다가 오픈되었는지 확인 (기루다로 컷한 적이 있는지)
  // 기루다가 아직 오픈되지 않았으면 다른 플레이어가 기루다로 컷할 가능성이 낮음
  bool _hasGirudaBeenOpened(GameState state) {
    if (state.giruda == null) return false;

    // 과거 트릭에서 기루다가 사용되었는지 확인
    for (final trick in state.tricks) {
      for (final card in trick.cards) {
        if (!card.isJoker && card.suit == state.giruda) {
          return true;
        }
      }
    }

    // 현재 트릭에서 기루다가 사용되었는지 확인
    if (state.currentTrick != null) {
      for (final card in state.currentTrick!.cards) {
        if (!card.isJoker && card.suit == state.giruda) {
          return true;
        }
      }
    }

    return false;
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

  /// 주공의 비기루다 무늬별 보유 확률 추론
  /// 확정 void 외에도 플레이 패턴(기루다/비기루다 사용량)으로 추정
  /// 반환: 비기루다 무늬 → 보유 확률 (0.0 = void 확정, 낮을수록 void 가능성)
  Map<Suit, double> _inferDeclarerSuitHoldings(GameState state) {
    Map<Suit, double> holdings = {};
    if (state.declarerId == null || state.giruda == null) return holdings;

    final Set<Suit> confirmedVoid = _getDeclarerVoidSuits(state);

    // 주공이 플레이한 카드 분석
    Map<Suit, int> suitPlayCount = {};
    int nonGirudaPlayed = 0;

    for (final trick in state.tricks) {
      int idx = trick.playerOrder.indexOf(state.declarerId!);
      if (idx >= 0 && idx < trick.cards.length) {
        PlayingCard card = trick.cards[idx];
        if (!card.isJoker && card.suit != null) {
          suitPlayCount[card.suit!] = (suitPlayCount[card.suit!] ?? 0) + 1;
          if (card.suit != state.giruda) {
            nonGirudaPlayed++;
          }
        }
      }
    }

    // 기루다를 많이 냈으면 비기루다 보유량이 적을 가능성
    // (10장 중 기루다 비중이 높을수록 비기루다 슬롯 감소)
    int girudaPlayed = suitPlayCount[state.giruda!] ?? 0;
    double girudaFactor = girudaPlayed >= 4 ? 0.15
        : girudaPlayed >= 3 ? 0.1
        : girudaPlayed >= 2 ? 0.05 : 0.0;

    for (Suit suit in Suit.values) {
      if (suit == state.giruda) continue;

      if (confirmedVoid.contains(suit)) {
        holdings[suit] = 0.0;
      } else if ((suitPlayCount[suit] ?? 0) > 0) {
        // 해당 무늬를 낸 적 있음 → 보유 확인됨, 남아있을 확률
        int played = suitPlayCount[suit]!;
        holdings[suit] = played >= 3 ? 0.3 : played >= 2 ? 0.5 : 0.7;
      } else {
        // 한 번도 해당 무늬를 내지 않음
        // 다른 비기루다를 많이 냈을수록 이 무늬가 없을 확률 증가
        // 기루다를 많이 가진 주공은 비기루다가 적어 void 가능성 추가 증가
        holdings[suit] = (0.6 - nonGirudaPlayed * 0.12 - girudaFactor).clamp(0.1, 0.6);
      }
    }

    return holdings;
  }

  // 수비팀 동료가 기루다를 가지고 있는지 추정 (조커 선공용)
  // 수비팀 동료만 확인 (본인, 주공, 프렌드 제외)
  bool _estimateDefenseTeammatesHaveGiruda(Player player, GameState state) {
    if (state.giruda == null) return false;

    // 수비팀 동료 ID (본인, 주공, 공개된 프렌드 제외)
    Set<int> teammateIds = {};
    for (final p in state.players) {
      if (p.id == player.id) continue; // 본인 제외
      if (p.id == state.declarerId) continue; // 주공 제외
      if (state.friendRevealed && p.isFriend) continue; // 공개된 프렌드 제외
      teammateIds.add(p.id);
    }

    if (teammateIds.isEmpty) return false;

    // 기루다 void가 확인된 동료
    Set<int> girudaVoidPlayers = {};

    for (final trick in state.tricks) {
      if (trick.leadSuit != state.giruda) continue;

      for (int i = 0; i < trick.playerOrder.length && i < trick.cards.length; i++) {
        int playerId = trick.playerOrder[i];
        if (!teammateIds.contains(playerId)) continue;

        PlayingCard card = trick.cards[i];
        if (!card.isJoker && card.suit != state.giruda) {
          girudaVoidPlayers.add(playerId);
        }
      }
    }

    bool hasNonVoidTeammate = teammateIds.any((id) => !girudaVoidPlayers.contains(id));

    final playedGirudaCount = _getPlayedGirudaCount(state);
    final myGirudaCount = player.hand.where((c) => !c.isJoker && c.suit == state.giruda).length;
    final remainingGiruda = 13 - playedGirudaCount - myGirudaCount;

    return hasNonVoidTeammate && remainingGiruda > 0;
  }

  // 수비팀에 기루다가 남아있는지 추정 (프렌드용)
  // 트릭 히스토리에서 수비팀 플레이어가 기루다 void인지 확인
  bool _estimateDefenseTeamHasGiruda(Player player, GameState state) {
    if (state.giruda == null) return false;

    // 수비팀 플레이어 ID 목록 (주공과 프렌드 제외)
    Set<int> defensePlayerIds = {};
    for (final p in state.players) {
      if (p.id == state.declarerId) continue; // 주공 제외
      if (p.id == player.id) continue; // 본인(프렌드) 제외
      if (state.friendRevealed && p.isFriend) continue; // 공개된 프렌드 제외
      defensePlayerIds.add(p.id);
    }

    // 수비팀 중 기루다 void가 확인된 플레이어
    Set<int> girudaVoidPlayers = {};

    for (final trick in state.tricks) {
      // 기루다 리드가 아니면 스킵
      if (trick.leadSuit != state.giruda) continue;

      for (int i = 0; i < trick.playerOrder.length && i < trick.cards.length; i++) {
        int playerId = trick.playerOrder[i];
        if (!defensePlayerIds.contains(playerId)) continue;

        PlayingCard card = trick.cards[i];
        // 기루다 리드에 기루다가 아닌 카드를 냈으면 void
        if (!card.isJoker && card.suit != state.giruda) {
          girudaVoidPlayers.add(playerId);
        }
      }
    }

    // 수비팀 중 void가 확인되지 않은 플레이어가 있으면 기루다 보유 가능성 있음
    bool hasNonVoidDefender = defensePlayerIds.any((id) => !girudaVoidPlayers.contains(id));

    // 추가 조건: 남은 기루다가 충분히 많으면 수비팀에도 있을 확률 높음
    final playedGirudaCount = _getPlayedGirudaCount(state);
    final myGirudaCount = player.hand.where((c) => !c.isJoker && c.suit == state.giruda).length;
    final remainingGiruda = 13 - playedGirudaCount - myGirudaCount;

    // void가 확인되지 않은 수비팀이 있고, 남은 기루다가 있으면 → 수비팀에 있을 가능성
    return hasNonVoidDefender && remainingGiruda > 0;
  }

  // 카드의 실효 가치 계산 (오픈된 카드 고려)
  // A가 오픈되면 K가 가장 높은 카드가 됨 -> K의 가치 = A의 가치
  int _getEffectiveCardValue(PlayingCard card, GameState state) {
    if (card.isJoker || card.isMightyWith(state.giruda)) {
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
    if (card.isJoker || card.isMightyWith(state.giruda)) return true;

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
        bool mightyPlayed = _getPlayedCards(state).any((c) => c.isMightyWith(state.giruda));
        bool mightyInHand = hand.any((c) => c.isMightyWith(state.giruda));
        if (mightyPlayed || mightyInHand) continue;
      }

      // 아직 나오지 않은 더 높은 카드가 있음
      return false;
    }

    return true;
  }

  /// 기루다 강도 점수: 카드 쌍별 연결성 가중치 적용
  /// A/K → 2.0, A/Q → 1.7, A/J → 1.5, A/Q/J → 2.7, A/K/Q → 3.0
  /// 3.0 이상이면 기루다 후보로 검토
  double _calcGirudaStrengthScore(List<PlayingCard> suitCards) {
    if (suitCards.isEmpty) return 0;
    final ranks = suitCards.map((c) => c.rank!.index).toList()
      ..sort((a, b) => b.compareTo(a)); // 내림차순 (A=12, K=11, ...)
    double score = 0;
    int i = 0;
    while (i < ranks.length) {
      score += 1; // 쌍의 첫 번째 카드
      if (i + 1 < ranks.length) {
        final gap = ranks[i] - ranks[i + 1] - 1;
        if (gap == 0) {
          score += 1;   // 인접 (A-K, K-Q 등)
        } else if (gap == 1) {
          score += 0.7;  // 한 칸 건너뜀 (A-Q, K-J 등)
        } else {
          score += 0.5;  // 두 칸 이상 건너뜀
        }
        i += 2;
      } else {
        i += 1; // 홀수 마지막 카드
      }
    }
    return score;
  }

  /// 모든 suit에 대해 예상 점수 범위를 계산하여 최적 기루다 선택
  BidEvaluation evaluateForBidding(List<PlayingCard> hand) {
    Suit? bestGiruda;
    int bestOptimal = 0;
    int bestMin = 0;
    int bestMax = 0;
    int bestGirudaCount = 0;

    for (final suit in Suit.values) {
      final suitCards = hand.where((c) => !c.isJoker && c.suit == suit).toList();
      // 기루다 강도 점수 기반 후보 필터링 (연결성 가중치 적용)
      if (_calcGirudaStrengthScore(suitCards) < 3.0) continue;

      final (minPts, maxPts) = estimatePointRange(hand, suit);
      // 바닥패 기대값: 키카드 보유 시 약한 카드 제거 효과 증가
      final hasMighty = hand.any((c) => !c.isJoker && c.suit == ((suit == Suit.spade) ? Suit.diamond : Suit.spade) && c.rank == Rank.ace);
      final hasJoker = hand.any((c) => c.isJoker);
      final hasGirudaAce = hand.any((c) => !c.isJoker && c.suit == suit && c.rank == Rank.ace);
      final keyCardCount = (hasMighty ? 1 : 0) + (hasJoker ? 1 : 0) + (hasGirudaAce ? 1 : 0);
      final kittyBonus = keyCardCount >= 2 ? 2 : (keyCardCount >= 1 ? 1 : 0);
      final optimal = (minPts * 0.3 + maxPts * 0.7 + 1).round() + kittyBonus;

      if (optimal > bestOptimal) {
        bestOptimal = optimal;
        bestMin = minPts;
        bestMax = maxPts;
        bestGiruda = suit;
        bestGirudaCount = suitCards.length;
      }
    }

    return BidEvaluation(
      bestGiruda: bestGiruda,
      minPoints: bestMin,
      maxPoints: bestMax,
      optimalPoints: bestOptimal,
      girudaCount: bestGirudaCount,
    );
  }

  /// 배팅 결정 + 평가 정보 반환 (auto-play 모드용)
  (Bid, BidEvaluation) decideBidWithEvaluation(Player player, GameState state) {
    final hand = player.hand;
    final evaluation = evaluateForBidding(hand);

    // 적정 점수 13점 미만이면 패스
    if (evaluation.optimalPoints < 13) {
      return (Bid.pass(player.id), evaluation);
    }

    // 배팅 금액 결정
    int bidAmount;
    if (state.currentBid == null) {
      bidAmount = 13;
    } else {
      bidAmount = state.currentBid!.tricks + 1;
    }

    // 적정 점수보다 높은 배팅이 필요하면 패스
    if (bidAmount > evaluation.optimalPoints) {
      return (Bid.pass(player.id), evaluation);
    }

    bidAmount = min(bidAmount, 20);

    return (
      Bid(
        playerId: player.id,
        suit: evaluation.bestGiruda,
        tricks: bidAmount,
      ),
      evaluation,
    );
  }

  Bid decideBid(Player player, GameState state) {
    final (bid, _) = decideBidWithEvaluation(player, state);
    return bid;
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

      // === 1-1. 기루다 품질 조정 ===
      // A+K+Q 연속 보유: 기루다 지배력 보너스 (수비가 기루다로 이기기 어려움)
      if (hasGirudaAce && hasGirudaKing && hasGirudaQueen) {
        strength += 1;
      }

      // K만 있고 A 없음: 수비의 A에 K가 잡힐 리스크
      if (hasGirudaKing && !hasGirudaAce) {
        strength -= 1;
      }

      // 로우 기루다 다수 + A 부재: 컷용으로만 사용 가능, 수비 고기루다에 취약
      int girudaHighCount = (hasGirudaAce ? 1 : 0) + (hasGirudaKing ? 1 : 0) +
          (hasGirudaQueen ? 1 : 0) + (hasGirudaJack ? 1 : 0) + (hasGirudaTen ? 1 : 0);
      int girudaLowCount = girudaCards.length - girudaHighCount;
      if (girudaLowCount >= 3 && !hasGirudaAce) {
        strength -= 1;
      }
    }

    // === 1-2. 짧은 무늬 평가 (컷 기회) ===
    if (giruda != null) {
      final girudaCount = hand.where((c) => !c.isJoker && c.suit == giruda).length;
      for (final suit in Suit.values) {
        if (suit == giruda) continue;
        final suitCount = hand.where((c) => !c.isJoker && c.suit == suit).length;
        // void + 기루다 3장 이상 = 컷으로 추가 트릭 확보 가능
        if (suitCount == 0 && girudaCount >= 3) {
          strength += 1;
        }
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

    // === 3-2. 프렌드 기여 (프렌드가 파워 카드로 약 1트릭 기여) ===
    // 주공은 자신이 없는 가장 강한 카드를 프렌드로 지명
    // 프렌드가 그 카드로 트릭을 이기면 점수 카드를 보호할 수 있음
    if (!hasMighty && !hasJoker) {
      // 마이티를 프렌드로 지명 → 확실한 1트릭
      strength += 1;
    } else if (hasMighty && !hasJoker) {
      // 조커를 프렌드로 지명 → 초구 사용 불가이므로 약간 불확실
      strength += 1;
    } else if (!hasMighty && hasJoker) {
      // 마이티를 프렌드로 지명 → 확실한 1트릭
      strength += 1;
    }
    // 둘 다 있으면 → 에이스 프렌드, section 3-1에서 이미 계산됨

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

  /// 주공의 예상 득점 범위 계산 (트릭 기반)
  /// 최대: 프렌드 포함, 모든 가능한 트릭 고려
  /// 최소: 프렌드 도움 없이 (조커콜/컷 당함), 확실한 트릭만
  /// 반환: (minPoints, maxPoints)
  (int, int) estimatePointRange(List<PlayingCard> hand, Suit? giruda) {
    final mightySuit = (giruda == Suit.spade) ? Suit.diamond : Suit.spade;
    bool hasMighty = hand.any((c) =>
        !c.isJoker && c.suit == mightySuit && c.rank == Rank.ace);
    bool hasJoker = hand.any((c) => c.isJoker);

    int minTricks = 0; // 프렌드 도움 없이 확실한 트릭
    int maxTricks = 0; // 프렌드 포함 최대 트릭
    double maxAdj = 0; // 불확실한 트릭의 소수점 보정

    // === 마이티: 확실한 1트릭 ===
    if (hasMighty) { minTricks++; maxTricks++; }

    // === 조커: 거의 확실하지만 조커콜 위험 ===
    if (hasJoker) {
      maxTricks++; // 최대에 포함
      // 최소에서는 조커콜 당할 수 있으므로 제외
    }

    // === 기루다 분석 ===
    int girudaLen = 0;
    if (giruda != null) {
      final gc = hand.where((c) => !c.isJoker && c.suit == giruda).toList();
      girudaLen = gc.length;
      bool gA = gc.any((c) => c.rank == Rank.ace);
      bool gK = gc.any((c) => c.rank == Rank.king);
      bool gQ = gc.any((c) => c.rank == Rank.queen);

      // 기루다 A: 확실한 1트릭
      if (gA) { minTricks++; maxTricks++; }
      // A 다음 K: A 이후 선 유지로 K도 확보
      if (gA && gK) { minTricks++; maxTricks++; }
      // A-K-Q 연속: Q까지 확보 가능
      if (gA && gK && gQ) { maxTricks++; }
      // A+Q (K 없이): A 이후 Q가 차상위 → 최대에 포함
      if (gA && gQ && !gK) { maxTricks++; }
      // K만 있고 A 없으면: A 소진 후 K 승리 가능
      if (gK && !gA) {
        maxTricks++;
        if (gc.length >= 3) minTricks++; // 3장+ K: A가 일찍 나가므로 K 거의 확실
      }
      // K+Q 연속 (A 없이): A 소진 후 K→Q 연속 승리
      if (gK && gQ && !gA) { maxTricks++; }

      // 기루다 장수가 많으면 후반 지배 (최대)
      // 5장+A: 상대 기루다 소진 후 남은 기루다가 전부 승리
      if (gc.length >= 5 && gA) maxTricks += 2;
      else if (gc.length >= 4 && gA) maxTricks++;
      if (gc.length >= 6 && gA) maxTricks++;

      // A 없이 K 보유 시 기루다 장수 보너스
      if (!gA && gK) {
        if (gc.length >= 5) {
          minTricks++;    // 5장+K: 상대 A 소진 후 K 거의 확실
          maxTricks += 2; // 후반 기루다 지배
        } else if (gc.length >= 4) {
          maxTricks++;    // 4장+K: 일부 후반 지배
        }
        if (gc.length >= 6) maxTricks++;
      }

      // A, K 없이 Q 최상위 기루다 (4장+ 부터 유효, 3장 Q는 너무 약함)
      if (!gA && !gK && gQ) {
        if (gc.length >= 5) {
          maxTricks++; // Q가 최상위
          maxTricks += 2; // 후반 기루다 지배
        } else if (gc.length >= 4) {
          maxTricks++; // Q가 최상위
          maxTricks++; // 일부 후반 지배
        }
        // 3장 Q: A,K 둘 다 소진되기 어려움 → 보너스 없음
      }

      // 마이티+기루다A 시너지 제거: 각각 이미 +1씩 반영되어 중복
    }

    // === 비기루다 에이스/킹 ===
    for (final suit in Suit.values) {
      if (suit == giruda) continue;
      final sc = hand.where((c) => !c.isJoker && c.suit == suit).toList();
      if (sc.isEmpty) continue;

      bool hasAce = sc.any((c) =>
          c.rank == Rank.ace && !(c.suit == mightySuit && c.rank == Rank.ace));
      bool hasKing = sc.any((c) => c.rank == Rank.king);

      // 비기루다 A: 선공 시 확실한 1트릭
      if (hasAce) { minTricks++; maxTricks++; }
      // A-K 연속: 선 유지하여 K도 확보 (최대)
      if (hasAce && hasKing) { maxTricks++; }
      // K만 있고 A 없으면: 후반에 A가 나간 후 K가 이김 (불확실하므로 0.6)
      if (hasKing && !hasAce) { maxAdj += 0.6; }
    }

    // === 비기루다 취약 수트 감점 ===
    // A도 K도 없는 비기루다 수트가 2개 이상이면 수비가 해당 수트로 점수 확보
    int weakSuits = 0;
    for (final suit in Suit.values) {
      if (suit == giruda) continue;
      final sc = hand.where((c) => !c.isJoker && c.suit == suit).toList();
      if (sc.isEmpty) continue; // 보이드는 컷 가능하므로 약점 아님
      bool hasAce = sc.any((c) =>
          c.rank == Rank.ace && !(c.suit == mightySuit && c.rank == Rank.ace));
      bool hasKing = sc.any((c) => c.rank == Rank.king);
      if (!hasAce && !hasKing) weakSuits++;
    }
    if (weakSuits >= 2) minTricks -= 1;

    // === 보이드 컷 기회 (최대만) ===
    if (giruda != null) {
      final girudaCount = hand.where((c) => !c.isJoker && c.suit == giruda).length;
      for (final suit in Suit.values) {
        if (suit == giruda) continue;
        final suitCount = hand.where((c) => !c.isJoker && c.suit == suit).length;
        if (suitCount == 0 && girudaCount >= 3) {
          maxTricks++;
        }
      }
    }

    // === 프렌드 기여 ===
    // 최소: 프렌드가 마이티만 보유한 경우 (바닥패 가능성 감안, 보수적)
    // 최대: 프렌드가 마이티/조커/A를 보유한 경우
    if (!hasMighty) {
      // 마이티 프렌드: 확실한 1트릭 (바닥패에 있을 수 있지만 93% 확률로 누군가 보유)
      minTricks++;
      maxTricks++;
    }
    if (!hasJoker) {
      // 최대: 프렌드가 조커도 보유 가능 (조커콜 위험 → 최대에만)
      maxTricks++;
      // 수비 조커가 트릭 탈취 가능 → 최소에서 감점
      minTricks -= 1;
    }
    // 마이티+조커 둘 다 미보유: 수비가 양대 키카드 보유 → 최소 2트릭 탈취
    if (!hasMighty && !hasJoker) {
      minTricks -= 1;
    }
    // 최대: 프렌드가 비기루다 A를 추가로 보유 가능
    maxTricks++;
    // 마이티+조커 모두 보유 시 기루다 프렌드(K/Q)의 안정성
    if (hasMighty && hasJoker && giruda != null) {
      bool hasGirudaAce = hand.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace);
      if (hasGirudaAce) { minTricks++; } // 기루다A 보유 → 프렌드 K/Q 거의 확실
    }

    // 트릭당 평균 점수 카드: 약 2장 (20장 / 10트릭)
    // 강한 핸드는 점수카드 밀집 트릭을 먹어 ppt 2.0~2.5 분포
    int minPoints = (minTricks * 1.5).round().clamp(0, 20);
    int maxPoints = ((maxTricks + maxAdj) * 2.2).round().clamp(0, 20);

    // === 런 감지: 마이티+조커+기루다A+5장기루다 → 올런 가능 ===
    if (hasMighty && hasJoker && giruda != null && girudaLen >= 5) {
      bool hasGirudaAce = hand.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace);
      if (hasGirudaAce && maxPoints < 20) { maxPoints = 20; }
    }
    // === 런 감지 2단계: 키카드 2개+ & 기루다A & 기루다4장+ → 최대 18점 이상 ===
    if (giruda != null && girudaLen >= 4) {
      bool hasGirudaAce = hand.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace);
      if (hasGirudaAce) {
        bool hasGirudaKing = hand.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.king);
        int keyCards = (hasMighty ? 1 : 0) + (hasJoker ? 1 : 0) +
            (hasGirudaKing ? 1 : 0);
        if (keyCards >= 2 && maxPoints < 18) { maxPoints = 18; }
      }
    }

    // ★ 조커콜 사용 비용: 수비 조커 강제 유도 시 해당 트릭 점수 손실 또는 마이티 소모
    if (!hasJoker) {
      minPoints = (minPoints - 1).clamp(0, 20);
      maxPoints = (maxPoints - 1).clamp(0, 20);
    }

    if (minPoints > maxPoints) minPoints = maxPoints;

    return (minPoints, maxPoints);
  }

  // Public method for debugging
  Suit? findBestSuit(List<PlayingCard> hand) {
    Map<Suit, int> suitStrength = {};

    for (final suit in Suit.values) {
      int strength = 0;
      final suitCards = hand.where((c) => !c.isJoker && c.suit == suit).toList();

      // 기루다 강도 점수 기반 후보 필터링 (연결성 가중치 적용)
      if (_calcGirudaStrengthScore(suitCards) < 3.0) {
        suitStrength[suit] = 0;
        continue;
      }

      // 고위 카드 확인
      bool hasAce = suitCards.any((c) => c.rank == Rank.ace && !c.isMightyWith(suit));
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
    // 마이티 무늬에서는 A가 마이티로 빠지므로 K가 실질 최상위
    final bool mightyIsAce = state.mighty.rank == Rank.ace;
    final Suit? mightySuit = state.mighty.suit;

    for (final suit in Suit.values) {
      final suitCards = hand.where((c) => !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == suit).toList();
      if (suitCards.isEmpty) continue;
      // A가 있거나 실효가치 14+ 카드가 있으면 최상위 카드 보유
      // ★ 마이티 무늬: A가 마이티로 별도 취급되므로 K가 해당 무늬 최상위
      bool hasTopCard = suitCards.any((c) =>
          c.rank == Rank.ace ||
          _getEffectiveCardValue(c, state) >= 14 ||
          (suit == mightySuit && mightyIsAce && c.rank == Rank.king));
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

    // ★ 기루다 점수카드가 최상위가 되면 보존 (미래 트릭에서 선 잡기 가능)
    // 기루다는 비기루다와 달리 A/K가 없어도 최상위면 모든 비기루다를 이김
    if (state.giruda != null && suit == state.giruda) {
      final currentTrickCards = state.currentTrick?.cards ?? [];
      int unaccountedHigherGiruda = 0;
      for (int rankVal = card.rankValue + 1; rankVal <= 14; rankVal++) {
        final rank = Rank.values[rankVal - 2];
        bool inMyHand = player.hand.any((c) =>
            c.suit == state.giruda && c.rank == rank);
        bool alreadyPlayed = playedCards.any((c) =>
            c.suit == state.giruda && c.rank == rank);
        bool inCurrentTrick = currentTrickCards.any((c) =>
            !c.isJoker && c.suit == state.giruda && c.rank == rank);
        if (!inMyHand && !alreadyPlayed && !inCurrentTrick) {
          unaccountedHigherGiruda++;
        }
      }
      if (unaccountedHigherGiruda == 0) {
        return false; // 최상위 기루다 → 이후 트릭에서 선 잡기 가능
      }

      // ★ 주공의 남은 기루다를 추정하여 최상위 가능성 판단
      // unaccountedHigherGiruda가 1-2장일 때, 주공이 그 카드를 가지고 있다면
      // 주공이 소진한 후 이 카드가 최상위 기루다가 됨 → 보존
      if (unaccountedHigherGiruda <= 2 && state.declarerId != null) {
        // 주공이 플레이한 기루다 수 추적
        int declarerGirudaPlayed = 0;
        for (final trick in state.tricks) {
          final idx = trick.playerOrder.indexOf(state.declarerId!);
          if (idx >= 0 && idx < trick.cards.length) {
            final declCard = trick.cards[idx];
            if (!declCard.isJoker && declCard.suit == state.giruda) {
              declarerGirudaPlayed++;
            }
          }
        }
        // 현재 트릭에서 주공이 이미 낸 카드도 확인
        if (state.currentTrick != null) {
          final cIdx = state.currentTrick!.playerOrder.indexOf(state.declarerId!);
          if (cIdx >= 0 && cIdx < state.currentTrick!.cards.length) {
            final declCard = state.currentTrick!.cards[cIdx];
            if (!declCard.isJoker && declCard.suit == state.giruda) {
              declarerGirudaPlayed++;
            }
          }
        }

        // 공약 수준에서 주공의 초기 기루다 수 추정
        // 13점(최소) → ~4장, 15점 → ~5장, 17점 → ~6장
        final bidPoints = state.currentBid?.tricks ?? 13;
        final estimatedInitialGiruda = ((bidPoints - 13) ~/ 2 + 4).clamp(3, 8);
        final estimatedDeclarerRemaining =
            (estimatedInitialGiruda - declarerGirudaPlayed).clamp(0, 10);

        // 미확인 상위 기루다가 주공에게 있을 가능성이 높으면
        // → 주공이 소진한 후 이 카드가 최상위가 됨 → 보존
        if (estimatedDeclarerRemaining >= unaccountedHigherGiruda) {
          return false; // 주공 기루다 소진 후 최상위가 될 가능성 높음 → 보존
        }
      }
    }

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
    // 마이티 보유 확인 (마이티 있으면 조커 프렌드 선언 가능성 높음)
    bool hasMighty = hand.any((c) => c.isMightyWith(state.giruda));
    // 조커가 공격팀에 있을 가능성 (조커 보유 또는 마이티로 조커 프렌드 선언)
    bool jokerLikelyOnAttack = hasJoker || hasMighty;
    final jokerCallCard = state.jokerCall;

    // 각 무늬별 카드 수 계산 (기루다 제외)
    Map<Suit, int> suitCount = {};
    for (final suit in Suit.values) {
      if (suit == state.giruda) continue;
      suitCount[suit] = hand.where((c) => !c.isJoker && c.suit == suit).length;
    }

    // 초구 카드 결정: 비기루다 A 또는 마이티 무늬 K (초구 승리 → 보이드 계획)
    PlayingCard? firstTrickCard;
    {
      final List<PlayingCard> firstTrickCandidates = [];
      for (final c in hand) {
        if (c.isJoker) continue;
        if (c.isMightyWith(state.giruda)) continue;
        if (c.suit == state.giruda) continue;
        // 비기루다 A
        if (c.rank == Rank.ace) firstTrickCandidates.add(c);
        // 마이티 무늬 K (마이티가 A일 때)
        if (c.suit == state.mighty.suit && state.mighty.rank == Rank.ace && c.rank == Rank.king) {
          firstTrickCandidates.add(c);
        }
      }
      if (firstTrickCandidates.isNotEmpty) {
        // 해당 무늬 카드 수가 적은 것 우선 (초구 후 보이드에 가까움)
        firstTrickCandidates.sort((a, b) {
          int aCount = suitCount[a.suit] ?? 0;
          int bCount = suitCount[b.suit] ?? 0;
          if (aCount != bCount) return aCount.compareTo(bCount);
          return b.rankValue.compareTo(a.rankValue); // A(14) > K(13) 우선
        });
        firstTrickCard = firstTrickCandidates.first;
      }
    }

    // 초구 카드를 제외한 실효 데이터 (초구 후 보이드 계획)
    final effectiveHand = firstTrickCard != null
        ? hand.where((c) => !identical(c, firstTrickCard)).toList()
        : hand;
    Map<Suit, int> effectiveSuitCount = Map.from(suitCount);
    if (firstTrickCard != null && effectiveSuitCount.containsKey(firstTrickCard.suit)) {
      effectiveSuitCount[firstTrickCard.suit!] =
          (effectiveSuitCount[firstTrickCard.suit!] ?? 1) - 1;
    }

    // 최상위 카드가 있는 무늬 (버리기 우선순위 낮춤) - 초구 카드 제외 후 평가
    final topSuits = _getSuitsWithTopCards(effectiveHand, state);

    // 마이티 무늬 시너지: Mighty + Q 보유 시 해당 무늬 보호
    final mightySuit = state.mighty.suit;
    final hasMightyInHand = hand.any((c) => c.isMightyWith(state.giruda));
    final hasMightyQ = hand.any((c) => !c.isJoker && c.suit == mightySuit && c.rank == Rank.queen);
    final mightySuitSynergy = hasMightyInHand && hasMightyQ;

    hand.sort((a, b) {
      // 1. 조커/마이티는 절대 버리지 않음
      if (a.isJoker || a.isMightyWith(state.giruda)) return 1;
      if (b.isJoker || b.isMightyWith(state.giruda)) return -1;

      // 1.5. 초구 카드는 버리지 않음 (초구 승리 계획에 필수)
      if (firstTrickCard != null) {
        if (identical(a, firstTrickCard)) return 1;
        if (identical(b, firstTrickCard)) return -1;
      }

      // 2. 조커콜 카드 처리
      // ★ 조커가 공격팀에 있을 가능성이 높으면: 일반 카드로 처리
      //   - 조커 보유: 자기 조커를 콜하지 않음
      //   - 마이티 보유: 조커 프렌드 선언 가능성 높음 → 프렌드 조커를 콜하지 않음
      // ★ 조커가 수비팀에 있을 가능성이 높으면: 조커콜 카드 보존 (상대 조커 콜용)
      if (!jokerLikelyOnAttack) {
        bool aIsJokerCall = a.suit == jokerCallCard.suit && a.rank == jokerCallCard.rank;
        bool bIsJokerCall = b.suit == jokerCallCard.suit && b.rank == jokerCallCard.rank;
        if (aIsJokerCall && !bIsJokerCall) return 1;
        if (!aIsJokerCall && bIsJokerCall) return -1;
      }

      // 3. 기루다는 버리지 않음
      if (state.giruda != null) {
        if (a.suit == state.giruda && b.suit != state.giruda) return 1;
        if (a.suit != state.giruda && b.suit == state.giruda) return -1;
      }

      // 4. 최상위 카드가 있는 무늬는 버리기 우선순위 낮춤
      bool aHasTop = a.suit != null && topSuits.contains(a.suit);
      bool bHasTop = b.suit != null && topSuits.contains(b.suit);
      if (aHasTop && !bHasTop) return 1;
      if (!aHasTop && bHasTop) return -1;

      // 5. 보호된 점수 카드만 보존
      // - A: 항상 보존 (초구 승리 + 해당 무늬 최상위)
      // - K,Q,J,10: 해당 무늬에 A가 있을 때만 보존 (A 뒤에서 안전)
      // - A 없는 무늬의 K,Q,J,10: 빼앗길 확률 높음 → 적은 무늬 기준으로 버림
      // ★ 초구 카드(A)는 T1에서 소진되므로 보호자에서 제외
      //   예: ♥A가 초구 카드 → ♥10은 T1 이후 보호 불가 → 키티에 묻는 것이 유리
      bool aProtected = !a.isJoker && a.isPointCard &&
          (a.rank == Rank.ace || hand.any((c) => !c.isJoker && c.suit == a.suit && c.rank == Rank.ace && !identical(c, firstTrickCard)));
      bool bProtected = !b.isJoker && b.isPointCard &&
          (b.rank == Rank.ace || hand.any((c) => !c.isJoker && c.suit == b.suit && c.rank == Rank.ace && !identical(c, firstTrickCard)));
      if (aProtected && !bProtected) return 1;
      if (!aProtected && bProtected) return -1;

      // 6. 마이티 무늬 시너지: Mighty+Q 보유 시 해당 무늬 카드 보호 (K 추출용)
      if (mightySuitSynergy) {
        bool aIsMightySuit = a.suit == mightySuit;
        bool bIsMightySuit = b.suit == mightySuit;
        if (aIsMightySuit && !bIsMightySuit) return 1;
        if (!aIsMightySuit && bIsMightySuit) return -1;
      }

      // 7. 보이드 생성 우선: 초구 카드 제외 후 1~2장 남은 비기루다 무늬(A 없음)를 우선 버림
      // 보이드 2개+ → 기루다 컷 기회 극대화, 무늬 집중으로 유리
      bool aVoidCandidate = !a.isJoker && a.suit != null &&
          (effectiveSuitCount[a.suit] ?? 0) > 0 && (effectiveSuitCount[a.suit] ?? 0) <= 2 &&
          !effectiveHand.any((c) => !c.isJoker && c.suit == a.suit && c.rank == Rank.ace);
      bool bVoidCandidate = !b.isJoker && b.suit != null &&
          (effectiveSuitCount[b.suit] ?? 0) > 0 && (effectiveSuitCount[b.suit] ?? 0) <= 2 &&
          !effectiveHand.any((c) => !c.isJoker && c.suit == b.suit && c.rank == Rank.ace);
      if (aVoidCandidate && !bVoidCandidate) return -1;
      if (!aVoidCandidate && bVoidCandidate) return 1;

      // 8. 카드 수가 적은 무늬 우선 버림 (컷 가능성 높임)
      int aCount = effectiveSuitCount[a.suit] ?? 0;
      int bCount = effectiveSuitCount[b.suit] ?? 0;
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
    // 마이티 보유 확인 (마이티 있으면 조커 프렌드 선언 가능성 높음)
    bool hasMighty = hand.any((c) => c.isMightyWith(finalGiruda ?? state.giruda));
    // 조커가 공격팀에 있을 가능성 (조커 보유 또는 마이티로 조커 프렌드 선언)
    bool jokerLikelyOnAttack = hasJoker || hasMighty;
    final jokerCallCard = state.jokerCall;

    // 각 무늬별 카드 수 계산 (최종 기루다 제외)
    Map<Suit, int> suitCount = {};
    for (final suit in Suit.values) {
      if (suit == finalGiruda) continue;
      suitCount[suit] = hand.where((c) => !c.isJoker && c.suit == suit).length;
    }

    // 초구 카드 결정: 비기루다 A 또는 마이티 무늬 K (초구 승리 → 보이드 계획)
    PlayingCard? firstTrickCard;
    {
      final List<PlayingCard> firstTrickCandidates = [];
      for (final c in hand) {
        if (c.isJoker) continue;
        if (c.suit == state.mighty.suit && c.rank == state.mighty.rank) continue;
        if (c.suit == finalGiruda) continue;
        // 비기루다 A
        if (c.rank == Rank.ace) firstTrickCandidates.add(c);
        // 마이티 무늬 K (마이티가 A일 때)
        if (c.suit == state.mighty.suit && state.mighty.rank == Rank.ace && c.rank == Rank.king) {
          firstTrickCandidates.add(c);
        }
      }
      if (firstTrickCandidates.isNotEmpty) {
        // 해당 무늬 카드 수가 적은 것 우선 (초구 후 보이드에 가까움)
        firstTrickCandidates.sort((a, b) {
          int aCount = suitCount[a.suit] ?? 0;
          int bCount = suitCount[b.suit] ?? 0;
          if (aCount != bCount) return aCount.compareTo(bCount);
          return b.rankValue.compareTo(a.rankValue); // A(14) > K(13) 우선
        });
        firstTrickCard = firstTrickCandidates.first;
      }
    }

    // 초구 카드를 제외한 실효 데이터 (초구 후 보이드 계획)
    final effectiveHand = firstTrickCard != null
        ? hand.where((c) => !identical(c, firstTrickCard)).toList()
        : hand;
    Map<Suit, int> effectiveSuitCount = Map.from(suitCount);
    if (firstTrickCard != null && effectiveSuitCount.containsKey(firstTrickCard.suit)) {
      effectiveSuitCount[firstTrickCard.suit!] =
          (effectiveSuitCount[firstTrickCard.suit!] ?? 1) - 1;
    }

    // 최상위 카드가 있는 무늬 (버리기 우선순위 낮춤) - 초구 카드 제외 후 평가
    final topSuits = _getSuitsWithTopCards(effectiveHand, state);

    // 마이티 카드 확인 (기루다에 따라 다름)
    final mightyCard = state.mighty;
    bool isMightyCard(PlayingCard c) {
      return c.suit == mightyCard.suit && c.rank == mightyCard.rank;
    }

    // 마이티 무늬 시너지: Mighty + Q 보유 시 해당 무늬 보호
    final mightySuit = state.mighty.suit;
    final hasMightyInHand = hand.any((c) => isMightyCard(c));
    final hasMightyQ = hand.any((c) => !c.isJoker && c.suit == mightySuit && c.rank == Rank.queen);
    final mightySuitSynergy = hasMightyInHand && hasMightyQ;

    hand.sort((a, b) {
      // 1. 조커/마이티는 절대 버리지 않음
      if (a.isJoker || isMightyCard(a)) return 1;
      if (b.isJoker || isMightyCard(b)) return -1;

      // 1.5. 초구 카드는 버리지 않음 (초구 승리 계획에 필수)
      if (firstTrickCard != null) {
        if (identical(a, firstTrickCard)) return 1;
        if (identical(b, firstTrickCard)) return -1;
      }

      // 2. 조커콜 카드 처리
      // ★ 조커가 공격팀에 있을 가능성이 높으면: 일반 카드로 처리
      //   - 조커 보유: 자기 조커를 콜하지 않음
      //   - 마이티 보유: 조커 프렌드 선언 가능성 높음 → 프렌드 조커를 콜하지 않음
      // ★ 조커가 수비팀에 있을 가능성이 높으면: 조커콜 카드 보존 (상대 조커 콜용)
      if (!jokerLikelyOnAttack) {
        bool aIsJokerCall = a.suit == jokerCallCard.suit && a.rank == jokerCallCard.rank;
        bool bIsJokerCall = b.suit == jokerCallCard.suit && b.rank == jokerCallCard.rank;
        if (aIsJokerCall && !bIsJokerCall) return 1;
        if (!aIsJokerCall && bIsJokerCall) return -1;
      }

      // 3. 최종 기루다는 버리지 않음
      if (finalGiruda != null) {
        if (a.suit == finalGiruda && b.suit != finalGiruda) return 1;
        if (a.suit != finalGiruda && b.suit == finalGiruda) return -1;
      }

      // 4. 최상위 카드가 있는 무늬는 버리기 우선순위 낮춤
      bool aHasTop = a.suit != null && topSuits.contains(a.suit);
      bool bHasTop = b.suit != null && topSuits.contains(b.suit);
      if (aHasTop && !bHasTop) return 1;
      if (!aHasTop && bHasTop) return -1;

      // 5. 보호된 점수 카드만 보존
      // - A: 항상 보존 (초구 승리 + 해당 무늬 최상위)
      // - K,Q,J,10: 해당 무늬에 A가 있을 때만 보존 (A 뒤에서 안전)
      // - A 없는 무늬의 K,Q,J,10: 빼앗길 확률 높음 → 적은 무늬 기준으로 버림
      // ★ 초구 카드(A)는 T1에서 소진되므로 보호자에서 제외
      //   예: ♥A가 초구 카드 → ♥10은 T1 이후 보호 불가 → 키티에 묻는 것이 유리
      bool aProtected = !a.isJoker && a.isPointCard &&
          (a.rank == Rank.ace || hand.any((c) => !c.isJoker && c.suit == a.suit && c.rank == Rank.ace && !identical(c, firstTrickCard)));
      bool bProtected = !b.isJoker && b.isPointCard &&
          (b.rank == Rank.ace || hand.any((c) => !c.isJoker && c.suit == b.suit && c.rank == Rank.ace && !identical(c, firstTrickCard)));
      if (aProtected && !bProtected) return 1;
      if (!aProtected && bProtected) return -1;

      // 6. 마이티 무늬 시너지: Mighty+Q 보유 시 해당 무늬 카드 보호 (K 추출용)
      if (mightySuitSynergy) {
        bool aIsMightySuit = a.suit == mightySuit;
        bool bIsMightySuit = b.suit == mightySuit;
        if (aIsMightySuit && !bIsMightySuit) return 1;
        if (!aIsMightySuit && bIsMightySuit) return -1;
      }

      // 7. 보이드 생성 우선: 초구 카드 제외 후 1~2장 남은 비기루다 무늬(A 없음)를 우선 버림
      // 보이드 2개+ → 기루다 컷 기회 극대화, 무늬 집중으로 유리
      bool aVoidCandidate = !a.isJoker && a.suit != null &&
          (effectiveSuitCount[a.suit] ?? 0) > 0 && (effectiveSuitCount[a.suit] ?? 0) <= 2 &&
          !effectiveHand.any((c) => !c.isJoker && c.suit == a.suit && c.rank == Rank.ace);
      bool bVoidCandidate = !b.isJoker && b.suit != null &&
          (effectiveSuitCount[b.suit] ?? 0) > 0 && (effectiveSuitCount[b.suit] ?? 0) <= 2 &&
          !effectiveHand.any((c) => !c.isJoker && c.suit == b.suit && c.rank == Rank.ace);
      if (aVoidCandidate && !bVoidCandidate) return -1;
      if (!aVoidCandidate && bVoidCandidate) return 1;

      // 8. 카드 수가 적은 무늬 우선 버림 (컷 가능성 높임)
      int aCount = effectiveSuitCount[a.suit] ?? 0;
      int bCount = effectiveSuitCount[b.suit] ?? 0;
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
          !c.isJoker && !c.isMightyWith(state.giruda) &&
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

    // ★ 조커콜 사용 비용: 수비 조커 강제 유도 시 점수 손실 또는 마이티 소모
    if (!hasJoker) {
      estimatedPoints -= 1;
    }

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

  /// AI가 풀(20) 선언 여부를 결정
  /// 주공 팀(주공 + 프렌드)이 모든 트릭을 이길 확률이 높을 때 풀 선언
  /// [declaration] 프렌드 선언 정보 (노프렌드, 마이티 프렌드, 조커 프렌드 등)
  bool shouldDeclareFull(Player player, GameState state, FriendDeclaration declaration) {
    final hand = player.hand;

    bool hasMighty = _handContainsMighty(hand, state.mighty);
    bool hasJoker = _handContainsJoker(hand);

    // 기루다 A 보유 확인
    bool hasGirudaAce = false;
    if (state.giruda != null) {
      if (!(state.mighty.suit == state.giruda && state.mighty.rank == Rank.ace)) {
        hasGirudaAce = _handContainsCard(hand, state.giruda, Rank.ace);
      }
    }

    // 기루다 K 보유 확인
    bool hasGirudaKing = false;
    if (state.giruda != null) {
      hasGirudaKing = _handContainsCard(hand, state.giruda, Rank.king);
    }

    // 비기루다 A 개수
    int nonGirudaAceCount = 0;
    for (final suit in Suit.values) {
      if (suit == state.giruda) continue;
      if (!(state.mighty.suit == suit && state.mighty.rank == Rank.ace)) {
        if (_handContainsCard(hand, suit, Rank.ace)) {
          nonGirudaAceCount++;
        }
      }
    }

    // 기루다 장수 확인
    int girudaCount = 0;
    if (state.giruda != null) {
      girudaCount = hand.where((c) => !c.isJoker && c.suit == state.giruda).length;
    }

    // 기루다 Q, J, 10 보유 확인
    bool hasGirudaQueen = state.giruda != null && _handContainsCard(hand, state.giruda, Rank.queen);
    bool hasGirudaJack = state.giruda != null && _handContainsCard(hand, state.giruda, Rank.jack);
    bool hasGirudaTen = state.giruda != null && _handContainsCard(hand, state.giruda, Rank.ten);

    // ★ 연속체인 계산: gA + gK + 연속 기루다(Q→J→10→...)
    int chainGirudaCount = 0;
    if (hasGirudaAce) chainGirudaCount++;
    if (hasGirudaKing) chainGirudaCount++;
    if (hasGirudaQueen) {
      chainGirudaCount++;
      if (hasGirudaJack) {
        chainGirudaCount++;
        if (hasGirudaTen) {
          chainGirudaCount++;
          final lowerRanks = [Rank.nine, Rank.eight, Rank.seven, Rank.six,
              Rank.five, Rank.four, Rank.three, Rank.two];
          for (final rank in lowerRanks) {
            if (_handContainsCard(hand, state.giruda, rank)) {
              chainGirudaCount++;
            } else {
              break;
            }
          }
        }
      }
    }

    // === 케이스별 풀 선언 검토 ===
    // 공식: 연속체인카드 + 비체인기루다 + 비기루다A >= threshold
    // = 비기루다특수카드 + girudaCount + nonGirudaAce >= threshold

    if (declaration.isNoFriend) {
      // === 노프렌드: 내가 모든 트릭 승리 ===
      // 마이티 + 조커 필수 (조커가 없으면 상대 조커로 1트릭 빼앗김)
      // ※ 조커콜 카드가 있어도 조커콜 트릭에서 상대가 점수카드를 내면 그 트릭을 잃음
      if (!hasMighty || !hasJoker) return false;
      // 기루다 A + K 필수
      if (!hasGirudaAce || !hasGirudaKing) return false;

      // 예상 점수 기반 풀 선언: 선 유지 카드 * 2.0 + 비체인 기루다 * 1.5 + 키티 점수
      final leadKeepingCards = (2 + chainGirudaCount + nonGirudaAceCount).clamp(0, 10);
      final nonChainGiruda = girudaCount - chainGirudaCount;
      final additionalWins = (nonChainGiruda).clamp(0, 10 - leadKeepingCards);
      final kittyPoints = state.kitty.where((c) => c.isPointCard).length;
      final expectedPoints = leadKeepingCards * 2.0 + additionalWins * 1.5 + kittyPoints;
      if (expectedPoints >= 20) return true;

    } else if (declaration.card != null) {
      final friendCard = declaration.card!;

      // 내 손 + 프렌드 카드로 통합 평가
      final evalHand = [...hand, friendCard];

      // 필수 카드 체크 (통합 핸드)
      bool eHasMighty = _handContainsMighty(evalHand, state.mighty);
      bool eHasJoker = _handContainsJoker(evalHand);
      if (!eHasMighty || !eHasJoker) return false;

      bool eHasGirudaAce = false;
      if (state.giruda != null) {
        if (!(state.mighty.suit == state.giruda && state.mighty.rank == Rank.ace)) {
          eHasGirudaAce = _handContainsCard(evalHand, state.giruda, Rank.ace);
        }
      }
      bool eHasGirudaKing = false;
      if (state.giruda != null) {
        eHasGirudaKing = _handContainsCard(evalHand, state.giruda, Rank.king);
      }
      if (!eHasGirudaAce || !eHasGirudaKing) return false;

      // 마이티 프렌드: 마이티 무늬 카드 체크 (실제 핸드)
      if (friendCard.isMightyWith(state.giruda)) {
        final mightySuit = state.mighty.suit;
        bool hasMightySuitCard = hand.any((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == mightySuit);
        if (hasMightySuitCard) return false;
      }

      // 통합 핸드 기준 기루다/비기루다 A 계산
      int eGirudaCount = 0;
      if (state.giruda != null) {
        eGirudaCount = evalHand.where((c) => !c.isJoker && c.suit == state.giruda).length;
      }

      int eNonGirudaAceCount = 0;
      for (final suit in Suit.values) {
        if (suit == state.giruda) continue;
        if (!(state.mighty.suit == suit && state.mighty.rank == Rank.ace)) {
          if (_handContainsCard(evalHand, suit, Rank.ace)) {
            eNonGirudaAceCount++;
          }
        }
      }

      // 연속체인 계산 (통합 핸드)
      bool eHasGirudaQueen = state.giruda != null && _handContainsCard(evalHand, state.giruda, Rank.queen);
      bool eHasGirudaJack = state.giruda != null && _handContainsCard(evalHand, state.giruda, Rank.jack);
      bool eHasGirudaTen = state.giruda != null && _handContainsCard(evalHand, state.giruda, Rank.ten);

      int eChainGirudaCount = 0;
      if (eHasGirudaAce) eChainGirudaCount++;
      if (eHasGirudaKing) eChainGirudaCount++;
      if (eHasGirudaQueen) {
        eChainGirudaCount++;
        if (eHasGirudaJack) {
          eChainGirudaCount++;
          if (eHasGirudaTen) {
            eChainGirudaCount++;
            final lowerRanks = [Rank.nine, Rank.eight, Rank.seven, Rank.six,
                Rank.five, Rank.four, Rank.three, Rank.two];
            for (final rank in lowerRanks) {
              if (_handContainsCard(evalHand, state.giruda, rank)) {
                eChainGirudaCount++;
              } else {
                break;
              }
            }
          }
        }
      }

      // 예상 점수 기반 풀 선언: 선 유지 카드 * 2.0 + 비체인 기루다 * 1.5 + 키티 점수
      final eLeadKeeping = (2 + eChainGirudaCount + eNonGirudaAceCount).clamp(0, 10);
      final eNonChainGiruda = eGirudaCount - eChainGirudaCount;
      final eAdditionalWins = (eNonChainGiruda).clamp(0, 10 - eLeadKeeping);
      final kittyPoints = state.kitty.where((c) => c.isPointCard).length;
      final expectedPoints = eLeadKeeping * 2.0 + eAdditionalWins * 1.5 + kittyPoints;
      if (expectedPoints >= 20) return true;
    }

    return false;
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

    // 비기루다 K 개수 확인
    int nonGirudaKingCount = hand.where((c) =>
        !c.isJoker && c.rank == Rank.king && c.suit != state.giruda).length;

    // 조건 1: 마이티 + 조커 + 기루다 A + 기루다 K + 기루다 외 A 2개 이상 + 기루다 외 K 1개 이상 → 노 프렌드
    if (hasMighty && hasJoker && hasGirudaAce && hasGirudaKing && nonGirudaAceCount >= 2 && nonGirudaKingCount >= 1) {
      return FriendDeclaration.noFriend();
    }

    // K 카드 개수 확인
    int kingCount = hand.where((c) => !c.isJoker && c.rank == Rank.king).length;

    // 조건 2: 마이티 + 모든 A + 조커 콜 카드 + K 2장 이상 → 노 프렌드
    // ★ 조커가 없어도 조커콜 카드가 있으면 2트릭에서 조커콜로 상대 조커 소진 가능
    int totalAces = (hasGirudaAce ? 1 : 0) + nonGirudaAceCount;
    // 마이티가 A인 경우 제외하고 3장의 A가 있으면 모든 A 보유
    int maxNonMightyAces = (state.mighty.rank == Rank.ace) ? 3 : 4;
    if (hasMighty && totalAces == maxNonMightyAces && hasJokerCallCard && kingCount >= 2) {
      return FriendDeclaration.noFriend();
    }

    // 조건 2-1: 기루다 압도적 우위 (8장 이상) + 마이티 + 기루다 A + 기루다 K → 노 프렌드
    // 상대에게 기루다가 거의 없어서 컷 불가능, 조커 1번 빼앗겨도 마이티로 탈환 가능
    if (state.giruda != null) {
      int girudaCount = hand.where((c) =>
          !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).length;
      if (girudaCount >= 8 && hasMighty && hasGirudaAce && hasGirudaKing) {
        return FriendDeclaration.noFriend();
      }
      // 기루다 7장 + 마이티 + 조커 + 기루다 A + 기루다 K → 노 프렌드
      if (girudaCount >= 7 && hasMighty && hasJoker && hasGirudaAce && hasGirudaKing) {
        return FriendDeclaration.noFriend();
      }
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
        bool isJokerFriend = friendCard != null && friendCard.isJoker;
        if (isJokerFriend) {
          return null;
        }
        // ★ 2~3트릭에서 조커콜 우선 사용 조건:
        // - 마이티 프렌드인 경우 (조커가 없으므로 수비팀 조커 무력화)
        // - 노프렌드인 경우
        bool isNoFriend = state.friendDeclaration?.isNoFriend == true;
        bool isMightyFriend = friendCard != null && friendCard.isMightyWith(state.giruda);
        if ((isMightyFriend || isNoFriend) &&
            (state.currentTrickNumber == 2 || state.currentTrickNumber == 3)) {
          return jokerCallCard.suit;
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
        bool isJokerFriend = friendCard != null && friendCard.isJoker;
        if (isJokerFriend) {
          return false;
        }
        // ★ 2트릭에서 조커콜 우선 사용 조건:
        // - 노프렌드인 경우, 또는
        // - 조커가 없고 조커 프렌드가 아닌 경우
        bool isNoFriend = state.friendDeclaration?.isNoFriend == true;
        bool shouldCallJokerEarly = isNoFriend || !isJokerFriend; // 조커 프렌드 아님 (이미 위에서 체크됨)
        if (shouldCallJokerEarly && state.currentTrickNumber == 2) {
          return true;
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
      // === 수비팀 조커 선공 ===
      // 수비팀이 조커를 가지고 있으면 마이티 프렌드일 가능성 높음

      // 1. 기루다가 공격팀에만 있으면 기루다 호출 (간 확률 감소)
      if (state.giruda != null) {
        final remainingGiruda = _getRemainingGirudaCount(state, player);
        if (remainingGiruda >= 1) {
          // 수비팀 동료가 기루다를 가지고 있는지 추정
          bool teammatesHaveGiruda = _estimateDefenseTeammatesHaveGiruda(player, state);
          if (!teammatesHaveGiruda) {
            // 기루다가 공격팀에만 있으면 → 기루다 호출 (공격팀 간 능력 감소)
            return state.giruda!;
          }
        }
      }

      // 2. 마이티가 아직 안 나왔으면 마이티 무늬 호출
      final mightySuit = state.giruda == Suit.spade ? Suit.diamond : Suit.spade;
      bool mightyPlayed = playedCards.any((c) => c.isMightyWith(state.giruda)) ||
          (state.currentTrick?.cards.any((c) => c.isMightyWith(state.giruda)) ?? false);

      if (!mightyPlayed) {
        return mightySuit;
      }

      // 3. 마이티가 나왔으면 공격팀이 없을 것 같은 무늬 (물패 방지)
      return _selectSuitAttackTeamLacks(player, state, playedCards);
    } else {
      // === 공격팀 조커 선공 ===

      // 조커가 프렌드 카드인지 확인
      bool jokerIsFriendCard = state.friendDeclaration?.card?.isJoker ?? false;

      // === 9번째 트릭 특별 처리 ===
      // 9번째 트릭에서 조커로 선공할 때:
      // 1. 수비팀에 기루다가 남아있으면 기루다 호출
      // 2. 기루다가 모두 소진되었으면 내가 가진 나머지 한 장의 무늬 호출
      if (state.currentTrickNumber == 9) {
        if (state.giruda != null) {
          final opponentGiruda = _getRemainingGirudaCount(state, player);
          if (opponentGiruda >= 1) {
            return state.giruda!;
          }
        }
        // 기루다가 없거나 소진되었으면 내 나머지 한 장의 무늬
        final remainingCards = player.hand.where((c) => !c.isJoker).toList();
        if (remainingCards.isNotEmpty) {
          final lastCard = remainingCards.first;
          if (lastCard.suit != null) {
            return lastCard.suit!;
          }
        }
        // fallback: 기루다 또는 스페이드
        return state.giruda ?? Suit.spade;
      }

      if (state.giruda != null) {
        // ★ 주공 조커 선공 전략 (2025.01 개선)
        // 1. 기루다 최상위 카드를 가지고 있으면 → 그 카드로 직접 공격, 조커는 선 탈환용
        // 2. 기루다 최상위가 없고, 상대에게 있으면 (오픈 안 됨 + 프렌드 아님) → 조커로 기루다 호출
        // 3. 그 외 → 조커는 선 탈환용

        final myGirudaCards = player.hand.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
        myGirudaCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));

        final playedGirudaCards = playedCards.where((c) =>
            !c.isJoker && c.suit == state.giruda).toList();

        // 프렌드 카드 확인
        final friendCard = state.friendDeclaration?.card;

        // 현재 남아있는 기루다 중 최상위 카드가 내 손에 있는지 확인
        // A부터 순서대로 확인: 오픈 안 됨 + 프렌드 아님 → 아직 게임에 있음
        bool hasTopGiruda = false;
        for (final rank in [Rank.ace, Rank.king, Rank.queen, Rank.jack, Rank.ten]) {
          bool played = playedGirudaCards.any((c) => c.rank == rank);
          bool isFriendCard = friendCard != null &&
              friendCard.suit == state.giruda &&
              friendCard.rank == rank;

          if (!played && !isFriendCard) {
            // 이 랭크가 현재 최상위 기루다
            bool inMyHand = myGirudaCards.any((c) => c.rank == rank);
            hasTopGiruda = inMyHand;
            break;
          }
        }

        // 조건 1: 기루다 최상위 카드를 가지고 있으면 직접 공격 가능
        // → 조커는 선 탈환용으로 아껴둠
        if (hasTopGiruda) {
          return _selectSuitWithSecondHighestCard(player, state, playedCards);
        }

        // 조건 2: 기루다 최상위가 없고, 상대에게 있으면 조커로 기루다 호출
        // (위 로직에서 hasTopGiruda가 false면 상대가 최상위를 가지고 있음)
        // ★ 단, 프렌드인 경우 수비팀에 기루다가 있는지 확인 (주공 기루다만 뽑는 상황 방지)
        bool isFriend = !player.isDeclarer;
        if (myGirudaCards.isNotEmpty || playedGirudaCards.length < 13) {
          // 프렌드인 경우: 수비팀에 기루다가 없으면 기루다 호출 금지 (주공 기루다 보호)
          if (isFriend && !_estimateDefenseTeamHasGiruda(player, state)) {
            return _selectSuitWithSecondHighestCard(player, state, playedCards);
          }
          // 기루다가 아직 게임에 남아있으면 조커로 기루다 호출
          return state.giruda!;
        }

        // 조건 3: 조커가 프렌드 카드이고 초반이면 기루다 호출
        if (jokerIsFriendCard && _isEarlyGirudaPhase(state, player)) {
          return state.giruda!;
        }

        // 조건 4: 마이티가 프렌드 카드이고 기루다 A가 없으면 초반에 기루다 호출
        bool mightyIsFriendCard = state.friendDeclaration?.card?.isMightyWith(state.giruda) ?? false;
        bool hasGirudaAce = player.hand.any((c) =>
            !c.isJoker && c.suit == state.giruda && c.rank == Rank.ace);

        if (mightyIsFriendCard && !hasGirudaAce && _isEarlyGirudaPhase(state, player)) {
          return state.giruda!;
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
          !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == suit).toList();

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

    // ★ 마이티 우선순위는 하단 shouldAvoidMighty (line ~2841)에서 관리
    // 여기서 제거하면 명확히 지는 상황에서도 마이티를 못 쓰는 문제 발생
    // 각 전략 분기에서 !c.isMightyWith() 필터로 마이티를 개별 제외함

    // === 트릭 9 선공: 조커 대응 전략 ===
    // 조커가 아직 안 나왔으면 이번 트릭에서 반드시 나옴 (트릭 10에는 조커 사용 불가)
    if (state.currentTrickNumber == 9) {
      final playedCardsForJoker = _getPlayedCards(state);
      bool jokerPlayed = playedCardsForJoker.any((c) => c.isJoker);

      if (!jokerPlayed) {
        bool hasMighty = playableCards.any((c) => c.isMightyWith(state.giruda));
        bool isAttackTeam = !_isPlayerOnDefenseTeam(player, state);

        // 조커가 같은 편인지 판단
        // 조커 프렌드 + 공격팀 → 같은 편 (프렌드가 조커 보유)
        // 그 외 → 적에게 있다고 가정 (수비 3명이 보유할 확률 높음)
        final friendCard = state.friendDeclaration?.card;
        bool friendIsJoker = friendCard != null && friendCard.isJoker;
        bool jokerOnMyTeam = friendIsJoker && isAttackTeam;

        if (!jokerOnMyTeam && hasMighty) {
          // 적 조커가 나올 것이므로 마이티로 잡기
          return playableCards.firstWhere((c) => c.isMightyWith(state.giruda));
        }

        if (jokerOnMyTeam) {
          // 같은 편 조커가 트릭 9를 가져갈 것이므로
          // 마이티, 기루다 최상위 등을 아껴서 트릭 10에서 사용
          final saveableCards = playableCards.where((c) {
            if (c.isMightyWith(state.giruda)) return false; // 마이티 아끼기
            if (c.isJoker) return false;
            // 기루다 최상위(실효 가치 14+)도 트릭 10용으로 아끼기
            if (state.giruda != null && c.suit == state.giruda &&
                _getEffectiveCardValue(c, state) >= 14) return false;
            return true;
          }).toList();

          if (saveableCards.isNotEmpty) {
            // 가장 낮은 비점수 카드 선공 (팀 조커가 이김)
            final nonPointCards = saveableCards.where((c) => !c.isPointCard).toList();
            if (nonPointCards.isNotEmpty) {
              nonPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return nonPointCards.first;
            }
            saveableCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return saveableCards.first;
          }
          // 아끼기 가능한 카드가 없으면 기존 로직으로 진행
        }
      }
    }

    // 방어팀인지 확인
    bool isDefenseTeam = _isPlayerOnDefenseTeam(player, state);

    if (isDefenseTeam && state.giruda != null) {
      // === 수비팀 후반전 조커 선공 전략 ===
      // 후반전(트릭 7 이후)에 조커로 선공하여 공격팀 공격력 감소
      if (state.currentTrickNumber >= 7 && state.currentTrickNumber < 10) {
        final joker = playableCards.where((c) => c.isJoker).toList();
        if (joker.isNotEmpty) {
          final remainingGiruda = _getRemainingGirudaCount(state, player);
          final playedCards = _getPlayedCards(state);
          bool mightyPlayed = playedCards.any((c) => c.isMightyWith(state.giruda)) ||
              (state.currentTrick?.cards.any((c) => c.isMightyWith(state.giruda)) ?? false);

          // 조건: 공격팀 기루다가 남아있거나 마이티가 안 나왔으면 조커 선공
          if (remainingGiruda >= 1 || !mightyPlayed) {
            return joker.first;
          }
        }
      }

      // === 방어팀 선공 전략 ===
      // 기루다를 아끼고, 다른 무늬의 높은 카드를 낸다
      // (주공이 높은 기루다를 많이 가지고 있을 가능성이 높으므로)
      // 오픈된 카드를 고려하여 현재 가장 높은 카드를 선택
      // ★ 주공 무늬 보유 추론: 주공이 보유한 무늬로 선공해야 기루다 컷 방지
      final declarerHoldings = _inferDeclarerSuitHoldings(state);

      // 기루다가 아닌 카드들
      final nonGirudaCards = playableCards.where((c) =>
          !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();

      // ★ 주공 확정 void 무늬 제외: 기루다 컷 확실 → 동료 점수카드 노출 위험
      // 대안이 있으면 void 무늬를 완전 배제, 없으면 원래 카드풀 사용
      final declarerVoidSuits = _getDeclarerVoidSuits(state);
      final safeNonGirudaCards = declarerVoidSuits.isNotEmpty
          ? nonGirudaCards.where((c) =>
              c.suit != null && !declarerVoidSuits.contains(c.suit)).toList()
          : nonGirudaCards;
      final defLeadCards = safeNonGirudaCards.isNotEmpty ? safeNonGirudaCards : nonGirudaCards;

      if (defLeadCards.isNotEmpty) {
        // 현재 가장 높은 카드인 것들을 찾기 (오픈된 카드 고려)
        final highestRemainingCards = defLeadCards.where((c) =>
            _isHighestRemainingCard(c, state, player.hand)).toList();

        if (highestRemainingCards.isNotEmpty) {
          // ★ 주공이 보유할 가능성 높은 무늬 우선 (기루다 컷 방지)
          // 주공이 void일 가능성 높은 무늬의 최상위 카드는 컷당해 낭비될 수 있음
          final safeHighCards = highestRemainingCards.where((c) =>
              c.suit != null && (declarerHoldings[c.suit!] ?? 0.5) >= 0.4).toList();
          if (safeHighCards.isNotEmpty) {
            safeHighCards.sort((a, b) =>
                _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
            return safeHighCards.first;
          }
          // 안전한 무늬가 없으면 최상위 카드 낭비 방지 → 아래 저가 카드 전략으로
        }

        // 높은 실효 가치 순으로 정렬 (오픈된 카드 고려)
        defLeadCards.sort((a, b) =>
            _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));

        // 실효 가치가 A(14) 이상인 카드가 있으면 선택 (= 현재 가장 높은 카드)
        // ★ 주공이 보유할 가능성 높은 무늬만 사용 (컷 방지)
        final effectiveHighCards = defLeadCards.where((c) =>
            _getEffectiveCardValue(c, state) >= 14 &&
            (declarerHoldings[c.suit] ?? 0.5) >= 0.4).toList();
        if (effectiveHighCards.isNotEmpty) {
          return effectiveHighCards.first;
        }

        // 이길 확률이 낮으면 높은 카드로 리드하지 않음
        // 대신 낮은 카드를 버리거나, 이길 확률이 낮은 점수카드를 버림

        // ★ 마이티 미출 여부 확인: 미출 시 리드 무늬의 점수카드 노출 최소화
        final bool mightyStillInPlay = !_getPlayedCards(state).any((c) => c.isMightyWith(state.giruda));

        // 1. 비점수카드 중 낮은 카드로 리드 (안전한 선택)
        // ★ 마이티 미출 시: 잔여 점수카드가 적은 무늬 우선 (마이티 캡처 피해 최소화)
        // ★ 주공 보유 확률 높은 무늬 우선 (기루다 컷 방지)
        final nonPointCards = defLeadCards.where((c) => !c.isPointCard).toList();
        if (nonPointCards.isNotEmpty) {
          nonPointCards.sort((a, b) {
            // 마이티 미출 시 해당 무늬의 잔여 점수카드 수로 1차 정렬
            if (mightyStillInPlay) {
              int exposureA = _countRemainingPointCardsInSuit(a.suit!, state, player.hand);
              int exposureB = _countRemainingPointCardsInSuit(b.suit!, state, player.hand);
              if (exposureA != exposureB) return exposureA.compareTo(exposureB);
            }
            double probA = declarerHoldings[a.suit] ?? 0.5;
            double probB = declarerHoldings[b.suit] ?? 0.5;
            int binA = (probA / 0.2).floor();
            int binB = (probB / 0.2).floor();
            if (binA != binB) return binB.compareTo(binA);
            return a.rankValue.compareTo(b.rankValue);
          });
          return nonPointCards.first;
        }

        // 2. 이길 확률이 낮은 점수카드 리드 (A/K가 오픈된 J/Q/10)
        // ★ 마이티 미출 시: 잔여 점수카드가 적은 무늬 우선
        final lowProbPointCards = defLeadCards.where((c) =>
            c.isPointCard && _isLowWinProbabilityPointCard(c, player, state)).toList();
        if (lowProbPointCards.isNotEmpty) {
          lowProbPointCards.sort((a, b) {
            if (mightyStillInPlay) {
              int exposureA = _countRemainingPointCardsInSuit(a.suit!, state, player.hand);
              int exposureB = _countRemainingPointCardsInSuit(b.suit!, state, player.hand);
              if (exposureA != exposureB) return exposureA.compareTo(exposureB);
            }
            return a.rankValue.compareTo(b.rankValue);
          });
          return lowProbPointCards.first;
        }

        // 3. 이길 가능성 있는 점수카드는 보존하고 싶지만 다른 카드가 없으면 낮은 것
        // ★ 마이티 미출 시: 잔여 점수카드가 적은 무늬 우선
        defLeadCards.sort((a, b) {
          if (mightyStillInPlay) {
            int exposureA = _countRemainingPointCardsInSuit(a.suit!, state, player.hand);
            int exposureB = _countRemainingPointCardsInSuit(b.suit!, state, player.hand);
            if (exposureA != exposureB) return exposureA.compareTo(exposureB);
          }
          return a.rankValue.compareTo(b.rankValue);
        });
        return defLeadCards.first;
      }

      // 기루다만 남은 경우, 가장 낮은 기루다를 낸다
      final girudaCards = playableCards.where((c) =>
          !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
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

      // 조커 프렌드인 경우, 주공이 마이티를 가지고 있을 확률이 높음
      // 마이티 무늬로 선공하면 주공이 마이티를 낭비해야 할 수 있으므로 피함
      final bool isJokerFriend = state.friendDeclaration?.card?.isJoker ?? false;
      final Suit mightySuit = state.giruda == Suit.spade ? Suit.diamond : Suit.spade;

      // === 프렌드 초반 기루다 선공 전략 ===
      // 트릭 2~6: 수비팀 기루다 보유 여부에 따라 전략 분기
      if (state.currentTrickNumber >= 2 && state.currentTrickNumber <= 6 &&
          remainingGiruda > 0) {
        final defenseHasGiruda = _estimateDefenseTeamHasGiruda(player, state);
        final myGirudaCards = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
        if (myGirudaCards.isNotEmpty) {
          myGirudaCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
        }

        if (defenseHasGiruda) {
          // === 수비팀 기루다 보유: 기루다 소진 유도 ===
          if (myGirudaCards.isNotEmpty) {
            final highGiruda = myGirudaCards.where((c) =>
                _getEffectiveCardValue(c, state) >= 13).toList();
            if (highGiruda.isNotEmpty) {
              // 최상위 기루다(K+)로 수비 기루다 소진
              return highGiruda.first;
            }
          }
          // 높은 기루다 없으면 조커 기루다콜
          final joker = playableCards.where((c) => c.isJoker).toList();
          if (joker.isNotEmpty && remainingGiruda >= 3) {
            return joker.first;
          }
          // 낮은 기루다 (주공에게 선 넘기기)
          if (myGirudaCards.isNotEmpty) {
            return myGirudaCards.last;
          }
        } else {
          // === 수비팀 기루다 없음: 기루다 리드 회피 ===
          // 기루다를 내면 주공의 기루다만 소진되므로 비기루다 전략으로 전환

          // 1. 비기루다 최상위 카드 (실효가치 13+ = K 이상)
          final nonGirudaTop = playableCards.where((c) {
            if (c.isJoker || c.isMightyWith(state.giruda)) return false;
            if (c.suit == state.giruda) return false;
            if (isJokerFriend && c.suit == mightySuit) return false;
            if (c.suit != null && cutSuits.contains(c.suit)) return false;
            return _getEffectiveCardValue(c, state) >= 13;
          }).toList();
          if (nonGirudaTop.isNotEmpty) {
            nonGirudaTop.sort((a, b) =>
                _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
            return nonGirudaTop.first;
          }

          // 2. 주공 물패 무늬 리드 (주공이 기루다 컷으로 승리 → 선 이동)
          final declarerVoidSuits = _getDeclarerVoidSuits(state);
          if (declarerVoidSuits.isNotEmpty) {
            for (Suit voidSuit in declarerVoidSuits) {
              if (voidSuit == state.giruda) continue;
              if (isJokerFriend && voidSuit == mightySuit) continue;
              final voidSuitCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == voidSuit).toList();
              if (voidSuitCards.isNotEmpty) {
                voidSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return voidSuitCards.first;
              }
            }
          }
          // 비기루다 최상위도 주공 물패도 없으면 → 후속 블록으로 fall through
        }
      }

      // 실효가치 14+ 최상위 카드가 있으면 우선 사용 (마이티/조커보다 먼저)
      // 마이티/조커는 점수 카드가 많을 때 사용하는 것이 유리
      // 조커 프렌드일 때는 마이티 무늬 제외
      final topCards = playableCards.where((c) {
        if (c.isJoker || c.isMightyWith(state.giruda)) return false;
        // 컷된 무늬는 제외 (상대 기루다 없으면 허용)
        if (remainingGiruda > 0 && c.suit != null && cutSuits.contains(c.suit)) {
          return false;
        }
        // 조커 프렌드일 때 마이티 무늬 제외
        if (isJokerFriend && c.suit == mightySuit) {
          return false;
        }
        return _getEffectiveCardValue(c, state) >= 14;
      }).toList();

      if (topCards.isNotEmpty) {
        // ★ 초반(트릭 6 이하)에는 기루다 최상위 우선 (상대 기루다 소진 → 후반 간 방지)
        // 기루다로 선 유지하면 상대 기루다를 빼앗고, 후반에 비기루다 카드가 컷 안 당함
        if (state.currentTrickNumber <= 6 && remainingGiruda > 0) {
          final girudaTopCards = topCards.where((c) => c.suit == state.giruda).toList();
          if (girudaTopCards.isNotEmpty) {
            girudaTopCards.sort((a, b) =>
                _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
            return girudaTopCards.first;
          }
        }

        // ★ 초반(트릭 2-5) 비기루다 A/K 적극 리드
        // 마이티/조커가 살아있어 상대가 점수카드를 아끼는 경향 → 기루다 컷 확률 낮음
        // → 프렌드의 비기루다 최상위(A/K) 리드로 주공 물패 소진(void 생성) 지원
        if (state.currentTrickNumber <= 5 && remainingGiruda > 0) {
          final nonGirudaTopCards = topCards.where((c) => c.suit != state.giruda).toList();
          if (nonGirudaTopCards.isNotEmpty) {
            // 마이티/조커가 아직 소진되지 않았는지 확인
            final jokerPlayed = _getPlayedCards(state).any((c) => c.isJoker);
            final mightyPlayed = _getPlayedCards(state).any((c) => c.isMightyWith(state.giruda));
            if (!jokerPlayed || !mightyPlayed) {
              // 마이티/조커 잔존 → 상대가 기루다 컷을 꺼림 → 비기루다 A/K 안전
              nonGirudaTopCards.sort((a, b) =>
                  _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
              return nonGirudaTopCards.first;
            }
          }
        }

        // ★ 상대 기루다 없음 + 최상위가 전부 기루다 → 물패 전략 검토
        // 기루다 보존 후 void 무늬에서 컷으로 선 탈환하는 것이 유리
        if (remainingGiruda == 0) {
          final nonGirudaTopCards = topCards.where((c) => c.suit != state.giruda).toList();
          if (nonGirudaTopCards.isNotEmpty) {
            // 비기루다 최상위 우선 사용
            nonGirudaTopCards.sort((a, b) =>
                _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
            return nonGirudaTopCards.first;
          }

          // 최상위가 전부 기루다: 마이티/조커 없으면 물패로 기루다 보존
          bool hasMightyOrJoker = playableCards.any((c) =>
              c.isJoker || c.isMightyWith(state.giruda));
          final nonGirudaAll = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();

          if (!hasMightyOrJoker && nonGirudaAll.isNotEmpty &&
              state.currentTrickNumber <= 8) {
            // void 무늬 수 확인
            Set<Suit> myNonGirudaSuits = {};
            for (final c in player.hand) {
              if (!c.isJoker && c.suit != null && c.suit != state.giruda) {
                myNonGirudaSuits.add(c.suit!);
              }
            }
            int nonGirudaSuitTotal = Suit.values.where((s) => s != state.giruda).length;
            int voidSuitCount = nonGirudaSuitTotal - myNonGirudaSuits.length;

            final myGirudaCount = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).length;
            int remainingTricks = 10 - state.currentTrickNumber + 1;

            if (myGirudaCount < remainingTricks && voidSuitCount > 0) {
              // 비점수 물패 우선
              final nonPointCards = nonGirudaAll.where((c) => !c.isPointCard).toList();
              if (nonPointCards.isNotEmpty) {
                nonPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return nonPointCards.first;
              }
              nonGirudaAll.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return nonGirudaAll.first;
            }
          }
        }

        // 가장 높은 실효가치 카드 선택
        topCards.sort((a, b) =>
            _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
        return topCards.first;
      }

      // 최상위 카드가 없을 때만 마이티/조커 사용 (후반전, 점수 카드 확보용)
      // 마이티가 있으면 마이티 사용 (7트릭 이후, 점수 카드 확보 가능성 높을 때)
      if (state.currentTrickNumber >= 7) {
        final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
        if (mighty.isNotEmpty) {
          return mighty.first;
        }
      }

      // 조커가 있으면 조커 사용 (7트릭 이후, 마지막 트릭 제외)
      if (state.currentTrickNumber >= 7 && state.currentTrickNumber < 10) {
        final joker = playableCards.where((c) => c.isJoker).toList();
        if (joker.isNotEmpty) {
          // ★ 9트릭이 아니고 수비팀에 기루다가 없으면 조커 선공 스킵
          // 조커로 선공하면 조커가 이기는데, 수비팀에 기루다가 없으면
          // 주공에게 선을 넘겨서 주공이 약한 카드로 선공하도록 하는 것이 유리
          if (state.currentTrickNumber != 9 && !_estimateDefenseTeamHasGiruda(player, state)) {
            // ★ 주공이 void인 무늬가 있으면 해당 무늬의 중간 순위 카드로 선공
            // 주공이 기루다로 컷해서 선을 잡을 수 있도록 함
            Set<Suit> declarerVoidSuits = _getDeclarerVoidSuits(state);
            if (declarerVoidSuits.isNotEmpty) {
              final Suit mightySuit = state.giruda == Suit.spade ? Suit.diamond : Suit.spade;
              for (Suit voidSuit in declarerVoidSuits) {
                // 조커 프렌드일 때 마이티 무늬 스킵
                if (isJokerFriend && voidSuit == mightySuit) continue;
                final voidSuitCards = playableCards.where((c) =>
                    !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == voidSuit).toList();
                if (voidSuitCards.isNotEmpty) {
                  // 중간 순위 카드 선택 (주공이 컷하기 좋게)
                  voidSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                  int midIndex = voidSuitCards.length ~/ 2;
                  return voidSuitCards[midIndex];
                }
              }
            }
            // void 무늬가 없으면 아래 로직으로 진행
          } else {
            return joker.first;
          }
        }
      }

      // === 최상위 카드가 없으면 주공에게 선공 넘기기 ===

      // ★ 주공이 몇 번째 순서인지 계산 (프렌드가 선공=1번째)
      // 주공이 중간 순서면 뒤에 수비팀이 남아있어 컷해도 뒤집힐 수 있음
      int declarerOrder = 0;
      if (state.declarerId != null) {
        for (int i = 1; i <= 4; i++) { // 5명 중 자신 제외 4명
          int playerId = (player.id + i) % 5;
          if (playerId == state.declarerId) {
            declarerOrder = i + 1; // 프렌드가 1번째이므로 주공은 i+1번째
            break;
          }
        }
      }
      bool isDeclarerLastOrFourth = declarerOrder >= 4; // 4번째 또는 5번째(마지막)

      // ★ 프렌드에게 선 유지 수단이 없으면 주공 순서와 관계없이 선 넘기기
      // 선 유지 수단: 기루다, 조커, 최상위카드(실효가치 14+)
      // ※ 마이티는 제외 (선 탈환용으로 보존하는 게 유리)
      bool hasNoLeadKeepingCards = !playableCards.any((c) =>
          c.isJoker ||
          c.suit == state.giruda ||
          _getEffectiveCardValue(c, state) >= 14);

      // 전략 1: 주공이 없는 무늬로 선공 (주공이 기루다로 컷 가능)
      // ★ 주공이 4번째 이후이거나, 프렌드에게 선 유지 수단이 없을 때 사용
      // 조커 프렌드일 때는 마이티 무늬 제외
      // ★ 주공이 기루다 컷할 것이 확실하면 점수카드를 실어서 득점 극대화
      Set<Suit> declarerVoidSuits = _getDeclarerVoidSuits(state);
      if ((isDeclarerLastOrFourth || hasNoLeadKeepingCards) && declarerVoidSuits.isNotEmpty) {
        for (Suit voidSuit in declarerVoidSuits) {
          // 조커 프렌드일 때 마이티 무늬 스킵
          if (isJokerFriend && voidSuit == mightySuit) continue;
          final voidSuitCards = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == voidSuit).toList();
          if (voidSuitCards.isNotEmpty) {
            // ★ 주공이 기루다 컷 가능 + 주공이 후순위(4,5번째)이면 점수카드 실어주기
            // 주공이 마지막에 가까울수록 수비 기루다 컷에 뒤집힐 위험 낮음
            if (isDeclarerLastOrFourth) {
              final pointCards = voidSuitCards.where((c) => c.isPointCard).toList();
              if (pointCards.isNotEmpty) {
                // 점수카드 중 가장 높은 것 (Q > J > 10 > K > A 순으로 가치 동일하지만 높은 카드 우선)
                pointCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
                return pointCards.first;
              }
            }
            // 점수카드 없거나 주공 순서가 빠르면 낮은 카드로 선공
            voidSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return voidSuitCards.first;
          }
        }
      }

      // 전략 1-2: 확정 void가 없으면 추론으로 주공 void 가능성 높은 무늬 선택
      // 주공이 한 번도 내지 않고 + 다른 비기루다/기루다를 많이 냈으면 void 가능성 높음
      if ((isDeclarerLastOrFourth || hasNoLeadKeepingCards) && declarerVoidSuits.isEmpty) {
        final suitHoldings = _inferDeclarerSuitHoldings(state);
        final inferredCandidates = suitHoldings.entries
            .where((e) => e.value > 0 && e.value <= 0.3)
            .where((e) => !(isJokerFriend && e.key == mightySuit))
            .toList()
          ..sort((a, b) => a.value.compareTo(b.value));
        for (final entry in inferredCandidates) {
          final suitCards = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == entry.key).toList();
          if (suitCards.isNotEmpty) {
            // ★ 추론 void도 주공 후순위이면 점수카드 우선
            if (isDeclarerLastOrFourth) {
              final pointCards = suitCards.where((c) => c.isPointCard).toList();
              if (pointCards.isNotEmpty) {
                pointCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
                return pointCards.first;
              }
            }
            suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return suitCards.first;
          }
        }
      }

      // 전략 2: 낮은 기루다로 선공 (주공이 높은 기루다로 이김)
      // ★ 상대에게 기루다가 있을 때만 사용 (기루다가 없으면 비기루다 우선)
      if (remainingGiruda > 0) {
        final myGirudaCards = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
        if (myGirudaCards.isNotEmpty) {
          // 내 기루다 중 가장 낮은 것
          myGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          // 10 이하의 낮은 기루다 우선 사용 (높은 기루다는 아낌)
          final lowGiruda = myGirudaCards.where((c) => c.rankValue <= 10).toList();
          if (lowGiruda.isNotEmpty) {
            return lowGiruda.first;
          }
          // 낮은 기루다가 없어도 (J 이상만 남은 경우) 가장 낮은 기루다 사용
          // 상대 기루다 소진이 비기루다 void 만들기보다 우선
          return myGirudaCards.first;
        }
      }

      // 전략 3: 비기루다 중 짧은 무늬의 비점수 카드로 선공 (void 만들기 → 기루다 컷 가능)
      // 조커 프렌드일 때는 마이티 무늬를 마지막에 사용
      final nonGirudaCards = playableCards.where((c) =>
          !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
      if (nonGirudaCards.isNotEmpty) {
        // 컷되지 않은 무늬 우선, 조커 프렌드일 때 마이티 무늬 제외
        final cutSuits2 = _getCutSuits(state);
        var candidates = nonGirudaCards.where((c) =>
            c.suit != null && !cutSuits2.contains(c.suit) &&
            !(isJokerFriend && c.suit == mightySuit)).toList();
        if (candidates.isEmpty) {
          if (isJokerFriend) {
            candidates = nonGirudaCards.where((c) => c.suit != mightySuit).toList();
          }
          if (candidates.isEmpty) {
            candidates = nonGirudaCards;
          }
        }

        // 가장 짧은 무늬 찾기 (void 만들기 → 이후 기루다 컷 가능)
        Map<Suit, List<PlayingCard>> suitGroups = {};
        for (final c in candidates) {
          if (c.suit != null) {
            suitGroups.putIfAbsent(c.suit!, () => []).add(c);
          }
        }
        if (suitGroups.isNotEmpty) {
          // 주공 보유 확률 낮은 무늬 우선 (주공이 컷 가능), 같으면 짧은 무늬 우선
          final suitHoldings3 = _inferDeclarerSuitHoldings(state);
          final sortedSuitEntries = suitGroups.entries.toList()
            ..sort((a, b) {
              double probA = suitHoldings3[a.key] ?? 0.5;
              double probB = suitHoldings3[b.key] ?? 0.5;
              // 보유 확률을 0.2 단위로 그룹화 (큰 차이만 반영)
              int binA = (probA / 0.2).floor();
              int binB = (probB / 0.2).floor();
              if (binA != binB) return binA.compareTo(binB);
              return a.value.length.compareTo(b.value.length);
            });
          final shortestSuit = sortedSuitEntries.first;
          final suitCards = shortestSuit.value;
          // 비점수 카드 우선, 없으면 상위 카드 유도용 높은 점수 카드
          final nonPoint = suitCards.where((c) => !c.isPointCard).toList();
          if (nonPoint.isNotEmpty) {
            nonPoint.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return nonPoint.first;
          }
          // ★ 점수 카드만 남음: 미출현 상위 카드(K 등) 유도를 위해 높은 카드 우선
          // 예: ♣10, ♣Q → ♣K 미출현 시 ♣Q 선공 (♣J가 ♣10만 이기므로 ♣K 미출현 방지)
          final playedForExtract = _getPlayedCards(state);
          final highestInSuit = suitCards.reduce((a, b) =>
              a.rankValue > b.rankValue ? a : b);
          bool hasHigherUnaccounted = false;
          for (int rv = highestInSuit.rankValue + 1; rv <= 14; rv++) {
            final rank = Rank.values[rv - 2];
            bool accounted =
                playedForExtract.any((c) => c.suit == highestInSuit.suit && c.rank == rank) ||
                player.hand.any((c) => c.suit == highestInSuit.suit && c.rank == rank);
            if (!accounted) {
              hasHigherUnaccounted = true;
              break;
            }
          }
          if (hasHigherUnaccounted) {
            // 상위 카드 유도: 높은 점수 카드 우선
            suitCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
          } else {
            // 상위 카드 소진: 낮은 카드 보존 (높은 카드는 이후 활용)
            suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          }
          return suitCards.first;
        }
        // 무늬 없는 경우 fallback
        candidates.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        return candidates.first;
      }
    }

    // === 주공 초구 프렌드 호출 전략 ===
    // === 주공 초구 전략: 마이티/조커 프렌드 ===
    // 초구 승리 카드(비기루다 A)가 없으면, 적은 무늬의 낮은 카드로 선공
    // → 마이티/조커 프렌드가 트릭 승리 (둘 다 무늬 무관하게 낼 수 있음)
    // → 적은 무늬를 소진하여 void 생성 (향후 기루다 컷 가능)
    // → 프렌드가 해당 무늬 최상위 카드를 갖고 있으면 마이티/조커를 아낄 수 있음
    if (state.currentTrickNumber == 1 && player.isDeclarer && state.giruda != null) {
      bool friendIsMighty = state.friendDeclaration?.card != null &&
          state.friendDeclaration!.card == state.mighty;
      bool friendIsJokerHere = state.friendDeclaration?.card?.isJoker ?? false;

      if (friendIsMighty || friendIsJokerHere) {
        // 초구 승리 가능한 카드 확인 (각 무늬 최상위 카드)
        // - 비기루다 A (마이티 무늬 제외): 해당 무늬 최상위
        // - 마이티 무늬 K: A가 마이티로 빠졌으므로 해당 무늬 실질 최상위
        final mightySuit = state.mighty.suit!;
        bool hasFirstTrickWinner = playableCards.any((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) &&
            c.suit != state.giruda &&
            ((c.rank == Rank.ace && c.suit != mightySuit) ||
             (c.rank == Rank.king && c.suit == mightySuit)));

        if (hasFirstTrickWinner) {
          // 초구 승리 카드를 선택하여 선공권 확보
          final firstTrickWinners = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) &&
              c.suit != state.giruda &&
              ((c.rank == Rank.ace && c.suit != mightySuit) ||
               (c.rank == Rank.king && c.suit == mightySuit))).toList();
          if (firstTrickWinners.isNotEmpty) {
            // Ace 우선, 같으면 낮은 랭크 (K는 Ace보다 후순위)
            firstTrickWinners.sort((a, b) {
              if (a.rank == Rank.ace && b.rank != Rank.ace) return -1;
              if (a.rank != Rank.ace && b.rank == Rank.ace) return 1;
              return a.rankValue.compareTo(b.rankValue);
            });
            return firstTrickWinners.first;
          }
        }

        if (!hasFirstTrickWinner) {
          // ★ 기루다가 많은데 기루다 A가 없으면 마이티로 초구 선공
          // 마이티로 선을 잡고 트릭 2부터 기루다 최상위(K)를 선공하여
          // 상대 기루다 A를 강제 소진 → 이후 기루다 우위 확보
          final myGirudaCount = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).length;
          final hasGirudaAce = playableCards.any((c) =>
              !c.isJoker && c.suit == state.giruda && c.rank == Rank.ace);
          final hasMighty = playableCards.any((c) => c.isMightyWith(state.giruda));
          if (myGirudaCount >= 4 && !hasGirudaAce && hasMighty) {
            final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
            return mighty.first;
          }

          // 비기루다 카드 (조커/마이티 제외)
          final nonGirudaCards = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) &&
              c.suit != state.giruda).toList();

          if (nonGirudaCards.isNotEmpty) {
            // 무늬별 카드 수 계산 (적은 무늬 우선 → void 생성)
            Map<Suit, int> suitCountMap = {};
            for (final c in nonGirudaCards) {
              if (c.suit != null) {
                suitCountMap[c.suit!] = (suitCountMap[c.suit!] ?? 0) + 1;
              }
            }

            // 적은 무늬 + 낮은 랭크 순으로 정렬
            nonGirudaCards.sort((a, b) {
              int aCount = suitCountMap[a.suit] ?? 0;
              int bCount = suitCountMap[b.suit] ?? 0;
              if (aCount != bCount) return aCount.compareTo(bCount);
              return a.rankValue.compareTo(b.rankValue);
            });

            // 1순위: 9 이하 비점수 카드 (안전)
            final safeCards = nonGirudaCards.where((c) => c.rankValue <= 9).toList();
            if (safeCards.isNotEmpty) {
              return safeCards.first;
            }
            // 2순위: 10 (점수카드 중 최저 랭크)
            final tenCards = nonGirudaCards.where((c) => c.rank == Rank.ten).toList();
            if (tenCards.isNotEmpty) {
              return tenCards.first;
            }
            // 3순위: J
            final jackCards = nonGirudaCards.where((c) => c.rank == Rank.jack).toList();
            if (jackCards.isNotEmpty) {
              return jackCards.first;
            }
            // 나머지: 최저 카드
            return nonGirudaCards.first;
          }
        }
      }
    }

    // === 주공팀 또는 노기루다 선공 전략 ===

    // === 주공: 트릭 2~3 기루다 선공 전략 ===
    // ★ 조커콜은 decideJokerCall()에서 처리 (마이티 프렌드 + 조커 없음 → 조커콜 선언)
    // 1. 기루다 최상위 카드 있음 → 기루다 최상위 카드로 선공
    // 2. 기루다 최상위 없음 + 마이티/조커/기루다 프렌드 → 중간 기루다로 선공
    // 3. 위 조건 해당 안 됨 → 일반 선공 정책
    if (state.giruda != null && (state.currentTrickNumber == 2 || state.currentTrickNumber == 3)) {
      bool isAttackTeam = !_isPlayerOnDefenseTeam(player, state);

      if (isAttackTeam && player.isDeclarer) {
        // 프렌드 유형 확인
        final friendCard = state.friendDeclaration?.card;
        bool friendIsMighty = friendCard != null && friendCard.isMightyWith(state.giruda);
        bool friendIsJoker = friendCard != null && friendCard.isJoker;
        bool friendIsGiruda = friendCard != null &&
            !friendCard.isJoker &&
            !friendCard.isMightyWith(state.giruda) &&
            friendCard.suit == state.giruda;
        bool friendIsSpecialOrGiruda = friendCard == null ||
            friendIsMighty || friendIsJoker || friendIsGiruda;

        // 내 기루다 카드들 (선공용)
        final myGirudaCardsForLead = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();

        // 지금까지 나온 기루다 카드들
        final playedGirudaCards = _getPlayedCards(state).where((c) =>
            !c.isJoker && c.suit == state.giruda).toList();

        // 내 기루다 중 최고 랭크 카드 찾기
        PlayingCard? myTopGiruda;
        int myHighestGirudaRank = 0;
        if (myGirudaCardsForLead.isNotEmpty) {
          final sortedGiruda = List<PlayingCard>.from(myGirudaCardsForLead)
            ..sort((a, b) => b.rankValue.compareTo(a.rankValue));
          myTopGiruda = sortedGiruda.first;
          myHighestGirudaRank = myTopGiruda.rankValue;
        }

        // 내 기루다가 실효 최상위인지 확인 (상대에게 더 높은 기루다가 없음)
        bool hasEffectiveTopGiruda = myHighestGirudaRank > 0;
        for (int rankValue = 14; rankValue > myHighestGirudaRank; rankValue--) {
          bool played = playedGirudaCards.any((c) => c.rankValue == rankValue);
          bool inMyHand = myGirudaCardsForLead.any((c) => c.rankValue == rankValue);
          if (!played && !inMyHand) {
            hasEffectiveTopGiruda = false;  // 상대에게 더 높은 기루다 있음
            break;
          }
        }

        // === 0. 기루다 프렌드 보호: 프렌드 카드가 아직 안 나왔으면 저액 기루다 선공 ===
        // 예: 프렌드가 ♦K이고 내가 ♦A를 내면 프렌드가 K딸랑일 때 K를 무의미하게 버림
        // → 프렌드 카드보다 낮은 기루다로 선공하여 프렌드에게 선 넘기기
        if (friendIsGiruda && friendCard != null && hasEffectiveTopGiruda) {
          bool friendCardPlayed = playedGirudaCards.any((c) =>
              c.rank == friendCard.rank);
          if (!friendCardPlayed) {
            final lowerCards = myGirudaCardsForLead.where((c) =>
                c.rankValue < friendCard.rankValue).toList();
            if (lowerCards.isNotEmpty) {
              // 9 이하 중간 기루다 우선 (높은 순)
              final midGiruda = lowerCards.where((c) => c.rankValue <= 9).toList();
              if (midGiruda.isNotEmpty) {
                midGiruda.sort((a, b) => b.rankValue.compareTo(a.rankValue));
                return midGiruda.first;
              }
              lowerCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return lowerCards.first;
            }
          }
        }

        // === 1. 기루다 최상위 카드 있음 → 기루다 최상위 카드로 선공 ===
        if (hasEffectiveTopGiruda && myTopGiruda != null) {
          return myTopGiruda;
        }

        // === 2. 기루다 최상위 없음 + 프렌드 지원 가능 → 중간 기루다로 선공 ===
        // 9 이하 중간 기루다(9, 8, 7...)로 상대 고액 기루다(A, K) 소진 유도
        // - 마이티 프렌드: 기루다 void이면 마이티로 트릭 승리 가능
        // - 기루다 프렌드: 고액 기루다로 트릭 승리 가능
        // (고액 기루다를 내면 상대 A/K에 불필요하게 상실)
        if (!hasEffectiveTopGiruda && friendIsSpecialOrGiruda && myGirudaCardsForLead.isNotEmpty) {
          // 9 이하 중간 기루다 우선 (높은 순: 9 > 8 > 7 ...)
          final midGiruda = myGirudaCardsForLead.where((c) => c.rankValue <= 9).toList();
          if (midGiruda.isNotEmpty) {
            midGiruda.sort((a, b) => b.rankValue.compareTo(a.rankValue));
            return midGiruda.first;
          }
          // 9 이하 없으면 최저 기루다
          myGirudaCardsForLead.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return myGirudaCardsForLead.first;
        }

        // 3. 위 조건 해당 안 됨 → 아래 일반 선공 정책으로 진행
      }
    }

    // === 조커로 기루다 콜하여 수비팀 기루다 소진 (트릭 4 이후) ===
    // ★ 프렌드가 일반 카드(마이티/조커 아님)인 경우 조커 선공 스킵
    // → 프렌드에게 선을 넘기는 전략 우선
    // ★ 기루다 최상위(A)가 있거나 마이티가 없는 경우에만 조커 콜
    if (state.giruda != null && state.currentTrickNumber >= 4 && state.currentTrickNumber <= 8) {
      bool isAttackTeam = !_isPlayerOnDefenseTeam(player, state);

      if (isAttackTeam && player.isDeclarer) {
        // ★ 프렌드가 일반 카드(마이티/조커 아님)인 경우 조커 선공 스킵
        final friendCard = state.friendDeclaration?.card;
        bool friendIsSpecialCard = friendCard == null ||
            friendCard.isJoker || friendCard.isMightyWith(state.giruda);

        // 프렌드가 마이티/조커인 경우에만 조커로 기루다 콜
        if (friendIsSpecialCard) {
          final joker = playableCards.where((c) => c.isJoker).toList();

          if (joker.isNotEmpty) {
            // 지금까지 나온 기루다 카드들
            final playedGirudaCards = _getPlayedCards(state).where((c) =>
                !c.isJoker && c.suit == state.giruda).toList();

            // 내 기루다 카드들
            final myGirudaCards = player.hand.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();

            // 기루다 A(최상위)가 있는지 확인
            bool hasGirudaAce = myGirudaCards.any((c) => c.rank == Rank.ace);

            // 마이티가 있는지 확인 (마이티가 있으면 위에서 기루다 선공으로 처리됨)
            bool hasMighty = playableCards.any((c) => c.isMightyWith(state.giruda));

            // 내 기루다 중 최고 랭크 (없으면 0)
            int myHighestGirudaRank = 0;
            if (myGirudaCards.isNotEmpty) {
              myGirudaCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
              myHighestGirudaRank = myGirudaCards.first.rankValue;
            }

            // 상대에게 내 기루다보다 높은 기루다가 남아있는지 확인
            bool opponentHasHigherGiruda = false;
            for (int rankValue = 14; rankValue > myHighestGirudaRank; rankValue--) {
              bool played = playedGirudaCards.any((c) => c.rankValue == rankValue);
              bool inMyHand = myGirudaCards.any((c) => c.rankValue == rankValue);
              if (!played && !inMyHand) {
                opponentHasHigherGiruda = true;
                break;
              }
            }

            // ★ 조커 콜 조건: 기루다 A가 있거나, 마이티가 없는 경우
            // (마이티가 있고 기루다 A가 없으면 위에서 기루다 선공으로 처리됨)
            if (opponentHasHigherGiruda && (hasGirudaAce || !hasMighty)) {
              final defensePlayedGiruda = _hasDefensePlayedGirudaOnCall(state);
              if (defensePlayedGiruda || !_hasGirudaCallTrick(state)) {
                return joker.first;
              }
            }
          }
        }
      }
    }

    // === 주공이 프렌드에게 선 넘기기 ===
    // 프렌드가 특정 카드로 선언되었고, 내가 그 무늬를 가지고 있으면
    // 프렌드에게 선을 넘겨서 프렌드가 선을 유지하게 함
    if (player.isDeclarer && state.friendDeclaration?.card != null) {
      final friendCard = state.friendDeclaration!.card!;
      final mightySuit = state.mighty.suit;

      // 조커를 가지고 있는지 확인
      bool hasJoker = playableCards.any((c) => c.isJoker);
      bool hasMighty = playableCards.any((c) => c.isMightyWith(state.giruda));

      // 선을 유지할 수 있는 최상위 카드(A) 확인 (기루다 A 포함)
      bool hasAnyAce = false;
      for (final suit in Suit.values) {
        // 마이티는 제외
        if (state.mighty.suit == suit && state.mighty.rank == Rank.ace) continue;
        bool hasAce = playableCards.any((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == suit && c.rank == Rank.ace);
        if (hasAce) {
          hasAnyAce = true;
          break;
        }
      }

      // 기루다 A 확인 (기루다가 있는 경우, 마이티가 아닌 A)
      bool hasGirudaAce = state.giruda != null && playableCards.any((c) =>
          !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda && c.rank == Rank.ace);

      // 실효가치 14+ 카드 확인
      bool hasTopCard = playableCards.any((c) =>
          !c.isJoker && !c.isMightyWith(state.giruda) &&
          _getEffectiveCardValue(c, state) >= 14);

      // ★ 선을 유지할 수 있는 카드가 있는지 확인
      bool canMaintainLead = hasAnyAce || hasTopCard || hasGirudaAce;

      // ★ 노기루다에서 선 유지 확률이 낮을 때 프렌드에게 선 넘기기
      // 조건: 노기루다 + A가 없고 + 실효가치 14+ 카드도 없음
      bool shouldPassToFriendNoGiruda = state.giruda == null &&
          !hasAnyAce && !hasTopCard;

      // ★★★ 프렌드가 비기루다 일반 카드인 경우 → 초구에서 선 넘기기 ★★★
      // 프렌드 무늬로 선공하여 프렌드에게 선을 넘김
      if (!friendCard.isJoker && !friendCard.isMightyWith(state.giruda) &&
          friendCard.suit != null && friendCard.suit != state.giruda) {

        // 초구에서 프렌드에게 선 넘기기
        if (state.currentTrickNumber == 1) {
          final friendSuit = friendCard.suit!;

          // 프렌드 무늬 카드가 있는지 확인 (마이티/조커 제외)
          final friendSuitCards = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == friendSuit).toList();

          if (friendSuitCards.isNotEmpty) {
            // 프렌드 무늬의 낮은 카드로 선공하여 프렌드에게 선 넘기기
            friendSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return friendSuitCards.first;
          }
        }
      }

      // ★★★ 프렌드가 기루다 카드인 경우 → 기루다 낮은 카드로 선 넘기기 ★★★
      // 기루다 낮은 카드로 선공 → 프렌드가 기루다 A로 받아서 선을 가져감
      // 수비팀 기루다도 빠지고, 프렌드에게 선을 넘길 수 있음
      if (!friendCard.isJoker && !friendCard.isMightyWith(state.giruda) &&
          friendCard.suit == state.giruda && state.giruda != null) {

        // 기루다 카드 중 프렌드 카드보다 낮은 카드 찾기
        final girudaCards = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();

        if (girudaCards.isNotEmpty) {
          // 프렌드 카드(예: 기루다 A)보다 낮은 기루다 카드 선택
          final lowerCards = girudaCards.where((c) =>
              c.rankValue < friendCard.rankValue).toList();

          if (lowerCards.isNotEmpty) {
            // 가장 낮은 기루다 카드로 선공
            lowerCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return lowerCards.first;
          }
        }
      }

      // ★ 마이티 프렌드인 경우 → 기루다 저액 선공 우선 (마이티 무늬 회피)
      // 기루다 저액 선공으로 수비팀 기루다 소진 → 마이티 프렌드가 기루다 void이면 마이티로 승리
      // 마이티 무늬(♠) 선공은 상대 고액 스페이드에 선을 빼앗길 위험이 높음
      if (friendCard.isMightyWith(state.giruda)) {
        if (!canMaintainLead && !hasMighty && !hasJoker) {
          final opponentGirudaMF = _getRemainingGirudaCount(state, player);
          if (opponentGirudaMF > 0) {
            // ★ 기루다 카드 있으면 중간 기루다 선공 (마이티 무늬 대신)
            // 9 이하 중간 기루다로 상대 고액 기루다 소진 유도
            // 프렌드가 기루다 void이면 마이티로 트릭 승리
            if (state.giruda != null) {
              final girudaCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
              if (girudaCards.isNotEmpty) {
                // 9 이하 중간 기루다 우선 (높은 순: 9 > 8 > 7 ...)
                final midGiruda = girudaCards.where((c) => c.rankValue <= 9).toList();
                if (midGiruda.isNotEmpty) {
                  midGiruda.sort((a, b) => b.rankValue.compareTo(a.rankValue));
                  return midGiruda.first;
                }
                // 9 이하 없으면 최저 기루다
                girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return girudaCards.first;
              }
            }

            // 기루다 없으면 마이티 무늬 카드로 선 넘기기 (마이티 자체 제외)
            final mightySuitCards = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == mightySuit).toList();

            if (mightySuitCards.isNotEmpty) {
              mightySuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return mightySuitCards.first;
            }
          }
          // opponentGirudaMF == 0 → 기루다 보존, 상대 기루다 소진 블록에서 종합 처리
        }
        // 마이티 프렌드일 때는 마이티 무늬 회피 - 다른 전략으로 진행
      }

      // ★ 노기루다에서 프렌드 무늬가 없을 때: 프렌드 공개 시도
      // 프렌드가 공개되면 프렌드가 선을 도와줄 수 있음
      if (shouldPassToFriendNoGiruda && !state.friendRevealed) {
        // 프렌드가 A를 가지고 있으면 (마이티 제외), 해당 무늬의 낮은 카드로 선공
        if (friendCard.rank == Rank.ace && !friendCard.isJoker && !friendCard.isMightyWith(state.giruda)) {
          final friendSuit = friendCard.suit;
          if (friendSuit != null) {
            final suitCards = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == friendSuit).toList();
            if (suitCards.isNotEmpty) {
              suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return suitCards.first;
            }
          }
        }
      }
    }

    // ★ 선 교환(Win-Lose Alternation) 전략
    // 주공이 보증 승리 카드를 연속 소진하면 후반에 선공권을 잃고
    // 고점수 트릭을 상대에 헌납함. 승리/버림을 교대하여 마지막까지 선 유지.
    if (state.giruda != null && player.isDeclarer &&
        state.currentTrickNumber >= 4 && state.currentTrickNumber <= 9) {
      final int remainingTricks = 10 - state.currentTrickNumber + 1;
      final giruda = state.giruda!;

      // 상대가 보유한 최고 기루다 rankValue 추정
      final playedGirudaCards = _getPlayedCardsOfSuit(state, giruda);
      final myGirudaCards = playableCards.where((c) =>
          !c.isJoker && !c.isMightyWith(giruda) && c.suit == giruda).toList();
      // 상대가 가질 수 있는 기루다: 전체 13장 - 나온 것 - 내 것
      final Set<int> goneGirudaRanks = {
        ...playedGirudaCards.map((c) => c.rankValue),
        ...myGirudaCards.map((c) => c.rankValue),
      };
      // 마이티는 기루다 무늬 A이므로 제외 (별도 처리)
      final mightyRankInGiruda = 14; // Ace
      int opponentHighestGiruda = 0;
      for (int rv = 13; rv >= 2; rv--) { // K(13)부터 2까지
        if (!goneGirudaRanks.contains(rv)) {
          opponentHighestGiruda = rv;
          break;
        }
      }
      // 마이티가 아직 안 나왔고 내가 안 갖고 있으면 상대 최고는 마이티(100급)
      if (!goneGirudaRanks.contains(mightyRankInGiruda) &&
          !playableCards.any((c) => c.isMightyWith(giruda))) {
        // 상대가 마이티를 가지고 있을 수 있음 → 내 기루다 A도 마이티에 짐
        opponentHighestGiruda = 100;
      }

      // 보증 승리 카드 목록
      List<PlayingCard> guaranteedWinCards = [];
      // (1) 기루다 중 상대 최고보다 높은 것 (마이티 제외)
      for (final c in myGirudaCards) {
        if (c.rankValue > opponentHighestGiruda) {
          guaranteedWinCards.add(c);
        }
      }
      // (2) 조커 (트릭 10 이전이면 항상 승리)
      if (state.currentTrickNumber < 10) {
        final joker = playableCards.where((c) => c.isJoker).toList();
        guaranteedWinCards.addAll(joker);
      }
      // (3) 마이티 (트릭 7 이상일 때만 — shouldAvoidMighty와 일치)
      if (state.currentTrickNumber >= 7) {
        final mighty = playableCards.where((c) => c.isMightyWith(giruda)).toList();
        guaranteedWinCards.addAll(mighty);
      }

      final int neededWins = remainingTricks ~/ 2; // 교대에 필요한 승리 수

      // 비기루다 버림 카드
      final nonGirudaDumpCards = playableCards.where((c) =>
          !c.isJoker && !c.isMightyWith(giruda) && c.suit != giruda).toList();

      // 선 탈환 수단: 조커 보유 OR (기루다 카드 + void 무늬 ≥ 1)
      final hasJokerForRecapture = playableCards.any((c) => c.isJoker);
      Set<Suit> myNonGirudaSuits = {};
      for (final c in player.hand) {
        if (!c.isJoker && c.suit != null && c.suit != giruda) {
          myNonGirudaSuits.add(c.suit!);
        }
      }
      final int nonGirudaSuitTotal = Suit.values.where((s) => s != giruda).length;
      final int voidSuitCount = nonGirudaSuitTotal - myNonGirudaSuits.length;
      final hasGirudaCutRecapture = myGirudaCards.isNotEmpty && voidSuitCount >= 1;
      final hasRecaptureMeans = hasJokerForRecapture || hasGirudaCutRecapture;

      // 발동 조건 검증
      // ★ 보증 승리가 충분하면 (물패 3장 미만) 교대 불필요 → 연속 승리 후 물패
      // 예: 7트릭 남고 5승 보유 → 5연승 후 2물패가 교대보다 유리
      final int dumpGap = remainingTricks - guaranteedWinCards.length;
      if (guaranteedWinCards.length >= neededWins &&
          guaranteedWinCards.length >= 2 &&
          guaranteedWinCards.length < remainingTricks &&
          dumpGap >= 3 &&
          nonGirudaDumpCards.isNotEmpty &&
          hasRecaptureMeans) {

        final bool shouldDump = remainingTricks % 2 == 1; // 홀수 남음 → 버림

        if (shouldDump) {
          // ★ 버림: 비기루다 카드 중 void 생성 우선
          // 무늬별 카드 수 계산 (적은 무늬 우선 → void 생성)
          Map<Suit, List<PlayingCard>> suitGroups = {};
          for (final c in nonGirudaDumpCards) {
            suitGroups.putIfAbsent(c.suit!, () => []).add(c);
          }
          // 카드 수가 적은 무늬 순으로 정렬
          final sortedSuits = suitGroups.entries.toList()
            ..sort((a, b) => a.value.length.compareTo(b.value.length));

          final bestSuitCards = sortedSuits.first.value;
          bestSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));

          if (!state.friendRevealed) {
            // 프렌드 미공개: 마이티/조커로 트릭 승리 가능 → 9이하 → 10 → J 순
            final safeCards = bestSuitCards.where((c) => c.rankValue <= 9).toList();
            if (safeCards.isNotEmpty) return safeCards.first;
            final tenCards = bestSuitCards.where((c) => c.rank == Rank.ten).toList();
            if (tenCards.isNotEmpty) return tenCards.first;
            final jackCards = bestSuitCards.where((c) => c.rank == Rank.jack).toList();
            if (jackCards.isNotEmpty) return jackCards.first;
            return bestSuitCards.first;
          } else {
            // 프렌드 공개 후: 수비 견제 → 비점수 최저 우선
            final nonPointDump = bestSuitCards.where((c) => !c.isPointCard).toList();
            if (nonPointDump.isNotEmpty) return nonPointDump.first;
            return bestSuitCards.first;
          }
        } else {
          // ★ 승리: 가장 약한 기루다 승리 카드 우선, 조커는 후순위 (트릭 9 탈환용 보존)
          final girudaWinCards = guaranteedWinCards.where((c) =>
              !c.isJoker && !c.isMightyWith(giruda)).toList();
          if (girudaWinCards.isNotEmpty) {
            girudaWinCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return girudaWinCards.first;
          }
          // 기루다 승리 카드 없으면 마이티
          final mightyWin = guaranteedWinCards.where((c) =>
              c.isMightyWith(giruda)).toList();
          if (mightyWin.isNotEmpty) {
            return mightyWin.first;
          }
          // 최후: 조커
          return guaranteedWinCards.first;
        }
      }
    }

    // 상대에게 남은 기루다가 없으면 최상위 카드 우선 (컷 당할 위험 없음)
    // 마이티/조커는 점수 카드가 많을 때 사용하는 것이 유리하므로 나중에 사용
    if (state.giruda != null) {
      final opponentGiruda = _getRemainingGirudaCount(state, player);

      if (opponentGiruda == 0) {
        // ★ 주공: 상대 기루다 소진 → 기루다 연속 리드 후 조커, 물패는 후반으로
        // 기루다 리드는 상대에게 기루다 없어 모두 승리 → 기루다 먼저 사용
        // 물패를 조기(4~6트릭)에 사용하면 손해 → 후반(9~10트릭)에 배치
        // 조커는 기루다 수 ≤ 물패 수 시점에 삽입하여 비기루다 호출로 점수 추출
        // 예: 4기루다 + JK + 2물패 → ♦♦ → JK(♥호출) → ♦♦ → ♥♥(후반 물패)
        if (player.isDeclarer && state.currentTrickNumber >= 2) {
          final myGirudaForLead = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
          final nonGirudaDump = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
          final jokerForLead = playableCards.where((c) => c.isJoker).toList();

          // 마이티 안전 여부 (내가 보유, 프렌드 카드, 또는 이미 플레이됨)
          bool mightySafe = false;
          if (jokerForLead.isNotEmpty) {
            final allPlayed = _getPlayedCards(state);
            mightySafe = allPlayed.any((c) => c.isMightyWith(state.giruda)) ||
                player.hand.any((c) => c.isMightyWith(state.giruda)) ||
                (state.friendDeclaration?.card?.isMightyWith(state.giruda) ?? false);
          }

          // ── 결정 트리: 주공 상대 기루다 소진 시 선공 전략 ──
          final int gCount = myGirudaForLead.length;
          final int dCount = nonGirudaDump.length;
          final bool hasJokerForLead = jokerForLead.isNotEmpty;
          final int winCards = gCount + (hasJokerForLead ? 1 : 0);

          // voidSuits: 비기루다 중 void인 무늬 수 (기루다 컷 가능 횟수)
          Set<Suit> myNonGirudaSuits = {};
          for (final c in player.hand) {
            if (!c.isJoker && c.suit != null && c.suit != state.giruda) {
              myNonGirudaSuits.add(c.suit!);
            }
          }
          final nonGirudaSuitTotal = Suit.values.where((s) => s != state.giruda!).length;
          final voidSuits = nonGirudaSuitTotal - myNonGirudaSuits.length;

          // (A) 프렌드 유도: 미공개 프렌드 공개 시도
          if (!state.friendRevealed && dCount >= 2) {
            final friendDecl = state.friendDeclaration?.card;
            if (friendDecl != null) {
              if (!friendDecl.isJoker &&
                  !friendDecl.isMightyWith(state.giruda) &&
                  friendDecl.suit != state.giruda && friendDecl.suit != null) {
                // 비특수 프렌드 → 프렌드 무늬 최저 카드 리드로 공개 유도
                final friendSuitCards = nonGirudaDump.where(
                    (c) => c.suit == friendDecl.suit).toList();
                if (friendSuitCards.isNotEmpty) {
                  friendSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                  return friendSuitCards.first;
                }
              } else if (friendDecl.isJoker || friendDecl.isMightyWith(state.giruda)) {
                // 마이티/조커 프렌드 → 트릭 승리가 보장되므로 무늬 무관 점수 극대화
                // 비기루다 점수 카드(A,K,Q,J,10) 최고값 리드 → 프렌드가 컷하여 점수 획득
                final pointCards = nonGirudaDump.where((c) => c.isPointCard).toList();
                if (pointCards.isNotEmpty) {
                  pointCards.sort((a, b) =>
                      _getEffectiveCardValue(b, state).compareTo(
                          _getEffectiveCardValue(a, state)));
                  return pointCards.first;
                }
              }
            }
          }

          // (B) 조커 삽입: J + mightySafe + G ≤ D
          // 비기루다 호출로 점수 추출
          if (hasJokerForLead && mightySafe && gCount <= dCount &&
              state.currentTrickNumber < 10) {
            return jokerForLead.first;
          }

          // (C) 기루다 연속 승리: winCards > D (승리 여유)
          // 충분히 이기므로 기루다 먼저, 물패는 후반
          if (winCards > dCount && myGirudaForLead.isNotEmpty) {
            myGirudaForLead.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return myGirudaForLead.first;
          }

          // (D) 물패/기루다 교대: D ≥ 2 AND (G ≥ 2 OR (G ≥ 1 AND voidSuits ≥ 1))
          // 기루다를 리드 대신 컷용으로 보존, 물패로 선 넘기기
          // → 상대 리드 시 void 무늬에서 기루다 컷 → 선 탈환
          // 예: T6 ♥10 리드(+1) → T9 -5 헌납 vs T6 물패 → T9 ♥10 컷(+5)
          if (dCount >= 2 && (gCount >= 2 || (gCount >= 1 && voidSuits >= 1))) {
            // 무늬별 그룹화, 카드 수 적은 순 (void 생성 → 미래 컷 기회 확보)
            Map<Suit, List<PlayingCard>> suitGroups = {};
            for (final c in nonGirudaDump) {
              if (c.suit != null) {
                suitGroups.putIfAbsent(c.suit!, () => []);
                suitGroups[c.suit!]!.add(c);
              }
            }
            final sortedSuits = suitGroups.entries.toList()
              ..sort((a, b) => a.value.length.compareTo(b.value.length));
            if (sortedSuits.isNotEmpty) {
              final suitCards = sortedSuits.first.value;
              if (!state.friendRevealed) {
                // rank ≤ 9 비점수 → 10 → J → 최저
                final lowNonPoint = suitCards.where((c) =>
                    c.rankValue <= 9 && !c.isPointCard).toList();
                if (lowNonPoint.isNotEmpty) {
                  lowNonPoint.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                  return lowNonPoint.first;
                }
                final tens = suitCards.where((c) => c.rankValue == 10).toList();
                if (tens.isNotEmpty) return tens.first;
                final jacks = suitCards.where((c) => c.rankValue == 11).toList();
                if (jacks.isNotEmpty) return jacks.first;
              } else {
                // 프렌드 공개 → 비점수 최저
                final nonPoint = suitCards.where((c) => !c.isPointCard).toList();
                if (nonPoint.isNotEmpty) {
                  nonPoint.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                  return nonPoint.first;
                }
              }
              // 최저 카드
              suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return suitCards.first;
            }
          }

          // (E) 조커 미출현: 비기루다 실효 최상위(≥14) 리드
          // 조커에 잡힐 비기루다 최상위를 먼저 소비, 기루다 보존
          if (nonGirudaDump.isNotEmpty) {
            final playedForJokerCheck = _getPlayedCards(state);
            bool jokerAccountedFor =
                playedForJokerCheck.any((c) => c.isJoker) ||
                player.hand.any((c) => c.isJoker);
            if (!jokerAccountedFor) {
              final highNonGiruda = nonGirudaDump.where((c) =>
                  _getEffectiveCardValue(c, state) >= 14).toList();
              if (highNonGiruda.isNotEmpty) {
                highNonGiruda.sort((a, b) =>
                    _getEffectiveCardValue(b, state).compareTo(
                        _getEffectiveCardValue(a, state)));
                return highNonGiruda.first;
              }
            }
          }

          // (F) Fallback: 기루다 최저 리드
          if (myGirudaForLead.isNotEmpty) {
            myGirudaForLead.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return myGirudaForLead.first;
          }

          // 2. 기루다 소진 → 조커로 비기루다 호출
          if (jokerForLead.isNotEmpty && mightySafe && state.currentTrickNumber < 10) {
            return jokerForLead.first;
          }

          // 3. 기루다만 남음 (물패 없음)
          if (myGirudaForLead.isNotEmpty) {
            myGirudaForLead.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return myGirudaForLead.first;
          }
        }

        // 상대 기루다 없음 → 최상위 카드 우선, 마이티/조커는 나중에
        // 최상위 카드 (실효 가치 14 이상) 우선 사용
        final highestCards = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) &&
            _getEffectiveCardValue(c, state) >= 14).toList();
        if (highestCards.isNotEmpty) {
          // 비기루다 최상위 우선 (기루다는 아껴둠)
          final nonGirudaHighest = highestCards.where((c) =>
              c.suit != state.giruda).toList();
          if (nonGirudaHighest.isNotEmpty) {
            return nonGirudaHighest.first;
          }

          // ★ 최상위 카드가 전부 기루다일 때: 물패 전략 검토
          // 마이티/조커 없이 기루다만으로 선을 유지하면 기루다 소진 후 선을 잃음
          // → 비기루다 물패로 선을 넘기고, void 무늬에서 기루다 컷으로 탈환
          bool hasMightyOrJoker = playableCards.any((c) =>
              c.isJoker || c.isMightyWith(state.giruda));
          final nonGirudaAll = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();

          if (!hasMightyOrJoker && nonGirudaAll.isNotEmpty &&
              state.currentTrickNumber <= 8) {
            // 현재 void인 비기루다 무늬 수 계산 (기루다 컷 가능 횟수)
            Set<Suit> myNonGirudaSuits = {};
            for (final c in player.hand) {
              if (!c.isJoker && c.suit != null && c.suit != state.giruda) {
                myNonGirudaSuits.add(c.suit!);
              }
            }
            int nonGirudaSuitTotal = Suit.values.where((s) => s != state.giruda).length;
            int voidSuitCount = nonGirudaSuitTotal - myNonGirudaSuits.length;

            // 기루다 카드 수 vs 남은 트릭 수 비교
            final myGirudaCount = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).length;
            int remainingTricks = 10 - state.currentTrickNumber + 1;

            // 기루다만으로 끝까지 선 유지 불가 + void 무늬 있음 → 물패 전략
            if (myGirudaCount < remainingTricks && voidSuitCount > 0) {
              nonGirudaAll.sort((a, b) => a.rankValue.compareTo(b.rankValue));

              if (!state.friendRevealed) {
                // 프렌드 미공개: 9이하 → 10 → J 순
                final safeCards = nonGirudaAll.where((c) => c.rankValue <= 9).toList();
                if (safeCards.isNotEmpty) return safeCards.first;
                final tenCards = nonGirudaAll.where((c) => c.rank == Rank.ten).toList();
                if (tenCards.isNotEmpty) return tenCards.first;
                final jackCards = nonGirudaAll.where((c) => c.rank == Rank.jack).toList();
                if (jackCards.isNotEmpty) return jackCards.first;
                return nonGirudaAll.first;
              } else {
                // 프렌드 공개 후: 비점수 최저 우선
                final nonPointCards = nonGirudaAll.where((c) => !c.isPointCard).toList();
                if (nonPointCards.isNotEmpty) return nonPointCards.first;
                return nonGirudaAll.first;
              }
            }
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
        // ★ 단, 조커 프렌드일 때는 마이티 보존 (프렌드 조커가 마이티에 지지 않도록)
        if (state.currentTrickNumber >= 7) {
          final friendIsJokerHere = state.friendDeclaration?.card?.isJoker ?? false;
          final jokerPlayedHere = _getPlayedCards(state).any((c) => c.isJoker);
          // 조커 프렌드 + 조커가 아직 안 나왔으면 마이티 보존
          final shouldSaveMightyForJokerFriend = friendIsJokerHere &&
              player.isDeclarer &&
              !jokerPlayedHere;

          if (!shouldSaveMightyForJokerFriend) {
            final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
            if (mighty.isNotEmpty) {
              return mighty.first;
            }
          }
        }
      }
    }

    // === 노기루다 선공 전략 ===
    // 노기루다에서는 컷이 불가능하므로 선공 유지가 매우 중요
    // 최상위 카드(A)가 없으면 마이티/조커로 선공 확보 필요
    if (state.giruda == null) {
      bool isAttackTeam = !_isPlayerOnDefenseTeam(player, state);

      if (isAttackTeam) {
        // 각 무늬별 A 보유 여부 확인 (마이티 제외)
        final playedCards = _getPlayedCards(state);
        bool hasAnyAce = false;
        Suit? bestAceSuit;

        for (final suit in Suit.values) {
          // 마이티는 제외
          if (state.mighty.suit == suit && state.mighty.rank == Rank.ace) continue;

          bool hasAce = playableCards.any((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == suit && c.rank == Rank.ace);
          if (hasAce) {
            hasAnyAce = true;
            bestAceSuit = suit;
            break;
          }
        }

        if (hasAnyAce && bestAceSuit != null) {
          // A가 있으면 A로 선공 (확실한 승리)
          final aceCard = playableCards.firstWhere((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == bestAceSuit && c.rank == Rank.ace);
          return aceCard;
        }

        // A가 없으면 실효가치 14+ (현재 최상위) 카드 확인
        final topCards = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) &&
            _getEffectiveCardValue(c, state) >= 14).toList();

        if (topCards.isNotEmpty) {
          // 실효 최상위 카드가 있으면 사용
          return topCards.first;
        }

        // 최상위 카드가 없으면 마이티/조커로 선공 확보 필요
        // (선을 빼앗기면 점수 손실이 큼)

        // ★ 조커 사용 (프렌드가 마이티/조커인 경우에만)
        // 프렌드가 일반 카드인 경우 조커 선공 스킵 → 프렌드에게 선 넘기기 우선
        if (state.currentTrickNumber > 1 && state.currentTrickNumber < 10) {
          final friendCard = state.friendDeclaration?.card;
          bool friendIsSpecialCard = friendCard == null ||
              friendCard.isJoker || friendCard.isMightyWith(state.giruda);

          if (friendIsSpecialCard) {
            final joker = playableCards.where((c) => c.isJoker).toList();
            if (joker.isNotEmpty) {
              return joker.first;
            }
          }
        }

        // 마이티 사용 (조커가 없거나 이미 사용된 경우, 중반 이후)
        // ★ 단, 조커 프렌드일 때는 마이티 보존 (프렌드 조커가 마이티에 지지 않도록)
        if (state.currentTrickNumber >= 4) {
          final friendIsJokerHere = state.friendDeclaration?.card?.isJoker ?? false;
          final jokerPlayedHere = _getPlayedCards(state).any((c) => c.isJoker);
          // 조커 프렌드 + 조커가 아직 안 나왔으면 마이티 보존
          final shouldSaveMightyForJokerFriend = friendIsJokerHere &&
              player.isDeclarer &&
              !jokerPlayedHere;

          if (!shouldSaveMightyForJokerFriend) {
            final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
            if (mighty.isNotEmpty) {
              return mighty.first;
            }
          }
        }
      }
    }

    // ★★★ 마이티 선공 제한 (탈환용으로 보존) ★★★
    // 트릭 7 이전에는 마이티로 선공하지 않음 (마이티가 유일한 카드가 아닌 경우)
    // 마이티는 선공을 빼앗겼을 때 되찾기 위해 사용해야 함
    final nonMightyPlayable = playableCards.where((c) => !c.isMightyWith(state.giruda)).toList();

    // ★ 조커 프렌드일 때 마이티 선공 금지 전략 ★
    // 마이티를 선으로 내면 프렌드(조커)가 낭비됨
    final friendIsJoker = state.friendDeclaration?.card?.isJoker ?? false;

    // 조커가 이미 나갔는지 확인
    final playedCards = _getPlayedCards(state);
    final jokerAlreadyPlayed = playedCards.any((c) => c.isJoker) ||
        (state.currentTrick?.cards.any((c) => c.isJoker) ?? false);

    // ★★★ 조커 프렌드 + 조커가 아직 안 나왔으면 마이티 보존 ★★★
    // 조커에게 선을 넘겨서 프렌드가 조커로 이기게 하고, 이후 마이티 사용
    final shouldSaveMightyForJokerFriend = friendIsJoker &&
        player.isDeclarer &&
        !jokerAlreadyPlayed &&
        nonMightyPlayable.isNotEmpty;

    // ★★★ 조커 프렌드일 때: 프렌드(조커)에게 선 넘기기 전략 ★★★
    if (friendIsJoker && player.isDeclarer && !jokerAlreadyPlayed && nonMightyPlayable.isNotEmpty) {
      // 선유지 가능한 카드 확인 (실효가치 14 이상 = 현재 최상위)
      final topCards = nonMightyPlayable.where((c) =>
          !c.isJoker && _getEffectiveCardValue(c, state) >= 14).toList();

      // 상대에게 기루다가 남아있는지 확인
      final opponentGirudaRemaining = state.giruda != null ?
          _getRemainingGirudaCount(state, player) : 0;

      // === 케이스 1: 선유지 카드가 있고 + 상대 기루다가 없으면 ===
      // → 비기루다 중간 카드로 선공하여 상대 고카드 유도
      // → 조커가 이기고, 프렌드가 주공에게 선을 넘기고, 주공이 선유지 카드로 선 유지
      if (topCards.isNotEmpty && opponentGirudaRemaining == 0) {
        final nonGirudaCards = nonMightyPlayable.where((c) =>
            !c.isJoker && c.suit != state.giruda).toList();
        if (nonGirudaCards.length >= 2) {
          // 중간 카드 선택 (상대가 이기려고 높은 카드를 쓰게 유도)
          // 단, 선유지 카드(실효가치 14 이상)는 제외
          final midCards = nonGirudaCards.where((c) =>
              _getEffectiveCardValue(c, state) < 14).toList();
          if (midCards.isNotEmpty) {
            midCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            final midIdx = midCards.length ~/ 2;
            return midCards[midIdx];
          }
        }
        // 비기루다가 1장이면 그것 사용
        if (nonGirudaCards.isNotEmpty) {
          nonGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return nonGirudaCards.first;
        }
      }

      // === 케이스 2: 선유지 카드가 없으면 낮은 카드로 프렌드에게 선 넘기기 ===
      if (topCards.isEmpty) {
        // 상대에게 기루다가 있으면 → 낮은 기루다로 선공 (상대 기루다 소진 + 조커 승리)
        if (opponentGirudaRemaining > 0) {
          final lowGirudaCards = nonMightyPlayable.where((c) =>
              !c.isJoker && c.suit == state.giruda).toList();
          if (lowGirudaCards.isNotEmpty) {
            lowGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return lowGirudaCards.first;
          }
        }

        // 상대에게 기루다가 없거나 내 기루다가 없으면 → 비기루다 낮은 카드
        // 단, 비기루다가 모두 약하면(실효가치 < 12) 기루다로 확실히 이기기
        final nonGirudaLowCards = nonMightyPlayable.where((c) =>
            !c.isJoker && c.suit != state.giruda).toList();
        if (nonGirudaLowCards.isNotEmpty) {
          final bestNonGirudaValue = nonGirudaLowCards
              .map((c) => _getEffectiveCardValue(c, state))
              .reduce((a, b) => a > b ? a : b);
          final hasGiruda = nonMightyPlayable.any((c) =>
              !c.isJoker && c.suit == state.giruda);
          if (bestNonGirudaValue < 12 && hasGiruda) {
            // 비기루다가 약하고 기루다가 있으면 → 기루다로 승리 유지
            final girudaCards = nonMightyPlayable.where((c) =>
                !c.isJoker && c.suit == state.giruda).toList();
            girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return girudaCards.first;
          }
          nonGirudaLowCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return nonGirudaLowCards.first;
        }

        // 비기루다도 없으면 낮은 기루다
        final lowGirudaCards = nonMightyPlayable.where((c) =>
            !c.isJoker && c.suit == state.giruda).toList();
        if (lowGirudaCards.isNotEmpty) {
          lowGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return lowGirudaCards.first;
        }
      }
    }

    final shouldAvoidMighty = (state.currentTrickNumber < 7 || shouldSaveMightyForJokerFriend) &&
        nonMightyPlayable.isNotEmpty;
    final cardsToConsider = shouldAvoidMighty ? nonMightyPlayable : playableCards;

    // 상대에게 기루다가 남아있는지 확인
    final opponentHasGiruda = state.giruda != null &&
        _getRemainingGirudaCount(state, player) > 0;

    // ★★★ 주공 기루다 리드 전략 (2025.01 개선) ★★★
    // 기루다 최상위가 있으면 → 최상위로 확실히 승리
    // 기루다 최상위가 없으면 → 중간 기루다로 상대 고액 기루다 유도
    // 상대에게 기루다가 없으면 → 비기루다로 선공하여 기루다 보존
    if (state.giruda != null && player.isDeclarer) {
      final myGirudaCards = cardsToConsider.where((c) =>
          !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();

      if (myGirudaCards.isNotEmpty) {
        // 나간 기루다 + 내 손의 기루다 확인하여 최상위 기루다 보유 여부 판단
        final playedCards = _getPlayedCards(state);

        // 상대가 가진 기루다 중 가장 높은 것 찾기
        PlayingCard? highestOpponentGiruda;
        for (int rankVal = 14; rankVal >= 2; rankVal--) {
          final rank = Rank.values[rankVal - 2];
          bool inMyHand = player.hand.any((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) &&
              c.suit == state.giruda && c.rank == rank);
          bool alreadyPlayed = playedCards.any((c) =>
              !c.isJoker && c.suit == state.giruda && c.rank == rank);
          if (!inMyHand && !alreadyPlayed) {
            highestOpponentGiruda = PlayingCard(suit: state.giruda, rank: rank);
            break;
          }
        }

        // 내 기루다 중 가장 높은 것 찾기
        myGirudaCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
        final myHighestGiruda = myGirudaCards.first;

        if (highestOpponentGiruda == null) {
          // 상대에게 기루다가 없음 → 비기루다 중 이길 수 있는 카드가 있으면 사용
          // 비기루다가 약하면(실효가치 < 12) 기루다로 확실히 이기는 것이 나음
          final nonGirudaCards = cardsToConsider.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();

          if (nonGirudaCards.isNotEmpty) {
            nonGirudaCards.sort((a, b) =>
                _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
            // 비기루다 최고 카드가 이길 가능성이 있을 때만 사용
            if (_getEffectiveCardValue(nonGirudaCards.first, state) >= 12) {
              return nonGirudaCards.first;
            }
          }

          // 비기루다가 없거나 약하면 기루다 사용 (확실한 승리)
          return myHighestGiruda;
        } else if (myHighestGiruda.rankValue > highestOpponentGiruda.rankValue) {
          // 내 기루다가 상대 최상위보다 높음 → 확실히 이김 → 가장 높은 기루다 사용
          return myHighestGiruda;
        } else {
          // 내 기루다가 상대 최상위보다 낮음
          // ★ 조커가 있으면 조커로 기루다 콜 (확실히 이기면서 상대 기루다 소진)
          // 낮은 기루다를 내면 트릭+선공을 잃지만, 조커는 확실히 이김
          final jokerForGirudaCall = playableCards.where((c) => c.isJoker).toList();
          if (jokerForGirudaCall.isNotEmpty && state.currentTrickNumber >= 2) {
            return jokerForGirudaCall.first;
          }
          // ★ 마이티 무늬 공격: Mighty+Q 보유 & K 미출현 시
          // 낮은 mighty suit 카드로 K를 추출 → Q가 해당 무늬 최상위가 됨
          final mightySuit = state.mighty.suit;
          final hasMighty = playableCards.any((c) => c.isMightyWith(state.giruda));
          final hasMightyQ = playableCards.any((c) => !c.isJoker && c.suit == mightySuit && c.rank == Rank.queen);
          final mightyKPlayed = _getPlayedCards(state).any((c) => c.suit == mightySuit && c.rank == Rank.king);
          if (hasMighty && hasMightyQ && !mightyKPlayed) {
            // mighty suit에서 Mighty/Q 제외한 가장 낮은 카드
            final mightySuitLow = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) &&
                c.suit == mightySuit && c.rank != Rank.queen
            ).toList();
            if (mightySuitLow.isNotEmpty) {
              mightySuitLow.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return mightySuitLow.first;
            }
          }
          // ★ 부분 승리 기루다: 상대 최상위는 못 이기지만 2번째는 이기는 카드
          // 예: 상대 K,J → 내 Q는 J 이김. K 보유자가 기루다 void이면 승리
          // 비점수 기루다를 무작정 내는 것보다 승리 가능성 있는 카드 우선
          if (state.currentTrickNumber >= 4) {
            final opponentGirudaRanks = <int>[];
            for (int rv = 13; rv >= 2; rv--) {
              final rank = Rank.values[rv - 2];
              bool inMyHand = player.hand.any((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) &&
                  c.suit == state.giruda && c.rank == rank);
              bool alreadyPlayed = playedCards.any((c) =>
                  !c.isJoker && c.suit == state.giruda && c.rank == rank);
              if (!inMyHand && !alreadyPlayed) {
                opponentGirudaRanks.add(rv);
              }
            }

            if (opponentGirudaRanks.length >= 2) {
              final secondHighestRank = opponentGirudaRanks[1];
              final partialWinCards = myGirudaCards.where((c) =>
                  c.rankValue > secondHighestRank &&
                  c.rankValue < highestOpponentGiruda!.rankValue).toList();

              if (partialWinCards.isNotEmpty) {
                partialWinCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
                return partialWinCards.first;
              }
            }
          }
          // 조커 없으면 중간 기루다(비점수)로 상대 고액 유도
          // 너무 낮은 카드를 내면 상대가 A/K 대신 중간 카드로 이길 수 있음
          // 점수 카드가 아닌 중간 카드(9~2)로 선공하여 상대 고액 유도
          final nonPointGirudaCards = myGirudaCards.where((c) => !c.isPointCard).toList();
          if (nonPointGirudaCards.isNotEmpty) {
            // 비점수 카드 중 가장 높은 것 (9가 있으면 9, 없으면 8...)
            nonPointGirudaCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
            return nonPointGirudaCards.first;
          }
          // 비점수 기루다가 없으면 점수 카드 중 가장 낮은 것 (10)
          myGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return myGirudaCards.first;
        }
      }
    }

    // === 초반 공격팀 기루다 선 유지 우선 (상대 기루다 소진) ===
    // 초반(트릭 6 이하)에 기루다로 선 유지하면 상대 기루다를 소진시켜 후반 간 방지
    // 선 유지 가능한 기루다(실효가치 13+)가 있으면 비기루다보다 우선 사용
    if (state.giruda != null && state.currentTrickNumber <= 6 && opponentHasGiruda) {
      bool isAttackTeamHere = !_isPlayerOnDefenseTeam(player, state);
      if (isAttackTeamHere) {
        final girudaLeadCards = cardsToConsider.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda &&
            _getEffectiveCardValue(c, state) >= 13).toList();
        if (girudaLeadCards.isNotEmpty) {
          girudaLeadCards.sort((a, b) =>
              _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state)));
          return girudaLeadCards.first;
        }
      }
    }

    // 오픈된 카드를 고려하여 실효 가치가 높은 카드 선택
    cardsToConsider.sort((a, b) {
      // 마이티는 후순위 (탈환용으로 보존)
      if (a.isMightyWith(state.giruda)) return 1;
      if (b.isMightyWith(state.giruda)) return -1;

      // ★ 상대에게 기루다가 없으면 비기루다 우선 (기루다로 선공할 필요 없음)
      if (state.giruda != null && !opponentHasGiruda) {
        if (a.suit == state.giruda && b.suit != state.giruda) return 1;  // 기루다 후순위
        if (a.suit != state.giruda && b.suit == state.giruda) return -1; // 비기루다 우선
      } else if (state.giruda != null) {
        // 상대에게 기루다가 있으면 기존대로 기루다 우선
        if (a.suit == state.giruda && b.suit != state.giruda) return -1;
        if (a.suit != state.giruda && b.suit == state.giruda) return 1;
      }

      // 실효 가치 기준으로 정렬 (오픈된 카드 고려)
      return _getEffectiveCardValue(b, state).compareTo(_getEffectiveCardValue(a, state));
    });

    // 마이티/조커 제외한 카드 우선
    final nonJokerMighty =
        cardsToConsider.where((c) => !c.isJoker && !c.isMightyWith(state.giruda)).toList();
    if (nonJokerMighty.isNotEmpty) {
      return nonJokerMighty.first;
    }

    return cardsToConsider.first;
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

        // 주공이 이미 이기고 있으면 프렌드 카드 낭비 방지
        bool declarerAlreadyWinning = currentWinnerId != null &&
            state.players[currentWinnerId].isDeclarer;

        // 조건 1: 주공이 두 번째 순서에서 낮은 카드를 냈을 때 (신호)
        if (_declarerPlayedLowAsSecond(state) && !declarerAlreadyWinning) {
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

        // 조건 3: 주공 선공 + 프렌드 카드가 마이티/조커 → 선 확보 필수
        // 비프렌드 카드로 확실히 이기면 프렌드 카드 온존, 못 이기면 프렌드 카드 사용
        // 마이티/조커는 무늬 무관 강력 → 확실한 대안 없을 때의 최종 보장
        if (state.currentTrick!.playerOrder.isNotEmpty &&
            state.currentTrick!.playerOrder[0] == state.declarerId &&
            (friendCard.isJoker || friendCard.isMightyWith(state.giruda)) &&
            state.currentTrickNumber > 1) {
          final isLastInTrick =
              state.currentTrick!.cards.length == state.players.length - 1;
          final nonFriendCards = playableCards.where((c) => c != friendCard).toList();
          final nonFriendWinners = nonFriendCards.where((c) =>
              currentWinningCard != null &&
              state.isCardStronger(c, currentWinningCard, leadSuit, false)).toList();

          if (isLastInTrick && nonFriendWinners.isNotEmpty) {
            // 마지막 순서: 현재 승리 카드만 이기면 확실 → 최저 카드로 절약
            nonFriendWinners.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return nonFriendWinners.first;
          }

          if (!isLastInTrick && nonFriendWinners.isNotEmpty) {
            // 중간 순서: 후속 플레이어 위협 확인
            final allPlayed = _getPlayedCards(state);
            // 상대 특수 카드 소진 확인 (마이티 프렌드→조커, 조커 프렌드→마이티)
            bool opposingSpecialGone;
            if (friendCard.isMightyWith(state.giruda)) {
              opposingSpecialGone = allPlayed.any((c) => c.isJoker) ||
                  player.hand.any((c) => c.isJoker);
            } else {
              opposingSpecialGone = allPlayed.any((c) => c.isMightyWith(state.giruda)) ||
                  player.hand.any((c) => c.isMightyWith(state.giruda));
            }
            if (opposingSpecialGone) {
              // 기루다 A (최상위 기루다): 특수 카드 외 이길 카드 없으므로 확실 승리
              final girudaAce = nonFriendWinners.where((c) =>
                  c.suit == state.giruda && c.rankValue == 14 &&
                  !c.isMightyWith(state.giruda)).toList();
              if (girudaAce.isNotEmpty) {
                return girudaAce.first;
              }
              // 상대 기루다 소진 시 리드 무늬 A도 확실 승리 (기루다 컷 불가)
              if (state.giruda != null) {
                final opponentGirudaCount = _getRemainingGirudaCount(state, player);
                if (opponentGirudaCount == 0 && leadSuit != null) {
                  final leadSuitAce = nonFriendWinners.where((c) =>
                      c.suit == leadSuit && c.rankValue == 14 &&
                      !c.isMightyWith(state.giruda)).toList();
                  if (leadSuitAce.isNotEmpty) {
                    return leadSuitAce.first;
                  }
                }
              }
            }
          }

          // 확실한 대안 없음 → 프렌드 카드(마이티/조커)로 선 확보
          // ★ 단, 주공이 이미 이기고 있고 마지막 순서면 확실히 이기므로 낭비 방지
          // 마지막이 아니면 뒤 플레이어가 뒤집을 수 있으므로 프렌드 카드로 확보
          if ((!declarerAlreadyWinning || !isLastInTrick) &&
              currentWinningCard != null &&
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

    // === 주공이 프렌드의 낮은 기루다 선공을 받아야 할 때 ===
    // 프렌드가 낮은 기루다로 선공하면, 주공은 높은 기루다로 받아서 선을 가져가야 함
    if (player.isDeclarer &&
        state.friendRevealed &&
        state.currentTrick!.cards.length == 1 && // 두 번째로 카드를 냄
        state.giruda != null &&
        leadSuit == state.giruda) { // 프렌드가 기루다로 선공

      // 선공한 사람이 프렌드인지 확인
      final leaderId = state.currentTrick!.playerOrder.first;
      final leader = state.players.firstWhere((p) => p.id == leaderId);

      if (leader.isFriend && !leader.isDeclarer) {
        // 프렌드가 낮은 기루다로 선공한 경우 (7 이하면 낮은 카드로 간주)
        if (currentWinningCard != null &&
            currentWinningCard.rankValue <= 10 && // 10 이하면 주공에게 넘기려는 신호
            !currentWinningCard.isJoker &&
            !currentWinningCard.isMightyWith(state.giruda)) {

          // 기루다 카드 중 이길 수 있는 카드 찾기
          final girudaCards = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();

          if (girudaCards.isNotEmpty) {
            // 프렌드 카드보다 높고, 남은 기루다 중 상대가 이길 수 없는 카드 찾기
            final playedCards = _getPlayedCards(state);

            // 상대가 낼 수 있는 기루다 중 가장 높은 것 찾기
            PlayingCard? highestOpponentGiruda;
            for (int rankVal = 14; rankVal >= 2; rankVal--) {
              final rank = Rank.values[rankVal - 2];
              bool inMyHand = player.hand.any((c) =>
                  c.suit == state.giruda && c.rank == rank);
              bool alreadyPlayed = playedCards.any((c) =>
                  c.suit == state.giruda && c.rank == rank);
              bool inCurrentTrick = state.currentTrick!.cards.any((c) =>
                  c.suit == state.giruda && c.rank == rank);
              // 프렌드도 제외 (프렌드가 낸 카드는 이미 알고 있음)
              if (!inMyHand && !alreadyPlayed && !inCurrentTrick) {
                highestOpponentGiruda = PlayingCard(suit: state.giruda, rank: rank);
                break;
              }
            }

            // 상대 최고 기루다보다 높은 내 기루다 찾기
            if (highestOpponentGiruda != null) {
              final winningGirudas = girudaCards.where((c) =>
                  c.rankValue > highestOpponentGiruda!.rankValue).toList();

              if (winningGirudas.isNotEmpty) {
                // 이길 수 있는 기루다 중 가장 낮은 것 선택 (효율적)
                winningGirudas.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return winningGirudas.first;
              }
            }

            // 확실히 이길 수 없어도 프렌드 카드보다 높은 기루다로 시도
            final higherThanFriend = girudaCards.where((c) =>
                c.rankValue > currentWinningCard!.rankValue).toList();

            if (higherThanFriend.isNotEmpty) {
              // 가장 높은 기루다로 최선을 다해 이기려 시도
              higherThanFriend.sort((a, b) => b.rankValue.compareTo(a.rankValue));
              return higherThanFriend.first;
            }
          }

          // 기루다가 없거나 더 높은 기루다가 없으면 마이티/조커 사용
          final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
          if (mighty.isNotEmpty) {
            return mighty.first;
          }

          bool jokerCalled = state.currentTrick?.jokerCall == JokerCallType.jokerCall;
          if (!jokerCalled) {
            final joker = playableCards.where((c) => c.isJoker).toList();
            if (joker.isNotEmpty) {
              return joker.first;
            }
          }
        }
      }
    }

    // === 주공이 프렌드의 비기루다 선공을 받아야 할 때 ===
    // 프렌드가 낮은 비기루다로 선공하면, 주공은 기루다로 컷해서 선을 가져갈 수 있음
    if (player.isDeclarer &&
        state.friendRevealed &&
        state.currentTrick!.cards.length == 1 && // 두 번째로 카드를 냄
        state.giruda != null &&
        leadSuit != state.giruda) { // 프렌드가 비기루다로 선공

      // 선공한 사람이 프렌드인지 확인
      final leaderId = state.currentTrick!.playerOrder.first;
      final leader = state.players.firstWhere((p) => p.id == leaderId);

      if (leader.isFriend && !leader.isDeclarer) {
        // 프렌드가 낮은 비기루다로 선공한 경우 (10 이하면 선 넘기기 신호로 간주)
        if (currentWinningCard != null &&
            currentWinningCard.rankValue <= 10 &&
            !currentWinningCard.isJoker &&
            !currentWinningCard.isMightyWith(state.giruda)) {

          // 선공 무늬가 없어서 기루다로 컷 가능한지 확인
          final leadSuitCards = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();

          if (leadSuitCards.isEmpty) {
            // 선공 무늬가 없음 - 기루다로 컷 가능
            final girudaCards = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();

            if (girudaCards.isNotEmpty) {
              // 상대가 낼 수 있는 기루다 중 가장 높은 것 찾기
              final playedCards = _getPlayedCards(state);
              PlayingCard? highestOpponentGiruda;
              for (int rankVal = 14; rankVal >= 2; rankVal--) {
                final rank = Rank.values[rankVal - 2];
                bool inMyHand = player.hand.any((c) =>
                    c.suit == state.giruda && c.rank == rank);
                bool alreadyPlayed = playedCards.any((c) =>
                    c.suit == state.giruda && c.rank == rank);
                bool inCurrentTrick = state.currentTrick!.cards.any((c) =>
                    c.suit == state.giruda && c.rank == rank);
                // 프렌드도 제외
                if (!inMyHand && !alreadyPlayed && !inCurrentTrick) {
                  highestOpponentGiruda = PlayingCard(suit: state.giruda, rank: rank);
                  break;
                }
              }

              // ★ 후반(7트릭 이후)에는 선을 잡는 것이 중요
              // 현재 이기는 카드가 기루다가 아니면 낮은 기루다로 무조건 컷
              bool isLateGame = state.currentTrickNumber >= 7;
              bool currentWinnerIsNotGiruda = currentWinningCard.suit != state.giruda;

              if (isLateGame && currentWinnerIsNotGiruda) {
                girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return girudaCards.first;
              }

              // 초반/중반: 상대 최고 기루다보다 높은 내 기루다가 있으면 컷
              if (highestOpponentGiruda != null) {
                final winningGirudas = girudaCards.where((c) =>
                    c.rankValue > highestOpponentGiruda!.rankValue).toList();

                if (winningGirudas.isNotEmpty) {
                  // 이길 수 있는 기루다 중 가장 낮은 것 선택 (효율적)
                  winningGirudas.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                  return winningGirudas.first;
                }
              } else {
                // 상대에게 기루다가 없으면 낮은 기루다로 컷
                girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return girudaCards.first;
              }

              // 확실히 이길 수 없어도 프렌드 신호이므로 가장 높은 기루다로 컷
              // (프렌드가 약한 비기루다를 낸 것은 주공에게 선을 넘기려는 신호)
              girudaCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
              return girudaCards.first;
            }
          }
        }
      }
    }

    // === 같은 팀이 이기고 있을 때 낮은 카드 버리기 ===
    // 팀원이 이기고 있으면 높은 카드를 낭비하지 않고 낮은 카드를 버린다
    // ※ 조커/마이티 전략보다 먼저 체크해야 함
    bool myTeamWinning = (isAttackTeam && !defenseWinning) || (isDefenseTeam && defenseWinning);

    // 마지막 순서인지 확인 (4장이 이미 나온 경우)
    bool isLastPlayer = state.currentTrick != null &&
        state.currentTrick!.cards.length == 4;

    // ★ 마지막 순서일 때 공격팀 직접 확인 (기존 myTeamWinning 보완)
    // 현재 이기는 사람이 주공이거나 공개된 프렌드면 공격팀이 이기는 것
    if (isLastPlayer && isAttackTeam && currentWinnerId != null && !myTeamWinning) {
      final winner = state.players[currentWinnerId];
      bool attackTeamWinning = winner.isDeclarer ||
          (state.friendRevealed && winner.isFriend);
      if (attackTeamWinning) {
        myTeamWinning = true;
      }
    }

    // ★ 공격팀 프렌드: 마이티/조커 보유 시 미래 리드용 최상위 카드 보존
    // 마이티/조커로 선을 잡을 확률이 높으므로, 리드에 활용할 카드 보존
    // 예: 주공 ♣A 리드 → ♣K는 이후 실질 최상위 → 프렌드가 선 잡은 후 리드에 활용
    if (myTeamWinning && isAttackTeam && !player.isDeclarer && leadSuit != null) {
      bool hasLeadCaptureCard = player.hand.any((c) =>
          c.isJoker || c.isMightyWith(state.giruda));
      if (hasLeadCaptureCard) {
        final suitCards = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
        if (suitCards.length >= 2) {
          suitCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
          final highestMyCard = suitCards.first;
          // 현재 트릭 카드 포함하여 더 높은 카드가 모두 소진되었는지 확인
          final playedAll = _getPlayedCards(state);
          final trickCards = state.currentTrick?.cards ?? [];
          bool willBeTop = true;
          for (int rv = highestMyCard.rankValue + 1; rv <= 14; rv++) {
            final rank = Rank.values[rv - 2];
            bool accounted =
                playedAll.any((c) => c.suit == leadSuit && c.rank == rank) ||
                trickCards.any((c) => !c.isJoker && c.suit == leadSuit && c.rank == rank) ||
                player.hand.any((c) => c.suit == leadSuit && c.rank == rank);
            if (!accounted) {
              willBeTop = false;
              break;
            }
          }
          if (willBeTop) {
            // 최상위 카드 보존, 나머지 중 가장 낮은 카드 반환
            final lowerCards = suitCards.sublist(1);
            lowerCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            final nonPointLower = lowerCards.where((c) => !c.isPointCard).toList();
            if (nonPointLower.isNotEmpty) return nonPointLower.first;
            return lowerCards.first;
          }
        }
      }
    }

    if (myTeamWinning && currentWinningCard != null) {
      // 이기고 있는 카드가 최상위 카드인지 확인
      bool winningCardIsTop = false;

      // 마지막 순서이면 무조건 팀이 이김 (더 이상 뒤집힐 수 없음)
      if (isLastPlayer) {
        winningCardIsTop = true;
      } else if (currentWinningCard.isMightyWith(state.giruda)) {
        winningCardIsTop = true;
      } else if (currentWinningCard.isJoker) {
        // 조커는 마이티만 이길 수 있음
        bool mightyPlayed = _getPlayedCards(state).any((c) => c.isMightyWith(state.giruda));
        bool mightyInMyHand = player.hand.any((c) => c.isMightyWith(state.giruda));
        winningCardIsTop = mightyPlayed || mightyInMyHand ||
            !playableCards.any((c) => c.isMightyWith(state.giruda));
      } else if (currentWinningCard.suit == state.giruda && leadSuit == state.giruda) {
        // ★★★ 팀원이 기루다로 선공해서 이기고 있는 경우 ★★★
        // 상대에게 기루다가 없으면 확실히 이김
        final opponentGiruda = _getRemainingGirudaCount(state, player);
        if (opponentGiruda == 0) {
          winningCardIsTop = true;
        } else {
          // 상대에게 더 높은 기루다가 남아있는지 확인
          final playedCards = _getPlayedCards(state);
          int winningGirudaRank = currentWinningCard.rankValue;
          bool higherGirudaRemaining = false;
          for (int rankVal = winningGirudaRank + 1; rankVal <= 14; rankVal++) {
            final rank = Rank.values[rankVal - 2];
            bool inMyHand = player.hand.any((c) => c.suit == state.giruda && c.rank == rank);
            bool alreadyPlayed = playedCards.any((c) => c.suit == state.giruda && c.rank == rank);
            if (!inMyHand && !alreadyPlayed) {
              higherGirudaRemaining = true;
              break;
            }
          }
          if (!higherGirudaRemaining) {
            winningCardIsTop = true;
          }
        }
      } else if (currentWinningCard.suit == state.giruda && leadSuit != state.giruda) {
        // ★ 팀원이 기루다로 컷해서 이기고 있는 경우
        // ★★★ 상대에게 기루다가 없으면 확실히 이김 ★★★
        final opponentGiruda = _getRemainingGirudaCount(state, player);
        if (opponentGiruda == 0) {
          winningCardIsTop = true;
        } else {
          // 선공 무늬가 처음 나온 경우 간을 칠 확률이 낮으므로 마이티 아끼기
          final playedCards = _getPlayedCards(state);

          // 선공 무늬가 이번 게임에서 처음 나왔는지 확인
          bool leadSuitFirstTime = !playedCards.any((c) => c.suit == leadSuit);

          // 상대에게 더 높은 기루다가 남아있는지 확인
          int winningGirudaRank = currentWinningCard.rankValue;
          bool higherGirudaRemaining = false;
          for (int rankVal = winningGirudaRank + 1; rankVal <= 14; rankVal++) {
            final rank = Rank.values[rankVal - 2];
            bool inMyHand = player.hand.any((c) => c.suit == state.giruda && c.rank == rank);
            bool alreadyPlayed = playedCards.any((c) => c.suit == state.giruda && c.rank == rank);
            if (!inMyHand && !alreadyPlayed) {
              higherGirudaRemaining = true;
              break;
            }
          }

          // 선공 무늬가 처음이고 더 높은 기루다가 없으면 확실히 이김
          if (leadSuitFirstTime && !higherGirudaRemaining) {
            winningCardIsTop = true;
          }
          // 선공 무늬가 처음이면 간을 칠 확률이 낮으므로 마이티 아끼기
          else if (leadSuitFirstTime) {
            winningCardIsTop = true;
          }
        }
      } else {
        // 일반 카드: 더 높은 카드가 나올 수 있는지 확인
        final playedCards = _getPlayedCards(state);

        // 현재 이기는 카드를 이길 수 있는 카드들이 모두 내 손에 있거나 오픈되었는지 확인
        bool canBeBeaten = false;

        // 1. 마이티 체크 (마이티가 남아있으면 뒤집힐 수 있음)
        bool mightyInMyHand = player.hand.any((c) => c.isMightyWith(state.giruda));
        bool mightyPlayed = playedCards.any((c) => c.isMightyWith(state.giruda));
        if (!mightyInMyHand && !mightyPlayed) {
          canBeBeaten = true;
        }

        // 2. 조커 체크 (조커가 남아있으면 뒤집힐 수 있음)
        // ★ 트릭 1에서는 조커 사용 불가 → 위협 없음
        if (!canBeBeaten && state.currentTrickNumber > 1) {
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
        // 수비팀이고 조커를 가지고 있고 마이티에게 안전하면 점수카드 적극 사용
        bool aggressivePointDump = false;
        if (isDefenseTeam && defenseWinning && player.hand.any((c) => c.isJoker)) {
          bool mightyPlayed = _getPlayedCards(state).any((c) => c.isMightyWith(state.giruda));
          bool mightyInMyHand = player.hand.any((c) => c.isMightyWith(state.giruda));
          aggressivePointDump = mightyPlayed || mightyInMyHand;
        }

        // 리드 무늬가 있으면 리드 무늬 중 낮은 카드
        final suitCards = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
        if (suitCards.isNotEmpty) {
          suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));

          // 수비팀이 확실히 이기고 있으면 점수 카드 우선 (더 많은 점수 획득)
          if (isDefenseTeam && defenseWinning) {
            if (aggressivePointDump) {
              // 조커가 안전 → 모든 점수카드 적극 사용
              final pointCards = suitCards.where((c) => c.isPointCard).toList();
              if (pointCards.isNotEmpty) {
                pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return pointCards.first;
              }
            } else {
              // 조커가 없음 → 이길 확률 낮은 점수카드만
              final lowProbPointCards = suitCards.where((c) =>
                  c.isPointCard && _isLowWinProbabilityPointCard(c, player, state)).toList();
              if (lowProbPointCards.isNotEmpty) {
                lowProbPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return lowProbPointCards.first;
              }
            }
            // 점수카드가 없거나 보존 → 비점수카드 버리기
            final nonPointSuitCards = suitCards.where((c) => !c.isPointCard).toList();
            if (nonPointSuitCards.isNotEmpty) {
              nonPointSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return nonPointSuitCards.first;
            }
            // 점수카드만 있으면 낮은 것 버리기
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
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();

        // 수비팀이 확실히 이기고 있으면 점수 카드 우선 (더 많은 점수 획득)
        if (isDefenseTeam && defenseWinning && nonGirudaCards.isNotEmpty) {
          if (aggressivePointDump) {
            // 조커가 안전 → 모든 점수카드 적극 사용
            final pointCards = nonGirudaCards.where((c) => c.isPointCard).toList();
            if (pointCards.isNotEmpty) {
              pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return pointCards.first;
            }
          } else {
            // 조커가 없음 → 이길 확률 낮은 점수카드만
            final lowProbPointCards = nonGirudaCards.where((c) =>
                c.isPointCard && _isLowWinProbabilityPointCard(c, player, state)).toList();
            if (lowProbPointCards.isNotEmpty) {
              lowProbPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return lowProbPointCards.first;
            }
          }
        }

        final discardCard = _selectCardToDiscard(nonGirudaCards, player, state);
        if (discardCard != null) {
          return discardCard;
        }

        // 기루다만 있으면 낮은 기루다
        final girudaCards = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
        if (girudaCards.isNotEmpty) {
          // 수비팀이 확실히 이기고 있으면 점수 카드 우선
          if (isDefenseTeam && defenseWinning) {
            if (aggressivePointDump) {
              // 조커가 안전 → 모든 점수카드 적극 사용
              final pointGirudaCards = girudaCards.where((c) => c.isPointCard).toList();
              if (pointGirudaCards.isNotEmpty) {
                pointGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return pointGirudaCards.first;
              }
            } else {
              // 조커가 없음 → 이길 확률 낮은 점수카드만
              final lowProbPointGirudaCards = girudaCards.where((c) =>
                  c.isPointCard && _isLowWinProbabilityPointCard(c, player, state)).toList();
              if (lowProbPointGirudaCards.isNotEmpty) {
                lowProbPointGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return lowProbPointGirudaCards.first;
              }
            }
          }
          girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return girudaCards.first;
        }

        // 조커/마이티만 남았어도 팀이 이기고 있으므로 아무거나 내기
        // (조커/마이티 낭비 방지 - 아래 전략 섹션 도달 방지)
        final anyCard = playableCards.where((c) => !c.isJoker && !c.isMightyWith(state.giruda)).toList();
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
              !currentWinningCard.isJoker && !currentWinningCard.isMightyWith(state.giruda) &&
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
            // 단, 기루다가 아직 오픈되지 않았고 선공 무늬가 기루다가 아니면 컷 가능성 낮음
            bool girudaNotOpenedAndNotLeadSuit = !_hasGirudaBeenOpened(state) &&
                leadSuit != state.giruda;

            bool girudaCutPossible = remainingPlayers > 0 &&
                remainingLeadSuitCount < remainingPlayers &&
                !girudaNotOpenedAndNotLeadSuit;

            // ★ 후반(7-9트릭)에 수비팀이 기루다가 많으면 점수 카드 적극 전달
            // 마지막 트릭에서 수비팀이 이길 확률이 높으므로 미리 팀원에게 점수 전달
            if (state.giruda != null &&
                state.currentTrickNumber >= 7 && state.currentTrickNumber <= 9) {
              final opponentGiruda = _getRemainingGirudaCount(state, player);
              final myGirudaCards = player.hand.where((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
              final myGirudaCount = myGirudaCards.length;

              // 수비팀 기루다가 내 기루다보다 많으면 마지막에 수비팀이 이길 확률 높음
              if (opponentGiruda > myGirudaCount) {
                // 팀원이 이기고 있으면 (확실하지 않아도) 점수 카드 전달
                // 리드 무늬 점수 카드가 있으면 주기
                final suitCards = playableCards.where((c) =>
                    !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
                if (suitCards.isNotEmpty) {
                  final suitPointCards = suitCards.where((c) => c.isPointCard).toList();
                  if (suitPointCards.isNotEmpty) {
                    suitPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                    return suitPointCards.first;
                  }
                }
                // 리드 무늬가 없으면 비기루다 점수 카드 주기
                final nonGirudaCards = playableCards.where((c) =>
                    !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
                if (nonGirudaCards.isNotEmpty) {
                  final nonGirudaPointCards = nonGirudaCards.where((c) => c.isPointCard).toList();
                  if (nonGirudaPointCards.isNotEmpty) {
                    nonGirudaPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                    return nonGirudaPointCards.first;
                  }
                }
              }
            }

            // 팀원이 확실히 이기는지 확인
            // 1. 기루다 컷 가능성이 없고
            // 2. 상대가 낼 수 있는 리드 무늬 최강보다 팀원 카드가 높으면 확실히 이김
            bool teammateWinningSecurely = !girudaCutPossible &&
                (highestRemainingLeadSuit == null ||
                 currentWinningCard.rankValue > highestRemainingLeadSuit.rankValue);

            if (teammateWinningSecurely) {
              // ★ 팀원이 확실히 이기면 이길 수 없는 점수 카드를 줘서 점수 늘리기
              final suitCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
              if (suitCards.isNotEmpty) {
                // 이기는 카드보다 낮은 점수 카드 찾기 (이길 수 없는 점수 카드)
                final losingPointCards = suitCards.where((c) =>
                    c.isPointCard && c.rankValue < currentWinningCard.rankValue).toList();
                if (losingPointCards.isNotEmpty) {
                  // 점수 카드 중 가장 낮은 것 (10 우선)
                  losingPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                  return losingPointCards.first;
                }
                // 점수 카드가 없거나 이길 수 있는 점수 카드뿐이면 낮은 비점수 카드
                suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                final nonPointCards = suitCards.where((c) => !c.isPointCard).toList();
                if (nonPointCards.isNotEmpty) {
                  return nonPointCards.first;
                }
                return suitCards.first;
              }
              // 리드 무늬가 없으면 비기루다 중 점수 카드 주기 (어차피 이길 수 없음)
              final nonGirudaCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
              if (nonGirudaCards.isNotEmpty) {
                // 비기루다 점수 카드가 있으면 팀원에게 주기
                final pointCards = nonGirudaCards.where((c) => c.isPointCard).toList();
                if (pointCards.isNotEmpty) {
                  pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                  return pointCards.first;
                }
                // 점수 카드가 없으면 낮은 카드
                nonGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return nonGirudaCards.first;
              }
              // 기루다만 있으면 낮은 기루다
              final girudaCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
              if (girudaCards.isNotEmpty) {
                girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return girudaCards.first;
              }
            } else if (highestRemainingLeadSuit != null) {
              // 팀원이 역전될 수 있으면 리드 무늬 내에서 보조
              // 상대 최강보다 높은 리드 무늬 카드 찾기
              final highestRemaining = highestRemainingLeadSuit;
              final strongerLeadSuitCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit &&
                  c.rankValue > highestRemaining.rankValue).toList();

              if (strongerLeadSuitCards.isNotEmpty) {
                // 이길 수 있는 카드 중 가장 낮은 것 선택
                strongerLeadSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return strongerLeadSuitCards.first;
              }

              // 팀원이 약한 카드를 냈고 리드 무늬로 이길 수 없을 때
              // 조커나 마이티로 트릭을 가져오기
              // ★ 단, 마지막 순서면 어차피 팀원이 이기므로 조커/마이티 낭비 방지
              bool isLastPlayerHere = state.currentTrick != null &&
                  state.currentTrick!.cards.length == 4;
              // 기루다 선공 시 상대에게 더 높은 기루다가 남아있으면 마이티/조커로 지원
              // (주공이 프렌드를 믿고 기루다를 냈으므로 뒤집히지 않게 보호)
              bool girudaLeadAtRisk = leadSuit == state.giruda &&
                  highestRemaining.rankValue > currentWinningCard.rankValue;
              if ((currentWinningCard.rankValue <= 7 || girudaLeadAtRisk) && !isLastPlayerHere) {
                // ★ 0점 트릭에서는 조커/마이티 낭비 방지 → 보유 기루다로 팔로우
                // 주공이 낮은 기루다로 선 넘기기 → 높은 기루다 카드로 충분
                // 단, 최고 기루다가 현재 이기는 카드보다 높을 때만 (이길 수 없으면 낭비)
                int currentPointCards = state.currentTrick!.cards
                    .where((c) => c.isPointCard || c.isJoker).length;
                if (currentPointCards == 0) {
                  final girudaFollowCards = playableCards.where((c) =>
                      !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
                  if (girudaFollowCards.isNotEmpty) {
                    girudaFollowCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));
                    // 최고 기루다가 현재 이기는 카드를 이길 수 있을 때만 사용
                    if (girudaFollowCards.first.rankValue > currentWinningCard.rankValue) {
                      return girudaFollowCards.first;
                    }
                    // 이길 수 없으면 → 높은 카드 낭비 방지, 아래 폴백(최저 카드)으로
                  }
                }
                // 마이티가 있으면 사용 (조커보다 강함)
                final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
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

              // 리드 무늬가 있으면 낮은 카드 버리기
              final suitCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
              if (suitCards.isNotEmpty) {
                suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                final nonPointCards = suitCards.where((c) => !c.isPointCard).toList();
                if (nonPointCards.isNotEmpty) {
                  return nonPointCards.first;
                }
                return suitCards.first;
              }

              // ★ 리드 무늬가 없고 팀원이 약한 카드로 이기고 있으면 기루다로 컷하여 선 탈환
              // 후반(7트릭+)이거나, 프렌드가 약한 카드로 선공한 경우 (선 넘기기 신호)
              if (state.giruda != null && currentWinningCard.suit != state.giruda) {
                bool isLateGameHere = state.currentTrickNumber >= 7;
                // 프렌드가 선공한 약한 카드인지 확인
                bool friendLedWeak = false;
                if (state.currentTrick != null && state.currentTrick!.playerOrder.isNotEmpty) {
                  final leaderId2 = state.currentTrick!.playerOrder.first;
                  final leader2 = state.players[leaderId2];
                  friendLedWeak = state.friendRevealed &&
                      leader2.isFriend && !leader2.isDeclarer &&
                      currentWinningCard.rankValue <= 10;
                }

                if (isLateGameHere || friendLedWeak) {
                  final girudaCardsForCut = playableCards.where((c) =>
                      !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
                  if (girudaCardsForCut.isNotEmpty) {
                    girudaCardsForCut.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                    return girudaCardsForCut.first;
                  }
                }
              }

              // 초반/중반: 리드 무늬가 없으면 비기루다 중 낮은 카드 버리기 (간 방지)
              final nonGirudaCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
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
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
              if (girudaCards.isNotEmpty) {
                girudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return girudaCards.first;
              }
            } else {
              // 기루다 컷 가능성이 있지만 리드 무늬 카드가 다 나간 경우
              // 팀원이 이기고 있으므로 낮은 카드 버리기 (간 방지)
              final suitCards = playableCards.where((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
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
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
              if (nonGirudaCards.isNotEmpty) {
                nonGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                final nonPointCards = nonGirudaCards.where((c) => !c.isPointCard).toList();
                if (nonPointCards.isNotEmpty) {
                  return nonPointCards.first;
                }
                return nonGirudaCards.first;
              }
              // 기루다만 있으면 낮은 기루다
              final girudaCards2 = playableCards.where((c) =>
                  !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
              if (girudaCards2.isNotEmpty) {
                girudaCards2.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return girudaCards2.first;
              }
            }
          } else {
            // 팀원이 기루다 컷, 마이티, 또는 조커로 이기고 있을 때
            bool isGirudaCut = !currentWinningCard.isJoker &&
                !currentWinningCard.isMightyWith(state.giruda) &&
                currentWinningCard.suit == state.giruda &&
                leadSuit != state.giruda;

            if (isGirudaCut) {
              // === 기루다 컷 역전 가능성 분석 ===
              final playedCards = _getPlayedCards(state);
              int remainingPlayers = 5 - state.currentTrick!.cards.length - 1;

              // 1. 상대에게 더 높은 기루다가 남아있는지 확인
              int winningGirudaRank = currentWinningCard.rankValue;
              int higherGirudaCount = 0;
              for (int rankVal = winningGirudaRank + 1; rankVal <= 14; rankVal++) {
                final rank = Rank.values[rankVal - 2];
                bool inMyHand = player.hand.any((c) =>
                    c.suit == state.giruda && c.rank == rank);
                bool alreadyPlayed = playedCards.any((c) =>
                    c.suit == state.giruda && c.rank == rank);
                bool inCurrentTrick = state.currentTrick!.cards.any((c) =>
                    !c.isJoker && c.suit == state.giruda && c.rank == rank);
                if (!inMyHand && !alreadyPlayed && !inCurrentTrick) {
                  higherGirudaCount++;
                }
              }

              // 2. 리드 무늬의 남은 카드 수 확인 (상대가 보유할 수 있는 리드 무늬)
              int openedLeadSuitCount =
                  playedCards.where((c) => c.suit == leadSuit).length +
                  player.hand.where((c) => c.suit == leadSuit).length +
                  state.currentTrick!.cards.where((c) =>
                      !c.isJoker && c.suit == leadSuit).length;
              int remainingLeadSuitCount = 13 - openedLeadSuitCount;

              // 역전 위험도 판단:
              // - 뒤에 남은 플레이어가 있고
              // - 상대에게 더 높은 기루다가 있고
              // - 리드 무늬가 부족하여 상대가 리드 무늬를 못 내고 기루다를 낼 수 있으면 위험
              bool overcutRisk = remainingPlayers > 0 &&
                  higherGirudaCount > 0 &&
                  remainingLeadSuitCount < remainingPlayers;

              if (overcutRisk) {
                // 역전 위험이 있으면 더 높은 기루다로 오버컷하여 보조
                final myHigherGiruda = playableCards.where((c) =>
                    !c.isJoker && !c.isMightyWith(state.giruda) &&
                    c.suit == state.giruda &&
                    c.rankValue > currentWinningCard.rankValue).toList();
                if (myHigherGiruda.isNotEmpty) {
                  // 이길 수 있는 기루다 중 가장 낮은 것 (자원 절약)
                  myHigherGiruda.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                  return myHigherGiruda.first;
                }
                // 더 높은 기루다가 없으면 아래에서 낮은 카드 버리기
              }
            }

            // 역전 위험이 없거나, 마이티/조커로 이기고 있거나, 보조할 카드가 없으면
            // → 낮은 카드 버리기 (조커/마이티 낭비 방지)
            final suitCardsElse = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
            if (suitCardsElse.isNotEmpty) {
              final pointCards = suitCardsElse.where((c) => c.isPointCard).toList();
              if (pointCards.isNotEmpty) {
                pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return pointCards.first;
              }
              suitCardsElse.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return suitCardsElse.first;
            }
            // 리드 무늬가 없으면 비기루다 중 낮은 카드 버리기
            final nonGirudaCardsElse = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
            if (nonGirudaCardsElse.isNotEmpty) {
              final pointCards = nonGirudaCardsElse.where((c) => c.isPointCard).toList();
              if (pointCards.isNotEmpty) {
                pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return pointCards.first;
              }
              nonGirudaCardsElse.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return nonGirudaCardsElse.first;
            }
            // 기루다만 있으면 낮은 기루다
            final girudaCardsElse = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
            if (girudaCardsElse.isNotEmpty) {
              girudaCardsElse.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return girudaCardsElse.first;
            }
          }
        } else if (isDefenseTeam) {
          // === 수비팀: 팀원이 이기고 있지만 확실하지 않을 때 ===
          // 프렌드 공개 여부에 따라 전략 분기
          final suitCardsDef = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();

          if (!state.friendRevealed) {
            // ★ 프렌드 미공개: 프렌드 카드(A/마이티/조커)가 뒤집을 수 있음
            // → 점수카드 낭비 방지, 낮은 비점수 카드 우선
            if (suitCardsDef.isNotEmpty) {
              suitCardsDef.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              final nonPointCards = suitCardsDef.where((c) => !c.isPointCard).toList();
              if (nonPointCards.isNotEmpty) {
                return nonPointCards.first;
              }
              return suitCardsDef.first;
            }
            final nonGirudaCardsDef = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
            if (nonGirudaCardsDef.isNotEmpty) {
              nonGirudaCardsDef.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              final nonPointCards = nonGirudaCardsDef.where((c) => !c.isPointCard).toList();
              if (nonPointCards.isNotEmpty) {
                return nonPointCards.first;
              }
              return nonGirudaCardsDef.first;
            }
            final girudaCardsDef = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
            if (girudaCardsDef.isNotEmpty) {
              girudaCardsDef.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return girudaCardsDef.first;
            }
          } else {
            // ★ 프렌드 공개 후: 위협 해소, 물패 가능성 높음
            // → 점수카드 적극 덤프하여 수비 점수 극대화
            if (suitCardsDef.isNotEmpty) {
              suitCardsDef.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              final pointCards = suitCardsDef.where((c) =>
                  c.isPointCard && _isLowWinProbabilityPointCard(c, player, state)).toList();
              if (pointCards.isNotEmpty) {
                pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return pointCards.first;
              }
              final nonPointCards = suitCardsDef.where((c) => !c.isPointCard).toList();
              if (nonPointCards.isNotEmpty) {
                return nonPointCards.first;
              }
              return suitCardsDef.first;
            }
            final nonGirudaCardsDef = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
            if (nonGirudaCardsDef.isNotEmpty) {
              nonGirudaCardsDef.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              final pointCards = nonGirudaCardsDef.where((c) =>
                  c.isPointCard && _isLowWinProbabilityPointCard(c, player, state)).toList();
              if (pointCards.isNotEmpty) {
                pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
                return pointCards.first;
              }
              final nonPointCards = nonGirudaCardsDef.where((c) => !c.isPointCard).toList();
              if (nonPointCards.isNotEmpty) {
                return nonPointCards.first;
              }
              return nonGirudaCardsDef.first;
            }
            final girudaCardsDef = playableCards.where((c) =>
                !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
            if (girudaCardsDef.isNotEmpty) {
              girudaCardsDef.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return girudaCardsDef.first;
            }
          }
        }
      }
    }

    // === 같은 팀이 조커로 이기고 있을 때 ===
    // 팀원이 조커로 이기고 있으면:
    // - 마이티에게 질 가능성이 낮으면 점수 카드를 내서 수비 점수 극대화 (언 방지)
    // - 마이티에게 질 가능성이 있으면 낮은 카드 버리기
    if (currentWinningCard != null && currentWinningCard.isJoker) {
      bool teammateWinningWithJoker = (isAttackTeam && !defenseWinning) ||
          (isDefenseTeam && defenseWinning);

      if (teammateWinningWithJoker) {
        // 마이티가 조커를 이길 가능성 판단
        final playedCards = _getPlayedCards(state);
        bool mightyPlayed = playedCards.any((c) => c.isMightyWith(state.giruda));
        bool mightyInMyHand = player.hand.any((c) => c.isMightyWith(state.giruda));
        bool isLastPlayerJoker = state.currentTrick != null &&
            state.currentTrick!.cards.length == 4;
        // 마이티가 이미 나왔거나, 내 손에 있거나, 마지막 순서이면 조커가 안전
        bool jokerIsSafe = mightyPlayed || mightyInMyHand || isLastPlayerJoker;

        // 수비팀이고 조커가 안전하면 점수 카드 우선 (공격팀 언 방지)
        bool dumpPointCards = isDefenseTeam && defenseWinning && jokerIsSafe;

        // 선공 무늬가 있으면
        final suitCardsTeamJoker = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
        if (suitCardsTeamJoker.isNotEmpty) {
          suitCardsTeamJoker.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          if (dumpPointCards) {
            // 점수 카드 우선 (낮은 점수 카드부터)
            final pointCards = suitCardsTeamJoker.where((c) => c.isPointCard).toList();
            if (pointCards.isNotEmpty) {
              pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return pointCards.first;
            }
          }
          final nonPointCards = suitCardsTeamJoker.where((c) => !c.isPointCard).toList();
          if (nonPointCards.isNotEmpty) {
            return nonPointCards.first;
          }
          return suitCardsTeamJoker.first;
        }
        // 선공 무늬가 없으면 비기루다 중
        final nonGirudaTeamJoker = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
        if (nonGirudaTeamJoker.isNotEmpty) {
          nonGirudaTeamJoker.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          if (dumpPointCards) {
            final pointCards = nonGirudaTeamJoker.where((c) => c.isPointCard).toList();
            if (pointCards.isNotEmpty) {
              pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return pointCards.first;
            }
          }
          final nonPointCards = nonGirudaTeamJoker.where((c) => !c.isPointCard).toList();
          if (nonPointCards.isNotEmpty) {
            return nonPointCards.first;
          }
          return nonGirudaTeamJoker.first;
        }
        // 기루다만 있으면 가장 낮은 기루다 (점수 카드 여부 확인)
        final girudaTeamJoker = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
        if (girudaTeamJoker.isNotEmpty) {
          girudaTeamJoker.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          if (dumpPointCards) {
            final pointCards = girudaTeamJoker.where((c) => c.isPointCard).toList();
            if (pointCards.isNotEmpty) {
              pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return pointCards.first;
            }
          }
          return girudaTeamJoker.first;
        }
      }
    }

    // === 상대팀 조커에 대한 마이티 대응 ===
    // 상대팀이 조커로 이기려 할 때 마이티로 선공 탈환
    if (currentWinningCard != null && currentWinningCard.isJoker) {
      // 상대팀이 조커로 이기고 있는지 확인
      bool opponentWinningWithJoker = (isAttackTeam && defenseWinning) ||
          (isDefenseTeam && !defenseWinning);

      if (opponentWinningWithJoker) {
        // 현재 트릭의 점수 카드 수 계산
        int pointCardsInTrick = state.currentTrick!.cards
            .where((c) => c.isPointCard || c.isJoker).length;

        // ★ 노프렌드 주공은 선공 유지가 중요하므로 점수 카드 1장 이상이면 마이티 사용
        // ★ 그 외에는 점수 카드 2장 이상이면 마이티 사용
        bool isNoFriend = state.friendDeclaration?.isNoFriend == true;
        int requiredPointCards = (player.isDeclarer && isNoFriend) ? 1 : 2;

        if (pointCardsInTrick >= requiredPointCards) {
          final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
          if (mighty.isNotEmpty) {
            return mighty.first;
          }
        }

        // ★ 마이티가 없으면 조커를 이길 수 없음 - 낮은 카드 버리기
        // 선공 무늬가 있으면 선공 무늬 중 낮은 카드
        final suitCardsForJoker = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
        if (suitCardsForJoker.isNotEmpty) {
          suitCardsForJoker.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          final nonPointCards = suitCardsForJoker.where((c) => !c.isPointCard).toList();
          if (nonPointCards.isNotEmpty) {
            return nonPointCards.first;
          }
          return suitCardsForJoker.first;
        }
        // 선공 무늬가 없으면 비기루다 중 낮은 카드
        final nonGirudaForJoker = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
        if (nonGirudaForJoker.isNotEmpty) {
          nonGirudaForJoker.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          final nonPointCards = nonGirudaForJoker.where((c) => !c.isPointCard).toList();
          if (nonPointCards.isNotEmpty) {
            return nonPointCards.first;
          }
          return nonGirudaForJoker.first;
        }
        // 기루다만 있으면 가장 낮은 기루다
        final girudaForJoker = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
        if (girudaForJoker.isNotEmpty) {
          girudaForJoker.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return girudaForJoker.first;
        }
      }
    }

    // === 같은 팀이 마이티로 이기고 있을 때 ===
    // 마이티는 무적이므로 수비팀은 점수 카드를 내서 점수 극대화 (공격팀 언 방지)
    if (currentWinningCard != null && currentWinningCard.isMightyWith(state.giruda)) {
      bool teammateWinningWithMighty = (isAttackTeam && !defenseWinning) ||
          (isDefenseTeam && defenseWinning);

      if (teammateWinningWithMighty) {
        // 수비팀이면 점수 카드 우선 (마이티는 무적이므로 항상 안전)
        bool dumpPointCards = isDefenseTeam && defenseWinning;

        // 선공 무늬가 있으면
        final suitCardsTeamMighty = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
        if (suitCardsTeamMighty.isNotEmpty) {
          suitCardsTeamMighty.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          if (dumpPointCards) {
            final pointCards = suitCardsTeamMighty.where((c) => c.isPointCard).toList();
            if (pointCards.isNotEmpty) {
              pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return pointCards.first;
            }
          }
          final nonPointCards = suitCardsTeamMighty.where((c) => !c.isPointCard).toList();
          if (nonPointCards.isNotEmpty) {
            return nonPointCards.first;
          }
          return suitCardsTeamMighty.first;
        }
        // 선공 무늬가 없으면 비기루다 중
        final nonGirudaTeamMighty = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
        if (nonGirudaTeamMighty.isNotEmpty) {
          nonGirudaTeamMighty.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          if (dumpPointCards) {
            final pointCards = nonGirudaTeamMighty.where((c) => c.isPointCard).toList();
            if (pointCards.isNotEmpty) {
              pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return pointCards.first;
            }
          }
          final nonPointCards = nonGirudaTeamMighty.where((c) => !c.isPointCard).toList();
          if (nonPointCards.isNotEmpty) {
            return nonPointCards.first;
          }
          return nonGirudaTeamMighty.first;
        }
        // 기루다만 있으면
        final girudaTeamMighty = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
        if (girudaTeamMighty.isNotEmpty) {
          girudaTeamMighty.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          if (dumpPointCards) {
            final pointCards = girudaTeamMighty.where((c) => c.isPointCard).toList();
            if (pointCards.isNotEmpty) {
              pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return pointCards.first;
            }
          }
          return girudaTeamMighty.first;
        }
      }
    }

    // === 상대팀 마이티에 대한 대응 ===
    // 마이티가 이기고 있으면 아무도 이길 수 없음 - 낮은 카드 버리기
    if (currentWinningCard != null && currentWinningCard.isMightyWith(state.giruda)) {
      bool opponentWinningWithMighty = (isAttackTeam && defenseWinning) ||
          (isDefenseTeam && !defenseWinning);

      if (opponentWinningWithMighty) {
        // 선공 무늬가 있으면 선공 무늬 중 낮은 카드
        final suitCardsForMighty = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
        if (suitCardsForMighty.isNotEmpty) {
          suitCardsForMighty.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          final nonPointCards = suitCardsForMighty.where((c) => !c.isPointCard).toList();
          if (nonPointCards.isNotEmpty) {
            return nonPointCards.first;
          }
          return suitCardsForMighty.first;
        }
        // 선공 무늬가 없으면 비기루다 중 낮은 카드
        final nonGirudaForMighty = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
        if (nonGirudaForMighty.isNotEmpty) {
          nonGirudaForMighty.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          final nonPointCards = nonGirudaForMighty.where((c) => !c.isPointCard).toList();
          if (nonPointCards.isNotEmpty) {
            return nonPointCards.first;
          }
          return nonGirudaForMighty.first;
        }
        // 기루다만 있으면 가장 낮은 기루다
        final girudaForMighty = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
        if (girudaForMighty.isNotEmpty) {
          girudaForMighty.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return girudaForMighty.first;
        }
      }
    }

    // === 수비팀이 이기고 있고 조커 보유 시 점수 카드 적극 사용 ===
    // 조커/마이티가 아닌 카드로 이기고 있지만, 조커를 가지고 있고 마이티에게 안전하면
    // 점수 카드를 적극 사용하여 공격팀 언 방지
    if (isDefenseTeam && defenseWinning && player.hand.any((c) => c.isJoker)) {
      bool mightyAlreadyPlayed = _getPlayedCards(state).any((c) => c.isMightyWith(state.giruda));
      bool mightyInMyHand = player.hand.any((c) => c.isMightyWith(state.giruda));
      bool jokerSafeFromMighty = mightyAlreadyPlayed || mightyInMyHand;

      if (jokerSafeFromMighty) {
        // 선공 무늬가 있으면 점수 카드 우선
        final suitCardsJokerHold = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
        if (suitCardsJokerHold.isNotEmpty) {
          final pointCards = suitCardsJokerHold.where((c) => c.isPointCard).toList();
          if (pointCards.isNotEmpty) {
            pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return pointCards.first;
          }
          suitCardsJokerHold.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return suitCardsJokerHold.first;
        }
        // 선공 무늬가 없으면 비기루다 중 점수 카드 우선
        final nonGirudaJokerHold = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
        if (nonGirudaJokerHold.isNotEmpty) {
          final pointCards = nonGirudaJokerHold.where((c) => c.isPointCard).toList();
          if (pointCards.isNotEmpty) {
            pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return pointCards.first;
          }
          nonGirudaJokerHold.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return nonGirudaJokerHold.first;
        }
        // 기루다만 있으면 점수 카드 우선
        final girudaJokerHold = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
        if (girudaJokerHold.isNotEmpty) {
          final pointCards = girudaJokerHold.where((c) => c.isPointCard).toList();
          if (pointCards.isNotEmpty) {
            pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return pointCards.first;
          }
          girudaJokerHold.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return girudaJokerHold.first;
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
          if (currentWinningCard == null || !currentWinningCard.isMightyWith(state.giruda)) {
            // 조커콜 상태가 아닐 때만 사용
            bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
            if (!jokerCalled) {
              // 같은 팀이 확실히 이기고 있는지 확인
              bool teamWinningSecurely = false;
              if (!defenseWinning && currentWinningCard != null) {
                // 공격팀이 이기고 있을 때, 이기는 카드가 최상위인지 확인
                if (currentWinningCard.isMightyWith(state.giruda)) {
                  teamWinningSecurely = true;
                } else if (currentWinningCard.isJoker) {
                  teamWinningSecurely = true;
                } else {
                  // 실효 가치 14 이상(A급)이면 확실히 이김
                  int effectiveValue = _getEffectiveCardValue(currentWinningCard, state);
                  if (effectiveValue >= 14) {
                    teamWinningSecurely = true;
                  }
                  // ★ 선공 무늬가 기루다이고 상대에게 기루다가 없으면 확실히 이김
                  if (!teamWinningSecurely && leadSuit == state.giruda) {
                    final opponentGiruda = _getRemainingGirudaCount(state, player);
                    if (opponentGiruda == 0) {
                      teamWinningSecurely = true;
                    }
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
          if (currentWinningCard == null || !currentWinningCard.isMightyWith(state.giruda)) {
            bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
            if (!jokerCalled) {
              // 같은 팀이 확실히 이기고 있는지 확인
              bool teamWinningSecurely = false;
              if (!defenseWinning && currentWinningCard != null) {
                if (currentWinningCard.isMightyWith(state.giruda) || currentWinningCard.isJoker) {
                  teamWinningSecurely = true;
                } else {
                  int effectiveValue = _getEffectiveCardValue(currentWinningCard, state);
                  if (effectiveValue >= 14) {
                    teamWinningSecurely = true;
                  }
                  // ★ 선공 무늬가 기루다이고 상대에게 기루다가 없으면 확실히 이김
                  if (!teamWinningSecurely && leadSuit == state.giruda && remainingGiruda == 0) {
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
    // 공격팀(주공/프렌드)이 후공에서 수비팀에 지고 있을 때
    // 1. 선공카드 보유: 이기면 최소 승리, 못 이기면 조커/마이티, 없으면 최하위
    // 2. 선공카드 미보유: 기루다 최소 승리, 못 이기면 조커/마이티, 없으면 물패 버림
    if (isAttackTeam && defenseWinning) {
      bool isLastPlayer = state.currentTrick != null &&
          state.currentTrick!.cards.length == 4;
      int pointCardsInTrick = state.currentTrick!.cards
          .where((c) => c.isPointCard || c.isJoker).length;
      bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
      bool winningIsMighty = currentWinningCard != null &&
          currentWinningCard.isMightyWith(state.giruda);
      // ★ 마지막 순서 + 트릭에 점수카드 없음 → 조커/마이티 아끼기
      bool saveSpecialCards = isLastPlayer && pointCardsInTrick == 0;

      final leadSuitCards = playableCards.where((c) =>
          !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();

      if (leadSuitCards.isNotEmpty) {
        // === 1. 선공카드 보유 ===

        // 1a. 선공 무늬로 이길 수 있으면 → 최소 이기는 카드
        if (currentWinningCard != null) {
          final winningCards = leadSuitCards.where((c) =>
              state.isCardStronger(c, currentWinningCard, leadSuit, false)).toList();
          if (winningCards.isNotEmpty) {
            winningCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            return winningCards.first;
          }
        }

        // 1b. 못 이기면 → 조커/마이티 (마지막+점수없으면 아낌, 마이티에는 대응 불가)
        if (!saveSpecialCards && !winningIsMighty) {
          final joker = playableCards.where((c) => c.isJoker).toList();
          if (joker.isNotEmpty && !jokerCalled &&
              state.currentTrickNumber > 1 && state.currentTrickNumber < 10) {
            return joker.first;
          }
          final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
          if (mighty.isNotEmpty) {
            return mighty.first;
          }
        }

        // 1c. 선공 무늬 최하위 카드
        leadSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        return leadSuitCards.first;

      } else {
        // === 2. 선공카드 미보유 ===

        // 2a. 기루다로 이길 수 있는 최소 카드
        if (state.giruda != null && currentWinningCard != null && !winningIsMighty) {
          final girudaCards = playableCards.where((c) =>
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
          if (girudaCards.isNotEmpty) {
            final winningGiruda = girudaCards.where((c) =>
                state.isCardStronger(c, currentWinningCard, leadSuit, false)).toList();
            if (winningGiruda.isNotEmpty) {
              winningGiruda.sort((a, b) => a.rankValue.compareTo(b.rankValue));
              return winningGiruda.first;
            }
          }
        }

        // 2b. 조커/마이티 (마지막+점수없으면 아낌)
        if (!saveSpecialCards && !winningIsMighty) {
          final joker = playableCards.where((c) => c.isJoker).toList();
          if (joker.isNotEmpty && !jokerCalled &&
              state.currentTrickNumber > 1 && state.currentTrickNumber < 10) {
            return joker.first;
          }
          final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
          if (mighty.isNotEmpty) {
            return mighty.first;
          }
        }

        // 2c. 비기루다 물패 우선 버림
        final nonGirudaDump = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
        if (nonGirudaDump.isNotEmpty) {
          nonGirudaDump.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return nonGirudaDump.first;
        }
        // 기루다만 있으면 낮은 기루다 버림
        final girudaDump = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda).toList();
        if (girudaDump.isNotEmpty) {
          girudaDump.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          return girudaDump.first;
        }
      }
    }

    // === 공격팀 마이티로 점수 카드 수집 전략 ===
    // 조커가 없고 점수 카드가 많을 때 마이티로 수집
    if (isAttackTeam && state.currentTrickNumber > 1) {
      final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
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
            if (currentWinningCard.isMightyWith(state.giruda) || currentWinningCard.isJoker) {
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
              if (c.isMightyWith(state.giruda) || c.isJoker) return false;
              // 컷된 무늬는 우선순위 낮춤 (상대 기루다 없으면 허용)
              if (remainingGiruda > 0 && c.suit != null && cutSuits.contains(c.suit)) {
                return false;
              }
              if (c.suit == mightySuit && c.rank == Rank.king) return true;
              return _getEffectiveCardValue(c, state) >= 14;
            }).toList();

            if (topCardsInstead.isNotEmpty && currentWinningCard != null &&
                !currentWinningCard.isJoker && !currentWinningCard.isMightyWith(state.giruda)) {
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
      final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
      if (mighty.isNotEmpty) {
        // 같은 팀이 확실히 이기고 있으면 마이티 사용 안 함
        bool teamWinningSecurely = false;
        if (!defenseWinning && currentWinningCard != null) {
          if (currentWinningCard.isMightyWith(state.giruda) || currentWinningCard.isJoker) {
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
              if (c.isMightyWith(state.giruda) || c.isJoker) return false;
              // 컷된 무늬는 우선순위 낮춤 (상대 기루다 없으면 허용)
              if (remainingGiruda > 0 && c.suit != null && cutSuits.contains(c.suit)) {
                return false;
              }
              if (c.suit == mightySuit && c.rank == Rank.king) return true;
              return _getEffectiveCardValue(c, state) >= 14;
            }).toList();

            if (topCardsInstead.isNotEmpty && currentWinningCard != null &&
                !currentWinningCard.isJoker && !currentWinningCard.isMightyWith(state.giruda)) {
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

    // === 수비팀 조커로 점수 카드 탈취 (공격팀 런 방지 최우선) ===
    // 트릭 2~9에서 공격팀이 이기고 있고, 점수 카드가 있고,
    // 마이티에게 질 확률이 낮으면 조커를 적극 사용
    if (isDefenseTeam && !defenseWinning &&
        state.currentTrickNumber > 1 && state.currentTrickNumber < 10) {
      final joker = playableCards.where((c) => c.isJoker).toList();
      if (joker.isNotEmpty) {
        bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
        // 마이티가 이기고 있으면 조커로 이길 수 없음
        bool winningWithMighty = currentWinningCard != null &&
            currentWinningCard.isMightyWith(state.giruda);

        if (!jokerCalled && !winningWithMighty) {
          // 트릭에 점수 카드가 1장 이상 있는지 확인
          int pointCardsInTrick = state.currentTrick!.cards
              .where((c) => c.isPointCard || c.isJoker).length;

          if (pointCardsInTrick >= 1) {
            // 마이티에게 질 확률 판단
            final allPlayedCards = _getPlayedCards(state);
            bool mightyPlayed = allPlayedCards.any((c) => c.isMightyWith(state.giruda));
            bool mightyInMyHand = player.hand.any((c) => c.isMightyWith(state.giruda));
            bool isLastPlayer = state.currentTrick != null &&
                state.currentTrick!.cards.length == 4;
            bool jokerSafe = mightyPlayed || mightyInMyHand || isLastPlayer;

            if (jokerSafe) {
              return joker.first;
            }
          }
        }
      }
    }

    // === 수비팀 조커로 선공권 탈환 (최상위 카드 보유 시) ===
    // 수비팀이 지고 있을 때, 조커로 선을 잡고 다음 트릭에서 최상위 카드를 내서
    // 연속으로 트릭을 가져오는 전략 (점수 카드 없어도 선공 확보 가치 있음)
    if (isDefenseTeam && !defenseWinning &&
        state.currentTrickNumber > 1 && state.currentTrickNumber < 10) {
      final jokerForLead = playableCards.where((c) => c.isJoker).toList();
      if (jokerForLead.isNotEmpty) {
        bool jokerCalledForLead = state.currentTrick?.jokerCallSuit != null;
        bool winningWithMightyForLead = currentWinningCard != null &&
            currentWinningCard.isMightyWith(state.giruda);

        if (!jokerCalledForLead && !winningWithMightyForLead) {
          // 선공권 탈환 후 유지할 최상위 카드가 있는지 확인
          // (실효 가치 14 이상 = 해당 무늬에서 최상위)
          bool hasTopCards = player.hand.any((c) =>
              !c.isMightyWith(state.giruda) && !c.isJoker &&
              _getEffectiveCardValue(c, state) >= 14);

          if (hasTopCards) {
            final allPlayedForLead = _getPlayedCards(state);
            bool mightyPlayedForLead = allPlayedForLead.any((c) => c.isMightyWith(state.giruda));
            bool mightyInMyHandForLead = player.hand.any((c) => c.isMightyWith(state.giruda));
            bool isLastPlayerForLead = state.currentTrick != null &&
                state.currentTrick!.cards.length == 4;
            bool jokerSafeForLead = mightyPlayedForLead || mightyInMyHandForLead || isLastPlayerForLead;

            if (jokerSafeForLead) {
              return jokerForLead.first;
            }
          }
        }
      }
    }

    // === 수비팀 마이티로 점수 카드 탈취 전략 ===
    // 공격팀이 점수 카드를 많이 가져갈 때 마이티로 뺏기
    if (isDefenseTeam && state.currentTrickNumber > 1) {
      final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
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
      final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
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
                !c.isMightyWith(state.giruda) && !c.isJoker &&
                _getEffectiveCardValue(c, state) >= 14);
            if (hasTopCards) {
              return mighty.first;
            }
          }
        }
      }
    }

    // === 9번째 트릭 조커/마이티 적극 사용 ===
    // 9번째에서 선을 잡아 10번째에 자신의 카드로 선공하여 이길 확률을 높임
    // 마지막 트릭에서 조커는 조커콜에 취약하므로 9번째에서 조커를 먼저 사용
    if (state.currentTrickNumber == 9) {
      final joker = playableCards.where((c) => c.isJoker).toList();
      final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();

      // 조커가 나오지 않고 상대팀이 이기고 있으면 사용 검토
      bool jokerPlayed = state.currentTrick!.cards.any((c) => c.isJoker);
      bool myTeamWinning = (isDefenseTeam && defenseWinning) || (isAttackTeam && !defenseWinning);

      if (!jokerPlayed && !myTeamWinning) {
        // 마이티와 조커 둘 다 있으면 조커 우선 (10번째에서 마이티로 확실하게 이김)
        if (joker.isNotEmpty && mighty.isNotEmpty) {
          bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
          if (!jokerCalled) {
            return joker.first;
          }
        }

        // 조커만 있으면 조커 사용 (10번째에서 조커는 조커콜에 취약)
        if (joker.isNotEmpty && mighty.isEmpty) {
          bool jokerCalled = state.currentTrick?.jokerCallSuit != null;
          if (!jokerCalled) {
            return joker.first;
          }
        }

        // 마이티만 있으면 마이티 사용
        if (mighty.isNotEmpty) {
          // 마이티 제외 남은 카드 중 10번째에서 이길 가능성 있는 카드 확인
          final remainingCards = player.hand.where((c) => !c.isMightyWith(state.giruda)).toList();
          bool hasWinningCard = remainingCards.any((c) =>
              (c.suit == state.giruda && _getEffectiveCardValue(c, state) >= 12) ||
              _getEffectiveCardValue(c, state) >= 14);

          if (hasWinningCard) {
            // 10번째에서 이길 카드가 있으면 마이티 사용하여 선 확보
            return mighty.first;
          } else {
            // 이길 카드가 없으면 점수 카드가 많을 때만 마이티 사용
            int pointCardsInTrick = state.currentTrick!.cards
                .where((c) => c.isPointCard || c.isJoker).length;
            if (pointCardsInTrick >= 2) {
              return mighty.first;
            }
          }
        }
      }
    }

    // === 수비팀 후반전 마이티 전략 ===
    // 후반전(트릭 8 이후)에 마이티를 사용하여 점수 확보
    if (isDefenseTeam && state.currentTrickNumber >= 8) {
      final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
      if (mighty.isNotEmpty) {
        // 같은 팀이 확실히 이기고 있으면 마이티 사용 안 함
        bool teamWinningSecurely = false;
        if (defenseWinning && currentWinningCard != null) {
          if (currentWinningCard.isMightyWith(state.giruda) || currentWinningCard.isJoker) {
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
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == state.giruda &&
            _getEffectiveCardValue(c, state) >= 14);
      }

      // 마이티/조커 보유 확인
      bool hasMightyOrJoker = player.hand.any((c) => c.isMightyWith(state.giruda) || c.isJoker);

      // 강한 카드가 있으면 낮은 카드 우선 버리기
      if (hasHighGiruda || hasMightyOrJoker) {
        // 리드 무늬가 있으면 리드 무늬 중 낮은 카드
        final suitCards = playableCards.where((c) =>
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit == leadSuit).toList();
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
            !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
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
          !c.isJoker && !c.isMightyWith(state.giruda) && c.isPointCard &&
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
        // ★ 마지막 순서이면 이길 수 있는지 먼저 확인 (상대팀 물패 대응)
        bool isLastPlayer = state.currentTrick != null &&
            state.currentTrick!.cards.length == 4;
        if (isLastPlayer && currentWinningCard != null) {
          // 이길 수 있는 카드 찾기 (가장 낮은 것으로 효율적으로)
          suitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          for (final card in suitCards) {
            if (state.isCardStronger(card, currentWinningCard, leadSuit, false)) {
              return card;
            }
          }
        }

        // 이길 수 없으면 점수 카드가 아닌 카드 중 가장 낮은 카드
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
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
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
              !c.isJoker && !c.isMightyWith(state.giruda) && c.suit != state.giruda).toList();
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
      final pointCards = playableCards.where((c) => c.isPointCard && !c.isMightyWith(state.giruda)).toList();
      if (pointCards.isNotEmpty) {
        pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        return pointCards.first;
      }
    }

    // 마이티가 이기고 있으면 조커를 내지 않음 (조커는 마이티를 이길 수 없음)
    bool mightyWinning = currentWinningCard != null && currentWinningCard.isMightyWith(state.giruda);

    // 조커/마이티 제외하고 낮은 카드 버리기
    final nonSpecialNonPointCards = playableCards.where((c) =>
        !c.isPointCard && !c.isJoker && !c.isMightyWith(state.giruda)).toList();
    if (nonSpecialNonPointCards.isNotEmpty) {
      nonSpecialNonPointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
      return nonSpecialNonPointCards.first;
    }

    // 조커/마이티 제외하고 점수 카드 버리기
    final nonSpecialCards = playableCards.where((c) =>
        !c.isJoker && !c.isMightyWith(state.giruda)).toList();
    if (nonSpecialCards.isNotEmpty) {
      nonSpecialCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
      return nonSpecialCards.first;
    }

    // 조커/마이티만 남은 경우
    // 마이티가 이기고 있으면 조커를 내지 않음 (조커는 마이티를 이길 수 없음)
    if (mightyWinning) {
      // 마이티가 있으면 마이티를 냄 (조커 보존)
      final mighty = playableCards.where((c) => c.isMightyWith(state.giruda)).toList();
      if (mighty.isNotEmpty) {
        return mighty.first;
      }
      // 마이티가 없으면 조커도 아끼고 아무거나 냄 (조커로는 마이티를 못 이김)
      final nonJoker = playableCards.where((c) => !c.isJoker).toList();
      if (nonJoker.isNotEmpty) {
        return nonJoker.first;
      }
      // ★ 조커만 남은 경우 어쩔 수 없이 조커를 냄 (여기서 return 해야 fallback 방지)
      return playableCards.first;
    }

    // 마이티가 이기고 있지 않을 때만 조커 우선 (마이티는 더 강하므로 아끼기)
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
    if (declarerCard.isJoker || declarerCard.isMightyWith(state.giruda)) return false;
    if (declarerCard.isPointCard) return false;

    // 기루다(트럼프)로 컷한 경우는 낮은 카드여도 신호가 아님 (이미 이기고 있음)
    final leadSuit = state.currentTrick!.leadSuit;
    if (state.giruda != null && declarerCard.suit == state.giruda && leadSuit != state.giruda) {
      return false;
    }

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
  /// 이전 트릭에서 조커로 기루다 콜한 트릭이 있는지 확인
  bool _hasGirudaCallTrick(GameState state) {
    if (state.giruda == null) return false;
    for (final trick in state.tricks) {
      if (trick.jokerLeadSuit == state.giruda) {
        return true;
      }
    }
    return false;
  }

  /// 이전 기루다 콜에서 수비팀이 기루다를 낸 적이 있는지 확인
  /// 프렌드만 기루다를 내고 있으면 false 반환 (기루다 아끼기)
  bool _hasDefensePlayedGirudaOnCall(GameState state) {
    if (state.giruda == null) return false;
    final declarerId = state.declarer;
    final friendId = state.friendRevealed ? state.friend : null;

    for (final trick in state.tricks) {
      // 조커로 기루다 콜한 트릭인지 확인
      if (trick.jokerLeadSuit == state.giruda) {
        // 각 플레이어가 낸 카드 확인
        for (int i = 0; i < trick.cards.length; i++) {
          final card = trick.cards[i];
          final playerId = trick.playerOrder[i];

          // 수비팀인지 확인 (주공, 프렌드 제외)
          if (playerId != declarerId && playerId != friendId) {
            // 기루다를 냈는지 확인
            if (!card.isJoker && card.suit == state.giruda) {
              return true;
            }
          }
        }
      }
    }

    return false;
  }

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
