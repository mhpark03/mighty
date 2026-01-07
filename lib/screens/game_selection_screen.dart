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

class GameSelectionScreen extends StatelessWidget {
  const GameSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final isSmallScreen = screenHeight < 600;

    return Scaffold(
      backgroundColor: Colors.green[900],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                child: Column(
                  children: [
                    // 앱 타이틀
                    Text(
                      l10n.selectGame,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 28 : 36,
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
                    SizedBox(height: isSmallScreen ? 24 : 32),

                    // 마이티 버튼
                    _buildGameButton(
                      context: context,
                      title: l10n.appTitle,
                      subtitle: l10n.gameSubtitle,
                      icon: Icons.style,
                      color: Colors.green[700]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                        );
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // 세븐카드 버튼
                    _buildGameButton(
                      context: context,
                      title: l10n.sevenCardTitle,
                      subtitle: l10n.sevenCardSubtitle,
                      icon: Icons.casino,
                      color: Colors.blue[700]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SevenCardHomeScreen()),
                        );
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // 하이로우 버튼
                    _buildGameButton(
                      context: context,
                      title: l10n.hiLoTitle,
                      subtitle: l10n.hiLoSubtitle,
                      icon: Icons.swap_vert,
                      color: Colors.purple[700]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HiLoHomeScreen()),
                        );
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // 훌라 버튼
                    _buildGameButton(
                      context: context,
                      title: l10n.hulaTitle,
                      subtitle: l10n.hulaSubtitle,
                      icon: Icons.style,
                      color: Colors.teal[700]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HulaHomeScreen()),
                        );
                      },
                      isSmallScreen: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // 원카드 버튼
                    _buildGameButton(
                      context: context,
                      title: '원카드',
                      subtitle: '4인 대전',
                      icon: Icons.filter_1,
                      color: Colors.orange[700]!,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const OneCardHomeScreen()),
                        );
                      },
                      isSmallScreen: isSmallScreen,
                    ),

                    SizedBox(height: isSmallScreen ? 16 : 24),

                    // 앱 종료 버튼
                    TextButton.icon(
                      onPressed: () => _showExitAppDialog(context, l10n),
                      icon: Icon(Icons.power_settings_new, color: Colors.white54, size: isSmallScreen ? 16 : 18),
                      label: Text(
                        l10n.exitApp,
                        style: TextStyle(color: Colors.white54, fontSize: isSmallScreen ? 12 : 13),
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

  Widget _buildGameButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required bool isSmallScreen,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: isSmallScreen ? 32 : 40,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 2 : 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white54,
                  size: isSmallScreen ? 20 : 24,
                ),
              ],
            ),
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
