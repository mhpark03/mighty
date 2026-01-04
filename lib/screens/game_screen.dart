import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../services/game_controller.dart';
import '../widgets/card_widget.dart';
import 'kitty_dialog.dart';
import 'friend_dialog.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  PlayingCard? selectedCard;
  bool _allPassedDialogShown = false;
  Timer? _trickTimer;
  int _trickCountdown = 10;
  bool _timerRunning = false;

  @override
  void dispose() {
    _trickTimer?.cancel();
    super.dispose();
  }

  void _startTrickTimer(GameController controller) {
    if (_timerRunning) return;
    _timerRunning = true;
    _trickCountdown = 10;

    _trickTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _trickCountdown--;
      });
      if (_trickCountdown <= 0) {
        timer.cancel();
        _timerRunning = false;
        controller.confirmTrick();
      }
    });
  }

  void _stopTrickTimer() {
    _trickTimer?.cancel();
    _timerRunning = false;
    _trickCountdown = 10;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<GameController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.green[800],
          appBar: AppBar(
            title: Text(l10n.appTitle),
            backgroundColor: Colors.green[900],
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  controller.reset();
                  controller.startNewGame();
                },
              ),
            ],
          ),
          body: _buildGameBody(controller),
        );
      },
    );
  }

  Widget _buildGameBody(GameController controller) {
    final state = controller.state;

    // 키티 선택 단계가 아니면 플래그 리셋
    if (state.phase != GamePhase.selectingKitty) {
      _kittyDialogShown = false;
    }

    switch (state.phase) {
      case GamePhase.waiting:
        // 모두 패스한 경우 팝업 표시
        if (state.allPassed && !_allPassedDialogShown) {
          _allPassedDialogShown = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showAllPassedDialog(controller);
          });
        }
        return _buildWaitingScreen(controller);
      case GamePhase.dealing:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      case GamePhase.bidding:
        return _buildBiddingScreen(controller);
      case GamePhase.selectingKitty:
        return _buildKittyScreen(controller);
      case GamePhase.declaringFriend:
        return _buildFriendScreen(controller);
      case GamePhase.playing:
      case GamePhase.roundEnd:
        return _buildPlayingScreen(controller);
      case GamePhase.gameEnd:
        return _buildGameEndScreen(controller);
    }
  }

  Widget _buildWaitingScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.appTitle,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.gameSubtitle,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => controller.startNewGame(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            ),
            child: Text(
              l10n.startGame,
              style: const TextStyle(fontSize: 20, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiddingScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;

    return Column(
      children: [
        // 상단 정보 바
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.black38,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.biddingPhase,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (state.currentBid != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    l10n.highestBid(state.currentBid.toString()),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
              else
                Text(
                  l10n.noBidYet,
                  style: const TextStyle(color: Colors.white70),
                ),
              ElevatedButton.icon(
                onPressed: () {
                  controller.reset();
                  controller.startNewGame();
                },
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(l10n.newGame),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
              ),
            ],
          ),
        ),
        // 게임 영역
        Expanded(
          child: Stack(
            children: [
              // AI 플레이어들 비딩 상태
              // AI 1 (왼쪽)
              Positioned(
                left: 8,
                top: 50,
                child: _buildBiddingPlayerStatus(state, 1, controller.isProcessing),
              ),
              // AI 2 (상단 왼쪽)
              Positioned(
                left: MediaQuery.of(context).size.width * 0.25,
                top: 8,
                child: _buildBiddingPlayerStatus(state, 2, controller.isProcessing),
              ),
              // AI 3 (상단 오른쪽)
              Positioned(
                right: MediaQuery.of(context).size.width * 0.25,
                top: 8,
                child: _buildBiddingPlayerStatus(state, 3, controller.isProcessing),
              ),
              // AI 4 (오른쪽)
              Positioned(
                right: 8,
                top: 50,
                child: _buildBiddingPlayerStatus(state, 4, controller.isProcessing),
              ),
              // 중앙 비딩 컨트롤
              Center(
                child: _buildCenterBiddingArea(controller),
              ),
            ],
          ),
        ),
        // 하단 사용자 카드
        _buildBiddingPlayerHand(controller),
      ],
    );
  }

  Widget _buildBiddingPlayerStatus(GameState state, int playerId, bool isProcessing) {
    final player = state.players[playerId];
    final isPassed = state.passedPlayers[playerId];
    final isCurrentBidder = state.currentBidder == playerId;
    final hasBid = state.currentBid?.playerId == playerId;

    Color borderColor;
    String statusText;
    Color statusColor;

    final l10n = AppLocalizations.of(context)!;

    if (isPassed) {
      borderColor = Colors.grey;
      statusText = l10n.pass;
      statusColor = Colors.grey;
    } else if (isCurrentBidder && isProcessing) {
      borderColor = Colors.orange;
      statusText = l10n.bidding;
      statusColor = Colors.orange;
    } else if (hasBid) {
      borderColor = Colors.amber;
      statusText = '${state.currentBid!.tricks}';
      statusColor = Colors.amber;
    } else {
      borderColor = Colors.white38;
      statusText = l10n.waiting;
      statusColor = Colors.white54;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            player.name,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterBiddingArea(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;
    final isHumanTurn = state.currentBidder == 0 && !controller.isProcessing;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[800],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[600]!, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isHumanTurn
                ? l10n.currentBidder(l10n.you)
                : l10n.currentBidder(state.players[state.currentBidder].name),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (isHumanTurn) ...[
            // 트릭 수 선택
            Text(
              l10n.tricks,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: [
                for (int i = 13; i <= 20; i++)
                  _buildBidChip(i, state),
              ],
            ),
            const SizedBox(height: 12),
            // 기루다 선택
            Text(
              l10n.giruda,
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              children: [
                _buildSuitChip(Suit.spade, '♠', l10n.spadeName),
                _buildSuitChip(Suit.diamond, '♦', l10n.diamondName),
                _buildSuitChip(Suit.heart, '♥', l10n.heartName),
                _buildSuitChip(Suit.club, '♣', l10n.clubName),
                _buildSuitChip(null, '', l10n.noGiruda),
              ],
            ),
            const SizedBox(height: 16),
            // 버튼들
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => controller.humanPass(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: Text(l10n.pass, style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _canBid(state) ? () => _submitBid(controller) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  ),
                  child: Text(
                    l10n.bidWithAmount(_selectedBidAmount),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ] else ...[
            if (controller.isProcessing)
              const CircularProgressIndicator(color: Colors.white)
            else
              Text(
                l10n.otherPlayerTurn,
                style: const TextStyle(color: Colors.white70),
              ),
          ],
        ],
      ),
    );
  }

  int _selectedBidAmount = 13;
  Suit? _selectedBidSuit = Suit.spade;

  Widget _buildBidChip(int amount, GameState state) {
    final minBid = (state.currentBid?.tricks ?? 12) + 1;
    final isEnabled = amount >= minBid;
    final isSelected = _selectedBidAmount == amount;

    return GestureDetector(
      onTap: isEnabled
          ? () => setState(() => _selectedBidAmount = amount)
          : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.amber
                : (isEnabled ? Colors.white24 : Colors.black38),
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: Colors.white, width: 2)
                : (isEnabled ? null : Border.all(color: Colors.grey[700]!, width: 1)),
          ),
          child: Text(
            '$amount',
            style: TextStyle(
              color: isSelected
                  ? Colors.black
                  : (isEnabled ? Colors.white : Colors.grey[600]),
              fontSize: 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              decoration: isEnabled ? null : TextDecoration.lineThrough,
              decorationColor: Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuitChip(Suit? suit, String symbol, String name) {
    final isSelected = _selectedBidSuit == suit;
    final isRed = suit == Suit.diamond || suit == Suit.heart;
    final isClub = suit == Suit.club;

    Color symbolColor;
    if (isSelected) {
      symbolColor = Colors.black;
    } else if (isRed) {
      symbolColor = Colors.red[400]!;
    } else if (isClub) {
      symbolColor = Colors.green[300]!; // 클로버는 녹색으로 구분
    } else {
      symbolColor = Colors.white;
    }

    return GestureDetector(
      onTap: () => setState(() => _selectedBidSuit = suit),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.white24,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (symbol.isNotEmpty) ...[
              Text(
                symbol,
                style: TextStyle(
                  color: symbolColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canBid(GameState state) {
    final minBid = (state.currentBid?.tricks ?? 12) + 1;
    return _selectedBidAmount >= minBid;
  }

  void _submitBid(GameController controller) {
    final bid = Bid(
      playerId: 0,
      suit: _selectedBidSuit,
      tricks: _selectedBidAmount,
    );
    controller.humanBid(bid);
  }

  Widget _buildBiddingPlayerHand(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;
    final hand = state.players[0].hand;
    final isPassed = state.passedPlayers[0];
    final isCurrentBidder = state.currentBidder == 0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isPassed
            ? Colors.grey[800]
            : (isCurrentBidder ? Colors.green[900] : Colors.black54),
        border: Border(
          top: BorderSide(
            color: isCurrentBidder ? Colors.amber : Colors.green[700]!,
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.yourCards,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isPassed) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.pass,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ] else if (isCurrentBidder) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l10n.biddingTurn,
                    style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final card in hand)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: CardWidget(
                        card: card,
                        width: 55,
                        height: 80,
                        isSelected: false,
                        isPlayable: true,
                        onTap: null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKittyScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;

    if (controller.state.declarerId != 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.aiSelectingKitty,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.white),
        ],
      );
    }

    // 사용자가 주공이면 바로 키티 선택 다이얼로그 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.state.phase == GamePhase.selectingKitty &&
          controller.state.declarerId == 0 &&
          !_kittyDialogShown) {
        _kittyDialogShown = true;
        _showKittyDialog(controller);
      }
    });

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  l10n.selectKitty,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        _buildPlayerHand(controller),
      ],
    );
  }

  bool _kittyDialogShown = false;

  void _showKittyDialog(GameController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => KittyDialog(
        hand: controller.humanPlayer.hand,
        kitty: controller.state.kitty,
        currentGiruda: controller.state.giruda,
        gameState: controller.state,
        onConfirm: (discards, newGiruda) {
          Navigator.pop(context);
          _kittyDialogShown = false;
          controller.humanSelectKitty(discards, newGiruda);
        },
      ),
    );
  }

  bool _friendDialogShown = false;

  Widget _buildFriendScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;

    if (controller.state.declarerId != 0) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            l10n.aiDeclaringFriend,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Colors.white),
        ],
      );
    }

    // 사용자가 주공이면 바로 프렌드 선언 다이얼로그 표시
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.state.phase == GamePhase.declaringFriend &&
          controller.state.declarerId == 0 &&
          !_friendDialogShown) {
        _friendDialogShown = true;
        _showFriendDialog(controller);
      }
    });

    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  l10n.declareFriend,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        _buildPlayerHand(controller),
      ],
    );
  }

  void _showFriendDialog(GameController controller) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => FriendDialog(
        mighty: controller.state.mighty,
        onDeclare: (declaration) {
          Navigator.pop(context);
          _friendDialogShown = false;
          controller.humanDeclareFriend(declaration);
        },
      ),
    );
  }

  Widget _buildPlayingScreen(GameController controller) {
    final state = controller.state;

    // 트릭 완료 대기 중이면 타이머 시작 (사용자가 선공이 아닐 때만)
    if (controller.waitingForTrickConfirm && !_timerRunning) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTrickTimer(controller);
      });
    } else if (!controller.waitingForTrickConfirm && _timerRunning) {
      _stopTrickTimer();
    }

    return Stack(
      children: [
        Column(
          children: [
            _buildGameInfo(state),
            const SizedBox(height: 4),
            Expanded(
              child: _buildPlayArea(controller),
            ),
            _buildPlayerHand(controller),
          ],
        ),
        // 트릭 완료 시 오버레이 (사용자가 선공이 아닐 때만)
        if (controller.waitingForTrickConfirm)
          _buildTrickConfirmOverlay(controller),
      ],
    );
  }

  Widget _buildTrickConfirmOverlay(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final trick = controller.lastCompletedTrick;
    if (trick == null) return const SizedBox.shrink();

    final winner = controller.state.players[trick.winnerId ?? 0];
    final isDeclarerTeam = winner.isDeclarer || winner.isFriend;

    return Positioned.fill(
      child: Container(
        color: Colors.black54,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[800],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDeclarerTeam ? Colors.blue : Colors.red,
                width: 3,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.trickComplete(trick.trickNumber),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                // 낸 카드들 표시
                Wrap(
                  spacing: 8,
                  children: [
                    for (int i = 0; i < trick.cards.length; i++)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            controller.state.players[trick.playerOrder[i]].name,
                            style: TextStyle(
                              color: trick.playerOrder[i] == trick.winnerId
                                  ? Colors.amber
                                  : Colors.white70,
                              fontSize: 11,
                              fontWeight: trick.playerOrder[i] == trick.winnerId
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Container(
                            decoration: trick.playerOrder[i] == trick.winnerId
                                ? BoxDecoration(
                                    border: Border.all(color: Colors.amber, width: 2),
                                    borderRadius: BorderRadius.circular(6),
                                  )
                                : null,
                            child: CardWidget(
                              card: trick.cards[i],
                              width: 50,
                              height: 75,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                // 승자 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDeclarerTeam ? Colors.blue[700] : Colors.red[700],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.winnerAnnouncement(winner.name, isDeclarerTeam ? l10n.attackTeam : l10n.defenseTeam),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // 타이머 & 진행 버튼
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 타이머 표시
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _trickCountdown <= 3 ? Colors.red : Colors.grey[700],
                      ),
                      child: Center(
                        child: Text(
                          '$_trickCountdown',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // 진행 버튼
                    ElevatedButton.icon(
                      onPressed: () {
                        _stopTrickTimer();
                        controller.confirmTrick();
                      },
                      icon: const Icon(Icons.play_arrow),
                      label: Text(l10n.nextTrick),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameInfo(GameState state) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(l10n.giruda, state.giruda != null
              ? _getSuitSymbol(state.giruda!)
              : l10n.noGiruda),
          _buildInfoItem(l10n.contract, '${state.currentBid?.tricks ?? 0}'),
          _buildInfoItem(l10n.trick, '${state.tricksPlayed}/10'),
          // 프렌드 선언 정보 표시
          _buildFriendInfo(state, l10n),
        ],
      ),
    );
  }

  Widget _buildFriendInfo(GameState state, AppLocalizations l10n) {
    String friendLabel = l10n.friend;
    String friendValue;
    Color valueColor = Colors.white;

    if (state.friendRevealed && state.friend != null) {
      // 프렌드가 공개됨
      friendValue = state.friend!.name;
      valueColor = Colors.lightBlueAccent;
    } else if (state.friendDeclaration != null) {
      // 프렌드 선언 조건 표시
      final decl = state.friendDeclaration!;
      if (decl.isNoFriend) {
        friendValue = l10n.friendNone;
        valueColor = Colors.grey;
      } else if (decl.isFirstTrickWinner) {
        friendValue = l10n.firstTrick;
        valueColor = Colors.amber;
      } else if (decl.trickNumber != null) {
        friendValue = l10n.nthTrickShort(decl.trickNumber!);
        valueColor = Colors.amber;
      } else if (decl.card != null) {
        friendValue = _getCardString(decl.card!);
        valueColor = Colors.amber;
      } else {
        friendValue = '?';
      }
    } else {
      friendValue = '?';
    }

    return Column(
      children: [
        Text(
          friendLabel,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          friendValue,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getCardString(PlayingCard card) {
    if (card.isJoker) return 'Joker';
    String suit = _getSuitSymbol(card.suit!);
    String rank;
    switch (card.rank) {
      case Rank.ace:
        rank = 'A';
        break;
      case Rank.king:
        rank = 'K';
        break;
      case Rank.queen:
        rank = 'Q';
        break;
      case Rank.jack:
        rank = 'J';
        break;
      case Rank.ten:
        rank = '10';
        break;
      default:
        rank = '${card.rankValue}';
    }
    return '$suit$rank';
  }

  String _getSuitSymbol(Suit suit) {
    switch (suit) {
      case Suit.spade:
        return '♠';
      case Suit.diamond:
        return '♦';
      case Suit.heart:
        return '♥';
      case Suit.club:
        return '♣';
    }
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayArea(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;
    final trick = state.currentTrick;

    return Stack(
      children: [
        Positioned(
          top: 10,
          left: 0,
          right: 0,
          child: _buildTopPlayers(state),
        ),
        Center(
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[600]!, width: 2),
            ),
            child: _buildTrickCards(trick, state, controller),
          ),
        ),
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: controller.isHumanTurn ? Colors.amber : Colors.black38,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    controller.isHumanTurn
                        ? l10n.yourTurn
                        : l10n.playerTurn(state.players[state.currentPlayer].name),
                    style: TextStyle(
                      color: controller.isHumanTurn ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (controller.isHumanTurn)
                    Text(
                      l10n.selectCardHint,
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopPlayers(GameState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (int i = 1; i < 5; i++)
          _buildPlayerIndicator(state.players[i], state, i),
      ],
    );
  }

  Widget _buildPlayerIndicator(Player player, GameState state, int index) {
    final l10n = AppLocalizations.of(context)!;
    final isCurrentPlayer = state.currentPlayer == index;
    final isDeclarer = player.isDeclarer;
    final isFriend = player.isFriend && state.friendRevealed;
    final isLeadPlayer = state.currentTrick != null &&
        state.currentTrick!.leadPlayerId == index;

    // 플레이어가 획득한 점수 카드
    final pointCards = player.wonCards
        .where((c) => c.isPointCard || c.isJoker)
        .toList();
    pointCards.sort((a, b) {
      if (a.isJoker) return -1;
      if (b.isJoker) return 1;
      if (a.suit != b.suit) return a.suit!.index.compareTo(b.suit!.index);
      return b.rankValue.compareTo(a.rankValue);
    });

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isCurrentPlayer ? Colors.amber.withValues(alpha: 0.3) : Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDeclarer
                      ? Colors.red
                      : (isFriend ? Colors.blue : Colors.transparent),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    player.name,
                    style: TextStyle(
                      color: isCurrentPlayer ? Colors.amber : Colors.white,
                      fontWeight: isCurrentPlayer ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    l10n.cards(player.hand.length),
                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                  if (isDeclarer)
                    Text(
                      l10n.declarer,
                      style: const TextStyle(color: Colors.red, fontSize: 9),
                    ),
                  if (isFriend)
                    Text(
                      l10n.friend,
                      style: const TextStyle(color: Colors.blue, fontSize: 9),
                    ),
                ],
              ),
            ),
            // 선공 표시
            if (isLeadPlayer)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // 획득한 점수 카드 표시
        if (pointCards.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Wrap(
              spacing: 4,
              runSpacing: 4,
              children: pointCards.map((card) => _buildTinyCard(card, state)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTinyCard(PlayingCard card, GameState state) {
    final isMighty = card == state.mighty;

    if (card.isJoker) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.purple[600],
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Text('🃏', style: TextStyle(fontSize: 14)),
      );
    }

    final isRed = card.suit == Suit.diamond || card.suit == Suit.heart;
    final suitSymbol = _getSuitSymbol(card.suit!);
    String rank;
    switch (card.rank) {
      case Rank.ace:
        rank = 'A';
        break;
      case Rank.king:
        rank = 'K';
        break;
      case Rank.queen:
        rank = 'Q';
        break;
      case Rank.jack:
        rank = 'J';
        break;
      case Rank.ten:
        rank = '10';
        break;
      default:
        rank = '${card.rankValue}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isMighty ? Colors.amber[700] : Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$suitSymbol$rank',
        style: TextStyle(
          color: isRed ? Colors.red[700] : Colors.black,
          fontSize: 14,
          fontWeight: isMighty ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTrickCards(Trick? trick, GameState state, GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final isHumanLeading = state.currentPlayer == 0 && (trick == null || trick.cards.isEmpty);
    final lastTrick = controller.lastCompletedTrick;
    final showPreviousTrick = isHumanLeading && lastTrick != null;

    if (trick == null || trick.cards.isEmpty) {
      // 이전 트릭이 있고 사용자가 선공이면 이전 트릭 표시
      if (showPreviousTrick) {
        final winner = state.players[lastTrick.winnerId ?? 0];
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 이전 트릭 헤더
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black38,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${l10n.previousTrick} ',
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${winner.name} ${l10n.winShort}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // 이전 트릭 카드들
              Wrap(
                spacing: 8,
                children: [
                  for (int i = 0; i < lastTrick.cards.length; i++)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.players[lastTrick.playerOrder[i]].name,
                          style: TextStyle(
                            color: lastTrick.playerOrder[i] == lastTrick.winnerId
                                ? Colors.amber
                                : Colors.white70,
                            fontSize: 10,
                            fontWeight: lastTrick.playerOrder[i] == lastTrick.winnerId
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        Container(
                          decoration: lastTrick.playerOrder[i] == lastTrick.winnerId
                              ? BoxDecoration(
                                  border: Border.all(color: Colors.amber, width: 2),
                                  borderRadius: BorderRadius.circular(4),
                                )
                              : null,
                          child: Opacity(
                            opacity: 0.7,
                            child: CardWidget(
                              card: lastTrick.cards[i],
                              width: 40,
                              height: 56,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              // 선공 안내
              Text(
                l10n.leadPlayerSelectCard,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }

      // 이전 트릭이 없는 경우 기본 메시지
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.playCard,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            if (isHumanLeading) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber, width: 1),
                ),
                child: Column(
                  children: [
                    Text(
                      l10n.leadPlayerHint,
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.selectCardBelow,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 조커 콜 표시
          if (trick.jokerCall == JokerCallType.jokerCall && trick.jokerCallSuit != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                l10n.jokerCallAnnouncement(_getSuitSymbol(trick.jokerCallSuit!)),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Wrap(
            spacing: 8,
            children: [
              for (int i = 0; i < trick.cards.length; i++)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.players[trick.playerOrder[i]].name,
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    CardWidget(
                      card: trick.cards[i],
                      width: 50,
                      height: 75,
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerHand(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final hand = controller.humanPlayer.hand;
    final playableCards =
        controller.state.phase == GamePhase.playing ? controller.getPlayableCards() : hand;
    final isLeadPlayer = controller.state.currentTrick != null &&
        controller.state.currentTrick!.leadPlayerId == 0;

    // 플레이어가 획득한 점수 카드
    final pointCards = controller.humanPlayer.wonCards
        .where((c) => c.isPointCard || c.isJoker)
        .toList();
    pointCards.sort((a, b) {
      if (a.isJoker) return -1;
      if (b.isJoker) return 1;
      if (a.suit != b.suit) return a.suit!.index.compareTo(b.suit!.index);
      return b.rankValue.compareTo(a.rankValue);
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: Colors.black26,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단: 선공 표시 & 획득한 점수 카드
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 선공 표시
              if (isLeadPlayer && controller.state.phase == GamePhase.playing)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        l10n.leadPlayer,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              // 획득한 점수 카드
              if (pointCards.isNotEmpty && controller.state.phase == GamePhase.playing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.wonCards,
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Wrap(
                        spacing: 4,
                        children: pointCards.map((card) => _buildTinyCard(card, controller.state)).toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          // 카드 목록
          SizedBox(
            height: 90,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (final card in hand)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: CardWidget(
                        card: card,
                        width: 55,
                        height: 80,
                        isSelected: selectedCard == card,
                        isPlayable: playableCards.contains(card),
                        onTap: () => _onCardTap(card, controller),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onCardTap(PlayingCard card, GameController controller) {
    if (controller.state.phase != GamePhase.playing) return;
    if (!controller.isHumanTurn) return;
    if (!controller.canPlayCard(card)) return;

    if (selectedCard == card) {
      // 조커 콜 카드(♣3 또는 ♠3)를 선공으로 낼 때만 조커 콜 가능
      final jokerCallCard = controller.state.jokerCall;
      if (controller.canDeclareJokerCall && card == jokerCallCard) {
        _showJokerCallDialog(card, controller);
      } else {
        controller.humanPlayCard(card);
        setState(() {
          selectedCard = null;
        });
      }
    } else {
      setState(() {
        selectedCard = card;
      });
    }
  }

  void _showJokerCallDialog(PlayingCard card, GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final suitSymbol = _getSuitSymbol(card.suit!);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.jokerCallTitle),
        content: Text(l10n.jokerCallQuestion(suitSymbol)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.humanPlayCard(card);
              setState(() {
                selectedCard = null;
              });
            },
            child: Text(l10n.no),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 조커 콜 카드의 무늬로 자동 콜
              controller.humanPlayCard(card, jokerCallSuit: card.suit);
              setState(() {
                selectedCard = null;
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.jokerCallButton(suitSymbol), style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAllPassedDialog(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.allPassedTitle),
        content: Text(l10n.allPassedMessage),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _allPassedDialogShown = false;
              });
              controller.reset();
              controller.startNewGame();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text(l10n.newGame, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildGameEndScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              state.declarerWon ? l10n.declarerTeamWins : l10n.defenderTeamWins,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: state.declarerWon ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.declarerTeamPoints(state.declarerTeamPoints),
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              l10n.defenderTeamPoints(state.defenderTeamPoints),
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              l10n.targetPoints(state.currentBid?.tricks ?? 0),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.score,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final player in state.players)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${player.name} ${player.isDeclarer ? "(${l10n.declarer})" : player.isFriend ? "(${l10n.friend})" : ""}',
                    ),
                    Text(
                      l10n.points(state.getPlayerScore(player.id)),
                      style: TextStyle(
                        color: state.getPlayerScore(player.id) >= 0
                            ? Colors.green
                            : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                controller.reset();
                controller.startNewGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text(
                l10n.newGame,
                style: const TextStyle(fontSize: 18, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
