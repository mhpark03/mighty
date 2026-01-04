import 'dart:math';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';

class AIPlayer {
  Bid decideBid(Player player, GameState state) {
    final hand = player.hand;

    // 1. 먼저 최적의 기루다를 선택
    Suit? bestSuit = findBestSuit(hand);

    // 2. 선택된 기루다를 기준으로 핸드 강도 계산
    int strength = evaluateHandStrength(hand, bestSuit);

    // 3. 비딩 결정 - 순서대로 1씩 증가하며 비딩
    int bidAmount;
    if (state.currentBid == null) {
      // 첫 비딩은 13부터 시작
      bidAmount = 13;
    } else {
      // 현재 최고 비딩 + 1로 비딩
      bidAmount = state.currentBid!.tricks + 1;
    }

    // 비딩할 금액이 자신의 강도보다 높으면 패스
    if (bidAmount > strength || strength < 13) {
      return Bid.pass(player.id);
    }

    // 최대 20까지만 비딩 가능
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

    // === 4. 기루다 이외의 A, K, Q (선공 시 트릭 가능) ===
    for (final suit in Suit.values) {
      if (suit == giruda) continue; // 기루다는 이미 계산함

      final suitCards = hand.where((c) => !c.isJoker && c.suit == suit).toList();
      if (suitCards.isEmpty) continue;

      // 마이티가 아닌 에이스
      bool hasAce = suitCards.any((c) =>
          c.rank == Rank.ace && !(c.suit == mightySuit && c.rank == Rank.ace));
      bool hasKing = suitCards.any((c) => c.rank == Rank.king);

      // 비기루다 고위 카드 (선공 시에만 유용, 가치 낮음)
      // A-K 연속이면 2트릭 가능성
      if (hasAce && hasKing) {
        strength += 2;
      } else if (hasAce) {
        strength += 1; // A만 있으면 1트릭
      } else if (hasKing && suitCards.length >= 3) {
        // K가 있고 그 무늬가 3장 이상이면 A가 나간 후 K로 트릭 가능성
        strength += 1;
      }
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

      // 5. 카드 수가 적은 무늬 우선 버림 (컷 가능성 높임)
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

      // 5. 카드 수가 적은 무늬 우선 버림 (컷 가능성 높임)
      int aCount = suitCount[a.suit] ?? 0;
      int bCount = suitCount[b.suit] ?? 0;
      if (aCount != bCount) {
        return aCount.compareTo(bCount); // 적은 쪽이 앞으로
      }

      return a.rankValue.compareTo(b.rankValue);
    });

    return hand.take(3).toList();
  }

  FriendDeclaration declareFriend(Player player, GameState state) {
    final hand = player.hand;

    bool hasMighty = hand.any((c) => c.isMighty);
    bool hasJoker = hand.any((c) => c.isJoker);

    // 기루다 A 보유 확인
    bool hasGirudaAce = false;
    if (state.giruda != null) {
      final girudaAce = PlayingCard(suit: state.giruda!, rank: Rank.ace);
      if (girudaAce != state.mighty) {
        hasGirudaAce = hand.any((c) => c.suit == girudaAce.suit && c.rank == girudaAce.rank);
      }
    }

    // 기루다 외 A 보유 확인
    int nonGirudaAceCount = 0;
    for (final suit in Suit.values) {
      if (suit == state.giruda) continue;
      final ace = PlayingCard(suit: suit, rank: Rank.ace);
      if (ace != state.mighty) {
        if (hand.any((c) => c.suit == ace.suit && c.rank == ace.rank)) {
          nonGirudaAceCount++;
        }
      }
    }

    // 조커 콜 카드 보유 확인
    final jokerCallCard = state.jokerCall;
    bool hasJokerCallCard = hand.any((c) =>
        c.suit == jokerCallCard.suit && c.rank == jokerCallCard.rank);

    // 기루다 K 보유 확인
    bool hasGirudaKing = false;
    if (state.giruda != null) {
      final girudaKing = PlayingCard(suit: state.giruda!, rank: Rank.king);
      hasGirudaKing = hand.any((c) => c.suit == girudaKing.suit && c.rank == girudaKing.rank);
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

    // === 일반 프렌드 선택 ===

    // 1. 마이티가 없으면 마이티 소유자를 프렌드로
    if (!hasMighty) {
      return FriendDeclaration.byCard(state.mighty);
    }

    // 2. 조커가 없으면 조커 소유자를 프렌드로
    if (!hasJoker) {
      return FriendDeclaration.byCard(PlayingCard.joker());
    }

    // 3. 기루다 A-K 체크
    if (state.giruda != null) {
      final girudaTopRanks = [Rank.ace, Rank.king];
      for (final rank in girudaTopRanks) {
        final girudaCard = PlayingCard(suit: state.giruda!, rank: rank);
        // 마이티가 아닌 경우에만 체크
        if (girudaCard != state.mighty) {
          bool hasCard = hand.any((c) => c.suit == girudaCard.suit && c.rank == girudaCard.rank);
          if (!hasCard) {
            return FriendDeclaration.byCard(girudaCard);
          }
        }
      }
    }

    // 4. 기루다 외 에이스 체크
    for (final suit in Suit.values) {
      if (suit == state.giruda) continue;  // 기루다는 이미 체크함
      final ace = PlayingCard(suit: suit, rank: Rank.ace);
      if (ace != state.mighty) {
        bool hasAce = hand.any((c) => c.suit == ace.suit && c.rank == ace.rank);
        if (!hasAce) {
          return FriendDeclaration.byCard(ace);
        }
      }
    }

    // 5. 기루다 Q-J-10 체크
    if (state.giruda != null) {
      final girudaMidRanks = [Rank.queen, Rank.jack, Rank.ten];
      for (final rank in girudaMidRanks) {
        final girudaCard = PlayingCard(suit: state.giruda!, rank: rank);
        bool hasCard = hand.any((c) => c.suit == girudaCard.suit && c.rank == girudaCard.rank);
        if (!hasCard) {
          return FriendDeclaration.byCard(girudaCard);
        }
      }
    }

    // 6. 마이티, 조커, 기루다 고위카드, 모든 에이스를 가지고 있으면 프렌드 없음
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

    // 조커 콜 카드 확인
    final jokerCallCard = state.jokerCall;
    bool hasJokerCallCard = player.hand.any((c) =>
        c.suit == jokerCallCard.suit && c.rank == jokerCallCard.rank);
    if (!hasJokerCallCard) return null;

    // 조커를 가지고 있으면 조커 콜 안 함
    bool hasJoker = player.hand.any((c) => c.isJoker);
    if (hasJoker) return null;

    // 50% 확률로 조커 콜 시도
    if (Random().nextDouble() > 0.5) return null;

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

    // 조커가 없으면 조커 콜 카드를 내서 조커 콜 시도
    bool hasJoker = player.hand.any((c) => c.isJoker);
    if (!hasJoker && Random().nextDouble() < 0.5) {
      return true;
    }

    return false;
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

        // 조건 2: 트릭에 점수 카드가 많거나 주공이 지고 있을 때 프렌드 카드 사용
        int pointCardsInTrick = state.currentTrick!.cards
            .where((c) => c.isPointCard).length;

        if (declarerInDanger && pointCardsInTrick >= 2) {
          // 프렌드 카드로 이길 수 있는지 확인
          if (currentWinningCard != null &&
              state.isCardStronger(friendCard, currentWinningCard, leadSuit, false)) {
            return friendCard;
          }
        }

        // 조건 3: 마지막 트릭(10번째)이거나 주공팀 점수가 부족할 때 프렌드 공개
        if (state.currentTrickNumber >= 8 && declarerInDanger) {
          if (currentWinningCard != null &&
              state.isCardStronger(friendCard, currentWinningCard, leadSuit, false)) {
            return friendCard;
          }
        }
      }
    }

    // === 수비팀 점수 카드 전략 ===
    // 프렌드가 공개되고, 내가 수비팀이고, 수비팀이 이길 확률이 높으면 점수 카드를 낸다
    bool isDefenseTeam = _isPlayerOnDefenseTeam(player, state);
    bool defenseWinning = _isDefenseTeamWinning(state, currentWinnerId);

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
      suitCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));

      for (final card in suitCards) {
        if (currentWinningCard != null &&
            state.isCardStronger(card, currentWinningCard, leadSuit, false)) {
          return card;
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

    // 수비팀이 이기고 있으면 점수 카드 우선
    if (isDefenseTeam && defenseWinning) {
      final pointCards = playableCards.where((c) => c.isPointCard && !c.isMighty).toList();
      if (pointCards.isNotEmpty) {
        pointCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        return pointCards.first;
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
      bool hasFriendCard = player.hand.any((c) =>
          c.suit == friendCard.suit && c.rank == friendCard.rank);
      if (hasFriendCard) return false; // 프렌드 카드를 가지고 있으면 주공팀
    }

    // 그 외에는 수비팀
    return true;
  }

  // 수비팀이 현재 트릭에서 이기고 있는지 확인
  bool _isDefenseTeamWinning(GameState state, int? currentWinnerId) {
    if (currentWinnerId == null) return false;

    final winner = state.players[currentWinnerId];

    // 주공이 이기고 있으면 수비팀이 이기는 것 아님
    if (winner.isDeclarer) return false;

    // 프렌드가 공개되고 프렌드가 이기고 있으면 수비팀이 이기는 것 아님
    if (state.friendRevealed && winner.isFriend) return false;

    // 프렌드가 아직 공개되지 않은 경우
    // 이기고 있는 사람이 프렌드 카드를 가지고 있을 수 있으므로 보수적으로 판단
    // -> 프렌드가 공개된 경우에만 수비팀 승리로 판단
    if (!state.friendRevealed) return false;

    // 수비팀이 이기고 있음
    return true;
  }
}
