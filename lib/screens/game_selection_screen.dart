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
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final isSmallScreen = screenHeight < 600;

    // 반응형: 화면 너비에 따라 최대 너비와 폰트 크기 결정
    final double maxContentWidth;
    final double iconSize;
    final double titleSize;
    final double subtitleSize;

    if (screenWidth >= 900) {
      // 데스크탑/대형 태블릿
      maxContentWidth = 800;
      iconSize = 48;
      titleSize = 20;
      subtitleSize = 14;
    } else if (screenWidth >= 600) {
      // 태블릿
      maxContentWidth = 600;
      iconSize = 40;
      titleSize = 18;
      subtitleSize = 13;
    } else {
      // 모바일
      maxContentWidth = double.infinity;
      iconSize = isSmallScreen ? 28 : 36;
      titleSize = isSmallScreen ? 14.0 : 17.0;
      subtitleSize = isSmallScreen ? 10.0 : 12.0;
    }

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

    // 타일 크기 계산 (고정 크기로 변경)
    final double tileWidth;
    final double tileHeight;
    if (screenWidth >= 900) {
      tileWidth = 200;
      tileHeight = 160;
    } else if (screenWidth >= 600) {
      tileWidth = 160;
      tileHeight = 130;
    } else {
      tileWidth = (screenWidth - 48) / 2; // 2열, 패딩 고려
      tileHeight = isSmallScreen ? 100 : 120;
    }

    return Scaffold(
      backgroundColor: Colors.green[900],
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      children: [
                        // 앱 타이틀
                        Text(
                          l10n.selectGame,
                          style: TextStyle(
                            fontSize: screenWidth >= 600 ? 32 : (isSmallScreen ? 22 : 28),
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
                        SizedBox(height: isSmallScreen ? 12 : 20),

                        // 게임 그리드 (Wrap으로 변경하여 스크롤 가능)
                        Wrap(
                          spacing: isSmallScreen ? 10 : 16,
                          runSpacing: isSmallScreen ? 10 : 16,
                          alignment: WrapAlignment.center,
                          children: games.map((game) => SizedBox(
                            width: tileWidth,
                            height: tileHeight,
                            child: _buildGameTile(
                              context: context,
                              game: game,
                              iconSize: iconSize,
                              titleSize: titleSize,
                              subtitleSize: subtitleSize,
                            ),
                          )).toList(),
                        ),

                        // 앱 종료 버튼
                        Padding(
                          padding: EdgeInsets.only(top: isSmallScreen ? 16 : 24),
                          child: TextButton.icon(
                            onPressed: () => _showExitAppDialog(context, l10n),
                            icon: Icon(Icons.power_settings_new, color: Colors.white54, size: isSmallScreen ? 16 : 20),
                            label: Text(
                              l10n.exitApp,
                              style: TextStyle(color: Colors.white54, fontSize: isSmallScreen ? 12 : 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
    required double iconSize,
    required double titleSize,
    required double subtitleSize,
  }) {
    return Material(
      color: game.color,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => game.screen),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // 사용 가능한 공간에 맞춰 동적 크기 계산
            final availableHeight = constraints.maxHeight;
            final availableWidth = constraints.maxWidth;
            final padding = availableHeight * 0.06;
            final dynamicIconSize = (availableHeight * 0.28).clamp(18.0, iconSize);
            final iconPadding = dynamicIconSize * 0.25;
            final dynamicTitleSize = (availableHeight * 0.11).clamp(11.0, titleSize);
            final dynamicSubtitleSize = (availableHeight * 0.08).clamp(8.0, subtitleSize);
            final spacing = availableHeight * 0.04;

            return Container(
              padding: EdgeInsets.all(padding),
              width: availableWidth,
              height: availableHeight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: availableWidth - padding * 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          game.icon,
                          color: Colors.white,
                          size: dynamicIconSize,
                        ),
                      ),
                      SizedBox(height: spacing),
                      Text(
                        game.title,
                        style: TextStyle(
                          fontSize: dynamicTitleSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: spacing * 0.3),
                      Text(
                        game.subtitle,
                        style: TextStyle(
                          fontSize: dynamicSubtitleSize,
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
          },
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
