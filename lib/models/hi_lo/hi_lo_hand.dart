import '../card.dart';

/// 로우 핸드 (낮을수록 좋음)
/// 스트레이트/플러시가 없는 핸드만 로우 자격
/// A-2-3-4-6이 최강 로우 (A-2-3-4-5는 백스트레이트이므로 제외)
class LowHand implements Comparable<LowHand> {
  final List<int> cardRanks; // 낮은 순서로 정렬된 카드 랭크 (A=1, 2=2, ..., K=13)
  final bool isQualified;    // 로우 자격 (스트레이트/플러시 없음)

  LowHand({
    required this.cardRanks,
    required this.isQualified,
  });

  @override
  int compareTo(LowHand other) {
    // 자격 없는 핸드는 최악
    if (!isQualified && !other.isQualified) return 0;
    if (!isQualified) return 1;
    if (!other.isQualified) return -1;

    // 가장 높은 카드부터 비교 (낮을수록 좋음)
    for (int i = cardRanks.length - 1; i >= 0; i--) {
      if (i >= other.cardRanks.length) return 1;
      if (cardRanks[i] != other.cardRanks[i]) {
        return cardRanks[i].compareTo(other.cardRanks[i]);
      }
    }
    return 0;
  }

  /// 로우 핸드 이름 반환
  String get name {
    if (!isQualified) return 'No Low';
    // 정렬된 카드 표시
    final rankNames = cardRanks.map((r) {
      if (r == 1) return 'A';
      if (r == 11) return 'J';
      if (r == 12) return 'Q';
      if (r == 13) return 'K';
      return r.toString();
    }).toList();
    return rankNames.reversed.join('-');
  }

  @override
  String toString() => name;
}

/// 하이로우 핸드 평가자
class HiLoHandEvaluator {
  /// 로우 핸드 평가 (7장에서 최적의 5장 선택)
  /// 스트레이트/플러시가 없는 가장 낮은 핸드
  static LowHand? evaluateLow(List<PlayingCard> cards) {
    if (cards.length < 5) return null;

    LowHand? bestLow;

    // 7장에서 가능한 모든 5장 조합 생성
    final combinations = _getCombinations(cards, 5);

    for (final combo in combinations) {
      final low = _evaluateLowHand(combo);
      if (low != null && low.isQualified) {
        if (bestLow == null || low.compareTo(bestLow) < 0) {
          bestLow = low;
        }
      }
    }

    return bestLow ?? LowHand(cardRanks: [], isQualified: false);
  }

  /// 5장 핸드의 로우 평가
  static LowHand? _evaluateLowHand(List<PlayingCard> cards) {
    if (cards.length != 5) return null;

    // 플러시 체크 (같은 무늬 5장)
    final firstSuit = cards[0].suit;
    final isFlush = cards.every((c) => c.suit == firstSuit);
    if (isFlush) {
      return LowHand(cardRanks: [], isQualified: false);
    }

    // 랭크 추출 (A=1)
    final ranks = cards.map((c) {
      if (c.rank == Rank.ace) return 1;
      if (c.rank == Rank.jack) return 11;
      if (c.rank == Rank.queen) return 12;
      if (c.rank == Rank.king) return 13;
      // Rank enum: two=0, three=1, ..., ten=8, so add 2
      return (c.rank?.index ?? 0) + 2;
    }).toList();

    // 중복 체크 (페어가 있으면 로우 불가)
    final uniqueRanks = ranks.toSet();
    if (uniqueRanks.length != 5) {
      return LowHand(cardRanks: [], isQualified: false);
    }

    // 정렬
    ranks.sort();

    // 스트레이트 체크
    if (_isStraight(ranks)) {
      return LowHand(cardRanks: [], isQualified: false);
    }

    return LowHand(cardRanks: ranks, isQualified: true);
  }

  /// 스트레이트 체크
  static bool _isStraight(List<int> sortedRanks) {
    // 일반 스트레이트 체크
    bool isConsecutive = true;
    for (int i = 1; i < sortedRanks.length; i++) {
      if (sortedRanks[i] != sortedRanks[i - 1] + 1) {
        isConsecutive = false;
        break;
      }
    }
    if (isConsecutive) return true;

    // 백스트레이트 (A-2-3-4-5) 체크
    // A=1이므로 [1,2,3,4,5]
    if (sortedRanks[0] == 1 &&
        sortedRanks[1] == 2 &&
        sortedRanks[2] == 3 &&
        sortedRanks[3] == 4 &&
        sortedRanks[4] == 5) {
      return true;
    }

    // 마운틴 (10-J-Q-K-A) 체크
    // A=1이므로 확인: [1,10,11,12,13]
    if (sortedRanks[0] == 1 &&
        sortedRanks[1] == 10 &&
        sortedRanks[2] == 11 &&
        sortedRanks[3] == 12 &&
        sortedRanks[4] == 13) {
      return true;
    }

    return false;
  }

  /// 조합 생성 (n개에서 r개 선택)
  static List<List<PlayingCard>> _getCombinations(List<PlayingCard> cards, int r) {
    final result = <List<PlayingCard>>[];
    _generateCombinations(cards, r, 0, [], result);
    return result;
  }

  static void _generateCombinations(
    List<PlayingCard> cards,
    int r,
    int start,
    List<PlayingCard> current,
    List<List<PlayingCard>> result,
  ) {
    if (current.length == r) {
      result.add(List.from(current));
      return;
    }

    for (int i = start; i < cards.length; i++) {
      current.add(cards[i]);
      _generateCombinations(cards, r, i + 1, current, result);
      current.removeLast();
    }
  }

  /// 로우 핸드 강도 계산 (0.0 ~ 1.0)
  /// 낮을수록 강함 (A-2-3-4-6 = 1.0)
  static double calculateLowStrength(LowHand? hand) {
    if (hand == null || !hand.isQualified) return 0.0;

    // A-2-3-4-6 (최강) = 1.0
    // A-2-3-4-7 = 0.95
    // ...
    // K-Q-J-10-9 (최약) = 0.1

    // 로우 값 계산 (낮을수록 좋음)
    // 가장 높은 카드가 중요
    final highCard = hand.cardRanks.last;

    // 6이 최강 로우의 하이카드 (A-2-3-4-6)
    if (highCard <= 6) return 1.0;
    if (highCard == 7) return 0.9;
    if (highCard == 8) return 0.8;
    if (highCard == 9) return 0.7;
    if (highCard == 10) return 0.5;
    if (highCard >= 11) return 0.3;

    return 0.2;
  }

  /// 스윙에 적합한지 평가
  /// 하이와 로우 둘 다 어느 정도 강해야 함
  static bool isSuitableForSwing(
    double hiStrength,
    LowHand? lowHand,
  ) {
    if (lowHand == null || !lowHand.isQualified) return false;

    final lowStrength = calculateLowStrength(lowHand);

    // 둘 다 0.6 이상이면 스윙 고려
    return hiStrength >= 0.6 && lowStrength >= 0.6;
  }
}
