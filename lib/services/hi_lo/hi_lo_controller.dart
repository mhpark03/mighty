import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../models/card.dart';
import '../../models/player.dart';
import '../../models/hi_lo/hi_lo_state.dart';
import '../../models/hi_lo/hi_lo_hand.dart';
import '../../models/seven_card/poker_hand.dart';

class HiLoController extends ChangeNotifier {
  late HiLoState _state;
  bool _isProcessing = false;
  bool _isRoundTransitioning = false;
  String _roundTransitionMessage = '';
  int _transitionCountdown = 0;
  Timer? _transitionTimer;
  HiLoPhase? _previousPhase;
  int _cardCountBeforeTransition = 0;

  HiLoController() {
    _initializePlayers();
  }

  HiLoState get state => _state;
  bool get isProcessing => _isProcessing;
  bool get isHumanTurn => _state.currentPlayerIndex == 0 && !_isProcessing && !_isRoundTransitioning;
  bool get isRoundTransitioning => _isRoundTransitioning;
  String get roundTransitionMessage => _roundTransitionMessage;
  int get transitionCountdown => _transitionCountdown;
  bool get hasActiveGame => _state.phase != HiLoPhase.waiting && _state.phase != HiLoPhase.gameEnd;
  int get cardCountBeforeTransition => _cardCountBeforeTransition;

  void _initializePlayers() {
    final players = [
      HiLoPlayer(id: 0, name: '플레이어', type: PlayerType.human),
      HiLoPlayer(id: 1, name: 'AI 1', type: PlayerType.ai),
      HiLoPlayer(id: 2, name: 'AI 2', type: PlayerType.ai),
      HiLoPlayer(id: 3, name: 'AI 3', type: PlayerType.ai),
      HiLoPlayer(id: 4, name: 'AI 4', type: PlayerType.ai),
    ];

    _state = HiLoState(players: players);
  }

  void startNewGame() {
    _state.startNewGame();
    notifyListeners();
    _processAISelectionIfNeeded();
  }

  /// 인간 플레이어가 공개 카드 선택
  void humanSelectOpenCard(int cardIndex) {
    if (_state.phase != HiLoPhase.selectOpen) return;
    if (_state.currentPlayerIndex != 0) return;

    _state.selectOpenCard(cardIndex);
    notifyListeners();
    _processAISelectionIfNeeded();
  }

  /// AI 공개 카드 선택 처리
  void _processAISelectionIfNeeded() async {
    if (_state.phase != HiLoPhase.selectOpen) {
      _processAITurnIfNeeded();
      return;
    }
    if (_state.currentPlayerIndex == 0) return;

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    final player = _state.currentPlayer;
    int bestIndex = 0;
    int bestValue = 0;
    for (int i = 0; i < player.hand.length && i < 3; i++) {
      final value = player.hand[i].rankValue;
      if (value > bestValue) {
        bestValue = value;
        bestIndex = i;
      }
    }

    _state.selectOpenCard(bestIndex);
    _isProcessing = false;
    notifyListeners();

    _processAISelectionIfNeeded();
  }

  void reset() {
    _cancelTransitionTimer();
    _initializePlayers();
    notifyListeners();
  }

  void _cancelTransitionTimer() {
    _transitionTimer?.cancel();
    _transitionTimer = null;
    _isRoundTransitioning = false;
    _transitionCountdown = 0;
  }

  void _startRoundTransition(String message) {
    _isRoundTransitioning = true;
    _roundTransitionMessage = message;
    _transitionCountdown = 5;
    notifyListeners();

    _transitionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _transitionCountdown--;
      notifyListeners();

      if (_transitionCountdown <= 0) {
        _endRoundTransition();
      }
    });
  }

  void skipTransition() {
    if (_isRoundTransitioning) {
      _endRoundTransition();
    }
  }

  void _endRoundTransition() {
    _cancelTransitionTimer();
    _isRoundTransitioning = false;
    _cardCountBeforeTransition = 0;
    notifyListeners();

    _processAITurnIfNeeded();
  }

  void _checkPhaseTransition() {
    if (_previousPhase == null) {
      _previousPhase = _state.phase;
      return;
    }

    final prevPhase = _previousPhase!;
    final currPhase = _state.phase;
    _previousPhase = currPhase;

    String? message;

    if (prevPhase == HiLoPhase.betting1 && currPhase == HiLoPhase.betting2) {
      message = '라운드 1 완료!\n5번째 카드가 배분됩니다.\n\nGOOD LUCK!';
      _cardCountBeforeTransition = 4;
    } else if (prevPhase == HiLoPhase.betting2 && currPhase == HiLoPhase.betting3) {
      message = '라운드 2 완료!\n6번째 카드가 배분됩니다.\n\nGOOD LUCK!';
      _cardCountBeforeTransition = 5;
    } else if (prevPhase == HiLoPhase.betting3 && currPhase == HiLoPhase.betting4) {
      message = '라운드 3 완료!\n마지막 7번째 카드가 배분됩니다.\n\nGOOD LUCK!';
      _cardCountBeforeTransition = 6;
    } else if (currPhase == HiLoPhase.gameEnd && prevPhase != HiLoPhase.gameEnd) {
      return;
    }

    if (message != null) {
      _startRoundTransition(message);
    }
  }

  // 플레이어 액션
  void humanBing() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    final prevPhase = _state.phase;
    _state.bing();
    notifyListeners();
    _handlePostAction(prevPhase);
  }

  void humanCall() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    final prevPhase = _state.phase;
    _state.call();
    notifyListeners();
    _handlePostAction(prevPhase);
  }

  void humanDdadang() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    final prevPhase = _state.phase;
    _state.ddadang();
    notifyListeners();
    _handlePostAction(prevPhase);
  }

  void humanQuarter() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    final prevPhase = _state.phase;
    _state.quarter();
    notifyListeners();
    _handlePostAction(prevPhase);
  }

  void humanHalf() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    final prevPhase = _state.phase;
    _state.half();
    notifyListeners();
    _handlePostAction(prevPhase);
  }

  void humanFull() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    final prevPhase = _state.phase;
    _state.full();
    notifyListeners();
    _handlePostAction(prevPhase);
  }

  void humanDie() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    final prevPhase = _state.phase;
    _state.fold();
    notifyListeners();
    _handlePostAction(prevPhase);
  }

  void humanCheck() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    final prevPhase = _state.phase;
    _state.check();
    notifyListeners();
    _handlePostAction(prevPhase);
  }

  /// 하이/로우/스윙 선택 (인간 플레이어)
  void humanSelectHiLo(HiLoChoice choice) {
    if (_state.phase != HiLoPhase.selectHiLo) return;
    if (_state.currentPlayerIndex != 0) return;

    _state.selectHiLo(choice);
    notifyListeners();
    _processAIHiLoSelectionIfNeeded();
  }

  void _handlePostAction(HiLoPhase prevPhase) {
    if (_state.phase != prevPhase) {
      _checkPhaseTransition();
      if (_isRoundTransitioning) return;
    }
    _processAITurnIfNeeded();
  }

  bool _isBettingPhase() {
    return _state.phase == HiLoPhase.betting1 ||
        _state.phase == HiLoPhase.betting2 ||
        _state.phase == HiLoPhase.betting3 ||
        _state.phase == HiLoPhase.betting4;
  }

  void _processAITurnIfNeeded() async {
    if (_isRoundTransitioning) return;

    _checkPhaseTransition();
    if (_isRoundTransitioning) return;

    // 하이/로우 선택 페이즈 처리
    if (_state.phase == HiLoPhase.selectHiLo) {
      _processAIHiLoSelectionIfNeeded();
      return;
    }

    if (!_isBettingPhase()) return;
    if (_state.currentPlayerIndex == 0) return;

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    if (_isRoundTransitioning || !_isBettingPhase()) {
      _isProcessing = false;
      notifyListeners();
      return;
    }

    final player = _state.currentPlayer;
    final action = _decideAIAction(player);

    final prevPhase = _state.phase;

    switch (action.type) {
      case 'bing':
        _state.bing();
        break;
      case 'call':
        _state.call();
        break;
      case 'ddadang':
        _state.ddadang();
        break;
      case 'quarter':
        _state.quarter();
        break;
      case 'half':
        _state.half();
        break;
      case 'full':
        _state.full();
        break;
      case 'die':
        _state.fold();
        break;
      case 'check':
        _state.check();
        break;
    }

    _isProcessing = false;
    notifyListeners();

    if (_state.phase != prevPhase) {
      _checkPhaseTransition();
      if (_isRoundTransitioning) return;
    }

    if (_isBettingPhase()) {
      _processAITurnIfNeeded();
    } else if (_state.phase == HiLoPhase.selectHiLo) {
      _processAIHiLoSelectionIfNeeded();
    }
  }

  /// AI 하이/로우/스윙 선택 처리
  void _processAIHiLoSelectionIfNeeded() async {
    if (_state.phase != HiLoPhase.selectHiLo) return;
    if (_state.currentPlayerIndex == 0) return;

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final player = _state.currentPlayer;
    final choice = _decideAIHiLoChoice(player);

    _state.selectHiLo(choice);
    _isProcessing = false;
    notifyListeners();

    // 다음 플레이어 또는 쇼다운
    if (_state.phase == HiLoPhase.selectHiLo && _state.currentPlayerIndex != 0) {
      _processAIHiLoSelectionIfNeeded();
    }
  }

  /// AI 하이/로우/스윙 결정
  HiLoChoice _decideAIHiLoChoice(HiLoPlayer player) {
    final hiHand = player.pokerHand;
    final loHand = player.lowHand;

    final hiStrength = _evaluateHandStrength(player, hiHand);
    final loStrength = HiLoHandEvaluator.calculateLowStrength(loHand);

    final random = Random();

    // 스윙 조건: 하이와 로우 둘 다 강해야 함
    if (hiStrength >= 0.65 && loStrength >= 0.7) {
      // 스윙 시도 (둘 다 매우 강함)
      if (random.nextDouble() < 0.7) {
        return HiLoChoice.swing;
      }
    }

    // 로우가 더 강하면 로우 선택
    if (loStrength >= 0.6 && loStrength > hiStrength) {
      return HiLoChoice.lo;
    }

    // 로우 자격이 있고 하이가 약하면 로우
    if (loHand != null && loHand.isQualified && hiStrength < 0.45) {
      if (loStrength >= 0.5) {
        return HiLoChoice.lo;
      }
    }

    // 기본적으로 하이 선택
    return HiLoChoice.hi;
  }

  /// AI 베팅 액션 결정 (세븐카드와 유사)
  _AIAction _decideAIAction(HiLoPlayer player) {
    final random = Random();
    final hand = player.pokerHand;
    final availableActions = _state.getAvailableActions();

    double handStrength = _evaluateHandStrength(player, hand);
    handStrength = _adjustStrengthByOpenCards(handStrength, player);

    // 보스인 경우
    if (_state.isCurrentPlayerBoss) {
      if (handStrength > 0.85 && random.nextDouble() < 0.3) {
        return _AIAction('full', 0);
      }
      if (handStrength > 0.75 && random.nextDouble() < 0.4) {
        return _AIAction('half', 0);
      }
      if (handStrength > 0.6 && random.nextDouble() < 0.5) {
        return _AIAction('quarter', 0);
      }
      if (handStrength > 0.4 || random.nextDouble() < 0.7) {
        return _AIAction('bing', 0);
      }
      return _AIAction('check', 0);
    }

    final cardsRemaining = 7 - player.hand.length;
    final drawBonus = cardsRemaining * 0.05;
    final callAmount = _state.getCallAmount();

    // 마지막 라운드
    if (cardsRemaining == 0) {
      final opponentStrength = _evaluateOpponentOpenCards();

      if (_isLosingToOpponentOpenCards(player, hand)) {
        if (callAmount > 0) {
          return _AIAction('die', 0);
        }
        return _AIAction('call', 0);
      }

      final relativeStrength = handStrength - opponentStrength;

      if (handStrength >= 0.45) {
        if (opponentStrength < 0.55) {
          return _AIAction('call', 0);
        }
        if (random.nextDouble() < 0.85) {
          return _AIAction('call', 0);
        }
      }

      if (opponentStrength < 0.3 && handStrength >= 0.15) {
        if (random.nextDouble() < 0.6) {
          return _AIAction('call', 0);
        }
      }

      if (relativeStrength > 0 && handStrength >= 0.2) {
        if (random.nextDouble() < 0.8) {
          return _AIAction('call', 0);
        }
      }

      if (handStrength < 0.25) {
        if (opponentStrength >= 0.35 && callAmount > 0) {
          return _AIAction('die', 0);
        }
        return _AIAction('call', 0);
      }
    }

    // 드로우 체크
    final strongDraw = _hasStrongDraw(player);

    final isEarlyRound = _state.phase == HiLoPhase.betting1 ||
                         _state.phase == HiLoPhase.betting2;

    if (callAmount == 0) {
      if (isEarlyRound) {
        if (handStrength >= 0.45 && random.nextDouble() < 0.70) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
        if (handStrength >= 0.35 && random.nextDouble() < 0.50) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
        if (handStrength >= 0.25 && random.nextDouble() < 0.30) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      }
      if (handStrength >= 0.60 && cardsRemaining >= 1) {
        if (handStrength < 0.70 && random.nextDouble() < 0.55) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
        if (handStrength >= 0.70 && random.nextDouble() < 0.70) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      }
      if (handStrength > 0.65 && random.nextDouble() < 0.5) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    final potOdds = callAmount / (_state.pot + callAmount + 1);
    final strongDrawBonus = strongDraw ? 0.25 : 0.0;
    final adjustedStrength = handStrength + drawBonus + strongDrawBonus;

    if (strongDraw && cardsRemaining >= 1) {
      if (random.nextDouble() < 0.85) {
        return _AIAction('call', 0);
      }
    }

    if (isEarlyRound && callAmount > 0) {
      if (handStrength >= 0.45 && random.nextDouble() < 0.60) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
      if (handStrength >= 0.35 && handStrength < 0.45 && random.nextDouble() < 0.40) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
    }

    if (handStrength >= 0.60 && cardsRemaining >= 1) {
      if (handStrength < 0.70) {
        if (random.nextDouble() < 0.6) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      } else {
        if (random.nextDouble() < 0.75) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      }
    }

    if (cardsRemaining == 0 && handStrength >= 0.68) {
      if (handStrength < 0.75) {
        if (random.nextDouble() < 0.70) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      } else {
        if (random.nextDouble() < 0.85) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      }
    }

    if (handStrength >= 0.75) {
      if (random.nextDouble() < 0.9) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    if (adjustedStrength > 0.7) {
      if (random.nextDouble() < 0.7) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    if (adjustedStrength > potOdds) {
      final callProbability = (adjustedStrength + 0.2 + drawBonus).clamp(0.0, 0.95);
      if (random.nextDouble() < callProbability) {
        return _AIAction('call', 0);
      }
      return _AIAction('die', 0);
    }

    if (cardsRemaining >= 2 && handStrength > 0.25) {
      final cheapCall = callAmount <= _state.pot * 0.3;
      if (cheapCall && random.nextDouble() < 0.5 + drawBonus) {
        return _AIAction('call', 0);
      }
    }

    if (random.nextDouble() < 0.08) {
      return _AIAction('call', 0);
    }
    return _AIAction('die', 0);
  }

  bool _hasStrongDraw(HiLoPlayer player) {
    final cards = player.hand;
    if (cards.length < 4) return false;

    final suits = <Suit, int>{};
    for (final card in cards) {
      if (card.suit != null) {
        suits[card.suit!] = (suits[card.suit!] ?? 0) + 1;
      }
    }
    if (suits.values.any((count) => count >= 4)) {
      return true;
    }

    final ranks = cards.map((c) => c.rankValue).toSet().toList()..sort();

    int maxConsecutive = 1;
    int currentConsecutive = 1;
    for (int i = 1; i < ranks.length; i++) {
      if (ranks[i] - ranks[i - 1] == 1) {
        currentConsecutive++;
        if (currentConsecutive > maxConsecutive) {
          maxConsecutive = currentConsecutive;
        }
      } else if (ranks[i] - ranks[i - 1] > 1) {
        currentConsecutive = 1;
      }
    }

    if (ranks.contains(14)) {
      final lowCards = [2, 3, 4, 5].where((r) => ranks.contains(r)).toList();
      if (lowCards.length + 1 >= 4) return true;
      final highCards = [10, 11, 12, 13].where((r) => ranks.contains(r)).toList();
      if (highCards.length + 1 >= 4) return true;
    }

    if (maxConsecutive >= 4) return true;

    if (ranks.length >= 4) {
      for (int i = 0; i <= ranks.length - 4; i++) {
        final span = ranks[i + 3] - ranks[i];
        if (span == 4) {
          return true;
        }
      }
    }

    return false;
  }

  _AIAction _selectRaiseAction(double handStrength, List<String> availableActions, Random random) {
    final opponentStrength = _evaluateOpponentOpenCards();

    if (handStrength > 0.93) {
      if (opponentStrength < 0.3) {
        if (availableActions.contains('quarter')) {
          return _AIAction('quarter', 0);
        }
        if (availableActions.contains('ddadang')) {
          return _AIAction('ddadang', 0);
        }
      }
      if (opponentStrength < 0.5 && availableActions.contains('half')) {
        return _AIAction('half', 0);
      }
      if (availableActions.contains('full')) {
        return _AIAction('full', 0);
      }
    }

    if (handStrength > 0.85 && availableActions.contains('full') && random.nextDouble() < 0.7) {
      return _AIAction('full', 0);
    }
    if (handStrength > 0.75 && availableActions.contains('half') && random.nextDouble() < 0.7) {
      return _AIAction('half', 0);
    }
    if (handStrength > 0.65 && availableActions.contains('quarter') && random.nextDouble() < 0.7) {
      return _AIAction('quarter', 0);
    }
    if (availableActions.contains('ddadang')) {
      return _AIAction('ddadang', 0);
    }
    return _AIAction('call', 0);
  }

  double _evaluateOpponentOpenCards() {
    double maxStrength = 0.0;

    for (final player in _state.players) {
      if (player.id == _state.currentPlayerIndex || player.isFolded) continue;

      final openCards = player.openCards;
      if (openCards.isEmpty) continue;

      double strength = 0.0;

      final ranks = <int, int>{};
      final suits = <Suit, int>{};
      for (final card in openCards) {
        ranks[card.rankValue] = (ranks[card.rankValue] ?? 0) + 1;
        if (card.suit != null) {
          suits[card.suit!] = (suits[card.suit!] ?? 0) + 1;
        }
      }

      final maxSameRank = ranks.values.isEmpty ? 0 : ranks.values.reduce(max);
      if (maxSameRank >= 3) {
        strength = 0.6;
      } else if (maxSameRank >= 2) {
        strength = 0.4;
      }

      final maxSameSuit = suits.values.isEmpty ? 0 : suits.values.reduce(max);
      if (maxSameSuit >= 3) {
        strength = max(strength, 0.5);
      }

      final sortedRanks = ranks.keys.toList()..sort();
      if (sortedRanks.length >= 3) {
        int consecutive = 1;
        for (int i = 1; i < sortedRanks.length; i++) {
          if (sortedRanks[i] - sortedRanks[i-1] == 1) {
            consecutive++;
          }
        }
        if (consecutive >= 3) {
          strength = max(strength, 0.45);
        }
      }

      if (strength == 0.0) {
        final highCard = ranks.keys.isEmpty ? 0 : ranks.keys.reduce(max);
        strength = 0.1 + (highCard / 14) * 0.15;
      }

      maxStrength = max(maxStrength, strength);
    }

    return maxStrength;
  }

  bool _isLosingToOpponentOpenCards(HiLoPlayer currentPlayer, PokerHand? myHand) {
    if (myHand == null) return false;

    for (final opponent in _state.players) {
      if (opponent.id == currentPlayer.id || opponent.isFolded) continue;

      final openCards = opponent.openCards;
      if (openCards.length < 3) continue;

      PokerHand? opponentOpenHand;
      if (openCards.length >= 5) {
        opponentOpenHand = PokerHandEvaluator.evaluate(openCards);
      } else {
        opponentOpenHand = PokerHandEvaluator.evaluatePartial(openCards);
      }

      if (opponentOpenHand == null) continue;

      final myRankIndex = myHand.rank.index;
      final opponentRankIndex = opponentOpenHand.rank.index;

      if (opponentRankIndex > myRankIndex) {
        return true;
      }

      if (opponentRankIndex == myRankIndex) {
        final comparison = myHand.compareTo(opponentOpenHand);
        if (comparison < 0) {
          return true;
        }
      }
    }
    return false;
  }

  double _evaluateHandStrength(HiLoPlayer player, PokerHand? hand) {
    if (hand == null) {
      return _evaluatePartialHand(player);
    }

    double baseStrength;
    switch (hand.rank) {
      case HandRank.royalStraightFlush:
        baseStrength = 1.0;
      case HandRank.backStraightFlush:
        baseStrength = 0.98;
      case HandRank.straightFlush:
        baseStrength = 0.97;
      case HandRank.fourOfAKind:
        baseStrength = 0.93;
      case HandRank.fullHouse:
        baseStrength = 0.85;
      case HandRank.flush:
        baseStrength = 0.78;
      case HandRank.mountain:
        baseStrength = 0.75;
      case HandRank.backStraight:
        baseStrength = 0.72;
      case HandRank.straight:
        baseStrength = 0.68;
      case HandRank.triple:
        baseStrength = 0.60;
      case HandRank.twoPair:
        baseStrength = 0.45;
      case HandRank.onePair:
        final pairRank = hand.tiebreakers.first;
        baseStrength = 0.25 + (pairRank / 14) * 0.15;
      case HandRank.highCard:
        final highCard = hand.tiebreakers.first;
        baseStrength = 0.10 + (highCard / 14) * 0.10;
    }

    return baseStrength;
  }

  double _evaluatePartialHand(HiLoPlayer player) {
    final cards = player.hand;
    if (cards.isEmpty) return 0.3;

    final cardsRemaining = 7 - cards.length;
    double strength = 0.2;

    final ranks = <int, int>{};
    for (final card in cards) {
      ranks[card.rankValue] = (ranks[card.rankValue] ?? 0) + 1;
    }

    final suits = <Suit, int>{};
    for (final card in cards) {
      if (card.suit != null) {
        suits[card.suit!] = (suits[card.suit!] ?? 0) + 1;
      }
    }

    final maxSameRank = ranks.values.isEmpty ? 0 : ranks.values.reduce(max);
    final maxSameSuit = suits.values.isEmpty ? 0 : suits.values.reduce(max);
    final pairCount = ranks.values.where((v) => v >= 2).length;

    if (maxSameRank == 4) {
      strength = 0.93;
    } else if (maxSameRank == 3) {
      strength = 0.55 + (cardsRemaining * 0.08);
    } else if (pairCount >= 2) {
      strength = 0.45 + (cardsRemaining * 0.05);
    } else if (maxSameRank == 2) {
      final pairRank = ranks.entries.firstWhere((e) => e.value == 2).key;
      strength = 0.30 + (pairRank / 14) * 0.10 + (cardsRemaining * 0.04);
    }

    if (maxSameSuit >= 4) {
      strength = max(strength, 0.65 + (cardsRemaining * 0.05));
    } else if (maxSameSuit >= 3 && cardsRemaining >= 2) {
      strength += 0.12;
    }

    final sortedRanks = ranks.keys.toList()..sort();
    int maxConsecutive = 1;
    int currentConsecutive = 1;
    for (int i = 1; i < sortedRanks.length; i++) {
      if (sortedRanks[i] - sortedRanks[i - 1] == 1) {
        currentConsecutive++;
        maxConsecutive = max(maxConsecutive, currentConsecutive);
      } else if (sortedRanks[i] - sortedRanks[i - 1] > 1) {
        currentConsecutive = 1;
      }
    }

    if (sortedRanks.contains(14)) {
      final lowStraight = [2, 3, 4, 5].where((r) => sortedRanks.contains(r)).length;
      final highStraight = [10, 11, 12, 13].where((r) => sortedRanks.contains(r)).length;
      maxConsecutive = max(maxConsecutive, lowStraight + 1);
      maxConsecutive = max(maxConsecutive, highStraight + 1);
    }

    if (maxConsecutive >= 4) {
      strength = max(strength, 0.55 + (cardsRemaining * 0.06));
    } else if (maxConsecutive >= 3 && cardsRemaining >= 2) {
      strength += 0.10;
    }

    final maxRank = cards.map((c) => c.rankValue).reduce(max);
    if (maxRank >= 12) {
      strength += (maxRank - 11) * 0.03;
    }

    return strength.clamp(0.0, 1.0);
  }

  double _adjustStrengthByOpenCards(double strength, HiLoPlayer player) {
    for (final opponent in _state.players) {
      if (opponent.id == player.id || !opponent.isActive) continue;

      final openCards = opponent.openCards;
      if (openCards.isEmpty) continue;

      final ranks = <int, int>{};
      for (final card in openCards) {
        ranks[card.rankValue] = (ranks[card.rankValue] ?? 0) + 1;
      }
      if (ranks.values.any((v) => v >= 2)) {
        strength -= 0.03;
      }

      final suits = <Suit?, int>{};
      for (final card in openCards) {
        suits[card.suit] = (suits[card.suit] ?? 0) + 1;
      }
      if (suits.values.any((v) => v >= 3)) {
        strength -= 0.03;
      }
    }

    return strength.clamp(0.0, 1.0);
  }

  /// 족보 이름 반환
  String getHandRankName(HandRank rank) {
    switch (rank) {
      case HandRank.royalStraightFlush:
        return '로열 스트레이트 플러시';
      case HandRank.backStraightFlush:
        return '백스트레이트 플러시';
      case HandRank.straightFlush:
        return '스트레이트 플러시';
      case HandRank.fourOfAKind:
        return '포카드';
      case HandRank.fullHouse:
        return '풀하우스';
      case HandRank.flush:
        return '플러시';
      case HandRank.mountain:
        return '마운틴';
      case HandRank.backStraight:
        return '백스트레이트';
      case HandRank.straight:
        return '스트레이트';
      case HandRank.triple:
        return '트리플';
      case HandRank.twoPair:
        return '투페어';
      case HandRank.onePair:
        return '원페어';
      case HandRank.highCard:
        return '하이카드';
    }
  }

  String getHandRankDisplayName(PokerHand? hand) {
    if (hand == null) return '';

    if (hand.rank == HandRank.highCard) {
      final highCard = hand.tiebreakers.isNotEmpty ? hand.tiebreakers.first : 0;
      return '${_getRankSymbol(highCard)}탑';
    }

    return getHandRankName(hand.rank);
  }

  String _getRankSymbol(int rankValue) {
    switch (rankValue) {
      case 14: return 'A';
      case 13: return 'K';
      case 12: return 'Q';
      case 11: return 'J';
      case 10: return '10';
      default: return '$rankValue';
    }
  }

  /// 로우 핸드 표시명
  String getLowHandDisplayName(LowHand? hand) {
    if (hand == null || !hand.isQualified) return 'No Low';
    return hand.name;
  }
}

class _AIAction {
  final String type;
  final int amount;

  _AIAction(this.type, this.amount);
}
