import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import 'ai_player.dart';
import 'game_save_service.dart';

class GameController extends ChangeNotifier {
  late GameState _state;
  final AIPlayer _aiPlayer = AIPlayer();
  bool _isProcessing = false;
  bool _waitingForTrickConfirm = false;
  Trick? _lastCompletedTrick;
  static const String _gameType = 'mighty';
  bool _isAutoPlayMode = false;
  bool _isAutoPlayPaused = false;
  BidExplanation? _lastBidExplanation;
  bool _showBidSummary = false;
  KittyExplanation? _kittyExplanation;
  bool _showKittySummary = false;
  FriendExplanation? _friendExplanation;
  bool _showFriendSummary = false;
  FriendDeclaration? _pendingDeclaration;

  GameController() {
    _initializePlayers();
  }

  bool get isAutoPlayMode => _isAutoPlayMode;
  bool get isAutoPlayPaused => _isAutoPlayPaused;
  BidExplanation? get lastBidExplanation => _lastBidExplanation;
  bool get showBidSummary => _showBidSummary;
  KittyExplanation? get kittyExplanation => _kittyExplanation;
  bool get showKittySummary => _showKittySummary;
  FriendExplanation? get friendExplanation => _friendExplanation;
  bool get showFriendSummary => _showFriendSummary;
  FriendDeclaration? get pendingDeclaration => _pendingDeclaration;

  /// 주공의 현재 핸드 강도 계산 (키티 선택 후 기준)
  int getDeclarerStrength() {
    if (_state.declarerId == null) return 0;
    final declarer = _state.players[_state.declarerId!];
    return _aiPlayer.evaluateHandStrength(declarer.hand, _state.giruda);
  }

  /// 주공의 예상 득점 범위 (최소/최대 점수 카드 수)
  (int, int) getEstimatedPointRange() {
    if (_state.declarerId == null) return (0, 0);
    final declarer = _state.players[_state.declarerId!];
    return _aiPlayer.estimatePointRange(declarer.hand, _state.giruda);
  }

  // 저장된 게임이 있는지 확인
  static Future<bool> hasSavedGame() async {
    return await GameSaveService.hasSavedGame(_gameType);
  }

  // 게임 저장
  Future<void> saveGame() async {
    // 진행 중인 게임만 저장
    if (_state.phase == GamePhase.waiting || _state.phase == GamePhase.gameEnd) {
      return;
    }
    await GameSaveService.saveGame(_gameType, _state.toJson());
  }

  // 저장된 게임 불러오기
  Future<bool> loadGame() async {
    final savedData = await GameSaveService.loadGame(_gameType);
    if (savedData == null) {
      return false;
    }
    try {
      _state = GameState.fromJson(savedData);
      notifyListeners();
      // AI 턴이면 자동 진행
      _resumeAIIfNeeded();
      return true;
    } catch (e) {
      return false;
    }
  }

  // 저장된 게임 삭제
  Future<void> clearSavedGame() async {
    await GameSaveService.clearSave();
  }

  // 게임 재개 시 AI 턴이면 자동 진행
  void _resumeAIIfNeeded() {
    if (_isAutoPlayMode) {
      // auto-play: 모든 플레이어를 AI로 처리
      if (_state.phase == GamePhase.bidding) {
        _processBiddingIfNeeded();
      } else if (_state.phase == GamePhase.selectingKitty) {
        _processAIKittySelection();
      } else if (_state.phase == GamePhase.declaringFriend) {
        _processAIFriendDeclaration();
      } else if (_state.phase == GamePhase.playing) {
        _processAIPlayIfNeeded();
      }
    } else {
      if (_state.phase == GamePhase.bidding && _state.currentBidder != 0) {
        _processBiddingIfNeeded();
      } else if (_state.phase == GamePhase.selectingKitty && _state.declarerId != 0) {
        _processAIKittySelection();
      } else if (_state.phase == GamePhase.declaringFriend && _state.declarerId != 0) {
        _processAIFriendDeclaration();
      } else if (_state.phase == GamePhase.playing && _state.currentPlayer != 0) {
        _processAIPlayIfNeeded();
      }
    }
  }

  GameState get state => _state;
  bool get isProcessing => _isProcessing;
  bool get waitingForTrickConfirm => _waitingForTrickConfirm;
  Trick? get lastCompletedTrick => _lastCompletedTrick;

  Player get humanPlayer => _state.players[0];
  Player get currentPlayer => _state.players[_state.currentPlayer];
  bool get isHumanTurn =>
      _state.currentPlayer == 0 && !_isProcessing && !_waitingForTrickConfirm;

  void _initializePlayers() {
    final players = [
      Player(id: 0, name: 'Player', type: PlayerType.human),
      Player(id: 1, name: 'AI 1', type: PlayerType.ai),
      Player(id: 2, name: 'AI 2', type: PlayerType.ai),
      Player(id: 3, name: 'AI 3', type: PlayerType.ai),
      Player(id: 4, name: 'AI 4', type: PlayerType.ai),
    ];

    _state = GameState(players: players);
  }

  /// 지역화된 플레이어 이름으로 업데이트
  void updateLocalizedNames(List<String> names) {
    for (int i = 0; i < _state.players.length && i < names.length; i++) {
      _state.players[i].name = names[i];
    }
    notifyListeners();
  }

  void startNewGame() {
    _lastBidExplanation = null;
    _showBidSummary = false;
    _pendingDeclaration = null;
    _kittyExplanation = null;
    _showKittySummary = false;
    _friendExplanation = null;
    _showFriendSummary = false;
    _state.startNewGame();
    notifyListeners();
    if (!_isAutoPlayMode) saveGame(); // 자동 저장 (auto-play 시 스킵)
    _processBiddingIfNeeded();
  }

  void _processBiddingIfNeeded() async {
    if (_state.phase != GamePhase.bidding) return;
    if (!_isAutoPlayMode && _state.currentBidder == 0) return;

    _isProcessing = true;
    notifyListeners();

    if (_isAutoPlayMode) {
      // auto-play: 먼저 배팅 결정 + 설명 생성 후 5초 표시
      await Future.delayed(const Duration(milliseconds: 500));
      if (_state.phase != GamePhase.bidding) return;
      if (_isAutoPlayPaused) { _isProcessing = false; notifyListeners(); return; }

      final currentPlayer = _state.players[_state.currentBidder];
      final (bid, evaluation) = _aiPlayer.decideBidWithEvaluation(currentPlayer, _state);

      var effectiveSuit = evaluation.bestGiruda;

      // bestGiruda가 없어도 가장 긴 무늬 찾기 (패스 시 표시용)
      if (effectiveSuit == null) {
        Suit? longestSuit;
        int longestCount = 0;
        for (final s in Suit.values) {
          final cnt = currentPlayer.hand.where((c) => !c.isJoker && c.suit == s).length;
          if (cnt > longestCount) {
            longestCount = cnt;
            longestSuit = s;
          }
        }
        if (longestCount >= 4) effectiveSuit = longestSuit;
      }

      final hasMighty = currentPlayer.hand.any((c) => c.suit == Suit.spade && c.rank == Rank.ace && !c.isJoker);
      final hasJoker = currentPlayer.hand.any((c) => c.isJoker);

      String passReason = '';
      if (bid.passed) {
        if (evaluation.optimalPoints < 13) {
          passReason = 'LOW_POINTS';
        } else {
          passReason = 'OUTBID';
        }
      }

      // 프렌드 예상 계산 (배팅한 경우)
      String? friendType;
      Suit? friendSuit;
      String? friendHolderName;

      if (!bid.passed) {
        final mightySuit = (effectiveSuit == Suit.spade) ? Suit.diamond : Suit.spade;

        if (!hasMighty) {
          // 마이티를 프렌드로 지명할 가능성 높음
          friendType = 'MIGHTY';
          friendSuit = mightySuit;
          for (final p in _state.players) {
            if (p.id == currentPlayer.id) continue;
            if (p.hand.any((c) => !c.isJoker && c.suit == mightySuit && c.rank == Rank.ace)) {
              friendHolderName = p.name;
              break;
            }
          }
        } else if (!hasJoker) {
          // 조커를 프렌드로 지명할 가능성 높음
          friendType = 'JOKER';
          for (final p in _state.players) {
            if (p.id == currentPlayer.id) continue;
            if (p.hand.any((c) => c.isJoker)) {
              friendHolderName = p.name;
              break;
            }
          }
        } else {
          // 둘 다 보유 → AI declareFriend 로직과 동일 순서로 예측
          // 1. 기루다 A 없으면 → 기루다 A 프렌드
          // 2. 기루다 K 없으면 → 기루다 K 프렌드
          // 3. 비기루다 A 중 없는 것 → 해당 A 프렌드
          bool found = false;
          if (effectiveSuit != null) {
            // 기루다 A 체크 (마이티가 아닌 경우)
            final mightyIsGirudaAce = mightySuit == effectiveSuit;
            if (!mightyIsGirudaAce) {
              bool hasGirudaAce = currentPlayer.hand.any((c) =>
                  !c.isJoker && c.suit == effectiveSuit && c.rank == Rank.ace);
              if (!hasGirudaAce) {
                friendType = 'GIRUDA_ACE';
                friendSuit = effectiveSuit;
                for (final p in _state.players) {
                  if (p.id == currentPlayer.id) continue;
                  if (p.hand.any((c) => !c.isJoker && c.suit == effectiveSuit && c.rank == Rank.ace)) {
                    friendHolderName = p.name;
                    break;
                  }
                }
                found = true;
              }
            }
            // 기루다 K 체크
            if (!found) {
              bool hasGirudaKing = currentPlayer.hand.any((c) =>
                  !c.isJoker && c.suit == effectiveSuit && c.rank == Rank.king);
              if (!hasGirudaKing) {
                friendType = 'GIRUDA_KING';
                friendSuit = effectiveSuit;
                for (final p in _state.players) {
                  if (p.id == currentPlayer.id) continue;
                  if (p.hand.any((c) => !c.isJoker && c.suit == effectiveSuit && c.rank == Rank.king)) {
                    friendHolderName = p.name;
                    break;
                  }
                }
                found = true;
              }
            }
          }
          // 비기루다 A 중 없는 것
          if (!found) {
            friendType = 'ACE';
            for (final s in Suit.values) {
              if (s == effectiveSuit) continue;
              final isMightySuitHere = (effectiveSuit == Suit.spade) ? s == Suit.diamond : s == Suit.spade;
              if (isMightySuitHere) continue;
              if (currentPlayer.hand.any((c) => !c.isJoker && c.suit == s && c.rank == Rank.ace)) continue;
              friendSuit = s;
              for (final p in _state.players) {
                if (p.id == currentPlayer.id) continue;
                if (p.hand.any((c) => !c.isJoker && c.suit == s && c.rank == Rank.ace)) {
                  friendHolderName = p.name;
                  break;
                }
              }
              break;
            }
          }
        }
      }

      _lastBidExplanation = BidExplanation(
        playerId: currentPlayer.id,
        playerName: currentPlayer.name,
        passed: bid.passed,
        suit: effectiveSuit,
        tricks: bid.tricks,
        minPoints: evaluation.minPoints,
        maxPoints: evaluation.maxPoints,
        optimalPoints: evaluation.optimalPoints,
        girudaCount: evaluation.girudaCount,
        passReason: passReason,
        friendType: friendType,
        friendSuit: friendSuit,
        friendHolderName: friendHolderName,
      );

      _state.placeBid(bid);
      _isProcessing = false;
      notifyListeners();

      // 설명을 5초간 표시 후 다음 진행
      await Future.delayed(const Duration(seconds: 5));
      if (_state.phase != GamePhase.bidding && !(_state.phase == GamePhase.waiting && _state.allPassed) && _state.phase != GamePhase.selectingKitty) return;
      if (_isAutoPlayPaused) return;

      if (_state.phase == GamePhase.bidding) {
        _processBiddingIfNeeded();
      } else if (_state.phase == GamePhase.selectingKitty) {
        if (_state.declarerId != 0 || _isAutoPlayMode) {
          _processAIKittySelection();
        }
      } else if (_state.phase == GamePhase.waiting && _state.allPassed) {
        // UI에서 "다음 게임" 버튼으로 처리
        notifyListeners();
      }
    } else {
      // 일반 모드
      await Future.delayed(const Duration(milliseconds: 800));
      if (_state.phase != GamePhase.bidding) return;

      final currentPlayer = _state.players[_state.currentBidder];
      final bid = _aiPlayer.decideBid(currentPlayer, _state);
      _state.placeBid(bid);

      _isProcessing = false;
      notifyListeners();
      saveGame();

      if (_state.phase == GamePhase.bidding) {
        _processBiddingIfNeeded();
      } else if (_state.phase == GamePhase.selectingKitty) {
        if (_state.declarerId != 0) {
          _processAIKittySelection();
        }
      }
    }
  }

  void humanBid(Bid bid) {
    if (_state.currentBidder != 0) return;

    _state.placeBid(bid);
    notifyListeners();
    saveGame(); // 자동 저장

    if (_state.phase == GamePhase.bidding) {
      _processBiddingIfNeeded();
    } else if (_state.phase == GamePhase.selectingKitty &&
        _state.declarerId != 0) {
      _processAIKittySelection();
    }
  }

  void humanPass() {
    humanBid(Bid.pass(0));
  }

  // 딜 미스 선언 가능 여부
  bool get canHumanDeclareDealMiss {
    if (_state.phase != GamePhase.bidding) return false;
    if (_state.currentBidder != 0) return false;
    return humanPlayer.canDeclareDealMiss;
  }

  // 딜 미스 선언
  void humanDeclareDealMiss() {
    if (!canHumanDeclareDealMiss) return;

    _state.declareDealMiss(0);
    notifyListeners();

    // AI가 딜 미스 체크 후 배팅 진행
    _processAIDealMissCheck();
  }

  // AI 딜 미스 체크 후 배팅 진행
  void _processAIDealMissCheck() async {
    while (_state.phase == GamePhase.bidding && _state.currentBidder != 0) {
      final currentPlayer = _state.players[_state.currentBidder];

      // AI 딜 미스 체크
      if (currentPlayer.canDeclareDealMiss) {
        // AI는 점수 카드가 0개일 때만 딜 미스 선언 (조커+1개는 플레이 시도)
        final pointCards = currentPlayer.hand.where((c) => c.isPointCard).length;
        if (pointCards == 0) {
          _isProcessing = true;
          notifyListeners();

          await Future.delayed(const Duration(milliseconds: 800));

          _state.declareDealMiss(_state.currentBidder);

          _isProcessing = false;
          notifyListeners();

          // 딜 미스 후 다시 체크
          continue;
        }
      }

      // 딜 미스 안하면 배팅 진행
      break;
    }

    _processBiddingIfNeeded();
  }

  void _processAIKittySelection() async {
    _isProcessing = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: _isAutoPlayMode ? 600 : 1000));
    if (_isAutoPlayMode && _state.phase != GamePhase.selectingKitty) return;
    if (_isAutoPlayPaused) { _isProcessing = false; notifyListeners(); return; }

    final declarer = _state.players[_state.declarerId!];
    final originalGiruda = _state.giruda;

    // 키티 카드 저장 (selectKitty 호출 전에)
    final kittyCards = List<PlayingCard>.from(_state.kitty);

    // 1. 13장으로 기루다 변경 여부 결정
    final newGiruda = _aiPlayer.decideGirudaChange(declarer, _state, _state.kitty);

    // 2. 최종 기루다를 기준으로 버릴 카드 선택
    final discardCards = _aiPlayer.selectKittyCardsWithGiruda(declarer, _state, _state.kitty, newGiruda);

    if (_isAutoPlayMode) {
      // 각 버릴 카드의 이유 생성
      final reasons = _generateDiscardReasons(discardCards, newGiruda, declarer);
      final girudaChanged = newGiruda != originalGiruda;

      // 최종 보유 카드 계산: (기존 10장 + 키티 3장) - 버릴 3장
      final allCards = [...declarer.hand, ...kittyCards];
      final finalHand = allCards.where((c) => !discardCards.contains(c)).toList();
      // 무늬별 정렬
      finalHand.sort((a, b) {
        if (a.isJoker) return -1;
        if (b.isJoker) return 1;
        if (a.suit != b.suit) return a.suit!.index.compareTo(b.suit!.index);
        return b.rankValue.compareTo(a.rankValue);
      });

      _kittyExplanation = KittyExplanation(
        kittyCards: kittyCards,
        discardCards: discardCards,
        finalHand: finalHand,
        originalGiruda: originalGiruda,
        newGiruda: newGiruda,
        girudaChanged: girudaChanged,
        discardReasons: reasons,
      );

      // 요약 화면 표시 (selectKitty 호출 전)
      _showKittySummary = true;
      _isProcessing = false;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 5));
      if (_isAutoPlayPaused) return;

      // 키티 선택 실행
      _showKittySummary = false;
      _state.selectKitty(discardCards, newGiruda);
      _kittyExplanation = null;
      notifyListeners();

      _processAIFriendDeclaration();
    } else {
      // 일반 모드: 즉시 실행
      _state.selectKitty(discardCards, newGiruda);
      _isProcessing = false;
      notifyListeners();
      saveGame();

      _processAIFriendDeclaration();
    }
  }

  void humanSelectKitty(List<PlayingCard> discardCards, Suit? newGiruda, {bool isFull = false}) {
    if (_state.declarerId != 0) return;
    if (discardCards.length != 3) return;

    _state.selectKitty(discardCards, newGiruda);
    if (isFull) {
      _state.declareFull();
    }
    notifyListeners();
    saveGame(); // 자동 저장
  }

  void _processAIFriendDeclaration() async {
    if (!_isAutoPlayMode && _state.declarerId == 0) return;

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: _isAutoPlayMode ? 500 : 800));
    if (_isAutoPlayMode && _state.phase != GamePhase.declaringFriend) return;
    if (_isAutoPlayPaused) { _isProcessing = false; notifyListeners(); return; }

    final declarer = _state.players[_state.declarerId!];
    final declaration = _aiPlayer.declareFriend(declarer, _state);

    // 풀(20) 선언 여부 검토 (노프렌드, 마이티 프렌드, 조커 프렌드)
    final isFull = _aiPlayer.shouldDeclareFull(declarer, _state, declaration);
    if (isFull) {
      _state.declareFull();
    }

    if (_isAutoPlayMode) {
      // 프렌드 선택 이유 생성
      final reason = _generateFriendReason(declaration, declarer, _state);
      final firstTrickInfo = _analyzeFirstTrick(declarer, _state);
      final strategyPoints = _generateStrategyPoints(declarer, _state);

      _friendExplanation = FriendExplanation(
        declaration: declaration,
        reason: reason,
        isFull: isFull,
        firstTrickCard: firstTrickInfo.$1,
        firstTrickStrategy: firstTrickInfo.$2,
        strategyPoints: strategyPoints,
      );

      // declareFriend 호출 전에 요약 화면 표시 (호출 시 phase가 playing으로 변경됨)
      _showFriendSummary = true;
      _isProcessing = false;
      notifyListeners();

      await Future.delayed(const Duration(seconds: 5));
      if (_isAutoPlayPaused) return;

      _showFriendSummary = false;
      _friendExplanation = null;
      notifyListeners();

      // 배팅 결과 요약 화면 표시 (버튼 클릭 시 진행)
      _pendingDeclaration = declaration;
      _showBidSummary = true;
      _lastBidExplanation = null;
      notifyListeners();
    } else {
      _state.declareFriend(declaration);
      _isProcessing = false;
      notifyListeners();
      saveGame();
      _processAIPlayIfNeeded();
    }
  }

  void humanDeclareFriend(FriendDeclaration declaration) {
    if (_state.declarerId != 0) return;

    _state.declareFriend(declaration);
    notifyListeners();
    saveGame(); // 자동 저장

    _processAIPlayIfNeeded();
  }

  void _processAIPlayIfNeeded() async {
    if (_state.phase != GamePhase.playing) return;
    if (!_isAutoPlayMode && _state.currentPlayer == 0) return;
    if (_waitingForTrickConfirm) return;

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(Duration(milliseconds: _isAutoPlayMode ? 300 : 600));
    if (!_isAutoPlayMode && _state.phase != GamePhase.playing) return;
    if (_isAutoPlayMode && _state.phase != GamePhase.playing) return;
    if (_isAutoPlayPaused) { _isProcessing = false; notifyListeners(); return; }

    final currentPlayer = _state.players[_state.currentPlayer];
    PlayingCard card;
    Suit? jokerLeadSuit;

    // AI 조커 콜 결정 (선공 시에만)
    if (_state.currentTrick != null && _state.currentTrick!.cards.isEmpty) {
      final jokerCallSuit = _aiPlayer.decideJokerCall(currentPlayer, _state);
      if (jokerCallSuit != null) {
        _state.declareJokerCall(jokerCallSuit);
        notifyListeners();
        await Future.delayed(Duration(milliseconds: _isAutoPlayMode ? 300 : 500));
        // 조커 콜 시 조커 콜 카드를 냄
        card = _state.jokerCall;
      } else {
        card = _aiPlayer.selectCard(currentPlayer, _state);
        // 조커 선공 시 무늬 결정
        if (card.isJoker) {
          jokerLeadSuit = _aiPlayer.selectJokerLeadSuit(currentPlayer, _state);
        }
        // 조커콜 카드를 내는데 조커콜을 선언하지 않은 경우 자동 선언
        // (조커가 없고, 조커가 아직 플레이되지 않았을 때만)
        final jokerCallCard = _state.jokerCall;
        if (card.suit == jokerCallCard.suit && card.rank == jokerCallCard.rank) {
          bool hasJoker = currentPlayer.hand.any((c) => c.isJoker);
          // 조커 프렌드인 경우 주공/프렌드는 자동 조커콜 안 함
          final friendCard = _state.friendDeclaration?.card;
          bool isJokerFriend = friendCard != null && friendCard.isJoker;
          bool isAttackTeam = currentPlayer.isDeclarer || currentPlayer.isFriend;
          if (!hasJoker && !_state.isJokerPlayed && _state.currentTrickNumber > 1 &&
              !(isJokerFriend && isAttackTeam)) {
            _state.declareJokerCall(jokerCallCard.suit!);
            notifyListeners();
            await Future.delayed(Duration(milliseconds: _isAutoPlayMode ? 300 : 500));
          }
        }
      }
    } else {
      card = _aiPlayer.selectCard(currentPlayer, _state);
    }

    // 트릭 완료 여부 확인을 위해 현재 트릭 수 저장
    final trickCountBefore = _state.tricks.length;

    _state.playCard(card, currentPlayer.id, jokerLeadSuit: jokerLeadSuit);

    _isProcessing = false;

    // 트릭이 완료되었는지 확인
    if (_state.tricks.length > trickCountBefore && _state.phase == GamePhase.playing) {
      _lastCompletedTrick = _state.tricks.last;
      if (_isAutoPlayMode) {
        // auto-play: 일시정지 중이면 멈춤, 아니면 2초 후 자동 진행
        _waitingForTrickConfirm = true;
        notifyListeners();
        if (!_isAutoPlayPaused) {
          await Future.delayed(const Duration(seconds: 2));
          if (_isAutoPlayMode && _waitingForTrickConfirm && !_isAutoPlayPaused) {
            confirmTrick();
          }
        }
      } else {
        // 사용자가 다음 선공이면 확인 없이 바로 카드 선택 가능
        if (_state.currentPlayer == 0) {
          _waitingForTrickConfirm = false;
        } else {
          _waitingForTrickConfirm = true;
        }
        notifyListeners();
        saveGame(); // 자동 저장
      }
      return;
    }

    // 게임 종료
    if (_state.phase == GamePhase.gameEnd) {
      if (_isAutoPlayMode) {
        notifyListeners();
        return;
      } else {
        clearSavedGame();
      }
    }

    notifyListeners();
    if (!_isAutoPlayMode) saveGame(); // 자동 저장

    if (_state.phase == GamePhase.playing) {
      _processAIPlayIfNeeded();
    }
  }

  void humanPlayCard(PlayingCard card, {Suit? jokerCallSuit, Suit? jokerLeadSuit}) {
    if (_state.currentPlayer != 0) return;
    if (!_state.canPlayCard(card, humanPlayer)) return;
    // 사용자가 선공일 때는 확인 대기 중이 아니므로 카드 낼 수 있음
    if (_waitingForTrickConfirm && _state.currentPlayer != 0) return;

    // 이전 트릭 표시 정리
    _lastCompletedTrick = null;

    // 조커 콜 선언 (선공 시에만)
    if (jokerCallSuit != null && isLeadingTrick) {
      _state.declareJokerCall(jokerCallSuit);
    }

    // 트릭 완료 여부 확인을 위해 현재 트릭 수 저장
    final trickCountBefore = _state.tricks.length;

    _state.playCard(card, 0, jokerLeadSuit: jokerLeadSuit);

    // 트릭이 완료되었는지 확인
    if (_state.tricks.length > trickCountBefore && _state.phase == GamePhase.playing) {
      _lastCompletedTrick = _state.tricks.last;
      // 사용자가 다음 선공이면 확인 없이 바로 카드 선택 가능
      if (_state.currentPlayer == 0) {
        _waitingForTrickConfirm = false;
      } else {
        _waitingForTrickConfirm = true;
      }
      notifyListeners();
      saveGame(); // 자동 저장
      return; // 사용자 확인 대기 또는 카드 선택 대기
    }

    // 게임 종료 시 저장 삭제
    if (_state.phase == GamePhase.gameEnd) {
      clearSavedGame();
    }

    notifyListeners();
    saveGame(); // 자동 저장

    if (_state.phase == GamePhase.playing) {
      _processAIPlayIfNeeded();
    }
  }

  // 사용자가 다음 선공인지 확인 (트릭 완료 후)
  bool get isHumanLeaderAfterTrick =>
      _lastCompletedTrick != null && _state.currentPlayer == 0 && !_waitingForTrickConfirm;

  // 트릭 확인 후 다음 단계 진행
  void confirmTrick() {
    if (!_waitingForTrickConfirm) return;

    _waitingForTrickConfirm = false;
    _lastCompletedTrick = null;
    notifyListeners();

    if (_state.phase == GamePhase.playing) {
      _processAIPlayIfNeeded();
    }
  }

  // 현재 트릭의 선공인지 확인
  bool get isLeadingTrick =>
      _state.currentTrick != null && _state.currentTrick!.cards.isEmpty;

  // 조커 콜이 가능한지 확인 (첫 트릭이 아니고, 선공이고, 조커가 아직 플레이되지 않은 경우)
  bool get canDeclareJokerCall =>
      _state.currentTrickNumber > 1 &&
      isLeadingTrick &&
      _state.currentPlayer == 0 &&
      !_state.isJokerPlayed;

  List<PlayingCard> getPlayableCards() {
    return humanPlayer.hand
        .where((card) => _state.canPlayCard(card, humanPlayer))
        .toList();
  }

  bool canPlayCard(PlayingCard card) {
    return _state.canPlayCard(card, humanPlayer);
  }

  String? getCannotPlayReason(PlayingCard card) {
    return _state.getCannotPlayReason(card, humanPlayer);
  }

  /// 사용자에게 추천할 카드를 반환
  /// AI 로직을 사용하여 최적의 카드를 선택
  PlayingCard? getRecommendedCard() {
    if (_state.phase != GamePhase.playing) return null;
    if (_state.currentPlayer != 0) return null;

    final playableCards = getPlayableCards();
    if (playableCards.isEmpty) return null;
    if (playableCards.length == 1) return playableCards.first;

    // AI 로직을 사용하여 추천 카드 선택
    return _aiPlayer.selectCard(humanPlayer, _state);
  }

  /// 사용자에게 추천할 배팅을 반환
  /// AI 로직을 사용하여 최적의 배팅을 선택
  Bid? getRecommendedBid() {
    if (_state.phase != GamePhase.bidding) return null;
    if (_state.currentBidder != 0) return null;
    if (_state.passedPlayers[0]) return null;

    // AI 로직을 사용하여 추천 배팅 선택
    return _aiPlayer.decideBid(humanPlayer, _state);
  }

  void startAutoPlay() {
    _isAutoPlayMode = true;
    _isAutoPlayPaused = false;
    startNewGame();
  }

  void stopAutoPlay() {
    _isAutoPlayMode = false;
    _isAutoPlayPaused = false;
    _isProcessing = false;
    _waitingForTrickConfirm = false;
    _showBidSummary = false;
    _pendingDeclaration = null;
    _kittyExplanation = null;
    _showKittySummary = false;
    _friendExplanation = null;
    _showFriendSummary = false;
    _lastCompletedTrick = null;
    _initializePlayers();
    notifyListeners();
  }

  void pauseAutoPlay() {
    _isAutoPlayPaused = true;
    notifyListeners();
  }

  void resumeAutoPlay() {
    if (!_isAutoPlayMode || !_isAutoPlayPaused) return;
    _isAutoPlayPaused = false;
    notifyListeners();
    // 트릭 확인 대기 중이면 confirmTrick으로 진행
    if (_waitingForTrickConfirm) {
      confirmTrick();
      return;
    }
    // 키티 요약 화면에서 일시정지 후 재개 시 프렌드 선언으로 진행
    if (_showKittySummary && _kittyExplanation != null) {
      _showKittySummary = false;
      _state.selectKitty(_kittyExplanation!.discardCards, _kittyExplanation!.newGiruda);
      _kittyExplanation = null;
      notifyListeners();
      _processAIFriendDeclaration();
      return;
    }
    // 프렌드 요약 화면에서 일시정지 후 재개 시 플레이로 진행
    if (_showFriendSummary && _friendExplanation != null) {
      _showFriendSummary = false;
      final declaration = _friendExplanation!.declaration;
      _friendExplanation = null;
      _state.declareFriend(declaration);
      notifyListeners();
      _processAIPlayIfNeeded();
      return;
    }
    // 배팅 요약 화면에서 일시정지 후 재개 시 버튼 대기 (자동 진행 안 함)
    if (_showBidSummary && _pendingDeclaration != null) {
      // 버튼 클릭으로 진행하므로 resume만 하고 화면 유지
      return;
    }
    _resumeAIIfNeeded();
  }

  void startNextAutoGame() {
    if (!_isAutoPlayMode) return;
    _isAutoPlayPaused = false;
    startNewGame();
  }

  void confirmBidSummary() {
    if (!_showBidSummary || _pendingDeclaration == null) return;
    _showBidSummary = false;
    _state.declareFriend(_pendingDeclaration!);
    _pendingDeclaration = null;
    notifyListeners();
    _processAIPlayIfNeeded();
  }

  /// 버릴 카드의 이유 생성
  List<String> _generateDiscardReasons(List<PlayingCard> discardCards, Suit? finalGiruda, Player declarer) {
    final hand = [...declarer.hand, ..._state.kitty];
    // 각 무늬별 카드 수 (기루다 제외)
    final suitCounts = <Suit, int>{};
    for (final suit in Suit.values) {
      suitCounts[suit] = hand.where((c) => !c.isJoker && c.suit == suit).length;
    }

    return discardCards.map((card) {
      if (card.isJoker) return 'SPECIAL'; // 조커는 보통 버리지 않음

      final isGiruda = card.suit == finalGiruda;
      final suitCount = suitCounts[card.suit] ?? 0;
      final isPointCard = card.isPointCard;

      if (!isGiruda && suitCount <= 2) {
        return 'CUT_SUIT'; // 무늬 정리 → 컷 가능
      } else if (!isGiruda && !isPointCard) {
        return 'NON_GIRUDA_LOW'; // 비기루다 낮은 카드
      } else if (!isPointCard) {
        return 'LOW_VALUE'; // 낮은 가치
      } else {
        return 'LEAST_USEFUL'; // 가장 불필요
      }
    }).toList();
  }

  /// 프렌드 선택 이유 생성
  String _generateFriendReason(FriendDeclaration declaration, Player declarer, GameState state) {
    if (declaration.isNoFriend) {
      return 'NO_FRIEND_STRONG';
    }
    if (declaration.isFirstTrickWinner) {
      return 'FIRST_TRICK';
    }
    if (declaration.trickNumber != null) {
      return 'NTH_TRICK';
    }
    if (declaration.card != null) {
      final card = declaration.card!;
      final mighty = state.mighty;
      if (card.suit == mighty.suit && card.rank == mighty.rank) {
        return 'NEED_MIGHTY';
      }
      if (card.isJoker) {
        return 'NEED_JOKER';
      }
      if (state.giruda != null && card.suit == state.giruda) {
        if (card.rank == Rank.ace) return 'NEED_GIRUDA_ACE';
        if (card.rank == Rank.king) return 'NEED_GIRUDA_KING';
        return 'NEED_GIRUDA_MID';
      }
      if (card.rank == Rank.ace) return 'NEED_ACE';
      return 'NEED_STRONG_CARD';
    }
    return '';
  }

  /// 초구 분석: (추천 카드, 전략 코드)
  (PlayingCard?, String) _analyzeFirstTrick(Player declarer, GameState state) {
    final hand = declarer.hand;
    final giruda = state.giruda;

    // 초구에서는 주공이 선공, 기루다 선공 불가
    // 비기루다 중 가장 강한 카드 찾기
    PlayingCard? bestFirstCard;
    String strategy = '';

    // 비기루다 에이스 찾기 (마이티 제외)
    for (final card in hand) {
      if (card.isJoker) continue;
      if (card.suit == giruda) continue;
      if (card.suit == state.mighty.suit && card.rank == state.mighty.rank) continue;

      if (card.rank == Rank.ace) {
        bestFirstCard = card;
        strategy = 'FIRST_ACE';
        break;
      }
    }

    // 에이스 없으면 킹 찾기
    if (bestFirstCard == null) {
      for (final card in hand) {
        if (card.isJoker) continue;
        if (card.suit == giruda) continue;
        if (card.rank == Rank.king) {
          bestFirstCard = card;
          strategy = 'FIRST_KING';
          break;
        }
      }
    }

    // 킹도 없으면 적은 무늬의 낮은 카드 (초구 포기)
    if (bestFirstCard == null) {
      final nonGirudaCards = hand.where((c) => !c.isJoker && c.suit != giruda).toList();
      if (nonGirudaCards.isNotEmpty) {
        nonGirudaCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
        bestFirstCard = nonGirudaCards.first;
        strategy = 'FIRST_GIVE_UP';
      }
    }

    return (bestFirstCard, strategy);
  }

  /// 점수 획득 전략 생성 (손패 기반 구체적 전략)
  List<String> _generateStrategyPoints(Player declarer, GameState state) {
    final hand = declarer.hand;
    final giruda = state.giruda;
    final strategies = <String>[];

    // 헬퍼: 카드 표시
    String ss(Suit? s) => switch (s) {
      Suit.spade => '♠', Suit.heart => '♥',
      Suit.diamond => '♦', Suit.club => '♣', _ => ''
    };
    String rs(Rank? r) => switch (r) {
      Rank.ace => 'A', Rank.king => 'K', Rank.queen => 'Q',
      Rank.jack => 'J', Rank.ten => '10', Rank.nine => '9',
      Rank.eight => '8', Rank.seven => '7', Rank.six => '6',
      Rank.five => '5', Rank.four => '4', Rank.three => '3',
      Rank.two => '2', _ => ''
    };
    String cs(PlayingCard c) => c.isJoker ? '조커' : '${ss(c.suit)}${rs(c.rank)}';

    final hasMighty = hand.any((c) => c.isMightyWith(giruda));
    final hasJoker = hand.any((c) => c.isJoker);
    final friendCard = state.friendDeclaration?.card;
    final mightySuit = state.mighty.suit;

    // === 0. 초구 전략 ===
    // 비기루다 A 찾기 (마이티 제외)
    PlayingCard? firstTrickAce;
    for (final card in hand) {
      if (card.isJoker || card.isMightyWith(giruda)) continue;
      if (card.suit == giruda) continue;
      if (card.rank == Rank.ace && card.suit != mightySuit) {
        firstTrickAce = card;
        break;
      }
    }
    if (firstTrickAce != null) {
      strategies.add('초구: ${cs(firstTrickAce)}로 선공하여 확실한 트릭 획득');
    } else {
      // A 없으면 프렌드 타입에 따라 초구 설명
      if (friendCard != null && (friendCard.isMightyWith(giruda) || friendCard.isJoker)) {
        strategies.add('초구: 적은 무늬 저액으로 프렌드에게 선 넘기기 (프렌드가 트릭 획득)');
      } else {
        // 비기루다 K 확인
        PlayingCard? firstTrickKing;
        for (final card in hand) {
          if (card.isJoker || card.isMightyWith(giruda)) continue;
          if (card.suit == giruda) continue;
          if (card.rank == Rank.king) { firstTrickKing = card; break; }
        }
        if (firstTrickKing != null) {
          strategies.add('초구: ${cs(firstTrickKing)}로 선공 (A가 나왔으면 승리)');
        } else {
          strategies.add('초구: 적은 무늬 저액으로 프렌드에게 선 넘기기');
        }
      }
    }

    // 기루다 카드 (마이티 제외, 높은 순)
    final girudaCards = giruda != null
        ? (hand.where((c) => !c.isJoker && !c.isMightyWith(giruda) && c.suit == giruda).toList()
          ..sort((a, b) => b.rankValue.compareTo(a.rankValue)))
        : <PlayingCard>[];
    final highGiruda = girudaCards.where((c) => c.rankValue >= 12).toList(); // A,K,Q

    // void 무늬 (비기루다)
    Set<Suit> voidSuits = {};
    for (final suit in Suit.values) {
      if (suit == giruda) continue;
      if (!hand.any((c) => !c.isJoker && !c.isMightyWith(giruda) && c.suit == suit)) {
        voidSuits.add(suit);
      }
    }

    // 물패 무늬 (void 또는 A없이 1-2장)
    List<Suit> weakSuits = [];
    for (final suit in Suit.values) {
      if (suit == giruda) continue;
      final sc = hand.where((c) => !c.isJoker && !c.isMightyWith(giruda) && c.suit == suit).toList();
      if (sc.isEmpty) { weakSuits.add(suit); continue; }
      if (!sc.any((c) => c.rank == Rank.ace) && sc.length <= 2) weakSuits.add(suit);
    }

    // === 1. 프렌드 연결 전략 ===
    bool friendIsGirudaCard = false;
    if (friendCard != null) {
      if (friendCard.isMightyWith(giruda)) {
        strategies.add('적은 무늬 저액으로 프렌드(마이티)에게 선 넘기기');
      } else if (friendCard.isJoker) {
        strategies.add('적은 무늬 저액으로 프렌드(조커)에게 선 넘기기');
      } else if (friendCard.suit == giruda && giruda != null) {
        // 기루다 프렌드 (예: ♦K) → 9이하 중간 기루다(높은 순)로 선 넘기기
        friendIsGirudaCard = true;
        final lowerGiruda = girudaCards.where((c) => c.rankValue < friendCard.rankValue).toList();
        if (lowerGiruda.isNotEmpty) {
          // 9이하 중간 기루다 우선 (AI 로직과 일치)
          final midGiruda = lowerGiruda.where((c) => c.rankValue <= 9).toList();
          PlayingCard passCard;
          if (midGiruda.isNotEmpty) {
            midGiruda.sort((a, b) => b.rankValue.compareTo(a.rankValue));
            passCard = midGiruda.first;
          } else {
            lowerGiruda.sort((a, b) => a.rankValue.compareTo(b.rankValue));
            passCard = lowerGiruda.first;
          }
          strategies.add('${cs(passCard)}로 프렌드(${cs(friendCard)})에게 선 넘기기 → ${rs(friendCard.rank)}딸랑 방지');
        }
      } else if (friendCard.suit != null) {
        // 비기루다 프렌드 (예: ♥K)
        final friendSuitCards = hand.where((c) =>
            !c.isJoker && !c.isMightyWith(giruda) &&
            c.suit == friendCard.suit &&
            c.rankValue < friendCard.rankValue).toList();
        if (friendSuitCards.isNotEmpty) {
          friendSuitCards.sort((a, b) => a.rankValue.compareTo(b.rankValue));
          strategies.add('${cs(friendSuitCards.first)}로 프렌드(${cs(friendCard)})에게 선 넘기기');
        }
      }
    }

    // === 2. 기루다 공격 전략 ===
    if (giruda != null && highGiruda.isNotEmpty) {
      final highNames = highGiruda.map((c) => rs(c.rank)).join('/');
      // 기루다 프렌드 → "프렌드 트릭 후" / 그 외 → "선 탈환 후"
      final leadSource = friendIsGirudaCard ? '프렌드 트릭 후' : '선 탈환 후';
      if (girudaCards.length >= 5) {
        strategies.add('$leadSource ${ss(giruda)}$highNames로 기루다 지배 → 수비팀 기루다 소진');
      } else {
        strategies.add('$leadSource ${ss(giruda)}$highNames로 수비팀 기루다 소진');
      }
    } else if (giruda != null && girudaCards.length >= 3) {
      strategies.add('${ss(giruda)}중간 기루다로 수비팀 고액 기루다 소진 유도');
    }

    // === 3. 조커 활용 전략 ===
    if (hasJoker && giruda != null) {
      final callSuits = weakSuits.map((s) => ss(s)).toList();
      if (callSuits.isNotEmpty && callSuits.length <= 3) {
        strategies.add('수비팀 기루다 소진 후 조커로 물패 무늬(${callSuits.join("/")}) 호출');
      } else {
        strategies.add('수비팀 기루다 소진 후 조커로 물패 무늬 호출');
      }
    } else if (hasJoker) {
      strategies.add('조커로 원하는 타이밍에 트릭 획득');
    }

    // === 4. 마이티 타이밍 ===
    if (hasMighty) {
      strategies.add('마이티를 9트릭에서 사용 → 10트릭 선행 확보');
    }

    // === 5. 컷 전략 ===
    if (voidSuits.isNotEmpty && giruda != null && girudaCards.isNotEmpty) {
      final voidSymbols = voidSuits.map((s) => ss(s)).join("/");
      strategies.add('$voidSymbols void → 상대 선공 시 기루다 컷으로 트릭 탈환');
    }

    return strategies;
  }

  void reset() {
    _initializePlayers();
    notifyListeners();
  }
}

class FriendExplanation {
  final FriendDeclaration declaration;
  final String reason;
  final bool isFull;
  final PlayingCard? firstTrickCard;    // 초구 카드 추천
  final String firstTrickStrategy;     // 초구 전략 설명 코드
  final List<String> strategyPoints;   // 점수 획득 전략 목록

  FriendExplanation({
    required this.declaration,
    required this.reason,
    this.isFull = false,
    this.firstTrickCard,
    this.firstTrickStrategy = '',
    this.strategyPoints = const [],
  });
}

class KittyExplanation {
  final List<PlayingCard> kittyCards;       // 바닥에서 받은 카드 3장
  final List<PlayingCard> discardCards;     // 버릴 카드 3장
  final List<PlayingCard> finalHand;       // 최종 보유 카드 10장
  final Suit? originalGiruda;              // 원래 기루다
  final Suit? newGiruda;                   // 변경된 기루다 (변경 없으면 동일)
  final bool girudaChanged;                // 기루다 변경 여부
  final List<String> discardReasons;       // 각 버릴 카드의 이유

  KittyExplanation({
    required this.kittyCards,
    required this.discardCards,
    required this.finalHand,
    required this.originalGiruda,
    required this.newGiruda,
    required this.girudaChanged,
    required this.discardReasons,
  });
}

class BidExplanation {
  final int playerId;
  final String playerName;
  final bool passed;
  final Suit? suit;
  final int tricks;
  final int minPoints;
  final int maxPoints;
  final int optimalPoints;
  final int girudaCount;
  final String passReason; // 'LOW_POINTS', 'OUTBID', ''
  final String? friendType; // 'MIGHTY', 'JOKER', 'ACE' (배팅 시 예상 프렌드)
  final Suit? friendSuit;  // 프렌드 카드 무늬 (ACE일 때)
  final String? friendHolderName; // 프렌드 카드 보유자 (null이면 키티)

  BidExplanation({
    required this.playerId,
    required this.playerName,
    required this.passed,
    this.suit,
    required this.tricks,
    required this.minPoints,
    required this.maxPoints,
    required this.optimalPoints,
    this.girudaCount = 0,
    this.passReason = '',
    this.friendType,
    this.friendSuit,
    this.friendHolderName,
  });
}
