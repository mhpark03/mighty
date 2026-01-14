import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/hearts/hearts_stats_service.dart';
import '../../services/ad_service.dart';
import '../../services/game_save_service.dart';

enum Suit { spade, heart, diamond, club }

class PlayingCard {
  final Suit suit;
  final int rank; // 2-14 (14 = Ace)

  const PlayingCard(this.suit, this.rank);

  bool get isHeart => suit == Suit.heart;
  bool get isQueenOfSpades => suit == Suit.spade && rank == 12;

  int get points {
    if (isHeart) return 1;
    if (isQueenOfSpades) return 13;
    return 0;
  }

  String get suitSymbol {
    switch (suit) {
      case Suit.spade: return '♠';
      case Suit.heart: return '♥';
      case Suit.diamond: return '♦';
      case Suit.club: return '♣';
    }
  }

  String get rankSymbol {
    switch (rank) {
      case 14: return 'A';
      case 13: return 'K';
      case 12: return 'Q';
      case 11: return 'J';
      default: return rank.toString();
    }
  }

  Color get color => (suit == Suit.heart || suit == Suit.diamond) ? Colors.red : Colors.black;

  @override
  String toString() => '$suitSymbol$rankSymbol';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlayingCard && other.suit == suit && other.rank == rank;
  }

  @override
  int get hashCode => suit.hashCode ^ rank.hashCode;

  // JSON 직렬화
  Map<String, dynamic> toJson() => {
    'suit': suit.index,
    'rank': rank,
  };

  factory PlayingCard.fromJson(Map<String, dynamic> json) {
    return PlayingCard(
      Suit.values[json['suit'] as int],
      json['rank'] as int,
    );
  }
}

enum GamePhase { passing, playing, roundEnd }

// 반응형 사이즈 헬퍼
class _HeartsResponsiveSizes {
  final double screenHeight;
  final double screenWidth;

  late final double centerCardWidth;
  late final double centerCardHeight;
  late final double playerCardWidth;
  late final double playerCardHeight;
  late final double aiCardWidth;
  late final double aiCardHeight;
  late final double aiCardOverlap;

  _HeartsResponsiveSizes(this.screenHeight, this.screenWidth) {
    final baseUnit = screenHeight / 100;
    final widthUnit = screenWidth / 100;

    // 중앙 트릭 영역 카드
    centerCardWidth = (widthUnit * 12).clamp(40.0, 70.0);
    centerCardHeight = (baseUnit * 11).clamp(58.0, 95.0);

    // 플레이어 카드
    playerCardWidth = (widthUnit * 8).clamp(32.0, 55.0);
    playerCardHeight = (baseUnit * 9).clamp(45.0, 75.0);

    // AI 카드 (상단)
    aiCardWidth = (widthUnit * 7).clamp(24.0, 40.0);
    aiCardHeight = (baseUnit * 6).clamp(32.0, 52.0);
    aiCardOverlap = aiCardWidth * 0.6;

    // AI 카드 (좌우)
  }
}

class HeartsScreen extends StatefulWidget {
  final bool resumeGame;

  const HeartsScreen({super.key, this.resumeGame = false});

  // 저장된 게임이 있는지 확인
  static Future<bool> hasSavedGame() async {
    return await GameSaveService.hasSavedGame('hearts');
  }

  // 저장된 게임 삭제
  static Future<void> clearSavedGame() async {
    await GameSaveService.clearSave();
  }

  @override
  State<HeartsScreen> createState() => _HeartsScreenState();
}

class _HeartsScreenState extends State<HeartsScreen> with TickerProviderStateMixin {
  // 게임 상태
  List<List<PlayingCard>> hands = [[], [], [], []];
  List<PlayingCard?> currentTrick = [null, null, null, null];
  List<List<PlayingCard>> wonCards = [[], [], [], []];
  List<int> scores = [0, 0, 0, 0];

  // 패싱
  List<PlayingCard> selectedForPassing = [];
  List<List<PlayingCard>> cardsToReceive = [[], [], [], []];
  List<double> shootMoonChances = [0.0, 0.0, 0.0, 0.0]; // 테스트용: 슛더문 확률

  // 게임 진행
  GamePhase phase = GamePhase.passing;
  int currentPlayer = 0;
  int leadPlayer = 0;
  int trickNumber = 0;
  bool heartsBroken = false;
  bool isProcessingTrick = false;
  List<PlayingCard> playedCards = []; // 플레이된 카드 추적

  // UI
  String message = '';
  Timer? _messageTimer;
  bool _showHint = false; // 힌트 표시 여부

  List<String> _getPlayerNames(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [l10n.player, l10n.aiPlayer1, l10n.aiPlayer2, l10n.aiPlayer3];
  }

  @override
  void initState() {
    super.initState();
    if (widget.resumeGame) {
      _loadGame();
    } else {
      _startNewGame();
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
  }

  // 게임 상태 저장
  Future<void> _saveGame() async {
    final gameState = {
      'hands': hands.map((hand) => hand.map((c) => c.toJson()).toList()).toList(),
      'currentTrick': currentTrick.map((c) => c?.toJson()).toList(),
      'wonCards': wonCards.map((cards) => cards.map((c) => c.toJson()).toList()).toList(),
      'scores': scores,
      'selectedForPassing': selectedForPassing.map((c) => c.toJson()).toList(),
      'cardsToReceive': cardsToReceive.map((cards) => cards.map((c) => c.toJson()).toList()).toList(),
      'phase': phase.index,
      'currentPlayer': currentPlayer,
      'leadPlayer': leadPlayer,
      'trickNumber': trickNumber,
      'heartsBroken': heartsBroken,
      'isProcessingTrick': isProcessingTrick,
      'playedCards': playedCards.map((c) => c.toJson()).toList(),
    };
    await GameSaveService.saveGame('hearts', gameState);
  }

  // 저장된 게임 불러오기
  Future<void> _loadGame() async {
    final gameState = await GameSaveService.loadGame('hearts');
    if (gameState == null) {
      _startNewGame();
      return;
    }

    setState(() {
      hands = (gameState['hands'] as List).map((hand) =>
        (hand as List).map((c) => PlayingCard.fromJson(c as Map<String, dynamic>)).toList()
      ).toList();

      currentTrick = (gameState['currentTrick'] as List).map((c) =>
        c == null ? null : PlayingCard.fromJson(c as Map<String, dynamic>)
      ).toList();

      wonCards = (gameState['wonCards'] as List).map((cards) =>
        (cards as List).map((c) => PlayingCard.fromJson(c as Map<String, dynamic>)).toList()
      ).toList();

      scores = List<int>.from(gameState['scores'] as List);

      selectedForPassing = (gameState['selectedForPassing'] as List)
        .map((c) => PlayingCard.fromJson(c as Map<String, dynamic>)).toList();

      cardsToReceive = (gameState['cardsToReceive'] as List).map((cards) =>
        (cards as List).map((c) => PlayingCard.fromJson(c as Map<String, dynamic>)).toList()
      ).toList();

      phase = GamePhase.values[gameState['phase'] as int];
      currentPlayer = gameState['currentPlayer'] as int;
      leadPlayer = gameState['leadPlayer'] as int;
      trickNumber = gameState['trickNumber'] as int;
      heartsBroken = gameState['heartsBroken'] as bool;
      isProcessingTrick = gameState['isProcessingTrick'] as bool;

      playedCards = (gameState['playedCards'] as List)
        .map((c) => PlayingCard.fromJson(c as Map<String, dynamic>)).toList();
    });

    // 게임 진행 중인 경우 AI 턴이면 AI가 플레이하도록
    if (phase == GamePhase.playing && currentPlayer != 0 && !isProcessingTrick) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _aiPlayCard();
      });
    }
  }

  void _startNewGame() {
    setState(() {
      hands = [[], [], [], []];
      currentTrick = [null, null, null, null];
      wonCards = [[], [], [], []];
      scores = [0, 0, 0, 0];
      selectedForPassing = [];
      cardsToReceive = [[], [], [], []];
      phase = GamePhase.passing;
      trickNumber = 0;
      heartsBroken = false;
      isProcessingTrick = false;
      playedCards = []; // 플레이된 카드 초기화
      message = '';
      _showHint = false; // 힌트 초기화
    });

    _dealCards();
  }

  void _dealCards() {
    final deck = <PlayingCard>[];
    for (final suit in Suit.values) {
      for (int rank = 2; rank <= 14; rank++) {
        deck.add(PlayingCard(suit, rank));
      }
    }
    deck.shuffle(Random());

    for (int i = 0; i < 52; i++) {
      hands[i % 4].add(deck[i]);
    }

    setState(() {
      // 정렬은 setState 내에서 호출하여 UI 갱신 보장
      for (int i = 0; i < 4; i++) {
        _sortHand(i);
      }
    });

    // AI가 패싱할 카드 선택
    _aiSelectPassingCards();

    // 게임 상태 저장
    _saveGame();
  }

  void _sortHand(int playerIndex) {
    // 정렬: 무늬별 그룹 (♠ > ♥ > ◆ > ♣) → 랭크 내림차순 (A > K > Q > ...)
    final suitOrder = {Suit.spade: 0, Suit.heart: 1, Suit.diamond: 2, Suit.club: 3};
    hands[playerIndex].sort((a, b) {
      final suitA = suitOrder[a.suit]!;
      final suitB = suitOrder[b.suit]!;
      if (suitA != suitB) return suitA - suitB; // 무늬순
      return b.rank - a.rank; // 랭크 내림차순 (높은 것 먼저)
    });
  }

  void _aiSelectPassingCards() {
    // 플레이어(0)의 슛더문 확률도 계산
    shootMoonChances[0] = _checkShootMoonPossibility(hands[0]);

    for (int i = 1; i < 4; i++) {
      final hand = List<PlayingCard>.from(hands[i]);
      final selected = <PlayingCard>[];

      // 수트별 카드 개수 계산
      final suitCounts = {
        Suit.spade: hand.where((c) => c.suit == Suit.spade).length,
        Suit.heart: hand.where((c) => c.suit == Suit.heart).length,
        Suit.diamond: hand.where((c) => c.suit == Suit.diamond).length,
        Suit.club: hand.where((c) => c.suit == Suit.club).length,
      };
      final lowSpadeCount = hand.where((c) => c.suit == Suit.spade && c.rank < 12).length;
      final lowHeartCount = hand.where((c) => c.suit == Suit.heart && c.rank < 10).length;

      // 슛 더 문 가능성 체크
      final shootMoonChance = _checkShootMoonPossibility(hand);
      shootMoonChances[i] = shootMoonChance; // 저장

      // 우선순위 계산하여 정렬
      final handCopy = List<PlayingCard>.from(hand); // 정렬 전 핸드 복사
      hand.sort((a, b) {
        int scoreA = _getPassPriority(a, suitCounts, lowSpadeCount, lowHeartCount, shootMoonChance, handCopy);
        int scoreB = _getPassPriority(b, suitCounts, lowSpadeCount, lowHeartCount, shootMoonChance, handCopy);
        return scoreB.compareTo(scoreA);
      });

      for (int j = 0; j < 3 && j < hand.length; j++) {
        selected.add(hand[j]);
      }

      cardsToReceive[(i + 1) % 4].addAll(selected);
      for (final card in selected) {
        hands[i].remove(card);
      }
    }
  }

  // 슛 더 문 가능성 체크 (0.0 ~ 1.0)
  double _checkShootMoonPossibility(List<PlayingCard> hand) {
    double score = 0.0;

    // 높은 하트 개수 (A, K, Q, J = 14, 13, 12, 11)
    final highHearts = hand.where((c) => c.isHeart && c.rank >= 11).length;
    score += highHearts * 0.15; // 최대 0.6 (4장)

    // 하트 총 개수
    final heartCount = hand.where((c) => c.isHeart).length;
    if (heartCount >= 6) score += 0.15;
    if (heartCount >= 8) score += 0.15;

    // 스페이드 Q 보유
    final hasQueenOfSpades = hand.any((c) => c.isQueenOfSpades);
    if (hasQueenOfSpades) score += 0.1;

    // 높은 스페이드 (A, K)
    final highSpades = hand.where((c) => c.suit == Suit.spade && c.rank >= 13).length;
    score += highSpades * 0.1; // 최대 0.2 (A, K)

    // 다른 수트의 A 개수 (컨트롤)
    final aceCount = hand.where((c) => c.rank == 14).length;
    score += aceCount * 0.05;

    // 보이드 수트 (한 수트가 0장이면 유리)
    final clubCount = hand.where((c) => c.suit == Suit.club).length;
    final diamondCount = hand.where((c) => c.suit == Suit.diamond).length;
    if (clubCount == 0 || diamondCount == 0) score += 0.1;

    return score.clamp(0.0, 1.0);
  }

  // 선 유지 가능 여부 계산 (수트별)
  // 반환: 각 수트별로 이길 수 있는 카드 수
  Map<Suit, int> _calculateLeadPotential(int playerIndex) {
    final hand = hands[playerIndex];
    final result = <Suit, int>{};

    for (final suit in Suit.values) {
      final myCards = hand.where((c) => c.suit == suit).toList();
      if (myCards.isEmpty) {
        result[suit] = 0;
        continue;
      }

      // 아직 플레이되지 않은 상대방 카드 계산
      final remainingCards = <PlayingCard>[];
      for (int rank = 2; rank <= 14; rank++) {
        final card = PlayingCard(suit, rank);
        // 내 카드도 아니고, 이미 플레이된 카드도 아닌 것
        if (!myCards.any((c) => c.rank == rank) &&
            !playedCards.any((c) => c.suit == suit && c.rank == rank)) {
          remainingCards.add(card);
        }
      }

      // 내 카드 중 이길 수 있는 카드 수 계산
      int winningCards = 0;
      myCards.sort((a, b) => b.rank.compareTo(a.rank)); // 높은 순 정렬

      for (final myCard in myCards) {
        // 남은 카드 중 내 카드보다 높은 것이 있는지
        final higherCards = remainingCards.where((c) => c.rank > myCard.rank).length;
        if (higherCards == 0) {
          winningCards++;
          // 이 카드를 내면 다음 높은 카드도 이길 수 있음
          remainingCards.removeWhere((c) => c.rank < myCard.rank);
        } else {
          break; // 이길 수 없으면 나머지도 불가
        }
      }

      result[suit] = winningCards;
    }

    return result;
  }

  // 전체 선 유지 가능성 점수 (0.0 ~ 1.0)
  double _calculateOverallLeadPotential(int playerIndex) {
    final potential = _calculateLeadPotential(playerIndex);
    final hand = hands[playerIndex];

    if (hand.isEmpty) return 0.0;

    int totalWinningCards = 0;
    for (final suit in Suit.values) {
      totalWinningCards += potential[suit]!;
    }

    // 보유 카드 대비 이길 수 있는 카드 비율
    return (totalWinningCards / hand.length).clamp(0.0, 1.0);
  }

  // 해당 카드보다 높은 카드 중 다른 플레이어가 가진 카드 수
  int _countRemainingHigherCards(PlayingCard card, int playerIndex) {
    int count = 0;
    for (int rank = card.rank + 1; rank <= 14; rank++) {
      final higherCard = PlayingCard(card.suit, rank);
      // 이미 플레이된 카드는 제외
      final alreadyPlayed = playedCards.contains(higherCard);
      // 내 손에 있으면 제외 (내가 컨트롤)
      final inMyHand = hands[playerIndex].contains(higherCard);
      if (!alreadyPlayed && !inMyHand) {
        // 다른 플레이어가 가지고 있을 수 있음
        count++;
      }
    }
    return count;
  }

  // 슛더문 해제/활성화 조건 체크
  void _updateShootMoonStatus() {
    for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
      final myPoints = wonCards[playerIndex].fold(0, (sum, c) => sum + c.points);
      final hand = hands[playerIndex];

      // ★ 역전 슛더문 활성화: 이미 점수가 높고(♠Q 등) 강한 하트 보유 시
      if (shootMoonChances[playerIndex] < 0.5) {
        // 다른 플레이어가 점수를 가지고 있는지 확인
        bool otherPlayerHasPoints = false;
        for (int i = 0; i < 4; i++) {
          if (i != playerIndex) {
            final otherPoints = wonCards[i].fold(0, (sum, c) => sum + c.points);
            if (otherPoints > 0) {
              otherPlayerHasPoints = true;
              break;
            }
          }
        }

        // 나만 점수를 가지고 있고, 10점 이상이면 역전 슛더문 검토
        if (!otherPlayerHasPoints && myPoints >= 10) {
          // 강한 하트 보유 확인 (A 또는 K)
          final hasHeartA = hand.any((c) => c.isHeart && c.rank == 14);
          final hasHeartK = hand.any((c) => c.isHeart && c.rank == 13);
          final heartCount = hand.where((c) => c.isHeart).length;

          // 하트 A/K 중 하나 이상 + 하트 3장 이상이면 역전 슛더문 시도
          if ((hasHeartA || hasHeartK) && heartCount >= 3) {
            shootMoonChances[playerIndex] = 0.6; // 역전 슛더문 활성화
            continue;
          }
        }
        continue; // 슛더문 시도 중 아니면 스킵
      }

      // === 이하 기존 슛더문 해제 로직 ===

      // 조건 1: 다른 플레이어가 점수를 획득했는지 확인
      bool otherPlayerHasPoints = false;
      for (int i = 0; i < 4; i++) {
        if (i != playerIndex) {
          final points = wonCards[i].fold(0, (sum, c) => sum + c.points);
          if (points > 0) {
            otherPlayerHasPoints = true;
            break;
          }
        }
      }

      if (otherPlayerHasPoints) {
        shootMoonChances[playerIndex] = 0.0; // 슛더문 해제
        continue;
      }

      // 조건 2: 선유지 가능성이 30% 미만
      final leadPotential = _calculateOverallLeadPotential(playerIndex);
      if (leadPotential < 0.3) {
        shootMoonChances[playerIndex] = 0.0; // 슛더문 해제
        continue;
      }

      // 조건 3: 남은 하트 + 스페이드Q를 모을 수 없는 경우
      final totalPlayedHearts = playedCards.where((c) => c.isHeart).length;
      if (totalPlayedHearts >= 5 && myPoints == 0) {
        // 하트가 5장 이상 나갔는데 내가 하나도 못 먹었으면 해제
        shootMoonChances[playerIndex] = 0.0;
      }
    }
  }

  // ★ 모든 점수 카드(하트 13장 + ♠Q)가 플레이되었는지 체크
  bool _checkAllPointCardsPlayed() {
    final heartsPlayed = playedCards.where((c) => c.isHeart).length;
    final queenOfSpadesPlayed = playedCards.any((c) => c.isQueenOfSpades);
    return heartsPlayed >= 13 && queenOfSpadesPlayed;
  }

  int _getPassPriority(PlayingCard card, Map<Suit, int> suitCounts, int lowSpadeCount, int lowHeartCount, double shootMoonChance, List<PlayingCard> hand) {
    // 높을수록 패스하고 싶은 카드
    final spadeCount = suitCounts[Suit.spade]!;
    final heartCount = suitCounts[Suit.heart]!;
    final clubCount = suitCounts[Suit.club]!;
    final diamondCount = suitCounts[Suit.diamond]!;
    final cardSuitCount = suitCounts[card.suit]!;

    // ★ 슛더문 잠재력 체크: 강한 스페이드 보유 시
    // 조건: 스페이드 5장 이상 + 높은 스페이드(J 이상) 2장 이상
    final highSpades = hand.where((c) => c.suit == Suit.spade && c.rank >= 11).length;
    final hasShootMoonPotential = spadeCount >= 5 && highSpades >= 2;

    // 슛 더 문 가능성이 높거나 잠재력이 있으면
    if (shootMoonChance >= 0.5 || hasShootMoonPotential) {
      // ★ 높은 하트는 보유 (슛더문 핵심)
      if (card.isHeart && card.rank >= 11) return 5; // 보유

      // ★ 모든 스페이드 보유 (슛더문 실패 시 ♠Q 방어용)
      // 슛더문 시도 중 스페이드를 버리면 실패 시 ♠Q를 받을 위험이 큼
      if (card.suit == Suit.spade) return 10 + (14 - card.rank); // 모든 스페이드 보유

      // ★ 보이드 만들기: 클럽/다이아만 대상 (스페이드는 보유)
      if ((card.suit == Suit.club || card.suit == Suit.diamond) && cardSuitCount == 1) {
        return 800 + (14 - card.rank); // 1장만 있으면 최우선 패스
      }
      if ((card.suit == Suit.club || card.suit == Suit.diamond) && cardSuitCount == 2) {
        return 700 + (14 - card.rank); // 2장이면 우선 패스
      }

      // 낮은 카드를 패스 (클럽/다이아만)
      if ((card.suit == Suit.club || card.suit == Suit.diamond) && card.rank <= 8) {
        return 600 + (14 - card.rank);
      }

      // 하트 낮은 카드 (슛더문에 필요하지만 높은 하트보다는 낮음)
      if (card.isHeart) return 20 + card.rank; // 보유

      // 그 외 클럽/다이아 높은 카드
      return 50 + card.rank;
    }

    // ★ 완전 보이드 패스: 정확히 3장인 무늬를 최우선 패스
    // 3장을 모두 버리면 그 무늬가 리드될 때 하트나 ♠Q를 넘길 수 있음
    // 특히 스페이드가 많으면(5장+) Q 방어가 가능하므로 다른 무늬 보이드가 유리
    final canDefendSpadeQ = spadeCount >= 5 && lowSpadeCount >= 3;

    // 정확히 3장인 무늬 찾기 (클럽/다이아만 대상)
    Suit? exactThreeSuit;
    if (diamondCount == 3) {
      exactThreeSuit = Suit.diamond;
    } else if (clubCount == 3) {
      exactThreeSuit = Suit.club;
    }

    // 정확히 3장인 무늬가 있으면 해당 무늬 전체를 최우선 패스
    if (exactThreeSuit != null && card.suit == exactThreeSuit) {
      // 스페이드 방어 가능하면 더 높은 우선순위
      final bonus = canDefendSpadeQ ? 100 : 0;
      return 900 + bonus + card.rank; // 최우선 패스
    }

    // ★ 보이드 집중 패스: 클럽/다이아 중 3장 이하인 무늬 찾기
    // 같은 무늬에서 집중 패스하면 보이드 생성 확률 증가
    final voidTargetSuit = (clubCount <= 3 && clubCount > 0 && clubCount < 3 && (diamondCount == 0 || clubCount <= diamondCount))
        ? Suit.club
        : (diamondCount <= 3 && diamondCount > 0 && diamondCount < 3)
            ? Suit.diamond
            : null;

    if (voidTargetSuit != null && card.suit == voidTargetSuit) {
      // 보이드 타겟 무늬의 카드는 높은 우선순위로 패스
      // 높은 카드일수록 우선 패스 (위험 카드 제거)
      return 700 + card.rank;
    }

    // ★ 스페이드 J,10,9: 낮은 스페이드가 많으면 방어용으로 보유
    // 낮은 스페이드로 따라가면서 높은 스페이드는 안전하게 보유
    if (card.suit == Suit.spade && card.rank >= 9 && card.rank <= 11) {
      if (lowSpadeCount >= 3) return 20 + card.rank; // 안전 - 보유
      if (lowSpadeCount >= 2 && spadeCount >= 4) return 40 + card.rank; // 비교적 안전
    }

    // 일반 패싱 로직
    // 스페이드 Q: 스페이드가 5장 이상이고 낮은 스페이드가 3장 이상이면 방어 가능
    if (card.isQueenOfSpades) {
      if (spadeCount >= 5 && lowSpadeCount >= 3) return 50; // 보유 가능
      if (spadeCount >= 4 && lowSpadeCount >= 2) return 500; // 약간 위험
      return 1000; // 위험 - 패스
    }

    // 스페이드 K, A: 스페이드가 많으면 방어 가능
    if (card.suit == Suit.spade && card.rank >= 13) {
      if (spadeCount >= 5 && lowSpadeCount >= 3) return 30 + card.rank; // 보유 가능
      if (spadeCount >= 4) return 200 + card.rank; // 약간 위험
      return 500 + card.rank; // 위험 - 패스
    }

    // 높은 하트 (10+): 하트가 많고 낮은 하트가 충분하면 방어 가능
    if (card.isHeart && card.rank >= 10) {
      // 낮은 하트가 대부분이면 높은 하트를 내지 않고 방어 가능
      // 조건: 하트 4장 이상 + 낮은 하트가 (전체 하트 - 1) 이상 = 높은 하트 1장 이하
      if (heartCount >= 4 && lowHeartCount >= heartCount - 1) return 15 + card.rank; // 안전 - 보유
      if (heartCount >= 5 && lowHeartCount >= 3) return 20 + card.rank; // 보유 가능
      if (heartCount >= 4 && lowHeartCount >= 2) return 80 + card.rank; // 비교적 안전
      return 300 + card.rank; // 위험 - 패스
    }

    // 다른 높은 카드 (K, Q, A) - 보이드 타겟이 아닌 경우
    if (card.rank >= 12) return 100 + card.rank;

    // 낮은 카드는 보유
    return card.rank;
  }

  // ★ 플레이어용 패싱 추천 카드 계산 (우선순위 높은 3장)
  List<PlayingCard> _getRecommendedPassingCards() {
    final hand = List<PlayingCard>.from(hands[0]);
    if (hand.length < 3) return [];

    // 수트별 카드 개수 계산
    final suitCounts = {
      Suit.spade: hand.where((c) => c.suit == Suit.spade).length,
      Suit.heart: hand.where((c) => c.suit == Suit.heart).length,
      Suit.diamond: hand.where((c) => c.suit == Suit.diamond).length,
      Suit.club: hand.where((c) => c.suit == Suit.club).length,
    };
    final lowSpadeCount = hand.where((c) => c.suit == Suit.spade && c.rank < 12).length;
    final lowHeartCount = hand.where((c) => c.suit == Suit.heart && c.rank < 10).length;

    // 슛 더 문 가능성 체크
    final shootMoonChance = _checkShootMoonPossibility(hand);

    // 우선순위 계산하여 정렬
    final handCopy = List<PlayingCard>.from(hand);
    hand.sort((a, b) {
      int scoreA = _getPassPriority(a, suitCounts, lowSpadeCount, lowHeartCount, shootMoonChance, handCopy);
      int scoreB = _getPassPriority(b, suitCounts, lowSpadeCount, lowHeartCount, shootMoonChance, handCopy);
      return scoreB.compareTo(scoreA); // 높은 우선순위 먼저
    });

    // 상위 3장 반환
    return hand.take(3).toList();
  }

  void _toggleCardForPassing(PlayingCard card) {
    if (phase != GamePhase.passing) return;

    setState(() {
      if (selectedForPassing.contains(card)) {
        selectedForPassing.remove(card);
      } else if (selectedForPassing.length < 3) {
        selectedForPassing.add(card);
      }
    });
    HapticFeedback.lightImpact();
  }

  void _confirmPassing() {
    if (selectedForPassing.length != 3) return;

    // 플레이어의 패싱 카드를 왼쪽(플레이어 1)에게 전달
    cardsToReceive[1].addAll(selectedForPassing);
    for (final card in selectedForPassing) {
      hands[0].remove(card);
    }

    // 모든 플레이어에게 받을 카드 추가
    for (int i = 0; i < 4; i++) {
      hands[i].addAll(cardsToReceive[i]);
    }

    // 클럽 2를 가진 플레이어 찾기
    int startPlayer = 0;
    for (int i = 0; i < 4; i++) {
      if (hands[i].any((c) => c.suit == Suit.club && c.rank == 2)) {
        startPlayer = i;
        break;
      }
    }

    setState(() {
      // 정렬은 setState 내에서 호출하여 UI 갱신 보장
      for (int i = 0; i < 4; i++) {
        _sortHand(i);
      }
      selectedForPassing = [];
      cardsToReceive = [[], [], [], []];
      phase = GamePhase.playing;
      currentPlayer = startPlayer;
      leadPlayer = startPlayer;
      trickNumber = 1;
    });

    // 게임 상태 저장
    _saveGame();

    final l10n = AppLocalizations.of(context)!;
    final playerNames = _getPlayerNames(context);
    _showMessage(l10n.playerStartsWithClub2(playerNames[startPlayer]));

    if (startPlayer != 0) {
      Future.delayed(const Duration(milliseconds: 1000), () {
        _aiPlayCard();
      });
    }
  }

  void _showMessage(String msg) {
    setState(() {
      message = msg;
    });
    _messageTimer?.cancel();
    _messageTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          message = '';
        });
      }
    });
  }

  List<PlayingCard> _getPlayableCards(int playerIndex) {
    final hand = hands[playerIndex];
    if (hand.isEmpty) return [];

    // 첫 트릭의 선공은 클럽 2를 내야 함
    if (trickNumber == 1 && currentTrick.every((c) => c == null)) {
      final club2 = hand.where((c) => c.suit == Suit.club && c.rank == 2).toList();
      if (club2.isNotEmpty) return club2;
    }

    // 선공이면
    if (currentTrick.every((c) => c == null)) {
      // 하트가 브레이킹되지 않았으면 하트로 시작 불가 (다른 카드가 있을 때)
      if (!heartsBroken) {
        final nonHearts = hand.where((c) => !c.isHeart).toList();
        if (nonHearts.isNotEmpty) return nonHearts;
      }
      return hand;
    }

    // 따라가기
    final leadSuit = currentTrick[leadPlayer]!.suit;
    final sameSuit = hand.where((c) => c.suit == leadSuit).toList();
    if (sameSuit.isNotEmpty) return sameSuit;

    // 첫 트릭에는 점수 카드 불가 (다른 카드가 있을 때)
    if (trickNumber == 1) {
      final nonPoints = hand.where((c) => c.points == 0).toList();
      if (nonPoints.isNotEmpty) return nonPoints;
    }

    return hand;
  }

  void _playCard(PlayingCard card) {
    if (phase != GamePhase.playing || isProcessingTrick) return;
    if (currentPlayer != 0) return;

    final playable = _getPlayableCards(0);
    if (!playable.contains(card)) return;

    _executePlayCard(0, card);
  }

  void _executePlayCard(int playerIndex, PlayingCard card) {
    setState(() {
      hands[playerIndex].remove(card);
      currentTrick[playerIndex] = card;
      playedCards.add(card); // 플레이된 카드 추적

      if (card.isHeart) {
        heartsBroken = true;
      }
    });

    HapticFeedback.lightImpact();
    _saveGame(); // 게임 상태 저장

    // 다음 플레이어
    final nextPlayer = (playerIndex + 1) % 4;

    // 트릭 완료 체크
    if (currentTrick.every((c) => c != null)) {
      _processTrickEnd();
    } else {
      setState(() {
        currentPlayer = nextPlayer;
      });

      if (nextPlayer != 0) {
        Future.delayed(const Duration(milliseconds: 600), () {
          _aiPlayCard();
        });
      }
    }
  }

  void _aiPlayCard() {
    if (phase != GamePhase.playing || isProcessingTrick) return;
    if (currentPlayer == 0) return;

    // ★ AI 턴 시작 시 슛더문 상태 업데이트 (역전 슛더문 활성화 체크)
    _updateShootMoonStatus();

    final playable = _getPlayableCards(currentPlayer);
    if (playable.isEmpty) return;

    PlayingCard selectedCard = _selectBestCard(currentPlayer, playable);
    _executePlayCard(currentPlayer, selectedCard);
  }

  // ★ 슛더문 위협 감지: 특정 플레이어가 20점 이상이고 다른 플레이어가 0점일 때
  int? _detectShootMoonThreat(int myIndex) {
    for (int i = 0; i < 4; i++) {
      if (i == myIndex) continue;
      // 상대가 20점 이상 (6점만 더 필요)
      if (scores[i] >= 20) {
        // 다른 모든 플레이어가 0점인지 확인
        bool othersHaveZero = true;
        for (int j = 0; j < 4; j++) {
          if (j != i && scores[j] > 0) {
            othersHaveZero = false;
            break;
          }
        }
        if (othersHaveZero) return i;
      }
    }
    return null;
  }

  PlayingCard _selectBestCard(int playerIndex, List<PlayingCard> playable) {
    // 슛더문 시도 중인지 확인
    final isShootingMoon = shootMoonChances[playerIndex] >= 0.5;

    // ★ 슛더문 방어: 상대가 슛더문 근접 시
    final shootMoonThreat = _detectShootMoonThreat(playerIndex);

    // 선공이면
    if (currentTrick.every((c) => c == null)) {
      // ★ 슛더문 시도 중 선공 전략
      if (isShootingMoon) {
        // ★ 하트 브레이킹 후: 가장 높은 하트로 선공 (모든 하트를 먹어야 함)
        if (heartsBroken) {
          final hearts = playable.where((c) => c.isHeart).toList();
          if (hearts.isNotEmpty) {
            hearts.sort((a, b) => b.rank.compareTo(a.rank)); // 높은 순
            return hearts.first; // 가장 높은 하트 (A, K, Q 순)
          }
        }

        // ★ 슛더문 시 Ace가 있으면 무조건 먼저 (확실한 승리)
        final aces = playable.where((c) => c.rank == 14 && !c.isHeart).toList();
        if (aces.isNotEmpty) {
          // 스페이드 A > 클럽 A > 다이아 A 순서 (스페이드가 더 위험하므로 먼저 처리)
          aces.sort((a, b) {
            if (a.suit == Suit.spade) return -1;
            if (b.suit == Suit.spade) return 1;
            return 0;
          });
          return aces.first;
        }

        // ★ Ace가 없으면 King으로 A 유도 또는 확실한 승리 카드 찾기
        List<PlayingCard> sureWins = [];
        List<PlayingCard> flushCards = [];

        for (final suit in Suit.values) {
          if (suit == Suit.heart) continue;

          final suitCards = playable.where((c) => c.suit == suit).toList();
          if (suitCards.isEmpty) continue;

          suitCards.sort((a, b) => b.rank.compareTo(a.rank));
          final highestInSuit = suitCards.first;
          final remainingHigher = _countRemainingHigherCards(highestInSuit, playerIndex);

          if (remainingHigher == 0) {
            sureWins.add(highestInSuit);
          } else if (remainingHigher == 1 && suitCards.length >= 2) {
            // K로 A 유도 가능
            final secondHighest = suitCards[1];
            final remainingAfterFlush = _countRemainingHigherCards(secondHighest, playerIndex) - 1;
            if (remainingAfterFlush <= 0) {
              flushCards.add(highestInSuit);
            }
          }
        }

        // 확실히 이기는 카드가 있으면 사용 (높은 순)
        if (sureWins.isNotEmpty) {
          sureWins.sort((a, b) => b.rank.compareTo(a.rank));
          return sureWins.first;
        }

        // A 유도 카드가 있으면 사용
        if (flushCards.isNotEmpty) {
          // 스페이드 우선 (♠Q 보호를 위해 ♠K로 ♠A 유도)
          final spadeFlush = flushCards.where((c) => c.suit == Suit.spade).toList();
          if (spadeFlush.isNotEmpty) {
            return spadeFlush.first;
          }
          // 그 외 클럽/다이아
          flushCards.sort((a, b) => b.rank.compareTo(a.rank));
          return flushCards.first;
        }

        // 이길 수 있는 리드가 없으면 슛더문 해제
        shootMoonChances[playerIndex] = 0.0;
      }

      // ★ 스페이드 Q 유도 전략
      // 조건: 스페이드 Q가 아직 안 나왔고, 내가 가지고 있지 않음
      final queenOfSpadesPlayed = playedCards.any((c) => c.isQueenOfSpades);
      final iHaveQueenOfSpades = playable.any((c) => c.isQueenOfSpades);

      if (!queenOfSpadesPlayed && !iHaveQueenOfSpades) {
        // 낮은 스페이드가 있으면 우선 공격 (Q 유도)
        final lowSpades = playable
            .where((c) => c.suit == Suit.spade && c.rank < 12) // Q(12) 미만
            .toList();
        if (lowSpades.isNotEmpty) {
          lowSpades.sort((a, b) => a.rank.compareTo(b.rank));
          return lowSpades.first; // 가장 낮은 스페이드로 공격
        }
      }

      // ★ 스페이드 Q가 나왔거나 스페이드가 없으면 낮은 하트 선공
      final hasSpades = playable.any((c) => c.suit == Suit.spade && !c.isQueenOfSpades);
      if ((queenOfSpadesPlayed || !hasSpades) && heartsBroken) {
        final lowHearts = playable.where((c) => c.isHeart).toList();
        if (lowHearts.isNotEmpty) {
          lowHearts.sort((a, b) => a.rank.compareTo(b.rank));
          return lowHearts.first; // 가장 낮은 하트로 공격
        }
      }

      // ★ 한 번도 나오지 않은 무늬가 있으면 최상위 카드 선공
      // (다른 플레이어가 해당 무늬를 가지고 있을 확률 높음 → 안전하게 높은 카드 처리)
      final playedSuits = playedCards.map((c) => c.suit).toSet();
      for (final suit in [Suit.club, Suit.diamond]) {
        // 클럽, 다이아만 체크 (하트/스페이드는 위험)
        if (!playedSuits.contains(suit)) {
          final unplayedSuitCards = playable
              .where((c) => c.suit == suit)
              .toList();
          if (unplayedSuitCards.isNotEmpty) {
            unplayedSuitCards.sort((a, b) => b.rank.compareTo(a.rank));
            return unplayedSuitCards.first; // 최상위 카드
          }
        }
      }

      // ★ 슛더문 방어: 상대가 슛더문 근접 시 하트로 선공하여 직접 획득
      if (shootMoonThreat != null && heartsBroken) {
        // 높은 하트로 선공하여 직접 하트를 가져옴 (슛더문 저지)
        final hearts = playable.where((c) => c.isHeart).toList();
        if (hearts.isNotEmpty) {
          hearts.sort((a, b) => b.rank.compareTo(a.rank)); // 높은 순
          return hearts.first;
        }
      }

      // 기본: 낮은 카드 선호, 하트/스페이드 퀸 피하기
      playable.sort((a, b) {
        if (a.isQueenOfSpades) return 1;
        if (b.isQueenOfSpades) return -1;
        if (a.isHeart && !b.isHeart) return 1;
        if (!a.isHeart && b.isHeart) return -1;
        return a.rank.compareTo(b.rank);
      });
      return playable.first;
    }

    // 따라가기
    final leadCard = currentTrick[leadPlayer]!;
    final leadSuit = leadCard.suit;
    final sameSuitCards = playable.where((c) => c.suit == leadSuit).toList();

    if (sameSuitCards.isNotEmpty) {
      // 같은 무늬가 있으면
      // 현재 트릭의 최고 카드 찾기
      int highestRank = leadCard.rank;
      for (final card in currentTrick) {
        if (card != null && card.suit == leadSuit && card.rank > highestRank) {
          highestRank = card.rank;
        }
      }

      final playedCount = currentTrick.where((c) => c != null).length;
      final isLastPlayer = playedCount == 3;
      final canWin = sameSuitCards.where((c) => c.rank > highestRank).toList();
      final cantWin = sameSuitCards.where((c) => c.rank <= highestRank).toList();
      final hasPointsInTrick = currentTrick.any((c) => c != null && c.points > 0);

      // ★ 슛더문 시도 중
      if (isShootingMoon) {
        // 이길 수 있을 때: 스페이드Q는 나중에 (다른 카드로 이기기)
        if (canWin.isNotEmpty) {
          final withoutQueen = canWin.where((c) => !c.isQueenOfSpades).toList();
          if (withoutQueen.isNotEmpty) {
            // Q 제외하고 가장 낮은 승리 카드 (Q 보존)
            withoutQueen.sort((a, b) => a.rank.compareTo(b.rank));
            return withoutQueen.first;
          }
          // Q만 이길 수 있으면 Q 냄
          return canWin.first;
        }
        // 이길 수 없으면 가장 낮은 카드
        sameSuitCards.sort((a, b) => a.rank.compareTo(b.rank));
        return sameSuitCards.first;
      }

      // ★ 슛더문 방어: 상대가 슛더문 근접 시 트릭을 이겨서 점수 가져오기
      if (shootMoonThreat != null && hasPointsInTrick) {
        // 현재 트릭에 점수 카드가 있고, 위협 플레이어가 이길 것 같으면
        // 내가 이길 수 있으면 이겨서 점수를 가져옴 (슛더문 방지)
        if (canWin.isNotEmpty) {
          // 가장 낮은 승리 카드로 이기기
          canWin.sort((a, b) => a.rank.compareTo(b.rank));
          return canWin.first;
        }
      }

      // ★ 마지막 순서 + 결과 확정 (모든 카드로 이김 또는 모든 카드로 짐) + 슛더문 아님
      final allCardsWin = sameSuitCards.every((c) => c.rank > highestRank);
      final allCardsLose = canWin.isEmpty;
      if (isLastPlayer && !isShootingMoon && (allCardsWin || allCardsLose)) {
        if (allCardsLose) {
          // 지는 상황: 스페이드 Q 우선 버리기 (상대에게 13점 벌점)
          final queenOfSpades = sameSuitCards.where((c) => c.isQueenOfSpades).toList();
          if (queenOfSpades.isNotEmpty) return queenOfSpades.first;
          // Q 없으면 가장 높은 카드
          sameSuitCards.sort((a, b) => b.rank.compareTo(a.rank));
          return sameSuitCards.first;
        } else {
          // 이기는 상황: Q 제외하고 가장 높은 카드 (Q 내면 내가 먹으므로)
          final safeHighCards = sameSuitCards.where((c) => !c.isQueenOfSpades).toList();
          if (safeHighCards.isNotEmpty) {
            safeHighCards.sort((a, b) => b.rank.compareTo(a.rank));
            return safeHighCards.first;
          }
          sameSuitCards.sort((a, b) => b.rank.compareTo(a.rank));
          return sameSuitCards.first;
        }
      }

      // 점수 트릭이면 피하기 (Q 제외)
      if (hasPointsInTrick && cantWin.isNotEmpty) {
        final withoutQueen = cantWin.where((c) => !c.isQueenOfSpades).toList();
        if (withoutQueen.isNotEmpty) {
          withoutQueen.sort((a, b) => b.rank.compareTo(a.rank));
          return withoutQueen.first;
        }
        cantWin.sort((a, b) => b.rank.compareTo(a.rank));
        return cantWin.first;
      }

      // 낮은 카드로 안전하게 (Q 제외)
      final withoutQueen = sameSuitCards.where((c) => !c.isQueenOfSpades).toList();
      if (withoutQueen.isNotEmpty) {
        withoutQueen.sort((a, b) => a.rank.compareTo(b.rank));
        return withoutQueen.first;
      }
      sameSuitCards.sort((a, b) => a.rank.compareTo(b.rank));
      return sameSuitCards.first;
    } else {
      // 다른 무늬 - 점수 카드 버리기 기회

      // ★ 슛더문 시도 중이면 선유지 가능한 카드 보유
      if (isShootingMoon) {
        final hand = hands[playerIndex];
        final leadPotential = _calculateLeadPotential(playerIndex);

        // 점수 없는 카드 중 버릴 카드 선택
        final nonPointCards = playable.where((c) => c.points == 0).toList();
        if (nonPointCards.isNotEmpty) {
          nonPointCards.sort((a, b) {
            // 선유지 가능성 (낮을수록 우선 버림)
            final potentialA = leadPotential[a.suit]!;
            final potentialB = leadPotential[b.suit]!;
            if (potentialA != potentialB) return potentialA.compareTo(potentialB);

            // 수트 개수 (적을수록 우선 버림)
            final countA = hand.where((c) => c.suit == a.suit).length;
            final countB = hand.where((c) => c.suit == b.suit).length;
            if (countA != countB) return countA.compareTo(countB);

            // 같은 수트면 낮은 카드 우선 버림 (높은 카드 보유)
            return a.rank.compareTo(b.rank);
          });
          return nonPointCards.first;
        }
        // 점수 카드만 있으면 가장 낮은 하트
        final hearts = playable.where((c) => c.isHeart).toList();
        if (hearts.isNotEmpty) {
          hearts.sort((a, b) => a.rank.compareTo(b.rank));
          return hearts.first;
        }
        return playable.first;
      }

      // ★ 슛더문 방어: 상대가 슛더문 근접 시
      if (shootMoonThreat != null) {
        // 현재 트릭에서 누가 이기고 있는지 확인
        int currentWinner = leadPlayer;
        int highestRank = currentTrick[leadPlayer]!.rank;
        final trickLeadSuit = currentTrick[leadPlayer]!.suit;

        for (int i = 0; i < 4; i++) {
          final card = currentTrick[i];
          if (card != null && card.suit == trickLeadSuit && card.rank > highestRank) {
            highestRank = card.rank;
            currentWinner = i;
          }
        }

        // 위협 플레이어가 이기고 있으면 → 점수 카드 주지 않음
        if (currentWinner == shootMoonThreat) {
          final nonPointCards = playable.where((c) => c.points == 0).toList();
          if (nonPointCards.isNotEmpty) {
            nonPointCards.sort((a, b) => b.rank.compareTo(a.rank));
            return nonPointCards.first;
          }
        } else {
          // 다른 플레이어가 이기고 있으면 → 하트 버려서 슛더문 깨기!
          final hearts = playable.where((c) => c.isHeart).toList();
          if (hearts.isNotEmpty) {
            hearts.sort((a, b) => b.rank.compareTo(a.rank)); // 높은 하트 우선
            return hearts.first;
          }
          // 스페이드 Q도 버리기
          final queenOfSpades = playable.where((c) => c.isQueenOfSpades).toList();
          if (queenOfSpades.isNotEmpty) return queenOfSpades.first;
        }
      }

      // ★ 일반: 트릭 승자 확인 후 버리기 전략 결정
      // 현재 트릭에서 누가 이기고 있는지 확인
      int currentWinner = leadPlayer;
      int highestRank = currentTrick[leadPlayer]!.rank;
      final trickLeadSuit = currentTrick[leadPlayer]!.suit;

      for (int i = 0; i < 4; i++) {
        final card = currentTrick[i];
        if (card != null && card.suit == trickLeadSuit && card.rank > highestRank) {
          highestRank = card.rank;
          currentWinner = i;
        }
      }

      // 한 명만 점수를 가지고 있는지 확인 (슛더문 가능성)
      int playersWithPoints = 0;
      int soloScorer = -1;
      for (int i = 0; i < 4; i++) {
        if (scores[i] > 0) {
          playersWithPoints++;
          soloScorer = i;
        }
      }
      final isSoloScorerSituation = playersWithPoints == 1 && soloScorer != -1;

      // ★ 트릭 승자가 점수 독점자면 → 점수 카드 주지 않기 (슛더문 방지)
      // (승자가 독점자가 아니면 일반 로직으로 하트 버리기)
      if (isSoloScorerSituation && currentWinner == soloScorer) {
        // 독점자가 모든 하트를 가지고 있는지 확인 (슛더문 확정 상황)
        final soloScorerHearts = wonCards[soloScorer].where((c) => c.isHeart).length;
        final totalHeartsPlayed = playedCards.where((c) => c.isHeart).length;
        final isShootMoonConfirmed = soloScorerHearts == totalHeartsPlayed && soloScorerHearts > 0;

        // 슛더문 확정이 아니면 스페이드 Q 먼저 버리기 (13점 부담 제거)
        if (!isShootMoonConfirmed) {
          final queenOfSpades = playable.where((c) => c.isQueenOfSpades).toList();
          if (queenOfSpades.isNotEmpty) return queenOfSpades.first;
        }

        // 슛더문 확정이면 비점수 카드만 (Q 주지 않음)
        final nonPointCards = playable.where((c) => c.points == 0).toList();
        if (nonPointCards.isNotEmpty) {
          nonPointCards.sort((a, b) => b.rank.compareTo(a.rank));
          return nonPointCards.first;
        }
      }

      // 일반 상황: 높은 카드 우선 버리기
      // 1. 스페이드 퀸 우선
      final queenOfSpades = playable.where((c) => c.isQueenOfSpades).toList();
      if (queenOfSpades.isNotEmpty) return queenOfSpades.first;

      // 2. 높은 하트 (A부터)
      final hearts = playable.where((c) => c.isHeart).toList();
      if (hearts.isNotEmpty) {
        hearts.sort((a, b) => b.rank.compareTo(a.rank));
        return hearts.first;
      }

      // 3. 높은 스페이드 (K, A) - ♠Q가 아직 안 나왔을 때만 위험
      final queenOfSpadesPlayed = playedCards.any((c) => c.isQueenOfSpades);
      if (!queenOfSpadesPlayed) {
        final highSpades = playable.where((c) => c.suit == Suit.spade && c.rank >= 13).toList();
        if (highSpades.isNotEmpty) {
          highSpades.sort((a, b) => b.rank.compareTo(a.rank));
          return highSpades.first;
        }
      }

      // 4. 선유지 가능성 낮은 카드 우선 버리기
      final leadPotential = _calculateLeadPotential(playerIndex);
      playable.sort((a, b) {
        // 선유지 가능성 (낮을수록 우선 버림) - 이길 수 없는 높은 카드 제거
        final potentialA = leadPotential[a.suit]!;
        final potentialB = leadPotential[b.suit]!;
        if (potentialA != potentialB) return potentialA.compareTo(potentialB);

        // 같은 선유지면 높은 카드 우선 버림
        return b.rank.compareTo(a.rank);
      });
      return playable.first;
    }
  }

  void _processTrickEnd() {
    setState(() {
      isProcessingTrick = true;
    });

    // 승자 결정
    final leadSuit = currentTrick[leadPlayer]!.suit;
    int winnerIndex = leadPlayer;
    int highestRank = currentTrick[leadPlayer]!.rank;

    for (int i = 0; i < 4; i++) {
      final card = currentTrick[i]!;
      if (card.suit == leadSuit && card.rank > highestRank) {
        highestRank = card.rank;
        winnerIndex = i;
      }
    }

    // 점수 계산
    int trickPoints = 0;
    for (final card in currentTrick) {
      trickPoints += card!.points;
      wonCards[winnerIndex].add(card);
    }
    scores[winnerIndex] += trickPoints;

    // 슛더문 상태 업데이트
    _updateShootMoonStatus();

    final l10n = AppLocalizations.of(context)!;
    final playerNames = _getPlayerNames(context);
    _showMessage(l10n.playerWonTrick(playerNames[winnerIndex], trickPoints));

    // winnerIndex를 final로 캡처하여 클로저 문제 방지
    final winner = winnerIndex;

    // ★ 모든 점수 카드가 나왔는지 체크 (하트 13장 + ♠Q)
    final allPointCardsPlayed = _checkAllPointCardsPlayed();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      // 게임 종료 체크: 13트릭 완료 OR 모든 점수 카드 소진
      final normalEnd = trickNumber >= 13;
      final earlyEnd = allPointCardsPlayed && !normalEnd;
      final gameEnded = normalEnd || earlyEnd;

      setState(() {
        currentTrick = [null, null, null, null];
        trickNumber++;
        isProcessingTrick = false;

        if (!gameEnded) {
          leadPlayer = winner;
          currentPlayer = winner;
        }
      });

      if (gameEnded) {
        if (earlyEnd) {
          final l10n = AppLocalizations.of(context)!;
          _showMessage(l10n.allScoreCardsUsed);
        }
        _endRound();
      } else {
        _saveGame(); // 게임 상태 저장
        if (winner != 0) {
          Future.delayed(const Duration(milliseconds: 500), () {
            _aiPlayCard();
          });
        }
      }
    });
  }

  void _endRound() {
    // 슈팅 더 문 체크
    int shooterIndex = -1;
    for (int i = 0; i < 4; i++) {
      if (scores[i] == 26) {
        shooterIndex = i;
        break;
      }
    }

    List<int> finalScores;
    if (shooterIndex >= 0) {
      // 슈팅 더 문 성공
      finalScores = [26, 26, 26, 26];
      finalScores[shooterIndex] = 0;
      final l10n = AppLocalizations.of(context)!;
      final playerNames = _getPlayerNames(context);
      _showMessage(l10n.playerShootMoonSuccess(playerNames[shooterIndex]));
    } else {
      finalScores = List<int>.from(scores);
    }

    // 승자 결정 (가장 낮은 점수)
    int minScore = finalScores.reduce(min);
    int winnerId = finalScores.indexOf(minScore);

    setState(() {
      scores = finalScores;
      phase = GamePhase.roundEnd;
    });

    // 저장된 게임 삭제 (게임 종료)
    GameSaveService.clearSave();

    // 통계 저장
    final statsService = Provider.of<HeartsStatsService>(context, listen: false);
    statsService.recordGameResult(
      winnerId: winnerId,
      roundScores: finalScores,
    );
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final screenWidth = mediaQuery.size.width;
    final isSmallScreen = screenHeight < 600;
    final sizes = _HeartsResponsiveSizes(screenHeight, screenWidth);

    return Scaffold(
      backgroundColor: Colors.red[900],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // 상단 정보 바
                      _buildTopBar(isSmallScreen),

                      // 상대방 핸드 (위)
                      _buildOpponentHand(2, isSmallScreen, sizes),

                      // 중앙 영역 (좌우 상대방 + 트릭)
                      Expanded(
                        child: Row(
                          children: [
                            // 왼쪽 상대방
                            _buildSideOpponent(1, isSmallScreen, sizes),

                            // 중앙 트릭 영역
                            Expanded(
                              child: _buildCenterArea(isSmallScreen, sizes),
                            ),

                            // 오른쪽 상대방
                            _buildSideOpponent(3, isSmallScreen, sizes),
                          ],
                        ),
                      ),

                      // 플레이어 핸드
                      _buildPlayerHand(isSmallScreen, sizes),
                    ],
                  ),

                  // 메시지 오버레이
                  if (message.isNotEmpty)
                    Positioned(
                      top: screenHeight * 0.4,
                      left: 20,
                      right: 20,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            message,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                  // 패싱 확인 버튼 (화면 중앙)
                  if (phase == GamePhase.passing)
                    Positioned.fill(
                      child: Center(
                        child: ElevatedButton(
                          onPressed: selectedForPassing.length == 3 ? _confirmPassing : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            disabledBackgroundColor: Colors.grey,
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 24 : 32,
                              vertical: isSmallScreen ? 12 : 16,
                            ),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.passLeftCount(selectedForPassing.length),
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // 게임 종료 오버레이
                  if (phase == GamePhase.roundEnd)
                    _buildGameEndOverlay(isSmallScreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isSmallScreen ? 6 : 10,
      ),
      color: Colors.black26,
      child: Row(
        children: [
          IconButton(
            onPressed: _exitGame,
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Text(
                phase == GamePhase.passing
                    ? l10n.cardPass
                    : l10n.trickProgress(trickNumber),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const Spacer(),
          if (heartsBroken)
            Flexible(
              child: Builder(
                builder: (context) => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.favorite, color: Colors.red, size: isSmallScreen ? 16 : 20),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        AppLocalizations.of(context)!.heartBroken,
                        style: TextStyle(
                          color: Colors.red[300],
                          fontSize: isSmallScreen ? 11 : 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(width: 8),
          // 힌트 버튼
          if (phase != GamePhase.roundEnd)
            Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                return TextButton.icon(
                  onPressed: _onHintButtonPressed,
                  icon: Icon(
                    Icons.lightbulb,
                    color: _showHint ? Colors.yellow : Colors.green,
                    size: isSmallScreen ? 16 : 18,
                  ),
                  label: Text(
                    _showHint ? l10n.hintOff : l10n.hint,
                    style: TextStyle(
                      color: _showHint ? Colors.yellow : Colors.green,
                      fontSize: isSmallScreen ? 11 : 13,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                );
              },
            ),
          // 새 게임 버튼 (아이콘만)
          IconButton(
            onPressed: () => _showNewGameDialog(),
            icon: Icon(
              Icons.refresh,
              color: Colors.amber,
              size: isSmallScreen ? 18 : 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: AppLocalizations.of(context)!.newGame,
          ),
        ],
      ),
    );
  }

  void _showNewGameDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.newGame),
        content: Text(l10n.newGameDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              AdService().showRewardedAd(
                onRewarded: _startNewGame,
                onAdNotAvailable: _startNewGame,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text(l10n.newGame, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _onHintButtonPressed() {
    if (_showHint) {
      // 힌트가 켜져 있으면 광고 없이 끄기
      setState(() {
        _showHint = false;
      });
    } else {
      // 힌트가 꺼져 있으면 다이얼로그 표시
      _showHintDialog();
    }
  }

  void _showHintDialog() {
    final l10n = AppLocalizations.of(context)!;
    final hintActivatedMsg = l10n.hintActivated;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.hint),
        content: Text(l10n.hintDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              AdService().showRewardedAd(
                onRewarded: () {
                  setState(() {
                    _showHint = true;
                  });
                  _showMessage(hintActivatedMsg);
                },
                onAdNotAvailable: () {
                  // 광고 로드 실패 시에도 힌트 활성화
                  setState(() {
                    _showHint = true;
                  });
                  _showMessage(hintActivatedMsg);
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text(l10n.watchAd, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentHand(int playerIndex, bool isSmallScreen, _HeartsResponsiveSizes sizes) {
    final hand = hands[playerIndex];
    final cardWidth = sizes.aiCardWidth;
    final cardHeight = sizes.aiCardHeight;
    final overlap = sizes.aiCardOverlap;
    final l10n = AppLocalizations.of(context)!;
    final playerNames = _getPlayerNames(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${playerNames[playerIndex]} (${scores[playerIndex]}${l10n.score})',
            style: TextStyle(
              color: currentPlayer == playerIndex ? Colors.amber : Colors.white70,
              fontSize: isSmallScreen ? 11 : 13,
              fontWeight: currentPlayer == playerIndex ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            height: cardHeight,
            child: Stack(
              alignment: Alignment.center,
              children: [
                for (int i = 0; i < hand.length; i++)
                  Positioned(
                    left: (MediaQuery.of(context).size.width / 2) -
                          (hand.length * overlap / 2) +
                          (i * overlap),
                    child: _buildCardBack(cardWidth, cardHeight),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideOpponent(int playerIndex, bool isSmallScreen, _HeartsResponsiveSizes sizes) {
    final hand = hands[playerIndex];
    final cardWidth = sizes.aiCardWidth;
    final cardHeight = sizes.aiCardHeight;
    final overlap = sizes.aiCardOverlap * 0.75; // 세로 배치시 더 촘촘하게
    final l10n = AppLocalizations.of(context)!;
    final playerNames = _getPlayerNames(context);

    return Container(
      width: sizes.aiCardWidth * 2,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: playerIndex == 1 ? 1 : 3,
            child: Text(
              '${playerNames[playerIndex]} (${scores[playerIndex]}${l10n.score})',
              style: TextStyle(
                color: currentPlayer == playerIndex ? Colors.amber : Colors.white70,
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: currentPlayer == playerIndex ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: hand.length * overlap + cardHeight,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                for (int i = 0; i < hand.length; i++)
                  Positioned(
                    top: i * overlap,
                    child: Transform.rotate(
                      angle: playerIndex == 1 ? -pi / 2 : pi / 2,
                      child: _buildCardBack(cardWidth, cardHeight),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterArea(bool isSmallScreen, _HeartsResponsiveSizes sizes) {
    final cardWidth = sizes.centerCardWidth;
    final cardHeight = sizes.centerCardHeight;

    // 패싱 페이즈일 때는 빈 공간 반환 (테스트 패널은 오버레이로 표시)
    if (phase == GamePhase.passing) {
      return const SizedBox.shrink();
    }

    return Center(
      child: SizedBox(
        width: cardWidth * 3,
        height: cardHeight * 2.5,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 트릭 카드들
            // 위 (플레이어 2)
            if (currentTrick[2] != null)
              Positioned(
                top: 0,
                child: _buildPlayingCard(currentTrick[2]!, cardWidth, cardHeight, false),
              ),
            // 왼쪽 (플레이어 1)
            if (currentTrick[1] != null)
              Positioned(
                left: 0,
                child: _buildPlayingCard(currentTrick[1]!, cardWidth, cardHeight, false),
              ),
            // 오른쪽 (플레이어 3)
            if (currentTrick[3] != null)
              Positioned(
                right: 0,
                child: _buildPlayingCard(currentTrick[3]!, cardWidth, cardHeight, false),
              ),
            // 아래 (플레이어 0)
            if (currentTrick[0] != null)
              Positioned(
                bottom: 0,
                child: _buildPlayingCard(currentTrick[0]!, cardWidth, cardHeight, false),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerHand(bool isSmallScreen, _HeartsResponsiveSizes sizes) {
    final hand = hands[0];
    final screenWidth = sizes.screenWidth;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final availableWidth = screenWidth - (horizontalPadding * 2);

    // 7장이 한 줄에 들어가도록 카드 크기 계산 - sizes 기반으로 조정
    final maxCardsPerRow = 7;
    final overlapRatio = 0.35; // 카드 겹침 비율 (35% 겹침)
    final baseCardWidth = availableWidth / (maxCardsPerRow - (maxCardsPerRow - 1) * overlapRatio);
    final cardWidth = baseCardWidth.clamp(sizes.playerCardWidth * 0.8, sizes.playerCardWidth * 1.5);
    final cardHeight = cardWidth * 1.35;
    final cardStep = cardWidth * (1 - overlapRatio); // 카드 간 간격

    final playable = phase == GamePhase.playing && currentPlayer == 0 && !isProcessingTrick
        ? _getPlayableCards(0)
        : <PlayingCard>[];

    // ★ AI 추천 카드 계산 (힌트 활성화 시에만)
    PlayingCard? recommendedCard;
    List<PlayingCard> recommendedForPassing = [];

    if (_showHint) {
      if (phase == GamePhase.passing) {
        // 패싱 단계: 패스 우선순위가 높은 3장 추천
        recommendedForPassing = _getRecommendedPassingCards();
      } else if (playable.isNotEmpty) {
        // 플레이 단계: 최선의 카드 1장 추천
        recommendedCard = _selectBestCard(0, playable);
      }
    }

    // 카드를 두 줄로 분배
    final topRowCount = (hand.length + 1) ~/ 2;
    final topRow = hand.take(topRowCount).toList();
    final bottomRow = hand.skip(topRowCount).toList();

    Widget buildCardRow(List<PlayingCard> cards) {
      final rowWidth = cardWidth + (cards.length - 1) * cardStep;
      return SizedBox(
        width: rowWidth,
        height: cardHeight + 12, // 선택 시 위로 올라가는 공간
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (int i = 0; i < cards.length; i++)
              Positioned(
                left: i * cardStep,
                top: selectedForPassing.contains(cards[i]) ? 0 : 12,
                child: GestureDetector(
                  onTap: () {
                    if (phase == GamePhase.passing) {
                      _toggleCardForPassing(cards[i]);
                    } else if (playable.contains(cards[i])) {
                      _playCard(cards[i]);
                    }
                  },
                  child: _buildPlayingCard(
                    cards[i],
                    cardWidth,
                    cardHeight,
                    phase == GamePhase.passing ? true : playable.contains(cards[i]),
                    isSelected: selectedForPassing.contains(cards[i]),
                    isRecommended: recommendedCard == cards[i] || recommendedForPassing.contains(cards[i]),
                  ),
                ),
              ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 6, horizontal: horizontalPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              final playerNames = _getPlayerNames(context);
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${playerNames[0]} (${scores[0]}${l10n.score})',
                    style: TextStyle(
                      color: currentPlayer == 0 ? Colors.amber : Colors.white,
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // ★ 추천 카드 힌트 표시
                  if (recommendedCard != null || recommendedForPassing.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.yellow, size: isSmallScreen ? 12 : 14),
                          const SizedBox(width: 2),
                          Text(
                            recommendedForPassing.isNotEmpty ? l10n.passRecommend : l10n.recommend,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 10 : 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
          if (phase == GamePhase.passing)
            Builder(
              builder: (context) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  AppLocalizations.of(context)!.selectCardsToPassLeft,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: isSmallScreen ? 10 : 12,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 4),
          // 첫 번째 줄
          buildCardRow(topRow),
          SizedBox(height: isSmallScreen ? 2 : 4),
          // 두 번째 줄
          if (bottomRow.isNotEmpty) buildCardRow(bottomRow),
        ],
      ),
    );
  }

  Widget _buildCardBack(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.white24, width: 1),
      ),
      child: Center(
        child: Icon(
          Icons.favorite,
          color: Colors.red[300],
          size: width * 0.5,
        ),
      ),
    );
  }

  Widget _buildPlayingCard(PlayingCard card, double width, double height, bool isPlayable, {bool isSelected = false, bool isRecommended = false}) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected ? Colors.amber : (isRecommended ? Colors.green : (isPlayable ? Colors.yellow : Colors.grey)),
              width: isSelected ? 3 : (isRecommended ? 3 : (isPlayable ? 2 : 1)),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.3),
                blurRadius: 4,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                card.suitSymbol,
                style: TextStyle(
                  color: card.color,
                  fontSize: width * 0.4,
                ),
              ),
              Text(
                card.rankSymbol,
                style: TextStyle(
                  color: card.color,
                  fontSize: width * 0.35,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // ★ 추천 카드 표시
        if (isRecommended)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(
                Icons.star,
                color: Colors.yellow,
                size: width * 0.25,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildGameEndOverlay(bool isSmallScreen) {
    // 승자 찾기
    int minScore = scores.reduce(min);
    int winnerId = scores.indexOf(minScore);
    bool isPlayerWinner = winnerId == 0;

    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final playerNames = _getPlayerNames(context);
        return Container(
          color: Colors.black87,
          child: Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red[900],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPlayerWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    color: isPlayerWinner ? Colors.amber : Colors.white70,
                    size: isSmallScreen ? 48 : 64,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPlayerWinner ? l10n.wins : l10n.playerNameWins(playerNames[winnerId]),
                    style: TextStyle(
                      color: isPlayerWinner ? Colors.amber : Colors.white,
                      fontSize: isSmallScreen ? 24 : 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 점수 표시
                  ...List.generate(4, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            playerNames[i],
                            style: TextStyle(
                              color: i == winnerId ? Colors.amber : Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: i == winnerId ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          Text(
                            '${scores[i]}${l10n.score}',
                            style: TextStyle(
                              color: i == winnerId ? Colors.amber : Colors.white,
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: i == winnerId ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: _startNewGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 20 : 28,
                            vertical: isSmallScreen ? 10 : 14,
                          ),
                        ),
                        child: Text(
                          l10n.newGame,
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: isSmallScreen ? 14 : 16,
                            fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 20 : 28,
                        vertical: isSmallScreen ? 10 : 14,
                      ),
                    ),
                    child: Text(
                      l10n.exit,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  void _exitGame() {
    Navigator.pop(context);
  }
}
