import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/game_save_service.dart';
import '../../services/ad_service.dart';
import '../../services/onecard/onecard_stats_service.dart';

// 카드 무늬
enum Suit { spade, heart, diamond, club }

// 카드 클래스
class PlayingCard {
  final Suit? suit; // null이면 조커
  final int rank; // 1-13 (A, 2-10, J, Q, K), 0이면 흑백조커, -1이면 컬러조커

  PlayingCard({this.suit, required this.rank});

  bool get isJoker => suit == null && rank <= 0;
  bool get isBlackJoker => suit == null && rank == 0;
  bool get isColorJoker => suit == null && rank == -1;
  bool get isAttack => rank == 2 || rank == 1 || isJoker; // 2, A, Joker
  bool get isJump => rank == 11; // J
  bool get isReverse => rank == 12; // Q (방향 반대)
  bool get isChain => rank == 13; // K (2턴 건너뛰기)
  bool get isChange => rank == 7; // 7

  int get attackPower {
    if (rank == 2) return 2;
    if (rank == 1 && suit == Suit.spade) return 5; // ♠A는 5장
    if (rank == 1) return 3; // 일반 A는 3장
    if (isBlackJoker) return 5; // 흑백 조커 5장
    if (isColorJoker) return 7; // 컬러 조커 7장
    return 0;
  }

  String get rankString {
    if (isBlackJoker) return 'JOKER';
    if (isColorJoker) return 'JOKER';
    switch (rank) {
      case 1:
        return 'A';
      case 11:
        return 'J';
      case 12:
        return 'Q';
      case 13:
        return 'K';
      default:
        return '$rank';
    }
  }

  String get suitSymbol {
    if (isJoker) return '';
    switch (suit) {
      case Suit.spade:
        return '♠';
      case Suit.heart:
        return '♥';
      case Suit.diamond:
        return '◆';
      case Suit.club:
        return '♣';
      default:
        return '';
    }
  }

  Color get suitColor {
    if (isBlackJoker) return Colors.black;
    if (isColorJoker) return Colors.red;
    if (suit == Suit.heart || suit == Suit.diamond) {
      return Colors.red;
    }
    return Colors.black;
  }

  bool canPlayOn(PlayingCard other, Suit? currentSuit) {
    // 조커는 항상 낼 수 있음
    if (isJoker) return true;

    // 7을 낸 후 선언된 무늬가 있으면 그 무늬만 가능
    if (currentSuit != null) {
      return suit == currentSuit || rank == 7 || isJoker;
    }

    // 상대가 조커를 냈으면 조커로만 방어 가능 (공격 상태)
    // 일반 상태에서는 같은 무늬 또는 같은 숫자
    if (other.isJoker) {
      return isJoker;
    }

    return suit == other.suit || rank == other.rank;
  }

  @override
  bool operator ==(Object other) {
    if (other is PlayingCard) {
      return suit == other.suit && rank == other.rank;
    }
    return false;
  }

  @override
  int get hashCode => Object.hash(suit, rank);
}

// 반응형 사이즈 헬퍼
class _OneCardResponsiveSizes {
  final double screenHeight;
  final double screenWidth;

  late final double centerCardWidth;
  late final double centerCardHeight;
  late final double playerCardWidth;
  late final double playerCardHeight;
  late final double aiCardWidth;
  late final double aiCardHeight;

  _OneCardResponsiveSizes(this.screenHeight, this.screenWidth) {
    final baseUnit = screenHeight / 100;
    final widthUnit = screenWidth / 100;

    // 중앙 덱/버린카드
    centerCardWidth = (widthUnit * 14).clamp(45.0, 85.0);
    centerCardHeight = (baseUnit * 13).clamp(65.0, 120.0);

    // 플레이어 카드
    playerCardWidth = (widthUnit * 10).clamp(38.0, 60.0);
    playerCardHeight = (baseUnit * 9).clamp(52.0, 85.0);

    // AI 카드 (뒷면)
    aiCardWidth = (widthUnit * 6).clamp(22.0, 38.0);
    aiCardHeight = (baseUnit * 5.5).clamp(30.0, 50.0);
  }
}

class OneCardScreen extends StatefulWidget {
  final int playerCount;
  final bool resumeGame;

  const OneCardScreen({
    super.key,
    this.playerCount = 2,
    this.resumeGame = false,
  });

  // 저장된 게임이 있는지 확인
  static Future<bool> hasSavedGame() async {
    return await GameSaveService.hasSavedGame('onecard');
  }

  // 저장된 인원 수 가져오기
  static Future<int?> getSavedPlayerCount() async {
    final gameState = await GameSaveService.loadGame('onecard');
    if (gameState == null) return null;
    return gameState['playerCount'] as int?;
  }

  // 저장된 게임 삭제
  static Future<void> clearSavedGame() async {
    await GameSaveService.clearSave();
  }

  @override
  State<OneCardScreen> createState() => _OneCardScreenState();
}

class _OneCardScreenState extends State<OneCardScreen> with TickerProviderStateMixin {
  // AI 이름 (동적으로 가져옴)
  List<String> _getAiNames(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [l10n.aiPlayer1, l10n.aiPlayer2, l10n.aiPlayer3];
  }

  List<PlayingCard> deck = [];
  List<PlayingCard> discardPile = [];
  List<PlayingCard> playerHand = [];
  List<List<PlayingCard>> computerHands = []; // 멀티 컴퓨터

  // 인원 설정
  late int playerCount;

  // 턴 관리
  int currentTurn = 0; // 0 = 플레이어, 1+ = 컴퓨터
  int turnDirection = 1; // 1 = 정방향, -1 = 역방향
  bool waitingForNextTurn = false;
  PlayingCard? lastPlayedCard;
  int? lastPlayerIndex;
  String? lastPlayerName;

  bool gameOver = false;
  String? winner;
  int? winnerIndex; // 승자 인덱스 (0 = 플레이어, 1+ = 컴퓨터)
  bool _statsRecorded = false; // 통계 기록 여부

  // 공격 스택
  int attackStack = 0;

  // 무늬 변경 (7 카드)
  Suit? declaredSuit;
  bool showSuitPicker = false;
  PlayingCard? pendingCard;

  // 점프 상태 (J 카드)
  bool skipNextTurn = false;

  // 방향 반대 (Q 카드) - 2인 게임에서는 건너뛰기와 동일
  bool reverseDirection = false;

  // 체인 모드 (K 카드) - 같은 무늬 더내기
  bool chainMode = false;
  Suit? chainSuit;

  // 조커 이전 카드 (조커 공격 후 기준 카드)
  PlayingCard? lastNormalCard;

  // 파산 기준
  static const int bankruptcyLimit = 20;

  // 원카드 외치기
  bool playerCalledOneCard = false;
  List<bool> computerCalledOneCard = [];

  // 원카드 타이머 (5초 내 외치지 않으면 벌칙)
  Timer? _oneCardTimer;
  int _oneCardTimeLeft = 0;
  static const int oneCardTimeLimit = 5;
  bool _waitingForOneCard = false; // 원카드 대기 중 (컴퓨터 턴 지연)

  // 애니메이션
  late AnimationController _cardAnimController;
  late Animation<double> _cardAnimation;
  int? selectedCardIndex;

  // 메시지 표시
  String? gameMessage;
  Timer? _messageTimer;
  int _messageTimeLeft = 0;
  static const int messageDisplayTime = 5;

  // AI 차례 자동 진행 타이머
  Timer? _nextTurnTimer;
  int _autoPlayCountdown = 5;
  static const int autoPlaySeconds = 5;

  @override
  void initState() {
    super.initState();
    playerCount = widget.playerCount;
    _cardAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _cardAnimation = CurvedAnimation(
      parent: _cardAnimController,
      curve: Curves.easeOut,
    );
    if (widget.resumeGame) {
      _loadGame();
    } else {
      _initGame();
    }
  }

  @override
  void dispose() {
    _cardAnimController.dispose();
    _oneCardTimer?.cancel();
    _messageTimer?.cancel();
    _nextTurnTimer?.cancel();
    super.dispose();
  }

  // AI 차례 자동 진행 타이머 시작
  void _startNextTurnTimer() {
    _cancelNextTurnTimer();
    _autoPlayCountdown = autoPlaySeconds;

    _nextTurnTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || gameOver) {
        timer.cancel();
        return;
      }

      setState(() {
        _autoPlayCountdown--;
      });

      if (_autoPlayCountdown <= 0) {
        timer.cancel();
        _onNextTurn();
      }
    });
  }

  // AI 차례 타이머 취소
  void _cancelNextTurnTimer() {
    _nextTurnTimer?.cancel();
    _nextTurnTimer = null;
  }

  // 메시지 표시 (5초 타이머와 함께)
  void _showMessage(String message) {
    _messageTimer?.cancel();
    setState(() {
      gameMessage = message;
      _messageTimeLeft = messageDisplayTime;
    });
    _messageTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _messageTimeLeft--;
        if (_messageTimeLeft <= 0) {
          gameMessage = null;
          timer.cancel();
        }
      });
    });
  }

  // 원카드 타이머 시작
  void _startOneCardTimer() {
    _oneCardTimer?.cancel();
    _oneCardTimeLeft = oneCardTimeLimit;
    _oneCardTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _oneCardTimeLeft--;
        if (_oneCardTimeLeft <= 0) {
          timer.cancel();
          _onOneCardTimeout();
        }
      });
    });
  }

  // 원카드 타이머 취소
  void _cancelOneCardTimer() {
    _oneCardTimer?.cancel();
    _oneCardTimer = null;
    _oneCardTimeLeft = 0;
  }

  // 원카드 타이머 만료 - 벌칙
  void _onOneCardTimeout() {
    if (playerHand.length == 1 && !playerCalledOneCard && !gameOver) {
      // 랜덤 컴퓨터가 원카드 외침
      final randomComputer = Random().nextInt(playerCount - 1) + 1;
      setState(() {
        _drawCards(playerHand, 1);
        playerCalledOneCard = true; // 더 이상 벌칙 없음
        _waitingForOneCard = false;
      });
      _showMessage('${_getPlayerName(randomComputer)}: ${AppLocalizations.of(context)!.oneCardCall}');
      HapticFeedback.heavyImpact();
      _saveGame();

      // 컴퓨터 턴 진행
      if (currentTurn > 0 && !gameOver) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!gameOver && currentTurn > 0) {
            _computerTurn(currentTurn);
          }
        });
      }
    }
  }

  void _initGame() {
    // 이전 게임 승자 저장 (새 게임 시작 플레이어로 사용)
    final previousWinner = winnerIndex;

    deck = _createDeck();
    deck.shuffle(Random());

    playerHand = [];
    computerHands = List.generate(playerCount - 1, (_) => <PlayingCard>[]);
    discardPile = [];

    // 각자 7장씩 분배
    for (int i = 0; i < 7; i++) {
      playerHand.add(deck.removeLast());
      for (int j = 0; j < playerCount - 1; j++) {
        computerHands[j].add(deck.removeLast());
      }
    }

    // 첫 카드 오픈 (공격/특수 카드가 아닌 것으로)
    PlayingCard firstCard;
    do {
      firstCard = deck.removeLast();
      if (firstCard.isAttack || firstCard.isJump || firstCard.isReverse ||
          firstCard.isChain || firstCard.isChange) {
        deck.insert(0, firstCard);
      } else {
        break;
      }
    } while (true);

    discardPile.add(firstCard);
    lastNormalCard = firstCard;

    // 시작 플레이어 선택 (이전 게임 승자가 먼저, 첫 게임은 플레이어)
    currentTurn = previousWinner ?? 0;
    turnDirection = 1;
    waitingForNextTurn = false;
    lastPlayedCard = null;
    lastPlayerIndex = null;
    lastPlayerName = null;
    gameOver = false;
    winner = null;
    winnerIndex = null;
    _statsRecorded = false;
    attackStack = 0;
    declaredSuit = null;
    skipNextTurn = false;
    reverseDirection = false;
    chainMode = false;
    chainSuit = null;
    playerCalledOneCard = false;
    computerCalledOneCard = List.generate(playerCount - 1, (_) => false);
    _waitingForOneCard = false;
    _cancelOneCardTimer();
    _messageTimer?.cancel();
    gameMessage = null;
    _messageTimeLeft = 0;
    selectedCardIndex = null;
  }

  // 게임 결과 통계 기록
  void _recordGameStats() {
    if (_statsRecorded || winnerIndex == null) return;
    _statsRecorded = true;

    try {
      final statsService = Provider.of<OneCardStatsService>(context, listen: false);
      statsService.recordGameResult(
        winnerId: winnerIndex!,
        playerCount: playerCount,
      );
    } catch (e) {
      // Provider가 없는 경우 무시 (통계는 기록되지 않지만 게임은 계속)
      debugPrint('Failed to record game stats: $e');
    }
  }

  // 게임 상태 저장
  Future<void> _saveGame() async {
    if (gameOver) {
      await OneCardScreen.clearSavedGame();
      return;
    }

    // 카드를 Map으로 변환하는 헬퍼 함수
    Map<String, dynamic> cardToMap(PlayingCard card) {
      return {
        'suit': card.suit?.index,
        'rank': card.rank,
      };
    }

    final gameState = {
      'playerCount': playerCount,
      'deck': deck.map(cardToMap).toList(),
      'discardPile': discardPile.map(cardToMap).toList(),
      'playerHand': playerHand.map(cardToMap).toList(),
      'computerHands': computerHands.map((hand) => hand.map(cardToMap).toList()).toList(),
      'currentTurn': currentTurn,
      'turnDirection': turnDirection,
      'attackStack': attackStack,
      'declaredSuit': declaredSuit?.index,
      'chainMode': chainMode,
      'chainSuit': chainSuit?.index,
      'lastNormalCard': lastNormalCard != null ? cardToMap(lastNormalCard!) : null,
      'playerCalledOneCard': playerCalledOneCard,
      'computerCalledOneCard': computerCalledOneCard,
    };

    await GameSaveService.saveGame('onecard', gameState);
  }

  // 저장된 게임 불러오기
  Future<void> _loadGame() async {
    final gameState = await GameSaveService.loadGame('onecard');

    if (gameState == null) {
      _initGame();
      return;
    }

    // Map에서 카드를 복원하는 헬퍼 함수
    PlayingCard mapToCard(Map<String, dynamic> map) {
      final suitIndex = map['suit'] as int?;
      return PlayingCard(
        suit: suitIndex != null ? Suit.values[suitIndex] : null,
        rank: map['rank'] as int,
      );
    }

    playerCount = gameState['playerCount'] as int? ?? 2;

    deck = (gameState['deck'] as List)
        .map((m) => mapToCard(Map<String, dynamic>.from(m)))
        .toList();
    discardPile = (gameState['discardPile'] as List)
        .map((m) => mapToCard(Map<String, dynamic>.from(m)))
        .toList();
    playerHand = (gameState['playerHand'] as List)
        .map((m) => mapToCard(Map<String, dynamic>.from(m)))
        .toList();
    computerHands = (gameState['computerHands'] as List)
        .map((hand) => (hand as List)
            .map((m) => mapToCard(Map<String, dynamic>.from(m)))
            .toList())
        .toList();

    currentTurn = gameState['currentTurn'] as int? ?? 0;
    turnDirection = gameState['turnDirection'] as int? ?? 1;
    attackStack = gameState['attackStack'] as int? ?? 0;

    final declaredSuitIndex = gameState['declaredSuit'] as int?;
    declaredSuit = declaredSuitIndex != null ? Suit.values[declaredSuitIndex] : null;

    chainMode = gameState['chainMode'] as bool? ?? false;
    final chainSuitIndex = gameState['chainSuit'] as int?;
    chainSuit = chainSuitIndex != null ? Suit.values[chainSuitIndex] : null;

    final lastNormalCardMap = gameState['lastNormalCard'];
    lastNormalCard = lastNormalCardMap != null
        ? mapToCard(Map<String, dynamic>.from(lastNormalCardMap))
        : null;

    playerCalledOneCard = gameState['playerCalledOneCard'] as bool? ?? false;
    computerCalledOneCard = (gameState['computerCalledOneCard'] as List?)
        ?.map((e) => e as bool)
        .toList() ?? List.generate(playerCount - 1, (_) => false);

    waitingForNextTurn = false;
    lastPlayedCard = null;
    lastPlayerIndex = null;
    lastPlayerName = null;
    gameOver = false;
    winner = null;
    winnerIndex = null;
    skipNextTurn = false;
    reverseDirection = false;
    selectedCardIndex = null;
    _waitingForOneCard = false;
    _cancelOneCardTimer();

    setState(() {});
    final l10n = AppLocalizations.of(context)!;
    _showMessage(l10n.continueGame);

    // 컴퓨터 턴인 경우 컴퓨터가 진행
    if (currentTurn > 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _computerTurn(currentTurn);
      });
    }
  }

  // 현재 플레이어 턴인지 확인
  bool get isPlayerTurn => currentTurn == 0;

  // 다음 턴으로 이동
  int _getNextTurn(int current) {
    int next = current + turnDirection;
    if (next >= playerCount) next = 0;
    if (next < 0) next = playerCount - 1;
    return next;
  }

  // 플레이어 이름
  String _getPlayerName(int turn, [BuildContext? ctx]) {
    final l10n = AppLocalizations.of(ctx ?? context)!;
    if (turn == 0) return l10n.player;
    final aiNames = _getAiNames(ctx ?? context);
    return aiNames[turn - 1];
  }

  // 특정 턴의 핸드 가져오기
  List<PlayingCard> _getHandForTurn(int turn) {
    if (turn == 0) return playerHand;
    return computerHands[turn - 1];
  }

  List<PlayingCard> _createDeck() {
    List<PlayingCard> newDeck = [];

    for (var suit in Suit.values) {
      for (int rank = 1; rank <= 13; rank++) {
        newDeck.add(PlayingCard(suit: suit, rank: rank));
      }
    }

    // 조커 2장 추가 (흑백 조커 5장, 컬러 조커 7장)
    newDeck.add(PlayingCard(rank: 0));  // 흑백 조커
    newDeck.add(PlayingCard(rank: -1)); // 컬러 조커

    return newDeck;
  }

  void _reshuffleDeck() {
    if (discardPile.length <= 1) return;

    final topCard = discardPile.removeLast();
    deck.addAll(discardPile);
    discardPile = [topCard];
    deck.shuffle(Random());
  }

  PlayingCard? _drawCard() {
    if (deck.isEmpty) {
      _reshuffleDeck();
    }
    if (deck.isEmpty) return null;
    return deck.removeLast();
  }

  void _drawCards(List<PlayingCard> hand, int count) {
    for (int i = 0; i < count; i++) {
      final card = _drawCard();
      if (card != null) {
        hand.add(card);
      }
    }
  }

  PlayingCard get topCard => discardPile.last;

  List<PlayingCard> _getPlayableCards(List<PlayingCard> hand) {
    // discardPile이 비어있으면 빈 리스트 반환
    if (discardPile.isEmpty) return [];

    // 공격 상태에서는 특정 공격 카드로만 방어 가능
    // - 2 공격: 아무 2 / 같은 무늬 A / 조커
    // - A/♠A 공격: 아무 A / 조커
    // - 흑백조커 공격: 컬러조커만 가능
    // - 컬러조커 공격: 방어 불가
    if (attackStack > 0) {
      return hand.where((card) {
        if (!card.isAttack) return false;

        // 컬러조커 공격은 방어 불가
        if (topCard.isColorJoker) {
          return false;
        }

        // 흑백조커 공격은 컬러조커로만 방어
        if (topCard.isBlackJoker) {
          return card.isColorJoker;
        }

        // A/♠A 공격: 아무 A 또는 조커로 방어
        if (topCard.rank == 1) {
          return card.rank == 1 || card.isJoker;
        }

        // 2 공격: 아무 2 / 같은 무늬 A / 조커로 방어
        if (topCard.rank == 2) {
          if (card.rank == 2) return true;
          if (card.rank == 1 && card.suit == topCard.suit) return true;
          if (card.isJoker) return true;
          return false;
        }

        return false;
      }).toList();
    }

    // 조커가 나온 후 공격을 받은 경우, 조커 이전 카드 기준으로 판단
    final referenceCard = (topCard.isJoker && lastNormalCard != null)
        ? lastNormalCard!
        : topCard;

    return hand.where((card) => card.canPlayOn(referenceCard, declaredSuit)).toList();
  }

  void _playCard(PlayingCard card, {Suit? newSuit}) {
    String? pendingMessage;
    final playerName = _getPlayerName(currentTurn);

    setState(() {
      // 현재 턴 플레이어의 핸드에서 카드 제거
      final currentHand = _getHandForTurn(currentTurn);
      currentHand.remove(card);

      // 마지막으로 낸 카드/플레이어 기록
      lastPlayedCard = card;
      lastPlayerIndex = currentTurn;
      lastPlayerName = _getPlayerName(currentTurn);

      discardPile.add(card);
      declaredSuit = null; // 초기화

      // 조커가 아닌 카드는 기준 카드로 저장
      if (!card.isJoker) {
        lastNormalCard = card;
      }

      // 카드 효과 처리
      final l10n = AppLocalizations.of(context)!;
      if (card.isAttack) {
        attackStack += card.attackPower;
        pendingMessage = '$playerName: ${l10n.attackTotalCards(card.attackPower, attackStack)}';
      } else if (card.isJump) {
        skipNextTurn = true;
        pendingMessage = '$playerName: ${l10n.skipNextTurnMessage}';
      } else if (card.isReverse) {
        // Q: 방향 반대 (2인용에서는 의미 없음)
        turnDirection *= -1;
        pendingMessage = '$playerName: ${l10n.reverseDirectionMessage}';
      } else if (card.isChain) {
        // K: 2턴 건너뛰기
        skipNextTurn = true; // 첫 번째 건너뛰기 (아래서 한 번 더 건너뜀)
        pendingMessage = '$playerName: ${l10n.skipTwoTurnsMessage}';
      } else if (card.isChange) {
        if (newSuit != null) {
          declaredSuit = newSuit;
          pendingMessage = '$playerName: ${l10n.changeSuitMessage(_getSuitName(newSuit, context))}';
        }
      } else {
        pendingMessage = l10n.playerPlayedCard(playerName);
      }

      // 승리 체크
      if (playerHand.isEmpty) {
        gameOver = true;
        winner = l10n.player;
        winnerIndex = 0;
        _recordGameStats();
        return;
      }
      final aiNames = _getAiNames(context);
      for (int i = 0; i < computerHands.length; i++) {
        if (computerHands[i].isEmpty) {
          gameOver = true;
          winner = aiNames[i];
          winnerIndex = i + 1;
          _recordGameStats();
          return;
        }
      }

      // 컴퓨터 원카드 체크 - 카드 낸 후 1장 남았을 때
      if (currentTurn > 0 && computerHands[currentTurn - 1].length == 1) {
        // 컴퓨터는 자동으로 원카드 외침
        computerCalledOneCard[currentTurn - 1] = true;
        pendingMessage = '$playerName: ${l10n.oneCardCall}';
      }

      // 카드가 2장 이상이면 원카드 상태 리셋
      if (playerHand.length > 1) {
        playerCalledOneCard = false;
        _cancelOneCardTimer();
      }
      for (int i = 0; i < computerHands.length; i++) {
        if (computerHands[i].length > 1) {
          computerCalledOneCard[i] = false;
        }
      }

      // 턴 전환
      if (skipNextTurn) {
        skipNextTurn = false;
        // 한 턴 건너뛰기
        currentTurn = _getNextTurn(currentTurn);
        // K 카드면 한 턴 더 건너뛰기 (총 2턴)
        if (card.isChain) {
          currentTurn = _getNextTurn(currentTurn);
        }
      }

      // 다음 턴으로
      currentTurn = _getNextTurn(currentTurn);

      // 다음이 컴퓨터면 대기 상태 설정
      if (currentTurn > 0 && !gameOver) {
        if (lastPlayerIndex == 0) {
          // 플레이어가 행동한 후 → 자동으로 컴퓨터 턴 (버튼 대기 없음)
          waitingForNextTurn = false;
        } else {
          // 컴퓨터가 행동한 후 → 다음 순서 버튼 대기
          waitingForNextTurn = true;
        }
      } else {
        waitingForNextTurn = false;
      }
    });

    // 메시지 표시
    if (pendingMessage != null) {
      _showMessage(pendingMessage!);
    }

    // 대기 상태면 타이머 시작
    if (waitingForNextTurn) {
      _startNextTurnTimer();
    }

    HapticFeedback.mediumImpact();
    _saveGame();

    // 플레이어가 카드를 냈고 1장 남았으면 원카드 타이머 시작 (컴퓨터 턴 대기)
    if (lastPlayerIndex == 0 && playerHand.length == 1 && !playerCalledOneCard && !gameOver) {
      _waitingForOneCard = true;
      _startOneCardTimer();
      return; // 원카드 타이머 끝날 때까지 컴퓨터 턴 대기
    }

    // 플레이어가 행동했고 다음이 컴퓨터면 자동 진행
    if (lastPlayerIndex == 0 && currentTurn > 0 && !gameOver && !_waitingForOneCard) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!gameOver && currentTurn > 0 && !_waitingForOneCard) {
          _computerTurn(currentTurn);
        }
      });
    }
  }

  // 다음 순서 버튼 눌렀을 때
  void _onNextTurn() {
    _cancelNextTurnTimer();
    setState(() {
      waitingForNextTurn = false;
    });
    if (currentTurn > 0 && !gameOver) {
      Future.delayed(const Duration(milliseconds: 300), () => _computerTurn(currentTurn));
    }
  }

  void _callOneCard() {
    if (gameOver) return;
    if (playerHand.length != 1) return; // 1장일 때만 가능

    _cancelOneCardTimer();
    setState(() {
      playerCalledOneCard = true;
      _waitingForOneCard = false;
    });
    final l10n = AppLocalizations.of(context)!;
    _showMessage(l10n.oneCardCall);
    HapticFeedback.heavyImpact();

    // 컴퓨터 턴 진행
    if (currentTurn > 0 && !gameOver) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!gameOver && currentTurn > 0) {
          _computerTurn(currentTurn);
        }
      });
    }
  }

  void _playerDrawCards() {
    if (!isPlayerTurn || gameOver || waitingForNextTurn) return;

    String? pendingMessage;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      if (attackStack > 0) {
        // 공격 받기
        _drawCards(playerHand, attackStack);
        pendingMessage = l10n.attackReceived(attackStack);
        attackStack = 0;
      } else {
        // 일반 드로우
        _drawCards(playerHand, 1);
        pendingMessage = l10n.cardDrawn;
      }

      // 파산 체크
      if (playerHand.length >= bankruptcyLimit) {
        gameOver = true;
        winner = _getBankruptcyWinner();
        _recordGameStats();
        pendingMessage = l10n.bankruptWithCards(playerHand.length);
        return;
      }

      // 다음 턴으로
      currentTurn = _getNextTurn(currentTurn);

      // 플레이어가 행동했으므로 버튼 대기 없이 자동 진행
      waitingForNextTurn = false;
    });

    if (pendingMessage != null) {
      _showMessage(pendingMessage!);
    }

    HapticFeedback.lightImpact();
    _saveGame();

    // 다음이 컴퓨터면 자동 진행
    if (!gameOver && currentTurn > 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!gameOver && currentTurn > 0) {
          _computerTurn(currentTurn);
        }
      });
    }
  }

  String _getBankruptcyWinner() {
    // 파산하지 않은 플레이어 중 카드가 가장 적은 사람
    int minCards = playerHand.length;
    int localWinnerIndex = 0; // 0 = 플레이어

    for (int i = 0; i < computerHands.length; i++) {
      if (computerHands[i].length < minCards) {
        minCards = computerHands[i].length;
        localWinnerIndex = i + 1; // AI 인덱스는 1부터 시작
      }
    }

    // 클래스 변수에 승자 인덱스 저장
    winnerIndex = localWinnerIndex;
    final l10n = AppLocalizations.of(context)!;
    final aiNames = _getAiNames(context);
    return localWinnerIndex == 0 ? l10n.player : aiNames[localWinnerIndex - 1];
  }

  void _computerTurn(int computerIndex) {
    if (gameOver || computerIndex == 0) return;

    final computerHand = computerHands[computerIndex - 1];
    final playable = _getPlayableCards(computerHand);
    final computerName = _getPlayerName(computerIndex);
    final l10n = AppLocalizations.of(context)!;

    if (playable.isEmpty) {
      // 낼 카드 없음
      String? pendingMessage;

      setState(() {
        if (attackStack > 0) {
          _drawCards(computerHand, attackStack);
          pendingMessage = '$computerName: ${l10n.attackReceived(attackStack)}';
          attackStack = 0;
        } else {
          _drawCards(computerHand, 1);
          pendingMessage = '$computerName: ${l10n.cardDrawn}';
        }

        lastPlayedCard = null;
        lastPlayerIndex = computerIndex;
        lastPlayerName = computerName;

        // 파산 체크
        if (computerHand.length >= bankruptcyLimit) {
          gameOver = true;
          winner = _getBankruptcyWinner();
          _recordGameStats();
          pendingMessage = '$computerName ${l10n.bankruptWithCards(computerHand.length)}';
          return;
        }

        // 다음 턴
        currentTurn = _getNextTurn(currentTurn);

        // 다음이 플레이어면 대기 해제, 컴퓨터면 계속 대기
        if (currentTurn == 0) {
          waitingForNextTurn = false;
        } else {
          waitingForNextTurn = true;
        }
      });

      if (pendingMessage != null) {
        _showMessage(pendingMessage!);
      }

      // 대기 상태면 타이머 시작
      if (waitingForNextTurn) {
        _startNextTurnTimer();
      }
    } else {
      // 카드 선택 (우선순위: 공격 > 점프 > 무늬변경 > 일반)
      PlayingCard cardToPlay;

      // 공격 상태면 가장 강한 공격 카드
      if (attackStack > 0) {
        playable.sort((a, b) => b.attackPower.compareTo(a.attackPower));
        cardToPlay = playable.first;
      } else {
        // 전략적 선택
        final attacks = playable.where((c) => c.isAttack).toList();
        final jumps = playable.where((c) => c.isJump).toList();
        final reverses = playable.where((c) => c.isReverse).toList();
        final chains = playable.where((c) => c.isChain).toList();
        final changes = playable.where((c) => c.isChange).toList();
        final normals = playable.where((c) =>
            !c.isAttack && !c.isJump && !c.isReverse && !c.isChain && !c.isChange).toList();

        if (attacks.isNotEmpty && Random().nextDouble() < 0.5) {
          cardToPlay = attacks[Random().nextInt(attacks.length)];
        } else if (jumps.isNotEmpty && Random().nextDouble() < 0.3) {
          cardToPlay = jumps.first;
        } else if (reverses.isNotEmpty && Random().nextDouble() < 0.3) {
          cardToPlay = reverses.first;
        } else if (chains.isNotEmpty && Random().nextDouble() < 0.4) {
          // K는 2턴 건너뛰기 효과
          cardToPlay = chains.first;
        } else if (normals.isNotEmpty) {
          cardToPlay = normals[Random().nextInt(normals.length)];
        } else if (changes.isNotEmpty) {
          cardToPlay = changes.first;
        } else {
          cardToPlay = playable[Random().nextInt(playable.length)];
        }
      }

      // 7이면 가장 많은 무늬로 변경
      Suit? newSuit;
      if (cardToPlay.isChange) {
        final suitCounts = <Suit, int>{};
        for (var card in computerHand) {
          if (card.suit != null) {
            suitCounts[card.suit!] = (suitCounts[card.suit!] ?? 0) + 1;
          }
        }
        if (suitCounts.isNotEmpty) {
          newSuit = suitCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        } else {
          newSuit = Suit.values[Random().nextInt(4)];
        }
      }

      _playCard(cardToPlay, newSuit: newSuit);
    }
  }

  String _getSuitName(Suit suit, [BuildContext? ctx]) {
    final l10n = AppLocalizations.of(ctx ?? context)!;
    switch (suit) {
      case Suit.spade:
        return l10n.spadeName;
      case Suit.heart:
        return l10n.heartName;
      case Suit.diamond:
        return l10n.diamondName;
      case Suit.club:
        return l10n.clubName;
    }
  }

  void _onPlayerCardTap(int index) {
    if (!isPlayerTurn || gameOver || showSuitPicker) return;

    final card = playerHand[index];
    final playable = _getPlayableCards(playerHand);

    if (!playable.contains(card)) {
      final l10n = AppLocalizations.of(context)!;
      _showMessage(l10n.cannotPlayThisCard);
      HapticFeedback.lightImpact();
      return;
    }

    // 7이면 무늬 선택 UI
    if (card.isChange) {
      setState(() {
        pendingCard = card;
        showSuitPicker = true;
      });
      return;
    }

    _playCard(card);
  }

  void _selectSuit(Suit suit) {
    if (pendingCard == null) return;

    setState(() {
      showSuitPicker = false;
    });

    _playCard(pendingCard!, newSuit: suit);
    pendingCard = null;
  }

  void _restartGame() {
    setState(() {
      _initGame();
    });
    HapticFeedback.mediumImpact();

    // 컴퓨터 턴인 경우 컴퓨터가 진행 (이전 게임 승자가 AI인 경우)
    if (currentTurn > 0 && !gameOver) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && !gameOver && currentTurn > 0) {
          _computerTurn(currentTurn);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final screenWidth = mediaQuery.size.width;
    final sizes = _OneCardResponsiveSizes(screenHeight, screenWidth);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.green.shade900,
      appBar: AppBar(
        backgroundColor: Colors.green.shade800,
        foregroundColor: Colors.white,
        title: Text(
          l10n.onecardWithPlayers(playerCount),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              AdService().showRewardedAd(
                onRewarded: _restartGame,
                onAdNotAvailable: _restartGame,
              );
            },
            tooltip: l10n.restart,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // 상단 컴퓨터: 2인용은 컴퓨터1, 3/4인용은 컴퓨터2 (반시계방향)
                      if (computerHands.isNotEmpty)
                        _buildTopComputerHand(playerCount == 2 ? 0 : 1, sizes),
                      // 중앙 영역 (좌우 컴퓨터 + 카드)
                      Expanded(
                        child: playerCount > 2
                            ? Row(
                                children: [
                                  // 왼쪽 컴퓨터 (컴퓨터 3) - 반시계방향으로 세 번째
                                  if (computerHands.length >= 3)
                                    _buildSideComputerHand(2, sizes),
                                  // 중앙 카드 영역
                                  Expanded(child: _buildCenterArea(sizes)),
                                  // 오른쪽 컴퓨터 (컴퓨터 1) - 반시계방향으로 첫 번째
                                  if (computerHands.isNotEmpty)
                                    _buildSideComputerHand(0, sizes),
                                ],
                              )
                            : _buildCenterArea(sizes),
                      ),
                      // 하단 영역 (차례/시작버튼/메시지/원카드/손패)
                      _buildBottomSection(sizes),
                    ],
                  ),
                  // 무늬 선택 UI
                  if (showSuitPicker) _buildSuitPicker(),
                  // 게임 오버 오버레이
                  if (gameOver) _buildGameOverOverlay(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 좌/우측 컴퓨터 (세로 배치) - 훌라 스타일
  Widget _buildSideComputerHand(int computerIndex, _OneCardResponsiveSizes sizes) {
    if (computerIndex >= computerHands.length) return const SizedBox();

    final hand = computerHands[computerIndex];
    final isCurrentTurn = currentTurn == computerIndex + 1;
    final aiNames = _getAiNames(context);

    return Container(
      width: sizes.aiCardWidth * 2,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 컴퓨터 이름
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: isCurrentTurn ? Colors.amber.shade700 : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              aiNames[computerIndex],
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 4),
          // 카드 수
          Text(
            AppLocalizations.of(context)!.cardCount(hand.length),
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
          const SizedBox(height: 8),
          // 세로 카드 스택
          Expanded(
            child: _buildVerticalCardStack(hand.length, sizes),
          ),
        ],
      ),
    );
  }

  // 세로 카드 스택 - 훌라 스타일
  Widget _buildVerticalCardStack(int cardCount, _OneCardResponsiveSizes sizes) {
    final overlap = sizes.aiCardHeight * 0.3;
    final cardHeight = sizes.aiCardHeight;
    final cardWidth = sizes.aiCardWidth;
    const maxVisible = 7;
    final visibleCount = cardCount > maxVisible ? maxVisible : cardCount;
    final totalHeight = cardHeight + (visibleCount - 1) * overlap;

    return Center(
      child: SizedBox(
        width: cardWidth,
        height: totalHeight,
        child: Stack(
          children: List.generate(visibleCount, (index) {
            return Positioned(
              top: index * overlap,
              child: Container(
                width: cardWidth,
                height: cardHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.blue.shade900],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.white24, width: 0.5),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // 상단 컴퓨터 (가로 배치) - 훌라 스타일
  Widget _buildTopComputerHand(int computerIndex, _OneCardResponsiveSizes sizes) {
    if (computerIndex >= computerHands.length) return const SizedBox();

    final hand = computerHands[computerIndex];
    final isCurrentTurn = currentTurn == computerIndex + 1;
    final aiNames = _getAiNames(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isCurrentTurn ? Colors.amber.shade700 : Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.computer, color: Colors.white, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      aiNames[computerIndex],
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context)!.cardCount(hand.length),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 카드 뒷면 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              hand.length > 8 ? 8 : hand.length,
              (j) => Container(
                width: sizes.aiCardWidth,
                height: sizes.aiCardHeight,
                margin: const EdgeInsets.only(left: 2),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade800, Colors.blue.shade900],
                  ),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(color: Colors.white24),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardBack(_OneCardResponsiveSizes sizes) {
    return Container(
      width: sizes.centerCardWidth,
      height: sizes.centerCardHeight,
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 40,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.blue.shade300, width: 1),
          ),
          child: const Center(
            child: Icon(Icons.style, color: Colors.white54, size: 20),
          ),
        ),
      ),
    );
  }

  // 하단 영역 (훌라 스타일) - 차례/시작버튼/메시지/상태/원카드/손패
  Widget _buildBottomSection(_OneCardResponsiveSizes sizes) {
    final l10n = AppLocalizations.of(context)!;
    return Flexible(
      flex: 0,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 현재 차례 표시 + 시작 버튼 + 메시지 + 상태
            if (!gameOver)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 상단: 현재 순서 표시 + 시작 버튼 + 상태
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: currentTurn == 0 ? Colors.green : Colors.orange,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            currentTurn == 0
                                ? l10n.myTurn
                                : (waitingForNextTurn
                                    ? l10n.aiTurnCountdown(_getAiNames(context)[currentTurn - 1], _autoPlayCountdown)
                                    : l10n.aiTurn(_getAiNames(context)[currentTurn - 1])),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // 시작하기 버튼 (컴퓨터 차례 대기 중일 때만 표시)
                        if (waitingForNextTurn && currentTurn != 0) ...[
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: _onNextTurn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              l10n.start,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    // 하단: 메시지
                    if (gameMessage != null) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          gameMessage!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

            // 원카드 버튼
            _buildOneCardButton(),

            // 플레이어 손패
            _buildPlayerHand(sizes),
          ],
        ),
      ),
    );
  }

  String _getSuitSymbol(Suit suit) {
    switch (suit) {
      case Suit.spade:
        return '♠';
      case Suit.heart:
        return '♥';
      case Suit.diamond:
        return '◆';
      case Suit.club:
        return '♣';
    }
  }

  Color _getSuitColor(Suit suit) {
    if (suit == Suit.heart || suit == Suit.diamond) {
      return Colors.red;
    }
    return Colors.black;
  }

  Widget _buildCenterArea(_OneCardResponsiveSizes sizes) {
    final l10n = AppLocalizations.of(context)!;
    // discardPile이 비어있으면 로딩 표시
    if (discardPile.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final showJokerInfo = topCard.isJoker && attackStack == 0 && lastNormalCard != null && lastNormalCard!.suit != null;

    Widget jokerInfoWidget() {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getSuitSymbol(lastNormalCard!.suit!),
              style: TextStyle(
                color: _getSuitColor(lastNormalCard!.suit!),
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              ' / ${lastNormalCard!.rankString}',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상태 표시 (공격 스택, 선언 무늬, 턴 방향)
          if (attackStack > 0 || declaredSuit != null || playerCount > 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 공격 스택
                  if (attackStack > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.bolt, color: Colors.yellow, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '+$attackStack',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // 선언된 무늬
                  if (declaredSuit != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getSuitSymbol(declaredSuit!),
                        style: TextStyle(
                          color: _getSuitColor(declaredSuit!),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  // 턴 방향 표시 (3/4인용)
                  if (playerCount > 2)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            turnDirection == 1 ? Icons.rotate_left : Icons.rotate_right,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            turnDirection == 1 ? l10n.counterClockwiseDirection : l10n.clockwiseDirection,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          // 카드 영역
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 덱
              GestureDetector(
                onTap: isPlayerTurn && !gameOver ? _playerDrawCards : null,
                child: Stack(
                  children: [
                    _buildCardBack(sizes),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${deck.length}',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              // 버린 카드 더미 (현재 카드) + 조커 정보
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPlayingCardWithSize(topCard, sizes.centerCardWidth, sizes.centerCardHeight),
                  if (showJokerInfo) jokerInfoWidget(),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayingCard(PlayingCard card, {double size = 1.0, bool highlight = false}) {
    final width = 60.0 * size;
    final height = 84.0 * size;
    return _buildPlayingCardWithSize(card, width, height, highlight: highlight);
  }

  Widget _buildPlayingCardWithSize(PlayingCard card, double width, double height, {bool highlight = false}) {
    final sizeRatio = width / 60.0;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * sizeRatio),
        border: Border.all(
          color: highlight ? Colors.yellow : Colors.grey.shade400,
          width: highlight ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: highlight
                ? Colors.yellow.withValues(alpha: 0.5)
                : Colors.black.withValues(alpha: 0.3),
            blurRadius: highlight ? 8 : 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: card.isJoker
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    color: card.isBlackJoker ? Colors.grey.shade800 : Colors.red,
                    size: 20 * sizeRatio,
                  ),
                  Text(
                    'JOKER',
                    style: TextStyle(
                      color: card.isBlackJoker ? Colors.grey.shade800 : Colors.red,
                      fontSize: 8 * sizeRatio,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    card.isBlackJoker ? AppLocalizations.of(context)!.blackWhiteJoker : AppLocalizations.of(context)!.colorJoker,
                    style: TextStyle(
                      color: card.isBlackJoker ? Colors.grey.shade600 : Colors.red.shade400,
                      fontSize: 6 * sizeRatio,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )
          : Stack(
              children: [
                // 좌상단
                Positioned(
                  left: 4 * sizeRatio,
                  top: 4 * sizeRatio,
                  child: Column(
                    children: [
                      Text(
                        card.rankString,
                        style: TextStyle(
                          color: card.suitColor,
                          fontSize: 14 * sizeRatio,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        card.suitSymbol,
                        style: TextStyle(
                          color: card.suitColor,
                          fontSize: 12 * sizeRatio,
                        ),
                      ),
                    ],
                  ),
                ),
                // 중앙
                Center(
                  child: Text(
                    card.suitSymbol,
                    style: TextStyle(
                      color: card.suitColor,
                      fontSize: 28 * sizeRatio,
                    ),
                  ),
                ),
                // 우하단 (뒤집힌)
                Positioned(
                  right: 4 * sizeRatio,
                  bottom: 4 * sizeRatio,
                  child: Transform.rotate(
                    angle: 3.14159,
                    child: Column(
                      children: [
                        Text(
                          card.rankString,
                          style: TextStyle(
                            color: card.suitColor,
                            fontSize: 14 * sizeRatio,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          card.suitSymbol,
                          style: TextStyle(
                            color: card.suitColor,
                            fontSize: 12 * sizeRatio,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOneCardButton() {
    final l10n = AppLocalizations.of(context)!;
    // 카드가 1장이고 아직 외치지 않았을 때 버튼 표시 (타이머 진행 중이거나 플레이어 턴일 때)
    final showButton = playerHand.length == 1 && !gameOver &&
        (!playerCalledOneCard || _oneCardTimeLeft > 0);
    final alreadyCalled = playerCalledOneCard;

    if (!showButton) {
      return const SizedBox(height: 40);
    }

    // 타이머가 작동 중이면 남은 시간 표시
    final buttonText = alreadyCalled
        ? l10n.oneCardCall
        : (_oneCardTimeLeft > 0 ? l10n.oneCardCallTimer(_oneCardTimeLeft) : l10n.oneCardCall);

    return GestureDetector(
      onTap: alreadyCalled ? null : _callOneCard,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: alreadyCalled
              ? Colors.grey.shade600
              : (_oneCardTimeLeft <= 2 && _oneCardTimeLeft > 0
                  ? Colors.red.shade700
                  : Colors.orange.shade700),
          borderRadius: BorderRadius.circular(20),
          boxShadow: alreadyCalled
              ? []
              : [
                  BoxShadow(
                    color: (_oneCardTimeLeft <= 2 && _oneCardTimeLeft > 0
                            ? Colors.red
                            : Colors.orange)
                        .withValues(alpha: 0.5),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              alreadyCalled ? Icons.check_circle : Icons.campaign,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              buttonText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerHand(_OneCardResponsiveSizes sizes) {
    final playable = _getPlayableCards(playerHand);

    // 2줄로 배열
    final int cardsPerRow = (playerHand.length / 2).ceil();
    final List<int> row1 = List.generate(
      cardsPerRow > playerHand.length ? playerHand.length : cardsPerRow,
      (i) => i,
    );
    final List<int> row2 = List.generate(
      playerHand.length - cardsPerRow > 0 ? playerHand.length - cardsPerRow : 0,
      (i) => cardsPerRow + i,
    );

    Widget buildCardRow(List<int> indices) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: indices.map((index) {
          final card = playerHand[index];
          final canPlay = playable.contains(card) && isPlayerTurn && !gameOver;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => _onPlayerCardTap(index),
              child: Opacity(
                opacity: canPlay ? 1.0 : 0.7,
                child: _buildPlayingCardWithSize(card, sizes.playerCardWidth, sizes.playerCardHeight, highlight: canPlay),
              ),
            ),
          );
        }).toList(),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 플레이어 정보 (카드 수 표시)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isPlayerTurn ? Colors.green : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  AppLocalizations.of(context)!.cardCount(playerHand.length),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          // 카드 (2줄, 스크롤 가능)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                buildCardRow(row1),
                if (row2.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  buildCardRow(row2),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuitPicker() {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectSuit,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildSuitButton(Suit.spade, '♠', Colors.black),
                  const SizedBox(width: 12),
                  _buildSuitButton(Suit.heart, '♥', Colors.red),
                  const SizedBox(width: 12),
                  _buildSuitButton(Suit.diamond, '◆', Colors.red),
                  const SizedBox(width: 12),
                  _buildSuitButton(Suit.club, '♣', Colors.black),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuitButton(Suit suit, String symbol, Color color) {
    return GestureDetector(
      onTap: () => _selectSuit(suit),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: Text(
            symbol,
            style: TextStyle(
              color: color,
              fontSize: 36,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    final l10n = AppLocalizations.of(context)!;
    final isPlayerWinner = winnerIndex == 0;

    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.grey.shade900,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlayerWinner ? Colors.amber : Colors.red,
              width: 3,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isPlayerWinner ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                color: isPlayerWinner ? Colors.amber : Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                isPlayerWinner ? l10n.victory : l10n.defeat,
                style: TextStyle(
                  color: isPlayerWinner ? Colors.amber : Colors.red,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.playerNameWins(winner ?? ''),
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text(
                  l10n.newGame,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRulesDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          l10n.gameRulesTitle,
          style: const TextStyle(color: Colors.purple),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.goal,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.goalText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.howToPlay,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.howToPlayText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.attackCards,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.onecardGuideAttackText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.defense,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.defenseText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.specialCards,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.onecardGuideSpecialText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.gameTips,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.onecardGuideOnecardText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }
}
