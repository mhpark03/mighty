import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/game_save_service.dart';
import '../../services/ad_service.dart';
import '../../services/hula/hula_stats_service.dart';

// 카드 무늬
enum Suit { spade, heart, diamond, club }

// 플레잉 카드
class PlayingCard {
  final Suit suit;
  final int rank; // 1-13 (A, 2-10, J, Q, K)

  PlayingCard({required this.suit, required this.rank});

  // 카드 점수 (A=1, 2-9=숫자, J=10, Q=11, K=12)
  int get point {
    if (rank == 1) return 1;
    if (rank == 11) return 10; // J
    if (rank == 12) return 11; // Q
    if (rank == 13) return 12; // K
    return rank;
  }

  String get rankString {
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
    switch (suit) {
      case Suit.spade:
        return '♠';
      case Suit.heart:
        return '♥';
      case Suit.diamond:
        return '♦';
      case Suit.club:
        return '♣';
    }
  }

  Color get suitColor {
    if (suit == Suit.heart || suit == Suit.diamond) {
      return Colors.red;
    }
    return Colors.black;
  }

  int get suitIndex {
    switch (suit) {
      case Suit.spade:
        return 0;
      case Suit.heart:
        return 1;
      case Suit.diamond:
        return 2;
      case Suit.club:
        return 3;
    }
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

  @override
  String toString() => '$suitSymbol$rankString';
}

// 멜드 (등록된 조합)
class Meld {
  final List<PlayingCard> cards;
  final bool isRun; // true = Run (시퀀스), false = Group (세트)

  Meld({required this.cards, required this.isRun});

  int get size => cards.length;
}

// 땡큐 옵션 타입
enum ThankYouType {
  seven,        // 7 단독 등록
  attachPlayer, // 플레이어 멜드에 붙이기
  attachComputer, // 컴퓨터 멜드에 붙이기
  newMeld,      // 새 멜드 생성
}

// 땡큐 옵션
class ThankYouOption {
  final ThankYouType type;
  final PlayingCard discardCard;
  final List<PlayingCard> handCards; // 손패에서 사용할 카드들
  final int? meldIndex; // 붙일 멜드 인덱스
  final int? computerIndex; // 컴퓨터 인덱스 (컴퓨터 멜드에 붙일 때)
  final String? computerName; // 컴퓨터 이름 (컴퓨터 멜드에 붙일 때)
  final bool isRun; // 새 멜드가 Run인지

  ThankYouOption({
    required this.type,
    required this.discardCard,
    this.handCards = const [],
    this.meldIndex,
    this.computerIndex,
    this.computerName,
    this.isRun = false,
  });

  // 옵션 설명 문자열
  String getDescription(AppLocalizations l10n) {
    switch (type) {
      case ThankYouType.seven:
        return l10n.thankYouSolo(discardCard.suitSymbol);
      case ThankYouType.attachPlayer:
        return l10n.thankYouAddToMine('${discardCard.suitSymbol}${discardCard.rankString}');
      case ThankYouType.attachComputer:
        return l10n.thankYouAddToAi('${discardCard.suitSymbol}${discardCard.rankString}', computerName ?? '');
      case ThankYouType.newMeld:
        final allCards = [...handCards, discardCard];
        if (isRun) {
          allCards.sort((a, b) => a.rank.compareTo(b.rank));
        }
        final cardStr = allCards.map((c) => '${c.suitSymbol}${c.rankString}').join(' ');
        return isRun ? 'Run: $cardStr' : 'Group: $cardStr';
    }
  }
}

// 반응형 사이즈 헬퍼
class _HulaResponsiveSizes {
  final double screenHeight;
  final double screenWidth;

  late final double centerCardWidth;
  late final double centerCardHeight;
  late final double playerCardWidth;
  late final double playerCardHeight;
  late final double playerSymbolSize;
  late final double playerRankSize;
  late final double aiCardWidth;
  late final double aiCardHeight;
  late final double meldCardWidth;
  late final double meldCardHeight;

  _HulaResponsiveSizes(this.screenHeight, this.screenWidth) {
    final baseUnit = screenHeight / 100;
    final widthUnit = screenWidth / 100;

    // 중앙 덱/버린카드 - 화면 비율로 계산
    centerCardWidth = (widthUnit * 15).clamp(50.0, 90.0);
    centerCardHeight = (baseUnit * 14).clamp(70.0, 130.0);

    // 플레이어 카드
    playerCardWidth = (widthUnit * 11).clamp(40.0, 65.0);
    playerCardHeight = (baseUnit * 10).clamp(55.0, 90.0);
    playerSymbolSize = (baseUnit * 3).clamp(14.0, 26.0);
    playerRankSize = (baseUnit * 2.5).clamp(12.0, 22.0);

    // AI 카드 (뒷면)
    aiCardWidth = (widthUnit * 6).clamp(20.0, 36.0);
    aiCardHeight = (baseUnit * 5).clamp(26.0, 44.0);

    // 멜드 영역 카드
    meldCardWidth = (widthUnit * 5).clamp(16.0, 28.0);
    meldCardHeight = (baseUnit * 4).clamp(22.0, 38.0);
  }
}

// 훌라 난이도
enum HulaDifficulty { easy, medium, hard }

// 52장 덱 생성
List<PlayingCard> createDeck() {
  final deck = <PlayingCard>[];
  for (final suit in Suit.values) {
    for (int rank = 1; rank <= 13; rank++) {
      deck.add(PlayingCard(suit: suit, rank: rank));
    }
  }
  return deck;
}

class HulaScreen extends StatefulWidget {
  final int playerCount;
  final bool resumeGame;
  final HulaDifficulty difficulty;

  const HulaScreen({
    super.key,
    this.playerCount = 2,
    this.resumeGame = false,
    this.difficulty = HulaDifficulty.medium,
  });

  static Future<bool> hasSavedGame() async {
    return await GameSaveService.hasSavedGame('hula');
  }

  static Future<int?> getSavedPlayerCount() async {
    final gameState = await GameSaveService.loadGame('hula');
    if (gameState == null) return null;
    return gameState['playerCount'] as int?;
  }

  static Future<HulaDifficulty?> getSavedDifficulty() async {
    final gameState = await GameSaveService.loadGame('hula');
    if (gameState == null) return null;
    final difficultyIndex = gameState['difficulty'] as int?;
    if (difficultyIndex == null) return null;
    return HulaDifficulty.values[difficultyIndex];
  }

  static Future<void> clearSavedGame() async {
    await GameSaveService.clearSave();
  }

  @override
  State<HulaScreen> createState() => _HulaScreenState();
}

class _HulaScreenState extends State<HulaScreen> with TickerProviderStateMixin {
  // AI 이름 (동적으로 가져옴)
  List<String> _getAiNames(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [l10n.aiPlayer1, l10n.aiPlayer2, l10n.aiPlayer3];
  }

  // 카드 덱
  List<PlayingCard> deck = [];
  List<PlayingCard> discardPile = [];

  // 손패
  List<PlayingCard> playerHand = [];
  List<List<PlayingCard>> computerHands = [];

  // 등록된 멜드
  List<Meld> playerMelds = [];
  List<List<Meld>> computerMelds = [];

  // 게임 상태
  late int playerCount;
  int currentTurn = 0; // 0 = 플레이어
  bool gameOver = false;
  String? winner;
  int? winnerIndex;
  bool isHula = false; // 훌라 여부

  // 컴퓨터 난이도 (0=쉬움, 1=보통, 2=어려움)
  List<int> computerDifficulties = [];

  // 턴 단계
  bool hasDrawn = false; // 이번 턴에 드로우했는지
  List<int> selectedCardIndices = []; // 선택된 카드 인덱스들
  bool waitingForNextTurn = false; // 다음 턴 대기 중
  Timer? _nextTurnTimer; // 자동 진행 타이머
  int _autoPlayCountdown = 5; // 자동 진행 카운트다운
  int _lastDiscardTurn = 0; // 마지막으로 카드를 버린 플레이어 턴
  Timer? _computerActionTimer; // 컴퓨터 액션 딜레이 타이머
  static const int _computerActionDelay = 2000; // 컴퓨터 액션 딜레이 (밀리초)
  VoidCallback? _pendingComputerAction; // 대기 후 실행할 컴퓨터 동작

  // 점수
  List<int> scores = [];      // 손패 점수 (남은 카드 합)
  List<int> roundScores = []; // 라운드 점수 (승자와의 차이)

  // 메시지
  String? gameMessage;
  Timer? _messageTimer;

  // 힌트
  bool _showHint = false;

  // 애니메이션
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    playerCount = widget.playerCount;

    _animController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    if (widget.resumeGame) {
      _loadSavedGame();
    } else {
      _initGame();
    }
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _nextTurnTimer?.cancel();
    _computerActionTimer?.cancel();
    _animController.dispose();
    super.dispose();
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
                onRewarded: () {
                  _showHint = false;
                  _initGame();
                },
                onAdNotAvailable: () {
                  _showHint = false;
                  _initGame();
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            child: Text(l10n.newGame, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _onHintButtonPressed() {
    if (_showHint) {
      setState(() {
        _showHint = false;
      });
    } else {
      _showHintDialog();
    }
  }

  void _showHintDialog() {
    final l10n = AppLocalizations.of(context)!;
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
                },
                onAdNotAvailable: () {
                  // 광고 로드 실패 시에도 힌트 활성화
                  setState(() {
                    _showHint = true;
                  });
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

  void _initGame() {
    // 타이머 모두 취소
    _cancelNextTurnTimer();
    _messageTimer?.cancel();
    _computerActionTimer?.cancel();

    // 이전 게임 승자 저장 (새 게임 시작 플레이어로 사용)
    final previousWinner = winnerIndex;

    deck = createDeck();
    deck.shuffle(Random());

    discardPile = [];
    playerHand = [];
    computerHands = List.generate(playerCount - 1, (_) => []);
    playerMelds = [];
    computerMelds = List.generate(playerCount - 1, (_) => []);
    scores = List.generate(playerCount, (_) => 0);
    roundScores = List.generate(playerCount, (_) => 0);

    // 컴퓨터 난이도 설정 (선택된 난이도 적용)
    final difficultyValue = widget.difficulty.index; // 0=쉬움, 1=보통, 2=어려움
    computerDifficulties = List.generate(playerCount - 1, (_) => difficultyValue);

    final random = Random();

    // 각 플레이어에게 7장씩 배분
    for (int i = 0; i < 7; i++) {
      playerHand.add(deck.removeLast());
      for (int c = 0; c < playerCount - 1; c++) {
        computerHands[c].add(deck.removeLast());
      }
    }

    // 버린 더미에 1장 공개
    discardPile.add(deck.removeLast());

    // 손패 정렬
    _sortHand(playerHand);
    for (var hand in computerHands) {
      _sortHand(hand);
    }

    // 시작 플레이어 선택 (이전 게임 승자가 먼저, 첫 게임은 랜덤)
    currentTurn = previousWinner ?? random.nextInt(playerCount);
    gameOver = false;
    winner = null;
    winnerIndex = null;
    isHula = false;
    hasDrawn = false;
    selectedCardIndices = [];
    waitingForNextTurn = false;
    gameMessage = null;
    _lastDiscardTurn = 0;
    _pendingComputerAction = null;

    setState(() {});
    _saveGame();

    // 컴퓨터가 먼저 시작하면 대기 상태로 전환
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (currentTurn != 0) {
        final startingComputer = currentTurn;
        final aiNames = _getAiNames(context);
        _showMessage('${aiNames[startingComputer - 1]} ${l10n.start}');
        setState(() {
          waitingForNextTurn = true;
        });
        _startNextTurnTimer();
      } else {
        // 플레이어가 먼저 시작
        _showMessage(l10n.drawCardMessage);
      }
    });
  }

  // 다음 턴 자동 진행 타이머 시작
  void _startNextTurnTimer({int seconds = 5}) {
    _cancelNextTurnTimer();
    _autoPlayCountdown = seconds;

    // 메시지 타이머 취소 (타이머 동안 메시지 유지)
    _messageTimer?.cancel();

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

  // 다음 턴 타이머 취소
  void _cancelNextTurnTimer() {
    _nextTurnTimer?.cancel();
    _nextTurnTimer = null;
  }

  // 컴퓨터 동작 후 대기 상태로 전환 (다음 동작을 콜백으로 저장)
  void _startWaitWithAction(VoidCallback nextAction, {int seconds = 5}) {
    setState(() {
      waitingForNextTurn = true;
      _pendingComputerAction = nextAction;
    });
    _startNextTurnTimer(seconds: seconds);
  }

  // 다음 턴 버튼 클릭
  void _onNextTurn() {
    _cancelNextTurnTimer();
    final pendingAction = _pendingComputerAction;
    setState(() {
      waitingForNextTurn = false;
      _pendingComputerAction = null;
    });
    _messageTimer?.cancel();

    if (gameOver) return;

    // 대기 중인 컴퓨터 동작이 있으면 실행
    if (pendingAction != null) {
      Timer(const Duration(milliseconds: 300), () {
        if (mounted && !gameOver) {
          pendingAction();
        }
      });
      return;
    }

    // 플레이어 후 순서 컴퓨터 땡큐 확인
    final afterResult = _checkComputerThankYouAfterPlayer(_lastDiscardTurn);
    if (afterResult != null) {
      Timer(const Duration(milliseconds: 300), () {
        if (mounted && !gameOver) {
          _executeComputerThankYou(afterResult);
        }
      });
      return;
    }

    // 땡큐 없으면 다음 턴 진행
    if (currentTurn != 0) {
      Timer(const Duration(milliseconds: 300), () {
        if (mounted && !gameOver) {
          _computerTurn();
        }
      });
    }
  }

  void _sortHand(List<PlayingCard> hand) {
    hand.sort((a, b) {
      if (a.suit != b.suit) {
        return a.suitIndex.compareTo(b.suitIndex);
      }
      return a.rank.compareTo(b.rank);
    });
  }

  // 카드를 Map으로 변환
  Map<String, dynamic> _cardToMap(PlayingCard card) {
    return {
      'suit': card.suit.index,
      'rank': card.rank,
    };
  }

  // Map에서 카드 복원
  PlayingCard _mapToCard(Map<String, dynamic> map) {
    return PlayingCard(
      suit: Suit.values[map['suit'] as int],
      rank: map['rank'] as int,
    );
  }

  // 멜드를 Map으로 변환
  Map<String, dynamic> _meldToMap(Meld meld) {
    return {
      'cards': meld.cards.map(_cardToMap).toList(),
      'isRun': meld.isRun,
    };
  }

  // Map에서 멜드 복원
  Meld _mapToMeld(Map<String, dynamic> map) {
    final cardsList = (map['cards'] as List)
        .map((c) => _mapToCard(c as Map<String, dynamic>))
        .toList();
    return Meld(
      cards: cardsList,
      isRun: map['isRun'] as bool,
    );
  }

  // 게임 상태 저장
  Future<void> _saveGame() async {
    if (gameOver) {
      await HulaScreen.clearSavedGame();
      return;
    }

    final gameState = {
      'playerCount': playerCount,
      'difficulty': widget.difficulty.index,
      'deck': deck.map(_cardToMap).toList(),
      'discardPile': discardPile.map(_cardToMap).toList(),
      'playerHand': playerHand.map(_cardToMap).toList(),
      'computerHands': computerHands
          .map((hand) => hand.map(_cardToMap).toList())
          .toList(),
      'playerMelds': playerMelds.map(_meldToMap).toList(),
      'computerMelds': computerMelds
          .map((melds) => melds.map(_meldToMap).toList())
          .toList(),
      'currentTurn': currentTurn,
      'hasDrawn': hasDrawn,
      'scores': scores,
      'computerDifficulties': computerDifficulties,
      'waitingForNextTurn': waitingForNextTurn,
      'lastDiscardTurn': _lastDiscardTurn,
    };

    await GameSaveService.saveGame('hula', gameState);
  }

  // 저장된 게임 불러오기
  Future<void> _loadSavedGame() async {
    final gameState = await GameSaveService.loadGame('hula');

    if (gameState == null) {
      _initGame();
      return;
    }

    setState(() {
      playerCount = gameState['playerCount'] as int;

      // 덱 복원
      deck = (gameState['deck'] as List)
          .map((c) => _mapToCard(c as Map<String, dynamic>))
          .toList();

      // 버린 더미 복원
      discardPile = (gameState['discardPile'] as List)
          .map((c) => _mapToCard(c as Map<String, dynamic>))
          .toList();

      // 플레이어 손패 복원
      playerHand = (gameState['playerHand'] as List)
          .map((c) => _mapToCard(c as Map<String, dynamic>))
          .toList();

      // 컴퓨터 손패 복원
      computerHands = (gameState['computerHands'] as List)
          .map((hand) => (hand as List)
              .map((c) => _mapToCard(c as Map<String, dynamic>))
              .toList())
          .toList();

      // 플레이어 멜드 복원
      playerMelds = (gameState['playerMelds'] as List)
          .map((m) => _mapToMeld(m as Map<String, dynamic>))
          .toList();

      // 컴퓨터 멜드 복원
      computerMelds = (gameState['computerMelds'] as List)
          .map((melds) => (melds as List)
              .map((m) => _mapToMeld(m as Map<String, dynamic>))
              .toList())
          .toList();

      currentTurn = gameState['currentTurn'] as int;
      hasDrawn = gameState['hasDrawn'] as bool;
      scores = List<int>.from(gameState['scores'] as List);

      // 난이도 복원 (저장된 게임에 없으면 선택된 난이도 사용)
      if (gameState.containsKey('computerDifficulties')) {
        computerDifficulties = List<int>.from(gameState['computerDifficulties'] as List);
      } else {
        final difficultyValue = widget.difficulty.index;
        computerDifficulties = List.generate(playerCount - 1, (_) => difficultyValue);
      }

      gameOver = false;
      winner = null;
      winnerIndex = null;
      isHula = false;
      selectedCardIndices = [];

      // 대기 상태 복원
      waitingForNextTurn = gameState['waitingForNextTurn'] as bool? ?? false;
      _lastDiscardTurn = gameState['lastDiscardTurn'] as int? ?? 0;

      // 내 차례에서는 대기 상태 불필요 (타이머/시작버튼 없음)
      if (currentTurn == 0) {
        waitingForNextTurn = false;
      }
    });
    _cancelNextTurnTimer();

    // 내 차례면 메시지만 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      if (currentTurn == 0) {
        _showMessage(hasDrawn ? l10n.discardOrMeldMessage : l10n.drawCardMessage);
      }
      // 컴퓨터 턴이고 대기 상태면 타이머 시작
      else if (waitingForNextTurn) {
        _startNextTurnTimer();
      }
      // 컴퓨터 턴이고 드로우 전이면 대기 상태로 만들고 타이머 시작
      else if (!hasDrawn) {
        setState(() {
          waitingForNextTurn = true;
        });
        _startNextTurnTimer();
      }
      // 컴퓨터 턴이고 드로우 후면 버리기 단계로 진행
      else {
        final computerIndex = currentTurn - 1;
        _computerActionTimer = Timer(const Duration(milliseconds: 500), () {
          if (mounted && !gameOver) {
            _computerTurnDiscard(computerIndex);
          }
        });
      }
    });
  }

  void _showMessage(String message, {int seconds = 2, bool keepDuringWait = false}) {
    setState(() {
      gameMessage = message;
    });
    _messageTimer?.cancel();
    // 메시지는 다음 동작까지 항상 유지 (타이머로 지우지 않음)
  }

  // 덱에서 카드 드로우
  void _drawFromDeck() {
    if (hasDrawn || gameOver || currentTurn != 0) return;

    // 대기 상태면 타이머 취소
    if (waitingForNextTurn) {
      _cancelNextTurnTimer();
    }

    if (deck.isEmpty) {
      // 덱이 비면 버린 더미 섞기
      if (discardPile.length <= 1) {
        final l10n = AppLocalizations.of(context)!;
        _showMessage(l10n.noCardsMessage);
        return;
      }
      final topCard = discardPile.removeLast();
      deck = List.from(discardPile);
      deck.shuffle(Random());
      discardPile = [topCard];
    }

    final card = deck.removeLast();
    playerHand.add(card);
    _sortHand(playerHand);

    setState(() {
      hasDrawn = true;
      selectedCardIndices = [];
      waitingForNextTurn = false;
    });
    _showMessage(AppLocalizations.of(context)!.drewCardWithCard('${card.suitSymbol}${card.rankString}'));
    _saveGame();
  }

  // 버린 더미에서 카드 가져오기 (땡큐)
  void _drawFromDiscard() {
    if (gameOver) return;
    if (discardPile.isEmpty) return;

    // 플레이어 턴이거나, 대기 중일 때 (땡큐)
    if (currentTurn == 0 && hasDrawn) return;
    if (currentTurn != 0 && !waitingForNextTurn) return;

    // 땡큐 가능 여부 확인 (등록 가능한 경우에만)
    if (!_canThankYou()) return;

    // 모든 가능한 옵션 찾기
    final options = _findAllThankYouOptions();
    if (options.isEmpty) return;

    // 옵션이 1개면 바로 실행, 2개 이상이면 선택 다이얼로그
    if (options.length == 1) {
      _executeThankYouOption(options.first);
    } else {
      _showThankYouOptionsDialog(options);
    }
  }

  // 땡큐 옵션 선택 다이얼로그 표시
  void _showThankYouOptionsDialog(List<ThankYouOption> options) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Text(
              '${options.first.discardCard.suitSymbol}${options.first.discardCard.rankString}',
              style: TextStyle(
                color: options.first.discardCard.suitColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Text(l10n.thankYouSelectMethod),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: _buildOptionIcon(option),
                  title: Text(
                    option.getDescription(l10n),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.pop(dialogContext);
                    _executeThankYouOption(option);
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  // 옵션 아이콘 빌드
  Widget _buildOptionIcon(ThankYouOption option) {
    IconData icon;
    Color color;
    switch (option.type) {
      case ThankYouType.seven:
        icon = Icons.looks_one;
        color = Colors.purple;
      case ThankYouType.attachPlayer:
        icon = Icons.add_circle;
        color = Colors.green;
      case ThankYouType.attachComputer:
        icon = Icons.add_circle_outline;
        color = Colors.orange;
      case ThankYouType.newMeld:
        icon = option.isRun ? Icons.linear_scale : Icons.grid_view;
        color = Colors.blue;
    }
    return Icon(icon, color: color, size: 32);
  }

  // 땡큐 옵션 실행
  void _executeThankYouOption(ThankYouOption option) {
    final l10n = AppLocalizations.of(context)!;
    // 땡큐 상황: 대기 중에 가져가기
    if (waitingForNextTurn) {
      _cancelNextTurnTimer();
      setState(() {
        currentTurn = 0;
        waitingForNextTurn = false;
      });
    }

    final card = discardPile.removeLast();
    String meldMessage = '';

    switch (option.type) {
      case ThankYouType.seven:
        playerMelds.add(Meld(cards: [card], isRun: false));
        meldMessage = l10n.thankYouSolo(card.suitSymbol);

      case ThankYouType.attachPlayer:
        _attachToMeld(option.meldIndex!, card);
        meldMessage = l10n.thankYouAddToMine('${card.suitSymbol}${card.rankString}');

      case ThankYouType.attachComputer:
        _attachToMeldList(option.meldIndex!, card, computerMelds[option.computerIndex!]);
        final aiNames = _getAiNames(context);
        meldMessage = l10n.thankYouAddToAi('${card.suitSymbol}${card.rankString}', aiNames[option.computerIndex!]);

      case ThankYouType.newMeld:
        final newMeldCards = [...option.handCards, card];
        // 손패에서 제거
        for (final c in option.handCards) {
          playerHand.remove(c);
        }
        if (option.isRun) {
          newMeldCards.sort((a, b) => a.rank.compareTo(b.rank));
        }
        playerMelds.add(Meld(cards: newMeldCards, isRun: option.isRun));
        meldMessage = l10n.thankYouDesc(option.getDescription(l10n));
    }

    setState(() {
      hasDrawn = true;
      selectedCardIndices = [];
    });
    _showMessage(meldMessage);
    _saveGame();

    // 손패가 비었으면 승리
    if (playerHand.isEmpty) {
      _playerWins();
    }
  }

  // 카드 선택/해제
  void _toggleCardSelection(int index) {
    if (gameOver || currentTurn != 0) return;

    setState(() {
      if (selectedCardIndices.contains(index)) {
        selectedCardIndices.remove(index);
      } else {
        selectedCardIndices.add(index);
      }
      selectedCardIndices.sort();
    });
  }

  // 선택된 카드들이 유효한 멜드인지 확인
  bool _isValidMeld(List<PlayingCard> cards) {
    if (cards.length < 3) return false;

    // Group (같은 숫자) 체크
    if (_isValidGroup(cards)) return true;

    // Run (같은 무늬 연속) 체크
    if (_isValidRun(cards)) return true;

    return false;
  }

  bool _isValidGroup(List<PlayingCard> cards) {
    if (cards.length < 3 || cards.length > 4) return false;
    final rank = cards.first.rank;
    return cards.every((c) => c.rank == rank);
  }

  bool _isValidRun(List<PlayingCard> cards) {
    if (cards.length < 3) return false;

    final suit = cards.first.suit;
    if (!cards.every((c) => c.suit == suit)) return false;

    // 랭크 정렬
    final ranks = cards.map((c) => c.rank).toList()..sort();

    // A-2-3 또는 Q-K-A 처리
    // A를 1 또는 14로 취급
    bool isSequential = true;
    for (int i = 1; i < ranks.length; i++) {
      if (ranks[i] != ranks[i - 1] + 1) {
        isSequential = false;
        break;
      }
    }
    if (isSequential) return true;

    // A를 14로 취급해서 다시 체크 (Q-K-A)
    if (ranks.contains(1)) {
      final highRanks = ranks.map((r) => r == 1 ? 14 : r).toList()..sort();
      isSequential = true;
      for (int i = 1; i < highRanks.length; i++) {
        if (highRanks[i] != highRanks[i - 1] + 1) {
          isSequential = false;
          break;
        }
      }
      if (isSequential) return true;
    }

    return false;
  }

  // 기존 멜드에 카드 붙이기 가능 여부 확인
  int _canAttachToMeld(PlayingCard card) {
    for (int i = 0; i < playerMelds.length; i++) {
      final meld = playerMelds[i];

      // 단독 7 카드 특별 처리: Run으로만 확장 가능 (Group 불가)
      if (meld.cards.length == 1 && meld.cards.first.rank == 7) {
        final seven = meld.cards.first;
        // 같은 무늬의 6 또는 8이면 Run으로 확장
        if (card.suit == seven.suit && (card.rank == 6 || card.rank == 8)) {
          return i;
        }
        continue;
      }

      if (meld.isRun) {
        // Run: 같은 무늬이고 앞이나 뒤에 연속되는 카드
        if (card.suit == meld.cards.first.suit) {
          final ranks = meld.cards.map((c) => c.rank).toList()..sort();
          final minRank = ranks.first;
          final maxRank = ranks.last;

          // 앞에 붙이기 (A-2-3에 K 붙이기는 제외, 단 A가 14로 사용된 경우 제외)
          if (card.rank == minRank - 1) return i;
          // 뒤에 붙이기
          if (card.rank == maxRank + 1) return i;
          // A를 14로 취급 (Q-K-A 케이스)
          if (maxRank == 13 && card.rank == 1) return i;
          // A-2-3에서 A 앞에 K는 안됨 (A가 1로 사용된 경우)
        }
      } else {
        // Group: 같은 숫자 (최대 4장까지)
        if (meld.cards.length < 4 && card.rank == meld.cards.first.rank) {
          // 이미 같은 무늬가 있는지 확인
          if (!meld.cards.any((c) => c.suit == card.suit)) {
            return i;
          }
        }
      }
    }
    return -1;
  }

  // 멜드에 카드 붙이기
  void _attachToMeld(int meldIndex, PlayingCard card) {
    final meld = playerMelds[meldIndex];
    final newCards = [...meld.cards, card];
    bool newIsRun = meld.isRun;

    // 단독 7 카드에 붙이는 경우: Run 또는 Group 결정
    if (meld.cards.length == 1 && meld.cards.first.rank == 7) {
      final seven = meld.cards.first;
      if (card.suit == seven.suit && (card.rank == 6 || card.rank == 8)) {
        // 같은 무늬의 6 또는 8 → Run으로 변환
        newIsRun = true;
      } else {
        // 다른 7 → Group 유지
        newIsRun = false;
      }
    }

    if (newIsRun) {
      // Run은 정렬
      newCards.sort((a, b) => a.rank.compareTo(b.rank));
    }

    playerMelds[meldIndex] = Meld(cards: newCards, isRun: newIsRun);
  }

  // 7 카드인지 확인
  bool _isSeven(PlayingCard card) => card.rank == 7;

  // 특정 무늬의 7이 멜드로 등록되었는지 확인
  bool _isSevenRegistered(Suit suit) {
    // 플레이어 멜드에서 확인
    for (final meld in playerMelds) {
      if (meld.cards.any((c) => c.rank == 7 && c.suit == suit)) {
        return true;
      }
    }
    // 컴퓨터 멜드에서 확인
    for (final melds in computerMelds) {
      for (final meld in melds) {
        if (meld.cards.any((c) => c.rank == 7 && c.suit == suit)) {
          return true;
        }
      }
    }
    return false;
  }

  // 특정 숫자의 카드가 멜드에 몇 장 있는지 확인
  int _countMeldedCards(int rank) {
    int count = 0;
    // 플레이어 멜드에서 확인
    for (final meld in playerMelds) {
      count += meld.cards.where((c) => c.rank == rank).length;
    }
    // 컴퓨터 멜드에서 확인
    for (final melds in computerMelds) {
      for (final meld in melds) {
        count += meld.cards.where((c) => c.rank == rank).length;
      }
    }
    return count;
  }

  // 등록된 런에 붙일 가능성 계산 (중간 카드가 남아있으면 보너스)
  // 예: 7-8-9 런이 있고, 내가 J를 가지고 있으면 10이 남아있을수록 J 가치 높음
  double _calculateRunAttachPotential(PlayingCard card) {
    double bonus = 0;

    // 모든 멜드에서 런 확인
    final allMelds = [...playerMelds];
    for (final melds in computerMelds) {
      allMelds.addAll(melds);
    }

    for (final meld in allMelds) {
      if (!meld.isRun || meld.cards.isEmpty) continue;
      if (meld.cards.first.suit != card.suit) continue;

      // 런의 최소/최대 랭크 찾기
      final ranks = meld.cards.map((c) => c.rank).toList()..sort();
      final minRank = ranks.first;
      final maxRank = ranks.last;

      // 카드가 런에서 1칸 떨어져 있으면 (바로 붙일 수 있음)
      if (card.rank == minRank - 1 || card.rank == maxRank + 1) {
        bonus += 30; // 바로 붙일 수 있음
      }
      // 카드가 런에서 2칸 떨어져 있으면 (중간 카드 필요)
      else if (card.rank == minRank - 2 || card.rank == maxRank + 2) {
        // 중간 카드가 남아있는지 확인 (각 무늬당 1장뿐)
        final bridgeRank = card.rank < minRank ? minRank - 1 : maxRank + 1;
        final bridgeUsed = discardPile.where((c) => c.rank == bridgeRank && c.suit == card.suit).length +
            _countMeldedCardsWithSuit(bridgeRank, card.suit);

        if (bridgeUsed == 0) {
          // 중간 카드가 남아있음 - 붙일 가능성 있음
          bonus += 25;
        }
        // bridgeUsed >= 1: 중간 카드가 사라짐 - 보너스 없음 (일반 단독 카드로 처리)
      }
    }

    return bonus;
  }

  // 특정 숫자와 무늬의 카드가 멜드에 있는지 확인
  int _countMeldedCardsWithSuit(int rank, Suit suit) {
    int count = 0;
    for (final meld in playerMelds) {
      count += meld.cards.where((c) => c.rank == rank && c.suit == suit).length;
    }
    for (final melds in computerMelds) {
      for (final meld in melds) {
        count += meld.cards.where((c) => c.rank == rank && c.suit == suit).length;
      }
    }
    return count;
  }

  // 땡큐 가능 여부 확인 (버린 카드를 가져와서 바로 등록 가능한지)
  // 주의: 새로운 멜드 등록이 가능할 때만 가져올 수 있음 (붙이기만 가능하면 안됨)
  bool _canThankYou() {
    if (discardPile.isEmpty) return false;
    final card = discardPile.last;

    // 1. 7이면 단독 등록 가능
    if (_isSeven(card)) return true;

    // 2. 손패와 합쳐서 새로운 멜드 가능한지 확인 (붙이기는 제외)
    final thankYouCards = _findThankYouMeldCards(card);
    if (thankYouCards != null) return true;

    return false;
  }

  // 땡큐 카드와 손패로 만들 수 있는 멜드 카드 찾기 (첫 번째만)
  List<PlayingCard>? _findThankYouMeldCards(PlayingCard discardCard) {
    final options = _findAllNewMeldOptions(discardCard);
    if (options.isNotEmpty) {
      return options.first.handCards;
    }
    return null;
  }

  // 모든 가능한 새 멜드 옵션 찾기 (손패와 합쳐서)
  List<ThankYouOption> _findAllNewMeldOptions(PlayingCard discardCard) {
    final options = <ThankYouOption>[];

    // Group 체크: 같은 숫자 2장 이상 있는지
    final sameRank = playerHand.where((c) => c.rank == discardCard.rank).toList();
    if (sameRank.length >= 2) {
      // 3장 Group
      options.add(ThankYouOption(
        type: ThankYouType.newMeld,
        discardCard: discardCard,
        handCards: sameRank.take(2).toList(),
        isRun: false,
      ));
    }

    // Run 체크: 같은 무늬의 연속 숫자
    final sameSuit = playerHand.where((c) => c.suit == discardCard.suit).toList();
    if (sameSuit.length >= 2) {
      sameSuit.sort((a, b) => a.rank.compareTo(b.rank));

      // 모든 2장 조합 체크
      for (int i = 0; i < sameSuit.length; i++) {
        for (int j = i + 1; j < sameSuit.length; j++) {
          final c1 = sameSuit[i];
          final c2 = sameSuit[j];

          // c1, c2, discardCard가 연속인지 확인
          final ranks = [c1.rank, c2.rank, discardCard.rank]..sort();
          bool isSequential = ranks[1] == ranks[0] + 1 && ranks[2] == ranks[1] + 1;

          // A-2-3 또는 Q-K-A 특수 케이스
          if (!isSequential && ranks.contains(1)) {
            final highRanks = ranks.map((r) => r == 1 ? 14 : r).toList()..sort();
            isSequential = highRanks[1] == highRanks[0] + 1 && highRanks[2] == highRanks[1] + 1;
          }

          if (isSequential) {
            options.add(ThankYouOption(
              type: ThankYouType.newMeld,
              discardCard: discardCard,
              handCards: [c1, c2],
              isRun: true,
            ));
          }
        }
      }
    }

    return options;
  }

  // 모든 땡큐 옵션 찾기
  List<ThankYouOption> _findAllThankYouOptions() {
    if (discardPile.isEmpty) return [];
    final card = discardPile.last;
    final options = <ThankYouOption>[];
    final aiNames = _getAiNames(context);

    // 1. 7이면 단독 등록 가능
    if (_isSeven(card)) {
      options.add(ThankYouOption(
        type: ThankYouType.seven,
        discardCard: card,
      ));
    }

    // 2. 플레이어 멜드에 붙이기 가능
    for (int i = 0; i < playerMelds.length; i++) {
      if (_canAttachToMeldAtIndex(card, playerMelds, i)) {
        options.add(ThankYouOption(
          type: ThankYouType.attachPlayer,
          discardCard: card,
          meldIndex: i,
        ));
      }
    }

    // 3. 컴퓨터 멜드에 붙이기 가능
    for (int c = 0; c < computerMelds.length; c++) {
      for (int i = 0; i < computerMelds[c].length; i++) {
        if (_canAttachToMeldAtIndex(card, computerMelds[c], i)) {
          options.add(ThankYouOption(
            type: ThankYouType.attachComputer,
            discardCard: card,
            meldIndex: i,
            computerIndex: c,
            computerName: aiNames[c],
          ));
        }
      }
    }

    // 4. 손패와 합쳐서 새 멜드 생성
    options.addAll(_findAllNewMeldOptions(card));

    return options;
  }

  // 특정 인덱스의 멜드에 카드를 붙일 수 있는지 확인
  bool _canAttachToMeldAtIndex(PlayingCard card, List<Meld> melds, int index) {
    if (index < 0 || index >= melds.length) return false;
    final meld = melds[index];

    // 단독 7 카드 특별 처리: Run으로만 확장 가능 (Group 불가)
    if (meld.cards.length == 1 && meld.cards.first.rank == 7) {
      final seven = meld.cards.first;
      if (card.suit == seven.suit && (card.rank == 6 || card.rank == 8)) {
        return true;
      }
      return false;
    }

    if (meld.isRun) {
      if (card.suit == meld.cards.first.suit) {
        final ranks = meld.cards.map((c) => c.rank).toList()..sort();
        final minRank = ranks.first;
        final maxRank = ranks.last;
        if (card.rank == minRank - 1) return true;
        if (card.rank == maxRank + 1) return true;
        if (maxRank == 13 && card.rank == 1) return true;
      }
    } else {
      if (meld.cards.length < 4 && card.rank == meld.cards.first.rank) {
        if (!meld.cards.any((c) => c.suit == card.suit)) {
          return true;
        }
      }
    }
    return false;
  }

  // 범용: 특정 멜드 목록에 카드를 붙일 수 있는지 확인
  int _canAttachToMeldList(PlayingCard card, List<Meld> melds) {
    for (int i = 0; i < melds.length; i++) {
      final meld = melds[i];

      // 단독 7 카드 특별 처리: Run으로만 확장 가능 (Group 불가)
      if (meld.cards.length == 1 && meld.cards.first.rank == 7) {
        final seven = meld.cards.first;
        if (card.suit == seven.suit && (card.rank == 6 || card.rank == 8)) {
          return i;
        }
        continue;
      }

      if (meld.isRun) {
        if (card.suit == meld.cards.first.suit) {
          final ranks = meld.cards.map((c) => c.rank).toList()..sort();
          final minRank = ranks.first;
          final maxRank = ranks.last;
          if (card.rank == minRank - 1) return i;
          if (card.rank == maxRank + 1) return i;
          if (maxRank == 13 && card.rank == 1) return i;
        }
      } else {
        if (meld.cards.length < 4 && card.rank == meld.cards.first.rank) {
          if (!meld.cards.any((c) => c.suit == card.suit)) {
            return i;
          }
        }
      }
    }
    return -1;
  }

  // 범용: 특정 멜드 목록에 카드 붙이기
  void _attachToMeldList(int meldIndex, PlayingCard card, List<Meld> melds) {
    final meld = melds[meldIndex];
    final newCards = [...meld.cards, card];
    bool newIsRun = meld.isRun;

    if (meld.cards.length == 1 && meld.cards.first.rank == 7) {
      final seven = meld.cards.first;
      if (card.suit == seven.suit && (card.rank == 6 || card.rank == 8)) {
        newIsRun = true;
      } else {
        newIsRun = false;
      }
    }

    if (newIsRun) {
      newCards.sort((a, b) => a.rank.compareTo(b.rank));
    }

    melds[meldIndex] = Meld(cards: newCards, isRun: newIsRun);
  }

  // AI 추천 버릴 카드 인덱스 (플레이어용)
  int? _getRecommendedDiscardCardIndex() {
    if (playerHand.isEmpty) return null;
    if (currentTurn != 0 || !hasDrawn) return null; // 버리기 단계가 아님

    final recommendedCard = _selectCardToDiscard(playerHand);
    return playerHand.indexOf(recommendedCard);
  }

  // 스마트 카드 버리기: 버릴 카드 선택
  PlayingCard _selectCardToDiscard(List<PlayingCard> hand, {int? computerIndex}) {
    if (hand.length == 1) return hand.first;

    // 난이도에 따른 랜덤 선택 확률 (쉬움: 40%, 보통: 15%, 어려움: 0%)
    if (computerIndex != null && computerIndex < computerDifficulties.length) {
      final difficulty = computerDifficulties[computerIndex];
      final randomChance = difficulty == 0 ? 40 : (difficulty == 1 ? 15 : 0);
      if (Random().nextInt(100) < randomChance) {
        // 랜덤하게 카드 선택 (단, 7은 제외)
        final nonSevenCards = hand.where((c) => !_isSeven(c)).toList();
        if (nonSevenCards.isNotEmpty) {
          return nonSevenCards[Random().nextInt(nonSevenCards.length)];
        }
      }
    }

    // 각 카드의 "유지 가치" 점수 계산 (높을수록 유지해야 함)
    final scores = <PlayingCard, double>{};

    for (final card in hand) {
      double keepScore = 0;

      // 1. 7 카드는 절대 버리면 안 됨 (단독 등록 가능)
      if (_isSeven(card)) {
        keepScore += 1000;
      }

      // 1-1. 6이나 8 카드는 같은 무늬 7이 등록되지 않았으면 유지 (7 등록 후 붙이기 가능)
      if (card.rank == 6 || card.rank == 8) {
        final sevenOfSameSuit = _isSevenRegistered(card.suit);
        if (!sevenOfSameSuit) {
          // 7이 아직 등록되지 않았으면 6/8 유지 가치 높임
          keepScore += 80;
        }
      }

      // 1-2. 5나 9 카드는 6/8 다음 우선순위 (5-6-7 또는 7-8-9 런 가능)
      if (card.rank == 5 || card.rank == 9) {
        final sevenOfSameSuit = _isSevenRegistered(card.suit);
        if (!sevenOfSameSuit) {
          // 7이 아직 등록되지 않았으면 5/9 유지 가치 높임 (6/8보다 낮은 우선순위)
          keepScore += 60;
        }
      }

      // 1-3. A/2/3 단독 카드는 스톱 시 점수가 낮아서 유리 (나중에 버리기)
      // 5/6/7/8/9는 별도 런 보너스가 있으므로 제외
      final sameRankCountForLow = hand.where((c) => c.rank == card.rank).length;
      if (sameRankCountForLow == 1 && !(card.rank >= 5 && card.rank <= 9)) {
        if (card.rank == 1) {
          keepScore += 50; // A: 가장 낮은 점수
        } else if (card.rank == 2) {
          keepScore += 45;
        } else if (card.rank == 3) {
          keepScore += 40;
        } else {
          // 1-4. 기타 단독 카드 (4, 10, J, Q, K)는 숫자 역순으로 버리기
          // rank가 높을수록 keepScore가 낮아짐
          keepScore += (14 - card.rank) * 4; // 4→40, 10→16, K→4
        }
      }

      // 2. 같은 숫자 카드 개수 (Group 가능성)
      final sameRankCount = hand.where((c) => c.rank == card.rank).length;
      if (sameRankCount >= 2) {
        // 먼저 그룹 완성 가능 여부 확인
        final discardedSameRank = discardPile.where((c) => c.rank == card.rank).length;
        final meldedSameRank = _countMeldedCards(card.rank);
        final usedSameRank = discardedSameRank + meldedSameRank;

        if (usedSameRank >= 2) {
          // 그룹 완성 불가능 - 단독 카드와 동일하게 처리 (숫자 역순으로 버리기)
          // 5/6/7/8/9는 제외 (별도 런 보너스)
          if (!(card.rank >= 5 && card.rank <= 9)) {
            if (card.rank == 1) {
              keepScore += 50;
            } else if (card.rank == 2) {
              keepScore += 45;
            } else if (card.rank == 3) {
              keepScore += 40;
            } else {
              keepScore += (14 - card.rank) * 4; // K→4, Q→8, J→12, 4→40
            }
          }
        } else {
          // 그룹 완성 가능 - 페어 보너스 적용
          keepScore += sameRankCount * 30; // 2장: 60, 3장: 90
          // K/Q/J 페어는 추가 보너스 (다른 플레이어가 버릴 확률 높음)
          if (card.rank >= 11) {
            keepScore += 40;
          }
          // 1장 사용됨 - 확률 낮아짐
          if (usedSameRank == 1) {
            keepScore -= 20;
          }
        }
      }

      // 3. 같은 무늬 연속 카드 (Run 가능성)
      final sameSuitCards = hand.where((c) => c.suit == card.suit).toList();
      if (sameSuitCards.length >= 2) {
        sameSuitCards.sort((a, b) => a.rank.compareTo(b.rank));
        int consecutiveCount = 1;
        for (int i = 0; i < sameSuitCards.length - 1; i++) {
          // 연속이거나 1칸 건너뛴 경우 (2,4 같은 경우 3이 오면 Run 가능)
          final diff = sameSuitCards[i + 1].rank - sameSuitCards[i].rank;
          if (diff == 1 || diff == 2) {
            if (sameSuitCards[i].rank == card.rank ||
                sameSuitCards[i + 1].rank == card.rank) {
              consecutiveCount++;
            }
          }
        }
        if (consecutiveCount >= 2) {
          keepScore += consecutiveCount * 25; // 2장 연속: 50, 3장: 75
        }
      }

      // 4. 등록된 런에 붙일 가능성 확인 (중간 카드가 남아있으면 가치 높음)
      final runAttachBonus = _calculateRunAttachPotential(card);
      keepScore += runAttachBonus;

      // 5. 버린 더미에서 같은 카드 확인 (확률 계산)
      // 같은 숫자가 이미 많이 버려졌으면 Group 확률 낮음
      final discardedSameRank =
          discardPile.where((c) => c.rank == card.rank).length;
      if (discardedSameRank >= 2) {
        keepScore -= 20; // Group 가능성 낮음
      }

      // 같은 무늬의 필요한 카드가 버려졌으면 Run 확률 낮음
      final neededForRun = [card.rank - 1, card.rank + 1];
      final discardedNeeded = discardPile
          .where((c) => c.suit == card.suit && neededForRun.contains(c.rank))
          .length;
      if (discardedNeeded >= 1) {
        keepScore -= 15 * discardedNeeded;
      }

      // 5. 카드 점수 (낮은 점수 카드 유지 선호)
      keepScore -= card.point * 2;

      scores[card] = keepScore;
    }

    // 가장 낮은 유지 가치를 가진 카드 버리기
    final sortedCards = hand.toList()
      ..sort((a, b) => scores[a]!.compareTo(scores[b]!));

    // 최종 안전장치: 7은 절대 버리지 않음 (다른 카드가 있는 경우)
    final selectedCard = sortedCards.first;
    if (_isSeven(selectedCard)) {
      final nonSeven = sortedCards.firstWhere((c) => !_isSeven(c), orElse: () => selectedCard);
      return nonSeven;
    }

    return selectedCard;
  }

  // 훌라 가능성 분석 (모든 카드를 한 번에 낼 수 있는지)
  // 반환: { 'canHula': bool, 'playableCount': int, 'probability': double }
  Map<String, dynamic> _analyzeHulaPotential(List<PlayingCard> hand, List<Meld> melds) {
    // 이미 멜드가 등록되어 있으면 훌라 불가능
    if (melds.isNotEmpty) {
      return {'canHula': false, 'playableCount': 0, 'probability': 0.0};
    }

    if (hand.isEmpty) {
      return {'canHula': true, 'playableCount': 0, 'probability': 100.0};
    }

    // 시뮬레이션: 모든 카드를 낼 수 있는지 계산
    final testHand = List<PlayingCard>.from(hand);
    final testMelds = <Meld>[];
    int playableCount = 0;

    // 1. 모든 가능한 멜드 찾기 (3장 이상)
    List<PlayingCard>? meld;
    while ((meld = _findBestMeld(testHand)) != null) {
      for (final card in meld!) {
        testHand.remove(card);
        playableCount++;
      }
      final isRun = _isValidRun(meld);
      testMelds.add(Meld(cards: meld, isRun: isRun));
    }

    // 2. 7 카드 단독 등록
    final sevens = testHand.where((c) => _isSeven(c)).toList();
    for (final seven in sevens) {
      testHand.remove(seven);
      testMelds.add(Meld(cards: [seven], isRun: false));
      playableCount++;
    }

    // 3. 자신의 멜드에 붙일 수 있는 카드
    bool attached = true;
    while (attached && testMelds.isNotEmpty) {
      attached = false;
      for (int i = testHand.length - 1; i >= 0; i--) {
        final card = testHand[i];
        final meldIndex = _canAttachToMeldList(card, testMelds);
        if (meldIndex >= 0) {
          _attachToMeldList(meldIndex, card, testMelds);
          testHand.removeAt(i);
          playableCount++;
          attached = true;
        }
      }
    }

    // 4. 다른 플레이어 멜드에 붙일 수 있는 카드 (자신의 멜드가 생긴 후에만)
    if (testMelds.isNotEmpty) {
      attached = true;
      while (attached && testHand.isNotEmpty) {
        attached = false;
        for (int i = testHand.length - 1; i >= 0; i--) {
          final card = testHand[i];

          // 플레이어 멜드에 붙이기
          if (playerMelds.isNotEmpty) {
            final idx = _canAttachToMeldList(card, playerMelds);
            if (idx >= 0) {
              testHand.removeAt(i);
              playableCount++;
              attached = true;
              continue;
            }
          }

          // 컴퓨터 멜드에 붙이기
          for (int c = 0; c < computerMelds.length; c++) {
            if (computerMelds[c].isNotEmpty) {
              final idx = _canAttachToMeldList(card, computerMelds[c]);
              if (idx >= 0) {
                testHand.removeAt(i);
                playableCount++;
                attached = true;
                break;
              }
            }
          }
        }
      }
    }

    // 남은 카드 확인
    final remainingCount = testHand.length;
    final canHula = remainingCount == 0;

    // 확률 계산
    double probability = 0.0;
    if (canHula) {
      probability = 100.0;
    } else {
      // 남은 카드가 적을수록 확률 높음
      // 남은 카드로 멜드를 만들 수 있는 가능성 계산
      probability = _calculateRemainingProbability(testHand, hand.length);
    }

    return {
      'canHula': canHula,
      'playableCount': playableCount,
      'remainingCount': remainingCount,
      'probability': probability,
    };
  }

  // 남은 카드로 멜드를 만들 확률 계산
  double _calculateRemainingProbability(List<PlayingCard> remaining, int originalHandSize) {
    if (remaining.isEmpty) return 100.0;

    double probability = 0.0;
    final checked = <PlayingCard>{};

    // 1. 기존 멜드에 붙일 수 있는 카드 확인 (확률 높음)
    int attachableCount = 0;
    for (final card in remaining) {
      bool canAttach = false;
      // 플레이어 멜드
      if (playerMelds.isNotEmpty && _canAttachToMeldList(card, playerMelds) >= 0) {
        canAttach = true;
      }
      // 컴퓨터 멜드
      if (!canAttach) {
        for (final cMelds in computerMelds) {
          if (cMelds.isNotEmpty && _canAttachToMeldList(card, cMelds) >= 0) {
            canAttach = true;
            break;
          }
        }
      }
      if (canAttach) {
        attachableCount++;
        probability += 25.0; // 붙일 수 있는 카드는 확률 높음
      }
    }

    // 2. 붙일 수 없는 카드들의 Group/Run 가능성
    for (final card in remaining) {
      if (checked.contains(card)) continue;
      checked.add(card);

      // 같은 숫자 카드 확인 (Group 가능성)
      final sameRank = remaining.where((c) => c.rank == card.rank).length;
      final discardedSameRank = discardPile.where((c) => c.rank == card.rank).length;
      final totalSameRank = sameRank + discardedSameRank;

      // 4장 중 남은 장수로 Group 확률 계산
      if (sameRank >= 2) {
        final neededForGroup = 3 - sameRank;
        final availableInDeck = 4 - totalSameRank;
        if (availableInDeck >= neededForGroup) {
          probability += 20.0 * (availableInDeck / 4.0);
        }
      }

      // 같은 무늬 연속 카드 확인 (Run 가능성)
      final sameSuit = remaining.where((c) => c.suit == card.suit).toList();
      if (sameSuit.length >= 2) {
        sameSuit.sort((a, b) => a.rank.compareTo(b.rank));
        // 연속 카드 확인
        bool hasConsecutive = false;
        for (int i = 0; i < sameSuit.length - 1; i++) {
          if (sameSuit[i + 1].rank - sameSuit[i].rank <= 2) {
            hasConsecutive = true;
            break;
          }
        }
        if (hasConsecutive) {
          // 필요한 카드가 버려졌는지 확인
          final neededRanks = <int>[];
          for (final c in sameSuit) {
            neededRanks.addAll([c.rank - 1, c.rank + 1]);
          }
          final discardedNeeded = discardPile
              .where((c) => c.suit == card.suit && neededRanks.contains(c.rank))
              .length;
          probability += 15.0 * (1 - discardedNeeded / neededRanks.length);
        }
      }
    }

    // 남은 카드 수에 따른 페널티 (붙일 수 있는 카드 제외)
    final nonAttachable = remaining.length - attachableCount;
    final remainingPenalty = nonAttachable * 10.0;
    probability = (probability - remainingPenalty).clamp(0.0, 100.0);

    return probability;
  }

  // 다른 플레이어의 스톱 위험도 계산
  // 반환: 0.0 ~ 100.0 (높을수록 스톱 가능성 높음)
  double _estimateStopRisk(int myIndex) {
    double maxRisk = 0.0;

    // 플레이어(0) 체크
    if (myIndex != 0) {
      final playerRisk = _calculatePlayerStopRisk(playerHand, playerMelds);
      maxRisk = maxRisk > playerRisk ? maxRisk : playerRisk;
    }

    // 다른 컴퓨터들 체크
    for (int i = 0; i < computerHands.length; i++) {
      if (i + 1 == myIndex) continue; // 자신 제외

      final risk = _calculatePlayerStopRisk(computerHands[i], computerMelds[i]);
      maxRisk = maxRisk > risk ? maxRisk : risk;
    }

    return maxRisk;
  }

  // 특정 플레이어의 스톱 가능성 계산
  double _calculatePlayerStopRisk(List<PlayingCard> hand, List<Meld> melds) {
    double risk = 0.0;

    // 1. 손패 수에 따른 위험도 (적을수록 위험)
    // 3장 이하: 매우 위험, 5장 이하: 위험, 7장 이하: 주의
    if (hand.length <= 2) {
      risk += 80.0;
    } else if (hand.length <= 3) {
      risk += 60.0;
    } else if (hand.length <= 4) {
      risk += 40.0;
    } else if (hand.length <= 5) {
      risk += 25.0;
    } else if (hand.length <= 7) {
      risk += 10.0;
    }

    // 2. 등록된 멜드 수에 따른 위험도
    // 멜드가 많을수록 카드 정리가 잘 되어 있음
    if (melds.length >= 4) {
      risk += 30.0;
    } else if (melds.length >= 3) {
      risk += 20.0;
    } else if (melds.length >= 2) {
      risk += 10.0;
    }

    // 3. 손패 점수 추정 (낮을수록 스톱 가능성 높음)
    final handScore = _calculateHandScore(hand);
    if (handScore <= 5) {
      risk += 25.0;
    } else if (handScore <= 10) {
      risk += 15.0;
    } else if (handScore <= 20) {
      risk += 5.0;
    }

    // 4. 기존 멜드에 붙일 수 있는 카드 수 (멜드가 있을 때만)
    if (melds.isNotEmpty) {
      int attachableCount = 0;
      for (final card in hand) {
        // 자신의 멜드에 붙이기
        if (_canAttachToMeldList(card, melds) >= 0) {
          attachableCount++;
          continue;
        }
        // 플레이어 멜드에 붙이기
        if (playerMelds.isNotEmpty && _canAttachToMeldList(card, playerMelds) >= 0) {
          attachableCount++;
          continue;
        }
        // 컴퓨터 멜드에 붙이기
        for (final cMelds in computerMelds) {
          if (cMelds.isNotEmpty && _canAttachToMeldList(card, cMelds) >= 0) {
            attachableCount++;
            break;
          }
        }
      }
      // 붙일 수 있는 카드가 많을수록 위험도 증가
      if (attachableCount >= 3) {
        risk += 20.0;
      } else if (attachableCount >= 2) {
        risk += 12.0;
      } else if (attachableCount >= 1) {
        risk += 5.0;
      }
    }

    return risk.clamp(0.0, 100.0);
  }

  // 컴퓨터가 스톱을 외칠지 결정
  bool _shouldComputerCallStop(int computerIndex) {
    // 난이도에 따른 스톱 확률 (쉬움: 0%, 보통: 50%, 어려움: 100%)
    final difficulty = computerDifficulties.length > computerIndex
        ? computerDifficulties[computerIndex]
        : 2;
    if (difficulty == 0) return false; // 쉬운 난이도는 스톱 안 함

    final myHand = computerHands[computerIndex];
    final myScore = _calculateHandScore(myHand);

    // 1. 손패가 너무 많으면 스톱 안 함 (불리할 가능성)
    if (myHand.length > 5) return false;

    // 2. 내 점수가 너무 높으면 스톱 안 함
    if (myScore > 15) return false;

    // 3. 다른 플레이어 점수 추정 및 비교
    int betterCount = 0; // 나보다 점수가 낮을 것 같은 플레이어 수
    int totalPlayers = playerCount - 1; // 자신 제외
    bool someoneAboutToWin = false;

    // 플레이어 확인
    final playerScore = _calculateHandScore(playerHand);
    if (playerScore < myScore) {
      betterCount++;
    }
    if (playerHand.length <= 2) {
      someoneAboutToWin = true;
    }

    // 다른 컴퓨터 확인
    for (int i = 0; i < computerHands.length; i++) {
      if (i == computerIndex) continue;

      final otherHand = computerHands[i];
      final otherScore = _calculateHandScore(otherHand);

      if (otherScore < myScore) {
        betterCount++;
      }
      if (otherHand.length <= 2) {
        someoneAboutToWin = true;
      }
    }

    // 4. 스톱 결정 조건

    // 4-1. 내 점수가 0이면 무조건 스톱 (완벽)
    if (myScore == 0) return true;

    // 4-2. 상대가 곧 이길 것 같고 내 점수가 낮으면 선제 스톱
    if (someoneAboutToWin && myScore <= 5 && betterCount == 0) {
      return true;
    }

    // 4-3. 손패 2장 이하 & 점수 5점 이하 & 모든 상대보다 유리
    if (myHand.length <= 2 && myScore <= 5 && betterCount == 0) {
      return true;
    }

    // 4-4. 손패 3장 이하 & 점수 3점 이하 & 절반 이상 상대보다 유리
    if (myHand.length <= 3 && myScore <= 3 && betterCount <= totalPlayers / 2) {
      return true;
    }

    // 4-5. 손패 1장 & 점수 10점 이하 (거의 확실히 유리)
    if (myHand.length == 1 && myScore <= 10 && betterCount == 0) {
      // 보통 난이도는 50% 확률
      if (difficulty == 1 && Random().nextInt(100) >= 50) return false;
      return true;
    }

    return false;
  }

  // 컴퓨터가 스톱 선언
  void _computerCallStop(int computerIndex) {
    final l10n = AppLocalizations.of(context)!;
    final aiNames = _getAiNames(context);
    _showMessage('${aiNames[computerIndex]} ${l10n.stop}!');
    _calculateScoresAndEnd(stopperIndex: computerIndex + 1); // 컴퓨터 인덱스 + 1
  }

  // 멜드 등록 여부 결정 (훌라 가능성 + 스톱 위험도 고려)
  bool _shouldRegisterMelds(List<PlayingCard> hand, List<Meld> melds, {int? computerIndex}) {
    // 이미 멜드가 있으면 훌라 불가능 → 등록해도 됨
    if (melds.isNotEmpty) return true;

    final analysis = _analyzeHulaPotential(hand, melds);

    // 훌라 가능하면 즉시 등록 (승리)
    if (analysis['canHula'] == true) return true;

    final probability = analysis['probability'] as double;
    final remainingCount = analysis['remainingCount'] as int;

    // 스톱 위험도 계산
    final myIndex = computerIndex ?? 0;
    final stopRisk = _estimateStopRisk(myIndex);
    final myHandScore = _calculateHandScore(hand);

    // 스톱 위험도가 높으면 등록하여 벌점 최소화
    // 위험도 70% 이상이고 내 손패 점수가 높으면 즉시 등록
    if (stopRisk >= 70.0 && myHandScore >= 15) {
      return true; // 방어적 등록
    }

    // 위험도 50% 이상이고 내 손패 점수가 매우 높으면 등록
    if (stopRisk >= 50.0 && myHandScore >= 25) {
      return true;
    }

    // 훌라 확률 vs 스톱 위험도 비교
    // 스톱 위험도가 훌라 확률보다 높으면 등록 고려
    if (stopRisk > probability && stopRisk >= 40.0) {
      // 단, 훌라가 거의 완성 상태면 (남은 카드 1장) 계속 시도
      if (remainingCount <= 1 && probability >= 50.0) {
        return false; // 훌라 시도 계속
      }
      return true; // 방어적 등록
    }

    // 훌라 확률이 높으면 대기
    // 60% 이상이고 남은 카드가 3장 이하면 훌라 시도
    if (probability >= 60.0 && remainingCount <= 3) {
      // 단, 스톱 위험도가 매우 높으면 등록
      if (stopRisk >= 60.0) {
        return true;
      }
      return false; // 등록 대기
    }

    // 손패가 많으면 일단 등록 (방어적)
    if (hand.length >= 10) return true;

    // 확률이 40% 이상이고 남은 카드가 2장 이하면 대기
    if (probability >= 40.0 && remainingCount <= 2) {
      // 단, 스톱 위험도가 높으면 등록
      if (stopRisk >= 50.0) {
        return true;
      }
      return false;
    }

    // 그 외에는 등록
    return true;
  }

  // 7 카드 3장 이상일 때 Group vs Run 전략 결정
  String _decideSevensStrategy(List<PlayingCard> sevens, List<PlayingCard> hand) {
    // Run 가능성 점수 계산
    double runPotential = 0;
    // Group 점수 (기본값: 3장 즉시 제거)
    double groupScore = 30;

    for (final seven in sevens) {
      final suit = seven.suit;

      // 손에 있는 6, 8 확인
      final hasSix = hand.any((c) => c.suit == suit && c.rank == 6);
      final hasEight = hand.any((c) => c.suit == suit && c.rank == 8);

      // 손에 있는 5, 9 확인 (더 긴 Run 가능성)
      final hasFive = hand.any((c) => c.suit == suit && c.rank == 5);
      final hasNine = hand.any((c) => c.suit == suit && c.rank == 9);

      // 버린 더미에서 6, 8 확인
      final discardedSix = discardPile.where((c) => c.suit == suit && c.rank == 6).length;
      final discardedEight = discardPile.where((c) => c.suit == suit && c.rank == 8).length;

      // Run 가능성 계산
      double sevenRunScore = 0;

      // 이미 6 또는 8을 가지고 있으면 Run 유리
      if (hasSix) sevenRunScore += 25;
      if (hasEight) sevenRunScore += 25;

      // 5 또는 9도 있으면 긴 Run 가능
      if (hasSix && hasFive) sevenRunScore += 15;
      if (hasEight && hasNine) sevenRunScore += 15;

      // 6, 8이 버려졌으면 Run 확률 낮음
      // 같은 숫자는 4장뿐이므로 2장 이상 버려지면 확률 낮음
      if (discardedSix >= 2) sevenRunScore -= 20;
      if (discardedEight >= 2) sevenRunScore -= 20;
      if (discardedSix == 1) sevenRunScore -= 5;
      if (discardedEight == 1) sevenRunScore -= 5;

      // 6, 8 모두 없고 버려진 것도 많으면 Run 불가능에 가까움
      if (!hasSix && !hasEight && discardedSix + discardedEight >= 2) {
        sevenRunScore -= 30;
      }

      runPotential += sevenRunScore;
    }

    // 평균 Run 가능성
    runPotential /= sevens.length;

    // Group 점수 조정
    // 4번째 7이 손에 있으면 Group 유리
    if (sevens.length >= 4) {
      groupScore += 20;
    }

    // 방어적 관점: 손패가 많으면 빨리 줄이는 Group 선호
    if (hand.length > 10) {
      groupScore += 15;
    }

    // 공격적 관점: 손패가 적으면 Run으로 더 많이 붙이기 선호
    if (hand.length <= 5) {
      runPotential += 10;
    }

    // 결정
    if (runPotential > groupScore) {
      return 'run';
    } else {
      return 'group';
    }
  }

  // 멜드 등록
  void _registerMeld() {
    final l10n = AppLocalizations.of(context)!;
    final selectedCards =
        selectedCardIndices.map((i) => playerHand[i]).toList();

    // 7 카드 단독 등록 (훌라 특별 규칙)
    if (selectedCardIndices.length == 1 && _isSeven(selectedCards.first)) {
      final card = selectedCards.first;
      playerHand.remove(card);
      playerMelds.add(Meld(cards: [card], isRun: false));

      setState(() {
        selectedCardIndices = [];
      });
      _showMessage(l10n.thankYouSolo(card.suitSymbol));
      _saveGame();

      if (playerHand.isEmpty) {
        _playerWins();
      }
      return;
    }

    // 1~2장 선택: 기존 멜드에 붙이기 시도 (플레이어 + 컴퓨터 멜드)
    if (selectedCardIndices.length < 3) {
      // 각 카드에 대해 붙이기 가능 여부 확인
      bool attached = false;
      for (final card in selectedCards) {
        // 1. 플레이어 멜드에 붙이기 시도
        final playerMeldIndex = _canAttachToMeld(card);
        if (playerMeldIndex >= 0) {
          _attachToMeld(playerMeldIndex, card);
          playerHand.remove(card);
          attached = true;
          continue;
        }

        // 2. 컴퓨터 멜드에 붙이기 시도
        for (int c = 0; c < computerMelds.length; c++) {
          final compMeldIndex = _canAttachToMeldList(card, computerMelds[c]);
          if (compMeldIndex >= 0) {
            _attachToMeldList(compMeldIndex, card, computerMelds[c]);
            playerHand.remove(card);
            attached = true;
            break;
          }
        }
      }

      if (attached) {
        setState(() {
          selectedCardIndices = [];
        });
        _showMessage(l10n.addedToMeld);
        _saveGame();

        if (playerHand.isEmpty) {
          _playerWins();
        }
        return;
      }

      _showMessage(l10n.noMeldToAttach);
      return;
    }

    // 3장 이상: 새 멜드 등록
    if (!_isValidMeld(selectedCards)) {
      _showMessage(l10n.invalidCombination);
      return;
    }

    final isRun = _isValidRun(selectedCards);

    // 카드 제거 (역순으로)
    for (int i = selectedCardIndices.length - 1; i >= 0; i--) {
      playerHand.removeAt(selectedCardIndices[i]);
    }

    playerMelds.add(Meld(cards: selectedCards, isRun: isRun));

    setState(() {
      selectedCardIndices = [];
    });

    _showMessage(isRun ? 'Run' : 'Group');
    _saveGame();

    // 손패가 비었으면 승리
    if (playerHand.isEmpty) {
      _playerWins();
    }
  }

  // 카드 버리기
  void _discardCard() {
    final l10n = AppLocalizations.of(context)!;
    if (!hasDrawn) {
      _showMessage(l10n.drawFirstMessage);
      return;
    }
    if (selectedCardIndices.length != 1) {
      _showMessage(l10n.selectCardToDiscard);
      return;
    }

    final cardIndex = selectedCardIndices.first;
    final card = playerHand.removeAt(cardIndex);
    discardPile.add(card);

    setState(() {
      selectedCardIndices = [];
      hasDrawn = false;
    });

    _showMessage(AppLocalizations.of(context)!.playerDiscards('${card.suitSymbol}${card.rankString}'));
    _saveGame();

    // 손패가 비었으면 승리
    if (playerHand.isEmpty) {
      _playerWins();
      return;
    }

    // 땡큐 확인: 플레이어 전 순서 컴퓨터는 즉시, 후 순서는 10초 후
    _lastDiscardTurn = 0;
    Timer(const Duration(milliseconds: 300), () {
      if (mounted && !gameOver) {
        // 1. 플레이어 전 순서 컴퓨터 땡큐 확인 (즉시)
        final beforeResult = _checkComputerThankYouBeforePlayer(0);
        if (beforeResult != null) {
          _executeComputerThankYou(beforeResult);
        } else {
          // 2. 플레이어 후 순서 컴퓨터가 있으면 10초 대기
          _startThankYouWait();
        }
      }
    });
  }

  // 땡큐 대기 시작 (플레이어에게 기회 부여)
  void _startThankYouWait() {
    setState(() {
      currentTurn = (currentTurn + 1) % playerCount;
      hasDrawn = false;
      selectedCardIndices = [];
      waitingForNextTurn = currentTurn == 0; // 플레이어 턴일 때만 대기 상태
    });
    _saveGame();

    if (currentTurn != 0) {
      // 컴퓨터 턴: 타이머 없이 바로 진행 (드로우 후 타이머가 동작함)
      Timer(const Duration(milliseconds: 300), () {
        if (mounted && !gameOver) {
          _onNextTurn();
        }
      });
    } else {
      // 플레이어 턴: 메시지 타이머만 취소 (메시지 유지)
      _messageTimer?.cancel();
    }
  }

  void _playerWins() {
    // 등록 없이 한 번에 다 냈으면 훌라
    isHula = playerMelds.isEmpty && playerHand.isEmpty;
    _endGame(0);
  }

  void _endTurn() {
    if (gameOver) return;

    setState(() {
      currentTurn = (currentTurn + 1) % playerCount;
      hasDrawn = false;
      selectedCardIndices = [];
      waitingForNextTurn = currentTurn == 0; // 플레이어 턴일 때만 대기 상태
    });
    _saveGame();

    if (currentTurn != 0) {
      // 컴퓨터 턴: 타이머 없이 바로 진행 (드로우 후 타이머가 동작함)
      Timer(const Duration(milliseconds: 300), () {
        if (mounted && !gameOver) {
          _computerTurn();
        }
      });
    } else {
      // 플레이어 턴: 타이머 없이 대기 (동작할 때까지 유지)
      _messageTimer?.cancel();
    }
  }

  void _computerTurn() {
    if (gameOver) return;
    _computerActionTimer?.cancel();

    final computerIndex = currentTurn - 1;
    final hand = computerHands[computerIndex];
    final melds = computerMelds[computerIndex];
    final aiNames = _getAiNames(context);
    final l10n = AppLocalizations.of(context)!;

    // 난이도에 따른 땡큐(드로우) 확률 (쉬움: 50%, 보통: 80%, 어려움: 100%)
    final difficulty = computerDifficulties.length > computerIndex
        ? computerDifficulties[computerIndex]
        : 2;
    final drawDiscardChance = difficulty == 0 ? 50 : (difficulty == 1 ? 80 : 100);

    // 1. 드로우 (버린 더미 or 덱)
    PlayingCard drawnCard;
    final topDiscard = discardPile.isNotEmpty ? discardPile.last : null;

    // 버린 카드가 멜드에 도움이 되면 가져오기 (난이도 적용)
    bool takeDiscard = false;
    if (topDiscard != null && Random().nextInt(100) < drawDiscardChance) {
      // 7 카드는 단독 등록 가능하므로 항상 가져오기
      if (_isSeven(topDiscard)) {
        takeDiscard = true;
      } else {
        final testHand = [...hand, topDiscard];
        if (_findBestMeld(testHand) != null) {
          takeDiscard = true;
        }
      }
    }

    if (takeDiscard && discardPile.isNotEmpty) {
      drawnCard = discardPile.removeLast();
      _showMessage(l10n.aiThankYouDraw(aiNames[computerIndex], '${drawnCard.suitSymbol}${drawnCard.rankString}'));
    } else {
      if (deck.isEmpty && discardPile.length > 1) {
        final topCard = discardPile.removeLast();
        deck = List.from(discardPile);
        deck.shuffle(Random());
        discardPile = [topCard];
      }
      if (deck.isEmpty) {
        _endTurn();
        return;
      }
      drawnCard = deck.removeLast();
      _showMessage(l10n.aiDrawsCard(aiNames[computerIndex]));
    }

    hand.add(drawnCard);
    _sortHand(hand);
    setState(() {});
    _saveGame();

    // 드로우 후 대기 상태로 전환 (1초 타이머)
    _startWaitWithAction(() => _computerTurnRegister(computerIndex), seconds: 1);
  }

  // 컴퓨터 턴 - 멜드 등록 단계
  void _computerTurnRegister(int computerIndex) {
    if (gameOver) return;

    final hand = computerHands[computerIndex];
    final melds = computerMelds[computerIndex];

    // 훌라 가능성 확인 후 등록 여부 결정 (스톱 위험도 포함)
    final shouldRegister = _shouldRegisterMelds(hand, melds, computerIndex: computerIndex + 1);

    if (!shouldRegister) {
      _computerTurnDiscard(computerIndex);
      return;
    }

    // 등록할 멜드 수집
    final meldsToRegister = <Map<String, dynamic>>[];

    // 일반 멜드 찾기
    final testHand = List<PlayingCard>.from(hand);
    List<PlayingCard>? bestMeld;
    while ((bestMeld = _findBestMeld(testHand)) != null) {
      final isRun = _isValidRun(bestMeld!);
      meldsToRegister.add({'cards': List<PlayingCard>.from(bestMeld), 'isRun': isRun, 'type': 'meld'});
      for (final card in bestMeld) {
        testHand.remove(card);
      }
    }

    // 7 카드 찾기
    final sevens = testHand.where((c) => _isSeven(c)).toList();
    if (sevens.length >= 3) {
      final decision = _decideSevensStrategy(sevens, testHand);
      if (decision == 'group') {
        meldsToRegister.add({'cards': sevens.take(3).toList(), 'isRun': false, 'type': '7group'});
        for (final seven in sevens.skip(3)) {
          meldsToRegister.add({'cards': [seven], 'isRun': false, 'type': '7'});
        }
      } else {
        for (final seven in sevens) {
          meldsToRegister.add({'cards': [seven], 'isRun': false, 'type': '7'});
        }
      }
    } else {
      for (final seven in sevens) {
        meldsToRegister.add({'cards': [seven], 'isRun': false, 'type': '7'});
      }
    }

    // 순차적으로 등록 실행
    _computerRegisterMeldsSequentially(computerIndex, meldsToRegister, 0);
  }

  // 멜드를 순차적으로 등록 (대기 상태 포함)
  void _computerRegisterMeldsSequentially(int computerIndex, List<Map<String, dynamic>> meldsToRegister, int index) {
    if (gameOver) return;
    if (index >= meldsToRegister.length) {
      // 모든 등록 완료, 붙여놓기 단계로 (타이머 없이 바로 진행)
      _computerTurnAttach(computerIndex);
      return;
    }

    final aiNames = _getAiNames(context);
    final l10n = AppLocalizations.of(context)!;
    final hand = computerHands[computerIndex];
    final melds = computerMelds[computerIndex];
    final meldData = meldsToRegister[index];
    final cards = meldData['cards'] as List<PlayingCard>;
    final isRun = meldData['isRun'] as bool;
    final type = meldData['type'] as String;

    // 카드가 손에 있는지 확인
    bool allCardsInHand = cards.every((c) => hand.contains(c));
    if (!allCardsInHand) {
      // 이미 처리된 카드, 다음으로
      _computerRegisterMeldsSequentially(computerIndex, meldsToRegister, index + 1);
      return;
    }

    // 멜드 등록
    for (final card in cards) {
      hand.remove(card);
    }
    melds.add(Meld(cards: cards, isRun: isRun));

    // 메시지 표시
    if (type == '7group') {
      _showMessage(l10n.aiRegistersSeven(aiNames[computerIndex], l10n.group));
    } else if (type == '7') {
      _showMessage(l10n.aiRegistersSeven(aiNames[computerIndex], l10n.solo));
    } else {
      final cardStr = cards.map((c) => '${c.suitSymbol}${c.rankString}').join(' ');
      _showMessage(l10n.aiRegistersMeld(aiNames[computerIndex], isRun ? 'Run' : 'Group', cardStr));
    }

    setState(() {});
    _saveGame();

    if (hand.isEmpty) {
      _endGame(currentTurn);
      return;
    }

    // 등록 후 대기 상태로 전환 (다음 등록 또는 붙여놓기 단계)
    _startWaitWithAction(() => _computerRegisterMeldsSequentially(computerIndex, meldsToRegister, index + 1));
  }

  // 컴퓨터 턴 - 붙여놓기 단계
  void _computerTurnAttach(int computerIndex) {
    if (gameOver) return;

    final aiNames = _getAiNames(context);
    final l10n = AppLocalizations.of(context)!;
    final hand = computerHands[computerIndex];
    final melds = computerMelds[computerIndex];

    // 자신의 멜드가 없으면 붙여놓기 불가 (훌라 규칙)
    if (melds.isEmpty) {
      _computerTurnDiscard(computerIndex);
      return;
    }

    // 난이도에 따른 붙여놓기 확률 (쉬움: 50%, 보통: 80%, 어려움: 100%)
    final difficulty = computerDifficulties.length > computerIndex
        ? computerDifficulties[computerIndex]
        : 2;
    final attachChance = difficulty == 0 ? 50 : (difficulty == 1 ? 80 : 100);

    // 붙일 수 있는 카드 찾기
    for (int i = hand.length - 1; i >= 0; i--) {
      final card = hand[i];

      // 자신의 멜드에 붙이기
      final ownMeldIndex = _canAttachToMeldList(card, melds);
      if (ownMeldIndex >= 0 && Random().nextInt(100) < attachChance) {
        _attachToMeldList(ownMeldIndex, card, melds);
        hand.removeAt(i);
        _showMessage(l10n.aiAttachesToMeld(aiNames[computerIndex], '${card.suitSymbol}${card.rankString}'));
        setState(() {});
        _saveGame();

        if (hand.isEmpty) {
          _endGame(currentTurn);
          return;
        }

        // 붙이기 후 대기 상태로 전환
        _startWaitWithAction(() => _computerTurnAttach(computerIndex));
        return;
      }

      // 플레이어 멜드에 붙이기
      final playerMeldIndex = _canAttachToMeldList(card, playerMelds);
      if (playerMeldIndex >= 0 && Random().nextInt(100) < attachChance) {
        _attachToMeldList(playerMeldIndex, card, playerMelds);
        hand.removeAt(i);
        _showMessage(l10n.aiAttachesToPlayerMeld(aiNames[computerIndex], '${card.suitSymbol}${card.rankString}'));
        setState(() {});
        _saveGame();

        if (hand.isEmpty) {
          _endGame(currentTurn);
          return;
        }

        // 붙이기 후 대기 상태로 전환
        _startWaitWithAction(() => _computerTurnAttach(computerIndex));
        return;
      }

      // 다른 컴퓨터 멜드에 붙이기
      for (int c = 0; c < computerMelds.length; c++) {
        if (c == computerIndex) continue;
        final otherMeldIndex = _canAttachToMeldList(card, computerMelds[c]);
        if (otherMeldIndex >= 0 && Random().nextInt(100) < attachChance) {
          _attachToMeldList(otherMeldIndex, card, computerMelds[c]);
          hand.removeAt(i);
          _showMessage(l10n.aiAttachesToOtherAiMeld(aiNames[computerIndex], '${card.suitSymbol}${card.rankString}', aiNames[c]));
          setState(() {});
          _saveGame();

          if (hand.isEmpty) {
            _endGame(currentTurn);
            return;
          }

          // 붙이기 후 대기 상태로 전환
          _startWaitWithAction(() => _computerTurnAttach(computerIndex));
          return;
        }
      }
    }

    // 붙일 카드 없음, 버리기 단계로
    _computerTurnDiscard(computerIndex);
  }

  // 컴퓨터 턴 - 버리기 단계
  void _computerTurnDiscard(int computerIndex) {
    if (gameOver) return;

    final aiNames = _getAiNames(context);
    final l10n = AppLocalizations.of(context)!;
    final hand = computerHands[computerIndex];
    final melds = computerMelds[computerIndex];

    // 손에 7이 있으면 먼저 등록
    final sevens = hand.where((c) => _isSeven(c)).toList();
    if (sevens.isNotEmpty) {
      final seven = sevens.first;
      hand.remove(seven);
      melds.add(Meld(cards: [seven], isRun: false));
      _showMessage(l10n.aiRegistersSeven(aiNames[computerIndex], l10n.solo));
      setState(() {});
      _saveGame();

      if (hand.isEmpty) {
        _endGame(currentTurn);
        return;
      }

      // 딜레이 후 다시 버리기 단계
      _computerActionTimer = Timer(Duration(milliseconds: _computerActionDelay), () {
        if (mounted && !gameOver) {
          _computerTurnDiscard(computerIndex);
        }
      });
      return;
    }

    // 스마트 카드 버리기 (난이도 적용)
    final discardCard = _selectCardToDiscard(hand, computerIndex: computerIndex);
    hand.remove(discardCard);
    discardPile.add(discardCard);
    _sortHand(hand);

    _showMessage(l10n.aiDiscards(aiNames[computerIndex], '${discardCard.suitSymbol}${discardCard.rankString}'));
    setState(() {});
    _saveGame();

    if (hand.isEmpty) {
      _endGame(currentTurn);
      return;
    }

    // 스톱 호출 여부 확인
    if (_shouldComputerCallStop(computerIndex)) {
      _computerCallStop(computerIndex);
      return;
    }

    // 땡큐 확인: 플레이어 전 순서 컴퓨터는 즉시, 후 순서는 10초 후
    _lastDiscardTurn = currentTurn;
    _computerActionTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted && !gameOver) {
        // 1. 플레이어 전 순서 컴퓨터 땡큐 확인 (즉시)
        final beforeResult = _checkComputerThankYouBeforePlayer(currentTurn);
        if (beforeResult != null) {
          _executeComputerThankYou(beforeResult);
        } else {
          // 2. 플레이어에게 10초 기회 부여 후 플레이어 후 순서 컴퓨터 확인
          _startThankYouWait();
        }
      }
    });
  }

  // 컴퓨터가 땡큐할 수 있는지 확인
  // beforePlayer: true면 플레이어 전 순서만, false면 플레이어 후 순서만
  int? _checkComputerThankYou(int fromTurn, {bool? beforePlayer}) {
    if (discardPile.isEmpty) return null;
    final topCard = discardPile.last;
    final random = Random();

    // fromTurn 다음 순서부터 확인
    bool passedPlayer = false;
    for (int i = 1; i < playerCount; i++) {
      final checkTurn = (fromTurn + i) % playerCount;

      if (checkTurn == 0) {
        passedPlayer = true;
        continue; // 플레이어는 건너뜀 (플레이어는 버튼으로 땡큐)
      }

      // beforePlayer 필터링
      if (beforePlayer == true && passedPlayer) continue; // 플레이어 전만 확인
      if (beforePlayer == false && !passedPlayer) continue; // 플레이어 후만 확인

      final computerIndex = checkTurn - 1;
      if (computerIndex < 0 || computerIndex >= computerHands.length) continue;
      final hand = computerHands[computerIndex];

      // 난이도에 따른 땡큐 확률 (쉬움: 50%, 보통: 80%, 어려움: 100%)
      final difficulty = computerDifficulties.length > computerIndex
          ? computerDifficulties[computerIndex]
          : 2;
      final thankYouChance = difficulty == 0 ? 50 : (difficulty == 1 ? 80 : 100);

      bool shouldThankYou = false;

      // 7 카드는 항상 땡큐 (난이도 적용)
      if (_isSeven(topCard)) {
        shouldThankYou = true;
      } else {
        // 멜드를 만들 수 있으면 땡큐
        final testHand = [...hand, topCard];
        if (_findBestMeld(testHand) != null) {
          shouldThankYou = true;
        }
      }

      if (shouldThankYou) {
        // 난이도에 따른 확률 체크
        if (random.nextInt(100) < thankYouChance) {
          return computerIndex;
        }
      }
    }
    return null;
  }

  // 플레이어 전 순서 컴퓨터만 땡큐 확인 (즉시 실행)
  int? _checkComputerThankYouBeforePlayer(int fromTurn) {
    return _checkComputerThankYou(fromTurn, beforePlayer: true);
  }

  // 플레이어 후 순서 컴퓨터만 땡큐 확인 (10초 후 실행)
  int? _checkComputerThankYouAfterPlayer(int fromTurn) {
    return _checkComputerThankYou(fromTurn, beforePlayer: false);
  }

  // 컴퓨터 땡큐 실행
  void _executeComputerThankYou(int computerIndex) {
    if (discardPile.isEmpty) return;
    _computerActionTimer?.cancel();

    final aiNames = _getAiNames(context);
    final l10n = AppLocalizations.of(context)!;

    // 땡큐한 컴퓨터의 턴으로 설정
    currentTurn = computerIndex + 1;

    final card = discardPile.removeLast();
    final hand = computerHands[computerIndex];

    hand.add(card);
    _sortHand(hand);
    _showMessage(l10n.aiThankYouDraw(aiNames[computerIndex], '${card.suitSymbol}${card.rankString}'));
    setState(() {});
    _saveGame();

    // 땡큐 후 바로 등록 단계로 진행 (등록 후 타이머가 동작함)
    Timer(const Duration(milliseconds: 300), () {
      if (mounted && !gameOver) {
        _executeComputerThankYouRegister(computerIndex);
      }
    });
  }

  // 컴퓨터 땡큐 후 - 멜드 등록 단계
  void _executeComputerThankYouRegister(int computerIndex) {
    if (gameOver) return;

    final hand = computerHands[computerIndex];
    final melds = computerMelds[computerIndex];

    // 훌라 가능성 확인 후 등록 여부 결정 (스톱 위험도 포함)
    final shouldRegister = _shouldRegisterMelds(hand, melds, computerIndex: computerIndex + 1);

    if (!shouldRegister) {
      _computerDiscardAfterThankYou(computerIndex);
      return;
    }

    // 등록할 멜드 수집
    final meldsToRegister = <Map<String, dynamic>>[];

    // 일반 멜드 찾기
    final testHand = List<PlayingCard>.from(hand);
    List<PlayingCard>? bestMeld;
    while ((bestMeld = _findBestMeld(testHand)) != null) {
      final isRun = _isValidRun(bestMeld!);
      meldsToRegister.add({'cards': List<PlayingCard>.from(bestMeld), 'isRun': isRun, 'type': 'meld'});
      for (final card in bestMeld) {
        testHand.remove(card);
      }
    }

    // 7 카드 찾기
    final sevens = testHand.where((c) => _isSeven(c)).toList();
    if (sevens.length >= 3) {
      final decision = _decideSevensStrategy(sevens, testHand);
      if (decision == 'group') {
        meldsToRegister.add({'cards': sevens.take(3).toList(), 'isRun': false, 'type': '7group'});
        for (final seven in sevens.skip(3)) {
          meldsToRegister.add({'cards': [seven], 'isRun': false, 'type': '7'});
        }
      } else {
        for (final seven in sevens) {
          meldsToRegister.add({'cards': [seven], 'isRun': false, 'type': '7'});
        }
      }
    } else {
      for (final seven in sevens) {
        meldsToRegister.add({'cards': [seven], 'isRun': false, 'type': '7'});
      }
    }

    // 순차적으로 등록 실행
    _executeComputerThankYouRegisterSequentially(computerIndex, meldsToRegister, 0);
  }

  // 땡큐 후 멜드를 순차적으로 등록 (대기 상태 포함)
  void _executeComputerThankYouRegisterSequentially(int computerIndex, List<Map<String, dynamic>> meldsToRegister, int index) {
    if (gameOver) return;
    if (index >= meldsToRegister.length) {
      // 모든 등록 완료, 붙여놓기 단계로 (타이머 없이 바로 진행)
      _executeComputerThankYouAttach(computerIndex);
      return;
    }

    final aiNames = _getAiNames(context);
    final l10n = AppLocalizations.of(context)!;
    final hand = computerHands[computerIndex];
    final melds = computerMelds[computerIndex];
    final meldData = meldsToRegister[index];
    final cards = meldData['cards'] as List<PlayingCard>;
    final isRun = meldData['isRun'] as bool;
    final type = meldData['type'] as String;

    // 카드가 손에 있는지 확인
    bool allCardsInHand = cards.every((c) => hand.contains(c));
    if (!allCardsInHand) {
      // 이미 처리된 카드, 다음으로
      _executeComputerThankYouRegisterSequentially(computerIndex, meldsToRegister, index + 1);
      return;
    }

    // 멜드 등록
    for (final card in cards) {
      hand.remove(card);
    }
    melds.add(Meld(cards: cards, isRun: isRun));

    // 메시지 표시
    if (type == '7group') {
      _showMessage(l10n.aiRegistersSeven(aiNames[computerIndex], l10n.group));
    } else if (type == '7') {
      _showMessage(l10n.aiRegistersSeven(aiNames[computerIndex], l10n.solo));
    } else {
      final cardStr = cards.map((c) => '${c.suitSymbol}${c.rankString}').join(' ');
      _showMessage(l10n.aiRegistersMeld(aiNames[computerIndex], isRun ? 'Run' : 'Group', cardStr));
    }

    setState(() {});
    _saveGame();

    if (hand.isEmpty) {
      _endGame(computerIndex + 1);
      return;
    }

    // 등록 후 대기 상태로 전환
    _startWaitWithAction(() => _executeComputerThankYouRegisterSequentially(computerIndex, meldsToRegister, index + 1));
  }

  // 컴퓨터 땡큐 후 - 붙여놓기 단계
  void _executeComputerThankYouAttach(int computerIndex) {
    if (gameOver) return;

    final aiNames = _getAiNames(context);
    final l10n = AppLocalizations.of(context)!;
    final hand = computerHands[computerIndex];
    final melds = computerMelds[computerIndex];

    // 자신의 멜드가 없으면 붙여놓기 불가 (훌라 규칙)
    if (melds.isEmpty) {
      _computerDiscardAfterThankYou(computerIndex);
      return;
    }

    // 난이도에 따른 붙여놓기 확률 (쉬움: 50%, 보통: 80%, 어려움: 100%)
    final difficulty = computerDifficulties.length > computerIndex
        ? computerDifficulties[computerIndex]
        : 2;
    final attachChance = difficulty == 0 ? 50 : (difficulty == 1 ? 80 : 100);

    // 붙일 수 있는 카드 찾기
    for (int i = hand.length - 1; i >= 0; i--) {
      final card = hand[i];

      // 자신의 멜드에 붙이기
      final ownMeldIndex = _canAttachToMeldList(card, melds);
      if (ownMeldIndex >= 0 && Random().nextInt(100) < attachChance) {
        _attachToMeldList(ownMeldIndex, card, melds);
        hand.removeAt(i);
        _showMessage(l10n.aiAttachesToMeld(aiNames[computerIndex], '${card.suitSymbol}${card.rankString}'));
        setState(() {});
        _saveGame();

        if (hand.isEmpty) {
          _endGame(computerIndex + 1);
          return;
        }

        // 붙이기 후 대기 상태로 전환
        _startWaitWithAction(() => _executeComputerThankYouAttach(computerIndex));
        return;
      }

      // 플레이어 멜드에 붙이기
      final playerMeldIndex = _canAttachToMeldList(card, playerMelds);
      if (playerMeldIndex >= 0 && Random().nextInt(100) < attachChance) {
        _attachToMeldList(playerMeldIndex, card, playerMelds);
        hand.removeAt(i);
        _showMessage(l10n.aiAttachesToPlayerMeld(aiNames[computerIndex], '${card.suitSymbol}${card.rankString}'));
        setState(() {});
        _saveGame();

        if (hand.isEmpty) {
          _endGame(computerIndex + 1);
          return;
        }

        // 붙이기 후 대기 상태로 전환
        _startWaitWithAction(() => _executeComputerThankYouAttach(computerIndex));
        return;
      }

      // 다른 컴퓨터 멜드에 붙이기
      for (int c = 0; c < computerMelds.length; c++) {
        if (c == computerIndex) continue;
        final otherMeldIndex = _canAttachToMeldList(card, computerMelds[c]);
        if (otherMeldIndex >= 0 && Random().nextInt(100) < attachChance) {
          _attachToMeldList(otherMeldIndex, card, computerMelds[c]);
          hand.removeAt(i);
          _showMessage(l10n.aiAttachesToOtherAiMeld(aiNames[computerIndex], '${card.suitSymbol}${card.rankString}', aiNames[c]));
          setState(() {});
          _saveGame();

          if (hand.isEmpty) {
            _endGame(computerIndex + 1);
            return;
          }

          // 붙이기 후 대기 상태로 전환
          _startWaitWithAction(() => _executeComputerThankYouAttach(computerIndex));
          return;
        }
      }
    }

    // 붙일 카드 없음, 버리기 단계로
    _computerDiscardAfterThankYou(computerIndex);
  }

  // 땡큐 후 컴퓨터가 카드 버리기
  void _computerDiscardAfterThankYou(int computerIndex) {
    final aiNames = _getAiNames(context);
    final l10n = AppLocalizations.of(context)!;
    final hand = computerHands[computerIndex];
    final melds = computerMelds[computerIndex];

    // 손에 7이 있으면 먼저 등록
    final sevens = hand.where((c) => _isSeven(c)).toList();
    if (sevens.isNotEmpty) {
      final seven = sevens.first;
      hand.remove(seven);
      melds.add(Meld(cards: [seven], isRun: false));
      _showMessage(l10n.aiRegistersSeven(aiNames[computerIndex], l10n.solo));
      setState(() {});
      _saveGame();

      if (hand.isEmpty) {
        _endGame(computerIndex + 1);
        return;
      }

      // 딜레이 후 다시 버리기 단계
      _computerActionTimer = Timer(Duration(milliseconds: _computerActionDelay), () {
        if (mounted && !gameOver) {
          _computerDiscardAfterThankYou(computerIndex);
        }
      });
      return;
    }

    // 스마트 카드 버리기 (난이도 적용)
    final discardCard = _selectCardToDiscard(hand, computerIndex: computerIndex);
    hand.remove(discardCard);
    discardPile.add(discardCard);
    _sortHand(hand);

    _showMessage(l10n.aiDiscards(aiNames[computerIndex], '${discardCard.suitSymbol}${discardCard.rankString}'));
    setState(() {});
    _saveGame();

    if (hand.isEmpty) {
      _endGame(computerIndex + 1);
      return;
    }

    // 스톱 호출 여부 확인
    if (_shouldComputerCallStop(computerIndex)) {
      _computerCallStop(computerIndex);
      return;
    }

    // 땡큐 확인: 플레이어 전 순서 컴퓨터는 즉시, 후 순서는 10초 후
    final discardTurn = computerIndex + 1;
    _lastDiscardTurn = discardTurn;
    Timer(const Duration(milliseconds: 500), () {
      if (mounted && !gameOver) {
        // 1. 플레이어 전 순서 컴퓨터 땡큐 확인 (즉시)
        final beforeResult = _checkComputerThankYouBeforePlayer(discardTurn);
        if (beforeResult != null) {
          _executeComputerThankYou(beforeResult);
        } else {
          // 2. 플레이어에게 10초 기회 부여 후 플레이어 후 순서 컴퓨터 확인
          _startThankYouWait();
        }
      }
    });
  }

  List<PlayingCard>? _findBestMeld(List<PlayingCard> hand) {
    if (hand.length < 3) return null;

    // Group 찾기
    final rankGroups = <int, List<PlayingCard>>{};
    for (final card in hand) {
      rankGroups.putIfAbsent(card.rank, () => []).add(card);
    }
    for (final group in rankGroups.values) {
      if (group.length >= 3) {
        return group.take(3).toList();
      }
    }

    // Run 찾기
    final suitGroups = <Suit, List<PlayingCard>>{};
    for (final card in hand) {
      suitGroups.putIfAbsent(card.suit, () => []).add(card);
    }
    for (final cards in suitGroups.values) {
      if (cards.length >= 3) {
        cards.sort((a, b) => a.rank.compareTo(b.rank));
        for (int i = 0; i <= cards.length - 3; i++) {
          final run = <PlayingCard>[cards[i]];
          for (int j = i + 1; j < cards.length && run.length < 3; j++) {
            if (cards[j].rank == run.last.rank + 1) {
              run.add(cards[j]);
            }
          }
          if (run.length >= 3) {
            return run;
          }
        }
      }
    }

    return null;
  }

  // 스톱 선언 (플레이어)
  void _callStop() {
    if (gameOver) return;
    _calculateScoresAndEnd(stopperIndex: 0); // 플레이어가 스톱
  }

  void _calculateScoresAndEnd({required int stopperIndex}) {
    // 모든 플레이어 점수 계산 (등록하지 못한 플레이어는 2배 패널티)
    final playerRegistered = playerMelds.isNotEmpty;
    scores[0] = _calculateHandScore(playerHand) * (playerRegistered ? 1 : 2);
    for (int i = 0; i < computerHands.length; i++) {
      final computerRegistered = computerMelds[i].isNotEmpty;
      scores[i + 1] = _calculateHandScore(computerHands[i]) * (computerRegistered ? 1 : 2);
    }

    // 최저 점수 찾기
    int minScore = scores[0];
    List<int> minIndices = [0]; // 최저 점수를 가진 모든 플레이어 인덱스

    for (int i = 1; i < scores.length; i++) {
      if (scores[i] < minScore) {
        minScore = scores[i];
        minIndices = [i];
      } else if (scores[i] == minScore) {
        minIndices.add(i);
      }
    }

    int winnerIdx;
    // 동점자가 여러 명인 경우
    if (minIndices.length > 1) {
      // 스톱한 사람이 동점자에 포함되어 있으면 스톱한 사람은 패배
      if (minIndices.contains(stopperIndex)) {
        // 스톱한 사람을 제외한 동점자 중 첫 번째가 승리
        minIndices.remove(stopperIndex);
        winnerIdx = minIndices.first;
      } else {
        // 스톱한 사람이 동점자가 아니면 첫 번째 동점자가 승리
        winnerIdx = minIndices.first;
      }
    } else {
      // 단독 최저 점수면 그 사람이 승리
      winnerIdx = minIndices.first;
    }

    // 스톱 실패 여부 확인 후 게임 종료
    final stopFailed = stopperIndex != winnerIdx;
    _endGame(winnerIdx, stopperIndex: stopFailed ? stopperIndex : null);
  }

  int _calculateHandScore(List<PlayingCard> hand) {
    return hand.fold(0, (sum, card) => sum + card.point);
  }

  // stopperIndex: 스톱 실패한 플레이어 인덱스 (null이면 일반 종료)
  void _endGame(int winnerIdx, {int? stopperIndex}) {
    // 손패 점수 계산 (등록하지 못한 플레이어는 2배 패널티)
    final playerRegistered = playerMelds.isNotEmpty;
    scores[0] = _calculateHandScore(playerHand) * (playerRegistered ? 1 : 2);
    for (int i = 0; i < computerHands.length; i++) {
      final computerRegistered = computerMelds[i].isNotEmpty;
      scores[i + 1] = _calculateHandScore(computerHands[i]) * (computerRegistered ? 1 : 2);
    }

    // 라운드 점수 계산
    final multiplier = (isHula && winnerIdx == 0) ? 2 : 1;
    final winnerHandScore = scores[winnerIdx];
    int winnerGain = 0;

    roundScores = List.generate(playerCount, (_) => 0);

    // 승자가 얻을 총 점수 계산 (모든 플레이어와의 차이 합)
    for (int i = 0; i < playerCount; i++) {
      if (i == winnerIdx) continue;
      final diff = (scores[i] - winnerHandScore) * multiplier;
      winnerGain += diff;
    }

    if (stopperIndex != null) {
      // 스톱 실패: 승자가 얻은 점수를 스톱한 플레이어가 모두 부담
      // 다른 플레이어는 감점 없음
      roundScores[winnerIdx] = winnerGain;
      roundScores[stopperIndex] = -winnerGain;
      // 나머지 플레이어는 0 (이미 초기화됨)
    } else {
      // 일반 종료: 각자 승자와의 차이만큼 감점
      for (int i = 0; i < playerCount; i++) {
        if (i == winnerIdx) continue;
        final diff = (scores[i] - winnerHandScore) * multiplier;
        roundScores[i] = -diff;
      }
      roundScores[winnerIdx] = winnerGain;
    }

    final l10n = AppLocalizations.of(context)!;
    setState(() {
      gameOver = true;
      winnerIndex = winnerIdx;
      if (winnerIdx == 0) {
        winner = l10n.player;
      } else {
        final aiNames = _getAiNames(context);
        winner = aiNames[winnerIdx - 1];
      }
    });

    // 통계 저장 (스톱 실패 시 특별 처리)
    final statsService = Provider.of<HulaStatsService>(context, listen: false);
    statsService.recordGameResultWithRoundScores(
      winnerId: winnerIdx,
      roundScores: roundScores,
    );

    // 게임 종료 시 저장된 게임 삭제
    _saveGame();

    _showGameOverDialog();
  }

  void _showGameOverDialog() {
    final l10n = AppLocalizations.of(context)!;
    final statsService = Provider.of<HulaStatsService>(context, listen: false);
    final aiNames = _getAiNames(context);
    final playerNames = [l10n.player, ...aiNames];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: winnerIndex == 0 ? Colors.amber : Colors.red.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        title: Column(
          children: [
            Text(
              winnerIndex == 0 ? l10n.victory : l10n.defeat,
              style: TextStyle(
                color: winnerIndex == 0 ? Colors.amber : Colors.red,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            if (isHula && winnerIndex == 0)
              Text(
                l10n.hulaWinBonus,
                style: const TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.playerNameWins(winner ?? ''),
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 16),
            // 점수 테이블 헤더
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  const Expanded(flex: 2, child: Text('', style: TextStyle(color: Colors.white70, fontSize: 12))),
                  Expanded(child: Text(l10n.handColumn, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                  Expanded(child: Text(l10n.scoreColumn, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                  Expanded(child: Text(l10n.cumulativeColumn, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70, fontSize: 12))),
                ],
              ),
            ),
            const SizedBox(height: 4),
            // 각 플레이어 점수
            ...List.generate(
              playerCount,
              (i) {
                final isWinner = winnerIndex == i;
                final stats = statsService.getPlayerStats(i);
                final roundScore = roundScores[i];
                final roundScoreStr = roundScore >= 0 ? '+$roundScore' : '$roundScore';
                final totalScore = stats?.totalScore ?? 0;
                final totalScoreStr = totalScore >= 0 ? '+$totalScore' : '$totalScore';

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white12)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            if (isWinner)
                              const Icon(Icons.emoji_events, color: Colors.amber, size: 16),
                            if (isWinner) const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                playerNames[i],
                                style: TextStyle(
                                  color: isWinner ? Colors.amber : Colors.white,
                                  fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${scores[i]}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          roundScoreStr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: roundScore >= 0 ? Colors.lightGreenAccent : Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          totalScoreStr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: totalScore >= 0 ? Colors.lightGreenAccent : Colors.redAccent,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _initGame();
            },
            child: Text(l10n.newGame),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context);
            },
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFF0D5C2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(l10n.hulaWithPlayers(playerCount),
            style: const TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.lightbulb, color: _showHint ? Colors.yellow : Colors.white),
            tooltip: _showHint ? l10n.hintOnOff('OFF') : l10n.hint,
            onPressed: _onHintButtonPressed,
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _showNewGameDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: _buildGameContent(),
      ),
    );
  }

  Widget _buildGameContent() {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final screenWidth = mediaQuery.size.width;
    final sizes = _HulaResponsiveSizes(screenHeight, screenWidth);

    return Column(
      children: [
        // 상단 컴퓨터: 2인은 COM1, 3인은 COM2, 4인은 COM2
        if (computerHands.isNotEmpty)
          _buildTopComputerHand(computerHands.length == 1 ? 0 : 1, sizes),

        // 중앙 영역 (좌우 컴퓨터 + 덱/버린더미)
        Expanded(
          child: computerHands.length >= 2
              ? Row(
                  children: [
                    // 왼쪽 컴퓨터 (COM3) - 4인 게임만
                    if (computerHands.length >= 3)
                      _buildSideComputerHand(2, sizes),
                    // 중앙 카드 영역
                    Expanded(child: _buildCenterArea(sizes)),
                    // 오른쪽 컴퓨터 (COM1) - 3인 이상
                    _buildSideComputerHand(0, sizes),
                  ],
                )
              : _buildCenterArea(sizes),
        ),

        // 하단 영역 (메시지, 멜드, 손패, 버튼)
        _buildBottomSection(sizes),
      ],
    );
  }

  // 하단 영역 (스크롤 가능)
  Widget _buildBottomSection(_HulaResponsiveSizes sizes) {
    final l10n = AppLocalizations.of(context)!;
    final aiNames = _getAiNames(context);
    return Flexible(
      flex: 0,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 현재 차례 표시 + 메시지 (위아래로 표시)
            if (!gameOver)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 상단: 현재 순서 표시 + 시작 버튼
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
                                : (waitingForNextTurn ? l10n.aiTurnCountdown(aiNames[currentTurn - 1], _autoPlayCountdown) : l10n.aiTurn(aiNames[currentTurn - 1])),
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

            // 등록된 멜드
            if (playerMelds.isNotEmpty) _buildPlayerMelds(sizes),

            // 플레이어 손패
            _buildPlayerHand(sizes),

            // 액션 버튼
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  // 상단 컴퓨터 (가로 배치)
  Widget _buildTopComputerHand(int computerIndex, _HulaResponsiveSizes sizes) {
    if (computerIndex >= computerHands.length) return const SizedBox();

    final aiNames = _getAiNames(context);
    final hand = computerHands[computerIndex];
    final melds = computerMelds[computerIndex];
    final isCurrentTurn = currentTurn == computerIndex + 1;

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
                    if (melds.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        '(${AppLocalizations.of(context)!.meldCount(melds.length)})',
                        style: const TextStyle(color: Colors.green, fontSize: 11),
                      ),
                    ],
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
              min(hand.length, 8),
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

  // 좌/우측 컴퓨터 (세로 배치)
  Widget _buildSideComputerHand(int computerIndex, _HulaResponsiveSizes sizes) {
    if (computerIndex >= computerHands.length) return const SizedBox();

    final aiNames = _getAiNames(context);
    final hand = computerHands[computerIndex];
    final melds = computerMelds[computerIndex];
    final isCurrentTurn = currentTurn == computerIndex + 1;

    return Container(
      width: 55,
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
          if (melds.isNotEmpty)
            Text(
              AppLocalizations.of(context)!.meldCount(melds.length),
              style: const TextStyle(color: Colors.green, fontSize: 9),
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

  // 세로 카드 스택
  Widget _buildVerticalCardStack(int cardCount, _HulaResponsiveSizes sizes) {
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

  Widget _buildCenterArea(_HulaResponsiveSizes sizes) {
    final l10n = AppLocalizations.of(context)!;
    final cardWidth = sizes.centerCardWidth;
    final cardHeight = sizes.centerCardHeight;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 덱 - 내 차례이고 드로우 전이면 탭 가능 (waitingForNextTurn 상태에서도)
              GestureDetector(
                onTap: currentTurn == 0 && !hasDrawn
                    ? _drawFromDeck
                    : null,
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade700, Colors.blue.shade900],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: currentTurn == 0 && !hasDrawn
                          ? Colors.yellow
                          : Colors.white24,
                      width: currentTurn == 0 && !hasDrawn
                          ? 3
                          : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🂠', style: TextStyle(fontSize: 28)),
                      Text(
                        '${deck.length}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // 버린 더미
              Builder(
                builder: (context) {
                  // 땡큐 가능: 대기 중이거나 플레이어 턴에서 드로우 안했을 때, 그리고 등록 가능할 때만
                  final canTakeDiscard = discardPile.isNotEmpty &&
                      ((currentTurn == 0 && !hasDrawn) || waitingForNextTurn) &&
                      _canThankYou();
                  // 땡큐 상태면 주황색, 일반 드로우면 녹색
                  final borderColor =
                      waitingForNextTurn && canTakeDiscard
                          ? Colors.orange
                          : (canTakeDiscard ? Colors.green : Colors.grey);

                  return GestureDetector(
                    onTap: canTakeDiscard ? _drawFromDiscard : null,
                    child: Container(
                      width: cardWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: borderColor,
                          width: canTakeDiscard ? 3 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                      child: discardPile.isEmpty
                          ? Center(
                              child: Text(
                                l10n.emptyDiscardPile,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            )
                          : _buildCardFace(discardPile.last, small: true),
                    ),
                  );
                },
              ),
            ],
          ),
          // 모든 등록된 멜드 표시
          _buildAllMeldsArea(),
        ],
      ),
    );
  }

  Widget _buildCardFace(PlayingCard card, {bool small = false}) {
    final fontSize = small ? 14.0 : 18.0;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(small ? 6 : 8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            card.suitSymbol,
            style: TextStyle(
              fontSize: fontSize + 4,
              color: card.suitColor,
            ),
          ),
          Text(
            card.rankString,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: card.suitColor,
            ),
          ),
        ],
      ),
    );
  }

  // 모든 플레이어의 멜드를 표시 (붙여놓기 가능)
  Widget _buildAllMeldsArea() {
    // 모든 멜드 수집
    final List<Map<String, dynamic>> allMelds = [];

    // 플레이어 멜드
    for (int i = 0; i < playerMelds.length; i++) {
      allMelds.add({
        'meldIndex': i,
        'meld': playerMelds[i],
        'melds': playerMelds,
      });
    }

    // 컴퓨터 멜드
    for (int c = 0; c < computerMelds.length; c++) {
      for (int i = 0; i < computerMelds[c].length; i++) {
        allMelds.add({
          'meldIndex': i,
          'meld': computerMelds[c][i],
          'melds': computerMelds[c],
        });
      }
    }

    // 고정 높이 영역 (멜드가 없어도 공간 유지)
    const fixedHeight = 70.0;
    const cardHeight = 28.0;
    const cardWidth = 20.0;
    const overlap = 12.0;

    return Container(
      height: fixedHeight,
      margin: const EdgeInsets.only(top: 8),
      child: allMelds.isEmpty
          ? const SizedBox()
          : SingleChildScrollView(
              child: Wrap(
                spacing: 12,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: allMelds.map((meldInfo) {
                  final meld = meldInfo['meld'] as Meld;
                  final melds = meldInfo['melds'] as List<Meld>;
                  final meldIndex = meldInfo['meldIndex'] as int;

                  // 선택된 카드가 이 멜드에 붙일 수 있는지 확인
                  bool canAttach = false;
                  if (selectedCardIndices.length == 1 &&
                      currentTurn == 0 &&
                      hasDrawn &&
                      playerMelds.isNotEmpty) {
                    final card = playerHand[selectedCardIndices.first];
                    canAttach = _canAttachToMeldList(card, melds) == meldIndex;
                  }

                  // 겹치는 카드 스택 너비 계산
                  final stackWidth = cardWidth + (meld.cards.length - 1) * overlap;

                  return GestureDetector(
                    onTap: canAttach
                        ? () {
                            final card = playerHand[selectedCardIndices.first];
                            _attachToMeldList(meldIndex, card, melds);
                            playerHand.remove(card);
                            selectedCardIndices.clear();

                            if (playerHand.isEmpty) {
                              _endGame(0);
                            } else {
                              setState(() {});
                              _saveGame();
                            }
                          }
                        : null,
                    child: Container(
                      width: stackWidth,
                      height: cardHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        border: canAttach
                            ? Border.all(color: Colors.yellow, width: 2)
                            : null,
                      ),
                      child: Stack(
                        children: List.generate(meld.cards.length, (i) {
                          final card = meld.cards[i];
                          return Positioned(
                            left: i * overlap,
                            child: Container(
                              width: cardWidth,
                              height: cardHeight,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(color: Colors.grey.shade400, width: 0.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.2),
                                    blurRadius: 1,
                                    offset: const Offset(0.5, 0.5),
                                  ),
                                ],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    card.suitSymbol,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: card.suitColor,
                                      height: 1,
                                    ),
                                  ),
                                  Text(
                                    card.rankString,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: card.suitColor,
                                      height: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }

  Widget _buildPlayerMelds(_HulaResponsiveSizes sizes) {
    return Container(
      height: sizes.meldCardHeight * 1.6,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: playerMelds.length,
        itemBuilder: (context, meldIndex) {
          final meld = playerMelds[meldIndex];
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  meld.isRun ? 'Run: ' : 'Set: ',
                  style: const TextStyle(color: Colors.green, fontSize: 10),
                ),
                ...meld.cards.map((card) => Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Text(
                        '${card.suitSymbol}${card.rankString}',
                        style: TextStyle(
                          color: card.suitColor == Colors.red
                              ? Colors.red.shade300
                              : Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerHand(_HulaResponsiveSizes sizes) {
    final cardWidth = sizes.playerCardWidth;
    final cardHeight = sizes.playerCardHeight;
    final symbolSize = sizes.playerSymbolSize;
    final rankSize = sizes.playerRankSize;

    // AI 추천 카드 인덱스
    final recommendedIndex = _showHint ? _getRecommendedDiscardCardIndex() : null;

    // 세로 모드: 2줄
    final int cardsPerRow = (playerHand.length / 2).ceil();

    final List<int> row1 = List.generate(
      cardsPerRow > playerHand.length ? playerHand.length : cardsPerRow,
      (i) => i,
    );
    final List<int> row2 = List.generate(
      playerHand.length - cardsPerRow > 0
          ? playerHand.length - cardsPerRow
          : 0,
      (i) => cardsPerRow + i,
    );

    Widget buildCard(int index) {
      final card = playerHand[index];
      final isSelected = selectedCardIndices.contains(index);
      final isRecommended = _showHint && recommendedIndex == index;

      return GestureDetector(
        onTap: () => _toggleCardSelection(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(0, isSelected ? -10 : 0, 0),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: isRecommended ? Colors.lightBlueAccent.withValues(alpha: 0.2) : Colors.white,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isRecommended ? Colors.lightBlueAccent : (isSelected ? Colors.amber : Colors.grey.shade400),
              width: isRecommended ? 3 : (isSelected ? 3 : 1),
            ),
            boxShadow: [
              BoxShadow(
                color: isRecommended
                    ? Colors.lightBlueAccent.withValues(alpha: 0.5)
                    : (isSelected
                        ? Colors.amber.withValues(alpha: 0.5)
                        : Colors.black.withValues(alpha: 0.2)),
                blurRadius: isRecommended ? 10 : (isSelected ? 8 : 4),
                offset: const Offset(1, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isRecommended)
                const Icon(Icons.lightbulb, color: Colors.lightBlueAccent, size: 12),
              Text(
                card.suitSymbol,
                style: TextStyle(
                  fontSize: symbolSize,
                  color: card.suitColor,
                ),
              ),
              Text(
                card.rankString,
                style: TextStyle(
                  fontSize: rankSize,
                  fontWeight: FontWeight.bold,
                  color: card.suitColor,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildCardRow(List<int> indices) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: indices.map((index) => buildCard(index)).toList(),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SingleChildScrollView(
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
    );
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context)!;
    // 7 단독: 특별 규칙, 1~2장: 붙이기 가능 여부, 3장+: 새 멜드 가능 여부
    bool canMeld = false;
    if (selectedCardIndices.length >= 3) {
      final cards = selectedCardIndices.map((i) => playerHand[i]).toList();
      canMeld = _isValidMeld(cards);
    } else if (selectedCardIndices.length == 1 && _isSeven(playerHand[selectedCardIndices.first])) {
      // 7 카드 단독 등록 가능 (훌라 특별 규칙)
      canMeld = true;
    } else if (selectedCardIndices.isNotEmpty && playerMelds.isNotEmpty) {
      // 1~2장 선택 시 붙이기 가능 여부 확인 (자신의 멜드가 있어야만 붙이기 가능 - 훌라 규칙)
      for (final idx in selectedCardIndices) {
        final card = playerHand[idx];
        // 플레이어 멜드 확인
        if (_canAttachToMeld(card) >= 0) {
          canMeld = true;
          break;
        }
        // 컴퓨터 멜드 확인
        for (final compMelds in computerMelds) {
          if (_canAttachToMeldList(card, compMelds) >= 0) {
            canMeld = true;
            break;
          }
        }
        if (canMeld) break;
      }
    }
    final canDiscard = hasDrawn && selectedCardIndices.length == 1;

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.black38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 멜드 등록 (드로우 후에만 가능)
          _buildActionButton(
            label: l10n.meldButton,
            color: Colors.green,
            onPressed: currentTurn == 0 && hasDrawn && canMeld ? _registerMeld : null,
          ),
          // 버리기
          _buildActionButton(
            label: l10n.discardButton,
            color: Colors.orange,
            onPressed: currentTurn == 0 && canDiscard ? _discardCard : null,
          ),
          // 스톱
          _buildActionButton(
            label: l10n.stopButton,
            color: Colors.red,
            onPressed: currentTurn == 0 && !gameOver ? _callStop : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed != null ? color : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
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
          style: const TextStyle(color: Colors.amber),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.hulaGuideGoal,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.hulaGuideGoalText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.hulaGuideHow,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.hulaGuideHowText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.hulaGuideMelds,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.hulaGuideMeldsText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.hulaGuideSeven,
                style: const TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.hulaGuideSevenText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.thankYouMeld,
                style: const TextStyle(
                  color: Colors.cyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.hulaGuideThankYouText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.hulaGuideStop,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.hulaGuideStopText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.hulaGuideCardPoints,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.hulaGuideCardPointsText,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.ok),
          ),
        ],
      ),
    );
  }
}
