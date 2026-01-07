import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../models/card.dart';
import '../../models/hi_lo/hi_lo_state.dart';
import '../../services/hi_lo/hi_lo_controller.dart';
import '../../services/hi_lo/hi_lo_stats_service.dart';
import '../../widgets/banner_ad_widget.dart';

/// 반응형 사이즈 헬퍼
class _ResponsiveSizes {
  final double screenHeight;
  final double screenWidth;

  late final double aiCardWidth;
  late final double aiCardHeight;
  late final double aiFontSize;
  late final double playerCardWidth;
  late final double playerCardHeight;
  late final double playerFontSize;
  late final double nameFontSize;
  late final double infoFontSize;
  late final double badgeFontSize;
  late final double potIconSize;
  late final double potFontSize;

  _ResponsiveSizes(this.screenHeight, this.screenWidth) {
    final isSmall = screenHeight < 700;
    final isMedium = screenHeight >= 700 && screenHeight < 800;

    aiCardWidth = isSmall ? 26 : (isMedium ? 30 : 32);
    aiCardHeight = isSmall ? 36 : (isMedium ? 40 : 44);
    aiFontSize = isSmall ? 9 : (isMedium ? 10 : 11);

    playerCardWidth = isSmall ? 32 : (isMedium ? 36 : 40);
    playerCardHeight = isSmall ? 46 : (isMedium ? 50 : 56);
    playerFontSize = isSmall ? 11 : (isMedium ? 13 : 14);

    nameFontSize = isSmall ? 10 : (isMedium ? 11 : 12);
    infoFontSize = isSmall ? 8 : (isMedium ? 9 : 10);
    badgeFontSize = isSmall ? 8 : (isMedium ? 9 : 10);

    potIconSize = isSmall ? 32 : (isMedium ? 38 : 44);
    potFontSize = isSmall ? 16 : (isMedium ? 20 : 24);
  }
}

class HiLoGameScreen extends StatefulWidget {
  const HiLoGameScreen({super.key});

  @override
  State<HiLoGameScreen> createState() => _HiLoGameScreenState();
}

class _HiLoGameScreenState extends State<HiLoGameScreen> {
  bool _statsRecorded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<HiLoController>(
      builder: (context, controller, child) {
        final state = controller.state;

        return Scaffold(
          backgroundColor: Colors.purple[900],
          appBar: AppBar(
            backgroundColor: Colors.purple[800],
            title: Text(l10n.hiLoTitle),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: _buildGameArea(controller, state, l10n),
                ),
                const BannerAdWidget(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameArea(HiLoController controller, HiLoState state, AppLocalizations l10n) {
    if (state.phase == HiLoPhase.waiting) {
      return _buildWaitingScreen(controller, l10n);
    } else if (state.phase == HiLoPhase.selectOpen) {
      return _buildSelectOpenScreen(controller, state, l10n);
    } else if (state.phase == HiLoPhase.selectHiLo) {
      return _buildSelectHiLoScreen(controller, state, l10n);
    } else if (state.phase == HiLoPhase.showdown) {
      return _buildShowdownScreen(controller, state, l10n);
    } else if (state.phase == HiLoPhase.gameEnd) {
      return _buildGameEndScreen(controller, state, l10n);
    } else {
      return _buildPlayingScreen(controller, state, l10n);
    }
  }

  Widget _buildSelectOpenScreen(HiLoController controller, HiLoState state, AppLocalizations l10n) {
    final player = state.humanPlayer;
    final isMyTurn = state.currentPlayerIndex == 0;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black26,
          child: Column(
            children: [
              const Icon(Icons.visibility, color: Colors.amber, size: 40),
              const SizedBox(height: 8),
              const Text(
                '공개할 카드를 선택하세요',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '선택한 카드가 상대에게 공개됩니다',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
        const Spacer(),
        if (isMyTurn)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: player.hand.asMap().entries.map((entry) {
                final index = entry.key;
                final card = entry.value;
                return _buildSelectableCard(card, index, controller);
              }).toList(),
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                CircularProgressIndicator(color: Colors.amber),
                SizedBox(height: 16),
                Text(
                  'AI가 카드를 선택하고 있습니다...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        const Spacer(),
      ],
    );
  }

  Widget _buildSelectableCard(PlayingCard card, int index, HiLoController controller) {
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.amber, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(2, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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

  Widget _buildWaitingScreen(HiLoController controller, AppLocalizations l10n) {
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

  /// 하이/로우/스윙 선택 화면
  Widget _buildSelectHiLoScreen(HiLoController controller, HiLoState state, AppLocalizations l10n) {
    final isMyTurn = state.currentPlayerIndex == 0;
    final player = state.humanPlayer;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black26,
          child: Column(
            children: [
              const Icon(Icons.swap_vert, color: Colors.amber, size: 40),
              const SizedBox(height: 8),
              Text(
                l10n.selectHiLo,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.selectHiLoDesc,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // 플레이어 카드 및 족보 표시
        _buildHiLoPlayerInfo(player, controller),
        const Spacer(),
        if (isMyTurn)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildHiLoButton(
                  label: l10n.hi,
                  icon: Icons.arrow_upward,
                  color: Colors.red,
                  onTap: () => controller.humanSelectHiLo(HiLoChoice.hi),
                ),
                _buildHiLoButton(
                  label: l10n.lo,
                  icon: Icons.arrow_downward,
                  color: Colors.blue,
                  onTap: () => controller.humanSelectHiLo(HiLoChoice.lo),
                ),
                _buildHiLoButton(
                  label: l10n.swing,
                  icon: Icons.swap_vert,
                  color: Colors.purple,
                  onTap: () => controller.humanSelectHiLo(HiLoChoice.swing),
                ),
              ],
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              children: [
                CircularProgressIndicator(color: Colors.amber),
                SizedBox(height: 16),
                Text(
                  'AI가 선택하고 있습니다...',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        // 다른 플레이어들의 선택 현황
        _buildOtherPlayersHiLoStatus(state, l10n),
        const Spacer(),
      ],
    );
  }

  /// 쇼다운 화면 - 모든 플레이어의 선택 표시
  Widget _buildShowdownScreen(HiLoController controller, HiLoState state, AppLocalizations l10n) {
    final activePlayers = state.players.where((p) => p.isActive).toList();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.black26,
          child: Column(
            children: [
              const Icon(Icons.visibility, color: Colors.amber, size: 40),
              const SizedBox(height: 8),
              Text(
                l10n.showdownTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.showdownDesc,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // 모든 플레이어 선택 현황
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: activePlayers.map((player) {
                return _buildShowdownPlayerCard(player, controller, l10n);
              }).toList(),
            ),
          ),
        ),
        // 결과 보기 버튼
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => controller.proceedToGameEnd(),
              icon: const Icon(Icons.emoji_events, size: 20),
              label: Text(l10n.viewResults),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 쇼다운 플레이어 카드
  Widget _buildShowdownPlayerCard(HiLoPlayer player, HiLoController controller, AppLocalizations l10n) {
    final isHuman = player.id == 0;
    final choice = player.hiLoChoice;
    final hiHand = player.pokerHand;
    final loHand = player.lowHand;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHuman ? Colors.amber.withValues(alpha: 0.2) : Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: isHuman ? Border.all(color: Colors.amber, width: 2) : null,
      ),
      child: Column(
        children: [
          // 이름과 선택
          Row(
            children: [
              if (isHuman)
                const Icon(Icons.person, color: Colors.amber, size: 18),
              if (isHuman) const SizedBox(width: 4),
              Text(
                player.name,
                style: TextStyle(
                  color: isHuman ? Colors.amber : Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              // 선택 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getHiLoChoiceColor(choice),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      choice == HiLoChoice.hi ? Icons.arrow_upward :
                      choice == HiLoChoice.lo ? Icons.arrow_downward :
                      Icons.swap_vert,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getHiLoChoiceText(choice, l10n),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // 카드 표시
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: player.hand.map((card) => _buildShowdownCard(card)).toList(),
            ),
          ),
          const SizedBox(height: 8),
          // 족보 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 하이 족보 (하이 또는 스윙 선택한 경우)
              if (choice == HiLoChoice.hi || choice == HiLoChoice.swing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Column(
                    children: [
                      const Text('Hi', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 11)),
                      Text(
                        hiHand != null ? controller.getHandRankDisplayName(hiHand) : '-',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              // 로우 족보 (로우 또는 스윙 선택한 경우)
              if (choice == HiLoChoice.lo || choice == HiLoChoice.swing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Column(
                    children: [
                      const Text('Lo', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 11)),
                      Text(
                        loHand != null && loHand.isQualified ? controller.getLowHandDisplayName(loHand) : l10n.noLowHand,
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// 쇼다운 카드 위젯
  Widget _buildShowdownCard(PlayingCard card) {
    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankStr = _getRankString(card.rank);

    return Container(
      width: 34,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(rankStr, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
          Text(suitSymbol, style: TextStyle(color: color, fontSize: 8)),
        ],
      ),
    );
  }

  Widget _buildHiLoPlayerInfo(HiLoPlayer player, HiLoController controller) {
    final hiHand = player.pokerHand;
    final loHand = player.lowHand;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // 카드 표시
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: player.hand.map((card) => _buildSmallPlayerCard(card)).toList(),
            ),
          ),
          const SizedBox(height: 12),
          // 하이/로우 핸드 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // 하이 족보
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Column(
                  children: [
                    const Text('Hi', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    Text(
                      hiHand != null ? controller.getHandRankDisplayName(hiHand) : '-',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // 로우 족보
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  children: [
                    const Text('Lo', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    Text(
                      loHand != null ? controller.getLowHandDisplayName(loHand) : '-',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPlayerCard(PlayingCard card) {
    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankStr = _getRankString(card.rank);

    return Container(
      width: 40,
      height: 56,
      margin: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(rankStr, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          Text(suitSymbol, style: TextStyle(color: color, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildHiLoButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherPlayersHiLoStatus(HiLoState state, AppLocalizations l10n) {
    final otherPlayers = state.players.where((p) => p.id != 0 && p.isActive).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: otherPlayers.map((player) {
          final choice = player.hiLoChoice;
          return Column(
            children: [
              Text(
                player.name,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getHiLoChoiceColor(choice),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getHiLoChoiceText(choice, l10n),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Color _getHiLoChoiceColor(HiLoChoice choice) {
    switch (choice) {
      case HiLoChoice.hi:
        return Colors.red;
      case HiLoChoice.lo:
        return Colors.blue;
      case HiLoChoice.swing:
        return Colors.purple;
      case HiLoChoice.none:
        return Colors.grey;
    }
  }

  String _getHiLoChoiceText(HiLoChoice choice, AppLocalizations l10n) {
    switch (choice) {
      case HiLoChoice.hi:
        return l10n.hi;
      case HiLoChoice.lo:
        return l10n.lo;
      case HiLoChoice.swing:
        return l10n.swing;
      case HiLoChoice.none:
        return '?';
    }
  }

  Widget _buildPlayingScreen(HiLoController controller, HiLoState state, AppLocalizations l10n) {
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final screenWidth = mediaQuery.size.width;
    final sizes = _ResponsiveSizes(screenHeight, screenWidth);

    final opponents = state.players.where((p) => p.id != 0).toList();
    final leftOpponents = opponents.length >= 2 ? opponents.sublist(0, 2) : opponents;
    final rightOpponents = opponents.length > 2 ? opponents.sublist(2) : <HiLoPlayer>[];

    return Stack(
      children: [
        Column(
          children: [
            _buildPotInfo(state, l10n, sizes),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: leftOpponents.map((opponent) =>
                        _buildOpponentArea(opponent, state, l10n, controller, sizes)
                      ).toList(),
                    ),
                  ),
                  _buildCenterPotArea(state, l10n, sizes),
                  Expanded(
                    flex: 3,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: rightOpponents.map((opponent) =>
                        _buildOpponentArea(opponent, state, l10n, controller, sizes)
                      ).toList(),
                    ),
                  ),
                ],
              ),
            ),
            _buildPlayerArea(controller, state, l10n, sizes),
            _buildActionButtons(controller, state, l10n, sizes),
          ],
        ),
        if (controller.isRoundTransitioning)
          _buildRoundTransitionOverlay(controller),
      ],
    );
  }

  Widget _buildRoundTransitionOverlay(HiLoController controller) {
    return GestureDetector(
      onTap: () => controller.skipTransition(),
      child: Container(
        color: Colors.black.withValues(alpha: 0.3),
        child: Column(
          children: [
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.purple[800],
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
                      controller.roundTransitionMessage,
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
                      '${controller.transitionCountdown}초',
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
            const SizedBox(height: 180),
          ],
        ),
      ),
    );
  }

  Widget _buildPotInfo(HiLoState state, AppLocalizations l10n, _ResponsiveSizes sizes) {
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

  Widget _buildPhaseIndicator(HiLoState state, AppLocalizations l10n) {
    String phaseName;
    switch (state.phase) {
      case HiLoPhase.betting1:
        phaseName = '${l10n.betting} 1';
        break;
      case HiLoPhase.betting2:
        phaseName = '${l10n.betting} 2';
        break;
      case HiLoPhase.betting3:
        phaseName = '${l10n.betting} 3';
        break;
      case HiLoPhase.betting4:
        phaseName = '${l10n.betting} 4';
        break;
      case HiLoPhase.selectHiLo:
        phaseName = l10n.selectHiLo;
        break;
      default:
        phaseName = '';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple[700],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        phaseName,
        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCenterPotArea(HiLoState state, AppLocalizations l10n, _ResponsiveSizes sizes) {
    return Container(
      padding: const EdgeInsets.all(6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: sizes.potIconSize * 0.4, vertical: sizes.potIconSize * 0.25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple[700]!, Colors.purple[500]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple[300]!, width: 2),
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
                Container(
                  width: sizes.potIconSize,
                  height: sizes.potIconSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.amber[400]!, Colors.amber[700]!],
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
          if (state.currentBetAmount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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

  Widget _buildOpponentArea(HiLoPlayer opponent, HiLoState state, AppLocalizations l10n, HiLoController controller, _ResponsiveSizes sizes) {
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
          if (isBoss)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              margin: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star, color: Colors.black, size: sizes.badgeFontSize),
                  const SizedBox(width: 2),
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                opponent.name,
                style: TextStyle(
                  color: isFolded ? Colors.grey : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: sizes.nameFontSize,
                ),
              ),
              if (!isFolded) ...[
                const SizedBox(width: 2),
                Text(
                  '(${HiLoPlayer.maxBettingActions - opponent.bettingActionsInRound})',
                  style: TextStyle(
                    color: opponent.canBet ? Colors.lightGreenAccent : Colors.red,
                    fontSize: sizes.infoFontSize,
                  ),
                ),
              ],
            ],
          ),
          Text(
            '총: ${opponent.totalBetInGame}',
            style: TextStyle(
              color: isFolded ? Colors.grey : Colors.amber,
              fontSize: sizes.infoFontSize,
            ),
          ),
          if (opponent.lastAction != HiLoBettingAction.none)
            Text(
              _getBettingActionText(opponent.lastAction, opponent.currentBet),
              style: TextStyle(
                color: _getBettingActionColor(opponent.lastAction),
                fontSize: sizes.infoFontSize,
                fontWeight: FontWeight.bold,
              ),
            )
          else if (opponent.currentBet > 0)
            Text(
              '${l10n.bet}: ${opponent.currentBet}',
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
                if (controller.isRoundTransitioning && controller.cardCountBeforeTransition > 0) ...[
                  ...opponent.hand.take(controller.cardCountBeforeTransition).map((card) {
                    final isOpen = opponent.openCards.contains(card);
                    return isOpen ? _buildSmallCard(card, sizes) : _buildSmallCardBackForAI(sizes);
                  }),
                ] else ...[
                  ...opponent.hiddenCards.map((card) => _buildSmallCardBackForAI(sizes)),
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
        color: Colors.purple[800],
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: Colors.purple[900]!, width: 1),
      ),
      child: Center(
        child: Container(
          width: sizes.aiCardWidth * 0.6,
          height: sizes.aiCardHeight * 0.65,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.purple[300]!, width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerArea(HiLoController controller, HiLoState state, AppLocalizations l10n, _ResponsiveSizes sizes) {
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
                    '(${HiLoPlayer.maxBettingActions - player.bettingActionsInRound})',
                    style: TextStyle(
                      color: player.canBet ? Colors.lightGreenAccent : Colors.red,
                      fontSize: sizes.infoFontSize,
                    ),
                  ),
                  if (isBoss) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, color: Colors.black, size: sizes.badgeFontSize + 2),
                          const SizedBox(width: 2),
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
                '총: ${player.totalBetInGame}',
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: sizes.nameFontSize),
              ),
            ],
          ),
          SizedBox(height: isSmall ? 2 : 4),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (player.isFolded) ...[
                  ...player.hand.map((card) => _buildPlayerCardBack(sizes)),
                ] else ...[
                  if (controller.isRoundTransitioning && controller.cardCountBeforeTransition > 0) ...[
                    ...player.hand.take(controller.cardCountBeforeTransition).map((card) {
                      final isOpen = player.openCards.contains(card);
                      return _buildPlayerCard(card, isOpen, sizes);
                    }),
                  ] else ...[
                    ...player.openCards.map((card) => _buildPlayerCard(card, true, sizes)),
                    ...player.hiddenCards.map((card) => _buildPlayerCard(card, false, sizes)),
                  ],
                ],
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
                else
                  // 하이/로우 족보를 세로로 배치 (승리 가능성 높은 쪽 하이라이트)
                  Builder(builder: (context) {
                    final betterHand = controller.evaluateBetterHand(player);
                    final highlightHi = betterHand == 'hi' || betterHand == 'both';
                    final highlightLo = betterHand == 'lo' || betterHand == 'both';

                    return Container(
                      margin: const EdgeInsets.only(left: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 하이 족보 표시
                          if (player.allCardsPokerHand != null)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: isSmall ? 4 : 6, vertical: isSmall ? 2 : 3),
                              decoration: BoxDecoration(
                                color: highlightHi ? Colors.red.shade600 : Colors.red.shade700,
                                borderRadius: BorderRadius.circular(4),
                                border: highlightHi ? Border.all(color: Colors.amber, width: 2) : null,
                                boxShadow: highlightHi ? [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ] : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (highlightHi)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 2),
                                      child: Icon(Icons.star, color: Colors.amber, size: sizes.nameFontSize),
                                    ),
                                  Text(
                                    'Hi ${controller.getHandRankDisplayName(player.allCardsPokerHand)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: sizes.nameFontSize - 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // 로우 족보 표시
                          if (player.lowHand != null && player.lowHand!.isQualified)
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              padding: EdgeInsets.symmetric(horizontal: isSmall ? 4 : 6, vertical: isSmall ? 2 : 3),
                              decoration: BoxDecoration(
                                color: highlightLo ? Colors.blue.shade600 : Colors.blue.shade700,
                                borderRadius: BorderRadius.circular(4),
                                border: highlightLo ? Border.all(color: Colors.amber, width: 2) : null,
                                boxShadow: highlightLo ? [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ] : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (highlightLo)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 2),
                                      child: Icon(Icons.star, color: Colors.amber, size: sizes.nameFontSize),
                                    ),
                                  Text(
                                    'Lo ${controller.getLowHandDisplayName(player.lowHand)}',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: sizes.nameFontSize - 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(PlayingCard card, bool isOpen, _ResponsiveSizes sizes) {
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
          child: Text('🃏', style: TextStyle(fontSize: sizes.playerFontSize + 4)),
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
          color: Colors.purple[800],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.purple[900]!, width: 1),
        ),
        child: Center(
          child: Container(
            width: sizes.playerCardWidth * 0.6,
            height: sizes.playerCardHeight * 0.65,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.purple[300]!, width: 1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(HiLoController controller, HiLoState state, AppLocalizations l10n, _ResponsiveSizes sizes) {
    final isMyTurn = controller.isHumanTurn;
    final availableActions = isMyTurn ? state.getAvailableActions() : <String>[];
    final isSmall = sizes.screenHeight < 700;

    VoidCallback? getAction(String actionName, VoidCallback action) {
      return isMyTurn && availableActions.contains(actionName) ? action : null;
    }

    return Container(
      padding: EdgeInsets.all(isSmall ? 4 : 8),
      color: Colors.black38,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBetButton(
                label: '삥',
                amount: state.getBingAmount(),
                color: Colors.green,
                onPressed: getAction('bing', () => controller.humanBing()),
                sizes: sizes,
              ),
              _buildBetButton(
                label: '콜',
                amount: state.getCallAmount(),
                color: Colors.cyan,
                onPressed: getAction('call', () => controller.humanCall()),
                sizes: sizes,
              ),
              _buildBetButton(
                label: '따당',
                amount: state.getDdadangAmount(),
                color: Colors.orange,
                onPressed: getAction('ddadang', () => controller.humanDdadang()),
                sizes: sizes,
              ),
              _buildBetButton(
                label: '다이',
                amount: null,
                color: Colors.red,
                onPressed: getAction('die', () => controller.humanDie()),
                sizes: sizes,
              ),
            ],
          ),
          SizedBox(height: isSmall ? 4 : 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildBetButton(
                label: '체크',
                amount: null,
                color: Colors.blue,
                onPressed: getAction('check', () => controller.humanCheck()),
                sizes: sizes,
              ),
              _buildBetButton(
                label: '쿼터',
                amount: state.getQuarterAmount(),
                color: Colors.teal,
                onPressed: getAction('quarter', () => controller.humanQuarter()),
                sizes: sizes,
              ),
              _buildBetButton(
                label: '하프',
                amount: state.getHalfAmount(),
                color: Colors.indigo,
                onPressed: getAction('half', () => controller.humanHalf()),
                sizes: sizes,
              ),
              _buildBetButton(
                label: '풀',
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

  Widget _buildGameEndScreen(HiLoController controller, HiLoState state, AppLocalizations l10n) {
    final result = state.result;
    final statsService = Provider.of<HiLoStatsService>(context, listen: false);

    // 통계 기록 (한 번만)
    if (!_statsRecorded && result != null) {
      _statsRecorded = true;
      final playerScores = <int, int>{};
      for (final player in state.players) {
        int score = -player.totalBetInGame;
        if (result.swingSuccess && player.id == result.swingPlayer?.id) {
          score = state.pot - player.totalBetInGame;
        } else {
          if (player.id == result.hiWinner?.id) {
            score += result.hiPot;
          }
          if (player.id == result.loWinner?.id) {
            score += result.loPot;
          }
        }
        playerScores[player.id] = score;
      }
      statsService.recordGameResult(
        hiWinnerId: result.hiWinner?.id,
        loWinnerId: result.loWinner?.id,
        swingSuccess: result.swingSuccess,
        swingPlayerId: result.swingPlayer?.id,
        playerScores: playerScores,
      );
    }

    return Consumer<HiLoStatsService>(
      builder: (context, stats, child) {
        return Center(
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
                const Icon(Icons.emoji_events, color: Colors.amber, size: 48),
                const SizedBox(height: 12),
                Text(
                  l10n.gameEnd,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // 하이 승자
                if (result?.hiWinner != null)
                  _buildWinnerInfo(l10n.hi, result!.hiWinner!, result.hiPot, Colors.red, controller),
                const SizedBox(height: 4),
                // 로우 승자
                if (result?.loWinner != null)
                  _buildWinnerInfo(l10n.lo, result!.loWinner!, result.loPot, Colors.blue, controller),
                // 스윙 성공
                if (result?.swingSuccess == true)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.purple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${result!.swingPlayer!.name} ${l10n.swingSuccess}!',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.pot}: ${state.pot}',
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
                      Row(
                        children: [
                          const Expanded(flex: 3, child: Text('플레이어', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          const Expanded(flex: 2, child: Text('이번 게임', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          const Expanded(flex: 2, child: Text('승/패', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                          const Expanded(flex: 2, child: Text('누적', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        ],
                      ),
                      const Divider(height: 8),
                      ...state.players.map((player) {
                        final playerStats = stats.getPlayerStats(player.id);
                        int gameScore = -player.totalBetInGame;
                        if (result?.swingSuccess == true && player.id == result?.swingPlayer?.id) {
                          gameScore = state.pot - player.totalBetInGame;
                        } else {
                          if (player.id == result?.hiWinner?.id) {
                            gameScore += result!.hiPot;
                          }
                          if (player.id == result?.loWinner?.id) {
                            gameScore += result!.loPot;
                          }
                        }
                        final isHiWinner = player.id == result?.hiWinner?.id;
                        final isLoWinner = player.id == result?.loWinner?.id;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    if (isHiWinner) const Icon(Icons.arrow_upward, color: Colors.red, size: 12),
                                    if (isLoWinner) const Icon(Icons.arrow_downward, color: Colors.blue, size: 12),
                                    const SizedBox(width: 2),
                                    Flexible(
                                      child: Text(
                                        player.name,
                                        style: TextStyle(
                                          fontWeight: (isHiWinner || isLoWinner) ? FontWeight.bold : FontWeight.normal,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 결과 확인 버튼
                    ElevatedButton.icon(
                      onPressed: () => _showDetailedResults(context, controller, state, l10n),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: Text(l10n.viewResults),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
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
        );
      },
    );
  }

  /// 상세 결과 다이얼로그 표시
  void _showDetailedResults(BuildContext context, HiLoController controller, HiLoState state, AppLocalizations l10n) {
    final activePlayers = state.players.where((p) => !p.isFolded).toList();
    final foldedPlayers = state.players.where((p) => p.isFolded).toList();
    final result = state.result;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: Colors.purple[900],
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
                  color: Colors.purple[800],
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
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: Colors.white),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // 활성 플레이어 (카드 표시)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: Column(
                    children: activePlayers.map((player) =>
                      _buildActivePlayerResultCard(player, controller, result, l10n)
                    ).toList(),
                  ),
                ),
              ),
              // 다이한 플레이어 (카드 표시)
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
                        l10n.fold,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 8),
                      Column(
                        children: foldedPlayers.map((player) =>
                          _buildFoldedPlayerResultCard(player, controller, l10n)
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

  /// 활성 플레이어 결과 카드
  Widget _buildActivePlayerResultCard(HiLoPlayer player, HiLoController controller, HiLoResult? result, AppLocalizations l10n) {
    final isHiWinner = player.id == result?.hiWinner?.id;
    final isLoWinner = player.id == result?.loWinner?.id;
    final isWinner = isHiWinner || isLoWinner;
    final choice = player.hiLoChoice;

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
          // 플레이어 이름, 선택, 족보
          Row(
            children: [
              if (isHiWinner)
                const Icon(Icons.arrow_upward, color: Colors.red, size: 16),
              if (isLoWinner)
                const Icon(Icons.arrow_downward, color: Colors.blue, size: 16),
              if (isWinner)
                const SizedBox(width: 4),
              Text(
                player.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              // 선택 배지
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getHiLoChoiceColor(choice),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getHiLoChoiceText(choice, l10n),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Text(
                '${l10n.bet}: ${player.totalBetInGame}',
                style: const TextStyle(color: Colors.amber, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // 족보 정보
          Row(
            children: [
              if (choice == HiLoChoice.hi || choice == HiLoChoice.swing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 4),
                  decoration: BoxDecoration(
                    color: isHiWinner ? Colors.red : Colors.red.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Hi: ${player.pokerHand != null ? controller.getHandRankDisplayName(player.pokerHand) : "-"}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              if (choice == HiLoChoice.lo || choice == HiLoChoice.swing)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isLoWinner ? Colors.blue : Colors.blue.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Lo: ${player.lowHand != null && player.lowHand!.isQualified ? controller.getLowHandDisplayName(player.lowHand) : l10n.noLowHand}',
                    style: const TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // 카드 표시
          Wrap(
            spacing: 3,
            runSpacing: 3,
            children: player.hand.map((card) => _buildResultCard(card, false)).toList(),
          ),
        ],
      ),
    );
  }

  /// 다이한 플레이어 결과 카드
  Widget _buildFoldedPlayerResultCard(HiLoPlayer player, HiLoController controller, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black38,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                player.name,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${l10n.bet}: ${player.totalBetInGame}',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // 카드 표시 (흐리게)
          Wrap(
            spacing: 3,
            runSpacing: 3,
            children: player.hand.map((card) => _buildResultCard(card, true)).toList(),
          ),
        ],
      ),
    );
  }

  /// 결과 카드 위젯
  Widget _buildResultCard(PlayingCard card, bool isDimmed) {
    final color = (card.suit == Suit.heart || card.suit == Suit.diamond) ? Colors.red : Colors.black;
    final suitSymbol = _getSuitSymbol(card.suit);
    final rankStr = _getRankString(card.rank);

    return Opacity(
      opacity: isDimmed ? 0.5 : 1.0,
      child: Container(
        width: 34,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(rankStr, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
            Text(suitSymbol, style: TextStyle(color: color, fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildWinnerInfo(String label, HiLoPlayer winner, int pot, Color color, HiLoController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Text(
          '${winner.name} +$pot',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 8),
        if (label == 'Hi' && winner.pokerHand != null)
          Text(
            controller.getHandRankDisplayName(winner.pokerHand),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        if (label == 'Lo' && winner.lowHand != null)
          Text(
            controller.getLowHandDisplayName(winner.lowHand),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
      ],
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

  String _getBettingActionText(HiLoBettingAction action, int amount) {
    switch (action) {
      case HiLoBettingAction.bing:
        return '삥 ($amount)';
      case HiLoBettingAction.check:
        return '체크';
      case HiLoBettingAction.call:
        return '콜 ($amount)';
      case HiLoBettingAction.ddadang:
        return '따당 ($amount)';
      case HiLoBettingAction.quarter:
        return '쿼터 ($amount)';
      case HiLoBettingAction.half:
        return '하프 ($amount)';
      case HiLoBettingAction.full:
        return '풀 ($amount)';
      case HiLoBettingAction.die:
        return '다이';
      case HiLoBettingAction.none:
        return '';
    }
  }

  Color _getBettingActionColor(HiLoBettingAction action) {
    switch (action) {
      case HiLoBettingAction.bing:
        return Colors.green;
      case HiLoBettingAction.check:
        return Colors.blue;
      case HiLoBettingAction.call:
        return Colors.cyan;
      case HiLoBettingAction.ddadang:
        return Colors.orange;
      case HiLoBettingAction.quarter:
        return Colors.teal;
      case HiLoBettingAction.half:
        return Colors.indigo;
      case HiLoBettingAction.full:
        return Colors.purple;
      case HiLoBettingAction.die:
        return Colors.red;
      case HiLoBettingAction.none:
        return Colors.grey;
    }
  }
}
