import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/game_state.dart';
import '../services/game_controller.dart';
import '../services/stats_service.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<GameController, StatsService>(
      builder: (context, controller, statsService, child) {
        final hasActiveGame = controller.state.phase != GamePhase.waiting &&
            controller.state.phase != GamePhase.gameEnd;

        return Scaffold(
          backgroundColor: Colors.green[800],
          body: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 타이틀
                      Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black54,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.gameSubtitle,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 이어하기 버튼 (진행 중인 게임이 있을 때만)
                      if (hasActiveGame) ...[
                        _buildMenuButton(
                          context,
                          icon: Icons.play_arrow,
                          label: l10n.continueGame,
                          color: Colors.amber,
                          textColor: Colors.black,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GameScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        // 현재 게임 상태 표시
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getGameStatusText(controller, l10n),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 새 게임 버튼
                      _buildMenuButton(
                        context,
                        icon: Icons.add,
                        label: l10n.newGame,
                        color: hasActiveGame ? Colors.white24 : Colors.amber,
                        textColor: hasActiveGame ? Colors.white : Colors.black,
                        onPressed: () {
                          if (hasActiveGame) {
                            _showNewGameConfirmDialog(context, controller, l10n);
                          } else {
                            controller.startNewGame();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const GameScreen(),
                              ),
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 40),

                      // 플레이어 통계
                      if (statsService.isLoaded)
                        _buildStatsSection(context, statsService, l10n),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection(BuildContext context, StatsService statsService, AppLocalizations l10n) {
    final stats = statsService.playerStats;
    if (stats.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.playerStats,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              TextButton.icon(
                onPressed: () => _showResetStatsDialog(context, statsService, l10n),
                icon: const Icon(Icons.refresh, size: 16, color: Colors.white70),
                label: Text(
                  l10n.resetStats,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 헤더
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    l10n.player,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.winLoss,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    l10n.totalScore,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          // 플레이어별 통계
          for (int i = 0; i < stats.length; i++)
            _buildPlayerStatRow(stats[i], i == 0, l10n),
        ],
      ),
    );
  }

  Widget _buildPlayerStatRow(dynamic playerStats, bool isHuman, AppLocalizations l10n) {
    final scoreColor = playerStats.totalScore >= 0 ? Colors.lightGreenAccent : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white12, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (isHuman)
                  const Icon(Icons.person, color: Colors.amber, size: 16),
                if (isHuman) const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    playerStats.name,
                    style: TextStyle(
                      color: isHuman ? Colors.amber : Colors.white,
                      fontSize: 14,
                      fontWeight: isHuman ? FontWeight.bold : FontWeight.normal,
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
              '${playerStats.wins}${l10n.win} / ${playerStats.losses}${l10n.loss}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${playerStats.totalScore >= 0 ? '+' : ''}${playerStats.totalScore}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: scoreColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetStatsDialog(BuildContext context, StatsService statsService, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetStats),
        content: Text(l10n.resetStatsConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              statsService.resetStats();
              Navigator.pop(dialogContext);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.resetStats, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required Color textColor,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 200,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: textColor),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  String _getGameStatusText(GameController controller, AppLocalizations l10n) {
    final state = controller.state;
    switch (state.phase) {
      case GamePhase.bidding:
        return l10n.biddingPhase;
      case GamePhase.selectingKitty:
        return l10n.selectKitty;
      case GamePhase.declaringFriend:
        return l10n.declareFriend;
      case GamePhase.playing:
        return '${l10n.trick} ${state.currentTrickNumber}/10';
      default:
        return '';
    }
  }

  void _showNewGameConfirmDialog(
    BuildContext context,
    GameController controller,
    AppLocalizations l10n,
  ) {
    final parentContext = context;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.newGame),
        content: Text(l10n.exitGameConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              controller.reset();
              controller.startNewGame();
              Navigator.push(
                parentContext,
                MaterialPageRoute(
                  builder: (context) => const GameScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
            child: Text(l10n.newGame, style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
