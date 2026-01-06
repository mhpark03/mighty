import '../card.dart';
import '../player.dart';
import 'poker_hand.dart';

/// 세븐카드 게임 단계
enum SevenCardPhase {
  waiting,      // 대기
  selectOpen,   // 공개 카드 선택 (3장 중 1장)
  betting1,     // 1차 베팅 (4장 받은 후)
  betting2,     // 2차 베팅 (5장째 받은 후)
  betting3,     // 3차 베팅 (6장째 받은 후)
  betting4,     // 4차 베팅 (7장째 받은 후)
  showdown,     // 쇼다운
  gameEnd,      // 게임 종료
}

/// 베팅 액션 종류
enum BettingAction {
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

/// 세븐카드 플레이어
class SevenCardPlayer {
  final int id;
  final String name;
  final PlayerType type;
  List<PlayingCard> hand; // 전체 카드 (최대 7장)
  int chips;              // 보유 칩
  int currentBet;         // 현재 라운드 베팅액
  int totalBetInGame;     // 현재 게임에서 배팅한 총 금액
  int bettingActionsInRound; // 현재 라운드에서 베팅 횟수
  bool isFolded;          // 폴드 여부
  bool isAllIn;           // 올인 여부
  int openCardIndex;      // 초기 3장 중 공개할 카드 인덱스 (-1이면 미선택)
  BettingAction lastAction; // 마지막 베팅 액션

  // 최대 베팅 횟수
  static const int maxBettingActions = 3;

  SevenCardPlayer({
    required this.id,
    required this.name,
    required this.type,
    List<PlayingCard>? hand,
    this.chips = 1000,
    this.currentBet = 0,
    this.totalBetInGame = 0,
    this.bettingActionsInRound = 0,
    this.isFolded = false,
    this.isAllIn = false,
    this.openCardIndex = -1,
    this.lastAction = BettingAction.none,
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

  /// 포커 핸드 평가 (전체 카드)
  PokerHand? get pokerHand {
    if (hand.length < 5) return null;
    return PokerHandEvaluator.evaluate(hand);
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
  bool get isActive => !isFolded && chips > 0;

  void reset() {
    hand.clear();
    currentBet = 0;
    totalBetInGame = 0;
    bettingActionsInRound = 0;
    isFolded = false;
    isAllIn = false;
    openCardIndex = -1;
    lastAction = BettingAction.none;
  }

  SevenCardPlayer copyWith({
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
    BettingAction? lastAction,
  }) {
    return SevenCardPlayer(
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
    );
  }
}

/// 세븐카드 게임 상태
class SevenCardState {
  final List<SevenCardPlayer> players;
  final Deck deck;
  SevenCardPhase phase;
  int dealerIndex;        // 딜러 위치
  int currentPlayerIndex; // 현재 차례
  int pot;                // 팟 (총 베팅액)
  int currentBetAmount;   // 현재 콜 금액
  int minRaise;           // 최소 레이즈 금액
  int lastRaiserIndex;    // 마지막 레이즈한 플레이어
  int bettingRoundStarterIndex; // 베팅 라운드 시작 플레이어 (보스)
  int? winnerId;          // 승자 ID

  // 기본 베팅 설정
  static const int basebet = 10;  // 삥 (기본 판돈)
  static const int ante = 5;

  SevenCardState({
    required this.players,
    Deck? deck,
    this.phase = SevenCardPhase.waiting,
    this.dealerIndex = 0,
    this.currentPlayerIndex = 0,
    this.pot = 0,
    this.currentBetAmount = 0,
    this.minRaise = basebet,
    this.lastRaiserIndex = -1,
    this.bettingRoundStarterIndex = 0,
    this.winnerId,
  }) : deck = deck ?? Deck();

  /// 활성 플레이어 수
  int get activePlayerCount => players.where((p) => p.isActive).length;

  /// 현재 플레이어
  SevenCardPlayer get currentPlayer => players[currentPlayerIndex];

  /// 딜러
  SevenCardPlayer get dealer => players[dealerIndex];

  /// 인간 플레이어
  SevenCardPlayer get humanPlayer => players[0];

  /// 새 게임 시작
  void startNewGame() {
    // 덱 초기화 및 셔플 (조커 제거 - 세븐포커는 조커 미사용)
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
    winnerId = null;

    // 딜러 이동
    dealerIndex = (dealerIndex + 1) % players.length;

    // 안테 징수
    for (final player in players) {
      final anteAmount = ante.clamp(0, player.chips);
      player.chips -= anteAmount;
      player.totalBetInGame += anteAmount;
      pot += anteAmount;
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
    phase = SevenCardPhase.selectOpen;
    currentPlayerIndex = 0;
  }

  /// 공개 카드 선택
  void selectOpenCard(int cardIndex) {
    if (phase != SevenCardPhase.selectOpen) return;
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
      phase = SevenCardPhase.betting1;
      // 하이카드 플레이어가 보스 (먼저 베팅)
      bettingRoundStarterIndex = _getHighCardPlayerIndex();
      currentPlayerIndex = bettingRoundStarterIndex;
      currentBetAmount = 0;  // 보스가 삥/체크 선택
    } else {
      currentPlayerIndex = nextIndex;
    }
  }

  /// 화면 배치 기준 시계 반대 방향 순서
  /// 화면 배치:
  ///    AI 1 (1)    AI 3 (3)
  ///         [POT]
  ///    AI 2 (2)    AI 4 (4)
  ///       Player (0)
  /// 시계 반대 방향: Player → AI 4 → AI 3 → AI 1 → AI 2 → Player
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
    return from; // 모두 비활성인 경우 (발생하지 않아야 함)
  }

  /// 오픈 카드 중 가장 높은 카드를 가진 플레이어 찾기 (보스)
  /// 전체 오픈 카드를 순서대로 비교 (A-A면 두번째 카드 비교)
  int _getHighCardPlayerIndex() {
    int highestIndex = 0;
    PokerHand? highestHand;
    List<PlayingCard> highestCards = [];
    bool foundFirst = false;

    for (int i = 0; i < players.length; i++) {
      final player = players[i];
      if (!player.isActive) continue;

      // 오픈 카드의 족보 평가
      final currentHand = player.openPokerHand;

      // 오픈 카드를 랭크 내림차순으로 정렬 (조커 제외) - 타이브레이커용
      final sortedCards = player.openCards
          .where((c) => !c.isJoker)
          .toList()
        ..sort((a, b) {
          // 랭크 비교 (내림차순)
          final rankCompare = b.rankValue.compareTo(a.rankValue);
          if (rankCompare != 0) return rankCompare;
          // 같은 랭크면 무늬 비교 (내림차순)
          return _getSuitValue(b.suit).compareTo(_getSuitValue(a.suit));
        });

      if (sortedCards.isEmpty) continue;

      // 첫 플레이어
      if (!foundFirst) {
        highestHand = currentHand;
        highestCards = sortedCards;
        highestIndex = i;
        foundFirst = true;
      } else {
        // 족보 비교
        if (currentHand != null && highestHand != null) {
          // 둘 다 족보 있음 - 족보로 비교
          final handCompare = currentHand.compareTo(highestHand);
          if (handCompare > 0) {
            highestHand = currentHand;
            highestCards = sortedCards;
            highestIndex = i;
          } else if (handCompare == 0) {
            // 족보가 같으면 카드로 비교 (무늬 포함)
            final cardCompare = _compareCardLists(sortedCards, highestCards);
            if (cardCompare > 0) {
              highestHand = currentHand;
              highestCards = sortedCards;
              highestIndex = i;
            }
          }
        } else if (currentHand != null && highestHand == null) {
          // 현재만 족보 있음 - 현재 플레이어가 높음
          highestHand = currentHand;
          highestCards = sortedCards;
          highestIndex = i;
        } else if (currentHand == null && highestHand == null) {
          // 둘 다 족보 없으면 카드로 비교
          final cardCompare = _compareCardLists(sortedCards, highestCards);
          if (cardCompare > 0) {
            highestCards = sortedCards;
            highestIndex = i;
          }
        }
        // currentHand == null && highestHand != null 인 경우 현재 플레이어는 패스
      }
    }

    return highestIndex;
  }

  /// 두 카드 리스트 비교 (정렬된 상태)
  /// 반환: 양수면 a가 큼, 음수면 b가 큼, 0이면 동일
  int _compareCardLists(List<PlayingCard> a, List<PlayingCard> b) {
    final maxLen = a.length > b.length ? a.length : b.length;

    for (int i = 0; i < maxLen; i++) {
      // 카드가 없으면 상대가 큼
      if (i >= a.length) return -1;
      if (i >= b.length) return 1;

      final cardA = a[i];
      final cardB = b[i];

      // 랭크 비교
      if (cardA.rankValue != cardB.rankValue) {
        return cardA.rankValue.compareTo(cardB.rankValue);
      }

      // 같은 랭크면 무늬 비교 (스페이드 > 다이아 > 하트 > 클로버)
      final suitCompare = _getSuitValue(cardA.suit).compareTo(_getSuitValue(cardB.suit));
      if (suitCompare != 0) {
        return suitCompare;
      }
    }

    return 0; // 모든 카드가 동일
  }

  /// 무늬 값 반환 (스페이드 > 다이아 > 하트 > 클로버)
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
    final callAmount = (currentBetAmount - player.currentBet).clamp(0, player.chips);
    player.chips -= callAmount;
    player.currentBet += callAmount;
    player.totalBetInGame += callAmount;
    pot += callAmount;
    player.lastAction = BettingAction.call;
    player.bettingActionsInRound++;

    if (player.chips == 0) {
      player.isAllIn = true;
    }

    _moveToNextPlayer();
  }

  /// 베팅 액션: 삥 (기본 판돈만 베팅 - 보스만 가능)
  void bing() {
    final player = currentPlayer;
    final bingAmount = basebet.clamp(0, player.chips);

    player.chips -= bingAmount;
    player.currentBet = bingAmount;
    player.totalBetInGame += bingAmount;
    pot += bingAmount;
    currentBetAmount = bingAmount;
    lastRaiserIndex = currentPlayerIndex;
    player.lastAction = BettingAction.bing;
    player.bettingActionsInRound++;

    if (player.chips == 0) {
      player.isAllIn = true;
    }

    _moveToNextPlayer();
  }

  /// 베팅 액션: 따당 (앞사람 베팅의 2배)
  void ddadang() {
    final player = currentPlayer;
    final ddadangAmount = (currentBetAmount * 2).clamp(0, player.chips);
    final additionalBet = (ddadangAmount - player.currentBet).clamp(0, player.chips);

    player.chips -= additionalBet;
    player.currentBet += additionalBet;
    player.totalBetInGame += additionalBet;
    pot += additionalBet;
    currentBetAmount = player.currentBet;
    lastRaiserIndex = currentPlayerIndex;
    player.lastAction = BettingAction.ddadang;
    player.bettingActionsInRound++;

    if (player.chips == 0) {
      player.isAllIn = true;
    }

    _moveToNextPlayer();
  }

  /// 베팅 액션: 쿼터 (전체 판돈의 25%)
  void quarter() {
    final player = currentPlayer;
    final quarterAmount = (pot * 0.25).ceil().clamp(basebet, player.chips);
    final additionalBet = (quarterAmount - player.currentBet).clamp(0, player.chips);

    player.chips -= additionalBet;
    player.currentBet += additionalBet;
    player.totalBetInGame += additionalBet;
    pot += additionalBet;
    currentBetAmount = player.currentBet;
    lastRaiserIndex = currentPlayerIndex;
    player.lastAction = BettingAction.quarter;
    player.bettingActionsInRound++;

    if (player.chips == 0) {
      player.isAllIn = true;
    }

    _moveToNextPlayer();
  }

  /// 베팅 액션: 하프 (전체 판돈의 50%)
  void half() {
    final player = currentPlayer;
    final halfAmount = (pot * 0.5).ceil().clamp(basebet, player.chips);
    final additionalBet = (halfAmount - player.currentBet).clamp(0, player.chips);

    player.chips -= additionalBet;
    player.currentBet += additionalBet;
    player.totalBetInGame += additionalBet;
    pot += additionalBet;
    currentBetAmount = player.currentBet;
    lastRaiserIndex = currentPlayerIndex;
    player.lastAction = BettingAction.half;
    player.bettingActionsInRound++;

    if (player.chips == 0) {
      player.isAllIn = true;
    }

    _moveToNextPlayer();
  }

  /// 베팅 액션: 풀 (전체 판돈의 100%)
  void full() {
    final player = currentPlayer;
    final fullAmount = pot.clamp(basebet, player.chips);
    final additionalBet = (fullAmount - player.currentBet).clamp(0, player.chips);

    player.chips -= additionalBet;
    player.currentBet += additionalBet;
    player.totalBetInGame += additionalBet;
    pot += additionalBet;
    currentBetAmount = player.currentBet;
    lastRaiserIndex = currentPlayerIndex;
    player.lastAction = BettingAction.full;
    player.bettingActionsInRound++;

    if (player.chips == 0) {
      player.isAllIn = true;
    }

    _moveToNextPlayer();
  }

  /// 베팅 액션: 폴드
  void fold() {
    currentPlayer.lastAction = BettingAction.die;
    currentPlayer.isFolded = true;

    // 남은 플레이어가 1명이면 즉시 승리
    if (activePlayerCount == 1) {
      final winner = players.firstWhere((p) => p.isActive);
      winner.chips += pot;
      winnerId = winner.id;
      phase = SevenCardPhase.gameEnd;
      return;
    }

    _moveToNextPlayer();
  }

  /// 베팅 액션: 체크 (베팅액이 같을 때)
  void check() {
    currentPlayer.lastAction = BettingAction.check;
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
    // 활성 플레이어가 1명이면 종료
    if (activePlayerCount <= 1) return true;

    // 모든 활성 플레이어가 같은 금액을 베팅했는지 확인
    final activePlayers = players.where((p) => p.isActive && !p.isAllIn).toList();
    if (activePlayers.isEmpty) return true;

    final targetBet = currentBetAmount;
    final allMatched = activePlayers.every((p) => p.currentBet == targetBet);

    // 모든 플레이어가 3회 베팅을 완료했으면 종료
    final allExhausted = activePlayers.every((p) => !p.canBet);
    if (allExhausted && allMatched) return true;

    // 모든 플레이어가 같은 금액을 베팅했을 때
    if (allMatched) {
      // 레이즈가 있었으면 레이저에게 돌아왔을 때 종료
      if (lastRaiserIndex >= 0) {
        return nextPlayer == lastRaiserIndex;
      }
      // 레이즈가 없었으면 (모두 체크/콜) 시작 플레이어에게 돌아왔을 때 종료
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
      player.lastAction = BettingAction.none;
    }
    currentBetAmount = 0;
    minRaise = basebet;
    lastRaiserIndex = -1;

    // 활성 플레이어가 1명이면 게임 종료
    if (activePlayerCount <= 1) {
      _endGame();
      return;
    }

    // 다음 단계로
    switch (phase) {
      case SevenCardPhase.betting1:
        _dealCard();
        phase = SevenCardPhase.betting2;
        break;
      case SevenCardPhase.betting2:
        _dealCard();
        phase = SevenCardPhase.betting3;
        break;
      case SevenCardPhase.betting3:
        _dealCard();
        phase = SevenCardPhase.betting4;
        break;
      case SevenCardPhase.betting4:
        phase = SevenCardPhase.showdown;
        _endGame();
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

  /// 게임 종료 및 승자 결정
  void _endGame() {
    phase = SevenCardPhase.gameEnd;

    // 활성 플레이어가 1명이면 그 플레이어 승리
    final activePlayers = players.where((p) => p.isActive).toList();
    if (activePlayers.length == 1) {
      final winner = activePlayers.first;
      winner.chips += pot;
      winnerId = winner.id;
      return;
    }

    // 쇼다운: 포커 핸드 비교
    SevenCardPlayer? winner;
    PokerHand? bestHand;

    for (final player in activePlayers) {
      final hand = player.pokerHand;
      if (hand != null) {
        if (bestHand == null || hand.compareTo(bestHand) > 0) {
          bestHand = hand;
          winner = player;
        }
      }
    }

    if (winner != null) {
      winner.chips += pot;
      winnerId = winner.id;
    }
  }

  /// 보스인지 확인 (라운드의 첫 번째 플레이어)
  bool get isCurrentPlayerBoss => lastRaiserIndex == -1 && currentBetAmount == 0;

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
      // 보스는 삥 또는 체크 가능
      actions.add('bing');
      actions.add('check');
    } else {
      // 콜
      if (player.currentBet < currentBetAmount) {
        actions.add('call');
      }
      // 따당 (2배)
      if (player.chips >= currentBetAmount * 2 - player.currentBet) {
        actions.add('ddadang');
      }
      // 쿼터 (25%)
      final quarterAmount = (pot * 0.25).ceil();
      if (quarterAmount > currentBetAmount && player.chips >= quarterAmount - player.currentBet) {
        actions.add('quarter');
      }
      // 하프 (50%)
      final halfAmount = (pot * 0.5).ceil();
      if (halfAmount > currentBetAmount && player.chips >= halfAmount - player.currentBet) {
        actions.add('half');
      }
      // 풀 (100%)
      if (pot > currentBetAmount && player.chips >= pot - player.currentBet) {
        actions.add('full');
      }
    }

    // 다이 (폴드)
    actions.add('die');

    return actions;
  }

  /// 각 베팅 액션의 금액 계산
  int getBingAmount() => basebet;
  int getCallAmount() => (currentBetAmount - currentPlayer.currentBet).clamp(0, currentPlayer.chips);
  int getDdadangAmount() => (currentBetAmount * 2 - currentPlayer.currentBet).clamp(0, currentPlayer.chips);
  int getQuarterAmount() => ((pot * 0.25).ceil() - currentPlayer.currentBet).clamp(0, currentPlayer.chips);
  int getHalfAmount() => ((pot * 0.5).ceil() - currentPlayer.currentBet).clamp(0, currentPlayer.chips);
  int getFullAmount() => (pot - currentPlayer.currentBet).clamp(0, currentPlayer.chips);
}
