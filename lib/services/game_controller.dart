import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import 'ai_player.dart';

class GameController extends ChangeNotifier {
  late GameState _state;
  final AIPlayer _aiPlayer = AIPlayer();
  bool _isProcessing = false;
  bool _waitingForTrickConfirm = false;
  Trick? _lastCompletedTrick;

  GameController() {
    _initializePlayers();
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
      Player(id: 0, name: '플레이어', type: PlayerType.human),
      Player(id: 1, name: '민준', type: PlayerType.ai),
      Player(id: 2, name: '서연', type: PlayerType.ai),
      Player(id: 3, name: '지호', type: PlayerType.ai),
      Player(id: 4, name: '수빈', type: PlayerType.ai),
    ];

    _state = GameState(players: players);
  }

  void startNewGame() {
    _state.startNewGame();
    notifyListeners();
    _processBiddingIfNeeded();
  }

  void _processBiddingIfNeeded() async {
    if (_state.phase != GamePhase.bidding) return;
    if (_state.currentBidder == 0) return;

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final currentPlayer = _state.players[_state.currentBidder];
    final bid = _aiPlayer.decideBid(currentPlayer, _state);
    _state.placeBid(bid);

    _isProcessing = false;
    notifyListeners();

    if (_state.phase == GamePhase.bidding) {
      _processBiddingIfNeeded();
    } else if (_state.phase == GamePhase.selectingKitty &&
        _state.declarerId != 0) {
      _processAIKittySelection();
    }
  }

  void humanBid(Bid bid) {
    if (_state.currentBidder != 0) return;

    _state.placeBid(bid);
    notifyListeners();

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

  void _processAIKittySelection() async {
    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    final declarer = _state.players[_state.declarerId!];

    // 1. 13장으로 기루다 변경 여부 결정
    final newGiruda = _aiPlayer.decideGirudaChange(declarer, _state, _state.kitty);

    // 2. 최종 기루다를 기준으로 버릴 카드 선택
    final discardCards = _aiPlayer.selectKittyCardsWithGiruda(declarer, _state, _state.kitty, newGiruda);

    // 3. 키티 선택 완료 (기루다 변경 시 목표 +2 자동 적용)
    _state.selectKitty(discardCards, newGiruda);

    _isProcessing = false;
    notifyListeners();

    _processAIFriendDeclaration();
  }

  void humanSelectKitty(List<PlayingCard> discardCards, Suit? newGiruda) {
    if (_state.declarerId != 0) return;
    if (discardCards.length != 3) return;

    _state.selectKitty(discardCards, newGiruda);
    notifyListeners();
  }

  void _processAIFriendDeclaration() async {
    if (_state.declarerId == 0) return;

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 800));

    final declarer = _state.players[_state.declarerId!];
    final declaration = _aiPlayer.declareFriend(declarer, _state);
    _state.declareFriend(declaration);

    _isProcessing = false;
    notifyListeners();

    _processAIPlayIfNeeded();
  }

  void humanDeclareFriend(FriendDeclaration declaration) {
    if (_state.declarerId != 0) return;

    _state.declareFriend(declaration);
    notifyListeners();

    _processAIPlayIfNeeded();
  }

  void _processAIPlayIfNeeded() async {
    if (_state.phase != GamePhase.playing) return;
    if (_state.currentPlayer == 0) return;
    if (_waitingForTrickConfirm) return;

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final currentPlayer = _state.players[_state.currentPlayer];
    PlayingCard card;
    Suit? jokerLeadSuit;

    // AI 조커 콜 결정 (선공 시에만)
    if (_state.currentTrick != null && _state.currentTrick!.cards.isEmpty) {
      final jokerCallSuit = _aiPlayer.decideJokerCall(currentPlayer, _state);
      if (jokerCallSuit != null) {
        _state.declareJokerCall(jokerCallSuit);
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 500));
        // 조커 콜 시 조커 콜 카드를 냄
        card = _state.jokerCall;
      } else {
        card = _aiPlayer.selectCard(currentPlayer, _state);
        // 조커 선공 시 무늬 결정
        if (card.isJoker) {
          jokerLeadSuit = _aiPlayer.selectJokerLeadSuit(currentPlayer, _state);
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
      // 사용자가 다음 선공이면 확인 없이 바로 카드 선택 가능
      if (_state.currentPlayer == 0) {
        _waitingForTrickConfirm = false;
      } else {
        _waitingForTrickConfirm = true;
      }
      notifyListeners();
      return; // 사용자 확인 대기 또는 카드 선택 대기
    }

    notifyListeners();

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
      return; // 사용자 확인 대기 또는 카드 선택 대기
    }

    notifyListeners();

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

  // 조커 콜이 가능한지 확인 (첫 트릭이 아니고, 선공이면 가능)
  bool get canDeclareJokerCall =>
      _state.currentTrickNumber > 1 &&
      isLeadingTrick &&
      _state.currentPlayer == 0;

  List<PlayingCard> getPlayableCards() {
    return humanPlayer.hand
        .where((card) => _state.canPlayCard(card, humanPlayer))
        .toList();
  }

  bool canPlayCard(PlayingCard card) {
    return _state.canPlayCard(card, humanPlayer);
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

  /// 사용자에게 추천할 비딩을 반환
  /// AI 로직을 사용하여 최적의 비딩을 선택
  Bid? getRecommendedBid() {
    if (_state.phase != GamePhase.bidding) return null;
    if (_state.currentBidder != 0) return null;
    if (_state.passedPlayers[0]) return null;

    // AI 로직을 사용하여 추천 비딩 선택
    return _aiPlayer.decideBid(humanPlayer, _state);
  }

  void reset() {
    _initializePlayers();
    notifyListeners();
  }
}
