import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/game_state.dart';
import '../services/game_controller.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<GameController>(
      builder: (context, controller, child) {
        final hasActiveGame = controller.state.phase != GamePhase.waiting &&
            controller.state.phase != GamePhase.gameEnd;

        return Scaffold(
          backgroundColor: Colors.green[800],
          body: SafeArea(
            child: Center(
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
                  const SizedBox(height: 60),

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
                ],
              ),
            ),
          ),
        );
      },
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.newGame),
        content: Text(l10n.exitGameConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              controller.reset();
              controller.startNewGame();
              Navigator.push(
                context,
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
