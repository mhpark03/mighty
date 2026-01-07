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

  // 게임 진행
  GamePhase phase = GamePhase.passing;
  int currentPlayer = 0;
  int leadPlayer = 0;
  int trickNumber = 0;
  bool heartsBroken = false;
  bool isProcessingTrick = false;

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
    for (int i = 1; i < 4; i++) {
      final hand = List<PlayingCard>.from(hands[i]);
      final selected = <PlayingCard>[];

      // 우선순위: 스페이드 퀸, 높은 스페이드, 높은 하트, 높은 카드
      hand.sort((a, b) {
        int scoreA = _getPassPriority(a);
        int scoreB = _getPassPriority(b);
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

  int _getPassPriority(PlayingCard card) {
    // 높을수록 패스하고 싶은 카드
    if (card.isQueenOfSpades) return 1000;
    if (card.suit == Suit.spade && card.rank >= 12) return 500 + card.rank;
    if (card.isHeart && card.rank >= 10) return 300 + card.rank;
    if (card.rank >= 12) return 100 + card.rank;
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

  PlayingCard _selectBestCard(int playerIndex, List<PlayingCard> playable) {
    // 선공이면
    if (currentTrick.every((c) => c == null)) {
      // 낮은 카드 선호, 하트/스페이드 퀸 피하기
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

      // 이길 수 없으면 가장 높은 카드 (점수 먹이기)
      final canWin = sameSuitCards.where((c) => c.rank > highestRank).toList();
      if (canWin.isEmpty) {
        sameSuitCards.sort((a, b) => b.rank.compareTo(a.rank));
        return sameSuitCards.first;
      }

      // 점수 카드가 있는 트릭이면 피하기
      bool hasPoints = currentTrick.any((c) => c != null && c.points > 0);
      if (hasPoints) {
        // 이기지 않을 카드 중 가장 높은 것
        final cantWin = sameSuitCards.where((c) => c.rank <= highestRank).toList();
        if (cantWin.isNotEmpty) {
          cantWin.sort((a, b) => b.rank.compareTo(a.rank));
          return cantWin.first;
        }
      }

      // 낮은 카드로 안전하게
      sameSuitCards.sort((a, b) => a.rank.compareTo(b.rank));
      return sameSuitCards.first;
    } else {
      // 다른 무늬 - 점수 카드 버리기 기회
      // 스페이드 퀸 우선
      final queenOfSpades = playable.where((c) => c.isQueenOfSpades).toList();
      if (queenOfSpades.isNotEmpty) return queenOfSpades.first;

      // 높은 하트
      final hearts = playable.where((c) => c.isHeart).toList();
      if (hearts.isNotEmpty) {
        hearts.sort((a, b) => b.rank.compareTo(a.rank));
        return hearts.first;
      }

      // 높은 스페이드 (퀸 위험 방지)
      final highSpades = playable.where((c) => c.suit == Suit.spade && c.rank >= 12).toList();
      if (highSpades.isNotEmpty) {
        highSpades.sort((a, b) => b.rank.compareTo(a.rank));
        return highSpades.first;
      }

      // 가장 높은 카드
      playable.sort((a, b) => b.rank.compareTo(a.rank));
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

    _showMessage('${playerNames[winnerIndex]} 트릭 획득! (+$trickPoints점)');

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;

      setState(() {
        currentTrick = [null, null, null, null];
        trickNumber++;
        isProcessingTrick = false;
      });

      // 게임 종료 체크
      if (trickNumber > 13) {
        _endRound();
      } else {
        setState(() {
          leadPlayer = winnerIndex;
          currentPlayer = winnerIndex;
        });

        if (winnerIndex != 0) {
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

                  // 패싱 확인 버튼
                  if (phase == GamePhase.passing)
                    Positioned(
                      bottom: isSmallScreen ? 160 : 200,
                      left: 0,
                      right: 0,
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
                    child: _buildCardBack(cardWidth, cardHeight),
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
    final overlap = isSmallScreen ? 12.0 : 15.0;

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

  Widget _buildCenterArea(bool isSmallScreen) {
    final cardWidth = isSmallScreen ? 45.0 : 55.0;
    final cardHeight = isSmallScreen ? 65.0 : 80.0;

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
          color: Colors.red[400],
          size: width * 0.5,
        ),
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
                    onPressed: () {
                      AdService().showRewardedAd(
                        onRewarded: _startNewGame,
                      );
                    },
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
