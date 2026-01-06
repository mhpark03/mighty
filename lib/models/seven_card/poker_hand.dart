import '../card.dart';

/// 포커 족보 순위 (낮은 것부터 높은 것)
enum HandRank {
  highCard,       // 하이카드
  onePair,        // 원페어
  twoPair,        // 투페어
  triple,         // 트리플 (쓰리오브어카인드)
  straight,       // 스트레이트
  backStraight,   // 백스트레이트 (A-2-3-4-5)
  mountain,       // 마운틴 (10-J-Q-K-A)
  flush,          // 플러시
  fullHouse,      // 풀하우스
  fourOfAKind,    // 포카드 (포오브어카인드)
  straightFlush,  // 스트레이트 플러시
  backStraightFlush, // 백스트레이트 플러시
  royalStraightFlush, // 로열 스트레이트 플러시
}

/// 포커 핸드 평가 결과
class PokerHand {
  final HandRank rank;
  final List<PlayingCard> bestFive;
  final List<int> tiebreakers; // 동점 시 비교용

  PokerHand({
    required this.rank,
    required this.bestFive,
    required this.tiebreakers,
  });

  /// 다른 핸드와 비교 (-1: 패배, 0: 무승부, 1: 승리)
  int compareTo(PokerHand other) {
    if (rank.index != other.rank.index) {
      return rank.index.compareTo(other.rank.index);
    }
    // 같은 족보면 타이브레이커로 비교
    for (int i = 0; i < tiebreakers.length && i < other.tiebreakers.length; i++) {
      if (tiebreakers[i] != other.tiebreakers[i]) {
        return tiebreakers[i].compareTo(other.tiebreakers[i]);
      }
    }
    return 0;
  }

  @override
  String toString() {
    return 'PokerHand($rank, tiebreakers: $tiebreakers)';
  }
}

/// 포커 핸드 평가기
class PokerHandEvaluator {
  /// 부분 카드 평가 (5장 미만 - 공개 카드용)
  static PokerHand? evaluatePartial(List<PlayingCard> cards) {
    if (cards.isEmpty) return null;

    final normalCards = cards.where((c) => !c.isJoker).toList();
    if (normalCards.isEmpty) return null;

    final sortedCards = List<PlayingCard>.from(normalCards);
    sortedCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));

    final groups = _getGroups(sortedCards);

    // 포카드
    if (groups.containsValue(4)) {
      final fourRank = groups.entries.firstWhere((e) => e.value == 4).key;
      return PokerHand(
        rank: HandRank.fourOfAKind,
        bestFive: sortedCards,
        tiebreakers: [fourRank],
      );
    }

    // 트리플
    if (groups.containsValue(3)) {
      final tripleRank = groups.entries.firstWhere((e) => e.value == 3).key;
      return PokerHand(
        rank: HandRank.triple,
        bestFive: sortedCards,
        tiebreakers: [tripleRank],
      );
    }

    // 투페어
    final pairs = groups.entries.where((e) => e.value == 2).toList();
    if (pairs.length >= 2) {
      final pairRanks = pairs.map((e) => e.key).toList()..sort((a, b) => b.compareTo(a));
      return PokerHand(
        rank: HandRank.twoPair,
        bestFive: sortedCards,
        tiebreakers: pairRanks,
      );
    }

    // 원페어
    if (pairs.length == 1) {
      final pairRank = pairs.first.key;
      return PokerHand(
        rank: HandRank.onePair,
        bestFive: sortedCards,
        tiebreakers: [pairRank],
      );
    }

    // 하이카드
    return PokerHand(
      rank: HandRank.highCard,
      bestFive: sortedCards,
      tiebreakers: sortedCards.map((c) => c.rankValue).toList(),
    );
  }

  /// 7장의 카드에서 최고의 5장 조합을 찾아 평가
  static PokerHand evaluate(List<PlayingCard> cards) {
    if (cards.length < 5) {
      throw ArgumentError('최소 5장의 카드가 필요합니다');
    }

    // 조커 제외한 카드만 사용
    final normalCards = cards.where((c) => !c.isJoker).toList();

    if (normalCards.length < 5) {
      // 조커가 너무 많은 경우 (실제 게임에서는 조커 없음)
      return PokerHand(
        rank: HandRank.highCard,
        bestFive: normalCards.take(5).toList(),
        tiebreakers: [0],
      );
    }

    // 모든 5장 조합 생성
    final combinations = _generateCombinations(normalCards, 5);

    PokerHand? bestHand;
    for (final combo in combinations) {
      final hand = _evaluateFiveCards(combo);
      if (bestHand == null || hand.compareTo(bestHand) > 0) {
        bestHand = hand;
      }
    }

    return bestHand!;
  }

  /// 5장의 카드를 평가
  static PokerHand _evaluateFiveCards(List<PlayingCard> cards) {
    assert(cards.length == 5);

    final sortedCards = List<PlayingCard>.from(cards);
    sortedCards.sort((a, b) => b.rankValue.compareTo(a.rankValue));

    final isFlush = _isFlush(sortedCards);
    final straightInfo = _getStraightInfo(sortedCards);
    final groups = _getGroups(sortedCards);

    // 로열 스트레이트 플러시
    if (isFlush && straightInfo.isMountain) {
      return PokerHand(
        rank: HandRank.royalStraightFlush,
        bestFive: sortedCards,
        tiebreakers: [14], // A가 최고
      );
    }

    // 백스트레이트 플러시
    if (isFlush && straightInfo.isBackStraight) {
      return PokerHand(
        rank: HandRank.backStraightFlush,
        bestFive: sortedCards,
        tiebreakers: [5], // 5가 최고
      );
    }

    // 스트레이트 플러시
    if (isFlush && straightInfo.isStraight) {
      return PokerHand(
        rank: HandRank.straightFlush,
        bestFive: sortedCards,
        tiebreakers: [straightInfo.highCard],
      );
    }

    // 포카드
    if (groups.containsValue(4)) {
      final fourRank = groups.entries.firstWhere((e) => e.value == 4).key;
      final kicker = sortedCards.firstWhere((c) => c.rankValue != fourRank).rankValue;
      return PokerHand(
        rank: HandRank.fourOfAKind,
        bestFive: sortedCards,
        tiebreakers: [fourRank, kicker],
      );
    }

    // 풀하우스
    if (groups.containsValue(3) && groups.containsValue(2)) {
      final tripleRank = groups.entries.firstWhere((e) => e.value == 3).key;
      final pairRank = groups.entries.firstWhere((e) => e.value == 2).key;
      return PokerHand(
        rank: HandRank.fullHouse,
        bestFive: sortedCards,
        tiebreakers: [tripleRank, pairRank],
      );
    }

    // 플러시
    if (isFlush) {
      return PokerHand(
        rank: HandRank.flush,
        bestFive: sortedCards,
        tiebreakers: sortedCards.map((c) => c.rankValue).toList(),
      );
    }

    // 마운틴
    if (straightInfo.isMountain) {
      return PokerHand(
        rank: HandRank.mountain,
        bestFive: sortedCards,
        tiebreakers: [14],
      );
    }

    // 백스트레이트
    if (straightInfo.isBackStraight) {
      return PokerHand(
        rank: HandRank.backStraight,
        bestFive: sortedCards,
        tiebreakers: [5],
      );
    }

    // 스트레이트
    if (straightInfo.isStraight) {
      return PokerHand(
        rank: HandRank.straight,
        bestFive: sortedCards,
        tiebreakers: [straightInfo.highCard],
      );
    }

    // 트리플
    if (groups.containsValue(3)) {
      final tripleRank = groups.entries.firstWhere((e) => e.value == 3).key;
      final kickers = sortedCards
          .where((c) => c.rankValue != tripleRank)
          .map((c) => c.rankValue)
          .toList();
      return PokerHand(
        rank: HandRank.triple,
        bestFive: sortedCards,
        tiebreakers: [tripleRank, ...kickers],
      );
    }

    // 투페어
    final pairs = groups.entries.where((e) => e.value == 2).toList();
    if (pairs.length >= 2) {
      final pairRanks = pairs.map((e) => e.key).toList()..sort((a, b) => b.compareTo(a));
      final kicker = sortedCards
          .firstWhere((c) => c.rankValue != pairRanks[0] && c.rankValue != pairRanks[1])
          .rankValue;
      return PokerHand(
        rank: HandRank.twoPair,
        bestFive: sortedCards,
        tiebreakers: [pairRanks[0], pairRanks[1], kicker],
      );
    }

    // 원페어
    if (pairs.length == 1) {
      final pairRank = pairs.first.key;
      final kickers = sortedCards
          .where((c) => c.rankValue != pairRank)
          .map((c) => c.rankValue)
          .toList();
      return PokerHand(
        rank: HandRank.onePair,
        bestFive: sortedCards,
        tiebreakers: [pairRank, ...kickers],
      );
    }

    // 하이카드
    return PokerHand(
      rank: HandRank.highCard,
      bestFive: sortedCards,
      tiebreakers: sortedCards.map((c) => c.rankValue).toList(),
    );
  }

  /// 플러시 여부 확인
  static bool _isFlush(List<PlayingCard> cards) {
    final suit = cards.first.suit;
    return cards.every((c) => c.suit == suit);
  }

  /// 스트레이트 정보
  static _StraightInfo _getStraightInfo(List<PlayingCard> cards) {
    final ranks = cards.map((c) => c.rankValue).toSet().toList()..sort((a, b) => b.compareTo(a));

    if (ranks.length != 5) {
      return _StraightInfo(isStraight: false, isBackStraight: false, isMountain: false, highCard: 0);
    }

    // 마운틴 (10-J-Q-K-A = 10,11,12,13,14)
    if (ranks[0] == 14 && ranks[1] == 13 && ranks[2] == 12 && ranks[3] == 11 && ranks[4] == 10) {
      return _StraightInfo(isStraight: true, isBackStraight: false, isMountain: true, highCard: 14);
    }

    // 백스트레이트 (A-2-3-4-5 = 14,5,4,3,2)
    if (ranks[0] == 14 && ranks[1] == 5 && ranks[2] == 4 && ranks[3] == 3 && ranks[4] == 2) {
      return _StraightInfo(isStraight: true, isBackStraight: true, isMountain: false, highCard: 5);
    }

    // 일반 스트레이트
    bool isStraight = true;
    for (int i = 0; i < 4; i++) {
      if (ranks[i] - ranks[i + 1] != 1) {
        isStraight = false;
        break;
      }
    }

    return _StraightInfo(
      isStraight: isStraight,
      isBackStraight: false,
      isMountain: false,
      highCard: isStraight ? ranks[0] : 0,
    );
  }

  /// 같은 랭크의 카드 그룹
  static Map<int, int> _getGroups(List<PlayingCard> cards) {
    final groups = <int, int>{};
    for (final card in cards) {
      groups[card.rankValue] = (groups[card.rankValue] ?? 0) + 1;
    }
    return groups;
  }

  /// n개 조합 생성
  static List<List<PlayingCard>> _generateCombinations(List<PlayingCard> cards, int n) {
    final result = <List<PlayingCard>>[];
    _generateCombinationsHelper(cards, n, 0, [], result);
    return result;
  }

  static void _generateCombinationsHelper(
    List<PlayingCard> cards,
    int n,
    int start,
    List<PlayingCard> current,
    List<List<PlayingCard>> result,
  ) {
    if (current.length == n) {
      result.add(List.from(current));
      return;
    }
    for (int i = start; i < cards.length; i++) {
      current.add(cards[i]);
      _generateCombinationsHelper(cards, n, i + 1, current, result);
      current.removeLast();
    }
  }
}

class _StraightInfo {
  final bool isStraight;
  final bool isBackStraight;
  final bool isMountain;
  final int highCard;

  _StraightInfo({
    required this.isStraight,
    required this.isBackStraight,
    required this.isMountain,
    required this.highCard,
  });
}
