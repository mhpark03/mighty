import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../services/hearts/hearts_stats_service.dart';
import '../../services/ad_service.dart';
import '../../widgets/banner_ad_widget.dart';

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
}

enum GamePhase { passing, playing, roundEnd }

class HeartsScreen extends StatefulWidget {
  const HeartsScreen({super.key});

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

  final playerNames = ['플레이어', '민준', '서연', '지호'];

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    super.dispose();
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

    for (int i = 0; i < 4; i++) {
      _sortHand(i);
    }

    setState(() {});

    // AI가 패싱할 카드 선택
    _aiSelectPassingCards();
  }

  void _sortHand(int playerIndex) {
    hands[playerIndex].sort((a, b) {
      final suitOrder = [Suit.spade, Suit.heart, Suit.diamond, Suit.club];
      final suitCompare = suitOrder.indexOf(a.suit).compareTo(suitOrder.indexOf(b.suit));
      if (suitCompare != 0) return suitCompare;
      return b.rank.compareTo(a.rank);
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

  // 슛더문 해제 조건 체크
  void _updateShootMoonStatus() {
    for (int playerIndex = 0; playerIndex < 4; playerIndex++) {
      // 이미 슛더문 시도 중이 아니면 스킵
      if (shootMoonChances[playerIndex] < 0.5) continue;

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
      // (이미 다른 플레이어가 하트를 가져갔으면 조건 1에서 걸림)
      // 추가로: 내가 하트를 하나도 못 먹었는데 하트가 많이 나갔으면 해제
      final myPoints = wonCards[playerIndex].fold(0, (sum, c) => sum + c.points);
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

    // ★ 보이드 집중 패스: 클럽/다이아 중 3장 이하인 무늬 찾기
    // 같은 무늬에서 집중 패스하면 보이드 생성 확률 증가
    final voidTargetSuit = (clubCount <= 3 && clubCount > 0 && (diamondCount == 0 || clubCount <= diamondCount))
        ? Suit.club
        : (diamondCount <= 3 && diamondCount > 0)
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
      _sortHand(i);
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
      selectedForPassing = [];
      cardsToReceive = [[], [], [], []];
      phase = GamePhase.playing;
      currentPlayer = startPlayer;
      leadPlayer = startPlayer;
      trickNumber = 1;
    });

    _showMessage('${playerNames[startPlayer]}가 클럽 2로 시작합니다');

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

      // ★ 일반 (슛더문 아님): 스페이드Q는 가장 나중에
      // 마지막 순서 + 어떤 카드를 내도 이김 + 점수 없음 → 높은 카드 버리기 (Q 제외)
      final allCardsWin = sameSuitCards.every((c) => c.rank > highestRank);
      if (isLastPlayer && allCardsWin && !hasPointsInTrick) {
        final safeHighCards = sameSuitCards.where((c) => !c.isQueenOfSpades).toList();
        if (safeHighCards.isNotEmpty) {
          safeHighCards.sort((a, b) => b.rank.compareTo(a.rank));
          return safeHighCards.first;
        }
      }

      // 이길 수 없으면 가장 높은 카드 (Q 제외)
      if (canWin.isEmpty) {
        final withoutQueen = sameSuitCards.where((c) => !c.isQueenOfSpades).toList();
        if (withoutQueen.isNotEmpty) {
          withoutQueen.sort((a, b) => b.rank.compareTo(a.rank));
          return withoutQueen.first;
        }
        sameSuitCards.sort((a, b) => b.rank.compareTo(a.rank));
        return sameSuitCards.first;
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

      // ★ 슛더문 방어: 상대가 슛더문 근접 시 점수 카드 주지 않기
      if (shootMoonThreat != null) {
        // 위협 플레이어가 이 트릭을 이길 것 같으면 점수 카드를 주지 않음
        // 비점수 카드만 버리기 (위협 플레이어에게 하트 주지 않음)
        final nonPointCards = playable.where((c) => c.points == 0).toList();
        if (nonPointCards.isNotEmpty) {
          // 높은 카드 우선 버리기 (나중에 트릭 이기기 위해 낮은 카드 보유)
          nonPointCards.sort((a, b) => b.rank.compareTo(a.rank));
          return nonPointCards.first;
        }
        // 점수 카드만 있으면 어쩔 수 없이 버림 (가장 낮은 하트)
        final hearts = playable.where((c) => c.isHeart).toList();
        if (hearts.isNotEmpty) {
          hearts.sort((a, b) => a.rank.compareTo(b.rank));
          return hearts.first;
        }
      }

      // ★ 일반: 높은 카드 우선 버리기
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

    _showMessage('${playerNames[winnerIndex]} 트릭 획득! (+$trickPoints점)');

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
          _showMessage('모든 점수 카드 소진! 게임 종료');
        }
        _endRound();
      } else {
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
      _showMessage('${playerNames[shooterIndex]} 슈팅 더 문 성공!');
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
    final isSmallScreen = screenHeight < 600;

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
                      _buildOpponentHand(2, isSmallScreen),

                      // 중앙 영역 (좌우 상대방 + 트릭)
                      Expanded(
                        child: Row(
                          children: [
                            // 왼쪽 상대방
                            _buildSideOpponent(1, isSmallScreen),

                            // 중앙 트릭 영역
                            Expanded(
                              child: _buildCenterArea(isSmallScreen),
                            ),

                            // 오른쪽 상대방
                            _buildSideOpponent(3, isSmallScreen),
                          ],
                        ),
                      ),

                      // 플레이어 핸드
                      _buildPlayerHand(isSmallScreen),
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

                  // 테스트용 정보 표시 (상단에 작게)
                  if (phase == GamePhase.passing || phase == GamePhase.playing)
                    Positioned(
                      top: isSmallScreen ? 40 : 50,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '🔍 테스트 정보',
                              style: TextStyle(
                                color: Colors.amber,
                                fontSize: isSmallScreen ? 8 : 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // 슛더문 확률 + 선유지 가능성 표시
                            for (int i = 0; i < 4; i++)
                              Builder(builder: (context) {
                                final leadPotential = phase == GamePhase.playing
                                    ? _calculateOverallLeadPotential(i)
                                    : 0.0;
                                final leadStr = phase == GamePhase.playing
                                    ? ' L:${(leadPotential * 100).toInt()}%'
                                    : '';
                                return Text(
                                  '${playerNames[i]}: ${(shootMoonChances[i] * 100).toInt()}%${shootMoonChances[i] >= 0.5 ? "🌙" : ""}$leadStr',
                                  style: TextStyle(
                                    color: shootMoonChances[i] >= 0.5 ? Colors.yellow : Colors.white70,
                                    fontSize: isSmallScreen ? 8 : 10,
                                    fontWeight: shootMoonChances[i] >= 0.5 ? FontWeight.bold : FontWeight.normal,
                                  ),
                                );
                              }),
                            // 패싱 페이즈: 패스 카드 표시
                            if (phase == GamePhase.passing) ...[
                              const SizedBox(height: 4),
                              for (int i = 0; i < 4; i++)
                                if (cardsToReceive[i].isNotEmpty)
                                  Text(
                                    '${playerNames[(i + 3) % 4]}→${playerNames[i]}: ${cardsToReceive[i].map((c) => c.toString()).join(' ')}',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: isSmallScreen ? 8 : 10,
                                    ),
                                  ),
                            ],
                            // 플레이 페이즈: 플레이된 카드 수 표시
                            if (phase == GamePhase.playing) ...[
                              const SizedBox(height: 4),
                              Text(
                                '플레이: ${playedCards.length}/52',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isSmallScreen ? 8 : 10,
                                ),
                              ),
                            ],
                          ],
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
                            '왼쪽으로 패스 (${selectedForPassing.length}/3)',
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
            const BannerAdWidget(),
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
            onPressed: () => _showExitDialog(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Text(
            phase == GamePhase.passing
                ? '카드 패스'
                : '트릭 $trickNumber/13',
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          if (heartsBroken)
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red, size: isSmallScreen ? 16 : 20),
                const SizedBox(width: 4),
                Text(
                  '하트 브레이킹',
                  style: TextStyle(
                    color: Colors.red[300],
                    fontSize: isSmallScreen ? 11 : 13,
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
          // 새 게임 버튼
          TextButton.icon(
            onPressed: () => _showNewGameDialog(),
            icon: Icon(
              Icons.refresh,
              color: Colors.amber,
              size: isSmallScreen ? 16 : 18,
            ),
            label: Text(
              '새 게임',
              style: TextStyle(
                color: Colors.amber,
                fontSize: isSmallScreen ? 11 : 13,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  void _showNewGameDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('새 게임'),
        content: const Text('현재 게임을 종료하고 새 게임을 시작하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              AdService().showRewardedAd(
                onRewarded: _startNewGame,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: const Text('새 게임', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentHand(int playerIndex, bool isSmallScreen) {
    final hand = hands[playerIndex];
    final cardWidth = isSmallScreen ? 26.0 : 32.0;
    final cardHeight = isSmallScreen ? 36.0 : 45.0;
    final overlap = isSmallScreen ? 16.0 : 20.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${playerNames[playerIndex]} (${scores[playerIndex]}점)',
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
                    // TODO: 테스트용 - AI 카드 보이기
                    child: _buildPlayingCard(hand[i], cardWidth, cardHeight, false),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSideOpponent(int playerIndex, bool isSmallScreen) {
    final hand = hands[playerIndex];
    final cardWidth = isSmallScreen ? 24.0 : 30.0;
    final cardHeight = isSmallScreen ? 34.0 : 42.0;
    final overlap = isSmallScreen ? 18.0 : 22.0;

    return Container(
      width: isSmallScreen ? 50 : 60,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RotatedBox(
            quarterTurns: playerIndex == 1 ? 1 : 3,
            child: Text(
              '${playerNames[playerIndex]} (${scores[playerIndex]}점)',
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
                      // TODO: 테스트용 - AI 카드 보이기
                      child: _buildPlayingCard(hand[i], cardWidth, cardHeight, false),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterArea(bool isSmallScreen) {
    final cardWidth = isSmallScreen ? 45.0 : 55.0;
    final cardHeight = isSmallScreen ? 65.0 : 80.0;

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

  Widget _buildPlayerHand(bool isSmallScreen) {
    final hand = hands[0];
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = isSmallScreen ? 12.0 : 16.0;
    final availableWidth = screenWidth - (horizontalPadding * 2);

    // 7장이 한 줄에 들어가도록 카드 크기 계산
    final maxCardsPerRow = 7;
    final overlapRatio = 0.35; // 카드 겹침 비율 (35% 겹침)
    final cardWidth = availableWidth / (maxCardsPerRow - (maxCardsPerRow - 1) * overlapRatio);
    final cardHeight = cardWidth * 1.35;
    final cardStep = cardWidth * (1 - overlapRatio); // 카드 간 간격

    final playable = phase == GamePhase.playing && currentPlayer == 0 && !isProcessingTrick
        ? _getPlayableCards(0)
        : <PlayingCard>[];

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
          Text(
            '${playerNames[0]} (${scores[0]}점)',
            style: TextStyle(
              color: currentPlayer == 0 ? Colors.amber : Colors.white,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (phase == GamePhase.passing)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                '왼쪽으로 보낼 카드 3장을 선택하세요',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: isSmallScreen ? 10 : 12,
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

  Widget _buildPlayingCard(PlayingCard card, double width, double height, bool isPlayable, {bool isSelected = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected ? Colors.amber : (isPlayable ? Colors.yellow : Colors.grey),
          width: isSelected ? 3 : (isPlayable ? 2 : 1),
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
    );
  }

  Widget _buildGameEndOverlay(bool isSmallScreen) {
    // 승자 찾기
    int minScore = scores.reduce(min);
    int winnerId = scores.indexOf(minScore);
    bool isPlayerWinner = winnerId == 0;

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
                isPlayerWinner ? '승리!' : '${playerNames[winnerId]} 승리',
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
                        '${scores[i]}점',
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
                      '새 게임',
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
                      '나가기',
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
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('게임 종료'),
        content: const Text('게임을 종료하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('종료', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
