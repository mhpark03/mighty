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

  GameController() {
    _initializePlayers();
  }

  GameState get state => _state;
  bool get isProcessing => _isProcessing;

  Player get humanPlayer => _state.players[0];
  Player get currentPlayer => _state.players[_state.currentPlayer];
  bool get isHumanTurn =>
      _state.currentPlayer == 0 && !_isProcessing;

  void _initializePlayers() {
    final players = [
      Player(id: 0, name: '플레이어', type: PlayerType.human),
      Player(id: 1, name: 'AI 1', type: PlayerType.ai),
      Player(id: 2, name: 'AI 2', type: PlayerType.ai),
      Player(id: 3, name: 'AI 3', type: PlayerType.ai),
      Player(id: 4, name: 'AI 4', type: PlayerType.ai),
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
    final discardCards = _aiPlayer.selectKittyCards(declarer, _state);
    _state.selectKitty(discardCards, _state.giruda);

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

    _isProcessing = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    final currentPlayer = _state.players[_state.currentPlayer];
    final card = _aiPlayer.selectCard(currentPlayer, _state);
    _state.playCard(card, currentPlayer.id);

    _isProcessing = false;
    notifyListeners();

    if (_state.phase == GamePhase.playing) {
      _processAIPlayIfNeeded();
    }
  }

  void humanPlayCard(PlayingCard card) {
    if (_state.currentPlayer != 0) return;
    if (!_state.canPlayCard(card, humanPlayer)) return;

    _state.playCard(card, 0);
    notifyListeners();

    if (_state.phase == GamePhase.playing) {
      _processAIPlayIfNeeded();
    }
  }

  List<PlayingCard> getPlayableCards() {
    return humanPlayer.hand
        .where((card) => _state.canPlayCard(card, humanPlayer))
        .toList();
  }

  bool canPlayCard(PlayingCard card) {
    return _state.canPlayCard(card, humanPlayer);
  }

  void reset() {
    _initializePlayers();
    notifyListeners();
  }
}
