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

  /// 쇼다운에서 결과 화면으로 이동
  void proceedToGameEnd() {
    _state.proceedToGameEnd();
    notifyListeners();
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

  /// AI 베팅 액션 결정 (하이로우 게임 - 상대 로우 잠재력 고려)
  _AIAction _decideAIAction(HiLoPlayer player) {
    final random = Random();
    final hand = player.pokerHand;
    final availableActions = _state.getAvailableActions();

    double handStrength = _evaluateHandStrength(player, hand);
    handStrength = _adjustStrengthByOpenCards(handStrength, player);

    // 하이로우 게임: 로우 핸드 잠재력도 고려
    final lowPotential = _evaluateLowPotential(player);
    final cardsRemaining = 7 - player.hand.length;
    // 초반에는 로우 드로우 기준을 낮춤 (3장 이상 남았으면 0.4, 그 외 0.5)
    final lowDrawThreshold = cardsRemaining >= 3 ? 0.4 : 0.5;
    final hasStrongLowDraw = lowPotential >= lowDrawThreshold;

    // 완성된 로우 핸드 강도 평가 (확률 기반)
    final lowHandStrength = _evaluateCompletedLowStrength(player);
    final hasCompletedLow = lowHandStrength > 0;

    // 상대 로우 잠재력 평가 (오픈 카드 기반)
    final opponentLowPotential = _evaluateOpponentLowPotential();
    final relativeLowStrength = _evaluateRelativeLowStrength(player);

    // 하이로우: 하이 또는 로우 중 더 강한 것 기준으로 베팅
    final effectiveStrength = hasCompletedLow
        ? (handStrength > lowHandStrength ? handStrength : lowHandStrength)
        : handStrength;

    // 보스인 경우
    if (_state.isCurrentPlayerBoss) {
      // 로우 핸드 베팅: 상대 로우 잠재력 고려
      if (hasCompletedLow) {
        // 상대가 강한 로우 잠재력을 보이면 베팅 축소
        final lowBetModifier = opponentLowPotential >= 0.7 ? 0.5 :
                               opponentLowPotential >= 0.5 ? 0.7 : 1.0;

        // 6탑 로우: 포카드급 (0.93)
        if (lowHandStrength >= 0.92) {
          if (relativeLowStrength > 0.3) {
            // 상대보다 명확히 우위
            if (random.nextDouble() < 0.4 * lowBetModifier) {
              return _AIAction('full', 0);
            }
            return _AIAction('half', 0);
          } else {
            // 상대와 비슷하거나 불확실
            if (random.nextDouble() < 0.3) {
              return _AIAction('quarter', 0);
            }
            return _AIAction('bing', 0);
          }
        }
        // 7탑 로우: 포카드~풀하우스급 (0.88)
        if (lowHandStrength >= 0.87) {
          if (relativeLowStrength > 0.2) {
            if (random.nextDouble() < 0.35 * lowBetModifier) {
              return _AIAction('half', 0);
            }
            return _AIAction('quarter', 0);
          } else {
            return _AIAction('bing', 0);
          }
        }
        // 8탑 로우: 풀하우스급 (0.85)
        if (lowHandStrength >= 0.84) {
          if (relativeLowStrength > 0.1) {
            if (random.nextDouble() < 0.4 * lowBetModifier) {
              return _AIAction('quarter', 0);
            }
            return _AIAction('bing', 0);
          } else {
            return _AIAction('call', 0);
          }
        }
        // 9탑 로우: 플러시~스트레이트급 (0.72)
        if (lowHandStrength >= 0.70) {
          if (relativeLowStrength > 0) {
            if (random.nextDouble() < 0.5 * lowBetModifier) {
              return _AIAction('bing', 0);
            }
          }
          return _AIAction('call', 0);
        }
      }

      // 하이 핸드가 스트레이트 이상 (0.68+): 하프 이상 베팅
      final opponentStrength = _evaluateOpponentOpenCards();
      if (effectiveStrength >= 0.68) {
        // 상대가 매우 강해 보이면 쿼터 (방어적)
        if (opponentStrength >= 0.6) {
          if (random.nextDouble() < 0.6) {
            return _AIAction('quarter', 0);
          }
          return _AIAction('half', 0);
        }
        // 포카드 이상 (0.93+): 풀 또는 하프
        if (effectiveStrength >= 0.93) {
          if (random.nextDouble() < 0.6) return _AIAction('full', 0);
          return _AIAction('half', 0);
        }
        // 풀하우스 (0.85+): 하프 또는 풀
        if (effectiveStrength >= 0.85) {
          if (random.nextDouble() < 0.5) return _AIAction('full', 0);
          return _AIAction('half', 0);
        }
        // 플러시/마운틴/백스트 (0.72~0.84): 하프 또는 쿼터
        if (effectiveStrength >= 0.72) {
          if (random.nextDouble() < 0.6) return _AIAction('half', 0);
          return _AIAction('quarter', 0);
        }
        // 스트레이트 (0.68~0.71): 하프 또는 쿼터
        if (random.nextDouble() < 0.5) return _AIAction('half', 0);
        return _AIAction('quarter', 0);
      }

      if (effectiveStrength > 0.55 && random.nextDouble() < 0.5) {
        return _AIAction('quarter', 0);
      }
      if (effectiveStrength > 0.4 || random.nextDouble() < 0.7) {
        return _AIAction('bing', 0);
      }
      return _AIAction('check', 0);
    }

    final drawBonus = cardsRemaining * 0.05;
    final callAmount = _state.getCallAmount();

    // 비보스이면서 강한 로우 핸드가 있으면 공격적으로 레이즈
    // 단, 상대 로우 잠재력 고려
    if (!_state.isCurrentPlayerBoss && hasCompletedLow) {
      // 상대가 강한 로우 잠재력을 보이면 레이즈 확률 축소
      final raiseModifier = opponentLowPotential >= 0.7 ? 0.4 :
                            opponentLowPotential >= 0.5 ? 0.6 : 1.0;

      // 6탑 로우: 포카드급 (0.93)
      if (lowHandStrength >= 0.92 && relativeLowStrength > 0.2) {
        if (random.nextDouble() < 0.4 * raiseModifier) {
          return _selectRaiseAction(lowHandStrength, availableActions, random);
        }
        return _AIAction('call', 0);
      }
      // 7탑 로우: 포카드~풀하우스급 (0.88)
      if (lowHandStrength >= 0.87 && relativeLowStrength > 0.1) {
        if (random.nextDouble() < 0.35 * raiseModifier) {
          return _selectRaiseAction(lowHandStrength, availableActions, random);
        }
        return _AIAction('call', 0);
      }
      // 8탑 로우: 풀하우스급 (0.85)
      if (lowHandStrength >= 0.84 && relativeLowStrength > 0) {
        if (random.nextDouble() < 0.3 * raiseModifier) {
          return _selectRaiseAction(lowHandStrength, availableActions, random);
        }
        return _AIAction('call', 0);
      }
      // 9탑 로우: 플러시~스트레이트급 (0.72) - 상대 로우가 약할 때만
      if (lowHandStrength >= 0.70 && relativeLowStrength > 0.1) {
        if (random.nextDouble() < 0.25 * raiseModifier) {
          return _selectRaiseAction(lowHandStrength, availableActions, random);
        }
        return _AIAction('call', 0);
      }
      // 로우 핸드가 있지만 상대가 더 강해 보이면 콜만
      if (hasCompletedLow && relativeLowStrength <= 0) {
        return _AIAction('call', 0);
      }
    }

    // 마지막 라운드
    if (cardsRemaining == 0) {
      final opponentStrength = _evaluateOpponentOpenCards();

      // 하이로우: 로우 핸드가 강하면 계속 진행 (상대 로우와 비교)
      final currentLowHand = player.lowHand;
      final hasGoodLow = currentLowHand != null && currentLowHand.isQualified;

      if (_isLosingToOpponentOpenCards(player, hand)) {
        // 하이에서 지고 있지만 로우가 좋으면 상대 로우 잠재력 확인
        if (hasGoodLow) {
          // 상대 로우가 약하면 콜, 강하면 신중하게
          if (relativeLowStrength > 0) {
            return _AIAction('call', 0);
          } else if (relativeLowStrength > -0.3) {
            // 로우에서도 약간 밀리지만 가능성 있음
            if (random.nextDouble() < 0.6) {
              return _AIAction('call', 0);
            }
          }
          // 로우에서도 크게 밀리면 폴드 고려
          if (callAmount > 0 && opponentLowPotential >= 0.7) {
            return _AIAction('die', 0);
          }
          return _AIAction('call', 0);
        }
        if (callAmount > 0) {
          return _AIAction('die', 0);
        }
        return _AIAction('call', 0);
      }

      final relativeHiStrength = handStrength - opponentStrength;

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

      if (relativeHiStrength > 0 && handStrength >= 0.2) {
        if (random.nextDouble() < 0.8) {
          return _AIAction('call', 0);
        }
      }

      if (handStrength < 0.25) {
        // 로우가 좋고 상대 로우보다 우위면 계속 진행
        if (hasGoodLow && relativeLowStrength > 0) {
          return _AIAction('call', 0);
        }
        // 로우가 있지만 상대 로우가 더 강해 보이면 신중하게
        if (hasGoodLow && relativeLowStrength > -0.2) {
          if (random.nextDouble() < 0.5) {
            return _AIAction('call', 0);
          }
        }
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
        if (effectiveStrength >= 0.45 && random.nextDouble() < 0.70) {
          return _selectRaiseAction(effectiveStrength, availableActions, random);
        }
        if (effectiveStrength >= 0.35 && random.nextDouble() < 0.50) {
          return _selectRaiseAction(effectiveStrength, availableActions, random);
        }
        if (effectiveStrength >= 0.25 && random.nextDouble() < 0.30) {
          return _selectRaiseAction(effectiveStrength, availableActions, random);
        }
      }
      if (effectiveStrength >= 0.60 && cardsRemaining >= 1) {
        if (effectiveStrength < 0.70 && random.nextDouble() < 0.55) {
          return _selectRaiseAction(effectiveStrength, availableActions, random);
        }
        if (effectiveStrength >= 0.70 && random.nextDouble() < 0.70) {
          return _selectRaiseAction(effectiveStrength, availableActions, random);
        }
      }
      if (effectiveStrength > 0.65 && random.nextDouble() < 0.5) {
        return _selectRaiseAction(effectiveStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    final potOdds = callAmount / (_state.pot + callAmount + 1);
    final strongDrawBonus = strongDraw ? 0.25 : 0.0;
    // 하이로우: 로우 잠재력 보너스 추가 (로우로 팟의 절반을 노릴 수 있음)
    final lowDrawBonus = hasStrongLowDraw ? (lowPotential * 0.3) : 0.0;
    final adjustedStrength = handStrength + drawBonus + strongDrawBonus + lowDrawBonus;

    // 강한 드로우가 있으면 콜
    if (strongDraw && cardsRemaining >= 1) {
      if (random.nextDouble() < 0.85) {
        return _AIAction('call', 0);
      }
    }

    // 하이로우: 강한 로우 드로우가 있으면 콜
    if (hasStrongLowDraw && cardsRemaining >= 1) {
      if (random.nextDouble() < 0.85) {
        return _AIAction('call', 0);
      }
    }

    if (isEarlyRound && callAmount > 0) {
      if (effectiveStrength >= 0.45 && random.nextDouble() < 0.60) {
        return _selectRaiseAction(effectiveStrength, availableActions, random);
      }
      if (effectiveStrength >= 0.35 && effectiveStrength < 0.45 && random.nextDouble() < 0.40) {
        return _selectRaiseAction(effectiveStrength, availableActions, random);
      }
    }

    if (effectiveStrength >= 0.60 && cardsRemaining >= 1) {
      if (effectiveStrength < 0.70) {
        if (random.nextDouble() < 0.6) {
          return _selectRaiseAction(effectiveStrength, availableActions, random);
        }
      } else {
        if (random.nextDouble() < 0.75) {
          return _selectRaiseAction(effectiveStrength, availableActions, random);
        }
      }
    }

    if (cardsRemaining == 0 && effectiveStrength >= 0.68) {
      if (effectiveStrength < 0.75) {
        if (random.nextDouble() < 0.70) {
          return _selectRaiseAction(effectiveStrength, availableActions, random);
        }
      } else {
        if (random.nextDouble() < 0.85) {
          return _selectRaiseAction(effectiveStrength, availableActions, random);
        }
      }
    }

    if (effectiveStrength >= 0.75) {
      if (random.nextDouble() < 0.9) {
        return _selectRaiseAction(effectiveStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    if (adjustedStrength > 0.7) {
      if (random.nextDouble() < 0.7) {
        return _selectRaiseAction(effectiveStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    if (adjustedStrength > potOdds) {
      final callProbability = (adjustedStrength + 0.2 + drawBonus + lowDrawBonus).clamp(0.0, 0.95);
      if (random.nextDouble() < callProbability) {
        return _AIAction('call', 0);
      }
      // 로우 드로우가 강하면 폴드하지 않음
      if (hasStrongLowDraw) {
        return _AIAction('call', 0);
      }
      return _AIAction('die', 0);
    }

    if (cardsRemaining >= 2 && handStrength > 0.25) {
      final cheapCall = callAmount <= _state.pot * 0.3;
      if (cheapCall && random.nextDouble() < 0.5 + drawBonus + lowDrawBonus) {
        return _AIAction('call', 0);
      }
    }

    // 하이로우: 로우 잠재력이 높으면 폴드하지 않고 콜
    if (hasStrongLowDraw && cardsRemaining >= 1) {
      return _AIAction('call', 0);
    }

    // 초반 라운드 (3장 이상 남음)에서는 로우 잠재력만으로도 적극적으로 콜
    if (cardsRemaining >= 3) {
      // 로우 잠재력이 조금이라도 있으면 콜 (3, 4 같은 로우 카드 2장)
      if (lowPotential >= 0.3) {
        return _AIAction('call', 0);  // 확정적으로 콜
      }
      // 로우 카드 1장이라도 있으면 높은 확률로 콜
      if (lowPotential >= 0.2 && random.nextDouble() < 0.7) {
        return _AIAction('call', 0);
      }
    }

    // 중반 라운드 (2장 남음)에서도 로우 잠재력 있으면 콜
    if (lowPotential >= 0.35 && cardsRemaining >= 2) {
      if (random.nextDouble() < 0.75) {
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

  /// 로우 핸드 잠재력 평가 (하이로우 게임 전용)
  /// 0.0 ~ 1.0 반환 (높을수록 로우 가능성이 높음)
  double _evaluateLowPotential(HiLoPlayer player) {
    final cards = player.hand;
    if (cards.isEmpty) return 0.0;

    // 로우 카드 (A=1, 2~7) 개수 세기
    // A는 로우에서 1로 사용됨
    final lowRanks = <int>[];
    for (final card in cards) {
      if (card.rank == Rank.ace) {
        lowRanks.add(1); // A = 1
      } else {
        final rankValue = card.rankValue;
        if (rankValue >= 2 && rankValue <= 7) {
          lowRanks.add(rankValue);
        }
      }
    }

    // 중복 제거 (페어가 있으면 로우에서 불리)
    final uniqueLowRanks = lowRanks.toSet();
    final lowCardCount = uniqueLowRanks.length;

    // 카드 수에 따른 기대치 계산
    final cardsRemaining = 7 - cards.length;

    // 이미 5장 이상의 유니크 로우 카드가 있으면 매우 좋음
    if (lowCardCount >= 5) {
      // 가장 높은 카드 확인 (낮을수록 좋음)
      final sortedLow = uniqueLowRanks.toList()..sort();
      final highCard = sortedLow.take(5).last;
      if (highCard <= 6) return 1.0;  // 6-high 이하 = 최강급
      if (highCard == 7) return 0.9;  // 7-high = 매우 좋음
      return 0.75;
    }

    // 4장의 유니크 로우 카드 + 남은 카드가 있음
    if (lowCardCount >= 4 && cardsRemaining >= 1) {
      return 0.7;
    }

    // 3장의 유니크 로우 카드 + 남은 카드 2장 이상
    if (lowCardCount >= 3 && cardsRemaining >= 2) {
      // A가 있으면 더 좋음
      if (uniqueLowRanks.contains(1)) return 0.6;
      return 0.5;
    }

    // 2장의 유니크 로우 카드 + 초반 (카드 3장 이상 남음)
    if (lowCardCount >= 2 && cardsRemaining >= 3) {
      // 연속된 로우 카드 (예: 3,4 또는 2,3)는 더 가치 있음
      final sortedLow = uniqueLowRanks.toList()..sort();
      bool hasConsecutive = false;
      for (int i = 0; i < sortedLow.length - 1; i++) {
        if (sortedLow[i + 1] - sortedLow[i] == 1) {
          hasConsecutive = true;
          break;
        }
      }

      if (uniqueLowRanks.contains(1)) {
        // A가 있으면 로우에서 매우 유리
        return hasConsecutive ? 0.55 : 0.45;
      }
      // A 없이 2개의 로우 카드
      return hasConsecutive ? 0.45 : 0.35;
    }

    // 로우 카드가 적음
    if (lowCardCount >= 1 && cardsRemaining >= 4) {
      if (uniqueLowRanks.contains(1)) return 0.3;
      return 0.2;
    }

    return 0.0;
  }

  /// 완성된 로우 핸드 강도 평가 (확률 기반)
  /// 6탑 (~0.4%) = 포카드급 0.93
  /// 7탑 (~0.8%) = 포카드~풀하우스 0.88
  /// 8탑 (~2.0%) = 풀하우스급 0.85
  /// 9탑 (~4.5%) = 플러시~스트레이트 0.72
  /// 10탑 (~8%) = 트리플급 0.60
  /// J탑 (~10%) = 트리플~투페어 0.50
  double _evaluateCompletedLowStrength(HiLoPlayer player) {
    final lowHand = player.lowHand;
    if (lowHand == null || !lowHand.isQualified) return 0.0;

    // lowHand.cardRanks는 정렬된 상태, 마지막이 가장 높은 카드
    if (lowHand.cardRanks.isEmpty) return 0.0;

    final highCard = lowHand.cardRanks.last;

    // 6탑: A-2-3-4-6 (최강 로우) = 포카드급 (~0.4%)
    if (highCard <= 6) return 0.93;

    // 7탑: A-2-3-4-7 등 = 포카드~풀하우스급 (~0.8%)
    if (highCard == 7) return 0.88;

    // 8탑: A-2-3-4-8 등 = 풀하우스급 (~2.0%)
    if (highCard == 8) return 0.85;

    // 9탑: A-2-3-4-9 등 = 플러시~스트레이트급 (~4.5%)
    if (highCard == 9) return 0.72;

    // 10탑: 트리플급 (~8%)
    if (highCard == 10) return 0.60;

    // J탑: 트리플~투페어급 (~10%)
    if (highCard == 11) return 0.50;

    // Q탑 이상: 투페어급 이하
    if (highCard >= 12) return 0.40;

    return 0.3;
  }

  _AIAction _selectRaiseAction(double handStrength, List<String> availableActions, Random random) {
    final opponentStrength = _evaluateOpponentOpenCards();

    // 스트레이트 이상 (0.68+): 하프 이상 베팅 (상대가 매우 강하면 쿼터)
    if (handStrength >= 0.68) {
      // 상대가 매우 강해 보이면 쿼터 (방어적)
      if (opponentStrength >= 0.6) {
        if (availableActions.contains('quarter')) {
          if (random.nextDouble() < 0.6) {
            return _AIAction('quarter', 0);
          }
        }
        if (availableActions.contains('half')) {
          return _AIAction('half', 0);
        }
      }

      // 최강 핸드 (로열/스플/포카드: 0.93+)
      if (handStrength >= 0.93) {
        // 상대가 약해 보이면 슬로우 플레이 (하프로 유인)
        if (opponentStrength < 0.3 && availableActions.contains('half')) {
          return _AIAction('half', 0);
        }
        // 상대가 중간 이상이면 풀 베팅
        if (availableActions.contains('full')) {
          if (random.nextDouble() < 0.6) return _AIAction('full', 0);
        }
        if (availableActions.contains('half')) {
          return _AIAction('half', 0);
        }
      }

      // 풀하우스 (0.85+): 풀 또는 하프
      if (handStrength >= 0.85) {
        if (availableActions.contains('full') && random.nextDouble() < 0.5) {
          return _AIAction('full', 0);
        }
        if (availableActions.contains('half')) {
          return _AIAction('half', 0);
        }
      }

      // 플러시/마운틴/백스트레이트 (0.72~0.84): 하프 또는 쿼터
      if (handStrength >= 0.72) {
        if (availableActions.contains('half') && random.nextDouble() < 0.6) {
          return _AIAction('half', 0);
        }
        if (availableActions.contains('quarter')) {
          return _AIAction('quarter', 0);
        }
      }

      // 스트레이트 (0.68~0.71): 하프 또는 쿼터
      if (availableActions.contains('half') && random.nextDouble() < 0.5) {
        return _AIAction('half', 0);
      }
      if (availableActions.contains('quarter')) {
        return _AIAction('quarter', 0);
      }
    }

    // 트리플 (0.55~0.67): 쿼터 또는 따당
    if (handStrength >= 0.55 && availableActions.contains('quarter') && random.nextDouble() < 0.5) {
      return _AIAction('quarter', 0);
    }

    // 기본 레이즈: 따당
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

  /// 모든 보이는 카드(내 카드 + 모든 오픈 카드) 수집
  /// 상대방이 가질 수 없는 "데드 카드" 목록
  Set<String> _collectDeadCards(HiLoPlayer currentPlayer) {
    final deadCards = <String>{};

    // 1. 내 모든 카드 (히든 + 오픈)
    for (final card in currentPlayer.hand) {
      if (card.suit != null && card.rank != null) {
        deadCards.add('${card.suit!.name}_${card.rank!.name}');
      }
    }

    // 2. 모든 플레이어의 오픈 카드 (다이한 플레이어 포함)
    for (final player in _state.players) {
      if (player.id == currentPlayer.id) continue;
      for (final card in player.openCards) {
        if (card.suit != null && card.rank != null) {
          deadCards.add('${card.suit!.name}_${card.rank!.name}');
        }
      }
    }

    return deadCards;
  }

  /// 특정 랭크의 남은 카드 수 계산 (4장 중 데드 카드 제외)
  int _countRemainingCards(int rankValue, Set<String> deadCards) {
    final rankName = _getRankNameFromValue(rankValue);
    int remaining = 4;  // 각 랭크당 4장 (스페이드, 하트, 다이아, 클럽)

    for (final suitName in ['spade', 'heart', 'diamond', 'club']) {
      if (deadCards.contains('${suitName}_$rankName')) {
        remaining--;
      }
    }

    return remaining;
  }

  String _getRankNameFromValue(int value) {
    switch (value) {
      case 1: return 'ace';
      case 2: return 'two';
      case 3: return 'three';
      case 4: return 'four';
      case 5: return 'five';
      case 6: return 'six';
      case 7: return 'seven';
      case 8: return 'eight';
      case 9: return 'nine';
      case 10: return 'ten';
      case 11: return 'jack';
      case 12: return 'queen';
      case 13: return 'king';
      case 14: return 'ace';
      default: return '';
    }
  }

  /// 상대방 오픈 카드 기반 로우 잠재력 평가
  /// 내 카드 + 모든 오픈 카드(데드 카드)를 고려하여 계산
  double _evaluateOpponentLowPotential() {
    final currentPlayer = _state.players[_state.currentPlayerIndex];
    final deadCards = _collectDeadCards(currentPlayer);

    double maxLowStrength = 0.0;

    for (final player in _state.players) {
      if (player.id == _state.currentPlayerIndex || player.isFolded) continue;

      final openCards = player.openCards;
      if (openCards.isEmpty) continue;

      // 로우 카드 (A=1, 2~8) 분석
      final lowRanks = <int>{};
      bool hasPair = false;
      final rankCounts = <int, int>{};

      for (final card in openCards) {
        final rankValue = card.rank == Rank.ace ? 1 : card.rankValue;
        rankCounts[rankValue] = (rankCounts[rankValue] ?? 0) + 1;

        if (rankValue <= 8) {
          lowRanks.add(rankValue);
        }
      }

      // 페어가 있으면 로우 잠재력 감소
      hasPair = rankCounts.values.any((count) => count >= 2);

      // 상대가 필요한 로우 카드 중 남은 카드 수 계산
      // 상대가 아직 필요한 로우 랭크들
      final neededLowRanks = <int>[];
      for (int rank = 1; rank <= 8; rank++) {
        if (!lowRanks.contains(rank)) {
          neededLowRanks.add(rank);
        }
      }

      // 필요한 카드들의 가용성 계산
      int totalNeededAvailable = 0;
      int criticalMissing = 0;  // 완전히 없는 중요 랭크
      for (final rank in neededLowRanks) {
        final remaining = _countRemainingCards(rank, deadCards);
        totalNeededAvailable += remaining;
        if (remaining == 0 && rank <= 6) {
          criticalMissing++;  // 6 이하의 카드가 모두 데드
        }
      }

      final uniqueLowCount = lowRanks.length;
      final cardsNeeded = 5 - uniqueLowCount;
      double lowStrength = 0.0;

      // 가용성 기반 잠재력 조정
      // cardsNeeded장이 필요한데, 가능한 로우 카드가 부족하면 잠재력 감소
      double availabilityFactor = 1.0;
      if (cardsNeeded > 0) {
        // 필요한 카드당 평균 2장 이상 남아있어야 정상
        final avgAvailable = totalNeededAvailable / max(neededLowRanks.length, 1);
        if (avgAvailable < 1.5) {
          availabilityFactor = 0.5;  // 가용 카드 부족
        } else if (avgAvailable < 2.5) {
          availabilityFactor = 0.7;  // 가용 카드 적음
        } else if (avgAvailable < 3.0) {
          availabilityFactor = 0.85;
        }

        // 중요 랭크가 완전히 데드면 추가 감소
        if (criticalMissing >= 2) {
          availabilityFactor *= 0.5;
        } else if (criticalMissing >= 1) {
          availabilityFactor *= 0.7;
        }
      }

      // 오픈 카드 수에 따른 로우 잠재력 계산
      if (uniqueLowCount >= 4) {
        // 4장 이상의 유니크 로우 카드 = 매우 위협적
        final sortedLow = lowRanks.toList()..sort();
        final highCard = sortedLow.length >= 5
            ? sortedLow[4]
            : sortedLow.last;

        if (highCard <= 6) {
          lowStrength = (hasPair ? 0.7 : 0.9) * availabilityFactor;
        } else if (highCard <= 7) {
          lowStrength = (hasPair ? 0.6 : 0.8) * availabilityFactor;
        } else {
          lowStrength = (hasPair ? 0.5 : 0.7) * availabilityFactor;
        }
      } else if (uniqueLowCount >= 3) {
        // 3장의 유니크 로우 카드 = 잠재력 있음
        if (lowRanks.contains(1)) {
          lowStrength = (hasPair ? 0.4 : 0.6) * availabilityFactor;
        } else {
          lowStrength = (hasPair ? 0.3 : 0.5) * availabilityFactor;
        }
      } else if (uniqueLowCount >= 2) {
        // 2장의 유니크 로우 카드 = 약간의 잠재력
        if (lowRanks.contains(1)) {
          lowStrength = 0.3 * availabilityFactor;
        } else {
          lowStrength = 0.2 * availabilityFactor;
        }
      }

      maxLowStrength = max(maxLowStrength, lowStrength);
    }

    return maxLowStrength;
  }

  /// 내 로우 핸드가 상대 오픈 카드 기준으로 우위인지 평가
  /// 반환값: 상대적 우위 (-1.0 ~ 1.0, 양수면 내가 우위)
  double _evaluateRelativeLowStrength(HiLoPlayer currentPlayer) {
    final myLowStrength = _evaluateCompletedLowStrength(currentPlayer);
    if (myLowStrength == 0) return -1.0;  // 로우 없음

    final opponentLowPotential = _evaluateOpponentLowPotential();

    // 상대적 강도 계산
    // 내 로우가 확정이고 상대는 잠재력만 있으므로 약간의 보너스
    final myAdjusted = myLowStrength + 0.1;
    return (myAdjusted - opponentLowPotential).clamp(-1.0, 1.0);
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
