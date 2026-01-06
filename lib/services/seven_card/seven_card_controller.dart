import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../../models/card.dart';
import '../../models/player.dart';
import '../../models/seven_card/seven_card_state.dart';
import '../../models/seven_card/poker_hand.dart';

class SevenCardController extends ChangeNotifier {
  late SevenCardState _state;
  bool _isProcessing = false;

  SevenCardController() {
    _initializePlayers();
  }

  SevenCardState get state => _state;
  bool get isProcessing => _isProcessing;
  bool get isHumanTurn => _state.currentPlayerIndex == 0 && !_isProcessing;

  void _initializePlayers() {
    final players = [
      SevenCardPlayer(id: 0, name: '플레이어', type: PlayerType.human),
      SevenCardPlayer(id: 1, name: 'AI 1', type: PlayerType.ai),
      SevenCardPlayer(id: 2, name: 'AI 2', type: PlayerType.ai),
      SevenCardPlayer(id: 3, name: 'AI 3', type: PlayerType.ai),
      SevenCardPlayer(id: 4, name: 'AI 4', type: PlayerType.ai),
    ];

    _state = SevenCardState(players: players);
  }

  void startNewGame() {
    _state.startNewGame();
    notifyListeners();
    _processAISelectionIfNeeded();
  }

  /// 인간 플레이어가 공개 카드 선택
  void humanSelectOpenCard(int cardIndex) {
    if (_state.phase != SevenCardPhase.selectOpen) return;
    if (_state.currentPlayerIndex != 0) return;

    _state.selectOpenCard(cardIndex);
    notifyListeners();
    _processAISelectionIfNeeded();
  }

  /// AI 공개 카드 선택 처리
  void _processAISelectionIfNeeded() async {
    if (_state.phase != SevenCardPhase.selectOpen) {
      // 선택 완료 후 베팅 단계로 넘어갔으면 AI 턴 처리
      _processAITurnIfNeeded();
      return;
    }
    if (_state.currentPlayerIndex == 0) return; // 인간 차례

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 500));

    // AI가 공개할 카드 선택 (가장 높은 카드를 공개 - 위협용)
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

    // 계속 처리
    _processAISelectionIfNeeded();
  }

  void reset() {
    _initializePlayers();
    notifyListeners();
  }

  // 플레이어 액션
  void humanBing() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    _state.bing();
    notifyListeners();
    _processAITurnIfNeeded();
  }

  void humanCall() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    _state.call();
    notifyListeners();
    _processAITurnIfNeeded();
  }

  void humanDdadang() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    _state.ddadang();
    notifyListeners();
    _processAITurnIfNeeded();
  }

  void humanQuarter() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    _state.quarter();
    notifyListeners();
    _processAITurnIfNeeded();
  }

  void humanHalf() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    _state.half();
    notifyListeners();
    _processAITurnIfNeeded();
  }

  void humanFull() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    _state.full();
    notifyListeners();
    _processAITurnIfNeeded();
  }

  void humanDie() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    _state.fold();
    notifyListeners();
    _processAITurnIfNeeded();
  }

  void humanCheck() {
    if (!isHumanTurn) return;
    if (!_isBettingPhase()) return;

    _state.check();
    notifyListeners();
    _processAITurnIfNeeded();
  }

  bool _isBettingPhase() {
    return _state.phase == SevenCardPhase.betting1 ||
        _state.phase == SevenCardPhase.betting2 ||
        _state.phase == SevenCardPhase.betting3 ||
        _state.phase == SevenCardPhase.betting4;
  }

  void _processAITurnIfNeeded() async {
    if (!_isBettingPhase()) return;
    if (_state.currentPlayerIndex == 0) return;

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final player = _state.currentPlayer;
    final action = _decideAIAction(player);

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

    // 게임이 아직 진행 중이면 계속
    if (_isBettingPhase()) {
      _processAITurnIfNeeded();
    }
  }

  /// AI 액션 결정
  _AIAction _decideAIAction(SevenCardPlayer player) {
    final random = Random();
    final hand = player.pokerHand;
    final availableActions = _state.getAvailableActions();

    // 핸드 강도 평가 (0.0 ~ 1.0)
    double handStrength = _evaluateHandStrength(player, hand);

    // 오픈 카드 기반 추가 평가
    handStrength = _adjustStrengthByOpenCards(handStrength, player);

    // 보스인 경우 (삥/체크 선택)
    if (_state.isCurrentPlayerBoss) {
      if (handStrength > 0.4 || random.nextDouble() < 0.7) {
        return _AIAction('bing', 0);
      }
      return _AIAction('check', 0);
    }

    // 콜 금액이 없으면 (이미 맞춤)
    final callAmount = _state.getCallAmount();
    if (callAmount == 0) {
      // 레이즈 고려
      if (handStrength > 0.7 && random.nextDouble() < 0.5) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    // 팟 오즈 계산
    final potOdds = callAmount / (_state.pot + callAmount + 1);

    // 강한 핸드 (레이즈 고려)
    if (handStrength > 0.7) {
      if (random.nextDouble() < 0.6) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    // 중간 핸드 (콜 또는 폴드)
    if (handStrength > potOdds) {
      if (random.nextDouble() < handStrength + 0.2) {
        return _AIAction('call', 0);
      }
      return _AIAction('die', 0);
    }

    // 약한 핸드
    // 블러프 확률
    if (random.nextDouble() < 0.08) {
      return _AIAction('call', 0);
    }
    return _AIAction('die', 0);
  }

  /// 레이즈 액션 선택 (따당/쿼터/하프/풀)
  _AIAction _selectRaiseAction(double handStrength, List<String> availableActions, Random random) {
    // 매우 강한 핸드
    if (handStrength > 0.9 && availableActions.contains('full') && random.nextDouble() < 0.4) {
      return _AIAction('full', 0);
    }
    // 강한 핸드
    if (handStrength > 0.8 && availableActions.contains('half') && random.nextDouble() < 0.5) {
      return _AIAction('half', 0);
    }
    // 중상 핸드
    if (handStrength > 0.7 && availableActions.contains('quarter') && random.nextDouble() < 0.6) {
      return _AIAction('quarter', 0);
    }
    // 기본 레이즈
    if (availableActions.contains('ddadang')) {
      return _AIAction('ddadang', 0);
    }
    return _AIAction('call', 0);
  }

  /// 핸드 강도 평가
  double _evaluateHandStrength(SevenCardPlayer player, PokerHand? hand) {
    if (hand == null) {
      // 5장 미만일 때 예상 강도
      return _evaluatePartialHand(player);
    }

    // 족보별 기본 강도
    switch (hand.rank) {
      case HandRank.royalStraightFlush:
        return 1.0;
      case HandRank.backStraightFlush:
        return 0.98;
      case HandRank.straightFlush:
        return 0.96;
      case HandRank.fourOfAKind:
        return 0.93;
      case HandRank.fullHouse:
        return 0.85;
      case HandRank.flush:
        return 0.75;
      case HandRank.mountain:
        return 0.72;
      case HandRank.backStraight:
        return 0.65;
      case HandRank.straight:
        return 0.68;
      case HandRank.triple:
        return 0.55;
      case HandRank.twoPair:
        return 0.40;
      case HandRank.onePair:
        // 페어 랭크에 따라 조정
        final pairRank = hand.tiebreakers.first;
        return 0.20 + (pairRank / 14) * 0.15;
      case HandRank.highCard:
        final highCard = hand.tiebreakers.first;
        return 0.05 + (highCard / 14) * 0.10;
    }
  }

  /// 부분 핸드 평가 (5장 미만)
  double _evaluatePartialHand(SevenCardPlayer player) {
    final cards = player.hand;
    if (cards.isEmpty) return 0.3;

    double strength = 0.3;

    // 페어 체크
    final ranks = <int, int>{};
    for (final card in cards) {
      ranks[card.rankValue] = (ranks[card.rankValue] ?? 0) + 1;
    }

    if (ranks.values.any((v) => v >= 3)) {
      strength = 0.6; // 트리플
    } else if (ranks.values.any((v) => v >= 2)) {
      strength = 0.4; // 페어
    }

    // 플러시 드로우 체크
    final suits = <Suit, int>{};
    for (final card in cards) {
      if (card.suit != null) {
        suits[card.suit!] = (suits[card.suit!] ?? 0) + 1;
      }
    }
    if (suits.values.any((v) => v >= 3)) {
      strength += 0.1; // 플러시 드로우
    }

    // 스트레이트 드로우 체크
    final sortedRanks = ranks.keys.toList()..sort();
    int consecutive = 1;
    for (int i = 1; i < sortedRanks.length; i++) {
      if (sortedRanks[i] - sortedRanks[i - 1] == 1) {
        consecutive++;
      }
    }
    if (consecutive >= 3) {
      strength += 0.1; // 스트레이트 드로우
    }

    // 하이카드 보너스
    final maxRank = cards.map((c) => c.rankValue).reduce(max);
    strength += (maxRank - 10) * 0.02;

    return strength.clamp(0.0, 1.0);
  }

  /// 오픈 카드 기반 강도 조정
  double _adjustStrengthByOpenCards(double strength, SevenCardPlayer player) {
    // 상대 오픈 카드 분석
    for (final opponent in _state.players) {
      if (opponent.id == player.id || !opponent.isActive) continue;

      final openCards = opponent.openCards;
      if (openCards.isEmpty) continue;

      // 상대가 페어를 보여주면 경계
      final ranks = <int, int>{};
      for (final card in openCards) {
        ranks[card.rankValue] = (ranks[card.rankValue] ?? 0) + 1;
      }
      if (ranks.values.any((v) => v >= 2)) {
        strength -= 0.1;
      }

      // 상대가 플러시 드로우를 보여주면 경계
      final suits = <Suit?, int>{};
      for (final card in openCards) {
        suits[card.suit] = (suits[card.suit] ?? 0) + 1;
      }
      if (suits.values.any((v) => v >= 3)) {
        strength -= 0.1;
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

  /// 족보 이름 반환 (하이카드는 "X탑"으로 표시)
  String getHandRankDisplayName(PokerHand? hand) {
    if (hand == null) return '';

    if (hand.rank == HandRank.highCard) {
      final highCard = hand.tiebreakers.isNotEmpty ? hand.tiebreakers.first : 0;
      return '${_getRankSymbol(highCard)}탑';
    }

    return getHandRankName(hand.rank);
  }

  /// 숫자를 카드 심볼로 변환
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
}

class _AIAction {
  final String type;
  final int amount;

  _AIAction(this.type, this.amount);
}
