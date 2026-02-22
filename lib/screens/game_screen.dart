import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/card.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../services/ad_service.dart';
import '../services/game_controller.dart';
import '../services/mighty_tracking_service.dart';
import '../services/stats_service.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/card_widget.dart';
import 'kitty_dialog.dart';
import 'friend_dialog.dart' show FriendSelectionScreen;

class GameScreen extends StatefulWidget {
  final bool isAutoPlay;

  const GameScreen({super.key, this.isAutoPlay = false});

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
  bool _showGameResult = false;
  bool _showTrickDetails = true;
  final ScrollController _trickTableScrollController = ScrollController();

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
    _trickTableScrollController.dispose();
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
    if (widget.isAutoPlay) {
      final controller = context.read<GameController>();
      controller.stopAutoPlay();
    }
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
                  _showTrickDetails = false;
                  _showHint = false;
                  controller.startNewGame();
                },
                onAdNotAvailable: () {
                  _statsRecorded = false;
                  _allPassedDialogShown = false;
                  _bidInitialized = false;
                  _showGameResult = true;
                  _showTrickDetails = false;
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
            title: Text(
              widget.isAutoPlay ? l10n.demoMode : l10n.appTitle,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: widget.isAutoPlay ? Colors.teal[800] : Colors.green[900],
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: widget.isAutoPlay ? () {
                controller.stopAutoPlay();
                Navigator.pop(context);
              } : _exitGame,
            ),
            actions: widget.isAutoPlay ? [
              // 일시정지/재개 버튼
              IconButton(
                onPressed: () {
                  if (controller.isAutoPlayPaused) {
                    controller.resumeAutoPlay();
                  } else {
                    controller.pauseAutoPlay();
                  }
                },
                icon: Icon(
                  controller.isAutoPlayPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                ),
                tooltip: controller.isAutoPlayPaused ? l10n.resumeDemo : l10n.pauseDemo,
              ),
              // 관전 종료 버튼
              TextButton.icon(
                onPressed: () {
                  controller.stopAutoPlay();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.stop, color: Colors.white),
                label: Text(l10n.stopDemo, style: const TextStyle(color: Colors.white)),
              ),
            ] : [
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
        // 모두 패스한 경우
        if (state.allPassed) {
          if (widget.isAutoPlay) {
            // 마지막 플레이어 설명이 아직 표시 중이면 배팅 화면 유지
            if (controller.lastBidExplanation != null) {
              return _buildBiddingScreen(controller);
            }
            return _buildAutoPlayAllPassedScreen(controller);
          }
          if (!_allPassedDialogShown) {
            _allPassedDialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showAllPassedDialog(controller);
            });
          }
        }
        return _buildWaitingScreen(controller);
      case GamePhase.dealing:
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      case GamePhase.bidding:
        return _buildBiddingScreen(controller);
      case GamePhase.selectingKitty:
        // auto-play: 마지막 플레이어 설명이 아직 표시 중이면 배팅 화면 유지
        if (widget.isAutoPlay && controller.lastBidExplanation != null) {
          return _buildBiddingScreen(controller);
        }
        return _buildKittyScreen(controller);
      case GamePhase.declaringFriend:
        if (widget.isAutoPlay && controller.showBidSummary) {
          return _buildBidSummaryScreen(controller);
        }
        return _buildFriendScreen(controller);
      case GamePhase.playing:
      case GamePhase.roundEnd:
        return _buildPlayingScreen(controller);
      case GamePhase.gameEnd:
        if (widget.isAutoPlay) {
          // auto-play: 게임 결과를 보여주되, controller가 자동으로 새 게임 시작
          return _buildGameEndScreen(controller);
        }
        if (_showGameResult) {
          return _buildGameEndScreen(controller);
        } else if (_showTrickDetails) {
          return _buildTrickDetailsScreen(controller);
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

  Widget _buildAutoPlayAllPassedScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n.allPassedTitle,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.allPassedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                controller.startNextAutoGame();
              },
              icon: const Icon(Icons.skip_next, color: Colors.white),
              label: Text(
                l10n.nextGameAuto,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiddingScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;

    if (widget.isAutoPlay) {
      return _buildAutoPlayBiddingScreen(controller);
    }

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

  Widget _buildAutoPlayBiddingScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;
    final explanation = controller.lastBidExplanation;

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
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              if (state.currentBid != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                    l10n.highestBid(_formatBid(state.currentBid!)),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                )
              else
                Text(l10n.noBidYet, style: const TextStyle(color: Colors.white70)),
            ],
          ),
        ),
        // 5명 플레이어 카드 공개 + 설명을 해당 플레이어 아래에 표시
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Column(
              children: [
                for (int i = 0; i < state.players.length; i++)
                  _buildBiddingPlayerWithCards(state, i, controller.isProcessing, l10n, explanation,
                    friendPlayerId: (explanation != null) ? _findExpectedFriend(explanation, state)?.id : null),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBidSummaryScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;
    final bid = state.currentBid!;
    final declarer = state.players[state.declarerId!];
    final declarerName = _getLocalizedPlayerName(declarer, l10n);
    final giruda = state.giruda;
    final targetTricks = bid.tricks;

    // 노기루다 여부
    final isNoGiruda = giruda == null;

    // 반응형 스케일: 화면 높이 기준 (기준: 800dp)
    final screenHeight = MediaQuery.of(context).size.height;
    final compact = screenHeight < 700;
    final s = compact ? 0.82 : 1.0; // 스케일 팩터

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: (12 * s)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 주공 정보
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: compact ? 8 : 14),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: compact
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.declarer, style: TextStyle(color: Colors.white70, fontSize: 13 * s)),
                      const SizedBox(width: 10),
                      Text(declarerName, style: TextStyle(fontSize: 20 * s, fontWeight: FontWeight.bold, color: Colors.amber)),
                    ],
                  )
                : Column(
                    children: [
                      Text(l10n.declarer, style: const TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text(declarerName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.amber)),
                    ],
                  ),
            ),
            SizedBox(height: 10 * s),

            // 기루다 + 목표
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10 * s),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        Text(l10n.giruda, style: TextStyle(color: Colors.white70, fontSize: 13 * s)),
                        SizedBox(height: 4 * s),
                        if (isNoGiruda)
                          Text(l10n.noGiruda, style: TextStyle(fontSize: 18 * s, fontWeight: FontWeight.bold, color: Colors.white))
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _getSuitSymbol(giruda),
                                style: TextStyle(
                                  fontSize: 28 * s,
                                  color: (giruda == Suit.heart || giruda == Suit.diamond) ? Colors.red[300] : Colors.white,
                                ),
                              ),
                              SizedBox(width: 6 * s),
                              Text(_getSuitName(giruda, l10n), style: TextStyle(fontSize: 18 * s, fontWeight: FontWeight.bold, color: Colors.white)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10 * s),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10 * s),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        Text(l10n.tricks, style: TextStyle(color: Colors.white70, fontSize: 13 * s)),
                        SizedBox(height: 4 * s),
                        Text('$targetTricks', style: TextStyle(fontSize: 30 * s, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8 * s),

            // 프렌드 정보
            _buildFriendInfoRow(controller, l10n),
            SizedBox(height: 8 * s),

            // 주공 최종 카드
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(8 * s),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.style, color: Colors.amber, size: 14 * s),
                      SizedBox(width: 4 * s),
                      Text(
                        '$declarerName ${l10n.handCards}',
                        style: TextStyle(color: Colors.amber, fontSize: 12 * s, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * s),
                  Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    children: _sortedHand(declarer.hand, giruda)
                        .map((card) => _buildTinyCardFixed(card, controller.state, 32.0))
                        .toList(),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8 * s),

            // 점수 획득 전략
            _buildStrategySection(controller, l10n, s),
            SizedBox(height: 8 * s),

            SizedBox(height: compact ? 10 : 20),

            // 게임 시작 버튼
            SizedBox(
              width: double.infinity,
              height: compact ? 40 : 48,
              child: ElevatedButton.icon(
                onPressed: () => controller.confirmBidSummary(),
                icon: Icon(Icons.play_arrow, size: compact ? 18 : 24),
                label: Text(
                  l10n.startGame,
                  style: TextStyle(fontSize: 16 * s, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            SizedBox(height: compact ? 8 : 16),
            // 배너 광고
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  List<PlayingCard> _sortedHand(List<PlayingCard> hand, Suit? giruda) {
    final sorted = hand.toList();
    sorted.sort((a, b) {
      if (a.isJoker && !b.isJoker) return -1;
      if (!a.isJoker && b.isJoker) return 1;
      if (a.isJoker && b.isJoker) return 0;
      final aIsGiruda = a.suit == giruda;
      final bIsGiruda = b.suit == giruda;
      if (aIsGiruda && !bIsGiruda) return -1;
      if (!aIsGiruda && bIsGiruda) return 1;
      if (a.suit == b.suit) return b.rankValue.compareTo(a.rankValue);
      return a.suit!.index.compareTo(b.suit!.index);
    });
    return sorted;
  }

  Widget _buildStrategySection(GameController controller, AppLocalizations l10n, double s) {
    final strategyPoints = controller.getStrategyPoints();
    if (strategyPoints.isEmpty) return const SizedBox.shrink();
    final giruda = controller.state.giruda;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.military_tech, color: Colors.greenAccent, size: 18 * s),
              SizedBox(width: 6 * s),
              Text(
                '${l10n.scoreStrategy} (${giruda != null ? _getSuitSymbol(giruda) : "NT"})',
                style: TextStyle(color: Colors.greenAccent, fontSize: 13 * s, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 6 * s),
          for (int i = 0; i < strategyPoints.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: 3 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${String.fromCharCode(0x2460 + i)} ', style: TextStyle(color: Colors.white54, fontSize: 12 * s)),
                  Expanded(
                    child: _buildSuitColoredText(
                      _getStrategyText(strategyPoints[i], l10n),
                      TextStyle(color: Colors.white70, fontSize: 12 * s),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getStrategyText((String, Map<String, String>) strategy, AppLocalizations l10n) {
    final (code, params) = strategy;
    return switch (code) {
      'STEP_FIRST_ACE' => l10n.stepFirstAce(params['card']!),
      'STEP_FIRST_KING' => l10n.stepFirstKing(params['card']!),
      'STEP_FIRST_MIGHTY' => l10n.stepFirstMighty,
      'STEP_FIRST_JOKER' => l10n.stepFirstJoker,
      'STEP_JOKER_CALL_EXHAUST' => l10n.stepJokerCallExhaust(params['card']!),
      'STEP_GIRUDA_ACE' => l10n.stepGirudaAce(params['card']!),
      'STEP_GIRUDA_ACE_CHECK_K' => l10n.stepGirudaAceCheckK(params['card']!),
      'STEP_GIRUDA_KING' => l10n.stepGirudaKing(params['card']!),
      'STEP_JOKER_CALL_GIRUDA' => l10n.stepJokerCallGiruda(params['suit']!),
      'STEP_JOKER_AFTER_FRIEND' => l10n.stepJokerAfterFriend,
      'STEP_FRIEND_MIGHTY_JOIN' => l10n.stepFriendMightyJoin,
      'STEP_FRIEND_JOKER_JOIN' => l10n.stepFriendJokerJoin,
      'STEP_LOW_GIRUDA_FRIEND_LURE' => l10n.stepLowGirudaFriendLure(params['highCards']!, params['card']!, params['mightyCard']!),
      'STEP_GIRUDA_Q_RECLAIM' => l10n.stepGirudaQReclaim(params['card']!),
      'STEP_GIRUDA_LEAD_FRIEND' => l10n.stepGirudaLeadFriend(params['friendCard']!),
      'STEP_JOKER_CALL_FRIEND' => l10n.stepJokerCallFriend(params['friendCard']!),
      'STEP_LURE_WITH_GIRUDA' => l10n.stepLureWithGiruda(params['card']!, params['friendCard']!),
      'STEP_SUIT_LEAD_FRIEND' => l10n.stepSuitLeadFriend(params['card']!, params['friendCard']!),
      'STEP_JOKER_CALL' => l10n.stepJokerCall(params['suits']!),
      'STEP_JOKER_OPTIMAL' => l10n.stepJokerOptimal,
      'STEP_HIGH_CARD_ATTACK' => l10n.stepHighCardAttack(params['cards']!),
      'STEP_MIGHTY_TIMING' => l10n.stepMightyTiming,
      'STEP_VOID_CUT' => l10n.stepVoidCut(params['suits']!),
      'STEP_ENDGAME_SCORING' => l10n.stepEndgameScoring,
      _ => code,
    };
  }

  Widget _buildFriendInfoRow(GameController controller, AppLocalizations l10n) {
    final declaration = controller.pendingDeclaration;
    if (declaration == null) return const SizedBox.shrink();

    // 프렌드 카드/조건 텍스트
    String friendText;
    Widget? cardWidget;

    if (declaration.isNoFriend) {
      friendText = l10n.noFriend;
    } else if (declaration.isFirstTrickWinner) {
      friendText = l10n.firstTrickFriend;
    } else if (declaration.card != null) {
      final card = declaration.card!;
      if (card.isJoker) {
        friendText = l10n.jokerOwner;
        cardWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)]),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.yellowAccent, size: 18),
              SizedBox(width: 4),
              Text('JOKER', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
        );
      } else {
        friendText = l10n.cardOwner('${card.suitSymbol}${card.rankSymbol}');
        final isRed = card.suit == Suit.heart || card.suit == Suit.diamond;
        cardWidget = Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '${card.suitSymbol}${card.rankSymbol}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isRed ? Colors.red : Colors.black,
              fontFamily: 'Roboto',
            ),
          ),
        );
      }
    } else {
      friendText = l10n.trickWinner(declaration.trickNumber!);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.people, color: Colors.cyan, size: 18),
          const SizedBox(width: 8),
          Text(
            l10n.friend,
            style: const TextStyle(color: Colors.cyan, fontSize: 14),
          ),
          const SizedBox(width: 12),
          if (cardWidget != null) ...[
            cardWidget,
            const SizedBox(width: 8),
          ],
          Text(
            friendText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// 배팅 결과 최소 점수 설명: 프렌드 타입에 따라 동적 생성
  String _getBidMinDesc(GameController controller, AppLocalizations l10n) {
    final declaration = controller.pendingDeclaration;
    if (declaration == null) return l10n.bidSummaryEstMinDesc;

    final card = declaration.card;
    if (card == null) return l10n.bidSummaryEstMinDesc;

    // 프렌드 카드 이름 결정
    String friendName;
    if (card.isJoker) {
      friendName = l10n.friendCardJoker;
    } else if (card.rank == Rank.ace) {
      final mighty = controller.state.mighty;
      if (card.suit == mighty.suit && card.rank == mighty.rank) {
        friendName = l10n.friendCardMighty;
      } else {
        friendName = '${_getSuitSymbol(card.suit!)}A';
      }
    } else {
      friendName = '${_getSuitSymbol(card.suit!)}${card.rank == Rank.king ? "K" : card.rank == Rank.queen ? "Q" : ""}';
    }

    return l10n.bidSummaryEstMinDescDynamic(friendName);
  }

  Widget _buildScoreRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildKittySummaryScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;
    final explanation = controller.kittyExplanation!;
    final declarerName = _getLocalizedPlayerName(state.players[state.declarerId!], l10n);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 타이틀
            Text(
              l10n.kittySummaryTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              declarerName,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 20),

            // 바닥에서 받은 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.add_circle_outline, color: Colors.lightBlueAccent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        l10n.kittyReceivedCards,
                        style: const TextStyle(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: explanation.kittyCards
                        .map((card) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 3),
                              child: _buildTinyCardFixed(card, state, 36.0),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 버릴 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.remove_circle_outline, color: Colors.redAccent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        l10n.kittyDiscardCards,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (int i = 0; i < explanation.discardCards.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          _buildTinyCardFixed(explanation.discardCards[i], state, 36.0, dimmed: true),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _getDiscardReason(explanation.discardReasons[i], l10n),
                              style: const TextStyle(color: Colors.white38, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // 기루다 변경 정보
            if (explanation.girudaChanged) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz, color: Colors.amber, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${l10n.giruda}: ',
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                            ),
                            TextSpan(
                              text: _getSuitName(explanation.originalGiruda, l10n),
                              style: const TextStyle(color: Colors.white54, fontSize: 14),
                            ),
                            const TextSpan(
                              text: ' → ',
                              style: TextStyle(color: Colors.amber, fontSize: 14),
                            ),
                            TextSpan(
                              text: _getSuitName(explanation.newGiruda, l10n),
                              style: const TextStyle(
                                color: Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: ' ${l10n.goalPlus2}',
                              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),

            // 최종 보유 카드 10장
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.back_hand, color: Colors.greenAccent, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        l10n.kittyFinalHand,
                        style: const TextStyle(
                          color: Colors.greenAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 3,
                    runSpacing: 4,
                    alignment: WrapAlignment.center,
                    children: [
                      ...explanation.finalHand
                          .map((card) => _buildTinyCardFixed(card, state, 30.0)),
                      // 버려진 카드를 흐리게 표시
                      ...explanation.discardCards
                          .map((card) => _buildTinyCardFixed(card, state, 30.0, dimmed: true)),
                    ],
                  ),
                ],
              ),
            ),

            // 예상 점수 변화 섹션
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.trending_up, color: Colors.purple[300], size: 18),
                      const SizedBox(width: 6),
                      Text(
                        explanation.girudaChanged
                            ? '${l10n.kittyScoreChange} (${_getSuitSymbol(explanation.originalGiruda!)} → ${_getSuitSymbol(explanation.newGiruda!)})'
                            : '${l10n.kittyScoreChange} (${_getSuitSymbol(explanation.newGiruda!)})',
                        style: TextStyle(
                          color: Colors.purple[300],
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          fontFamily: 'Roboto',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 교체 전
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.kittyBeforeExchange} ${_getSuitSymbol(explanation.originalGiruda!)}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 11, fontFamily: 'Roboto'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${explanation.beforeMinPoints}~${explanation.beforeMaxPoints}',
                            style: const TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          Text(
                            l10n.optimalScore(explanation.beforeOptimalPoints),
                            style: TextStyle(color: Colors.orange[300], fontSize: 12),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Icon(Icons.arrow_forward, color: Colors.purple[300], size: 20),
                      ),
                      // 교체 후
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${l10n.kittyAfterExchange} ${_getSuitSymbol(explanation.newGiruda!)}',
                            style: TextStyle(color: Colors.grey[400], fontSize: 11, fontFamily: 'Roboto'),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${explanation.afterMinPoints}~${explanation.afterMaxPoints}',
                            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            l10n.optimalScore(explanation.afterOptimalPoints),
                            style: TextStyle(
                              color: explanation.afterOptimalPoints > explanation.beforeOptimalPoints
                                  ? Colors.greenAccent
                                  : explanation.afterOptimalPoints < explanation.beforeOptimalPoints
                                      ? Colors.red[300]
                                      : Colors.orange[300],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      if (explanation.afterOptimalPoints != explanation.beforeOptimalPoints) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: explanation.afterOptimalPoints > explanation.beforeOptimalPoints
                                ? Colors.green[800]
                                : Colors.red[800],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${explanation.afterOptimalPoints > explanation.beforeOptimalPoints ? '+' : ''}${explanation.afterOptimalPoints - explanation.beforeOptimalPoints}',
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // 기루다 비교 섹션
            if (explanation.girudaComparison.isNotEmpty) ...[
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.compare_arrows, color: Colors.tealAccent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          l10n.girudaComparisonTitle,
                          style: const TextStyle(
                            color: Colors.tealAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _buildGirudaComparisonContent(explanation),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
            // 자동 진행 타이머
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGirudaComparisonContent(KittyExplanation explanation) {
    final comp = explanation.girudaComparison;
    if (comp.isEmpty) return const SizedBox.shrink();

    final currentSuit = explanation.newGiruda;
    int bestOptimal = 0;
    Suit? bestSuit;
    for (final (suit, _, _, optimal) in comp) {
      if (optimal > bestOptimal) {
        bestOptimal = optimal;
        bestSuit = suit;
      }
    }

    int currentOptimal = 0;
    for (final (suit, _, _, optimal) in comp) {
      if (suit == currentSuit) {
        currentOptimal = optimal;
        break;
      }
    }

    return Column(
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: comp.map((entry) {
            final (suit, min, max, optimal) = entry;
            final isCurrent = suit == currentSuit;
            final isBest = suit == bestSuit && bestSuit != currentSuit;
            final suitSymbol = switch (suit) {
              Suit.spade => '♠', Suit.heart => '♥',
              Suit.diamond => '♦', Suit.club => '♣', _ => ''
            };
            final suitColor = _getSuitColorForInfo(suit!);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isCurrent
                      ? Colors.teal[400]!
                      : isBest
                          ? Colors.amber[600]!
                          : Colors.grey[300]!,
                  width: isCurrent || isBest ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(suitSymbol, style: TextStyle(color: suitColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Roboto')),
                      if (isCurrent)
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Icon(Icons.check_circle, color: Colors.teal[600], size: 12),
                        ),
                      if (isBest)
                        Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Icon(Icons.star, color: Colors.amber[700], size: 12),
                        ),
                    ],
                  ),
                  Text('$min~$max', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                  Text(
                    '$optimal점',
                    style: TextStyle(
                      color: isCurrent ? Colors.teal[700] : isBest ? Colors.amber[800] : Colors.grey[800],
                      fontSize: 13,
                      fontWeight: isCurrent || isBest ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        if (bestSuit != null && bestSuit != currentSuit && bestOptimal > currentOptimal) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bestOptimal >= currentOptimal + 3
                  ? Colors.amber[900]!.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              bestOptimal >= currentOptimal + 3
                  ? '${switch (bestSuit) { Suit.spade => '♠', Suit.heart => '♥', Suit.diamond => '♦', Suit.club => '♣', _ => '' }} +${bestOptimal - currentOptimal}점 (변경 시 패널티 +2)'
                  : '${switch (bestSuit) { Suit.spade => '♠', Suit.heart => '♥', Suit.diamond => '♦', Suit.club => '♣', _ => '' }} +${bestOptimal - currentOptimal}점 (변경 패널티 감안 시 유지 적절)',
              style: TextStyle(
                color: bestOptimal >= currentOptimal + 3 ? Colors.amber[200] : Colors.grey[400],
                fontSize: 11,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _getDiscardReason(String reason, AppLocalizations l10n) {
    switch (reason) {
      case 'CUT_SUIT':
        return l10n.discardReasonCutSuit;
      case 'NON_GIRUDA_LOW':
        return l10n.discardReasonNonGirudaLow;
      case 'LOW_VALUE':
        return l10n.discardReasonLowValue;
      case 'LEAST_USEFUL':
        return l10n.discardReasonLeastUseful;
      default:
        return '';
    }
  }

  Widget _buildFriendSummaryScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;
    final explanation = controller.friendExplanation!;
    final declaration = explanation.declaration;
    final declarerName = _getLocalizedPlayerName(state.players[state.declarerId!], l10n);

    // 프렌드 카드/타입 표시 문자열
    String friendTypeText;
    Widget? friendCardWidget;
    Color friendColor;
    IconData friendIcon;

    if (declaration.isNoFriend) {
      friendTypeText = l10n.noFriend;
      friendColor = Colors.grey;
      friendIcon = Icons.person_off;
    } else if (declaration.isFirstTrickWinner) {
      friendTypeText = l10n.firstTrickFriend;
      friendColor = Colors.amber;
      friendIcon = Icons.emoji_events;
    } else if (declaration.trickNumber != null) {
      friendTypeText = l10n.trickWinner(declaration.trickNumber!);
      friendColor = Colors.amber;
      friendIcon = Icons.emoji_events;
    } else if (declaration.card != null) {
      friendTypeText = l10n.cardOwner(_getCardString(declaration.card!));
      friendColor = Colors.lightBlueAccent;
      friendIcon = Icons.style;
      friendCardWidget = _buildTinyCardFixed(declaration.card!, state, 40.0);
    } else {
      friendTypeText = '?';
      friendColor = Colors.white;
      friendIcon = Icons.help_outline;
    }

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 타이틀
            Text(
              l10n.friendSummaryTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              declarerName,
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 16),

            // 주공 보유 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.style, color: Colors.white70, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        l10n.handCards,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    children: state.players[state.declarerId!].hand
                        .map((card) => _buildTinyCardFixed(card, state, 32.0))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 프렌드 선언 내용
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: friendColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: friendColor.withValues(alpha: 0.6), width: 2),
              ),
              child: Column(
                children: [
                  Icon(friendIcon, color: friendColor, size: 40),
                  const SizedBox(height: 12),
                  if (friendCardWidget != null) ...[
                    friendCardWidget,
                    const SizedBox(height: 10),
                  ],
                  Text(
                    friendTypeText,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: friendColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (explanation.isFull) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.fullDeclarationWarning,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 선택 이유
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _getFriendReason(explanation.reason, l10n),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 초구 전략
            if (explanation.firstTrickCard != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.play_circle_outline, color: Colors.orange, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          l10n.firstTrickStrategy,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildTinyCardFixed(explanation.firstTrickCard!, state, 36.0),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _getFirstTrickStrategy(explanation.firstTrickStrategy, l10n),
                            style: const TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
            // 자동 진행 타이머
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white38,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getFirstTrickStrategy(String strategy, AppLocalizations l10n) {
    switch (strategy) {
      case 'FIRST_ACE':
        return l10n.firstTrickAce;
      case 'FIRST_KING':
        return l10n.firstTrickKing;
      case 'FIRST_GIVE_UP':
        return l10n.firstTrickGiveUp;
      default:
        return '';
    }
  }

  String _getFriendStrategyText((String, Map<String, String>) strategy, AppLocalizations l10n) {
    final (code, params) = strategy;
    switch (code) {
      case 'FIRST_TRICK_ACE_LEAD':
        return l10n.strategyFirstTrickAceLead(params['card']!);
      case 'FIRST_TRICK_PASS_FRIEND_WIN':
        return l10n.strategyFirstTrickPassFriendWin;
      case 'FIRST_TRICK_KING_LEAD':
        return l10n.strategyFirstTrickKingLead(params['card']!);
      case 'FIRST_TRICK_PASS_FRIEND':
        return l10n.strategyFirstTrickPassFriend;
      case 'PASS_TO_MIGHTY_FRIEND':
        return l10n.strategyPassToMightyFriend;
      case 'PASS_TO_JOKER_FRIEND':
        return l10n.strategyPassToJokerFriend;
      case 'PASS_TRUMP_TO_FRIEND':
        return l10n.strategyPassTrumpToFriend(params['passCard']!, params['friendCard']!, params['rank']!);
      case 'PASS_SUIT_TO_FRIEND':
        return l10n.strategyPassSuitToFriend(params['card']!, params['friendCard']!);
      case 'TRUMP_DOMINATE':
        return l10n.strategyTrumpDominate(params['source'] == 'friend' ? l10n.strategySourceFriend : l10n.strategySourceReclaim, params['cards']!);
      case 'TRUMP_EXHAUST':
        return l10n.strategyTrumpExhaust(params['source'] == 'friend' ? l10n.strategySourceFriend : l10n.strategySourceReclaim, params['cards']!);
      case 'TRUMP_EXHAUST_CHECK_K':
        return l10n.strategyTrumpExhaustCheckK(params['cards']!);
      case 'TRUMP_MID_DRAW':
        return l10n.strategyTrumpMidDraw(params['suit']!);
      case 'JOKER_AFTER_FRIEND':
        return l10n.strategyJokerAfterFriend;
      case 'JOKER_CALL_GIRUDA':
        return l10n.strategyJokerCallGiruda(params['suit']!);
      case 'LOW_GIRUDA_FRIEND_LURE':
        return l10n.strategyLowGirudaFriendLure(params['card']!);
      case 'GIRUDA_Q_RECLAIM':
        return l10n.strategyGirudaQReclaim(params['card']!);
      case 'JOKER_CALL_SUITS':
        return l10n.strategyJokerCallSuits(params['suits']!);
      case 'JOKER_CALL_WEAK':
        return l10n.strategyJokerCallWeak;
      case 'JOKER_OPTIMAL':
        return l10n.strategyJokerOptimal;
      case 'HIGH_CARD_ATTACK':
        return l10n.strategyHighCardAttack(params['cards']!);
      case 'MIGHTY_TIMING':
        return l10n.strategyMightyTiming;
      case 'VOID_TRUMP_CUT':
        return l10n.strategyVoidTrumpCut(params['suits']!);
      default:
        return code;
    }
  }

  String _getFriendReason(String reason, AppLocalizations l10n) {
    switch (reason) {
      case 'NO_FRIEND_STRONG':
        return l10n.friendReasonNoFriendStrong;
      case 'FIRST_TRICK':
        return l10n.friendReasonFirstTrick;
      case 'NTH_TRICK':
        return l10n.friendReasonNthTrick;
      case 'NEED_MIGHTY':
        return l10n.friendReasonNeedMighty;
      case 'NEED_JOKER':
        return l10n.friendReasonNeedJoker;
      case 'NEED_GIRUDA_ACE':
        return l10n.friendReasonNeedGirudaAce;
      case 'NEED_GIRUDA_KING':
        return l10n.friendReasonNeedGirudaKing;
      case 'NEED_GIRUDA_MID':
        return l10n.friendReasonNeedGirudaMid;
      case 'NEED_ACE':
        return l10n.friendReasonNeedAce;
      case 'NEED_STRONG_CARD':
        return l10n.friendReasonNeedStrongCard;
      case 'NO_FRIEND_ALL':
        return l10n.friendReasonNoFriendAll;
      default:
        return '';
    }
  }

  Widget _buildBiddingPlayerWithCards(GameState state, int playerId, bool isProcessing, AppLocalizations l10n, BidExplanation? explanation, {int? friendPlayerId}) {
    final player = state.players[playerId];
    final isPassed = state.passedPlayers[playerId];
    final isCurrentBidder = state.currentBidder == playerId;
    final hasBid = state.currentBid?.playerId == playerId;
    // 이 플레이어가 마지막 설명 대상인지
    final hasExplanation = explanation != null && explanation.playerId == playerId;
    // 이 플레이어가 예상 프렌드인지
    final isFriend = friendPlayerId != null && friendPlayerId == playerId;

    final handCards = List<PlayingCard>.from(player.hand);
    handCards.sort((a, b) {
      if (a.isJoker) return -1;
      if (b.isJoker) return 1;
      if (a.suit != b.suit) return a.suit!.index.compareTo(b.suit!.index);
      return b.rankValue.compareTo(a.rankValue);
    });

    Color borderColor;
    String statusText;
    Color statusColor;

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
      statusText = '${state.currentBid!.tricks} ${_getSuitName(state.currentBid!.suit, l10n)}';
      statusColor = Colors.amber;
    } else {
      borderColor = Colors.white38;
      statusText = l10n.waiting;
      statusColor = Colors.white54;
    }

    // 하이라이트: 설명 대상 플레이어
    if (hasExplanation) {
      borderColor = explanation.passed ? Colors.grey[300]! : Colors.amber;
    }
    // 프렌드 하이라이트 (설명 대상이 아닌 경우)
    if (isFriend && !hasExplanation) {
      borderColor = Colors.cyanAccent;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: hasExplanation
                ? (explanation.passed
                    ? Colors.grey.withValues(alpha: 0.25)
                    : Colors.amber.withValues(alpha: 0.2))
                : isFriend
                    ? Colors.cyan.withValues(alpha: 0.15)
                    : (isCurrentBidder && isProcessing
                        ? Colors.orange.withValues(alpha: 0.15)
                        : Colors.black38),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: borderColor,
              width: hasExplanation || isFriend || (isCurrentBidder && isProcessing) ? 2 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 왼쪽: 이름 + 상태
              SizedBox(
                width: 60,
                child: Column(
                  children: [
                    Text(
                      _getLocalizedPlayerName(player, l10n),
                      style: TextStyle(
                        color: hasExplanation
                            ? (explanation.passed ? Colors.white : Colors.amber)
                            : isFriend
                                ? Colors.cyanAccent
                                : (isCurrentBidder ? Colors.orange : Colors.white),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (isFriend) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.friendBadge,
                          style: const TextStyle(color: Colors.cyanAccent, fontSize: 9, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              // 오른쪽: 카드 목록
              Expanded(
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: handCards.map((card) => _buildTinyCardFixed(card, state, 24.0)).toList(),
                ),
              ),
            ],
          ),
        ),
        // 현재 배팅 중이거나 설명 대상인 플레이어의 카드를 크게 표시
        if (hasExplanation || (isCurrentBidder && isProcessing))
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 16, right: 16, top: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Wrap(
              spacing: 3,
              runSpacing: 3,
              children: handCards.map((card) => _buildTinyCardFixed(card, state, 36.0)).toList(),
            ),
          ),
        // 설명을 해당 플레이어 카드 바로 아래에 표시
        if (hasExplanation)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(left: 16, right: 16, bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: explanation.passed
                  ? Colors.grey[800]!.withValues(alpha: 0.9)
                  : Colors.amber.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
              border: Border.all(
                color: explanation.passed ? Colors.grey[600]! : Colors.amber.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: _buildBidExplanationContent(explanation, state, l10n),
          )
        else
          const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildBidExplanationContent(BidExplanation explanation, GameState state, AppLocalizations l10n) {
    final keyCardInfo = _getKeyCardInfo(explanation, state, l10n);
    if (explanation.passed) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.block, color: Colors.grey, size: 16),
              const SizedBox(width: 4),
              Text(
                l10n.pass,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (explanation.suit != null) ...[
            const SizedBox(height: 3),
            if (explanation.scoreBreakdown.isNotEmpty) ...[
              _buildSuitColoredText(
                '${explanation.scoreBreakdown} ${l10n.estimatedMinWins(explanation.totalMinTricks)}',
                const TextStyle(color: Colors.white38, fontSize: 9),
              ),
              const SizedBox(height: 2),
            ],
            _buildSuitColoredText(
              '${_getSuitSymbol(explanation.suit!)} ${explanation.girudaCount}${l10n.cardCount(explanation.girudaCount).replaceAll('${explanation.girudaCount}', '').trim()}, ${l10n.estimatedRange(explanation.minPoints, explanation.maxPoints)} (${l10n.optimalScore(explanation.optimalPoints)})',
              const TextStyle(color: Colors.white54, fontSize: 10),
            ),
            if (explanation.suitComparison.isNotEmpty) ...[
              const SizedBox(height: 6),
              _buildBidSuitComparison(explanation),
            ],
          ],
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.gavel, color: Colors.amber, size: 16),
              const SizedBox(width: 4),
              Text(
                '${explanation.tricks} ${_getSuitName(explanation.suit, l10n)}',
                style: const TextStyle(color: Colors.amber, fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 3),
          if (explanation.scoreBreakdown.isNotEmpty) ...[
            _buildSuitColoredText(
              '${explanation.scoreBreakdown} ${l10n.estimatedMinWins(explanation.totalMinTricks)}',
              const TextStyle(color: Colors.white38, fontSize: 9),
            ),
            const SizedBox(height: 2),
          ],
          _buildSuitColoredText(
            '${_getSuitSymbol(explanation.suit!)} ${explanation.girudaCount}${l10n.cardCount(explanation.girudaCount).replaceAll('${explanation.girudaCount}', '').trim()}, ${l10n.estimatedRange(explanation.minPoints, explanation.maxPoints)} (${l10n.optimalScore(explanation.optimalPoints)})',
            const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          if (explanation.friendType != null) ...[
            const SizedBox(height: 3),
            Row(
              children: [
                const Icon(Icons.people, color: Colors.cyan, size: 13),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    _getFriendExpectedText(explanation, l10n),
                    style: const TextStyle(color: Colors.cyanAccent, fontSize: 10),
                  ),
                ),
              ],
            ),
          ],
          if (explanation.suitComparison.isNotEmpty) ...[
            const SizedBox(height: 6),
            _buildBidSuitComparison(explanation),
          ],
        ],
      );
    }
  }

  Widget _buildBidSuitComparison(BidExplanation explanation) {
    final comp = explanation.suitComparison;
    final selectedSuit = explanation.suit;

    int bestOptimal = 0;
    Suit? bestSuit;
    for (final (suit, _, _, optimal) in comp) {
      if (optimal > bestOptimal) {
        bestOptimal = optimal;
        bestSuit = suit;
      }
    }

    return Wrap(
      spacing: 4,
      runSpacing: 2,
      children: comp.map((entry) {
        final (suit, min, max, optimal) = entry;
        final isSelected = suit == selectedSuit;
        final isBest = suit == bestSuit && bestSuit != selectedSuit;
        final suitColor = _getSuitColorOnDark(suit);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isSelected
                  ? Colors.teal
                  : isBest
                      ? Colors.amber[700]!
                      : Colors.grey[300]!,
              width: isSelected || isBest ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _getSuitSymbol(suit),
                style: TextStyle(color: suitColor, fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Roboto'),
              ),
              const SizedBox(width: 2),
              Text(
                '$min~$max',
                style: TextStyle(color: Colors.grey[500], fontSize: 9),
              ),
              const SizedBox(width: 2),
              Text(
                '($optimal)',
                style: TextStyle(
                  color: isSelected ? Colors.teal[700] : isBest ? Colors.amber[800] : Colors.black54,
                  fontSize: 11,
                  fontWeight: isSelected || isBest ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBidSummarySuitComparison(GameController controller, AppLocalizations l10n, double s) {
    final state = controller.state;
    final snapshots = controller.bidSnapshots;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.bidSummaryEstimatedRange,
            style: TextStyle(fontSize: 13 * s, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          SizedBox(height: 6 * s),
          for (int i = 0; i < state.players.length; i++)
            _buildBidSummaryPlayerRow(state.players[i], state, snapshots, l10n, s),
        ],
      ),
    );
  }

  Widget _buildBidSummaryPlayerRow(Player player, GameState state, List<BidEvaluationSnapshot> snapshots, AppLocalizations l10n, double s) {
    final snap = snapshots.where((s) => s.playerId == player.id).lastOrNull;
    final isDeclarer = player.id == state.declarerId;

    Suit? bestSuit;
    int bestOptimal = 0;
    if (snap != null && snap.suitComparison.isNotEmpty) {
      for (final (suit, _, _, optimal) in snap.suitComparison) {
        if (optimal > bestOptimal) {
          bestOptimal = optimal;
          bestSuit = suit;
        }
      }
    }
    final selectedSuit = snap?.bestGiruda != null
        ? Suit.values.firstWhere((st) => st.name == snap!.bestGiruda)
        : null;

    return Container(
      margin: EdgeInsets.only(bottom: 4 * s),
      padding: EdgeInsets.symmetric(horizontal: 8 * s, vertical: 5 * s),
      decoration: BoxDecoration(
        color: isDeclarer ? Colors.teal[900] : Colors.black26,
        borderRadius: BorderRadius.circular(6),
        border: isDeclarer ? Border.all(color: Colors.teal, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 60 * s,
                child: Text(
                  _getLocalizedPlayerName(player, l10n),
                  style: TextStyle(
                    color: isDeclarer ? Colors.amber : Colors.white,
                    fontWeight: isDeclarer ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12 * s,
                  ),
                ),
              ),
              if (snap != null) ...[
                Text(
                  '${snap.predictedMin}~${snap.predictedMax}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 11 * s),
                ),
                SizedBox(width: 6 * s),
                Text(
                  l10n.optimalScore(snap.predictedOptimal),
                  style: TextStyle(color: Colors.greenAccent, fontSize: 11 * s),
                ),
              ],
              const Spacer(),
              if (isDeclarer)
                Icon(Icons.star, color: Colors.amber, size: 14 * s),
            ],
          ),
          if (snap != null && snap.suitComparison.isNotEmpty) ...[
            SizedBox(height: 4 * s),
            Wrap(
              spacing: 4 * s,
              runSpacing: 2 * s,
              children: snap.suitComparison.map((entry) {
                final (suit, min, max, optimal) = entry;
                final isSelected = suit == selectedSuit;
                final isBest = suit == bestSuit && bestSuit != selectedSuit;
                final suitColor = _getSuitColorOnDark(suit);

                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 5 * s, vertical: 2 * s),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.teal[800]!.withValues(alpha: 0.5)
                        : isBest
                            ? Colors.amber[800]!.withValues(alpha: 0.3)
                            : Colors.black26,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isSelected
                          ? Colors.teal[400]!
                          : isBest
                              ? Colors.amber[400]!
                              : Colors.white12,
                      width: isSelected || isBest ? 1.5 : 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getSuitSymbol(suit),
                        style: TextStyle(color: suitColor, fontSize: 11 * s, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 2 * s),
                      Text(
                        '$min~$max',
                        style: TextStyle(color: Colors.grey[500], fontSize: 9 * s),
                      ),
                      SizedBox(width: 2 * s),
                      Text(
                        '$optimal',
                        style: TextStyle(
                          color: isSelected ? Colors.teal[200] : isBest ? Colors.amber[200] : Colors.white54,
                          fontSize: 10 * s,
                          fontWeight: isSelected || isBest ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  /// 배팅 설명에 핵심 카드 정보 라인 생성
  String? _getKeyCardInfo(BidExplanation explanation, GameState state, AppLocalizations l10n) {
    if (explanation.suit == null) return null;

    final hand = state.players[explanation.playerId].hand;
    final giruda = explanation.suit!;

    // 기루다 핵심 카드 추출
    final gc = hand.where((c) => !c.isJoker && c.suit == giruda).toList();
    final keyRanks = <String>[];
    if (gc.any((c) => c.rank == Rank.ace)) keyRanks.add('A');
    if (gc.any((c) => c.rank == Rank.king)) keyRanks.add('K');
    if (gc.any((c) => c.rank == Rank.queen)) keyRanks.add('Q');
    if (gc.any((c) => c.rank == Rank.jack)) keyRanks.add('J');
    if (gc.any((c) => c.rank == Rank.ten)) keyRanks.add('10');

    if (keyRanks.isEmpty) return null;

    // 마이티: 플레이어 자신의 기루다 후보 기준으로 계산
    final mightySuit = (giruda == Suit.spade) ? Suit.diamond : Suit.spade;
    final mightyRank = Rank.ace;

    // 비기루다 초구 카드 추출 (A 우선, 없으면 K)
    final firstTrickCards = <String>[];
    for (final suit in Suit.values) {
      if (suit == giruda) continue;
      final suitCards = hand.where((c) =>
          !c.isJoker && c.suit == suit &&
          !(c.suit == mightySuit && c.rank == mightyRank)).toList(); // 마이티 제외
      final hasAce = suitCards.any((c) => c.rank == Rank.ace);
      final hasKing = suitCards.any((c) => c.rank == Rank.king);
      if (hasAce) {
        firstTrickCards.add('${_getSuitSymbol(suit)}A');
      } else if (hasKing) {
        firstTrickCards.add('${_getSuitSymbol(suit)}K');
      }
    }

    // 마이티/조커 보유 여부 (플레이어 자신의 기루다 기준)
    final hasMighty = hand.any((c) => !c.isJoker && c.suit == mightySuit && c.rank == mightyRank);
    final hasJoker = hand.any((c) => c.isJoker);

    final parts = <String>[];

    // 기루다 핵심 카드 (무늬 포함)
    parts.add(l10n.bidInfoGirudaKeys('${_getSuitSymbol(giruda)} ${keyRanks.join('·')}'));

    // 비기루다 초구 카드 (A 또는 K)
    if (firstTrickCards.isNotEmpty) parts.add(l10n.bidInfoFirstTrickAces(firstTrickCards.join('·')));

    // 마이티/조커 + 프렌드 정보
    if (hasMighty && hasJoker) {
      parts.add(l10n.bidInfoHasBoth(l10n.friendCardMighty, l10n.friendCardJoker));
    } else if (hasMighty) {
      parts.add(l10n.bidInfoHasCard(l10n.friendCardMighty));
      if (!hasJoker) parts.add(l10n.bidInfoFriend(l10n.friendCardJoker));
    } else if (hasJoker) {
      parts.add(l10n.bidInfoHasCard(l10n.friendCardJoker));
      parts.add(l10n.bidInfoFriend(l10n.friendCardMighty));
    } else {
      parts.add(l10n.bidInfoFriend(l10n.friendCardMighty));
    }

    return parts.join(', ');
  }

  /// 예상 프렌드 플레이어 찾기 (바닥패 획득 고려 폴백 체인)
  Player? _findExpectedFriend(BidExplanation explanation, GameState state) {
    if (explanation.suit == null) return null;

    final giruda = explanation.suit!;
    final declarerHand = state.players[explanation.playerId].hand;
    final mightySuit = (giruda == Suit.spade) ? Suit.diamond : Suit.spade;

    final selfHasMighty = declarerHand.any((c) =>
        !c.isJoker && c.suit == mightySuit && c.rank == Rank.ace);
    final selfHasJoker = declarerHand.any((c) => c.isJoker);

    final mightyInKitty = state.kitty.any((c) =>
        !c.isJoker && c.suit == mightySuit && c.rank == Rank.ace);
    final jokerInKitty = state.kitty.any((c) => c.isJoker);

    final effectiveHasMighty = selfHasMighty || mightyInKitty;
    final effectiveHasJoker = selfHasJoker || jokerInKitty;

    Player? friendPlayer;
    if (!effectiveHasMighty) {
      for (final p in state.players) {
        if (p.id == explanation.playerId) continue;
        if (p.hand.any((c) => !c.isJoker && c.suit == mightySuit && c.rank == Rank.ace)) {
          friendPlayer = p;
          break;
        }
      }
    }
    if (friendPlayer == null && !effectiveHasJoker && effectiveHasMighty) {
      for (final p in state.players) {
        if (p.id == explanation.playerId) continue;
        if (p.hand.any((c) => c.isJoker)) {
          friendPlayer = p;
          break;
        }
      }
    }
    if (friendPlayer == null && effectiveHasMighty && effectiveHasJoker) {
      final effectiveHasGirudaA = declarerHand.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace)
          || state.kitty.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace);
      if (!effectiveHasGirudaA) {
        for (final p in state.players) {
          if (p.id == explanation.playerId) continue;
          if (p.hand.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace)) {
            friendPlayer = p;
            break;
          }
        }
      }
      if (friendPlayer == null) {
        final effectiveHasGirudaK = declarerHand.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.king)
            || state.kitty.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.king);
        if (!effectiveHasGirudaK) {
          for (final p in state.players) {
            if (p.id == explanation.playerId) continue;
            if (p.hand.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.king)) {
              friendPlayer = p;
              break;
            }
          }
        }
      }
    }
    return friendPlayer;
  }

  /// 바닥패 + 프렌드 핸드를 고려한 조정 예상 점수 위젯
  String _getFriendExpectedText(BidExplanation explanation, AppLocalizations l10n) {
    String cardName;
    String note = '';
    switch (explanation.friendType) {
      case 'MIGHTY':
        cardName = '${l10n.friendCardMighty} (${_getSuitSymbol(explanation.friendSuit!)}A)';
        break;
      case 'JOKER':
        cardName = l10n.friendCardJoker;
        note = ' (${l10n.friendJokerNote})';
        break;
      case 'GIRUDA_ACE':
        cardName = explanation.friendSuit != null
            ? '${_getSuitSymbol(explanation.friendSuit!)}A (${l10n.giruda})'
            : 'A';
        break;
      case 'GIRUDA_KING':
        cardName = explanation.friendSuit != null
            ? '${_getSuitSymbol(explanation.friendSuit!)}K (${l10n.giruda})'
            : 'K';
        note = l10n.hasAceNote;
        break;
      case 'ACE':
        cardName = explanation.friendSuit != null ? '${_getSuitSymbol(explanation.friendSuit!)}A' : 'A';
        break;
      default:
        return '';
    }

    final holder = explanation.friendHolderName != null
        ? l10n.friendHeldBy(explanation.friendHolderName!)
        : l10n.friendInKitty;

    return '${l10n.friendExpected}: $cardName - $holder$note';
  }

  Set<String> _computePlayedCardsBefore(GameState state, int trickNumber) {
    final played = <String>{};
    for (final t in state.tricks) {
      if (t.trickNumber >= trickNumber) break;
      for (final c in t.cards) {
        if (c.isJoker) {
          played.add('joker');
        } else if (c.suit != null) {
          played.add('${c.suit!.index}-${c.rankValue}');
        }
      }
    }
    return played;
  }

  String _getRankName(Rank rank) {
    switch (rank) {
      case Rank.ace: return 'A';
      case Rank.king: return 'K';
      case Rank.queen: return 'Q';
      case Rank.jack: return 'J';
      case Rank.ten: return '10';
      case Rank.nine: return '9';
      case Rank.eight: return '8';
      case Rank.seven: return '7';
      case Rank.six: return '6';
      case Rank.five: return '5';
      case Rank.four: return '4';
      case Rank.three: return '3';
      case Rank.two: return '2';
    }
  }

  String _getPassReason(BidExplanation explanation, GameState state, AppLocalizations l10n) {
    switch (explanation.passReason) {
      case 'LOW_POINTS':
        return l10n.passReasonLowPoints(explanation.optimalPoints);
      case 'OUTBID':
        final needed = state.currentBid != null ? state.currentBid!.tricks + 1 : 13;
        return l10n.passReasonOutbid(explanation.optimalPoints, needed);
      // legacy pass reasons (deprecated)
      case 'NO_SUIT':
        return l10n.passReasonNoSuit;
      case 'NO_HIGH_CARD':
        return l10n.passReasonNoHighCard;
      case 'WEAK_HAND':
        final needed = state.currentBid != null ? state.currentBid!.tricks + 1 : 13;
        return l10n.passReasonWeakHand(explanation.optimalPoints, needed);
      case 'POWER_WEAK':
        return l10n.passReasonPowerWeak;
      default:
        return '';
    }
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
    final isHumanTurn = !widget.isAutoPlay && state.currentBidder == 0 && !controller.isProcessing;

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
    final compact = screenHeight < 700;
    final maxBiddingHeight = compact ? screenHeight * 0.52 : screenHeight * 0.45;

    return Container(
      constraints: BoxConstraints(maxHeight: maxBiddingHeight),
      padding: EdgeInsets.all(compact ? 8 : 12),
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
          SizedBox(height: compact ? 4 : 8),
          if (isHumanTurn) ...[
            // 트릭 수 선택
            Text(
              l10n.tricks,
              style: TextStyle(color: Colors.white70, fontSize: compact ? 10 : 11),
            ),
            SizedBox(height: compact ? 2 : 4),
            Wrap(
              spacing: compact ? 2 : 4,
              runSpacing: compact ? 2 : 4,
              children: [
                for (int i = 13; i <= 20; i++)
                  _buildBidChip(i, state, l10n, compact: compact),
              ],
            ),
            SizedBox(height: compact ? 4 : 8),
            // 기루다 선택
            Text(
              l10n.giruda,
              style: TextStyle(color: Colors.white70, fontSize: compact ? 10 : 11),
            ),
            SizedBox(height: compact ? 2 : 4),
            Wrap(
              spacing: compact ? 4 : 6,
              runSpacing: compact ? 2 : 4,
              children: [
                _buildSuitChip(Suit.spade, '♠', l10n.spadeName, compact: compact),
                _buildSuitChip(Suit.diamond, '♦', l10n.diamondName, compact: compact),
                _buildSuitChip(Suit.heart, '♥', l10n.heartName, compact: compact),
                _buildSuitChip(Suit.club, '♣', l10n.clubName, compact: compact),
                _buildSuitChip(null, '✕', l10n.noGiruda, compact: compact),
              ],
            ),
            SizedBox(height: compact ? 6 : 10),
            // 버튼들
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () => controller.humanPass(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24, vertical: compact ? 4 : 8),
                  ),
                  child: Text(l10n.pass, style: const TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _canBid(state) ? () => _submitBid(controller) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24, vertical: compact ? 4 : 8),
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
              SizedBox(height: compact ? 6 : 12),
              ElevatedButton(
                onPressed: () => _showDealMissDialog(controller),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24, vertical: compact ? 4 : 8),
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

  Widget _buildBidChip(int amount, GameState state, AppLocalizations l10n, {bool compact = false}) {
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
          padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 12, vertical: compact ? 5 : 8),
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
              fontSize: compact ? 14 : 16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              decoration: isEnabled ? null : TextDecoration.lineThrough,
              decorationColor: Colors.grey[500],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuitChip(Suit? suit, String symbol, String name, {bool compact = false}) {
    // 사용자가 직접 선택했거나 AI가 배팅을 추천한 경우에만 선택 표시
    final isSelected = _suitManuallySelected && _selectedBidSuit == suit;
    final isRed = suit == Suit.diamond || suit == Suit.heart;

    Color symbolColor;
    if (isRed) {
      symbolColor = Colors.red[700]!;
    } else if (suit == Suit.spade || suit == Suit.club) {
      symbolColor = Colors.black;  // 스페이드, 클로버는 검정
    } else {
      symbolColor = isSelected ? Colors.black : Colors.white;  // 노기루다
    }

    return GestureDetector(
      onTap: () => setState(() {
        _selectedBidSuit = suit;
        _suitManuallySelected = true;
      }),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 5 : 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.white54,
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
                  fontSize: compact ? 16 : 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Roboto',
                ),
              ),
              SizedBox(width: compact ? 2 : 4),
            ],
            Text(
              name,
              style: TextStyle(
                color: isSelected ? Colors.black : Colors.white,
                fontSize: compact ? 11 : 12,
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
    final isCurrentBidder = !widget.isAutoPlay && state.currentBidder == 0;

    // 세로 모드 확인
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final screenWidth = MediaQuery.of(context).size.width;

    // 세로 모드에서 카드 크기와 배치 계산
    final screenHeight = MediaQuery.of(context).size.height;
    final compact = screenHeight < 700;
    final cardWidth = isPortrait ? (screenWidth - 32) / 6 - 4 : 55.0;
    final cardHeight = cardWidth * (compact ? 1.2 : 1.4);

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
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: compact ? 13 : 14,
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
          SizedBox(height: compact ? 3 : 6),
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

    // auto-play: 키티 요약 화면
    if (widget.isAutoPlay && controller.showKittySummary && controller.kittyExplanation != null) {
      return _buildKittySummaryScreen(controller);
    }

    if (widget.isAutoPlay || controller.state.declarerId != 0) {
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
          onConfirm: (discards, newGiruda, isFull) {
            Navigator.pop(context);
            _kittyDialogShown = false;
            controller.humanSelectKitty(discards, newGiruda, isFull: isFull);
          },
        ),
      ),
    );
  }

  bool _friendDialogShown = false;

  Widget _buildFriendScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;

    // auto-play: 프렌드 요약 화면
    if (widget.isAutoPlay && controller.showFriendSummary && controller.friendExplanation != null) {
      return _buildFriendSummaryScreen(controller);
    }

    if (widget.isAutoPlay || controller.state.declarerId != 0) {
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

    // 트릭 완료 대기 중이면 타이머 시작 (auto-play 시에는 controller가 자동 진행)
    if (controller.waitingForTrickConfirm && !_timerRunning && !widget.isAutoPlay) {
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
        if (state.phase == GamePhase.gameEnd && !_showGameResult && !_showTrickDetails)
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
                            _showTrickDetails = false;
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
                            _showTrickDetails = false;
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
                          if (_buildCardEventBadge(trick.cards[i], i, trick, controller.state) != null)
                            _buildCardEventBadge(trick.cards[i], i, trick, controller.state)!,
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
                // 트릭 이벤트 설명
                () {
                  final playedCards = _computePlayedCardsBefore(controller.state, trick.trickNumber);
                  final description = _describeTrick(trick, controller.state, l10n, playedCards, isAutoPlay: widget.isAutoPlay);
                  if (description != null)
                    return Padding(
                      padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                      child: Text(
                        description,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    );
                  return const SizedBox.shrink();
                }(),
                const SizedBox(height: 20),
                if (widget.isAutoPlay)
                  // auto-play: 자동 진행 표시
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(
                      color: Colors.amber,
                      strokeWidth: 3,
                    ),
                  )
                else
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

    // 노프렌드 체크를 먼저 해야 함 (노프렌드 시에도 friendRevealed=true가 됨)
    if (state.friendDeclaration != null && state.friendDeclaration!.isNoFriend) {
      friendValue = l10n.friendNone;
    } else if (state.friendRevealed && state.friend != null) {
      // 프렌드가 공개됨
      friendValue = _getLocalizedPlayerName(state.friend!, l10n);
    } else if (state.friendDeclaration != null) {
      // 프렌드 선언 조건 표시
      final decl = state.friendDeclaration!;
      if (decl.isFirstTrickWinner) {
        friendValue = l10n.firstTrick;
      } else if (decl.trickNumber != null) {
        friendValue = l10n.nthTrickShort(decl.trickNumber!);
      } else if (decl.card != null) {
        friendValue = _getCardString(decl.card!);
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
          ),
          child: hasFriendCard
              ? _buildColoredCardTextForInfo(decl.card!)
              : Text(
                  friendValue,
                  style: TextStyle(
                    color: state.friendRevealed ? Colors.blue.shade800 : Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
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
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getSuitSymbol(giruda),
                      style: TextStyle(
                        color: _getSuitColorForInfo(giruda),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    Text(
                      ' ($playedCount/13)',
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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

  // 어두운 배경용 무늬 색상 (스페이드/클로버는 흰색, 하트/다이아는 빨강)
  Color _getSuitColorOnDark(Suit suit) {
    switch (suit) {
      case Suit.spade:
      case Suit.club:
        return Colors.white;
      case Suit.heart:
      case Suit.diamond:
        return Colors.red[300]!;
    }
  }

  // 무늬 기호가 포함된 텍스트를 흰색 배경 미니 카드로 렌더링 (어두운 배경용)
  Widget _buildSuitColoredText(String text, TextStyle baseStyle) {
    final suitPattern = RegExp('[♠♦♥♣]');
    final spans = <InlineSpan>[];
    int lastEnd = 0;
    final cardSize = (baseStyle.fontSize ?? 10) * 1.2;
    for (final match in suitPattern.allMatches(text)) {
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      final symbol = match.group(0)!;
      final color = (symbol == '♥' || symbol == '♦') ? Colors.red : Colors.black;
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Container(
          width: cardSize,
          height: cardSize,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(2),
          ),
          child: Center(
            child: Text(
              symbol,
              style: TextStyle(
                fontSize: cardSize * 0.8,
                color: color,
                fontFamily: 'Roboto',
                height: 1.0,
              ),
            ),
          ),
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }
    return RichText(text: TextSpan(style: baseStyle, children: spans));
  }

  // 정보 표시용 무늬 색상 (스페이드/클로버는 검정, 하트/다이아는 빨강)
  Color _getSuitColorForInfo(Suit suit) {
    switch (suit) {
      case Suit.spade:
      case Suit.club:
        return Colors.black;
      case Suit.heart:
      case Suit.diamond:
        return Colors.red;
    }
  }

  // 정보 표시용 무늬 색상이 적용된 카드 텍스트 위젯 (흰색 배경용 - 스페이드/클로버는 검정)
  Widget _buildColoredCardTextForInfo(PlayingCard card) {
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
            color: _getSuitColorForInfo(suit),
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto',
          ),
        ),
        Text(
          rank,
          style: TextStyle(
            color: _getSuitColorForInfo(suit),
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
    final isFriend = player.isFriend && (state.friendRevealed || widget.isAutoPlay);
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

    // auto-play 시 핸드 카드 정렬
    final handCards = List<PlayingCard>.from(player.hand);
    handCards.sort((a, b) {
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
        // auto-play: 핸드 카드 공개
        if (widget.isAutoPlay && handCards.isNotEmpty)
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
              children: handCards.map((card) => _buildTinyCardFixed(card, state, 24.0)).toList(),
            ),
          ),
        // 획득한 점수 카드 표시 (고정 크기)
        if (pointCards.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.5), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.wonCards,
                  style: const TextStyle(color: Colors.amber, fontSize: 8, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 1),
                Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  alignment: WrapAlignment.center,
                  children: pointCards.map((card) => _buildTinyCardFixed(card, state, 28.0)).toList(),
                ),
              ],
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
          gradient: const LinearGradient(colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)]),
          borderRadius: BorderRadius.circular(3),
        ),
        child: const Text(
          '★JK',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.yellowAccent, fontFamily: 'Roboto'),
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
          fontFamily: 'Roboto',  // 이모지 폰트 대신 텍스트 폰트 사용
        ),
      ),
    );
  }

  // 고정 너비의 작은 카드 (3열 레이아웃용)
  Widget _buildTinyCardFixed(PlayingCard card, GameState state, double width, {bool dimmed = false}) {
    final isMighty = card == state.mighty;

    Widget cardWidget;
    if (card.isJoker) {
      cardWidget = Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
        decoration: BoxDecoration(
          gradient: dimmed
              ? LinearGradient(colors: [Colors.grey[700]!, Colors.grey[600]!])
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7B1FA2), Color(0xFFAB47BC)],
                ),
          borderRadius: BorderRadius.circular(3),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '★JK',
            style: TextStyle(fontSize: width * 0.43, fontWeight: FontWeight.bold, color: dimmed ? Colors.grey[400] : Colors.yellowAccent, fontFamily: 'Roboto'),
          ),
        ),
      );
    } else {
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

      final effectiveWidth = rank == '10' ? width * 1.25 : width;
      cardWidget = Container(
        width: effectiveWidth,
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
        decoration: BoxDecoration(
          color: dimmed ? Colors.grey[400] : (isMighty ? Colors.amber[700] : Colors.white),
          borderRadius: BorderRadius.circular(3),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$suitSymbol$rank',
            style: TextStyle(
              color: dimmed ? Colors.grey[600] : (isRed ? Colors.red[700] : Colors.black),
              fontSize: 12,
              fontWeight: isMighty ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'Roboto',  // 이모지 폰트 대신 텍스트 폰트 사용
            ),
          ),
        ),
      );
    }

    if (dimmed) {
      return Opacity(opacity: 0.45, child: cardWidget);
    }
    return cardWidget;
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
                      if (_buildCardEventBadge(trick.cards[i], i, trick, state) != null)
                        _buildCardEventBadge(trick.cards[i], i, trick, state)!,
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildCardEventBadge(PlayingCard card, int cardIndex, Trick trick, GameState state) {
    final giruda = state.giruda;
    final mighty = state.mighty;

    // 마이티 (선공/후속 모두)
    if (!card.isJoker && card.suit == mighty.suit && card.rank == mighty.rank) {
      return _eventBadge('마이티!', Colors.amber);
    }
    // 조커 (비선공만 - 선공은 jokerLeadSuit 뱃지 있음)
    if (card.isJoker && cardIndex > 0) {
      return _eventBadge('조커!', Colors.purple);
    }
    // 기루다 컷 (비선공, 비조커, 기루다 카드, 리드가 비기루다)
    if (cardIndex > 0 && !card.isJoker && giruda != null && card.suit == giruda && trick.leadSuit != giruda) {
      return _eventBadge('컷!', Colors.red);
    }
    // 프렌드 공개
    if (state.friendRevealed && state.friendId != null && state.friendId != state.declarerId) {
      final friendDecl = state.friendDeclaration?.card;
      if (friendDecl != null) {
        final isMatch = (friendDecl.isJoker && card.isJoker) ||
            (!friendDecl.isJoker && !card.isJoker && friendDecl.suit == card.suit && friendDecl.rank == card.rank);
        final playerId = trick.playerOrder[cardIndex];
        if (isMatch && playerId == state.friendId) {
          return _eventBadge('프렌드!', Colors.blue);
        }
      }
    }
    return null;
  }

  Widget _eventBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      margin: const EdgeInsets.only(top: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
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

  // 무늬 이름 로컬라이즈
  String _getSuitNameLocalized(Suit suit, AppLocalizations l10n) {
    switch (suit) {
      case Suit.spade:
        return l10n.suitSpade;
      case Suit.diamond:
        return l10n.suitDiamond;
      case Suit.heart:
        return l10n.suitHeart;
      case Suit.club:
        return l10n.suitClub;
    }
  }

  // 카드 규칙 코드를 로컬라이즈된 메시지로 변환
  String _getLocalizedCannotPlayReason(String code, AppLocalizations l10n) {
    if (code == 'firstTrickDeclarerGiruda') {
      return l10n.cannotPlayFirstTrickDeclarerGiruda;
    } else if (code == 'firstTrickJoker') {
      return l10n.cannotPlayFirstTrickJoker;
    } else if (code == 'lastTrickJoker') {
      return l10n.cannotPlayLastTrickJoker;
    } else if (code == 'lastTrickJokerHasLeadSuit') {
      return l10n.cannotPlayLastTrickJokerHasLeadSuit;
    } else if (code == 'jokerCall') {
      return l10n.mustPlayJokerCall;
    } else if (code.startsWith('followSuit:')) {
      final suitIndex = int.tryParse(code.split(':')[1]) ?? 0;
      final suitName = _getSuitNameLocalized(Suit.values[suitIndex], l10n);
      return l10n.mustFollowSuit(suitName);
    }
    return code;
  }

  void _onCardTap(PlayingCard card, GameController controller) {
    if (widget.isAutoPlay) return;
    if (controller.state.phase != GamePhase.playing) return;
    if (!controller.isHumanTurn) return;
    if (!controller.canPlayCard(card)) {
      // 낼 수 없는 이유를 토스트로 표시
      final reasonCode = controller.getCannotPlayReason(card);
      if (reasonCode != null) {
        final l10n = AppLocalizations.of(context)!;
        final localizedReason = _getLocalizedCannotPlayReason(reasonCode, l10n);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizedReason),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

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

  Widget _buildBaseScoreExplanation(GameState state, {bool compact = false}) {
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
      padding: EdgeInsets.all(compact ? 8 : 12),
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
              fontSize: compact ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: declarerWon ? Colors.blue[700] : Colors.red[700],
            ),
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            formula,
            style: TextStyle(fontSize: compact ? 10 : 12, color: Colors.grey[600]),
          ),
          Text(
            calculation,
            style: TextStyle(fontSize: compact ? 11 : 13, fontWeight: FontWeight.w500),
          ),
          if (multipliers.isNotEmpty) ...[
            SizedBox(height: compact ? 2 : 4),
            Text(
              '${l10n.multiplierLabel}: ${multipliers.join(', ')}',
              style: TextStyle(fontSize: compact ? 10 : 12, color: Colors.blue[700]),
            ),
            Text(
              '$baseScore × $specialMultiplier = $finalBaseScore',
              style: TextStyle(fontSize: compact ? 10 : 12, color: Colors.blue[700]),
            ),
          ],
          SizedBox(height: compact ? 4 : 8),
          Text(
            'Base Score = $finalBaseScore',
            style: TextStyle(
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: compact ? 4 : 8),
          Text(
            isNoFriend ? l10n.scoreMultipliersNoFriend : l10n.scoreMultipliers,
            style: TextStyle(fontSize: compact ? 10 : 11, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildGameEndScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;

    // 통계 기록 (한 번만, auto-play 시 스킵)
    if (!_statsRecorded && state.declarerId != null && !widget.isAutoPlay) {
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
    final compact = screenHeight < 700;
    final maxDialogHeight = screenHeight * (compact ? 0.92 : 0.85);

    return Center(
      child: Container(
        constraints: BoxConstraints(maxHeight: maxDialogHeight),
        padding: EdgeInsets.all(compact ? 12 : 20),
        margin: EdgeInsets.all(compact ? 8 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              () {
                final isPlayerWinner = widget.isAutoPlay ? state.declarerWon : state.getPlayerScore(state.players[0].id) >= 0;
                return Text(
                  widget.isAutoPlay
                      ? (isPlayerWinner ? l10n.declarerTeamWins : l10n.defenderTeamWins)
                      : (isPlayerWinner ? l10n.victory : l10n.defeat),
                  style: TextStyle(
                    fontSize: compact ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: isPlayerWinner ? Colors.green : Colors.red,
                  ),
                );
              }(),
            SizedBox(height: compact ? 2 : 4),
            Text(
              '${state.declarerTeamPoints == 20 ? '${l10n.declarerTeam}: ${l10n.fullPoints}' : l10n.declarerTeamPoints(state.declarerTeamPoints)}  /  ${l10n.targetPoints(state.currentBid?.tricks ?? 0)}',
              style: TextStyle(fontSize: compact ? 13 : 15, color: Colors.grey[700]),
            ),
            SizedBox(height: compact ? 6 : 12),
            if (widget.isAutoPlay)
              _buildTrickDetailsTable(state, compact: compact, l10n: l10n)
            else ...[
              // baseScore 계산 설명
              _buildBaseScoreExplanation(state, compact: compact),
              SizedBox(height: compact ? 8 : 16),
              Text(
                l10n.score,
                style: TextStyle(fontSize: compact ? 16 : 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: compact ? 4 : 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < state.players.length; i++)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12, vertical: compact ? 5 : 8),
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
                                padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 4, vertical: compact ? 1 : 2),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n.declarer,
                                  style: TextStyle(fontSize: compact ? 9 : 10, color: Colors.red[700], fontWeight: FontWeight.bold),
                                ),
                              )
                            else if (state.players[i].isFriend)
                              Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 4, vertical: compact ? 1 : 2),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  l10n.friend,
                                  style: TextStyle(fontSize: compact ? 9 : 10, color: Colors.blue[700], fontWeight: FontWeight.bold),
                                ),
                              ),
                            // 이름
                            Expanded(
                              child: Text(
                                _getLocalizedPlayerName(state.players[i], l10n),
                                style: TextStyle(fontSize: compact ? 12 : 14),
                              ),
                            ),
                            // 점수
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: compact ? 7 : 10, vertical: compact ? 2 : 4),
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
                                  fontSize: compact ? 12 : 14,
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
            ],
            SizedBox(height: compact ? 10 : 20),
            if (widget.isAutoPlay)
              // auto-play: 다음 게임 버튼
              Padding(
                padding: EdgeInsets.all(compact ? 4 : 8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _statsRecorded = false;
                      _showGameResult = true;
                    });
                    controller.startNextAutoGame();
                  },
                  icon: Icon(Icons.skip_next, color: Colors.white, size: compact ? 18 : 24),
                  label: Text(
                    l10n.nextGameAuto,
                    style: TextStyle(fontSize: compact ? 14 : 16, color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 24, vertical: compact ? 8 : 12),
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showGameResult = false;
                        _showTrickDetails = true;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20, vertical: compact ? 7 : 10),
                    ),
                    child: Text(
                      l10n.trickDetails,
                      style: TextStyle(fontSize: compact ? 14 : 16, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _statsRecorded = false;
                        _showGameResult = true;
                        _showTrickDetails = false;
                        _showHint = false;
                      });
                      controller.reset();
                      controller.startNewGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20, vertical: compact ? 7 : 10),
                    ),
                    child: Text(
                      l10n.newGame,
                      style: TextStyle(fontSize: compact ? 14 : 16, color: Colors.black),
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

  /// describeTrick: 서버 GameDetailPage.tsx의 로직을 Dart로 포팅
  String? _describeTrick(Trick trick, GameState state, AppLocalizations l10n, Set<String> playedCards, {bool isAutoPlay = false}) {
    if (trick.cards.isEmpty) return null;

    final giruda = state.giruda;
    final leadId = trick.leadPlayerId;
    final leadIdx = trick.playerOrder.indexOf(leadId);
    if (leadIdx < 0 || leadIdx >= trick.cards.length) return null;
    final leadCard = trick.cards[leadIdx];

    final mighty = state.mighty;
    bool isMighty(PlayingCard c) => !c.isJoker && c.suit == mighty.suit && c.rank == mighty.rank;
    bool isGiruda(PlayingCard c) => !c.isJoker && giruda != null && c.suit == giruda;
    bool isAttack(int id) => id == state.declarerId || id == state.friendId;

    // 트릭 10: 마지막 트릭 + 점수 + 승패 확정
    if (trick.trickNumber == 10) {
      final lastParts = <String>[];
      final pointCount = trick.cards.where((c) => !c.isJoker && c.isPointCard).length;

      // 게임 결과 선계산
      int attackPoints = 0;
      for (final t in state.tricks) {
        if (t.winnerId != null && isAttack(t.winnerId!)) {
          attackPoints += t.cards.where((c) => !c.isJoker && c.isPointCard).length;
        }
      }
      final bidTricks = state.currentBid?.tricks ?? 13;
      final attackWins = attackPoints >= bidTricks;

      // 수비 최상위 카드 보호 승리 but 방어 실패 판정
      bool defenseTopProtect = false;
      if (trick.winnerId != null && !isAttack(trick.winnerId!) && pointCount > 0 && attackWins) {
        final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
        if (winIdx >= 0 && winIdx < trick.cards.length) {
          final winCard = trick.cards[winIdx];
          if (!winCard.isJoker && winCard.suit != null && !isMighty(winCard)) {
            bool isWinTop = winCard.rankValue >= 14;
            if (!isWinTop) {
              isWinTop = true;
              for (int r = 14; r > winCard.rankValue; r--) {
                if (winCard.suit == mighty.suit && r == mighty.rankValue) continue;
                if (!playedCards.contains('${winCard.suit!.index}-$r')) { isWinTop = false; break; }
              }
            }
            if (isWinTop) defenseTopProtect = true;
          }
        }
      }

      if (defenseTopProtect) {
        lastParts.add(l10n.trickEventLastDefenseTopProtectFail(pointCount));
      } else {
        // 승리 카드 유형에 따른 마지막 트릭 설명
        String? lastLabel;
        bool winDescribed = false;
        if (trick.winnerId != null) {
          final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
          if (winIdx >= 0 && winIdx < trick.cards.length) {
            final winCard = trick.cards[winIdx];
            if (isMighty(winCard)) {
              lastLabel = l10n.trickEventLastTrickMighty;
              winDescribed = true;
            } else if (isGiruda(winCard)) {
              lastLabel = l10n.trickEventLastTrickGiruda;
              winDescribed = true;
            } else if (!winCard.isJoker && winCard.suit != null && isAttack(trick.winnerId!)) {
              bool isWinTop = winCard.rankValue >= 14;
              if (!isWinTop) {
                isWinTop = true;
                for (int r = 14; r > winCard.rankValue; r--) {
                  if (winCard.suit == mighty.suit && r == mighty.rankValue) continue;
                  if (!playedCards.contains('${winCard.suit!.index}-$r')) { isWinTop = false; break; }
                }
              }
              if (isWinTop) {
                lastLabel = l10n.trickEventLastAttackTopCardWin;
                winDescribed = true;
              }
            }
          }
        }
        // "마지막 카드"는 최상위 카드가 아닐 때만 표시
        if (lastLabel == null && !leadCard.isJoker && leadCard.suit != null) {
          bool isLeadTop = leadCard.rankValue >= 14;
          if (!isLeadTop && leadCard.suit != giruda) {
            isLeadTop = true;
            for (int r = 14; r > leadCard.rankValue; r--) {
              if (leadCard.suit == mighty.suit && r == mighty.rankValue) continue;
              if (!playedCards.contains('${leadCard.suit!.index}-$r')) { isLeadTop = false; break; }
            }
          }
          if (!isLeadTop) lastLabel = l10n.trickEventLastCard;
        }
        if (lastLabel != null) lastParts.add(lastLabel);

        // 점수
        if (!winDescribed && trick.winnerId != null && pointCount > 0) {
          if (!isAttack(trick.winnerId!)) {
            lastParts.add(l10n.trickEventLastCardDefenseWin(pointCount));
          } else {
            lastParts.add(l10n.trickEventLastCardAttackWin(pointCount));
          }
        }
      }

      // 총평 - 이벤트 기반
      final attackTrickWins = state.tricks.where((t) => t.winnerId != null && isAttack(t.winnerId!)).length;
      final defenseTrickWins = 10 - attackTrickWins;
      if (attackTrickWins == 10) {
        lastParts.add(l10n.trickEventSummaryRun(attackPoints, bidTricks));
      } else if (defenseTrickWins == 10) {
        lastParts.add(l10n.trickEventSummaryBackRun(bidTricks));
      } else {
        final keyEvents = <String>[];

        // 1. 조커 활용/반격
        for (final t in state.tricks) {
          for (int i = 0; i < t.cards.length && i < t.playerOrder.length; i++) {
            if (t.cards[i].isJoker && t.winnerId == t.playerOrder[i]) {
              if (isAttack(t.playerOrder[i]) && attackWins) {
                keyEvents.add(l10n.summaryJokerUse);
              } else if (!isAttack(t.playerOrder[i]) && !attackWins) {
                keyEvents.add(l10n.summaryJokerCounter);
              }
              break;
            }
          }
          if (keyEvents.isNotEmpty) break;
        }

        // 2. 수비 물패 공략 (공격 비기루다 비최상위 선공 → 수비 승리)
        if (!attackWins) {
          int defWasteWins = 0;
          for (final t in state.tricks) {
            if (t.winnerId == null) continue;
            final tLead = t.leadPlayerId;
            if (!isAttack(tLead) || isAttack(t.winnerId!)) continue;
            final tLeadIdx = t.playerOrder.indexOf(tLead);
            if (tLeadIdx < 0 || tLeadIdx >= t.cards.length) continue;
            final tLeadCard = t.cards[tLeadIdx];
            if (!tLeadCard.isJoker && !isMighty(tLeadCard) && tLeadCard.suit != giruda) {
              defWasteWins++;
            }
          }
          if (defWasteWins >= 2) keyEvents.add(l10n.summaryWasteExploit);
        }

        // 3. 기루다 지배 (공격 기루다 승리 3회 이상)
        if (attackWins && giruda != null) {
          int girudaWins = 0;
          for (final t in state.tricks) {
            if (t.winnerId == null || !isAttack(t.winnerId!)) continue;
            final winIdx = t.playerOrder.indexOf(t.winnerId!);
            if (winIdx >= 0 && winIdx < t.cards.length && isGiruda(t.cards[winIdx])) girudaWins++;
          }
          if (girudaWins >= 3) keyEvents.add(l10n.summaryTrumpDominate);
        }

        // 4. 프렌드 활약 (2승 이상)
        if (attackWins && state.friendId != null && state.friendId != state.declarerId) {
          final friendWins = state.tricks.where((t) => t.winnerId == state.friendId).length;
          if (friendWins >= 2) {
            keyEvents.add(l10n.summaryFriendContrib);
          }
        }

        // 5. 후반 점수 방어 (7-10트릭 중 수비 3승 이상)
        if (!attackWins) {
          final lateDefWins = state.tricks.where((t) =>
              t.trickNumber >= 7 && t.winnerId != null && !isAttack(t.winnerId!)).length;
          if (lateDefWins >= 3) keyEvents.add(l10n.summaryLateDefense);
        }

        // 6. 수비 기루다 컷 (2회 이상)
        if (!attackWins && giruda != null) {
          int defCutCount = 0;
          for (final t in state.tricks) {
            if (t.winnerId == null || isAttack(t.winnerId!)) continue;
            final winIdx = t.playerOrder.indexOf(t.winnerId!);
            if (winIdx >= 0 && winIdx < t.cards.length) {
              final wc = t.cards[winIdx];
              if (isGiruda(wc) && t.leadSuit != giruda) defCutCount++;
            }
          }
          if (defCutCount >= 2) keyEvents.add(l10n.summaryDefenseCut);
        }

        // 7. 마이티 활용 (마이티 트릭에서 공격 3점 이상 획득)
        if (attackWins) {
          for (final t in state.tricks) {
            if (t.winnerId == null || !isAttack(t.winnerId!)) continue;
            final hasMighty = t.cards.any((c) => isMighty(c));
            if (hasMighty) {
              final pts = t.cards.where((c) => !c.isJoker && c.isPointCard).length;
              if (pts >= 3) { keyEvents.add(l10n.summaryMightyImpact); break; }
            }
          }
        }

        // 8. 조커/마이티 보유 추가 점수 실패 (최소 점수 달성 시)
        if (attackWins && attackPoints == bidTricks) {
          bool attackPlayedJoker = false;
          bool attackPlayedMighty = false;
          for (final t in state.tricks) {
            for (int i = 0; i < t.cards.length && i < t.playerOrder.length; i++) {
              if (isAttack(t.playerOrder[i])) {
                if (t.cards[i].isJoker) attackPlayedJoker = true;
                if (isMighty(t.cards[i])) attackPlayedMighty = true;
              }
            }
          }
          if (attackPlayedJoker && attackPlayedMighty) {
            keyEvents.clear();
            keyEvents.add(l10n.summaryJokerMightyNoExtra);
          }
        }

        // 결과 라벨
        final result = attackWins && attackPoints >= bidTricks + 5
            ? l10n.summaryResultBigWin
            : attackWins && attackPoints == bidTricks
                ? l10n.summaryResultMinGoal
                : attackWins
                    ? l10n.summaryResultWin
                    : attackPoints >= bidTricks - 3
                        ? l10n.summaryResultNarrowLoss
                        : l10n.summaryResultBigLoss;

        if (keyEvents.isNotEmpty) {
          final events = keyEvents.length >= 2
              ? '${keyEvents[0]}${l10n.summaryAnd}${keyEvents[1]}'
              : keyEvents[0];
          lastParts.add(l10n.summaryNarrative(events, result));
        } else {
          lastParts.add(l10n.summaryFallback(attackTrickWins, defenseTrickWins, attackPoints, bidTricks, result));
        }
      }

      return lastParts.join(' / ');
    }
    bool isTeammate(int winnerId) => isAttack(leadId) == isAttack(winnerId);
    final hasMightyInTrick = trick.cards.any((c) => isMighty(c));
    final isDeclarerLead = leadId == state.declarerId;

    // auto-play 전략 비교용: K가 이 트릭에서 나왔는지, 프렌드 합류 여부
    bool girudaKInTrick = giruda != null && trick.cards.any((c) =>
        !c.isJoker && c.suit == giruda && c.rank == Rank.king);

    // 이번 트릭 이후 남은 기루다 최상위 카드 계산 (무늬 포함)
    String? topRemainingGirudaStr;
    if (isAutoPlay && giruda != null) {
      const suitSym = {Suit.spade: '\u2660', Suit.diamond: '\u2666', Suit.heart: '\u2665', Suit.club: '\u2663'};
      const rankSym = {14: 'A', 13: 'K', 12: 'Q', 11: 'J', 10: '10', 9: '9', 8: '8', 7: '7', 6: '6', 5: '5', 4: '4', 3: '3', 2: '2'};
      final currentTrickGiruda = trick.cards
          .where((c) => !c.isJoker && c.suit == giruda)
          .map((c) => c.rankValue)
          .toSet();
      for (int r = 14; r >= 2; r--) {
        if (giruda == mighty.suit && r == mighty.rankValue) continue;
        if (playedCards.contains('${giruda.index}-$r')) continue;
        if (currentTrickGiruda.contains(r)) continue;
        topRemainingGirudaStr = '${suitSym[giruda]}${rankSym[r]}';
        break;
      }
    }
    bool friendAlreadyRevealed = false;
    final friendCard = state.friendDeclaration?.card;
    if (friendCard != null) {
      if (friendCard.isMightyWith(giruda)) {
        friendAlreadyRevealed = mighty.suit != null && playedCards.contains('${mighty.suit!.index}-${mighty.rankValue}');
      } else if (friendCard.isJoker) {
        friendAlreadyRevealed = playedCards.any((s) => s == 'joker');
      } else if (friendCard.suit != null) {
        friendAlreadyRevealed = playedCards.contains('${friendCard.suit!.index}-${friendCard.rankValue}');
      }
    }

    bool isTopOfSuit(Suit suit, int rankValue) {
      final mightySuit = mighty.suit;
      final mightyRankValue = mighty.rankValue;
      for (int r = 14; r > rankValue; r--) {
        if (suit == mightySuit && r == mightyRankValue) continue;
        if (!playedCards.contains('${suit.index}-$r')) return false;
      }
      return true;
    }

    // 리드 설명에 포함 시 outcome 중복 방지용 플래그
    bool girudaCutDescribed = false;
    bool mightyExhaustDescribed = false;
    bool isAttackGirudaCut() {
      if (trick.leadSuit == giruda || giruda == null || trick.winnerId == null) return false;
      final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
      if (winIdx < 0 || winIdx >= trick.cards.length) return false;
      return isGiruda(trick.cards[winIdx]) && trick.winnerId != leadId && isAttack(trick.winnerId!);
    }
    bool isDefenseGirudaCut() {
      if (trick.leadSuit == giruda || giruda == null || trick.winnerId == null) return false;
      final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
      if (winIdx < 0 || winIdx >= trick.cards.length) return false;
      return isGiruda(trick.cards[winIdx]) && trick.winnerId != leadId && !isAttack(trick.winnerId!);
    }

    final parts = <String>[];

    // Lead card description
    bool leadDescribed = false;
    if (trick.leadIntent != null) {
      final leadDesc = _describeLeadFromIntent(trick, state, l10n);
      if (leadDesc != null) {
        parts.add(leadDesc);
        leadDescribed = true;
        if (trick.leadIntent == LeadIntent.defenseMightyExhaust ||
            trick.leadIntent == LeadIntent.midGirudaMightyBait) {
          mightyExhaustDescribed = true;
        }
      }
    }
    if (!leadDescribed) {
    if (leadCard.isJoker) {
      const suitSymbols = {Suit.spade: '\u2660', Suit.diamond: '\u2666', Suit.heart: '\u2665', Suit.club: '\u2663'};
      final declaredSuit = trick.leadSuit;
      final suitStr = declaredSuit != null ? suitSymbols[declaredSuit] ?? '' : '';
      if (isAutoPlay && isDeclarerLead && friendAlreadyRevealed) {
        // 전략: 프렌드 합류 후 조커 사용
        String jokerDesc = suitStr.isNotEmpty
            ? l10n.trickEventJokerAfterFriend(suitStr)
            : l10n.trickEventJokerAfterFriendGeneral;
        parts.add(jokerDesc);
      } else {
        String jokerDesc = suitStr.isNotEmpty
            ? l10n.trickEventJokerLeadSuit(suitStr)
            : l10n.trickEventJokerLead;
        if (declaredSuit != null && declaredSuit == giruda) {
          jokerDesc += ' / ${l10n.trickEventJokerGirudaExhaust}';
        }
        parts.add(jokerDesc);
      }
    } else if (isMighty(leadCard)) {
      parts.add(l10n.trickEventMightyLead);
    } else if (isGiruda(leadCard)) {
      final isTop = leadCard.rankValue >= 14 || isTopOfSuit(leadCard.suit!, leadCard.rankValue);
      if (isTop) {
        parts.add(l10n.trickEventTopGirudaLead);
        // 상대 기루다 소진 시: 비기루다 공략, 기루다는 간용 보존
        {
          bool noOpponentGiruda = true;
          for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
            if (i == leadIdx) continue;
            if (isAttack(trick.playerOrder[i]) != isAttack(leadId) &&
                !trick.cards[i].isJoker && trick.cards[i].suit == giruda) {
              noOpponentGiruda = false;
              break;
            }
          }
          if (noOpponentGiruda) {
            parts.add(l10n.trickEventTopGirudaLeadOpponentExhausted);
          }
        }
      } else {
        if (hasMightyInTrick) {
          if (isAutoPlay && isDeclarerLead && topRemainingGirudaStr != null) {
            parts.add(l10n.trickEventMidGirudaMightyBaitForTop(topRemainingGirudaStr!));
          } else {
            parts.add(l10n.trickEventMidGirudaMightyBait);
          }
        } else if (isAutoPlay && isDeclarerLead && leadCard.rank == Rank.queen) {
          // 전략: Q로 선 탈환
          final won = trick.winnerId == leadId;
          if (won) {
            parts.add(l10n.trickEventGirudaQReclaimSuccess);
          } else {
            parts.add(l10n.trickEventGirudaQReclaimFail);
          }
        } else if (trick.winnerId != leadId && isTeammate(trick.winnerId!)) {
          // 수비가 선공보다 높은 카드를 냈는지 확인 (역전 시도)
          bool defenseTriedOvertake = false;
          for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
            if (i == leadIdx) continue;
            final c = trick.cards[i];
            if (!isAttack(trick.playerOrder[i]) && !c.isJoker &&
                c.suit == leadCard.suit && c.rankValue > leadCard.rankValue) {
              defenseTriedOvertake = true;
              break;
            }
          }
          if (defenseTriedOvertake) {
            parts.add(l10n.trickEventFriendAttackDeclarerReOvertake);
          } else {
            parts.add(l10n.trickEventMidGirudaPassLead);
          }
        } else if (trick.winnerId != leadId && !isTeammate(trick.winnerId!)) {
          parts.add(l10n.trickEventDefenderGirudaWin);
        } else {
          // 기루다 리드 시 다른 플레이어가 기루다를 내지 못하면 → 선공자만 기루다 보유
          bool onlyLeaderHasGiruda = true;
          for (int i = 0; i < trick.cards.length; i++) {
            if (i == leadIdx) continue;
            if (!trick.cards[i].isJoker && trick.cards[i].suit == giruda) {
              onlyLeaderHasGiruda = false;
              break;
            }
          }
          if (onlyLeaderHasGiruda && isAttack(leadId)) {
            parts.add(l10n.trickEventSoleGirudaLeadMaintain);
          } else {
            parts.add(l10n.trickEventMidGirudaLead);
          }
        }
        // Check for high giruda card depletion failure
        if (isAttack(leadId) && giruda != null) {
          const suitSymbols = {Suit.spade: '\u2660', Suit.diamond: '\u2666', Suit.heart: '\u2665', Suit.club: '\u2663'};
          final girudaSymbol = suitSymbols[giruda] ?? '';
          // Collect giruda ranks seen up to and including this trick
          final Set<int> seenGirudaRanks = {};
          for (final pt in state.tricks) {
            if (pt.trickNumber > trick.trickNumber) break;
            for (final c in pt.cards) {
              if (!c.isJoker && c.suit == giruda) {
                seenGirudaRanks.add(c.rankValue);
              }
            }
          }
          // Find highest giruda (J+) played by defense in future tricks
          int? highestUnflushed;
          for (final ft in state.tricks) {
            if (ft.trickNumber <= trick.trickNumber) continue;
            for (int i = 0; i < ft.cards.length && i < ft.playerOrder.length; i++) {
              final c = ft.cards[i];
              if (!c.isJoker && c.suit == giruda && !isMighty(c) &&
                  c.rankValue > leadCard.rankValue && c.rankValue >= 11 &&
                  !isAttack(ft.playerOrder[i]) && !seenGirudaRanks.contains(c.rankValue)) {
                if (highestUnflushed == null || c.rankValue > highestUnflushed) {
                  highestUnflushed = c.rankValue;
                }
                seenGirudaRanks.add(c.rankValue);
              }
            }
          }
          if (highestUnflushed != null) {
            const rankNames = {11: 'J', 12: 'Q', 13: 'K', 14: 'A'};
            final rankStr = rankNames[highestUnflushed] ?? highestUnflushed.toString();
            parts.add(l10n.trickEventGirudaDepletionFail('$girudaSymbol$rankStr'));
          }
        }
      }
    } else {
      final isTop = leadCard.rankValue >= 14 || isTopOfSuit(leadCard.suit!, leadCard.rankValue);
      if (isTop) {
        if (isAutoPlay && isDeclarerLead && trick.trickNumber > 1) {
          parts.add(l10n.trickEventHighCardAttack);
        } else if (!isAttack(leadId) && isAttackGirudaCut()) {
          // 수비 비기루다 공격 → 공격팀 기루다 컷 선 탈환
          parts.add(l10n.trickEventDefenseLeadAttackCut);
          girudaCutDescribed = true;
        } else if (isAttack(leadId) && isDefenseGirudaCut()) {
          // 공격 비기루다 최상위 선공 → 수비 기루다 컷
          parts.add(l10n.trickEventAttackLeadDefenseCut);
          girudaCutDescribed = true;
        } else if (!isAttack(leadId) && trick.winnerId != null && !isAttack(trick.winnerId!)) {
          // 수비팀 비기루다 최상위 선공 → 점수 방어
          // 주공 기루다 컷 시도 → 수비 상위 기루다 방어 체크
          bool declarerCutFailed = false;
          int defGirudaCount = 0;
          if (giruda != null && state.declarerId != null) {
            final declIdx = trick.playerOrder.indexOf(state.declarerId!);
            if (declIdx >= 0 && declIdx < trick.cards.length) {
              final declCard = trick.cards[declIdx];
              if (!declCard.isJoker && declCard.suit == giruda) {
                final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
                if (winIdx >= 0 && winIdx < trick.cards.length) {
                  final winCard = trick.cards[winIdx];
                  if (!winCard.isJoker && winCard.suit == giruda) {
                    declarerCutFailed = true;
                    for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
                      if (i == leadIdx) continue;
                      if (!isAttack(trick.playerOrder[i]) && !trick.cards[i].isJoker && trick.cards[i].suit == giruda) {
                        defGirudaCount++;
                      }
                    }
                  }
                }
              }
            }
          }
          if (declarerCutFailed && defGirudaCount >= 2) {
            parts.add(l10n.trickEventDefenseTopDeclarerCutTeamDefense);
            girudaCutDescribed = true;
          } else if (declarerCutFailed) {
            parts.add(l10n.trickEventDefenseTopDeclarerCutDefense);
            girudaCutDescribed = true;
          } else {
            parts.add(l10n.trickEventDefenseTopCardDefend);
          }
        } else {
          parts.add(l10n.trickEventTopNonGirudaLead);
        }
      } else if (trick.trickNumber == 1) {
        if (trick.winnerId != null && isAttack(trick.winnerId!)) {
          // 마이티 프렌드는 초구 사용 가능 → 의도적 유도, 그 외는 행운
          final isMightyFriend = state.friendDeclaration?.card != null &&
              state.friendDeclaration!.card!.isMightyWith(giruda);
          if (isMightyFriend) {
            parts.add(l10n.trickEventFirstTrickMightyBait);
          } else {
            parts.add(l10n.trickEventFirstTrickFriendBait);
          }
        } else {
          parts.add(l10n.trickEventFirstTrickWaste);
        }
      } else {
        // 해당 무늬의 최상위 미출현 카드 찾기
        const rankSymbols = {14: 'A', 13: 'K', 12: 'Q', 11: 'J', 10: '10', 9: '9', 8: '8', 7: '7', 6: '6', 5: '5', 4: '4', 3: '3', 2: '2'};
        const suitSymbolMap = {Suit.spade: '\u2660', Suit.diamond: '\u2666', Suit.heart: '\u2665', Suit.club: '\u2663'};
        String? topCardStr;
        if (leadCard.suit != null) {
          final s = leadCard.suit!;
          for (int r = 14; r > leadCard.rankValue; r--) {
            if (s == mighty.suit && r == mighty.rankValue) continue;
            if (!playedCards.contains('${s.index}-$r')) {
              topCardStr = '${suitSymbolMap[s]}${rankSymbols[r]}';
              break;
            }
          }
        }

        // 선공자가 해당 무늬 손패 중 최선의 카드를 냈는지 확인
        bool leadPlayedBestOfSuit = false;
        if (leadCard.suit != null && isAttack(leadId)) {
          leadPlayedBestOfSuit = true;
          // 현재 손패에 더 높은 같은 무늬 카드 확인
          for (final c in state.players[leadId].hand) {
            if (!c.isJoker && c.suit == leadCard.suit && c.rankValue > leadCard.rankValue) {
              leadPlayedBestOfSuit = false;
              break;
            }
          }
          // 향후 트릭에서 더 높은 같은 무늬 카드를 내는지 확인
          if (leadPlayedBestOfSuit) {
            for (final t in state.tricks) {
              if (t.trickNumber <= trick.trickNumber) continue;
              for (int i = 0; i < t.cards.length && i < t.playerOrder.length; i++) {
                if (t.playerOrder[i] == leadId) {
                  final c = t.cards[i];
                  if (!c.isJoker && c.suit == leadCard.suit && c.rankValue > leadCard.rankValue) {
                    leadPlayedBestOfSuit = false;
                  }
                }
              }
              if (!leadPlayedBestOfSuit) break;
            }
          }
        }

        // 주공 프렌드 유도: 주공이 프렌드 카드 무늬에 저카드 선공 → 프렌드 카드 등장
        bool isDeclarerFriendLure = false;
        if (leadId == state.declarerId && state.friendDeclaration?.card != null) {
          final fCard = state.friendDeclaration!.card!;
          final fSuit = fCard.isJoker ? null : fCard.suit;
          if (fSuit != null && leadCard.suit == fSuit) {
            bool friendCardInTrick = false;
            for (int i = 0; i < trick.cards.length; i++) {
              if (i == leadIdx) continue;
              final c = trick.cards[i];
              if (!c.isJoker && c.suit == fCard.suit && c.rank == fCard.rank) {
                friendCardInTrick = true;
                break;
              }
            }
            if (friendCardInTrick) {
              bool alreadyRevealed = false;
              for (final t in state.tricks) {
                if (t.trickNumber >= trick.trickNumber) break;
                for (final c in t.cards) {
                  if (!fCard.isJoker && !c.isJoker && c.suit == fCard.suit && c.rank == fCard.rank) {
                    alreadyRevealed = true;
                    break;
                  }
                }
                if (alreadyRevealed) break;
              }
              if (!alreadyRevealed) {
                isDeclarerFriendLure = true;
              }
            }
          }
        }

        // 프렌드 물패 → 주공 기루다 컷 시도 → 수비 기루다 재역전
        bool isFriendWasteDeclarerCutDefenseOvercut = false;
        if (isAttack(leadId) && leadId != state.declarerId &&
            leadCard.suit != giruda &&
            trick.winnerId != null && !isAttack(trick.winnerId!)) {
          final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
          if (winIdx >= 0 && winIdx < trick.cards.length) {
            final winCard = trick.cards[winIdx];
            if (!winCard.isJoker && winCard.suit == giruda) {
              // 주공이 기루다를 냈는지 확인 (기루다 컷 시도)
              if (state.declarerId != null) {
                final declIdx = trick.playerOrder.indexOf(state.declarerId!);
                if (declIdx >= 0 && declIdx < trick.cards.length) {
                  final declCard = trick.cards[declIdx];
                  if (!declCard.isJoker && declCard.suit == giruda) {
                    isFriendWasteDeclarerCutDefenseOvercut = true;
                  }
                }
              }
            }
          }
        }

        // 프렌드 선공 → 수비 역전 → 주공 기루다 컷 재역전
        bool isFriendLeadDefenseBeatDeclarerCut = false;
        if (isAttack(leadId) && leadId != state.declarerId && trick.winnerId == state.declarerId) {
          // 프렌드가 선공, 주공이 승리
          final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
          if (winIdx >= 0 && winIdx < trick.cards.length) {
            final winCard = trick.cards[winIdx];
            // 주공이 기루다 컷으로 승리
            if (!winCard.isJoker && winCard.suit == giruda && leadCard.suit != giruda) {
              // 수비가 선공 무늬의 더 높은 카드를 냈는지 확인
              for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
                if (i == leadIdx || i == winIdx) continue;
                final c = trick.cards[i];
                if (!isAttack(trick.playerOrder[i]) && !c.isJoker && c.suit == leadCard.suit && c.rankValue > leadCard.rankValue) {
                  isFriendLeadDefenseBeatDeclarerCut = true;
                  break;
                }
              }
            }
          }
        }

        if (isDeclarerFriendLure) {
          if (trick.winnerId != null && isAttack(trick.winnerId!)) {
            parts.add(l10n.trickEventDeclarerFriendLure);
          } else {
            parts.add(l10n.trickEventDeclarerFriendLureFailed);
          }
        } else if (isFriendWasteDeclarerCutDefenseOvercut) {
          final ptCount = trick.cards.where((c) => !c.isJoker && c.isPointCard).length;
          if (ptCount > 0) {
            parts.add(l10n.trickEventFriendWasteDeclarerCutDefenseOvercutPoints(ptCount));
          } else {
            parts.add(l10n.trickEventFriendWasteDeclarerCutDefenseOvercut);
          }
          girudaCutDescribed = true;
        } else if (isFriendLeadDefenseBeatDeclarerCut) {
          parts.add(l10n.trickEventFriendLeadDefenseBeatDeclarerCut);
          girudaCutDescribed = true;
        // 수비팀이 마이티 무늬를 내서 마이티 소진 유도
        } else if (!isAttack(leadId) && leadCard.suit == mighty.suit && hasMightyInTrick) {
          final ptCount = trick.cards.where((c) => !c.isJoker && c.isPointCard).length;
          if (ptCount <= 1) {
            parts.add(l10n.trickEventDefenseMightyExhaust);
          } else {
            parts.add(l10n.trickEventDefenseMightyExhaustPoints(ptCount));
          }
          mightyExhaustDescribed = true;
        } else if (trick.winnerId != null && trick.winnerId != leadId && trick.winnerId == state.declarerId) {
          if (topCardStr != null) {
            parts.add(l10n.trickEventWasteDeclarerReclaimWithTop(topCardStr));
          } else {
            parts.add(l10n.trickEventWasteDeclarerReclaim);
          }
        } else if (trick.winnerId != null && trick.winnerId != leadId && isAttack(trick.winnerId!)) {
          // 프렌드가 마이티로 수비 공격을 탈환한 경우
          final fWinIdx = trick.playerOrder.indexOf(trick.winnerId!);
          final fWinCard = (fWinIdx >= 0 && fWinIdx < trick.cards.length) ? trick.cards[fWinIdx] : null;
          final friendWonWithMighty = fWinCard != null && fWinCard.isMightyWith(giruda);
          if (!isAttack(leadId) && friendWonWithMighty) {
            if (topCardStr != null) {
              parts.add(l10n.trickEventFriendMightyReclaimWithTop(topCardStr));
            } else {
              parts.add(l10n.trickEventFriendMightyReclaim);
            }
          } else {
            if (topCardStr != null) {
              parts.add(l10n.trickEventWasteFriendRescueWithTop(topCardStr));
            } else {
              parts.add(l10n.trickEventWasteFriendRescue);
            }
          }
        } else if (leadPlayedBestOfSuit && trick.winnerId != null && trick.winnerId != leadId && !isAttack(trick.winnerId!)) {
          // 공격팀 최선 공격 → 수비 상위 카드에 패배
          if (topCardStr != null) {
            parts.add(l10n.trickEventAttackFailedWithTop(topCardStr));
          } else {
            parts.add(l10n.trickEventAttackFailed);
          }
        } else {
          if (topCardStr != null) {
            parts.add(l10n.trickEventWasteWithTop(topCardStr));
          } else {
            parts.add(l10n.trickEventWaste);
          }
        }
      }
    }
    } // end if (!leadDescribed)

    // 조커콜 선언
    if (trick.jokerCall == JokerCallType.jokerCall) {
      parts.add(l10n.trickEventJokerCallDeclared);
    }

    // Outcome: 기루다 컷 (리드 설명에서 이미 기술된 경우 생략)
    if (!girudaCutDescribed && trick.leadSuit != giruda && giruda != null) {
      final winIdx = trick.playerOrder.indexOf(trick.winnerId!);
      if (winIdx >= 0 && winIdx < trick.cards.length) {
        final winCard = trick.cards[winIdx];
        if (isGiruda(winCard) && trick.winnerId != leadId) {
          if (isAttack(trick.winnerId!)) {
            parts.add(l10n.trickEventAttackGirudaCut);
          } else {
            parts.add(l10n.trickEventDefenseGirudaCut);
            // 공격팀 기루다 소진 상태에서 수비만 기루다 보유 → 특이 상황
            bool attackHasGirudaLeft = false;
            for (final ft in state.tricks) {
              if (ft.trickNumber <= trick.trickNumber) continue;
              for (int i = 0; i < ft.cards.length && i < ft.playerOrder.length; i++) {
                if (isAttack(ft.playerOrder[i]) && !ft.cards[i].isJoker && ft.cards[i].suit == giruda) {
                  attackHasGirudaLeft = true;
                }
              }
            }
            if (!attackHasGirudaLeft) {
              bool attackPlayedGirudaHere = false;
              for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
                if (isAttack(trick.playerOrder[i]) && !trick.cards[i].isJoker && trick.cards[i].suit == giruda) {
                  attackPlayedGirudaHere = true;
                }
              }
              if (!attackPlayedGirudaHere) {
                parts.add(l10n.trickEventAttackNoGirudaDefenseHas);
              }
            }
          }
        }
      }
    }

    // Outcome: K/Q 소진 성공 (기루다 K, Q가 비선공으로 출현, 공격팀 승리 시만)
    final attackWonTrick = trick.winnerId != null && isAttack(trick.winnerId!);
    if (giruda != null && girudaKInTrick && attackWonTrick) {
      final kIdx = trick.cards.indexWhere((c) =>
          !c.isJoker && c.suit == giruda && c.rank == Rank.king);
      final qIdx = trick.cards.indexWhere((c) =>
          !c.isJoker && c.suit == giruda && c.rank == Rank.queen);
      if (kIdx >= 0 && kIdx != leadIdx && qIdx >= 0 && qIdx != leadIdx) {
        parts.add(l10n.trickEventGirudaKQExhaustSuccess);
      } else if (kIdx >= 0 && kIdx != leadIdx) {
        parts.add(l10n.trickEventGirudaKExhaustSuccess);
      }
    }

    // Outcome: 프렌드 유도 → 수비 기루다 소진 성공
    if (giruda != null && attackWonTrick &&
        trick.leadIntent == LeadIntent.lowGirudaFriendPass &&
        trick.leadPlayerId == state.declarerId) {
      const rankNames = {11: 'J', 12: 'Q', 13: 'K'};
      final exhausted = <String>[];
      for (int i = 0; i < trick.cards.length && i < trick.playerOrder.length; i++) {
        if (i == leadIdx) continue;
        final c = trick.cards[i];
        if (!c.isJoker && c.suit == giruda && c.rankValue >= 11 && c.rankValue <= 13 &&
            !isAttack(trick.playerOrder[i])) {
          final name = rankNames[c.rankValue];
          if (name != null) exhausted.add(name);
        }
      }
      if (exhausted.isNotEmpty) {
        parts.add(l10n.trickEventFriendLureGirudaExhaust(exhausted.join('/')));
      }
    }

    // Outcome: 마이티 출현 (비선공 카드, 마이티 소진 유도에서 이미 기술된 경우 생략)
    if (!mightyExhaustDescribed) {
      for (int i = 0; i < trick.cards.length; i++) {
        if (i == leadIdx) continue;
        if (isMighty(trick.cards[i])) {
          parts.add(l10n.trickMightyAppeared);
          break;
        }
      }
    }

    // Outcome: 수비팀 조커 반격 / 런 저지 (비선공 조커가 트릭 승리)
    {
      bool defenseJokerWin = false;
      for (int i = 0; i < trick.cards.length; i++) {
        if (i == leadIdx) continue;
        if (trick.cards[i].isJoker &&
            i < trick.playerOrder.length &&
            trick.winnerId == trick.playerOrder[i] &&
            !isAttack(trick.playerOrder[i])) {
          defenseJokerWin = true;
          break;
        }
      }
      if (defenseJokerWin) {
        // 이전 트릭 모두 공격팀 승리 → 수비 조커로 런 저지
        if (trick.trickNumber >= 2) {
          final allPrevAttackWin = state.tricks
              .where((t) => t.trickNumber < trick.trickNumber)
              .every((t) => t.winnerId != null && isAttack(t.winnerId!));
          if (allPrevAttackWin) {
            parts.add(l10n.trickEventDefenseJokerRunBlock);
          }
        }
        // 마이티 소멸 후 조커 반격
        final bool mightyAlreadyPlayed = mighty.suit != null &&
            playedCards.contains('${mighty.suit!.index}-${mighty.rankValue}');
        if (mightyAlreadyPlayed) {
          parts.add(l10n.trickEventDefenseJokerCounterattack);
        }
      }
    }

    // Outcome: 프렌드 합류 (이번 트릭에서 프렌드 카드 출현)
    if (friendCard != null && !friendAlreadyRevealed) {
      bool friendInTrick = false;
      if (friendCard.isJoker) {
        friendInTrick = trick.cards.any((c) => c.isJoker);
      } else if (friendCard.suit != null) {
        friendInTrick = trick.cards.any((c) =>
            !c.isJoker && c.suit == friendCard.suit && c.rank == friendCard.rank);
      }
      if (friendInTrick) {
        parts.add(l10n.trickFriendJoined);
      }
    }

    // Outcome: 프렌드 최상위 카드 승리 & 프렌드 공격 기여 트릭 수
    if (state.friendRevealed && state.friendId != null && trick.winnerId == state.friendId) {
      // 프렌드가 낸 카드 확인
      final friendPlayerIdx = trick.playerOrder.indexOf(state.friendId!);
      if (friendPlayerIdx >= 0 && friendPlayerIdx < trick.cards.length) {
        final friendPlayedCard = trick.cards[friendPlayerIdx];
        if (!friendPlayedCard.isJoker && !friendPlayedCard.isMightyWith(giruda) &&
            friendPlayedCard.suit != null) {
          final isTopCard = isTopOfSuit(friendPlayedCard.suit!, friendPlayedCard.rankValue);
          // 프렌드가 선공이면 리드 설명과 중복되므로 생략
          if (isTopCard && friendPlayerIdx != leadIdx) {
            // 프렌드 기루다 K + 주공 A 보유 → 공격팀 기루다 장악
            if (giruda != null && friendPlayedCard.suit == giruda && friendPlayedCard.rank == Rank.king) {
              bool declarerHasGirudaA = false;
              for (final t in state.tricks) {
                for (int i = 0; i < t.cards.length && i < t.playerOrder.length; i++) {
                  if (t.playerOrder[i] == state.declarerId && !t.cards[i].isJoker &&
                      t.cards[i].suit == giruda && t.cards[i].rank == Rank.ace) {
                    declarerHasGirudaA = true;
                  }
                }
              }
              parts.add(declarerHasGirudaA ? l10n.trickEventFriendGirudaKDeclarerA : l10n.trickEventFriendTopCardWin);
            } else {
              parts.add(l10n.trickEventFriendTopCardWin);
            }
          }
        }
      }
      // 프렌드가 승리한 트릭 수 누적 (현재 트릭 포함)
      int friendWinCount = 0;
      for (final t in state.tricks) {
        if (t.trickNumber > trick.trickNumber) break;
        if (t.winnerId == state.friendId) friendWinCount++;
      }
      if (friendWinCount >= 2) {
        parts.add(l10n.trickEventFriendTrickContribution(friendWinCount));
      }
    }

    // 주요 카드 보유 미사용 분석 (조커, 기루다 A)
    {
      // 현재 손패 또는 향후 트릭에서 특정 카드를 내는 플레이어 찾기
      int? findCardHolder(bool Function(PlayingCard) matcher) {
        for (final pid in trick.playerOrder) {
          if (state.players[pid].hand.any(matcher)) return pid;
        }
        for (final t in state.tricks) {
          if (t.trickNumber <= trick.trickNumber) continue;
          for (int i = 0; i < t.cards.length && i < t.playerOrder.length; i++) {
            if (matcher(t.cards[i])) return t.playerOrder[i];
          }
        }
        return null;
      }

      final pointCount = trick.cards.where((c) => !c.isJoker && c.isPointCard).length;

      // 조커 보유자가 이 트릭에서 조커를 내지 않았을 때 (무득점 트릭)
      if (trick.trickNumber > 1 && !playedCards.contains('joker') &&
          !trick.cards.any((c) => c.isJoker) && pointCount == 0) {
        final jokerHolder = findCardHolder((c) => c.isJoker);
        if (jokerHolder != null) {
          final name = _getLocalizedPlayerName(state.players[jokerHolder], l10n);
          parts.add(l10n.trickEventJokerSkipNoPoints(name));
        }
      }

      // 기루다 A 보유자가 이 트릭에서 기루다 A를 내지 않았을 때
      if (giruda != null && !playedCards.contains('${giruda.index}-14') &&
          !trick.cards.any((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace)) {
        final girudaAHolder = findCardHolder((c) => !c.isJoker && c.suit == giruda && c.rank == Rank.ace);
        if (girudaAHolder != null) {
          final name = _getLocalizedPlayerName(state.players[girudaAHolder], l10n);
          final mightyPlayed = mighty.suit != null &&
              (playedCards.contains('${mighty.suit!.index}-${mighty.rankValue}') ||
               trick.cards.any((c) => isMighty(c)));
          if (!mightyPlayed && !isAttack(girudaAHolder)) {
            parts.add(l10n.trickEventGirudaAceHeldMightyGuard(name));
          } else if (mightyPlayed) {
            parts.add(l10n.trickEventGirudaAceHeld(name));
          }
        }
      }
    }

    return parts.isNotEmpty ? parts.join(' / ') : null;
  }

  String? _describeLeadFromIntent(Trick trick, GameState state, AppLocalizations l10n) {
    final intent = trick.leadIntent;
    if (intent == null) return null;

    final giruda = state.giruda;
    const suitSymbols = {Suit.spade: '\u2660', Suit.diamond: '\u2666', Suit.heart: '\u2665', Suit.club: '\u2663'};
    final declaredSuit = trick.leadSuit;
    final suitStr = declaredSuit != null ? suitSymbols[declaredSuit] ?? '' : '';

    switch (intent) {
      case LeadIntent.jokerAfterFriend:
        return suitStr.isNotEmpty
            ? l10n.trickEventJokerAfterFriend(suitStr)
            : l10n.trickEventJokerAfterFriendGeneral;
      case LeadIntent.jokerLeadSuit:
        String desc = suitStr.isNotEmpty
            ? l10n.trickEventJokerLeadSuit(suitStr)
            : l10n.trickEventJokerLead;
        if (declaredSuit != null && declaredSuit == giruda) {
          desc += ' / ${l10n.trickEventJokerGirudaExhaust}';
        }
        return desc;
      case LeadIntent.jokerGirudaExhaust:
        String desc = suitStr.isNotEmpty
            ? l10n.trickEventJokerLeadSuit(suitStr)
            : l10n.trickEventJokerLead;
        desc += ' / ${l10n.trickEventJokerGirudaExhaust}';
        return desc;
      case LeadIntent.mightyLead:
        return l10n.trickEventMightyLead;
      case LeadIntent.mightyTrick9:
        return l10n.trickEventMightyLead;
      case LeadIntent.topGirudaLead:
        return l10n.trickEventTopGirudaLead;
      case LeadIntent.midGirudaMightyBait:
        return l10n.trickEventMidGirudaMightyBait;
      case LeadIntent.midGirudaLead:
        return l10n.trickEventMidGirudaLead;
      case LeadIntent.midGirudaPassLead:
        return l10n.trickEventMidGirudaPassLead;
      case LeadIntent.soleGirudaLeadMaintain:
        return l10n.trickEventSoleGirudaLeadMaintain;
      case LeadIntent.lowGirudaFriendPass:
        // 주공 선공이면 프렌드 유도, 프렌드 선공이면 선 넘김
        if (trick.leadPlayerId == state.declarerId) {
          return l10n.trickEventDeclarerFriendLure;
        }
        return l10n.trickEventMidGirudaPassLead;
      case LeadIntent.highCardAttack:
        final attackWon = trick.winnerId != null &&
            (trick.winnerId == state.declarerId || trick.winnerId == state.friendId);
        return attackWon ? l10n.trickEventHighCardAttack : l10n.trickEventHighCardAttackFailed;
      case LeadIntent.topNonGirudaLead:
        return l10n.trickEventTopNonGirudaLead;
      case LeadIntent.defenseTopCard:
        return l10n.trickEventDefenseTopCardDefend;
      case LeadIntent.firstTrickTopAttack:
        return l10n.trickEventFirstTrickTopAttack;
      case LeadIntent.firstTrickMightyBait:
        return l10n.trickEventFirstTrickMightyBait;
      case LeadIntent.firstTrickFriendBait:
        return l10n.trickEventFirstTrickFriendBait;
      case LeadIntent.firstTrickWaste:
        return l10n.trickEventFirstTrickWaste;
      case LeadIntent.declarerFriendLure:
        return l10n.trickEventDeclarerFriendLure;
      case LeadIntent.defenseMightyExhaust:
        return l10n.trickEventDefenseMightyExhaust;
      case LeadIntent.friendVoidPass:
        return l10n.trickEventWaste;
      case LeadIntent.friendTopCardLead:
        return l10n.trickEventTopNonGirudaLead;
      case LeadIntent.defenseJokerLead:
        return l10n.trickEventJokerLead;
      case LeadIntent.defenseHighCard:
        return l10n.trickEventDefenseTopCardDefend;
      case LeadIntent.defenseLowCard:
        return l10n.trickEventWaste;
      case LeadIntent.waste:
        return l10n.trickEventWaste;
    }
  }

  Widget _buildTrickDetailsScreen(GameController controller) {
    final l10n = AppLocalizations.of(context)!;
    final state = controller.state;
    final screenHeight = MediaQuery.of(context).size.height;
    final compact = screenHeight < 700;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxHeight: screenHeight * (compact ? 0.92 : 0.85)),
        padding: EdgeInsets.all(compact ? 12 : 20),
        margin: EdgeInsets.all(compact ? 8 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              () {
                final isPlayerWinner = widget.isAutoPlay ? state.declarerWon : state.getPlayerScore(state.players[0].id) >= 0;
                return Text(
                  widget.isAutoPlay
                      ? (isPlayerWinner ? l10n.declarerTeamWins : l10n.defenderTeamWins)
                      : (isPlayerWinner ? l10n.victory : l10n.defeat),
                  style: TextStyle(
                    fontSize: compact ? 22 : 28,
                    fontWeight: FontWeight.bold,
                    color: isPlayerWinner ? Colors.green : Colors.red,
                  ),
                );
              }(),
              SizedBox(height: compact ? 2 : 4),
              Text(
                '${state.declarerTeamPoints == 20 ? '${l10n.declarerTeam}: ${l10n.fullPoints}' : l10n.declarerTeamPoints(state.declarerTeamPoints)}  /  ${l10n.targetPoints(state.currentBid?.tricks ?? 0)}',
                style: TextStyle(fontSize: compact ? 13 : 15, color: Colors.grey[700]),
              ),
              SizedBox(height: compact ? 6 : 12),
              _buildTrickDetailsTable(state, compact: compact, l10n: l10n),
              SizedBox(height: compact ? 10 : 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _showGameResult = true;
                        _showTrickDetails = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20, vertical: compact ? 7 : 10),
                    ),
                    child: Text(
                      l10n.score,
                      style: TextStyle(fontSize: compact ? 14 : 16, color: Colors.black),
                    ),
                  ),
                  SizedBox(width: compact ? 8 : 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _statsRecorded = false;
                        _showGameResult = true;
                        _showTrickDetails = false;
                        _showHint = false;
                      });
                      controller.reset();
                      controller.startNewGame();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(horizontal: compact ? 14 : 20, vertical: compact ? 7 : 10),
                    ),
                    child: Text(
                      l10n.newGame,
                      style: TextStyle(fontSize: compact ? 14 : 16, color: Colors.white),
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

  Widget _buildTrickDetailsTable(GameState state, {required bool compact, required AppLocalizations l10n}) {
    final tricks = state.tricks;
    if (tricks.isEmpty) return const SizedBox.shrink();

    final giruda = state.giruda;
    final fontSize = compact ? 10.0 : 12.0;

    // 플레이어 이름 + 역할
    final playerNames = <int, String>{};
    final playerRoles = <int, String>{};
    for (int i = 0; i < state.players.length; i++) {
      playerNames[i] = _getLocalizedPlayerName(state.players[i], l10n);
      if (state.players[i].isDeclarer) {
        playerRoles[i] = l10n.declarer;
      } else if (state.players[i].isFriend) {
        playerRoles[i] = l10n.friend;
      }
    }

    final friendCard = state.friendDeclaration?.card;

    // 트릭별 데이터 계산
    final playedCards = <String>{};
    final rows = <_TrickRowData>[];
    int girudaRemaining = giruda != null ? 13 : 0;

    for (final trick in tricks) {
      // describeTrick
      final description = _describeTrick(trick, state, l10n, playedCards, isAutoPlay: widget.isAutoPlay);

      // 카드 → playedCards에 추가, 기루다 카운트 감소
      int girudaInTrick = 0;
      final cardsByPlayer = <int, PlayingCard>{};
      for (int i = 0; i < trick.cards.length; i++) {
        final card = trick.cards[i];
        final playerId = trick.playerOrder[i];
        cardsByPlayer[playerId] = card;
        if (card.isJoker) {
          playedCards.add('joker');
        } else if (card.suit != null) {
          playedCards.add('${card.suit!.index}-${card.rankValue}');
          if (card.suit == giruda) girudaInTrick++;
        }
      }
      girudaRemaining -= girudaInTrick;

      // 득실 계산: 공격팀 기준 점수카드 수
      int trickDelta = 0;
      if (trick.winnerId != null) {
        final pointCount = trick.cards.where((c) => c.isPointCard).length;
        final isAttackWin = trick.winnerId == state.declarerId || trick.winnerId == state.friendId;
        trickDelta = isAttackWin ? pointCount : -pointCount;
      }

      rows.add(_TrickRowData(
        trickNumber: trick.trickNumber,
        cardsByPlayer: cardsByPlayer,
        leadPlayerId: trick.leadPlayerId,
        winnerId: trick.winnerId,
        trickDelta: trickDelta,
        girudaRemaining: girudaRemaining,
        description: description,
        jokerLeadSuit: trick.jokerLeadSuit,
      ));
    }

    // 기루다/마이티 정보 및 범례
    final girudaSymbol = giruda != null ? _getSuitSymbol(giruda) : null;
    final girudaColor = giruda != null
        ? (giruda == Suit.diamond || giruda == Suit.heart ? Colors.red[600]! : Colors.grey[900]!)
        : null;
    final mighty = state.mighty;
    final mightyText = '${_getSuitSymbol(mighty.suit!)}${mighty.rankSymbol}';
    final mightyColor = mighty.isRed ? Colors.red[600]! : Colors.grey[900]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.trickDetails,
          style: TextStyle(fontSize: compact ? 14 : 16, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: compact ? 2 : 4),
        // 범례
        Wrap(
          spacing: compact ? 8 : 12,
          runSpacing: 4,
          children: [
            // 기루다
            if (giruda != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.giruda}: ',
                    style: TextStyle(fontSize: fontSize, color: Colors.grey[600]),
                  ),
                  Text(
                    girudaSymbol!,
                    style: TextStyle(fontSize: fontSize + 2, color: girudaColor, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            else
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${l10n.giruda}: ',
                    style: TextStyle(fontSize: fontSize, color: Colors.grey[600]),
                  ),
                  Text(
                    l10n.noGiruda,
                    style: TextStyle(fontSize: fontSize, color: Colors.grey[600], fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            // 마이티
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${l10n.mighty}: ',
                  style: TextStyle(fontSize: fontSize, color: Colors.grey[600]),
                ),
                Text(
                  mightyText,
                  style: TextStyle(fontSize: fontSize, color: mightyColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            // 선공 범례
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[400]!, width: 1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'A',
                    style: TextStyle(fontSize: fontSize, color: Colors.grey[600]),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  l10n.trickLegendLead,
                  style: TextStyle(fontSize: fontSize, color: Colors.grey[600]),
                ),
              ],
            ),
            // 승자 범례
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: fontSize + 6,
                  height: fontSize + 4,
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  l10n.trickLegendWinner,
                  style: TextStyle(fontSize: fontSize, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: compact ? 4 : 8),
        Scrollbar(
          controller: _trickTableScrollController,
          thumbVisibility: true,
          child: SingleChildScrollView(
            controller: _trickTableScrollController,
            scrollDirection: Axis.horizontal,
            child: Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey[200]!, width: 0.5),
              ),
            children: [
              // 헤더 행
              TableRow(
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1)),
                ),
                children: [
                  _trickHeaderCell('#', fontSize),
                  for (int i = 0; i < 5; i++)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      child: Column(
                        children: [
                          Text(
                            playerNames[i] ?? '',
                            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                          ),
                          if (playerRoles[i] != null)
                            Text(
                              playerRoles[i]!,
                              style: TextStyle(
                                fontSize: fontSize - 2,
                                color: state.players[i].isDeclarer ? Colors.red[600] : Colors.blue[600],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  _trickHeaderCell(l10n.trickColumnGainLoss, fontSize),
                  _trickHeaderCell(l10n.trickColumnGiruda, fontSize),
                  _trickHeaderCell(l10n.trickColumnEvent, fontSize),
                ],
              ),
              // 데이터 행
              for (final row in rows)
                TableRow(
                  children: [
                    // 트릭 번호
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Text(
                        '${row.trickNumber}',
                        style: TextStyle(fontSize: fontSize, color: Colors.grey[500], fontFamily: 'monospace'),
                      ),
                    ),
                    // 5명의 플레이어 카드
                    for (int i = 0; i < 5; i++)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                        color: row.winnerId == i ? Colors.blue[50] : null,
                        child: row.cardsByPlayer[i] != null
                            ? _buildTrickCardCell(row.cardsByPlayer[i]!, i == row.leadPlayerId, fontSize,
                                jokerLeadSuit: i == row.leadPlayerId ? row.jokerLeadSuit : null,
                                isFriendCard: friendCard != null && row.cardsByPlayer[i] == friendCard)
                            : Text('-', textAlign: TextAlign.center, style: TextStyle(fontSize: fontSize, color: Colors.grey[300])),
                      ),
                    // 득실
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Text(
                        row.trickDelta > 0 ? '+${row.trickDelta}' : row.trickDelta < 0 ? '${row.trickDelta}' : '-',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: fontSize,
                          fontFamily: 'monospace',
                          fontWeight: row.trickDelta != 0 ? FontWeight.bold : FontWeight.normal,
                          color: row.trickDelta > 0 ? Colors.blue[600] : row.trickDelta < 0 ? Colors.red[500] : Colors.grey[300],
                        ),
                      ),
                    ),
                    // 기루다 남은 수
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Text(
                        '${row.girudaRemaining}',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: fontSize, fontFamily: 'monospace', color: Colors.grey[400]),
                      ),
                    ),
                    // 이벤트
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      child: Text(
                        row.description ?? '',
                        style: TextStyle(fontSize: fontSize, color: Colors.grey[500]),
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

  Widget _trickHeaderCell(String text, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Colors.grey[700]),
      ),
    );
  }

  Widget _buildTrickCardCell(PlayingCard card, bool isLead, double fontSize, {Suit? jokerLeadSuit, bool isFriendCard = false}) {
    String text = card.toString();
    Color textColor;
    if (card.isJoker) {
      textColor = Colors.green[700]!;
      if (jokerLeadSuit != null) {
        const suitSymbols = {Suit.spade: '\u2660', Suit.diamond: '\u2666', Suit.heart: '\u2665', Suit.club: '\u2663'};
        text = 'JK${suitSymbols[jokerLeadSuit] ?? ''}';
      }
    } else if (card.isRed) {
      textColor = Colors.red[600]!;
    } else {
      textColor = Colors.grey[900]!;
    }

    Widget child = Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: fontSize, color: textColor, fontWeight: FontWeight.w500),
    );

    if (isLead) {
      child = Container(
        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      );
    }

    if (isFriendCard) {
      child = Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.blue[400]!, width: 2)),
        ),
        child: child,
      );
    }

    return child;
  }
}

class _TrickRowData {
  final int trickNumber;
  final Map<int, PlayingCard> cardsByPlayer;
  final int leadPlayerId;
  final int? winnerId;
  final int trickDelta;
  final int girudaRemaining;
  final String? description;
  final Suit? jokerLeadSuit;

  _TrickRowData({
    required this.trickNumber,
    required this.cardsByPlayer,
    required this.leadPlayerId,
    required this.winnerId,
    required this.trickDelta,
    required this.girudaRemaining,
    required this.description,
    this.jokerLeadSuit,
  });
}
