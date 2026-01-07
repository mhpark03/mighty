import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/generated/app_localizations.dart';
import '../widgets/banner_ad_widget.dart';
import 'home_screen.dart';
import 'seven_card/seven_card_home_screen.dart';
import 'hi_lo/hi_lo_home_screen.dart';
import 'hula/hula_home_screen.dart';
import 'onecard/onecard_home_screen.dart';
import 'hearts/hearts_home_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final isSmallScreen = screenHeight < 600;

    final games = [
      _GameInfo(
        title: l10n.appTitle,
        subtitle: l10n.gameSubtitle,
        icon: Icons.style,
        color: Colors.green[700]!,
        screen: const HomeScreen(),
      ),
      _GameInfo(
        title: l10n.sevenCardTitle,
        subtitle: l10n.sevenCardSubtitle,
        icon: Icons.casino,
        color: Colors.blue[700]!,
        screen: const SevenCardHomeScreen(),
      ),
      _GameInfo(
        title: l10n.hiLoTitle,
        subtitle: l10n.hiLoSubtitle,
        icon: Icons.swap_vert,
        color: Colors.purple[700]!,
        screen: const HiLoHomeScreen(),
      ),
      _GameInfo(
        title: l10n.hulaTitle,
        subtitle: l10n.hulaSubtitle,
        icon: Icons.style,
        color: Colors.teal[700]!,
        screen: const HulaHomeScreen(),
      ),
      _GameInfo(
        title: '원카드',
        subtitle: '4인 대전',
        icon: Icons.filter_1,
        color: Colors.orange[700]!,
        screen: const OneCardHomeScreen(),
      ),
      _GameInfo(
        title: l10n.heartsTitle,
        subtitle: l10n.heartsSubtitle,
        icon: Icons.favorite,
        color: Colors.red[700]!,
        screen: const HeartsHomeScreen(),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.green[900],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  children: [
                    // 앱 타이틀
                    Text(
                      l10n.selectGame,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 22 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black54,
                            offset: Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 12 : 16),

                    // 게임 그리드 (2x3)
                    Expanded(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: isSmallScreen ? 10 : 14,
                          mainAxisSpacing: isSmallScreen ? 10 : 14,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: games.length,
                        itemBuilder: (context, index) {
                          final game = games[index];
                          return _buildGameTile(
                            context: context,
                            game: game,
                            isSmallScreen: isSmallScreen,
                          );
                        },
                      ),
                    ),

                    // 앱 종료 버튼
                    Padding(
                      padding: EdgeInsets.only(top: isSmallScreen ? 8 : 12),
                      child: TextButton.icon(
                        onPressed: () => _showExitAppDialog(context, l10n),
                        icon: Icon(Icons.power_settings_new, color: Colors.white54, size: isSmallScreen ? 16 : 18),
                        label: Text(
                          l10n.exitApp,
                          style: TextStyle(color: Colors.white54, fontSize: isSmallScreen ? 12 : 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTile({
    required BuildContext context,
    required _GameInfo game,
    required bool isSmallScreen,
  }) {
    return Material(
      color: game.color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => game.screen),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  game.icon,
                  color: Colors.white,
                  size: isSmallScreen ? 28 : 36,
                ),
              ),
              SizedBox(height: isSmallScreen ? 8 : 10),
              Text(
                game.title,
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                game.subtitle,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExitAppDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.exitApp),
        content: Text(l10n.exitAppConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              } else {
                exit(0);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.exit, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _GameInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Widget screen;

  const _GameInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.screen,
  });
}
