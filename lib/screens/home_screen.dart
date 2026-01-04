import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../models/game_state.dart';
import '../services/game_controller.dart';
import '../services/stats_service.dart';
import '../services/ad_service.dart';
import '../widgets/banner_ad_widget.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;

    // 화면 크기에 따른 동적 크기 계산
    final isSmallScreen = screenHeight < 600;
    final isMediumScreen = screenHeight >= 600 && screenHeight < 800;

    // 타이틀 크기
    final titleSize = isSmallScreen ? 32.0 : (isMediumScreen ? 38.0 : 42.0);
    final subtitleSize = isSmallScreen ? 12.0 : 14.0;

    // 버튼 크기
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;
    final buttonPadding = isSmallScreen ? 12.0 : 14.0;
    final buttonIconSize = isSmallScreen ? 22.0 : 26.0;

    // 통계 테이블 크기
    final statsHeaderSize = isSmallScreen ? 14.0 : 16.0;
    final statsLabelSize = isSmallScreen ? 11.0 : 12.0;
    final statsNameSize = isSmallScreen ? 13.0 : 15.0;
    final statsValueSize = isSmallScreen ? 12.0 : 14.0;
    final statsScoreSize = isSmallScreen ? 14.0 : 16.0;
    final statsIconSize = isSmallScreen ? 16.0 : 18.0;

    // 여백
    final topPadding = isSmallScreen ? 12.0 : (isMediumScreen ? 16.0 : 20.0);
    final sectionGap = isSmallScreen ? 12.0 : 16.0;
    final bottomPadding = isSmallScreen ? 8.0 : 12.0;

    return Consumer2<GameController, StatsService>(
      builder: (context, controller, statsService, child) {
        final hasActiveGame = controller.state.phase != GamePhase.waiting &&
            controller.state.phase != GamePhase.gameEnd;

        return Scaffold(
          backgroundColor: Colors.green[800],
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(8, topPadding, 8, bottomPadding),
                    child: Column(
                      children: [
                  // 타이틀
                  Text(
                    l10n.appTitle,
                    style: TextStyle(
                      fontSize: titleSize,
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
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    l10n.gameSubtitle,
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: sectionGap),

                  // 게임 시작하기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (hasActiveGame) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GameScreen()),
                          );
                        } else {
                          controller.startNewGame();
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const GameScreen()),
                          );
                        }
                      },
                      icon: Icon(
                        Icons.play_arrow,
                        color: Colors.black,
                        size: buttonIconSize,
                      ),
                      label: Text(
                        hasActiveGame ? l10n.continueGame : l10n.startGame,
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        padding: EdgeInsets.symmetric(vertical: buttonPadding),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: sectionGap),

                  // 통계 테이블 (Expanded로 남은 공간 채움)
                  Expanded(
                    child: statsService.isLoaded
                        ? Container(
                            padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                // 헤더
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      l10n.playerStats,
                                      style: TextStyle(
                                        fontSize: statsHeaderSize,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => _showResetStatsDialog(context, statsService, l10n),
                                      icon: Icon(Icons.refresh, size: statsLabelSize, color: Colors.white70),
                                      label: Text(
                                        l10n.resetStats,
                                        style: TextStyle(color: Colors.white70, fontSize: statsLabelSize - 1),
                                      ),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 6),
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 4 : 6),
                                // 테이블 헤더
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: statsLabelSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          l10n.winLoss,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: statsLabelSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          l10n.totalScore,
                                          textAlign: TextAlign.right,
                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: statsLabelSize,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 2 : 4),
                                // 플레이어별 통계 (남은 공간을 균등 분배)
                                Expanded(
                                  child: Column(
                                    children: [
                                      for (int i = 0; i < statsService.playerStats.length; i++)
                                        Expanded(
                                          child: _buildPlayerStatRow(
                                            statsService.playerStats[i],
                                            i == 0,
                                            l10n,
                                            statsNameSize,
                                            statsValueSize,
                                            statsScoreSize,
                                            statsIconSize,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: isSmallScreen ? 4 : 8),

                        // 앱 종료 버튼
                        TextButton.icon(
                          onPressed: () => _showExitAppDialog(context, l10n),
                          icon: Icon(Icons.power_settings_new, color: Colors.white54, size: isSmallScreen ? 16 : 18),
                          label: Text(
                            l10n.exitApp,
                            style: TextStyle(color: Colors.white54, fontSize: isSmallScreen ? 12 : 13),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 12, vertical: isSmallScreen ? 4 : 6),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
      },
    );
  }

  Widget _buildPlayerStatRow(
    dynamic playerStats,
    bool isHuman,
    AppLocalizations l10n,
    double nameSize,
    double valueSize,
    double scoreSize,
    double iconSize,
  ) {
    final scoreColor = playerStats.totalScore >= 0 ? Colors.lightGreenAccent : Colors.redAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
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
                  Icon(Icons.person, color: Colors.amber, size: iconSize),
                if (isHuman) const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    playerStats.name,
                    style: TextStyle(
                      color: isHuman ? Colors.amber : Colors.white,
                      fontSize: nameSize,
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
              style: TextStyle(
                color: Colors.white,
                fontSize: valueSize,
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
                fontSize: scoreSize,
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
              Navigator.pop(dialogContext);
              // 보상형 광고 표시 후 초기화
              AdService().showRewardedAd(
                onRewarded: () {
                  statsService.resetStats();
                },
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.resetStats, style: const TextStyle(color: Colors.white)),
          ),
        ],
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
