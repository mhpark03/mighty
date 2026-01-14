import '../card.dart';
import '../player.dart';
import '../seven_card/poker_hand.dart';
import 'hi_lo_hand.dart';

/// 하이로우 게임 단계
enum HiLoPhase {
  waiting,      // 대기
  selectOpen,   // 공개 카드 선택 (3장 중 1장)
  betting1,     // 1차 베팅 (4장 받은 후)
  betting2,     // 2차 베팅 (5장째 받은 후)
  betting3,     // 3차 베팅 (6장째 받은 후)
  betting4,     // 4차 베팅 (7장째 받은 후)
  selectHiLo,   // 하이/로우/스윙 선택
  showdown,     // 쇼다운
  gameEnd,      // 게임 종료
}

/// 베팅 액션 종류
enum HiLoBettingAction {
  none,    // 아직 액션 없음
  bing,    // 삥
  check,   // 체크
  call,    // 콜
  ddadang, // 따당
  quarter, // 쿼터
  half,    // 하프
  full,    // 풀
  die,     // 다이
}

/// 하이/로우 선택
enum HiLoChoice {
  none,   // 미선택
  hi,     // 하이
  lo,     // 로우
  swing,  // 스윙 (하이/로우 둘 다)
}

/// 하이로우 플레이어
class HiLoPlayer {
  final int id;
  String name;
  final PlayerType type;
  List<PlayingCard> hand; // 전체 카드 (최대 7장)
  int chips;              // 보유 칩
  int currentBet;         // 현재 라운드 베팅액
  int totalBetInGame;     // 현재 게임에서 배팅한 총 금액
  int bettingActionsInRound; // 현재 라운드에서 베팅 횟수
  bool isFolded;          // 폴드 여부
  bool isAllIn;           // 올인 여부
  int openCardIndex;      // 초기 3장 중 공개할 카드 인덱스 (-1이면 미선택)
  HiLoBettingAction lastAction; // 마지막 베팅 액션
  HiLoChoice hiLoChoice;  // 하이/로우/스윙 선택

  // 최대 베팅 횟수
  static const int maxBettingActions = 3;

  HiLoPlayer({
    required this.id,
    required this.name,
    required this.type,
    List<PlayingCard>? hand,
    this.chips = 0,
    this.currentBet = 0,
    this.totalBetInGame = 0,
    this.bettingActionsInRound = 0,
    this.isFolded = false,
    this.isAllIn = false,
    this.openCardIndex = -1,
    this.lastAction = HiLoBettingAction.none,
    this.hiLoChoice = HiLoChoice.none,
  }) : hand = hand ?? [];

  /// 베팅 가능 여부 (3회 미만)
  bool get canBet => bettingActionsInRound < maxBettingActions;

  /// 오픈 카드 (상대에게 보이는 카드)
  /// - 초기 3장 중 선택한 카드 + 4번째~6번째 카드 (7번째는 히든)
  List<PlayingCard> get openCards {
    final open = <PlayingCard>[];
    // 선택한 공개 카드 (처음 3장 중)
    if (openCardIndex >= 0 && openCardIndex < hand.length && openCardIndex < 3) {
      open.add(hand[openCardIndex]);
    }
    // 4번째~6번째 카드만 공개 (7번째 카드는 히든)
    if (hand.length > 3) {
      final endIndex = hand.length > 6 ? 6 : hand.length;
      open.addAll(hand.sublist(3, endIndex));
    }
    return open;
  }

  /// 히든 카드 (처음 3장 중 공개하지 않은 카드 + 7번째 카드)
  List<PlayingCard> get hiddenCards {
    if (hand.isEmpty) return [];
    final hidden = <PlayingCard>[];
    // 처음 3장 중 공개하지 않은 카드
    final limit = hand.length > 3 ? 3 : hand.length;
    for (int i = 0; i < limit; i++) {
      if (i != openCardIndex) {
        hidden.add(hand[i]);
      }
    }
    // 7번째 카드도 히든
    if (hand.length >= 7) {
      hidden.add(hand[6]);
    }
    return hidden;
  }

  /// 하이 포커 핸드 평가 (전체 카드 - 5장 이상)
  PokerHand? get pokerHand {
    if (hand.length < 5) return null;
    return PokerHandEvaluator.evaluate(hand);
  }

  /// 로우 핸드 평가
  LowHand? get lowHand {
    if (hand.length < 5) return null;
    return HiLoHandEvaluator.evaluateLow(hand);
  }

  /// 전체 카드 기준 족보 평가 (부분 평가 포함)
  PokerHand? get allCardsPokerHand {
    if (hand.length < 2) return null;
    // 5장 이상이면 정상 평가
    if (hand.length >= 5) {
      return PokerHandEvaluator.evaluate(hand);
    }
    // 5장 미만이면 부분 평가 (페어, 트리플 등만 체크)
    return PokerHandEvaluator.evaluatePartial(hand);
  }

  /// 공개 카드 기준 족보 평가
  PokerHand? get openPokerHand {
    if (openCards.length < 2) return null;
    // 공개 카드가 5장 이상이면 정상 평가
    if (openCards.length >= 5) {
      return PokerHandEvaluator.evaluate(openCards);
    }
    // 5장 미만이면 부분 평가 (페어, 트리플 등만 체크)
    return PokerHandEvaluator.evaluatePartial(openCards);
  }

  /// 게임 참여 가능 여부
  bool get isActive => !isFolded;

  void reset() {
    hand.clear();
    currentBet = 0;
    totalBetInGame = 0;
    bettingActionsInRound = 0;
    isFolded = false;
    isAllIn = false;
    openCardIndex = -1;
    lastAction = HiLoBettingAction.none;
    hiLoChoice = HiLoChoice.none;
  }

  HiLoPlayer copyWith({
    int? id,
    String? name,
    PlayerType? type,
    List<PlayingCard>? hand,
    int? chips,
    int? currentBet,
    int? totalBetInGame,
    int? bettingActionsInRound,
    bool? isFolded,
    bool? isAllIn,
    int? openCardIndex,
    HiLoBettingAction? lastAction,
    HiLoChoice? hiLoChoice,
  }) {
    return HiLoPlayer(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      hand: hand ?? List.from(this.hand),
      chips: chips ?? this.chips,
      currentBet: currentBet ?? this.currentBet,
      totalBetInGame: totalBetInGame ?? this.totalBetInGame,
      bettingActionsInRound: bettingActionsInRound ?? this.bettingActionsInRound,
      isFolded: isFolded ?? this.isFolded,
      isAllIn: isAllIn ?? this.isAllIn,
      openCardIndex: openCardIndex ?? this.openCardIndex,
      lastAction: lastAction ?? this.lastAction,
      hiLoChoice: hiLoChoice ?? this.hiLoChoice,
    );
  }

  // JSON 직렬화
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type.index,
    'hand': hand.map((c) => c.toJson()).toList(),
    'chips': chips,
    'currentBet': currentBet,
    'totalBetInGame': totalBetInGame,
    'bettingActionsInRound': bettingActionsInRound,
    'isFolded': isFolded,
    'isAllIn': isAllIn,
    'openCardIndex': openCardIndex,
    'lastAction': lastAction.index,
    'hiLoChoice': hiLoChoice.index,
  };

  factory HiLoPlayer.fromJson(Map<String, dynamic> json) {
    return HiLoPlayer(
      id: json['id'],
      name: json['name'],
      type: PlayerType.values[json['type']],
      hand: (json['hand'] as List).map((c) => PlayingCard.fromJson(c)).toList(),
      chips: json['chips'],
      currentBet: json['currentBet'],
      totalBetInGame: json['totalBetInGame'],
      bettingActionsInRound: json['bettingActionsInRound'],
      isFolded: json['isFolded'],
      isAllIn: json['isAllIn'],
      openCardIndex: json['openCardIndex'],
      lastAction: HiLoBettingAction.values[json['lastAction']],
      hiLoChoice: HiLoChoice.values[json['hiLoChoice']],
    );
  }
}

/// 보너스 핸드 정보
class BonusHandInfo {
  final HiLoPlayer winner;
  final HandRank handRank;
  final int bonusAmount;
  final int totalWinnings; // 보너스 + 팟

  BonusHandInfo({
    required this.winner,
    required this.handRank,
    required this.bonusAmount,
    required this.totalWinnings,
  });

  /// 보너스 금액 계산 (포카드 이상)
  static int getBonusAmount(HandRank rank) {
    switch (rank) {
      case HandRank.royalStraightFlush:
        return 500;
      case HandRank.backStraightFlush:
        return 300;
      case HandRank.straightFlush:
        return 200;
      case HandRank.fourOfAKind:
        return 100;
      default:
        return 0;
    }
  }

  /// 보너스 핸드인지 확인 (포카드 이상)
  static bool isBonusHand(HandRank rank) {
    return rank == HandRank.fourOfAKind ||
           rank == HandRank.straightFlush ||
           rank == HandRank.backStraightFlush ||
           rank == HandRank.royalStraightFlush;
  }
}

/// 하이로우 게임 결과
class HiLoResult {
  final HiLoPlayer? hiWinner;
  final HiLoPlayer? loWinner;
  final int hiPot;
  final int loPot;
  final bool swingSuccess; // 스윙 성공 여부
  final HiLoPlayer? swingPlayer; // 스윙 시도자
  final BonusHandInfo? bonusInfo; // 보너스 핸드 정보

  HiLoResult({
    this.hiWinner,
    this.loWinner,
    this.hiPot = 0,
    this.loPot = 0,
    this.swingSuccess = false,
    this.swingPlayer,
    this.bonusInfo,
  });
}

/// 하이로우 게임 상태
class HiLoState {
  final List<HiLoPlayer> players;
  final Deck deck;
  HiLoPhase phase;
  int dealerIndex;        // 딜러 위치
  int currentPlayerIndex; // 현재 차례
  int pot;                // 팟 (총 베팅액)
  int currentBetAmount;   // 현재 콜 금액
  int minRaise;           // 최소 레이즈 금액
  int lastRaiserIndex;    // 마지막 레이즈한 플레이어
  int bettingRoundStarterIndex; // 베팅 라운드 시작 플레이어 (보스)
  HiLoResult? result;     // 게임 결과

  // 기본 베팅 설정
  static const int basebet = 10;  // 삥 (기본 판돈)
  static const int ante = 10;

  HiLoState({
    required this.players,
    Deck? deck,
    this.phase = HiLoPhase.waiting,
    this.dealerIndex = 0,
    this.currentPlayerIndex = 0,
    this.pot = 0,
    this.currentBetAmount = 0,
    this.minRaise = basebet,
    this.lastRaiserIndex = -1,
    this.bettingRoundStarterIndex = 0,
    this.result,
  }) : deck = deck ?? Deck();

  /// 활성 플레이어 수
  int get activePlayerCount => players.where((p) => p.isActive).length;

  /// 현재 플레이어
  HiLoPlayer get currentPlayer => players[currentPlayerIndex];

  /// 딜러
  HiLoPlayer get dealer => players[dealerIndex];

  /// 인간 플레이어
  HiLoPlayer get humanPlayer => players[0];

  /// 새 게임 시작
  void startNewGame() {
    // 덱 초기화 및 셔플 (조커 제거)
    deck.reset();
    deck.cards.removeWhere((c) => c.isJoker);
    deck.shuffle();

    // 플레이어 초기화
    for (final player in players) {
      player.reset();
    }

    // 팟 초기화
    pot = 0;
    currentBetAmount = 0;
    minRaise = basebet;
    lastRaiserIndex = -1;
    result = null;

    // 딜러 이동
    dealerIndex = (dealerIndex + 1) % players.length;

    // 안테 징수 (각 플레이어 10칩)
    for (final player in players) {
      player.chips -= ante;
      player.totalBetInGame += ante;
      pot += ante;
    }

    // 카드 배분 (각 플레이어에게 3장씩)
    for (int i = 0; i < 3; i++) {
      for (final player in players) {
        if (deck.cards.isNotEmpty) {
          player.hand.add(deck.cards.removeLast());
        }
      }
    }

    // 공개 카드 선택 단계 (인간 플레이어부터)
    phase = HiLoPhase.selectOpen;
    currentPlayerIndex = 0;
  }

  /// 공개 카드 선택
  void selectOpenCard(int cardIndex) {
    if (phase != HiLoPhase.selectOpen) return;
    if (cardIndex < 0 || cardIndex >= 3) return;

    currentPlayer.openCardIndex = cardIndex;
    _moveToNextPlayerForSelection();
  }

  /// 공개 카드 선택 다음 플레이어로 이동
  void _moveToNextPlayerForSelection() {
    // 다음 플레이어 찾기
    int nextIndex = (currentPlayerIndex + 1) % players.length;

    // 모든 플레이어가 선택했는지 확인
    bool allSelected = players.every((p) => p.openCardIndex >= 0);

    if (allSelected) {
      // 4번째 카드 배분 후 베팅 시작
      _dealCard();
      phase = HiLoPhase.betting1;
      // 하이카드 플레이어가 보스 (먼저 베팅)
      bettingRoundStarterIndex = _getHighCardPlayerIndex();
      currentPlayerIndex = bettingRoundStarterIndex;
      currentBetAmount = 0;  // 보스가 삥/체크 선택
    } else {
      currentPlayerIndex = nextIndex;
    }
  }

  /// 화면 배치 기준 시계 반대 방향 순서
  static const List<int> _visualTurnOrder = [0, 4, 3, 1, 2];

  /// 다음 활성 플레이어 인덱스 (시계 반대 방향 - 화면 배치 기준)
  int _getNextActivePlayer(int from) {
    // 현재 플레이어의 시각적 순서 위치 찾기
    int currentPos = _visualTurnOrder.indexOf(from);
    if (currentPos == -1) currentPos = 0;

    int count = 0;
    while (count < players.length) {
      currentPos = (currentPos + 1) % _visualTurnOrder.length;
      int nextIndex = _visualTurnOrder[currentPos];
      if (players[nextIndex].isActive) {
        return nextIndex;
      }
      count++;
    }
    return from;
  }

  /// 오픈 카드 중 가장 높은 카드를 가진 플레이어 찾기 (보스)
  int _getHighCardPlayerIndex() {
    int highestIndex = 0;
    PokerHand? highestHand;
    List<PlayingCard> highestCards = [];
    bool foundFirst = false;

    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      if (!player.isActive) continue;

      final currentHand = player.openPokerHand;

      final sortedCards = player.openCards
          .where((c) => !c.isJoker)
          .toList()
        ..sort((a, b) {
          final rankCompare = b.rankValue.compareTo(a.rankValue);
          if (rankCompare != 0) return rankCompare;
          return _getSuitValue(b.suit).compareTo(_getSuitValue(a.suit));
        });

      if (sortedCards.isEmpty) continue;

      if (!foundFirst) {
        highestHand = currentHand;
        highestCards = sortedCards;
        highestIndex = i;
        foundFirst = true;
      } else {
        if (currentHand != null && highestHand != null) {
          final handCompare = currentHand.compareTo(highestHand);
          if (handCompare > 0) {
            highestHand = currentHand;
            highestCards = sortedCards;
            highestIndex = i;
          } else if (handCompare == 0) {
            final cardCompare = _compareCardLists(sortedCards, highestCards);
            if (cardCompare > 0) {
              highestHand = currentHand;
              highestCards = sortedCards;
              highestIndex = i;
            }
          }
        } else if (currentHand != null && highestHand == null) {
          highestHand = currentHand;
          highestCards = sortedCards;
          highestIndex = i;
        } else if (currentHand == null && highestHand == null) {
          final cardCompare = _compareCardLists(sortedCards, highestCards);
          if (cardCompare > 0) {
            highestCards = sortedCards;
            highestIndex = i;
          }
        }
      }
    }

    return highestIndex;
  }

  int _compareCardLists(List<PlayingCard> a, List<PlayingCard> b) {
    final maxLen = a.length > b.length ? a.length : b.length;

    for (int i = 0; i < maxLen; i++) {
      if (i >= a.length) return -1;
      if (i >= b.length) return 1;

      final cardA = a[i];
      final cardB = b[i];

      if (cardA.rankValue != cardB.rankValue) {
        return cardA.rankValue.compareTo(cardB.rankValue);
      }

      final suitCompare = _getSuitValue(cardA.suit).compareTo(_getSuitValue(cardB.suit));
      if (suitCompare != 0) {
        return suitCompare;
      }
    }

    return 0;
  }

  int _getSuitValue(Suit? suit) {
    const suitOrder = {
      Suit.spade: 4,
      Suit.diamond: 3,
      Suit.heart: 2,
      Suit.club: 1,
    };
    return suitOrder[suit] ?? 0;
  }

  /// 베팅 액션: 콜
  void call() {
    final player = currentPlayer;
    final callAmount = (currentBetAmount - player.currentBet).clamp(0, 999999);
    player.chips -= callAmount;
    player.currentBet += callAmount;
    player.totalBetInGame += callAmount;
    pot += callAmount;
    player.lastAction = HiLoBettingAction.call;
    player.bettingActionsInRound++;

    _moveToNextPlayer();
  }

  /// 베팅 액션: 삥 (기본 판돈만 베팅 - 보스만 가능)
  void bing() {
    final player = currentPlayer;
    final bingAmount = basebet;

    player.chips -= bingAmount;
    player.currentBet = bingAmount;
    player.totalBetInGame += bingAmount;
    pot += bingAmount;
    currentBetAmount = bingAmount;
    lastRaiserIndex = currentPlayerIndex;
    player.lastAction = HiLoBettingAction.bing;
    player.bettingActionsInRound++;

    _moveToNextPlayer();
  }

  /// 베팅 액션: 따당 (앞사람 베팅의 2배)
  void ddadang() {
    final player = currentPlayer;
    final ddadangAmount = currentBetAmount * 2;
    final additionalBet = (ddadangAmount - player.currentBet).clamp(0, 999999);

    player.chips -= additionalBet;
    player.currentBet += additionalBet;
    player.totalBetInGame += additionalBet;
    pot += additionalBet;
    currentBetAmount = player.currentBet;
    lastRaiserIndex = currentPlayerIndex;
    player.lastAction = HiLoBettingAction.ddadang;
    player.bettingActionsInRound++;

    _moveToNextPlayer();
  }

  /// 베팅 액션: 쿼터 (전체 판돈의 25%)
  void quarter() {
    final player = currentPlayer;
    final quarterAmount = (pot * 0.25).ceil().clamp(basebet, 999999);
    final additionalBet = (quarterAmount - player.currentBet).clamp(0, 999999);

    player.chips -= additionalBet;
    player.currentBet += additionalBet;
    player.totalBetInGame += additionalBet;
    pot += additionalBet;
    currentBetAmount = player.currentBet;
    lastRaiserIndex = currentPlayerIndex;
    player.lastAction = HiLoBettingAction.quarter;
    player.bettingActionsInRound++;

    _moveToNextPlayer();
  }

  /// 베팅 액션: 하프 (전체 판돈의 50%)
  void half() {
    final player = currentPlayer;
    final halfAmount = (pot * 0.5).ceil().clamp(basebet, 999999);
    final additionalBet = (halfAmount - player.currentBet).clamp(0, 999999);

    player.chips -= additionalBet;
    player.currentBet += additionalBet;
    player.totalBetInGame += additionalBet;
    pot += additionalBet;
    currentBetAmount = player.currentBet;
    lastRaiserIndex = currentPlayerIndex;
    player.lastAction = HiLoBettingAction.half;
    player.bettingActionsInRound++;

    _moveToNextPlayer();
  }

  /// 베팅 액션: 풀 (전체 판돈의 100%)
  void full() {
    final player = currentPlayer;
    final fullAmount = pot.clamp(basebet, 999999);
    final additionalBet = (fullAmount - player.currentBet).clamp(0, 999999);

    player.chips -= additionalBet;
    player.currentBet += additionalBet;
    player.totalBetInGame += additionalBet;
    pot += additionalBet;
    currentBetAmount = player.currentBet;
    lastRaiserIndex = currentPlayerIndex;
    player.lastAction = HiLoBettingAction.full;
    player.bettingActionsInRound++;

    _moveToNextPlayer();
  }

  /// 베팅 액션: 폴드
  void fold() {
    currentPlayer.lastAction = HiLoBettingAction.die;
    currentPlayer.isFolded = true;

    // 남은 플레이어가 1명이면 즉시 승리
    if (activePlayerCount == 1) {
      final winner = players.firstWhere((p) => p.isActive);
      winner.chips += pot;
      result = HiLoResult(hiWinner: winner, hiPot: pot);
      phase = HiLoPhase.gameEnd;
      return;
    }

    _moveToNextPlayer();
  }

  /// 베팅 액션: 체크 (베팅액이 같을 때)
  void check() {
    currentPlayer.lastAction = HiLoBettingAction.check;
    currentPlayer.bettingActionsInRound++;
    _moveToNextPlayer();
  }

  /// 베팅 액션: 올인
  void allIn() {
    final player = currentPlayer;
    final allInAmount = player.chips;
    player.currentBet += allInAmount;
    player.totalBetInGame += allInAmount;
    pot += allInAmount;
    player.chips = 0;
    player.isAllIn = true;
    player.bettingActionsInRound++;

    if (player.currentBet > currentBetAmount) {
      currentBetAmount = player.currentBet;
      minRaise = allInAmount;
      lastRaiserIndex = currentPlayerIndex;
    }

    _moveToNextPlayer();
  }

  /// 하이/로우/스윙 선택
  void selectHiLo(HiLoChoice choice) {
    if (phase != HiLoPhase.selectHiLo) return;

    currentPlayer.hiLoChoice = choice;
    _moveToNextPlayerForHiLoSelection();
  }

  /// 하이/로우 선택 다음 플레이어로 이동
  void _moveToNextPlayerForHiLoSelection() {
    // 모든 활성 플레이어가 선택했는지 확인
    final activePlayers = players.where((p) => p.isActive).toList();
    final allSelected = activePlayers.every((p) => p.hiLoChoice != HiLoChoice.none);

    if (allSelected) {
      // 쇼다운으로 이동
      phase = HiLoPhase.showdown;
      _determineWinners();
    } else {
      // 다음 활성 플레이어 찾기
      currentPlayerIndex = _getNextActivePlayer(currentPlayerIndex);
    }
  }

  /// 다음 플레이어로 이동
  void _moveToNextPlayer() {
    final nextPlayer = _getNextActivePlayer(currentPlayerIndex);

    // 베팅 라운드 종료 조건 확인
    bool roundComplete = _isBettingRoundComplete(nextPlayer);

    if (roundComplete) {
      _endBettingRound();
    } else {
      currentPlayerIndex = nextPlayer;
    }
  }

  /// 베팅 라운드 완료 여부
  bool _isBettingRoundComplete(int nextPlayer) {
    if (activePlayerCount <= 1) return true;

    final activePlayers = players.where((p) => p.isActive && !p.isAllIn).toList();
    if (activePlayers.isEmpty) return true;

    final targetBet = currentBetAmount;
    final allMatched = activePlayers.every((p) => p.currentBet == targetBet);

    final allExhausted = activePlayers.every((p) => !p.canBet);
    if (allExhausted && allMatched) return true;

    if (allMatched) {
      if (lastRaiserIndex >= 0) {
        return nextPlayer == lastRaiserIndex;
      }
      return nextPlayer == bettingRoundStarterIndex;
    }

    return false;
  }

  /// 베팅 라운드 종료
  void _endBettingRound() {
    // 베팅액 및 액션 초기화
    for (final player in players) {
      player.currentBet = 0;
      player.bettingActionsInRound = 0;
      player.lastAction = HiLoBettingAction.none;
    }
    currentBetAmount = 0;
    minRaise = basebet;
    lastRaiserIndex = -1;

    // 활성 플레이어가 1명이면 게임 종료
    if (activePlayerCount <= 1) {
      _endGameWithSingleWinner();
      return;
    }

    // 다음 단계로
    switch (phase) {
      case HiLoPhase.betting1:
        _dealCard();
        phase = HiLoPhase.betting2;
        break;
      case HiLoPhase.betting2:
        _dealCard();
        phase = HiLoPhase.betting3;
        break;
      case HiLoPhase.betting3:
        _dealCard();
        phase = HiLoPhase.betting4;
        break;
      case HiLoPhase.betting4:
        // 보너스 핸드 확인 (포카드 이상)
        final bonusWinner = _checkBonusHand();
        if (bonusWinner != null) {
          // 보너스 핸드 발생 - 하이/로우 선택 건너뛰고 바로 쇼다운
          _handleBonusWin(bonusWinner);
          return;
        }
        // 하이/로우 선택 단계로 이동
        phase = HiLoPhase.selectHiLo;
        // 보스부터 선택 시작
        bettingRoundStarterIndex = _getHighCardPlayerIndex();
        currentPlayerIndex = bettingRoundStarterIndex;
        return;
      default:
        break;
    }

    // 다음 베팅 시작 (하이카드 플레이어가 보스)
    bettingRoundStarterIndex = _getHighCardPlayerIndex();
    currentPlayerIndex = bettingRoundStarterIndex;
  }

  /// 카드 한 장씩 배분
  void _dealCard() {
    for (final player in players) {
      if (player.isActive && deck.cards.isNotEmpty) {
        player.hand.add(deck.cards.removeLast());
      }
    }
  }

  /// 단일 승자로 게임 종료
  void _endGameWithSingleWinner() {
    phase = HiLoPhase.gameEnd;

    final activePlayers = players.where((p) => p.isActive).toList();
    if (activePlayers.length == 1) {
      final winner = activePlayers.first;
      winner.chips += pot;
      result = HiLoResult(hiWinner: winner, hiPot: pot);
    }
  }

  /// 쇼다운에서 게임 종료로 이동
  void proceedToGameEnd() {
    if (phase == HiLoPhase.showdown) {
      phase = HiLoPhase.gameEnd;
    }
  }

  /// 승자 결정 (하이/로우 분리)
  void _determineWinners() {
    // showdown 상태 유지 (proceedToGameEnd로 gameEnd로 전환)

    final activePlayers = players.where((p) => p.isActive).toList();

    // 하이 참가자 (하이 또는 스윙 선택)
    final hiPlayers = activePlayers.where((p) =>
        p.hiLoChoice == HiLoChoice.hi || p.hiLoChoice == HiLoChoice.swing).toList();

    // 로우 참가자 (로우 또는 스윙 선택)
    final loPlayers = activePlayers.where((p) =>
        p.hiLoChoice == HiLoChoice.lo || p.hiLoChoice == HiLoChoice.swing).toList();

    // 스윙 플레이어
    final swingPlayers = activePlayers.where((p) =>
        p.hiLoChoice == HiLoChoice.swing).toList();

    // 하이 승자 결정
    HiLoPlayer? hiWinner;
    if (hiPlayers.isNotEmpty) {
      PokerHand? bestHiHand;
      for (final player in hiPlayers) {
        final hand = player.pokerHand;
        if (hand != null) {
          if (bestHiHand == null || hand.compareTo(bestHiHand) > 0) {
            bestHiHand = hand;
            hiWinner = player;
          }
        }
      }
    }

    // 로우 승자 결정
    HiLoPlayer? loWinner;
    if (loPlayers.isNotEmpty) {
      LowHand? bestLoHand;
      for (final player in loPlayers) {
        final hand = player.lowHand;
        if (hand != null && hand.isQualified) {
          if (bestLoHand == null || hand.compareTo(bestLoHand) < 0) {
            bestLoHand = hand;
            loWinner = player;
          }
        }
      }
    }

    // 팟 분배 계산
    int hiPot = 0;
    int loPot = 0;

    // 스윙 성공 여부 확인
    bool swingSuccess = false;
    HiLoPlayer? swingPlayer;

    if (swingPlayers.length == 1) {
      swingPlayer = swingPlayers.first;
      // 스윙 성공: 하이와 로우 모두 1등
      if (hiWinner == swingPlayer && loWinner == swingPlayer) {
        swingSuccess = true;
        swingPlayer.chips += pot;
        hiPot = pot;
        loPot = 0;
      }
    }

    // 스윙 실패 또는 스윙 없음: 50:50 분배
    if (!swingSuccess) {
      final halfPot = pot ~/ 2;
      final remainder = pot % 2;

      if (hiWinner != null && loWinner != null) {
        hiPot = halfPot + remainder;
        loPot = halfPot;
        hiWinner.chips += hiPot;
        loWinner.chips += loPot;
      } else if (hiWinner != null && loWinner == null) {
        // 로우 승자 없음: 하이 승자가 전체 획득
        hiPot = pot;
        hiWinner.chips += pot;
      } else if (hiWinner == null && loWinner != null) {
        // 하이 승자 없음: 로우 승자가 전체 획득
        loPot = pot;
        loWinner.chips += pot;
      }
      // 둘 다 없으면 팟은 그대로 (다음 게임으로)
    }

    result = HiLoResult(
      hiWinner: hiWinner,
      loWinner: loWinner,
      hiPot: hiPot,
      loPot: loPot,
      swingSuccess: swingSuccess,
      swingPlayer: swingPlayer,
    );
  }

  /// 보스인지 확인 (라운드의 첫 번째 플레이어)
  bool get isCurrentPlayerBoss => lastRaiserIndex == -1 && currentBetAmount == 0;

  /// 보너스 핸드 확인 (포카드 이상을 가진 플레이어 반환)
  HiLoPlayer? _checkBonusHand() {
    HiLoPlayer? bestBonusPlayer;
    PokerHand? bestBonusHand;

    for (final player in players) {
      if (!player.isActive) continue;

      final hand = player.pokerHand;
      if (hand == null) continue;

      if (BonusHandInfo.isBonusHand(hand.rank)) {
        if (bestBonusHand == null || hand.compareTo(bestBonusHand) > 0) {
          bestBonusHand = hand;
          bestBonusPlayer = player;
        }
      }
    }

    return bestBonusPlayer;
  }

  /// 보너스 핸드 승리 처리
  void _handleBonusWin(HiLoPlayer winner) {
    final hand = winner.pokerHand!;
    final bonusAmount = BonusHandInfo.getBonusAmount(hand.rank);

    // 다른 모든 플레이어에게서 보너스 금액 징수
    int totalBonus = 0;
    for (final player in players) {
      if (player.id == winner.id) continue;
      player.chips -= bonusAmount;
      totalBonus += bonusAmount;
    }

    // 승자에게 팟 + 보너스 지급
    final totalWinnings = pot + totalBonus;
    winner.chips += totalWinnings;

    // 결과 저장
    result = HiLoResult(
      hiWinner: winner,
      hiPot: pot,
      bonusInfo: BonusHandInfo(
        winner: winner,
        handRank: hand.rank,
        bonusAmount: bonusAmount,
        totalWinnings: totalWinnings,
      ),
    );

    // 바로 쇼다운으로 이동 (하이/로우 선택 건너뜀)
    phase = HiLoPhase.showdown;
  }

  /// 현재 플레이어가 취할 수 있는 액션
  List<String> getAvailableActions() {
    final player = currentPlayer;
    final actions = <String>[];

    // 3회 베팅 완료시 콜/다이만 가능
    if (!player.canBet) {
      if (player.currentBet < currentBetAmount) {
        actions.add('call');
      }
      actions.add('die');
      return actions;
    }

    if (isCurrentPlayerBoss) {
      actions.add('bing');
      actions.add('check');
      actions.add('quarter');
      actions.add('half');
      actions.add('full');
    } else {
      if (player.currentBet < currentBetAmount) {
        actions.add('call');
      }
      actions.add('ddadang');
      final quarterAmount = (pot * 0.25).ceil();
      if (quarterAmount > currentBetAmount) {
        actions.add('quarter');
      }
      final halfAmount = (pot * 0.5).ceil();
      if (halfAmount > currentBetAmount) {
        actions.add('half');
      }
      if (pot > currentBetAmount) {
        actions.add('full');
      }
    }

    actions.add('die');

    return actions;
  }

  /// 각 베팅 액션의 금액 계산
  int getBingAmount() => basebet;
  int getCallAmount() => (currentBetAmount - currentPlayer.currentBet).clamp(0, 999999);
  int getDdadangAmount() => (currentBetAmount * 2 - currentPlayer.currentBet).clamp(0, 999999);
  int getQuarterAmount() => ((pot * 0.25).ceil() - currentPlayer.currentBet).clamp(0, 999999);
  int getHalfAmount() => ((pot * 0.5).ceil() - currentPlayer.currentBet).clamp(0, 999999);
  int getFullAmount() => (pot - currentPlayer.currentBet).clamp(0, 999999);

  // JSON 직렬화
  Map<String, dynamic> toJson() => {
    'players': players.map((p) => p.toJson()).toList(),
    'deckCards': deck.cards.map((c) => c.toJson()).toList(),
    'phase': phase.index,
    'dealerIndex': dealerIndex,
    'currentPlayerIndex': currentPlayerIndex,
    'pot': pot,
    'currentBetAmount': currentBetAmount,
    'minRaise': minRaise,
    'lastRaiserIndex': lastRaiserIndex,
    'bettingRoundStarterIndex': bettingRoundStarterIndex,
  };

  factory HiLoState.fromJson(Map<String, dynamic> json) {
    final players = (json['players'] as List)
        .map((p) => HiLoPlayer.fromJson(p))
        .toList();

    final deck = Deck();
    deck.cards.clear();
    // 조커 제거된 덱 복원
    deck.cards.addAll(
      (json['deckCards'] as List).map((c) => PlayingCard.fromJson(c)),
    );

    return HiLoState(
      players: players,
      deck: deck,
      phase: HiLoPhase.values[json['phase']],
      dealerIndex: json['dealerIndex'],
      currentPlayerIndex: json['currentPlayerIndex'],
      pot: json['pot'],
      currentBetAmount: json['currentBetAmount'],
      minRaise: json['minRaise'],
      lastRaiserIndex: json['lastRaiserIndex'],
      bettingRoundStarterIndex: json['bettingRoundStarterIndex'],
    );
  }
}
