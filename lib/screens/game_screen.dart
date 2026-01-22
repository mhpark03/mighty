import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../services/ad_service.dart';
import '../services/game_controller.dart';
import '../services/stats_service.dart';
import '../widgets/card_widget.dart';
import 'kitty_dialog.dart';
import 'friend_dialog.dart' show FriendSelectionScreen;

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
  bool _showHint = false;
  bool _statsRecorded = false;
  bool _bidInitialized = false;
  bool _showGameResult = true;

  /// 배팅을 무늬 기호로 포맷
  String _formatBid(Bid bid) {
    if (bid.passed) return 'Pass';
    final suitSymbol = bid.suit != null ? _getSuitSymbol(bid.suit!) : 'NT';
    return '${bid.tricks} $suitSymbol';
  }

  /// 플레이어 ID에 따라 로컬라이즈된 이름 반환
  String _getLocalizedPlayerName(Player player, AppLocalizations l10n) {
    switch (player.id) {
      case 0:
        return l10n.player;
      case 1:
        return l10n.aiPlayer1;
      case 2:
        return l10n.aiPlayer2;
      case 3:
        return l10n.aiPlayer3;
      case 4:
        return l10n.aiPlayer4;
      default:
        return player.name;
    }
  }

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

  void _exitGame() {
    Navigator.pop(context); // Go back to home screen
  }

  void _onHintButtonPressed() {
    if (_showHint) {
      setState(() {
        _showHint = false;
      });
    } else {
      _showHintDialog();
    }
  }

  void _showHintDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.hint),
        content: Text(l10n.hintDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              AdService().showRewardedAd(
                onRewarded: () {
                  setState(() {
                    _showHint = true;
                  });
                },
                onAdNotAvailable: () {
                  // 광고 로드 실패 시에도 힌트 활성화
                  setState(() {
                    _showHint = true;
                  });
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text(l10n.watchAd, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showNewGameDialog(GameController controller, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.newGame),
        content: Text(l10n.newGameDialogContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              AdService().showRewardedAd(
                onRewarded: () {
                  _statsRecorded = false;
                  _allPassedDialogShown = false;
                  _bidInitialized = false;
                  _showGameResult = true;
                  _showHint = false;
                  controller.startNewGame();
                },
                onAdNotAvailable: () {
                  _statsRecorded = false;
                  _allPassedDialogShown = false;
                  _bidInitialized = false;
                  _showGameResult = true;
                  _showHint = false;
                  controller.startNewGame();
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text(l10n.newGame, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<GameController>(
      builder: (context, controller, child) {
        return Scaffold(
          backgroundColor: Colors.green[800],
          appBar: AppBar(
            title: Text(l10n.appTitle, style: const TextStyle(color: Colors.white)),
            backgroundColor: Colors.green[900],
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: _exitGame,
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.lightbulb, color: _showHint ? Colors.yellow : Colors.white),
                tooltip: _showHint ? l10n.hintOff : l10n.hint,
                onPressed: _onHintButtonPressed,
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                tooltip: l10n.newGame,
                onPressed: () => _showNewGameDialog(controller, l10n),
              ),
            ],
          ),
          body: SafeArea(
            child: _buildGameBody(controller),
          ),
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
        if (_showGameResult) {
          return _buildGameEndScreen(controller);
        } else {
          return _buildPlayingScreen(controller);
        }
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
                    l10n.highestBid(_formatBid(state.currentBid!)),
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
            ],
          ),
        ),
        // 게임 영역
        Expanded(
          child: Stack(
            children: [
              // AI 플레이어들 배팅 상태
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
              // 중앙 배팅 컨트롤
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
            _getLocalizedPlayerName(player, l10n),
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

    // AI 추천 배팅 가져오기
    final recommendedBid = isHumanTurn ? controller.getRecommendedBid() : null;

    // AI 추천으로 초기값 설정 (한 번만)
    if (isHumanTurn && recommendedBid != null && !_bidInitialized) {
      _bidInitialized = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            if (recommendedBid.passed) {
              // 패스 추천: 기루다 선택 안 함
              _suitManuallySelected = false;
            } else {
              // 배팅 추천: 추천값으로 설정
              _selectedBidAmount = recommendedBid.tricks;
              _selectedBidSuit = recommendedBid.suit;
              _suitManuallySelected = true;
            }
          });
        }
      });
    }
    // 배팅 페이즈가 아니면 초기화 플래그 리셋
    if (state.phase != GamePhase.bidding) {
      _bidInitialized = false;
      _suitManuallySelected = false;
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final maxBiddingHeight = screenHeight * 0.45; // 화면 높이의 45%로 제한

    return Container(
      constraints: BoxConstraints(maxHeight: maxBiddingHeight),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green[800],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[600]!, width: 2),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isHumanTurn
                  ? l10n.currentBidder(l10n.you)
                  : l10n.currentBidder(_getLocalizedPlayerName(state.players[state.currentBidder], l10n)),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          // AI 추천 표시 (힌트 모드일 때만)
          if (_showHint && isHumanTurn && recommendedBid != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.lightBlueAccent, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.lightbulb, color: Colors.lightBlueAccent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    recommendedBid.passed
                        ? '${l10n.aiRecommendation}: ${l10n.pass}'
                        : '${l10n.aiRecommendation}: ${recommendedBid.tricks} ${_getSuitName(recommendedBid.suit, l10n)}',
                    style: const TextStyle(
                      color: Colors.lightBlueAccent,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          if (isHumanTurn) ...[
            // 트릭 수 선택
            Text(
              l10n.tricks,
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (int i = 13; i <= 20; i++)
                  _buildBidChip(i, state, l10n),
              ],
            ),
            const SizedBox(height: 8),
            // 기루다 선택
            Text(
              l10n.giruda,
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _buildSuitChip(Suit.spade, '♠', l10n.spadeName),
                _buildSuitChip(Suit.diamond, '♦', l10n.diamondName),
                _buildSuitChip(Suit.heart, '♥', l10n.heartName),
                _buildSuitChip(Suit.club, '♣', l10n.clubName),
                _buildSuitChip(null, '✕', l10n.noGiruda),
              ],
            ),
            const SizedBox(height: 10),
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
            // 딜 미스 버튼
            if (controller.canHumanDeclareDealMiss) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => _showDealMissDialog(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                ),
                child: Text(
                  l10n.dealMiss,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
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
      ),
    );
  }

  int _selectedBidAmount = 13;
  Suit? _selectedBidSuit = Suit.spade;
  bool _suitManuallySelected = false;  // 사용자가 직접 기루다를 선택했는지

  Widget _buildBidChip(int amount, GameState state, AppLocalizations l10n) {
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
            amount == 20 ? l10n.fullPoints : '$amount',
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
    // 사용자가 직접 선택했거나 AI가 배팅을 추천한 경우에만 선택 표시
    final isSelected = _suitManuallySelected && _selectedBidSuit == suit;
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
      onTap: () => setState(() {
        _selectedBidSuit = suit;
        _suitManuallySelected = true;
      }),
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
    // 기루다가 선택되어야 배팅 가능
    return _selectedBidAmount >= minBid && _suitManuallySelected;
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

    // 세로 모드 확인
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;

    // 세로 모드에서 카드 크기와 배치 계산
    final cardWidth = isPortrait ? (screenWidth - 32) / 6 - 4 : 55.0;
    final cardHeight = cardWidth * 1.4;

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
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 6),
          // 세로 모드: 2줄 배치, 가로 모드: 1줄 스크롤
          if (isPortrait)
            _buildTwoRowCards(hand, cardWidth, cardHeight)
          else
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

  Widget _buildTwoRowCards(List<PlayingCard> hand, double cardWidth, double cardHeight) {
    // 카드를 2줄로 나누기 (위: 앞 절반, 아래: 뒤 절반)
    final halfIndex = (hand.length + 1) ~/ 2;
    final firstRow = hand.sublist(0, halfIndex);
    final secondRow = hand.sublist(halfIndex);

    return Column(
      children: [
        // 첫 번째 줄
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final card in firstRow)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: CardWidget(
                  card: card,
                  width: cardWidth,
                  height: cardHeight,
                  isSelected: false,
                  isPlayable: true,
                  onTap: null,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        // 두 번째 줄
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final card in secondRow)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: CardWidget(
                  card: card,
                  width: cardWidth,
                  height: cardHeight,
                  isSelected: false,
                  isPlayable: true,
                  onTap: null,
                ),
              ),
          ],
        ),
      ],
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => KittySelectionScreen(
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendSelectionScreen(
          mighty: controller.state.mighty,
          hand: controller.humanPlayer.hand,
          gameState: controller.state,
          onDeclare: (declaration) {
            Navigator.pop(context);
            _friendDialogShown = false;
            controller.humanDeclareFriend(declaration);
          },
        ),
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

    final l10n = AppLocalizations.of(context)!;

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
        // 게임 종료 후 팀별 점수 및 버튼 표시
        if (state.phase == GamePhase.gameEnd && !_showGameResult)
          Positioned(
            bottom: 180,
            left: 0,
            right: 0,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 팀별 점수 표시
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // 주공팀 점수
                            Column(
                              children: [
                                Text(
                                  l10n.declarerTeam,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  state.declarerTeamPoints == 20
                                      ? l10n.fullPoints
                                      : '${state.declarerTeamPoints}${l10n.points(0).replaceAll('0', '').trim()}',
                                  style: TextStyle(
                                    color: state.declarerWon ? Colors.greenAccent : Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'vs',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // 수비팀 점수
                            Column(
                              children: [
                                Text(
                                  l10n.defenderTeam,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  state.defenderTeamPoints == 20
                                      ? l10n.fullPoints
                                      : '${state.defenderTeamPoints}${l10n.points(0).replaceAll('0', '').trim()}',
                                  style: TextStyle(
                                    color: !state.declarerWon ? Colors.redAccent : Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        // 버린 카드 (키티) 표시
                        if (state.kitty.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                l10n.discardCards,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(width: 6),
                              ...state.kitty.map((card) => Padding(
                                padding: const EdgeInsets.only(right: 3),
                                child: _buildTinyCard(card, state),
                              )),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 버튼들
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showGameResult = true;
                          });
                        },
                        icon: const Icon(Icons.emoji_events, color: Colors.black),
                        label: Text(
                          l10n.score,
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _statsRecorded = false;
                            _showGameResult = true;
                            _showHint = false;
                          });
                          controller.reset();
                          controller.startNewGame();
                        },
                        icon: const Icon(Icons.refresh, color: Colors.black),
                        label: Text(
                          l10n.newGame,
                          style: const TextStyle(fontSize: 16, color: Colors.black),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[400],
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                // 조커 콜 표시
                if (trick.jokerCall == JokerCallType.jokerCall && trick.jokerCallSuit != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    margin: const EdgeInsets.only(top: 8),
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
                            _getLocalizedPlayerName(controller.state.players[trick.playerOrder[i]], l10n),
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
                    l10n.winnerAnnouncement(_getLocalizedPlayerName(winner, l10n), isDeclarerTeam ? l10n.attackTeam : l10n.defenseTeam),
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

    // 오픈된 기루다 수 계산
    int playedGirudaCount = 0;
    if (state.giruda != null) {
      for (final trick in state.tricks) {
        playedGirudaCount += trick.cards
            .where((c) => !c.isJoker && c.suit == state.giruda)
            .length;
      }
      if (state.currentTrick != null) {
        playedGirudaCount += state.currentTrick!.cards
            .where((c) => !c.isJoker && c.suit == state.giruda)
            .length;
      }
    }

    // 공격팀 획득 점수 계산
    int attackTeamPoints = 0;
    for (final player in state.players) {
      if (player.isDeclarer || player.isFriend) {
        attackTeamPoints += player.pointsWon;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildGirudaInfo(l10n, state.giruda, playedGirudaCount),
          _buildInfoItem(l10n.contract, '${state.currentBid?.tricks ?? 0} ($attackTeamPoints)'),
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

    // 노프렌드 체크를 먼저 해야 함 (노프렌드 시에도 friendRevealed=true가 됨)
    if (state.friendDeclaration != null && state.friendDeclaration!.isNoFriend) {
      friendValue = l10n.friendNone;
      valueColor = Colors.grey;
    } else if (state.friendRevealed && state.friend != null) {
      // 프렌드가 공개됨
      friendValue = _getLocalizedPlayerName(state.friend!, l10n);
      valueColor = Colors.lightBlueAccent;
    } else if (state.friendDeclaration != null) {
      // 프렌드 선언 조건 표시
      final decl = state.friendDeclaration!;
      if (decl.isFirstTrickWinner) {
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

    // 프렌드 카드인 경우 무늬 색상 적용
    final decl = state.friendDeclaration;
    final bool hasFriendCard = decl != null && decl.card != null && !state.friendRevealed;

    return Column(
      children: [
        Text(
          friendLabel,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        hasFriendCard
            ? _buildColoredCardText(decl.card!)
            : Text(
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

  // 무늬 색상이 적용된 카드 텍스트 위젯
  Widget _buildColoredCardText(PlayingCard card) {
    if (card.isJoker) {
      return const Text(
        'Joker',
        style: TextStyle(
          color: Colors.purple,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    final suit = card.suit!;
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getSuitSymbol(suit),
          style: TextStyle(
            color: _getSuitColor(suit),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          rank,
          style: const TextStyle(
            color: Colors.amber,
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

  // 무늬별 색상 반환 (검은 무늬 구분을 위해)
  Color _getSuitColor(Suit suit) {
    switch (suit) {
      case Suit.heart:
        return Colors.red;
      case Suit.diamond:
        return Colors.red[300]!; // 연한 빨강
      case Suit.spade:
        return Colors.white;
      case Suit.club:
        return Colors.lightGreenAccent; // 클로버는 녹색 계열로 구분
    }
  }

  String _getSuitName(Suit? suit, AppLocalizations l10n) {
    if (suit == null) return l10n.noGiruda;
    switch (suit) {
      case Suit.spade:
        return l10n.spadeName;
      case Suit.diamond:
        return l10n.diamondName;
      case Suit.heart:
        return l10n.heartName;
      case Suit.club:
        return l10n.clubName;
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

  // 기루다 정보 표시 (무늬별 색상 적용)
  Widget _buildGirudaInfo(AppLocalizations l10n, Suit? giruda, int playedCount) {
    return Column(
      children: [
        Text(
          l10n.giruda,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        giruda != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getSuitSymbol(giruda),
                    style: TextStyle(
                      color: _getSuitColor(giruda),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' ($playedCount/13)',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Text(
                l10n.noGiruda,
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

    // 반응형 크기 계산
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // 중앙 영역 크기: 화면의 비율에 따라 계산
    final centerWidth = (screenWidth * 0.75).clamp(260.0, 500.0);
    final centerHeight = (screenHeight * 0.22).clamp(100.0, 200.0);

    // 트릭 카드 크기: 중앙 영역에 맞춰 계산
    final trickCardWidth = (centerWidth / 6).clamp(30.0, 55.0);
    final trickCardHeight = trickCardWidth * 1.4;

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
            width: centerWidth,
            height: centerHeight,
            padding: EdgeInsets.all(centerWidth * 0.02),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green[600]!, width: 2),
            ),
            child: ClipRect(
              child: _buildTrickCards(trick, state, controller, trickCardWidth, trickCardHeight),
            ),
          ),
        ),
        // 게임 진행 중: 차례 표시, 게임 종료: 표시 안 함
        if (state.phase == GamePhase.playing)
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
                          : l10n.playerTurn(_getLocalizedPlayerName(state.players[state.currentPlayer], l10n)),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final playerWidth = (screenWidth - 32) / 4; // AI 4명만 표시, 좌우 여백 16씩

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI 플레이어만 표시 (index 1-4)
        for (int i = 1; i <= 4; i++)
          SizedBox(
            width: playerWidth,
            child: _buildPlayerIndicator(state.players[i], state, i, playerWidth),
          ),
      ],
    );
  }

  Widget _buildPlayerIndicator(Player player, GameState state, int index, double maxWidth) {
    final l10n = AppLocalizations.of(context)!;
    final isCurrentPlayer = state.currentPlayer == index;
    final isDeclarer = player.isDeclarer;
    final isFriend = player.isFriend && state.friendRevealed;
    final isLeadPlayer = state.currentTrick != null &&
        state.currentTrick!.leadPlayerId == index;

    // 플레이어가 획득한 점수 카드 (조커 제외)
    final pointCards = player.wonCards
        .where((c) => c.isPointCard && !c.isJoker)
        .toList();
    pointCards.sort((a, b) {
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
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getLocalizedPlayerName(player, l10n),
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
                top: -6,
                right: -6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: const Text(
                    '1',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        // 획득한 점수 카드 표시 (고정 크기)
        if (pointCards.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Wrap(
              spacing: 2,
              runSpacing: 2,
              alignment: WrapAlignment.center,
              children: pointCards.map((card) => _buildTinyCardFixed(card, state, 28.0)).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildTinyCard(PlayingCard card, GameState state) {
    final isMighty = card == state.mighty;

    if (card.isJoker) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.purple[600],
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Text('🃏', style: TextStyle(fontSize: 11)),
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
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
      decoration: BoxDecoration(
        color: isMighty ? Colors.amber[700] : Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        '$suitSymbol$rank',
        style: TextStyle(
          color: isRed ? Colors.red[700] : Colors.black,
          fontSize: 11,
          fontWeight: isMighty ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // 고정 너비의 작은 카드 (3열 레이아웃용)
  Widget _buildTinyCardFixed(PlayingCard card, GameState state, double width) {
    final isMighty = card == state.mighty;

    if (card.isJoker) {
      return Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 1),
        decoration: BoxDecoration(
          color: Colors.purple[600],
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Center(
          child: Text('🃏', style: TextStyle(fontSize: 10)),
        ),
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
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
      decoration: BoxDecoration(
        color: isMighty ? Colors.amber[700] : Colors.white,
        borderRadius: BorderRadius.circular(3),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          '$suitSymbol$rank',
          style: TextStyle(
            color: isRed ? Colors.red[700] : Colors.black,
            fontSize: 12,
            fontWeight: isMighty ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTrickCards(Trick? trick, GameState state, GameController controller, double cardWidth, double cardHeight) {
    final l10n = AppLocalizations.of(context)!;
    final isHumanLeading = state.currentPlayer == 0 && (trick == null || trick.cards.isEmpty);
    final lastTrick = controller.lastCompletedTrick;
    final showPreviousTrick = isHumanLeading && lastTrick != null;

    // 이전 트릭용 작은 카드 크기
    final prevCardWidth = cardWidth * 0.85;
    final prevCardHeight = cardHeight * 0.85;

    if (trick == null || trick.cards.isEmpty) {
      // 이전 트릭이 있고 사용자가 선공이면 이전 트릭 표시
      if (showPreviousTrick) {
        final winner = state.players[lastTrick.winnerId ?? 0];
        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 이전 트릭 헤더
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${l10n.previousTrick} ',
                        style: const TextStyle(color: Colors.white70, fontSize: 10),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${_getLocalizedPlayerName(winner, l10n)} ${l10n.winShort}',
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // 이전 트릭 카드들
                Wrap(
                  spacing: 4,
                  children: [
                    for (int i = 0; i < lastTrick.cards.length; i++)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getLocalizedPlayerName(state.players[lastTrick.playerOrder[i]], l10n),
                            style: TextStyle(
                              color: lastTrick.playerOrder[i] == lastTrick.winnerId
                                  ? Colors.amber
                                  : Colors.white70,
                              fontSize: 8,
                              fontWeight: lastTrick.playerOrder[i] == lastTrick.winnerId
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          Container(
                            decoration: lastTrick.playerOrder[i] == lastTrick.winnerId
                                ? BoxDecoration(
                                    border: Border.all(color: Colors.amber, width: 1),
                                    borderRadius: BorderRadius.circular(4),
                                  )
                                : null,
                            child: Opacity(
                              opacity: 0.7,
                              child: CardWidget(
                                card: lastTrick.cards[i],
                                width: prevCardWidth,
                                height: prevCardHeight,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 2),
                // 선공 안내
                Text(
                  l10n.leadPlayerSelectCard,
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
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
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 조커 콜 표시
            if (trick.jokerCall == JokerCallType.jokerCall && trick.jokerCallSuit != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  l10n.jokerCallAnnouncement(_getSuitSymbol(trick.jokerCallSuit!)),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            // 조커 선공 무늬 표시
            if (trick.jokerLeadSuit != null && trick.cards.isNotEmpty && trick.cards.first.isJoker)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.purple,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  AppLocalizations.of(context)!.jokerLead(_getSuitSymbol(trick.jokerLeadSuit!)),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            Wrap(
              spacing: 4,
              children: [
                for (int i = 0; i < trick.cards.length; i++)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getLocalizedPlayerName(state.players[trick.playerOrder[i]], l10n),
                        style: const TextStyle(color: Colors.white70, fontSize: 9),
                      ),
                      CardWidget(
                        card: trick.cards[i],
                        width: cardWidth,
                        height: cardHeight,
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
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

    // 추천 카드 가져오기
    final recommendedCard = _showHint ? controller.getRecommendedCard() : null;

    // 플레이어가 획득한 점수 카드 (조커 제외)
    final pointCards = controller.humanPlayer.wonCards
        .where((c) => c.isPointCard && !c.isJoker)
        .toList();
    pointCards.sort((a, b) {
      if (a.suit != b.suit) return a.suit!.index.compareTo(b.suit!.index);
      return b.rankValue.compareTo(a.rankValue);
    });

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      color: Colors.black26,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 선공 표시
          if (isLeadPlayer && controller.state.phase == GamePhase.playing)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
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
          // 획득한 점수 카드 - AI와 같은 형식으로 표시
          if (pointCards.isNotEmpty && (controller.state.phase == GamePhase.playing || controller.state.phase == GamePhase.gameEnd))
            Container(
              margin: const EdgeInsets.only(bottom: 2),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Wrap(
                spacing: 2,
                runSpacing: 2,
                alignment: WrapAlignment.center,
                children: pointCards.map((card) => _buildTinyCardFixed(card, controller.state, 32.0)).toList(),
              ),
            ),
          // 카드 목록 - 세로 모드: 2줄, 가로 모드: 1줄 스크롤
          _buildGamePlayerCards(
            hand,
            playableCards,
            recommendedCard,
            controller,
          ),
        ],
      ),
    );
  }

  Widget _buildGamePlayerCards(
    List<PlayingCard> hand,
    List<PlayingCard> playableCards,
    PlayingCard? recommendedCard,
    GameController controller,
  ) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;

    if (isPortrait) {
      // 세로 모드: 2줄 배치
      final cardWidth = (screenWidth - 32) / 6 - 4;
      final cardHeight = cardWidth * 1.4;

      final halfIndex = (hand.length + 1) ~/ 2;
      final firstRow = hand.sublist(0, halfIndex);
      final secondRow = hand.sublist(halfIndex);

      return Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final card in firstRow)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: CardWidget(
                    card: card,
                    width: cardWidth,
                    height: cardHeight,
                    isSelected: selectedCard == card,
                    isPlayable: playableCards.contains(card),
                    isRecommended: recommendedCard != null && _isSameCard(card, recommendedCard),
                    onTap: () => _onCardTap(card, controller),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final card in secondRow)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: CardWidget(
                    card: card,
                    width: cardWidth,
                    height: cardHeight,
                    isSelected: selectedCard == card,
                    isPlayable: playableCards.contains(card),
                    isRecommended: recommendedCard != null && _isSameCard(card, recommendedCard),
                    onTap: () => _onCardTap(card, controller),
                  ),
                ),
            ],
          ),
        ],
      );
    } else {
      // 가로 모드: 1줄 스크롤
      return SizedBox(
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
                    isRecommended: recommendedCard != null && _isSameCard(card, recommendedCard),
                    onTap: () => _onCardTap(card, controller),
                  ),
                ),
            ],
          ),
        ),
      );
    }
  }

  // 두 카드가 같은지 비교
  bool _isSameCard(PlayingCard a, PlayingCard b) {
    if (a.isJoker && b.isJoker) return true;
    if (a.isJoker || b.isJoker) return false;
    return a.suit == b.suit && a.rank == b.rank;
  }

  void _onCardTap(PlayingCard card, GameController controller) {
    if (controller.state.phase != GamePhase.playing) return;
    if (!controller.isHumanTurn) return;
    if (!controller.canPlayCard(card)) return;

    if (selectedCard == card) {
      // 조커 콜 카드(♣3 또는 ♠3)를 선공으로 낼 때만 조커 콜 가능
      final jokerCallCard = controller.state.jokerCall;

      // 디버그 로그
      print('=== Card Tap Debug ===');
      print('card.isJoker: ${card.isJoker}');
      print('isLeadingTrick: ${controller.isLeadingTrick}');
      print('currentTrick: ${controller.state.currentTrick}');
      print('currentTrick.cards.length: ${controller.state.currentTrick?.cards.length}');
      print('currentTrick.cards.isEmpty: ${controller.state.currentTrick?.cards.isEmpty}');
      print('currentTrickNumber: ${controller.state.currentTrickNumber}');
      print('lastCompletedTrick: ${controller.lastCompletedTrick}');
      print('currentPlayer: ${controller.state.currentPlayer}');

      if (controller.canDeclareJokerCall && card == jokerCallCard) {
        _showJokerCallDialog(card, controller);
      } else if (card.isJoker) {
        // 조커 선공 시 무늬 선택 다이얼로그 (선공인 경우에만)
        print('=== Joker Play Debug ===');
        print('isLeadingTrick: ${controller.isLeadingTrick}');
        print('currentTrick.cards.isEmpty: ${controller.state.currentTrick?.cards.isEmpty}');
        if (controller.isLeadingTrick) {
          print('Showing Joker Lead Suit Dialog');
          _showJokerLeadSuitDialog(card, controller);
        } else {
          // 조커를 따라가는 경우 (선공 아님)
          print('Playing Joker as follower');
          controller.humanPlayCard(card);
          setState(() {
            selectedCard = null;
          });
        }
        return;
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

  void _showJokerLeadSuitDialog(PlayingCard card, GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.jokerLeadSuitTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.jokerLeadSuitQuestion),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final suit in Suit.values)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.humanPlayCard(card, jokerLeadSuit: suit);
                      setState(() {
                        selectedCard = null;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (suit == Suit.heart || suit == Suit.diamond)
                          ? Colors.red[100]
                          : Colors.grey[200],
                      foregroundColor: (suit == Suit.heart || suit == Suit.diamond)
                          ? Colors.red
                          : Colors.black,
                    ),
                    child: Text(
                      _getSuitSymbol(suit),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
              ],
            ),
          ],
        ),
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

  void _showDealMissDialog(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final hand = controller.humanPlayer.hand;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.dealMissTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.dealMissConfirm),
            const SizedBox(height: 16),
            // 패 공개
            Text(
              l10n.yourCards,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final card in hand)
                  CardWidget(
                    card: card,
                    width: 40,
                    height: 56,
                  ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.humanDeclareDealMiss();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: Text(l10n.dealMiss, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseScoreExplanation(GameState state) {
    final l10n = AppLocalizations.of(context)!;
    final targetTricks = state.currentBid?.tricks ?? 13;
    const int minContract = 13;
    final isNoFriend = state.friendDeclaration?.isNoFriend ?? false;
    final isNoGiruda = state.giruda == null;
    final isRun = state.declarerTeamPoints >= 20;
    final isBackRun = state.defenderTeamPoints >= 11;
    final declarerWon = state.declarerWon;

    int baseScore;
    String formula;
    String calculation;
    List<String> multipliers = [];
    int specialMultiplier = 1;

    if (declarerWon) {
      // 승리: (득점 - 공약 + 1) + (득점 - 최소) * 2
      final basicPart = state.declarerTeamPoints - targetTricks + 1;
      final bonusPart = (state.declarerTeamPoints - minContract) * 2;
      baseScore = basicPart + bonusPart;
      formula = l10n.scoreFormula;
      calculation = '(${state.declarerTeamPoints}-$targetTricks+1) + (${state.declarerTeamPoints}-$minContract)×2 = $basicPart + $bonusPart = $baseScore';

      if (isRun) {
        specialMultiplier *= 2;
        multipliers.add(l10n.multiplierRun);
      }
      if (isNoGiruda) {
        specialMultiplier *= 2;
        multipliers.add(l10n.multiplierNoGiruda);
      }
      if (isNoFriend) {
        specialMultiplier *= 2;
        multipliers.add(l10n.multiplierNoFriend);
      }
    } else {
      // 패배: -(공약 - 득점)
      baseScore = -(targetTricks - state.declarerTeamPoints);
      formula = l10n.scoreFormulaLose;
      calculation = '-($targetTricks - ${state.declarerTeamPoints}) = $baseScore';

      if (isBackRun) {
        specialMultiplier *= 2;
        multipliers.add(l10n.multiplierBackRun);
      }
    }

    final finalBaseScore = baseScore * specialMultiplier;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            declarerWon ? l10n.scoreCalcWin : l10n.scoreCalcLose,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: declarerWon ? Colors.blue[700] : Colors.red[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formula,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          Text(
            calculation,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          if (multipliers.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              '${l10n.multiplierLabel}: ${multipliers.join(', ')}',
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
            Text(
              '$baseScore × $specialMultiplier = $finalBaseScore',
              style: TextStyle(fontSize: 12, color: Colors.blue[700]),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Base Score = $finalBaseScore',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.scoreMultipliers,
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildGameEndScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;

    // 통계 기록 (한 번만)
    if (!_statsRecorded && state.declarerId != null) {
      _statsRecorded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final statsService = context.read<StatsService>();
        final playerScores = <int, int>{};
        for (int i = 0; i < state.players.length; i++) {
          playerScores[i] = state.getPlayerScore(i);
        }

        // 프렌드 ID 찾기
        int? friendId;
        for (int i = 0; i < state.players.length; i++) {
          if (state.players[i].isFriend) {
            friendId = i;
            break;
          }
        }

        statsService.recordGameResult(
          playerScores: playerScores,
          declarerWon: state.declarerWon,
          declarerId: state.declarerId!,
          friendId: friendId,
        );
      });
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final maxDialogHeight = screenHeight * 0.85;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxDialogHeight),
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.declarerWon ? l10n.declarerTeamWins : l10n.defenderTeamWins,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: state.declarerWon ? Colors.green : Colors.red,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              state.declarerTeamPoints == 20
                  ? '${l10n.declarerTeam}: ${l10n.fullPoints}'
                  : l10n.declarerTeamPoints(state.declarerTeamPoints),
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              state.defenderTeamPoints == 20
                  ? '${l10n.defenderTeam}: ${l10n.fullPoints}'
                  : l10n.defenderTeamPoints(state.defenderTeamPoints),
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              l10n.targetPoints(state.currentBid?.tricks ?? 0),
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // baseScore 계산 설명
            _buildBaseScoreExplanation(state),
            const SizedBox(height: 16),
            Text(
              l10n.score,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < state.players.length; i++)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: i % 2 == 0 ? Colors.grey[100] : Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: i == 0 ? const Radius.circular(7) : Radius.zero,
                          bottom: i == state.players.length - 1 ? const Radius.circular(7) : Radius.zero,
                        ),
                        border: i < state.players.length - 1
                            ? Border(bottom: BorderSide(color: Colors.grey[300]!))
                            : null,
                      ),
                      child: Row(
                        children: [
                          // 역할 아이콘
                          if (state.players[i].isDeclarer)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.declarer,
                                style: TextStyle(fontSize: 10, color: Colors.red[700], fontWeight: FontWeight.bold),
                              ),
                            )
                          else if (state.players[i].isFriend)
                            Container(
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue[100],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                l10n.friend,
                                style: TextStyle(fontSize: 10, color: Colors.blue[700], fontWeight: FontWeight.bold),
                              ),
                            ),
                          // 이름
                          Expanded(
                            child: Text(
                              _getLocalizedPlayerName(state.players[i], l10n),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          // 점수
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: state.getPlayerScore(state.players[i].id) >= 0
                                  ? Colors.green[50]
                                  : Colors.red[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: state.getPlayerScore(state.players[i].id) >= 0
                                    ? Colors.green[300]!
                                    : Colors.red[300]!,
                              ),
                            ),
                            child: Text(
                              l10n.points(state.getPlayerScore(state.players[i].id)),
                              style: TextStyle(
                                fontSize: 14,
                                color: state.getPlayerScore(state.players[i].id) >= 0
                                    ? Colors.green[700]
                                    : Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showGameResult = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    l10n.confirm,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _statsRecorded = false;
                      _showGameResult = true;
                      _showHint = false;
                    });
                    controller.reset();
                    controller.startNewGame();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: Text(
                    l10n.newGame,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }
}
