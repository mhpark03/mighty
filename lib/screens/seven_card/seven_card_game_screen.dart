import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/card.dart';
import '../../models/seven_card/poker_hand.dart';
import '../../models/seven_card/seven_card_state.dart';
import '../../services/ad_service.dart';
import '../../services/seven_card/seven_card_controller.dart';
import '../../services/seven_card/seven_card_stats_service.dart';
import '../../l10n/l10n_helper.dart';

/// 반응형 사이즈 헬퍼
class _ResponsiveSizes {
  final double screenHeight;
  final double screenWidth;

  // AI 카드 사이즈
  late final double aiCardWidth;
  late final double aiCardHeight;
  late final double aiFontSize;

  // 플레이어 카드 사이즈
  late final double playerCardWidth;
  late final double playerCardHeight;
  late final double playerFontSize;

  // 일반 폰트 사이즈
  late final double nameFontSize;
  late final double infoFontSize;
  late final double badgeFontSize;

  // 팟 사이즈
  late final double potIconSize;
  late final double potFontSize;

  _ResponsiveSizes(this.screenHeight, this.screenWidth) {
    // 화면 크기에 비례해서 동적으로 계산
    final baseUnit = screenHeight / 100;
    final widthUnit = screenWidth / 100;

    // AI 카드 - 화면 높이의 비율로 계산
    aiCardWidth = (widthUnit * 4.5).clamp(26.0, 50.0);
    aiCardHeight = (baseUnit * 7).clamp(36.0, 70.0);
    aiFontSize = (baseUnit * 1.8).clamp(9.0, 14.0);

    // 플레이어 카드 - 화면 너비 기준으로 7장이 들어가도록
    playerCardWidth = (widthUnit * 5.5).clamp(32.0, 60.0);
    playerCardHeight = (baseUnit * 9).clamp(46.0, 85.0);
    playerFontSize = (baseUnit * 2.2).clamp(11.0, 18.0);

    // 폰트
    nameFontSize = (baseUnit * 2).clamp(10.0, 16.0);
    infoFontSize = (baseUnit * 1.5).clamp(8.0, 13.0);
    badgeFontSize = (baseUnit * 1.5).clamp(8.0, 13.0);

    // 팟
    potIconSize = (baseUnit * 7).clamp(32.0, 60.0);
    potFontSize = (baseUnit * 4).clamp(16.0, 32.0);
  }
}

class SevenCardGameScreen extends StatefulWidget {
  const SevenCardGameScreen({super.key});

  @override
  State<SevenCardGameScreen> createState() => _SevenCardGameScreenState();
}

class _SevenCardGameScreenState extends State<SevenCardGameScreen> with TickerProviderStateMixin {
  bool _statsRecorded = false;
  bool _showHint = false;
  late AnimationController _fireworksController;
  late Animation<double> _fireworksAnimation;
  bool _showFireworks = false;

  @override
  void initState() {
    super.initState();
    _fireworksController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fireworksAnimation = CurvedAnimation(
      parent: _fireworksController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _fireworksController.dispose();
    super.dispose();
  }

  void _triggerFireworks() {
    setState(() {
      _showFireworks = true;
    });
    _fireworksController.forward(from: 0.0);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showFireworks = false;
        });
      }
    });
  }

  void _showNewGameDialog(SevenCardController controller, AppLocalizations l10n) {
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
                  _showHint = false;
                  controller.startNewGame();
                },
                onAdNotAvailable: () {
                  _statsRecorded = false;
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<SevenCardController>(
      builder: (context, controller, child) {
        final state = controller.state;

        return Scaffold(
          backgroundColor: Colors.blue[900],
          appBar: AppBar(
            backgroundColor: Colors.blue[800],
            title: Text(l10n.sevenCardTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.lightbulb, color: _showHint ? Colors.yellow : Colors.white),
                tooltip: _showHint ? l10n.hintOff : l10n.hint,
                onPressed: _onHintButtonPressed,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.newGame,
                onPressed: () => _showNewGameDialog(controller, l10n),
              ),
            ],
          ),
          body: SafeArea(
            child: _buildGameArea(controller, state, l10n),
          ),
        );
      },
    );
  }

  Widget _buildGameArea(SevenCardController controller, SevenCardState state, AppLocalizations l10n) {
    if (state.phase == SevenCardPhase.waiting) {
      return _buildWaitingScreen(controller, l10n);
    } else if (state.phase == SevenCardPhase.selectOpen) {
      return _buildSelectOpenScreen(controller, state, l10n);
    } else if (state.phase == SevenCardPhase.gameEnd) {
      return _buildGameEndScreen(controller, state, l10n);
    } else {
      return _buildPlayingScreen(controller, state, l10n);
    }
  }

  Widget _buildSelectOpenScreen(SevenCardController controller, SevenCardState state, AppLocalizations l10n) {
    final player = state.humanPlayer;
    final isMyTurn = state.currentPlayerIndex == 0;
    final recommendedIndex = _showHint ? controller.getRecommendedOpenCardIndex() : null;

    return Column(
      children: [
        // 상단 안내
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black26,
          child: Column(
            children: [
              const Icon(Icons.visibility, color: Colors.amber, size: 40),
              const SizedBox(height: 8),
              Text(
                l10n.selectOpenCard,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.selectOpenCardDesc,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              // AI 추천 표시
              if (_showHint && isMyTurn && recommendedIndex != null) ...[
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
                        '${l10n.aiRecommendation}: ${l10n.nthCard(recommendedIndex + 1)}',
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
            ],
          ),
        ),
        const Spacer(),
        // 카드 선택 영역
        if (isMyTurn)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: player.hand.asMap().entries.map((entry) {
                final index = entry.key;
                final card = entry.value;
                final isRecommended = _showHint && recommendedIndex == index;
                return _buildSelectableCard(card, index, controller, isRecommended: isRecommended);
              }).toList(),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const CircularProgressIndicator(color: Colors.amber),
                const SizedBox(height: 16),
                Text(
                  l10n.aiSelectingCard,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        const Spacer(),
      ],
    );
  }

  Widget _buildSelectableCard(PlayingCard card, int index, SevenCardController controller, {bool isRecommended = false}) {
    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankStr = _getRankString(card.rank);

    return GestureDetector(
      onTap: () => controller.humanSelectOpenCard(index),
      child: Container(
        width: 80,
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isRecommended ? Colors.lightBlueAccent.withValues(alpha: 0.2) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isRecommended ? Colors.lightBlueAccent : Colors.amber,
            width: isRecommended ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isRecommended
                  ? Colors.lightBlueAccent.withValues(alpha: 0.5)
                  : Colors.black.withValues(alpha: 0.3),
              blurRadius: isRecommended ? 8 : 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isRecommended)
              const Icon(Icons.lightbulb, color: Colors.lightBlueAccent, size: 16),
            Text(
              rankStr,
              style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              suitSymbol,
              style: TextStyle(color: color, fontSize: 32),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingScreen(SevenCardController controller, AppLocalizations l10n) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () => controller.startNewGame(),
        icon: const Icon(Icons.play_arrow),
        label: Text(l10n.startGame),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPlayingScreen(SevenCardController controller, SevenCardState state, AppLocalizations l10n) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final screenWidth = mediaQuery.size.width;
    final sizes = _ResponsiveSizes(screenHeight, screenWidth);

    final opponents = state.players.where((p) => p.id != 0).toList();
    final leftOpponents = opponents.length >= 2 ? opponents.sublist(0, 2) : opponents;
    final rightOpponents = opponents.length > 2 ? opponents.sublist(2) : <SevenCardPlayer>[];

    return Stack(
      children: [
        Column(
          children: [
            // 베팅 단계 표시
            _buildPotInfo(state, l10n, sizes),
            // AI 플레이어들 + 중앙 팟 영역
            Expanded(
              child: Row(
                children: [
                  // 왼쪽 AI 2명
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: leftOpponents.map((opponent) =>
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: _buildOpponentArea(opponent, state, l10n, controller, sizes),
                          ),
                        )
                      ).toList(),
                    ),
                  ),
                  // 중앙 팟 영역
                  _buildCenterPotArea(state, l10n, sizes),
                  // 오른쪽 AI 2명
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: rightOpponents.map((opponent) =>
                        Flexible(
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: _buildOpponentArea(opponent, state, l10n, controller, sizes),
                          ),
                        )
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
            // 플레이어 영역
            _buildPlayerArea(controller, state, l10n, sizes),
            // 액션 버튼 (항상 표시)
            _buildActionButtons(controller, state, l10n, sizes),
          ],
        ),
        // 라운드 전환 오버레이
        if (controller.isRoundTransitioning)
          _buildRoundTransitionOverlay(controller),
      ],
    );
  }

  Widget _buildRoundTransitionOverlay(SevenCardController controller) {
    return GestureDetector(
      onTap: () => controller.skipTransition(),
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Column(
          children: [
            const Spacer(),
            // 하단에 작게 표시
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.blue[800],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.info_outline, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      getRoundTransitionMessage(context, controller.transitionRound),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.secondsCount(controller.transitionCountdown),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 180), // 버튼 영역 위에 위치
          ],
        ),
      ),
    );
  }

  Widget _buildPotInfo(SevenCardState state, AppLocalizations l10n, _ResponsiveSizes sizes) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPhaseIndicator(state, l10n),
        ],
      ),
    );
  }

  Widget _buildPhaseIndicator(SevenCardState state, AppLocalizations l10n) {
    String phaseName;
    switch (state.phase) {
      case SevenCardPhase.betting1:
        phaseName = '${l10n.betting} 1';
        break;
      case SevenCardPhase.betting2:
        phaseName = '${l10n.betting} 2';
        break;
      case SevenCardPhase.betting3:
        phaseName = '${l10n.betting} 3';
        break;
      case SevenCardPhase.betting4:
        phaseName = '${l10n.betting} 4';
        break;
      default:
        phaseName = '';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        phaseName,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCenterPotArea(SevenCardState state, AppLocalizations l10n, _ResponsiveSizes sizes) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 팟 (칩 모양) - 세로 배치
          Container(
            padding: EdgeInsets.symmetric(horizontal: sizes.potIconSize * 0.4, vertical: sizes.potIconSize * 0.25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber[700]!, Colors.amber[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.amber[300]!, width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 칩 아이콘
                Container(
                  width: sizes.potIconSize,
                  height: sizes.potIconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.red[400]!, Colors.red[700]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '\$',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: sizes.potIconSize * 0.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // 팟 금액
                Text(
                  '${state.pot}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sizes.potFontSize,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(
                        color: Colors.black54,
                        blurRadius: 2,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // 현재 베팅 금액
          if (state.currentBetAmount > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${l10n.currentBet}: ${state.currentBetAmount}',
                style: TextStyle(color: Colors.white70, fontSize: sizes.infoFontSize),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOpponentArea(SevenCardPlayer opponent, SevenCardState state, AppLocalizations l10n, SevenCardController controller, _ResponsiveSizes sizes) {
    final isCurrentPlayer = state.currentPlayerIndex == opponent.id;
    final isFolded = opponent.isFolded;
    final isBoss = state.bettingRoundStarterIndex == opponent.id && !isFolded;

    return Container(
      padding: EdgeInsets.all(sizes.screenHeight < 700 ? 4 : 6),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? Colors.amber.withValues(alpha: 0.3) : Colors.black26,
        borderRadius: BorderRadius.circular(6),
        border: isCurrentPlayer ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 보스 표시
          if (isBoss)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.black, size: sizes.badgeFontSize),
                  SizedBox(width: 2),
                  Text(
                    'BOSS',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: sizes.badgeFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          // 이름과 총 베팅액
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                getPlayerName(context, opponent.id),
                style: TextStyle(
                  color: isFolded ? Colors.grey : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: sizes.nameFontSize,
                ),
              ),
              if (!isFolded) ...[
                const SizedBox(width: 2),
                Text(
                  '(${SevenCardPlayer.maxBettingActions - opponent.bettingActionsInRound})',
                  style: TextStyle(
                    color: opponent.canBet ? Colors.lightGreenAccent : Colors.red,
                    fontSize: sizes.infoFontSize,
                  ),
                ),
              ],
            ],
          ),
          Text(
            l10n.totalBetAmount(opponent.totalBetInGame),
            style: TextStyle(
              color: isFolded ? Colors.grey : Colors.amber,
              fontSize: sizes.infoFontSize,
            ),
          ),
          // 베팅 정보 (액션 + 금액)
          if (opponent.lastAction != BettingAction.none)
            Text(
              getBettingActionText(context, opponent.lastAction, opponent.currentBet),
              style: TextStyle(
                color: _getBettingActionColor(opponent.lastAction),
                fontSize: sizes.infoFontSize,
                fontWeight: FontWeight.bold,
              ),
            )
          else if (opponent.currentBet > 0)
            Text(
              l10n.bettingAmount(opponent.currentBet),
              style: TextStyle(
                color: Colors.green,
                fontSize: sizes.infoFontSize,
              ),
            ),
          if (isFolded)
            Text(
              l10n.folded,
              style: TextStyle(color: Colors.red, fontSize: sizes.infoFontSize),
            ),
          const SizedBox(height: 2),
          // 카드 표시 (한 줄로: 히든 + 오픈 + 강도)
          if (isFolded) ...[
            if (opponent.hand.isNotEmpty)
              Opacity(
                opacity: 0.5,
                child: Wrap(
                  spacing: 1,
                  children: opponent.hand.map((card) => _buildSmallCardBackForAI(sizes)).toList(),
                ),
              ),
          ] else ...[
            Wrap(
              spacing: 1,
              alignment: WrapAlignment.center,
              children: [
                // 전환 중이면 이전 카드 수만큼만 표시
                if (controller.isRoundTransitioning && controller.cardCountBeforeTransition > 0) ...[
                  ...opponent.hand.take(controller.cardCountBeforeTransition).map((card) {
                    final isOpen = opponent.openCards.contains(card);
                    return isOpen ? _buildSmallCard(card, sizes) : _buildSmallCardBackForAI(sizes);
                  }),
                ] else ...[
                  // 히든 카드 (뒷면 표시)
                  ...opponent.hiddenCards.map((card) => _buildSmallCardBackForAI(sizes)),
                  // 오픈 카드
                  ...opponent.openCards.map((card) => _buildSmallCard(card, sizes)),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallCard(PlayingCard card, _ResponsiveSizes sizes) {
    // 조커 처리
    if (card.isJoker) {
      return Container(
        width: sizes.aiCardWidth,
        height: sizes.aiCardHeight,
        margin: const EdgeInsets.all(1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: Colors.purple),
        ),
        child: Center(
          child: Text(
            'JK',
            style: TextStyle(color: Colors.purple, fontSize: sizes.aiFontSize, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankStr = _getRankString(card.rank);

    return Container(
      width: sizes.aiCardWidth,
      height: sizes.aiCardHeight,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rankStr,
            style: TextStyle(color: color, fontSize: sizes.aiFontSize, fontWeight: FontWeight.bold),
          ),
          Text(
            suitSymbol,
            style: TextStyle(color: color, fontSize: sizes.aiFontSize),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallCardBackForAI(_ResponsiveSizes sizes) {
    return Container(
      width: sizes.aiCardWidth,
      height: sizes.aiCardHeight,
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.blue[900]!, width: 1),
      ),
      child: Center(
        child: Container(
          width: sizes.aiCardWidth * 0.6,
          height: sizes.aiCardHeight * 0.65,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue[300]!, width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerArea(SevenCardController controller, SevenCardState state, AppLocalizations l10n, _ResponsiveSizes sizes) {
    final player = state.humanPlayer;
    final isCurrentPlayer = state.currentPlayerIndex == 0;
    final isBoss = state.bettingRoundStarterIndex == 0;
    final isSmall = sizes.screenHeight < 700;

    return Container(
      padding: EdgeInsets.all(isSmall ? 6 : 10),
      decoration: BoxDecoration(
        color: isCurrentPlayer ? Colors.amber.withValues(alpha: 0.2) : Colors.black26,
        border: isCurrentPlayer ? const Border(top: BorderSide(color: Colors.amber, width: 2)) : null,
      ),
      child: Column(
        children: [
          // 플레이어 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person, color: Colors.amber, size: isSmall ? 16 : 20),
                  const SizedBox(width: 4),
                  Text(
                    l10n.player,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: sizes.nameFontSize + 2),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${SevenCardPlayer.maxBettingActions - player.bettingActionsInRound})',
                    style: TextStyle(
                      color: player.canBet ? Colors.lightGreenAccent : Colors.red,
                      fontSize: sizes.infoFontSize,
                    ),
                  ),
                  // 보스 표시
                  if (isBoss) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.black, size: sizes.badgeFontSize + 2),
                          SizedBox(width: 2),
                          Text(
                            'BOSS',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: sizes.badgeFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                l10n.totalBetAmount(player.totalBetInGame),
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: sizes.nameFontSize),
              ),
            ],
          ),
          SizedBox(height: isSmall ? 2 : 4),
          // 플레이어 카드 (한 줄로 표시: 오픈카드 + 히든카드 + 족보)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 다이한 경우 모든 카드 뒷면 표시
                if (player.isFolded) ...[
                  ...player.hand.map((card) => _buildPlayerCardBack(sizes)),
                ] else ...[
                  // 전환 중이면 이전 카드 수만큼만 표시
                  if (controller.isRoundTransitioning && controller.cardCountBeforeTransition > 0) ...[
                    ...player.hand.take(controller.cardCountBeforeTransition).map((card) {
                      final isOpen = player.openCards.contains(card);
                      return _buildPlayerCard(card, isOpen, sizes);
                    }),
                  ] else ...[
                    // 오픈 카드
                    ...player.openCards.map((card) => _buildPlayerCard(card, true, sizes)),
                    // 히든 카드
                    ...player.hiddenCards.map((card) => _buildPlayerCard(card, false, sizes)),
                  ],
                ],
                // 족보 표시 (다이 상태면 "다이" 표시)
                if (player.isFolded)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: EdgeInsets.symmetric(horizontal: isSmall ? 6 : 8, vertical: isSmall ? 4 : 5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      l10n.fold,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: sizes.nameFontSize,
                      ),
                    ),
                  )
                else if (player.allCardsPokerHand != null)
                  Container(
                    margin: const EdgeInsets.only(left: 4),
                    padding: EdgeInsets.symmetric(horizontal: isSmall ? 6 : 8, vertical: isSmall ? 4 : 5),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      getHandRankDisplayName(context, player.allCardsPokerHand),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: sizes.nameFontSize,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(PlayingCard card, bool isOpen, _ResponsiveSizes sizes) {
    // 조커 처리
    if (card.isJoker) {
      return Container(
        width: sizes.playerCardWidth,
        height: sizes.playerCardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: isOpen ? Colors.amber : Colors.grey, width: isOpen ? 2 : 1),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber[700], size: sizes.playerFontSize + 2),
              Text('JK', style: TextStyle(fontSize: sizes.playerFontSize - 2, fontWeight: FontWeight.bold, color: Colors.purple)),
            ],
          ),
        ),
      );
    }

    final color = (card.suit == Suit.heart || card.suit == Suit.diamond)
        ? Colors.red
        : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankText = _getRankString(card.rank);

    return Container(
      width: sizes.playerCardWidth,
      height: sizes.playerCardHeight,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isOpen ? Colors.amber : Colors.grey[400]!,
          width: isOpen ? 2 : 1,
        ),
        boxShadow: isOpen ? [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.5),
            blurRadius: 3,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            rankText,
            style: TextStyle(
              color: color,
              fontSize: sizes.playerFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            suitSymbol,
            style: TextStyle(
              color: color,
              fontSize: sizes.playerFontSize - 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCardBack(_ResponsiveSizes sizes) {
    return Opacity(
      opacity: 0.5,
      child: Container(
        width: sizes.playerCardWidth,
        height: sizes.playerCardHeight,
        margin: const EdgeInsets.symmetric(horizontal: 1),
        decoration: BoxDecoration(
          color: Colors.blue[800],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue[900]!, width: 1),
        ),
        child: Center(
          child: Container(
            width: sizes.playerCardWidth * 0.6,
            height: sizes.playerCardHeight * 0.65,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue[300]!, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(SevenCardController controller, SevenCardState state, AppLocalizations l10n, _ResponsiveSizes sizes) {
    final isMyTurn = controller.isHumanTurn;
    final availableActions = isMyTurn ? state.getAvailableActions() : <String>[];
    final isSmall = sizes.screenHeight < 700;
    final recommendedAction = _showHint && isMyTurn ? controller.getRecommendedAction() : null;

    // 버튼 활성화 여부 확인 헬퍼
    VoidCallback? getAction(String actionName, VoidCallback action) {
      return isMyTurn && availableActions.contains(actionName) ? action : null;
    }

    return Container(
      padding: EdgeInsets.all(isSmall ? 4 : 8),
      color: Colors.black38,
      child: Column(
        children: [
          // AI 추천 표시
          if (_showHint && isMyTurn && recommendedAction != null) ...[
            Container(
              margin: EdgeInsets.only(bottom: isSmall ? 4 : 8),
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
                    '${l10n.aiRecommendation}: ${getBettingActionName(context, recommendedAction.action)}${recommendedAction.amount > 0 ? ' (${recommendedAction.amount})' : ''}',
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
          // 상단 행: 삥, 콜, 따당, 다이
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 삥 (기본 판돈 - 보스만)
              _buildBetButton(
                label: l10n.betPing,
                amount: state.getBingAmount(),
                color: Colors.green,
                onPressed: getAction('bing', () => controller.humanBing()),
                sizes: sizes,
              ),
              // 콜
              _buildBetButton(
                label: l10n.betCall,
                amount: state.getCallAmount(),
                color: Colors.cyan,
                onPressed: getAction('call', () => controller.humanCall()),
                sizes: sizes,
              ),
              // 따당 (2배)
              _buildBetButton(
                label: l10n.betDdadang,
                amount: state.getDdadangAmount(),
                color: Colors.orange,
                onPressed: getAction('ddadang', () => controller.humanDdadang()),
                sizes: sizes,
              ),
              // 다이 (폴드)
              _buildBetButton(
                label: l10n.betDie,
                amount: null,
                color: Colors.red,
                onPressed: getAction('die', () => controller.humanDie()),
                sizes: sizes,
              ),
            ],
          ),
          SizedBox(height: isSmall ? 4 : 6),
          // 하단 행: 체크, 쿼터, 하프, 풀
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 체크 (보스만)
              _buildBetButton(
                label: l10n.betCheck,
                amount: null,
                color: Colors.blue,
                onPressed: getAction('check', () => controller.humanCheck()),
                sizes: sizes,
              ),
              // 쿼터 (25%)
              _buildBetButton(
                label: l10n.betQuarter,
                amount: state.getQuarterAmount(),
                color: Colors.teal,
                onPressed: getAction('quarter', () => controller.humanQuarter()),
                sizes: sizes,
              ),
              // 하프 (50%)
              _buildBetButton(
                label: l10n.betHalf,
                amount: state.getHalfAmount(),
                color: Colors.indigo,
                onPressed: getAction('half', () => controller.humanHalf()),
                sizes: sizes,
              ),
              // 풀 (100%)
              _buildBetButton(
                label: l10n.betFull,
                amount: state.getFullAmount(),
                color: Colors.purple,
                onPressed: getAction('full', () => controller.humanFull()),
                sizes: sizes,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBetButton({
    required String label,
    required int? amount,
    required Color color,
    required VoidCallback? onPressed,
    required _ResponsiveSizes sizes,
  }) {
    final isSmall = sizes.screenHeight < 700;
    final buttonFontSize = isSmall ? 12.0 : 14.0;
    final amountFontSize = isSmall ? 9.0 : 11.0;
    final verticalPadding = isSmall ? 6.0 : 10.0;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 2 : 4),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: onPressed != null ? color : Colors.grey,
            padding: EdgeInsets.symmetric(vertical: verticalPadding),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.white, fontSize: buttonFontSize, fontWeight: FontWeight.bold),
              ),
              if (amount != null)
                Text(
                  '$amount',
                  style: TextStyle(color: Colors.white70, fontSize: amountFontSize),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameEndScreen(SevenCardController controller, SevenCardState state, AppLocalizations l10n) {
    final winner = state.winnerId != null ? state.players[state.winnerId!] : null;
    final statsService = Provider.of<SevenCardStatsService>(context, listen: false);
    final bonusInfo = state.bonusInfo;

    // 보너스 핸드 발생 시 폭죽 애니메이션 트리거
    if (bonusInfo != null && !_showFireworks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_showFireworks) {
          _triggerFireworks();
        }
      });
    }

    // 통계 기록 (한 번만)
    if (!_statsRecorded && winner != null) {
      _statsRecorded = true;
      final playerScores = <int, int>{};
      for (final player in state.players) {
        if (bonusInfo != null) {
          // 보너스 핸드: 승자는 totalWinnings, 패자는 -베팅액-보너스
          if (player.id == winner.id) {
            playerScores[player.id] = bonusInfo.totalWinnings - player.totalBetInGame;
          } else {
            playerScores[player.id] = -player.totalBetInGame - bonusInfo.bonusAmount;
          }
        } else if (player.id == winner.id) {
          // 일반 승리: +pot - 자신의 베팅액
          playerScores[player.id] = state.pot - player.totalBetInGame;
        } else {
          // 패자: -베팅액
          playerScores[player.id] = -player.totalBetInGame;
        }
      }
      statsService.recordGameResult(winnerId: winner.id, playerScores: playerScores);
    }

    return Consumer<SevenCardStatsService>(
      builder: (context, stats, child) {
        return Stack(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 보너스 핸드 표시
                    if (bonusInfo != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.amber[700]!, Colors.amber[400]!],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '🎉 ${l10n.bonusHand}',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            Text(
                              getHandRankName(context, bonusInfo.handRank),
                              style: TextStyle(color: Colors.red[900], fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else
                      const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                    if (bonusInfo == null) const SizedBox(height: 12),
                    () {
                      final isPlayerWinner = winner?.id == 0;
                      return Text(
                        isPlayerWinner ? l10n.victory : l10n.defeat,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isPlayerWinner ? Colors.green : Colors.red,
                        ),
                      );
                    }(),
                    const SizedBox(height: 4),
                    Text(
                      winner != null ? '${getPlayerName(context, winner.id)} ${l10n.wins}!' : l10n.gameEnd,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    if (winner?.pokerHand != null && bonusInfo == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        getHandRankName(context, winner!.pokerHand!.rank),
                        style: const TextStyle(fontSize: 16, color: Colors.green),
                      ),
                    ],
                    const SizedBox(height: 8),
                    // 보너스 핸드 수익 정보
                    if (bonusInfo != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBonusChip(l10n.pot, '+${state.pot}', Colors.green),
                          const SizedBox(width: 8),
                          _buildBonusChip(l10n.bonus, '+${bonusInfo.bonusAmount * 4}', Colors.amber),
                          const SizedBox(width: 8),
                          _buildBonusChip(l10n.total, '+${bonusInfo.totalWinnings}', Colors.blue),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          l10n.otherPlayersLose(bonusInfo.bonusAmount),
                          style: const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ] else
                      Text(
                        '${l10n.pot}: ${state.pot}${winner != null ? ' (+${state.pot - winner.totalBetInGame})' : ''}',
                        style: const TextStyle(fontSize: 16),
                      ),
                const SizedBox(height: 16),
                // 누적 통계 테이블
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      // 테이블 헤더
                      Row(
                        children: [
                          Expanded(flex: 3, child: Text(l10n.player, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 2, child: Text(l10n.thisGame, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 2, child: Text(l10n.winLoss, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          Expanded(flex: 2, child: Text(l10n.cumulative, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                      const Divider(height: 8),
                      // 플레이어별 통계
                      ...state.players.map((player) {
                        final playerStats = stats.getPlayerStats(player.id);
                        int gameScore;
                        if (bonusInfo != null) {
                          if (player.id == winner?.id) {
                            gameScore = bonusInfo.totalWinnings - player.totalBetInGame;
                          } else {
                            gameScore = -player.totalBetInGame - bonusInfo.bonusAmount;
                          }
                        } else if (player.id == winner?.id) {
                          gameScore = state.pot - player.totalBetInGame;
                        } else {
                          gameScore = -player.totalBetInGame;
                        }
                        final isWinner = player.id == winner?.id;
                        final isBonusWinner = bonusInfo != null && player.id == bonusInfo.winner.id;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    if (isBonusWinner) const Icon(Icons.star, color: Colors.amber, size: 14),
                                    if (isWinner && !isBonusWinner) const Icon(Icons.emoji_events, color: Colors.amber, size: 14),
                                    if (isWinner) const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        getPlayerName(context, player.id),
                                        style: TextStyle(
                                          fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                                          color: player.isFolded ? Colors.grey : Colors.black,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${gameScore >= 0 ? '+' : ''}$gameScore',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: gameScore >= 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${playerStats?.wins ?? 0}/${playerStats?.losses ?? 0}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '${playerStats?.totalScore ?? 0}',
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    color: (playerStats?.totalScore ?? 0) >= 0 ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // 버튼들
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 결과 확인 버튼
                    ElevatedButton.icon(
                      onPressed: () => _showDetailedResults(context, controller, state),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: Text(l10n.viewResults),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 새 게임 버튼
                    ElevatedButton.icon(
                      onPressed: () {
                        _statsRecorded = false;
                        controller.startNewGame();
                      },
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n.newGame),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // 폭죽 애니메이션 오버레이
        if (_showFireworks)
          AnimatedBuilder(
            animation: _fireworksAnimation,
            builder: (context, child) {
              return IgnorePointer(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _SevenCardFireworksPainter(_fireworksAnimation.value),
                ),
              );
            },
          ),
          ],
        );
      },
    );
  }

  Widget _buildBonusChip(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showDetailedResults(BuildContext context, SevenCardController controller, SevenCardState state) {
    final l10n = AppLocalizations.of(context)!;
    // 활성 플레이어와 다이한 플레이어 분리
    final activePlayers = state.players.where((p) => !p.isFolded).toList();
    final foldedPlayers = state.players.where((p) => p.isFolded).toList();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.blue[900],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.amber, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[800],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.finalResults,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // 활성 플레이어 (카드 표시)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                child: Column(
                  children: activePlayers.map((player) =>
                    _buildActivePlayerResultCard(player, controller, state)
                  ).toList(),
                ),
              ),
              // 다이한 플레이어 (카드 뒷면만)
              if (foldedPlayers.isNotEmpty)
                Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.foldedSection,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: foldedPlayers.map((player) =>
                          _buildFoldedPlayerResult(player, controller)
                        ).toList(),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivePlayerResultCard(SevenCardPlayer player, SevenCardController controller, SevenCardState state) {
    final isWinner = player.id == state.winnerId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isWinner ? Colors.amber.withValues(alpha: 0.2) : Colors.black26,
        borderRadius: BorderRadius.circular(10),
        border: isWinner ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 플레이어 이름과 족보
          Row(
            children: [
              if (isWinner)
                const Icon(Icons.emoji_events, color: Colors.amber, size: 18),
              if (isWinner)
                const SizedBox(width: 4),
              Text(
                getPlayerName(context, player.id),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (player.pokerHand != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    getHandRankDisplayName(context, player.pokerHand),
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.bettingAmount(player.totalBetInGame),
                style: const TextStyle(color: Colors.amber, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 카드 표시 (족보 핵심 카드만 하이라이트, 나머지는 흐리게)
          Builder(
            builder: (context) {
              final pokerHand = player.pokerHand;
              final handCards = _getHandCoreCards(player.hand, pokerHand);
              final otherCards = player.hand.where((c) =>
                !handCards.any((h) => h.suit == c.suit && h.rank == c.rank)
              ).toList();

              return Wrap(
                spacing: 3,
                runSpacing: 3,
                children: [
                  // 족보 핵심 카드 (하이라이트)
                  ...handCards.map((card) => _buildResultCard(card, true, false)),
                  // 나머지 카드 (흐리게)
                  ...otherCards.map((card) => _buildResultCard(card, false, true)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFoldedPlayerResult(SevenCardPlayer player, SevenCardController controller) {
    return Builder(
      builder: (context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black38,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Text(
              getPlayerName(context, player.id),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            // 카드 뒷면 표시
            ...List.generate(player.hand.length, (index) => _buildSmallCardBack()),
            const Spacer(),
            Text(
              AppLocalizations.of(context)!.bettingAmount(player.totalBetInGame),
              style: const TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallCardBack() {
    return Container(
      width: 20,
      height: 28,
      margin: const EdgeInsets.only(right: 2),
      decoration: BoxDecoration(
        color: Colors.blue[800],
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: Colors.blue[900]!, width: 1),
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 18,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue[300]!, width: 1),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(PlayingCard card, bool isHighlighted, [bool isDimmed = false]) {
    if (card.isJoker) {
      return Opacity(
        opacity: isDimmed ? 0.4 : 1.0,
        child: Container(
          width: 36,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: isHighlighted ? Colors.amber : Colors.purple,
              width: isHighlighted ? 2 : 1,
            ),
          ),
          child: const Center(
            child: Text(
              'JK',
              style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }

    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankStr = _getRankString(card.rank);

    return Opacity(
      opacity: isDimmed ? 0.4 : 1.0,
      child: Container(
        width: 36,
        height: 50,
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.amber[50] : Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isHighlighted ? Colors.amber : Colors.grey,
            width: isHighlighted ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              rankStr,
              style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            Text(
              suitSymbol,
              style: TextStyle(color: color, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  String _getSuitSymbol(Suit? suit) {
    switch (suit) {
      case Suit.spade:
        return '♠';
      case Suit.heart:
        return '♥';
      case Suit.diamond:
        return '♦';
      case Suit.club:
        return '♣';
      default:
        return '';
    }
  }

  String _getRankString(Rank? rank) {
    switch (rank) {
      case Rank.ace:
        return 'A';
      case Rank.two:
        return '2';
      case Rank.three:
        return '3';
      case Rank.four:
        return '4';
      case Rank.five:
        return '5';
      case Rank.six:
        return '6';
      case Rank.seven:
        return '7';
      case Rank.eight:
        return '8';
      case Rank.nine:
        return '9';
      case Rank.ten:
        return '10';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
      default:
        return '';
    }
  }

  /// 족보 핵심 카드 추출 (키커 제외)
  List<PlayingCard> _getHandCoreCards(List<PlayingCard> hand, PokerHand? pokerHand) {
    if (pokerHand == null) return [];

    final bestFive = pokerHand.bestFive;
    final rank = pokerHand.rank;

    // 랭크별 카드 그룹화
    final groups = <int, List<PlayingCard>>{};
    for (final card in bestFive) {
      final rankValue = card.rankValue;
      groups[rankValue] = (groups[rankValue] ?? [])..add(card);
    }

    switch (rank) {
      case HandRank.onePair:
        // 원페어: 페어 2장만
        final pairCards = groups.entries.firstWhere((e) => e.value.length == 2).value;
        return pairCards;

      case HandRank.twoPair:
        // 투페어: 두 페어 4장만
        final pairs = groups.entries.where((e) => e.value.length == 2).expand((e) => e.value).toList();
        // 랭크 내림차순 정렬
        pairs.sort((a, b) => b.rankValue.compareTo(a.rankValue));
        return pairs;

      case HandRank.triple:
        // 트리플: 트리플 3장만
        final tripleCards = groups.entries.firstWhere((e) => e.value.length == 3).value;
        return tripleCards;

      case HandRank.fourOfAKind:
        // 포카드: 포카드 4장만
        final fourCards = groups.entries.firstWhere((e) => e.value.length == 4).value;
        return fourCards;

      case HandRank.fullHouse:
        // 풀하우스: 트리플 3장 + 페어 2장 = 5장 모두
        final tripleCards = groups.entries.firstWhere((e) => e.value.length == 3).value;
        final pairCards = groups.entries.firstWhere((e) => e.value.length == 2).value;
        return [...tripleCards, ...pairCards];

      case HandRank.straight:
      case HandRank.backStraight:
      case HandRank.mountain:
      case HandRank.flush:
      case HandRank.straightFlush:
      case HandRank.backStraightFlush:
      case HandRank.royalStraightFlush:
        // 스트레이트/플러시 계열: 5장 모두
        final sorted = List<PlayingCard>.from(bestFive);
        sorted.sort((a, b) => b.rankValue.compareTo(a.rankValue));
        return sorted;

      case HandRank.highCard:
        // 하이카드: 가장 높은 카드 1장만
        final sorted = List<PlayingCard>.from(bestFive);
        sorted.sort((a, b) => b.rankValue.compareTo(a.rankValue));
        return [sorted.first];
    }
  }

  /// 베팅 액션을 로컬라이즈된 텍스트로 변환
  String _getBettingActionText(BuildContext context, BettingAction action, int amount) {
    return getBettingActionText(context, action, amount);
  }

  /// 베팅 액션별 색상
  Color _getBettingActionColor(BettingAction action) {
    switch (action) {
      case BettingAction.bing:
        return Colors.green;
      case BettingAction.check:
        return Colors.blue;
      case BettingAction.call:
        return Colors.cyan;
      case BettingAction.ddadang:
        return Colors.orange;
      case BettingAction.quarter:
        return Colors.teal;
      case BettingAction.half:
        return Colors.indigo;
      case BettingAction.full:
        return Colors.purple;
      case BettingAction.die:
        return Colors.red;
      case BettingAction.none:
        return Colors.grey;
    }
  }
}

/// 폭죽 애니메이션 페인터
class _SevenCardFireworksPainter extends CustomPainter {
  final double progress;

  _SevenCardFireworksPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final positions = [
      Offset(0.2, 0.3),
      Offset(0.5, 0.2),
      Offset(0.8, 0.35),
      Offset(0.3, 0.5),
      Offset(0.7, 0.45),
      Offset(0.15, 0.6),
      Offset(0.85, 0.55),
    ];

    final colors = [
      Colors.red,
      Colors.amber,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.pink,
      Colors.orange,
    ];

    for (int i = 0; i < positions.length; i++) {
      final center = Offset(
        positions[i].dx * size.width,
        positions[i].dy * size.height,
      );

      final color = colors[i % colors.length];
      final particleProgress = (progress - (i * 0.1)).clamp(0.0, 1.0);

      if (particleProgress > 0) {
        _drawFirework(canvas, center, color, particleProgress);
      }
    }
  }

  void _drawFirework(Canvas canvas, Offset center, Color color, double progress) {
    final paint = Paint()
      ..color = color.withValues(alpha: (1.0 - progress) * 0.8)
      ..style = PaintingStyle.fill;

    final numParticles = 12;
    final maxRadius = 80.0 * progress;

    for (int i = 0; i < numParticles; i++) {
      final angle = (i / numParticles) * 2 * math.pi;
      final radius = maxRadius * (0.5 + 0.5 * progress);
      final particleSize = 4.0 * (1.0 - progress * 0.5);

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }

    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: (1.0 - progress) * 0.6)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 8; i++) {
      final angle = (i / 8) * 2 * math.pi + progress * 2;
      final radius = maxRadius * 0.7;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      canvas.drawCircle(Offset(x, y), 2.0, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SevenCardFireworksPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
