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
  bool _isRoundTransitioning = false;
  String _roundTransitionMessage = '';
  int _transitionCountdown = 0;
  Timer? _transitionTimer;
  SevenCardPhase? _previousPhase;
  int _cardCountBeforeTransition = 0; // 전환 전 카드 수 (새 카드 숨기기용)

  SevenCardController() {
    _initializePlayers();
  }

  SevenCardState get state => _state;
  bool get isProcessing => _isProcessing;
  bool get isHumanTurn => _state.currentPlayerIndex == 0 && !_isProcessing && !_isRoundTransitioning;
  bool get isRoundTransitioning => _isRoundTransitioning;
  String get roundTransitionMessage => _roundTransitionMessage;
  int get transitionCountdown => _transitionCountdown;
  bool get hasActiveGame => _state.phase != SevenCardPhase.waiting && _state.phase != SevenCardPhase.gameEnd;
  int get cardCountBeforeTransition => _cardCountBeforeTransition;

  void _initializePlayers() {
    final players = [
      SevenCardPlayer(id: 0, name: '플레이어', type: PlayerType.human),
      SevenCardPlayer(id: 1, name: '민준', type: PlayerType.ai),
      SevenCardPlayer(id: 2, name: '서연', type: PlayerType.ai),
      SevenCardPlayer(id: 3, name: '지호', type: PlayerType.ai),
      SevenCardPlayer(id: 4, name: '수빈', type: PlayerType.ai),
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

  /// 라운드 전환 시작 (5초 카운트다운)
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

  /// 라운드 전환 종료 (수동 스킵 또는 타이머 완료)
  void skipTransition() {
    if (_isRoundTransitioning) {
      _endRoundTransition();
    }
  }

  void _endRoundTransition() {
    _cancelTransitionTimer();
    _isRoundTransitioning = false;
    _cardCountBeforeTransition = 0; // 전환 완료 - 모든 카드 표시
    notifyListeners();

    // AI 턴 처리 계속
    _processAITurnIfNeeded();
  }

  /// 페이즈 변경 감지 및 전환 메시지 생성
  void _checkPhaseTransition() {
    if (_previousPhase == null) {
      _previousPhase = _state.phase;
      return;
    }

    // 베팅 페이즈 간 전환 감지
    final prevPhase = _previousPhase!;
    final currPhase = _state.phase;
    _previousPhase = currPhase;

    String? message;

    if (prevPhase == SevenCardPhase.betting1 && currPhase == SevenCardPhase.betting2) {
      message = '라운드 1 완료!\n5번째 카드가 배분됩니다.\n\nGOOD LUCK!';
      _cardCountBeforeTransition = 4; // 전환 전 카드 수 (새 카드 숨기기용)
    } else if (prevPhase == SevenCardPhase.betting2 && currPhase == SevenCardPhase.betting3) {
      message = '라운드 2 완료!\n6번째 카드가 배분됩니다.\n\nGOOD LUCK!';
      _cardCountBeforeTransition = 5;
    } else if (prevPhase == SevenCardPhase.betting3 && currPhase == SevenCardPhase.betting4) {
      message = '라운드 3 완료!\n마지막 7번째 카드가 배분됩니다.\n\nGOOD LUCK!';
      _cardCountBeforeTransition = 6;
    } else if (currPhase == SevenCardPhase.gameEnd && prevPhase != SevenCardPhase.gameEnd) {
      // 게임 종료는 별도 화면으로 처리
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

  /// 액션 후 처리 (페이즈 전환 체크)
  void _handlePostAction(SevenCardPhase prevPhase) {
    if (_state.phase != prevPhase) {
      _checkPhaseTransition();
      if (_isRoundTransitioning) return;
    }
    _processAITurnIfNeeded();
  }

  bool _isBettingPhase() {
    return _state.phase == SevenCardPhase.betting1 ||
        _state.phase == SevenCardPhase.betting2 ||
        _state.phase == SevenCardPhase.betting3 ||
        _state.phase == SevenCardPhase.betting4;
  }

  void _processAITurnIfNeeded() async {
    // 라운드 전환 중이면 대기
    if (_isRoundTransitioning) return;

    // 페이즈 전환 체크
    _checkPhaseTransition();
    if (_isRoundTransitioning) return;

    if (!_isBettingPhase()) return;
    if (_state.currentPlayerIndex == 0) return;

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1));

    // 다시 한번 체크 (전환 중에 호출되었을 수 있음)
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

    // 페이즈가 변경되었는지 확인
    if (_state.phase != prevPhase) {
      _checkPhaseTransition();
      if (_isRoundTransitioning) return;
    }

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

    // 보스인 경우 (삥/체크/쿼터/하프/풀 선택 가능)
    if (_state.isCurrentPlayerBoss) {
      final opponentStrength = _evaluateOpponentOpenCards();

      // 스트레이트 이상 (0.68+): 하프 이상 베팅
      // 스트레이트=0.68, 백스트=0.72, 마운틴=0.75, 플러시=0.78, 풀하우스=0.85, 포카드=0.93, SF=0.97+
      if (handStrength >= 0.68) {
        // 상대가 매우 강해 보이면 쿼터 (방어적)
        if (opponentStrength >= 0.6) {
          if (random.nextDouble() < 0.6) {
            return _AIAction('quarter', 0);
          }
          return _AIAction('half', 0);
        }

        // 포카드 이상 (0.93+): 풀 또는 하프
        if (handStrength >= 0.93) {
          if (random.nextDouble() < 0.6) {
            return _AIAction('full', 0);
          }
          return _AIAction('half', 0);
        }

        // 풀하우스 (0.85+): 하프 또는 풀
        if (handStrength >= 0.85) {
          if (random.nextDouble() < 0.5) {
            return _AIAction('full', 0);
          }
          return _AIAction('half', 0);
        }

        // 플러시/마운틴/백스트 (0.72~0.84): 하프 또는 쿼터
        if (handStrength >= 0.72) {
          if (random.nextDouble() < 0.6) {
            return _AIAction('half', 0);
          }
          return _AIAction('quarter', 0);
        }

        // 스트레이트 (0.68~0.71): 하프 또는 쿼터
        if (random.nextDouble() < 0.5) {
          return _AIAction('half', 0);
        }
        return _AIAction('quarter', 0);
      }

      // 트리플 (0.60~0.67): 쿼터 또는 빙
      if (handStrength >= 0.60) {
        if (random.nextDouble() < 0.5) {
          return _AIAction('quarter', 0);
        }
        return _AIAction('bing', 0);
      }

      // 투페어 (0.45~0.59): 빙 또는 체크
      if (handStrength >= 0.45) {
        if (random.nextDouble() < 0.7) {
          return _AIAction('bing', 0);
        }
        return _AIAction('check', 0);
      }

      // 원페어 이하: 빙 또는 체크
      if (handStrength > 0.25 || random.nextDouble() < 0.5) {
        return _AIAction('bing', 0);
      }
      return _AIAction('check', 0);
    }

    // 남은 카드 수에 따른 드로우 보너스
    final cardsRemaining = 7 - player.hand.length;
    final drawBonus = cardsRemaining * 0.05; // 카드가 많이 남을수록 콜 유리

    // === 마지막 라운드 (7장 완료): 상대적 강도 비교 ===
    if (cardsRemaining == 0) {
      final callAmount = _state.getCallAmount();
      final opponentStrength = _evaluateOpponentOpenCards();

      // === 오픈 카드만으로도 지는지 확인 (명확한 패배 시 폴드) ===
      if (_isLosingToOpponentOpenCards(player, hand)) {
        // 콜 금액이 있으면 폴드
        if (callAmount > 0) {
          return _AIAction('die', 0);
        }
        // 콜 금액이 0이면 체크
        return _AIAction('call', 0);
      }

      // 상대적 강도: 내 핸드 강도 - 상대 오픈 카드 강도
      // 양수면 내가 우세, 음수면 상대가 우세해 보임
      final relativeStrength = handStrength - opponentStrength;

      // === 투페어 이상 (강도 >= 0.45): 마지막 라운드는 신중하게 ===
      // 다른 AI가 모두 폴드했는지 확인
      final isLastActiveAIFinal = _isLastActiveAI(player);

      if (handStrength >= 0.45) {
        // 다른 AI가 모두 다이한 경우: 블러프 캐치로 높은 확률 유지
        if (isLastActiveAIFinal) {
          if (opponentStrength < 0.55) {
            return _AIAction('call', 0);  // 무조건 콜
          }
          if (random.nextDouble() < 0.85) {
            return _AIAction('call', 0);
          }
        } else {
          // 다른 AI가 남아있는 경우: 신중하게 판단
          if (opponentStrength < 0.45) {
            // 상대가 약해 보이면 콜 (70%)
            if (random.nextDouble() < 0.7) {
              return _AIAction('call', 0);
            }
          } else if (opponentStrength < 0.55) {
            // 상대가 중간 강도면 콜 (50%)
            if (random.nextDouble() < 0.5) {
              return _AIAction('call', 0);
            }
          }
          // 상대가 강해 보이면 폴드 가능
        }
      }

      // === 상대가 약해 보이면 버티기 ===
      // 상대 오픈 카드가 약하면 (< 0.3) 내 패가 약해도 콜 고려
      if (opponentStrength < 0.3 && handStrength >= 0.15) {
        // 상대가 매우 약해 보이면 하이카드로도 콜 (60%)
        if (random.nextDouble() < 0.6) {
          return _AIAction('call', 0);
        }
      }

      // 내가 상대보다 강해 보이면 (상대적 강도 > 0) 콜
      if (relativeStrength > 0 && handStrength >= 0.2) {
        // 내가 우세해 보이면 80% 콜
        if (random.nextDouble() < 0.8) {
          return _AIAction('call', 0);
        }
      }

      // === 상대가 강해 보일 때만 폴드 고려 ===
      // 하이카드 (강도 < 0.25): 상대가 강해 보이면 폴드
      if (handStrength < 0.25) {
        // 상대가 강해 보이고 (>= 0.35) 콜 금액이 있으면 폴드
        if (opponentStrength >= 0.35 && callAmount > 0) {
          return _AIAction('die', 0);
        }
        // 상대도 약해 보이면 콜
        return _AIAction('call', 0);
      }

      // 약한 원페어 (강도 0.25 ~ 0.35): 상대가 확실히 강해 보일 때만 폴드
      if (handStrength < 0.35) {
        // 상대 오픈 카드가 강해 보이면 (페어 이상) 폴드 고려
        if (opponentStrength >= 0.4 && relativeStrength < -0.1) {
          if (callAmount > 0 && random.nextDouble() < 0.7) {
            return _AIAction('die', 0);
          }
        }
        // 베팅이 크고 상대가 강해 보이면 폴드
        if (callAmount > _state.pot * 0.4 && opponentStrength >= 0.35 && random.nextDouble() < 0.6) {
          return _AIAction('die', 0);
        }
      }

      // 강한 원페어 (강도 0.35 ~ 0.45): 더 버티기
      if (handStrength >= 0.35 && handStrength < 0.45) {
        // 상대가 매우 강해 보이지 않으면 (< 0.5) 콜
        if (opponentStrength < 0.5) {
          return _AIAction('call', 0);
        }
        // 상대가 강해 보여도 70% 콜
        if (random.nextDouble() < 0.7) {
          return _AIAction('call', 0);
        }
      }
    }

    // === 상대적 강도 기반 판단 (모든 라운드) ===
    final humanPlayer = _state.players[0];
    final humanOpenStrength = _evaluatePlayerOpenCards(humanPlayer);
    final relativeStrengthVsHuman = handStrength - humanOpenStrength;
    final callAmount = _state.getCallAmount();

    // === 이미 베팅한 활성 AI 수 확인 (보수적 플레이 결정용) ===
    // 뒤에 있는 AI는 아직 베팅하지 않았으므로 제외
    final activeAIsWhoBet = _countActiveAIsWhoBet();
    final hasOtherAICommitted = activeAIsWhoBet >= 1; // 이미 베팅한 AI가 1명 이상

    // === 낮은 투페어 이하 (강도 < 0.50): 다른 AI가 베팅했으면 보수적으로 ===
    if (handStrength < 0.50 && callAmount > 0 && hasOtherAICommitted) {
      // 콜 금액이 큰 경우 (팟의 30% 이상)
      if (callAmount > _state.pot * 0.3) {
        // 약한 원페어 (0.25 ~ 0.35): 70% 폴드
        if (handStrength < 0.35) {
          if (random.nextDouble() < 0.7) {
            return _AIAction('die', 0);
          }
        }
        // 강한 원페어 (0.35 ~ 0.45): 50% 폴드
        else if (handStrength < 0.45) {
          if (random.nextDouble() < 0.5) {
            return _AIAction('die', 0);
          }
        }
        // 낮은 투페어 (0.45 ~ 0.50): 40% 폴드
        else {
          if (random.nextDouble() < 0.4) {
            return _AIAction('die', 0);
          }
        }
      }
      // 콜 금액이 매우 큰 경우 (팟의 50% 이상) 더 높은 폴드 확률
      if (callAmount > _state.pot * 0.5) {
        // 원페어 이하: 80% 폴드
        if (handStrength < 0.45 && random.nextDouble() < 0.8) {
          return _AIAction('die', 0);
        }
        // 낮은 투페어: 60% 폴드
        if (handStrength < 0.50 && random.nextDouble() < 0.6) {
          return _AIAction('die', 0);
        }
      }
    }

    // === 높은 투페어 (강도 0.50 ~ 0.60): 중간 라운드에서 공격적으로 콜 ===
    // 트리플 이상(>= 0.60)은 레이즈 로직으로 넘김
    if (handStrength >= 0.50 && handStrength < 0.60 && callAmount > 0) {
      // 중간 라운드에서는 높은 투페어이면 거의 항상 콜
      // 상대가 매우 강해 보이지 않으면 무조건 콜
      if (humanOpenStrength < 0.55) {
        return _AIAction('call', 0);
      }
      // 상대가 강해 보여도 95% 콜 (중간 라운드는 공격적)
      if (random.nextDouble() < 0.95) {
        return _AIAction('call', 0);
      }
    }

    // === 강한 원페어 (강도 0.35 ~ 0.45): 중간 라운드에서 버티기 ===
    if (handStrength >= 0.35 && handStrength < 0.45 && callAmount > 0) {
      // 다른 AI가 이미 베팅했으면 보수적으로
      if (hasOtherAICommitted) {
        // 상대가 약해 보이면 50% 콜
        if (humanOpenStrength < 0.40) {
          if (random.nextDouble() < 0.5) {
            return _AIAction('call', 0);
          }
        }
        // 아니면 폴드
        return _AIAction('die', 0);
      }
      // 마지막 AI면 더 버티기
      if (humanOpenStrength < 0.45) {
        if (random.nextDouble() < 0.8) {
          return _AIAction('call', 0);
        }
      }
    }

    // 상대(플레이어)가 약해 보이면 버티기 (트리플 미만만)
    if (humanOpenStrength < 0.3 && callAmount > 0 && handStrength < 0.60) {
      // 상대가 약해 보이고 내가 최소한 하이카드 이상이면 콜 (70%)
      if (handStrength >= 0.15 && random.nextDouble() < 0.7) {
        return _AIAction('call', 0);
      }
    }

    // 내가 상대보다 우세해 보이면 콜 (트리플 미만만)
    if (relativeStrengthVsHuman > 0.05 && callAmount > 0 && handStrength >= 0.2 && handStrength < 0.60) {
      if (random.nextDouble() < 0.75) {
        return _AIAction('call', 0);
      }
    }

    // === 블러프 캐처 로직 (트리플 미만만) ===
    // 마지막 남은 AI가 플레이어의 블러프를 잡아야 함
    // 트리플 이상(>= 0.60)은 레이즈 로직으로 넘김
    final isLastActiveAI = _isLastActiveAI(player);

    if (isLastActiveAI && callAmount > 0 && handStrength < 0.60) {
      // 팟 오즈 계산: 팟이 크면 블러프 캐치 가치가 있음
      final potOddsForBluffCatch = callAmount / (_state.pot + callAmount);

      // 플레이어가 공격적으로 베팅했는지 확인 (팟의 50% 이상 베팅)
      final isAggressiveBet = callAmount > _state.pot * 0.5;

      // 블러프 캐치 조건:
      // 1. 플레이어 오픈 카드가 약해 보임 (강도 < 0.35)
      // 2. 공격적인 베팅 (블러프 가능성)
      // 3. 내 핸드가 최소한 원페어 이상 (강도 >= 0.25)
      if (humanOpenStrength < 0.35 && isAggressiveBet && handStrength >= 0.25) {
        // 블러프 캐치 확률: 80%
        if (random.nextDouble() < 0.8) {
          return _AIAction('call', 0);
        }
      }

      // 내가 상대보다 강해 보이면 무조건 콜 (블러프 캐치)
      if (relativeStrengthVsHuman > 0) {
        return _AIAction('call', 0);
      }

      // 팟 오즈가 좋으면 (콜 금액이 팟의 25% 이하) 블러프 캐치
      if (potOddsForBluffCatch < 0.25 && handStrength >= 0.15) {
        // 저렴한 콜: 85% 확률로 블러프 캐치
        if (random.nextDouble() < 0.85) {
          return _AIAction('call', 0);
        }
      }

      // 마지막 AI로서 최소한의 블러프 캐치 의무 (40%)
      // 하이카드 이상이면 일정 확률로 콜
      if (handStrength >= 0.15 && random.nextDouble() < 0.4) {
        return _AIAction('call', 0);
      }
    }

    // 강한 드로우 체크 (4장 플러시/스트레이트 드로우)
    final strongDraw = _hasStrongDraw(player);

    // === 라운드 1, 2에서 도전적 베팅 ===
    final isEarlyRound = _state.phase == SevenCardPhase.betting1 ||
                         _state.phase == SevenCardPhase.betting2;

    // 스트레이트 이상 완성된 핸드 (0.68+): 비보스도 적극적으로 레이즈
    if (handStrength >= 0.68) {
      // 플러시 이상 (0.72+): 거의 항상 레이즈
      if (handStrength >= 0.72) {
        if (random.nextDouble() < 0.9) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
        return _AIAction('call', 0);
      }
      // 스트레이트 (0.68~0.71): 높은 확률로 레이즈
      if (random.nextDouble() < 0.8) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    // 콜 금액이 없으면 (이미 맞춤)
    if (callAmount == 0) {
      // 라운드 1, 2: 더 공격적으로 레이즈
      if (isEarlyRound) {
        // 투페어 이상 (0.45+): 70% 레이즈
        if (handStrength >= 0.45 && random.nextDouble() < 0.70) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
        // 강한 원페어 (0.35~0.45): 50% 레이즈
        if (handStrength >= 0.35 && random.nextDouble() < 0.50) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
        // 원페어 (0.25~0.35): 30% 레이즈
        if (handStrength >= 0.25 && random.nextDouble() < 0.30) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      }
      // 트리플 이상이고 마지막 카드가 아니면 공격적으로 레이즈
      if (handStrength >= 0.60 && cardsRemaining >= 1) {
        // 트리플~스트레이트: 55% 레이즈
        if (handStrength < 0.70 && random.nextDouble() < 0.55) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
        // 스트레이트 이상: 70% 레이즈
        if (handStrength >= 0.70 && random.nextDouble() < 0.70) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      }
      // 기존 로직: 강한 핸드 레이즈 고려
      if (handStrength > 0.65 && random.nextDouble() < 0.5) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    // 팟 오즈 계산 (드로우 보너스 적용)
    final potOdds = callAmount / (_state.pot + callAmount + 1);
    final strongDrawBonus = strongDraw ? 0.25 : 0.0; // 강한 드로우가 있으면 추가 보너스
    final adjustedStrength = handStrength + drawBonus + strongDrawBonus;

    // 강한 드로우가 있으면 카드를 더 받아보기 (거의 항상 콜)
    if (strongDraw && cardsRemaining >= 1) {
      // 4장 플러시/스트레이트 드로우: 높은 확률로 콜
      if (random.nextDouble() < 0.85) {
        return _AIAction('call', 0);
      }
    }

    // === 라운드 1, 2에서 콜 금액이 있을 때 도전적 베팅 ===
    if (isEarlyRound && callAmount > 0) {
      // 투페어 이상 (0.45+): 60% 레이즈
      if (handStrength >= 0.45 && random.nextDouble() < 0.60) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
      // 강한 원페어 (0.35~0.45): 40% 레이즈
      if (handStrength >= 0.35 && handStrength < 0.45 && random.nextDouble() < 0.40) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
    }

    // === 트리플 이상 (마지막 카드가 아닌 경우): 공격적 베팅 ===
    // 트리플(0.60) 이상이고 아직 카드가 남아있으면 레이즈 확률 높임
    if (handStrength >= 0.60 && cardsRemaining >= 1) {
      // 트리플~스트레이트 (0.60~0.70): 60% 확률로 레이즈
      if (handStrength < 0.70) {
        if (random.nextDouble() < 0.6) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      }
      // 스트레이트 이상 (0.70+): 75% 확률로 레이즈
      else {
        if (random.nextDouble() < 0.75) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      }
    }

    // === 마지막 라운드에서 스트레이트 이상: 공격적 베팅 ===
    if (cardsRemaining == 0 && handStrength >= 0.68) {
      // 스트레이트~플러시 (0.68~0.75): 70% 레이즈
      if (handStrength < 0.75) {
        if (random.nextDouble() < 0.70) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      }
      // 플러시 이상 (0.75+): 85% 레이즈
      else {
        if (random.nextDouble() < 0.85) {
          return _selectRaiseAction(handStrength, availableActions, random);
        }
      }
    }

    // 매우 강한 핸드 (마운틴 이상: 플러시, 풀하우스, 포카드 등)
    // 90% 확률로 레이즈
    if (handStrength >= 0.75) {
      if (random.nextDouble() < 0.9) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    // 강한 핸드 (레이즈 고려) - 70% 확률로 레이즈
    if (adjustedStrength > 0.7) {
      if (random.nextDouble() < 0.7) {
        return _selectRaiseAction(handStrength, availableActions, random);
      }
      return _AIAction('call', 0);
    }

    // 중간 핸드 (콜 또는 폴드) - 드로우 보너스 적용
    if (adjustedStrength > potOdds) {
      // 남은 카드가 많을수록 콜 확률 증가
      final callProbability = (adjustedStrength + 0.2 + drawBonus).clamp(0.0, 0.95);
      if (random.nextDouble() < callProbability) {
        return _AIAction('call', 0);
      }
      return _AIAction('die', 0);
    }

    // 약한 핸드지만 드로우 가능성 있으면 콜 고려
    if (cardsRemaining >= 2 && handStrength > 0.25) {
      // 드로우 가능성이 있으면 저렴한 콜은 수용
      final cheapCall = callAmount <= _state.pot * 0.3; // 30%로 상향
      if (cheapCall && random.nextDouble() < 0.5 + drawBonus) {
        return _AIAction('call', 0);
      }
    }

    // 블러프 확률
    if (random.nextDouble() < 0.08) {
      return _AIAction('call', 0);
    }
    return _AIAction('die', 0);
  }

  /// 강한 드로우 체크 (4장 플러시 또는 4장 스트레이트 드로우)
  bool _hasStrongDraw(SevenCardPlayer player) {
    final cards = player.hand;
    if (cards.length < 4) return false;

    // 4장 플러시 드로우 체크
    final suits = <Suit, int>{};
    for (final card in cards) {
      if (card.suit != null) {
        suits[card.suit!] = (suits[card.suit!] ?? 0) + 1;
      }
    }
    if (suits.values.any((count) => count >= 4)) {
      return true; // 4장 이상 같은 무늬
    }

    // 4장 스트레이트 드로우 체크
    final ranks = cards.map((c) => c.rankValue).toSet().toList()..sort();

    // 4장 연속 체크
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

    // A를 1로도 사용 (백스트레이트/마운틴)
    if (ranks.contains(14)) {
      // A-2-3-4 체크
      final lowCards = [2, 3, 4, 5].where((r) => ranks.contains(r)).toList();
      if (lowCards.length + 1 >= 4) return true;
      // 10-J-Q-K-A 체크
      final highCards = [10, 11, 12, 13].where((r) => ranks.contains(r)).toList();
      if (highCards.length + 1 >= 4) return true;
    }

    if (maxConsecutive >= 4) return true;

    // 거셧 스트레이트 (중간 1장만 빠진 경우) - 예: 3-4-6-7
    if (ranks.length >= 4) {
      for (int i = 0; i <= ranks.length - 4; i++) {
        final span = ranks[i + 3] - ranks[i];
        if (span == 4) {
          // 4장이 5 범위 안에 있으면 거셧
          return true;
        }
      }
    }

    return false;
  }

  /// 레이즈 액션 선택 (따당/쿼터/하프/풀)
  /// 족보 강도에 맞춰 베팅 레벨 결정
  /// 상대 오픈 카드를 보고 슬로우 플레이 여부 결정
  _AIAction _selectRaiseAction(double handStrength, List<String> availableActions, Random random) {
    // 상대방들의 오픈 카드 강도 평가
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

  /// 모든 보이는 카드(내 카드 + 모든 오픈 카드) 수집
  /// 상대방이 가질 수 없는 "데드 카드" 목록
  Set<String> _collectDeadCards(SevenCardPlayer currentPlayer) {
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
  int _countRemainingCardsForRank(int rankValue, Set<String> deadCards) {
    final rankName = _getRankNameFromValue(rankValue);
    int remaining = 4;

    for (final suitName in ['spade', 'heart', 'diamond', 'club']) {
      if (deadCards.contains('${suitName}_$rankName')) {
        remaining--;
      }
    }

    return remaining;
  }

  /// 특정 무늬의 남은 카드 수 계산 (13장 중 데드 카드 제외)
  int _countRemainingCardsForSuit(Suit suit, Set<String> deadCards) {
    int remaining = 13;

    for (final rankName in [
      'two', 'three', 'four', 'five', 'six', 'seven', 'eight',
      'nine', 'ten', 'jack', 'queen', 'king', 'ace'
    ]) {
      if (deadCards.contains('${suit.name}_$rankName')) {
        remaining--;
      }
    }

    return remaining;
  }

  String _getRankNameFromValue(int value) {
    switch (value) {
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

  /// 상대방 오픈 카드 강도 평가 (데드 카드 고려)
  double _evaluateOpponentOpenCards() {
    final currentPlayer = _state.players[_state.currentPlayerIndex];
    final deadCards = _collectDeadCards(currentPlayer);

    double maxStrength = 0.0;

    for (final player in _state.players) {
      // 자신과 폴드한 플레이어 제외
      if (player.id == _state.currentPlayerIndex || player.isFolded) continue;

      final openCards = player.openCards;
      if (openCards.isEmpty) continue;

      double strength = 0.0;

      // 오픈 카드에서 페어 체크
      final ranks = <int, int>{};
      final suits = <Suit, int>{};
      for (final card in openCards) {
        ranks[card.rankValue] = (ranks[card.rankValue] ?? 0) + 1;
        if (card.suit != null) {
          suits[card.suit!] = (suits[card.suit!] ?? 0) + 1;
        }
      }

      // 페어/트리플 확인 - 데드 카드 고려
      final maxSameRank = ranks.values.isEmpty ? 0 : ranks.values.reduce(max);
      if (maxSameRank >= 3) {
        strength = 0.6; // 트리플 보임
      } else if (maxSameRank >= 2) {
        // 페어가 보이는 경우, 트리플/포카드 가능성 체크
        final pairRank = ranks.entries.firstWhere((e) => e.value >= 2).key;
        final remainingForPair = _countRemainingCardsForRank(pairRank, deadCards);
        if (remainingForPair >= 2) {
          strength = 0.45; // 포카드 가능성
        } else if (remainingForPair >= 1) {
          strength = 0.4; // 트리플 가능성
        } else {
          strength = 0.35; // 페어만 (발전 불가)
        }
      }

      // 플러시 드로우 (같은 무늬 3장 이상) - 데드 카드 고려
      Suit? flushSuit;
      int flushCount = 0;
      for (final entry in suits.entries) {
        if (entry.value >= 3 && entry.value > flushCount) {
          flushCount = entry.value;
          flushSuit = entry.key;
        }
      }

      if (flushSuit != null && flushCount >= 3) {
        final remainingForFlush = _countRemainingCardsForSuit(flushSuit, deadCards);
        final cardsNeeded = 5 - flushCount;
        final hiddenCards = 7 - openCards.length;  // 히든 카드 수

        if (flushCount >= 4) {
          // 4장 플러시 드로우 - 완성 가능성 높음
          if (remainingForFlush >= 1) {
            strength = max(strength, 0.6);
          } else {
            strength = max(strength, 0.35); // 발전 불가
          }
        } else if (flushCount >= 3 && hiddenCards >= cardsNeeded) {
          // 3장 플러시 드로우
          if (remainingForFlush >= cardsNeeded) {
            strength = max(strength, 0.5);
          } else if (remainingForFlush >= 1) {
            strength = max(strength, 0.4);
          }
        }
      }

      // 스트레이트 드로우 (연속 카드) - 데드 카드 고려
      final sortedRanks = ranks.keys.toList()..sort();
      if (sortedRanks.length >= 3) {
        int maxConsecutive = 1;
        int currentConsecutive = 1;
        for (int i = 1; i < sortedRanks.length; i++) {
          if (sortedRanks[i] - sortedRanks[i-1] == 1) {
            currentConsecutive++;
            maxConsecutive = max(maxConsecutive, currentConsecutive);
          } else if (sortedRanks[i] - sortedRanks[i-1] > 1) {
            currentConsecutive = 1;
          }
        }

        if (maxConsecutive >= 4) {
          // 4장 스트레이트 드로우 - 필요한 카드 확인
          // 양 끝 카드 중 남은 것 체크
          final lowEnd = sortedRanks.first - 1;
          final highEnd = sortedRanks.last + 1;
          int availableOuts = 0;
          if (lowEnd >= 2) {
            availableOuts += _countRemainingCardsForRank(lowEnd, deadCards);
          }
          if (highEnd <= 14) {
            availableOuts += _countRemainingCardsForRank(highEnd, deadCards);
          }
          if (availableOuts >= 4) {
            strength = max(strength, 0.55);
          } else if (availableOuts >= 2) {
            strength = max(strength, 0.45);
          } else {
            strength = max(strength, 0.35); // 아웃이 적음
          }
        } else if (maxConsecutive >= 3) {
          strength = max(strength, 0.4);
        }
      }

      // 하이카드만 있는 경우
      if (strength == 0.0) {
        final highCard = ranks.keys.isEmpty ? 0 : ranks.keys.reduce(max);
        strength = 0.1 + (highCard / 14) * 0.15;
      }

      maxStrength = max(maxStrength, strength);
    }

    return maxStrength;
  }

  /// 마지막 남은 활성 AI인지 확인 (블러프 캐처용)
  bool _isLastActiveAI(SevenCardPlayer currentPlayer) {
    int activeAICount = 0;
    for (final player in _state.players) {
      // 플레이어(인덱스 0)와 폴드한 AI 제외
      if (player.id == 0 || player.isFolded) continue;
      activeAICount++;
    }
    // 활성 AI가 1명이고 그게 현재 플레이어면 마지막 AI
    return activeAICount == 1 && !currentPlayer.isFolded && currentPlayer.id != 0;
  }

  /// 활성 AI 수 카운트 (보수적 플레이 결정용)
  int _countActiveAIs() {
    int count = 0;
    for (final player in _state.players) {
      // 플레이어(인덱스 0)와 폴드한 AI 제외
      if (player.id == 0 || player.isFolded) continue;
      count++;
    }
    return count;
  }

  /// 이미 베팅한 활성 AI 수 카운트 (보수적 플레이 결정용)
  /// 현재 라운드에서 한번이라도 베팅한 AI만 카운트
  int _countActiveAIsWhoBet() {
    int count = 0;
    for (final player in _state.players) {
      // 플레이어(인덱스 0)와 폴드한 AI 제외
      if (player.id == 0 || player.isFolded) continue;
      // 현재 라운드에서 베팅한 적이 있는 AI만 카운트
      if (player.bettingActionsInRound > 0 || player.currentBet > 0) {
        count++;
      }
    }
    return count;
  }

  /// 특정 플레이어의 오픈 카드 강도 평가
  double _evaluatePlayerOpenCards(SevenCardPlayer player) {
    final openCards = player.openCards;
    if (openCards.isEmpty) return 0.0;

    double strength = 0.0;

    // 오픈 카드에서 페어 체크
    final ranks = <int, int>{};
    final suits = <Suit, int>{};
    for (final card in openCards) {
      ranks[card.rankValue] = (ranks[card.rankValue] ?? 0) + 1;
      if (card.suit != null) {
        suits[card.suit!] = (suits[card.suit!] ?? 0) + 1;
      }
    }

    // 페어/트리플 확인
    final maxSameRank = ranks.values.isEmpty ? 0 : ranks.values.reduce(max);
    if (maxSameRank >= 3) {
      strength = 0.6; // 트리플 보임
    } else if (maxSameRank >= 2) {
      strength = 0.4; // 페어 보임
    }

    // 플러시 드로우 (같은 무늬 3장 이상)
    final maxSameSuit = suits.values.isEmpty ? 0 : suits.values.reduce(max);
    if (maxSameSuit >= 3) {
      strength = max(strength, 0.5); // 플러시 드로우 가능성
    }

    // 스트레이트 드로우 (연속 카드)
    final sortedRanks = ranks.keys.toList()..sort();
    if (sortedRanks.length >= 3) {
      int consecutive = 1;
      for (int i = 1; i < sortedRanks.length; i++) {
        if (sortedRanks[i] - sortedRanks[i-1] == 1) {
          consecutive++;
        }
      }
      if (consecutive >= 3) {
        strength = max(strength, 0.45); // 스트레이트 드로우 가능성
      }
    }

    // 하이카드만 있는 경우
    if (strength == 0.0) {
      final highCard = ranks.keys.isEmpty ? 0 : ranks.keys.reduce(max);
      strength = 0.1 + (highCard / 14) * 0.15;
    }

    return strength;
  }

  /// 상대방 오픈 카드만으로도 내 완성된 핸드에 지는지 확인
  bool _isLosingToOpponentOpenCards(SevenCardPlayer currentPlayer, PokerHand? myHand) {
    if (myHand == null) return false;

    for (final opponent in _state.players) {
      // 자신과 폴드한 플레이어 제외
      if (opponent.id == currentPlayer.id || opponent.isFolded) continue;

      final openCards = opponent.openCards;
      if (openCards.length < 3) continue; // 3장 미만이면 비교 불가

      // 상대방 오픈 카드로 족보 평가
      PokerHand? opponentOpenHand;
      if (openCards.length >= 5) {
        opponentOpenHand = PokerHandEvaluator.evaluate(openCards);
      } else {
        // 4장 이하면 부분 평가 사용
        opponentOpenHand = PokerHandEvaluator.evaluatePartial(openCards);
      }

      if (opponentOpenHand == null) continue;

      // 내 핸드와 상대 오픈 카드 핸드 비교
      // 상대 오픈 카드가 같은 족보 등급 이상이면서 더 높으면 폴드
      final myRankIndex = myHand.rank.index;
      final opponentRankIndex = opponentOpenHand.rank.index;

      // 상대 오픈 카드 족보가 내 족보보다 높은 등급이면 무조건 폴드
      // (예: 상대 트리플 vs 내 투페어)
      if (opponentRankIndex > myRankIndex) {
        return true;
      }

      // 같은 족보 등급이면 세부 비교
      if (opponentRankIndex == myRankIndex) {
        final comparison = myHand.compareTo(opponentOpenHand);
        if (comparison < 0) {
          // 같은 족보인데 상대가 더 높음 (예: 상대 A투페어 vs 내 4투페어)
          return true;
        }
      }
    }
    return false;
  }

  /// 핸드 강도 평가
  double _evaluateHandStrength(SevenCardPlayer player, PokerHand? hand) {
    if (hand == null) {
      // 5장 미만일 때 예상 강도
      return _evaluatePartialHand(player);
    }

    // 족보별 기본 강도 (수학적 확률 기반)
    // 로열: 0.003%, 스플: 0.03%, 포카드: 0.17%, 풀하우스: 2.6%
    // 플러시: 3.03%, 마운틴: 0.46%, 백스트: 0.46%, 스트레이트: 3.7%
    // 트리플: 4.83%, 투페어: 23.5%, 원페어: 43.8%, 하이카드: 17.4%
    double baseStrength;
    switch (hand.rank) {
      case HandRank.royalStraightFlush:
        baseStrength = 1.0;    // 0.003%
      case HandRank.backStraightFlush:
        baseStrength = 0.98;   // 백스트레이트 플러시
      case HandRank.straightFlush:
        baseStrength = 0.97;   // 0.03%
      case HandRank.fourOfAKind:
        baseStrength = 0.93;   // 0.17%
      case HandRank.fullHouse:
        baseStrength = 0.85;   // 2.6%
      case HandRank.flush:
        baseStrength = 0.78;   // 3.03%
      case HandRank.mountain:
        baseStrength = 0.75;   // 0.46% (특수 스트레이트)
      case HandRank.backStraight:
        baseStrength = 0.72;   // 0.46% (특수 스트레이트)
      case HandRank.straight:
        baseStrength = 0.68;   // 3.7%
      case HandRank.triple:
        baseStrength = 0.60;   // 4.83%
      case HandRank.twoPair:
        baseStrength = 0.45;   // 23.5%
      case HandRank.onePair:
        // 페어 랭크에 따라 조정 (0.25 ~ 0.40)
        final pairRank = hand.tiebreakers.first;
        baseStrength = 0.25 + (pairRank / 14) * 0.15;
      case HandRank.highCard:
        // 하이카드 랭크에 따라 조정 (0.10 ~ 0.20)
        final highCard = hand.tiebreakers.first;
        baseStrength = 0.10 + (highCard / 14) * 0.10;
    }

    // 아직 카드가 더 올 경우, 드로우 가능성 추가 평가
    final cardsRemaining = 7 - player.hand.length;
    if (cardsRemaining > 0 && baseStrength < 0.75) {
      final drawBonus = _evaluateDrawPotential(player);
      baseStrength = max(baseStrength, baseStrength + drawBonus);
    }

    return baseStrength;
  }

  /// 드로우 가능성 평가 (플러시/스트레이트 드로우 - 오픈 카드 고려)
  double _evaluateDrawPotential(SevenCardPlayer player) {
    final cards = player.hand;
    final cardsRemaining = 7 - cards.length;
    if (cardsRemaining <= 0) return 0.0;

    double drawBonus = 0.0;

    // 모든 오픈된 카드 수집 (자신 제외)
    final visibleCards = <PlayingCard>[];
    for (final p in _state.players) {
      if (p.id != player.id) {
        visibleCards.addAll(p.openCards);
      }
    }

    // 무늬별 카드 수 (플러시 드로우)
    final suits = <Suit, int>{};
    Suit? flushSuit;
    int maxSameSuit = 0;
    for (final card in cards) {
      if (card.suit != null) {
        suits[card.suit!] = (suits[card.suit!] ?? 0) + 1;
        if (suits[card.suit!]! > maxSameSuit) {
          maxSameSuit = suits[card.suit!]!;
          flushSuit = card.suit;
        }
      }
    }

    // 플러시 드로우 확률 계산
    if (maxSameSuit >= 3 && flushSuit != null) {
      // 해당 무늬 중 이미 보이는 카드 수
      final visibleSameSuit = visibleCards.where((c) => c.suit == flushSuit).length;
      // 덱에 남은 해당 무늬 카드 수 (13장 - 내 카드 - 보이는 카드)
      final remainingInDeck = 13 - maxSameSuit - visibleSameSuit;
      // 덱에 남은 총 카드 수 (52 - 내 카드 - 보이는 모든 카드)
      final totalRemaining = 52 - cards.length - visibleCards.length;

      if (totalRemaining > 0 && remainingInDeck > 0) {
        final neededCards = 5 - maxSameSuit; // 플러시 완성에 필요한 카드 수

        if (neededCards == 1) {
          // 4장 플러시 드로우: 1장만 더 필요
          final probability = remainingInDeck / totalRemaining;
          // 남은 카드 수만큼 뽑을 기회
          final completionProb = 1 - _pow((1 - probability), cardsRemaining);
          drawBonus = max(drawBonus, completionProb * 0.35);
        } else if (neededCards == 2 && cardsRemaining >= 2) {
          // 3장 플러시 드로우: 2장 더 필요
          final probability = remainingInDeck / totalRemaining;
          final completionProb = probability * probability * 0.5; // 대략적 확률
          drawBonus = max(drawBonus, completionProb * 0.35);
        }
      }
    }

    // 스트레이트 드로우 체크
    final ranks = cards.map((c) => c.rankValue).toSet().toList()..sort();

    // 오픈된 카드의 랭크 수집
    final visibleRanks = visibleCards.map((c) => c.rankValue).toList();

    // 4장 연속 스트레이트 드로우
    int maxConsecutive = 1;
    int currentConsecutive = 1;
    List<int> consecutiveRanks = [ranks.first];

    for (int i = 1; i < ranks.length; i++) {
      if (ranks[i] - ranks[i - 1] == 1) {
        currentConsecutive++;
        consecutiveRanks.add(ranks[i]);
        if (currentConsecutive > maxConsecutive) {
          maxConsecutive = currentConsecutive;
        }
      } else if (ranks[i] - ranks[i - 1] > 1) {
        currentConsecutive = 1;
        consecutiveRanks = [ranks[i]];
      }
    }

    // A를 1로도 사용
    if (ranks.contains(14)) {
      final lowCards = [2, 3, 4, 5].where((r) => ranks.contains(r)).toList();
      if (lowCards.length + 1 > maxConsecutive) {
        maxConsecutive = lowCards.length + 1;
        consecutiveRanks = [1, ...lowCards]; // A=1
      }
      final highCards = [10, 11, 12, 13].where((r) => ranks.contains(r)).toList();
      if (highCards.length + 1 > maxConsecutive) {
        maxConsecutive = highCards.length + 1;
        consecutiveRanks = [...highCards, 14];
      }
    }

    // 스트레이트 완성 확률 계산
    if (maxConsecutive >= 4) {
      // 양쪽 끝에서 완성 가능한 카드 확인
      final neededRanks = <int>[];
      final minRank = consecutiveRanks.reduce(min);
      final maxRank = consecutiveRanks.reduce(max);
      if (minRank > 1 && minRank != 2) neededRanks.add(minRank - 1);
      if (maxRank < 14 && maxRank != 13) neededRanks.add(maxRank + 1);
      // A 특수 처리
      if (minRank == 2 && !ranks.contains(14)) neededRanks.add(14); // A로 백스트레이트
      if (maxRank == 13 && !ranks.contains(14)) neededRanks.add(14); // A로 마운틴

      // 필요한 랭크 중 보이지 않는 카드 수
      int availableOuts = 0;
      for (final r in neededRanks) {
        final visibleCount = visibleRanks.where((v) => v == r).length;
        final myCount = ranks.where((v) => v == r).length;
        availableOuts += (4 - visibleCount - myCount); // 각 랭크당 4장
      }

      final totalRemaining = 52 - cards.length - visibleCards.length;
      if (totalRemaining > 0 && availableOuts > 0) {
        final probability = availableOuts / totalRemaining;
        final completionProb = 1 - _pow((1 - probability), cardsRemaining);
        drawBonus = max(drawBonus, completionProb * 0.30);
      }
    } else if (maxConsecutive >= 3 && cardsRemaining >= 2) {
      drawBonus = max(drawBonus, 0.06);
    }

    // 거셧 스트레이트 (중간 1장 빠진 경우)
    if (ranks.length >= 4) {
      for (int i = 0; i <= ranks.length - 4; i++) {
        final span = ranks[i + 3] - ranks[i];
        if (span == 4) {
          // 중간에 빠진 랭크 찾기
          final neededRank = _findMissingRank(ranks.sublist(i, i + 4));
          if (neededRank != null) {
            final visibleCount = visibleRanks.where((v) => v == neededRank).length;
            final availableOuts = 4 - visibleCount;
            final totalRemaining = 52 - cards.length - visibleCards.length;
            if (totalRemaining > 0 && availableOuts > 0) {
              final probability = availableOuts / totalRemaining;
              final completionProb = 1 - _pow((1 - probability), cardsRemaining);
              drawBonus = max(drawBonus, completionProb * 0.25);
            }
          }
          break;
        }
      }
    }

    return drawBonus;
  }

  /// 빠진 랭크 찾기 (거셧 스트레이트용)
  int? _findMissingRank(List<int> ranks) {
    final sorted = List<int>.from(ranks)..sort();
    for (int i = sorted.first; i <= sorted.last; i++) {
      if (!sorted.contains(i)) return i;
    }
    return null;
  }

  /// 거듭제곱 계산
  double _pow(double base, int exp) {
    double result = 1.0;
    for (int i = 0; i < exp; i++) {
      result *= base;
    }
    return result;
  }

  /// 부분 핸드 평가 (5장 미만 - 남은 카드로 완성 가능성 고려)
  double _evaluatePartialHand(SevenCardPlayer player) {
    final cards = player.hand;
    if (cards.isEmpty) return 0.3;

    final cardsRemaining = 7 - cards.length; // 남은 카드 수
    double strength = 0.2;

    // 랭크별 카드 수
    final ranks = <int, int>{};
    for (final card in cards) {
      ranks[card.rankValue] = (ranks[card.rankValue] ?? 0) + 1;
    }

    // 무늬별 카드 수
    final suits = <Suit, int>{};
    for (final card in cards) {
      if (card.suit != null) {
        suits[card.suit!] = (suits[card.suit!] ?? 0) + 1;
      }
    }

    // 현재 족보 + 완성 가능성
    final maxSameRank = ranks.values.isEmpty ? 0 : ranks.values.reduce(max);
    final maxSameSuit = suits.values.isEmpty ? 0 : suits.values.reduce(max);
    final pairCount = ranks.values.where((v) => v >= 2).length;

    // 포카드 (현재 또는 가능성)
    if (maxSameRank == 4) {
      strength = 0.93;
    }
    // 트리플 → 풀하우스/포카드 가능성
    else if (maxSameRank == 3) {
      // 트리플 + 남은 카드로 풀하우스/포카드 가능
      strength = 0.55 + (cardsRemaining * 0.08); // 최대 0.79
    }
    // 투페어 → 풀하우스 가능성
    else if (pairCount >= 2) {
      strength = 0.45 + (cardsRemaining * 0.05); // 최대 0.60
    }
    // 원페어 → 트리플/투페어/풀하우스 가능성
    else if (maxSameRank == 2) {
      final pairRank = ranks.entries.firstWhere((e) => e.value == 2).key;
      strength = 0.30 + (pairRank / 14) * 0.10 + (cardsRemaining * 0.04);
    }

    // 플러시 드로우 (4장 같은 무늬 = 매우 강함)
    if (maxSameSuit >= 4) {
      strength = max(strength, 0.65 + (cardsRemaining * 0.05));
    }
    // 플러시 드로우 (3장 같은 무늬)
    else if (maxSameSuit >= 3 && cardsRemaining >= 2) {
      strength += 0.12;
    }

    // 스트레이트 드로우 체크
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
    // A-2-3-4 또는 J-Q-K-A 체크
    if (sortedRanks.contains(14)) {
      // A를 1로도 사용 가능
      final lowStraight = [2, 3, 4, 5].where((r) => sortedRanks.contains(r)).length;
      final highStraight = [10, 11, 12, 13].where((r) => sortedRanks.contains(r)).length;
      maxConsecutive = max(maxConsecutive, lowStraight + 1);
      maxConsecutive = max(maxConsecutive, highStraight + 1);
    }

    // 거셧 스트레이트 드로우 체크 (중간 1장 빠진 경우: 3-4-6-7, 5-6-8-9 등)
    bool hasGutshot = false;
    if (sortedRanks.length >= 4) {
      for (int i = 0; i <= sortedRanks.length - 4; i++) {
        final span = sortedRanks[i + 3] - sortedRanks[i];
        // 4장이 5칸 범위 내에 있으면 거셧 (예: 3,4,6,7 = 7-3=4)
        if (span == 4) {
          hasGutshot = true;
          break;
        }
      }
    }
    // A를 포함한 거셧 체크 (A-2-3-5, A-3-4-5, 10-J-K-A, 10-Q-K-A 등)
    if (sortedRanks.contains(14) && sortedRanks.length >= 3) {
      // 로우 거셧: A를 1로 사용
      final lowCards = sortedRanks.where((r) => r <= 5 || r == 14).toList();
      if (lowCards.length >= 4) {
        final lowRanks = lowCards.map((r) => r == 14 ? 1 : r).toList()..sort();
        if (lowRanks.last - lowRanks.first == 4) hasGutshot = true;
      }
      // 하이 거셧: 10-J-Q-K-A 범위
      final highCards = sortedRanks.where((r) => r >= 10).toList();
      if (highCards.length >= 4 && highCards.last - highCards.first == 4) {
        hasGutshot = true;
      }
    }

    // 스트레이트 드로우 (4장 연속 = 양방향 오픈)
    if (maxConsecutive >= 4) {
      strength = max(strength, 0.55 + (cardsRemaining * 0.06));
    }
    // 스트레이트 드로우 (3장 연속)
    else if (maxConsecutive >= 3 && cardsRemaining >= 2) {
      strength += 0.10;
    }
    // 거셧 스트레이트 드로우 (중간 1장만 채우면 완성)
    else if (hasGutshot && cardsRemaining >= 1) {
      strength += 0.07;
    }

    // 하이카드 보너스 (A, K 등)
    final maxRank = cards.map((c) => c.rankValue).reduce(max);
    if (maxRank >= 12) { // Q 이상
      strength += (maxRank - 11) * 0.03;
    }

    return strength.clamp(0.0, 1.0);
  }

  /// 오픈 카드 기반 강도 조정
  double _adjustStrengthByOpenCards(double strength, SevenCardPlayer player) {
    // 상대 오픈 카드 분석
    for (final opponent in _state.players) {
      if (opponent.id == player.id || !opponent.isActive) continue;

      final openCards = opponent.openCards;
      if (openCards.isEmpty) continue;

      // 상대가 페어를 보여주면 경계 (감소 완화)
      final ranks = <int, int>{};
      for (final card in openCards) {
        ranks[card.rankValue] = (ranks[card.rankValue] ?? 0) + 1;
      }
      if (ranks.values.any((v) => v >= 2)) {
        strength -= 0.03;
      }

      // 상대가 플러시 드로우를 보여주면 경계 (감소 완화)
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

  /// AI 조정 강도 계산 (테스트용)
  double getAdjustedStrength(SevenCardPlayer player) {
    final hand = player.pokerHand;
    double handStrength = _evaluateHandStrength(player, hand);
    handStrength = _adjustStrengthByOpenCards(handStrength, player);

    final cardsRemaining = 7 - player.hand.length;
    final drawBonus = cardsRemaining * 0.05;

    return (handStrength + drawBonus).clamp(0.0, 1.0);
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

  /// AI 추천 베팅 액션 (플레이어용)
  RecommendedAction? getRecommendedAction() {
    if (_state.phase == SevenCardPhase.waiting ||
        _state.phase == SevenCardPhase.gameEnd ||
        _state.phase == SevenCardPhase.selectOpen) {
      return null;
    }
    if (_state.currentPlayerIndex != 0) return null; // 플레이어 턴이 아님

    final player = _state.humanPlayer;
    final aiAction = _decideAIAction(player);

    return RecommendedAction(
      action: aiAction.type,
      amount: _getActionAmount(aiAction.type),
    );
  }

  /// 액션별 금액 계산
  int _getActionAmount(String action) {
    switch (action) {
      case 'bing':
        return _state.getBingAmount();
      case 'call':
        return _state.getCallAmount();
      case 'ddadang':
        return _state.getDdadangAmount();
      case 'quarter':
        return _state.getQuarterAmount();
      case 'half':
        return _state.getHalfAmount();
      case 'full':
        return _state.getFullAmount();
      default:
        return 0;
    }
  }

  /// AI 추천 공개 카드 인덱스 (플레이어용)
  int? getRecommendedOpenCardIndex() {
    if (_state.phase != SevenCardPhase.selectOpen) return null;
    if (_state.currentPlayerIndex != 0) return null;

    final player = _state.humanPlayer;
    if (player.hand.isEmpty) return null;

    // AI와 동일 로직: 가장 높은 카드 공개 (위협용)
    int bestIndex = 0;
    int bestValue = 0;
    for (int i = 0; i < player.hand.length && i < 3; i++) {
      final value = player.hand[i].rankValue;
      if (value > bestValue) {
        bestValue = value;
        bestIndex = i;
      }
    }
    return bestIndex;
  }

  /// 추천 액션 이름 (한글)
  String getRecommendedActionName(RecommendedAction? action) {
    if (action == null) return '';
    switch (action.action) {
      case 'bing': return '삥';
      case 'check': return '체크';
      case 'call': return '콜';
      case 'ddadang': return '따당';
      case 'quarter': return '쿼터';
      case 'half': return '하프';
      case 'full': return '풀';
      case 'die': return '다이';
      default: return action.action;
    }
  }
}

/// AI 추천 액션 클래스
class RecommendedAction {
  final String action;
  final int amount;

  RecommendedAction({required this.action, required this.amount});
}

class _AIAction {
  final String type;
  final int amount;

  _AIAction(this.type, this.amount);
}
