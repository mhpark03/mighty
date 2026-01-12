import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/hula/hula_stats_service.dart';
import '../../services/ad_service.dart';
import 'hula_screen.dart';

class HulaHomeScreen extends StatefulWidget {
  const HulaHomeScreen({super.key});

  @override
  State<HulaHomeScreen> createState() => _HulaHomeScreenState();
}

class _HulaHomeScreenState extends State<HulaHomeScreen> {
  bool _hasSavedGame = false;

  @override
  void initState() {
    super.initState();
    _checkSavedGame();
  }

  Future<void> _checkSavedGame() async {
    final hasSaved = await HulaScreen.hasSavedGame();
    if (mounted) {
      setState(() {
        _hasSavedGame = hasSaved;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final isSmallScreen = screenHeight < 600;
    final isMediumScreen = screenHeight >= 600 && screenHeight < 800;

    final titleSize = isSmallScreen ? 28.0 : (isMediumScreen ? 34.0 : 38.0);
    final subtitleSize = isSmallScreen ? 12.0 : 14.0;
    final buttonFontSize = isSmallScreen ? 16.0 : 18.0;
    final buttonPadding = isSmallScreen ? 12.0 : 14.0;
    final buttonIconSize = isSmallScreen ? 22.0 : 26.0;
    final topPadding = isSmallScreen ? 8.0 : (isMediumScreen ? 12.0 : 16.0);
    final sectionGap = isSmallScreen ? 12.0 : 16.0;
    final bottomPadding = isSmallScreen ? 8.0 : 12.0;

    // 통계 테이블 크기
    final statsHeaderSize = isSmallScreen ? 14.0 : 16.0;
    final statsLabelSize = isSmallScreen ? 11.0 : 12.0;
    final statsNameSize = isSmallScreen ? 13.0 : 15.0;
    final statsValueSize = isSmallScreen ? 12.0 : 14.0;
    final statsScoreSize = isSmallScreen ? 14.0 : 16.0;
    final statsIconSize = isSmallScreen ? 16.0 : 18.0;

    return Consumer<HulaStatsService>(
      builder: (context, statsService, child) {
        return Scaffold(
          backgroundColor: Colors.teal[900],
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(12, topPadding, 12, bottomPadding),
                    child: Column(
                      children: [
                        // 뒤로가기 버튼
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 8),

                        // 타이틀
                        Text(
                          l10n.hulaTitle,
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
                          l10n.hulaSubtitle,
                          style: TextStyle(
                            fontSize: subtitleSize,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: sectionGap),

                        // 게임 시작하기/이어하기 버튼
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HulaScreen(
                                    playerCount: 4,
                                    difficulty: HulaDifficulty.hard,
                                    resumeGame: _hasSavedGame,
                                  ),
                                ),
                              ).then((_) => _checkSavedGame());
                            },
                            icon: Icon(
                              Icons.play_arrow,
                              color: Colors.black,
                              size: buttonIconSize,
                            ),
                            label: Text(
                              _hasSavedGame ? l10n.continueGame : l10n.startGame,
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

                        // 통계 테이블
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
                                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
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
                                      // 플레이어별 통계
                                      Expanded(
                                        child: Column(
                                          children: [
                                            for (int i = 0; i < statsService.playerStats.length; i++)
                                              Expanded(
                                                child: _buildPlayerStatRow(
                                                  statsService.playerStats[i],
                                                  i,
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

                        // 게임 가이드 버튼
                        TextButton.icon(
                          onPressed: () => _showGameGuideDialog(context, isSmallScreen),
                          icon: Icon(Icons.help_outline, color: Colors.white54, size: isSmallScreen ? 16 : 18),
                          label: Text(
                            l10n.gameGuide,
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
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerStatRow(
    HulaPlayerStats playerStats,
    int playerIndex,
    AppLocalizations l10n,
    double nameSize,
    double valueSize,
    double scoreSize,
    double iconSize,
  ) {
    final isHuman = playerIndex == 0;
    final scoreColor = playerStats.totalScore >= 0 ? Colors.lightGreenAccent : Colors.redAccent;
    final playerNames = ['플레이어', '민준', '서연', '지호'];

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
                    playerNames[playerIndex],
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

  void _showResetStatsDialog(BuildContext context, HulaStatsService statsService, AppLocalizations l10n) {
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
                onAdNotAvailable: () {
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

  Widget _buildInfoRow(IconData icon, String text, bool isSmallScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.amber, size: isSmallScreen ? 18 : 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 13 : 14,
            ),
          ),
        ),
      ],
    );
  }

  void _showGameGuideDialog(BuildContext context, bool isSmallScreen) {
    final titleSize = isSmallScreen ? 14.0 : 16.0;
    final textSize = isSmallScreen ? 12.0 : 14.0;

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.teal[900],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 헤더
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal[800],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.menu_book, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '게임 규칙',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      icon: const Icon(Icons.close, color: Colors.white70),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // 내용
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildGuideSection('목표', '손패의 카드를 모두 등록하거나 버려서 가장 먼저 없애는 것이 목표입니다.', Icons.info_outline, titleSize, textSize),
                      const SizedBox(height: 16),
                      _buildGuideSection('진행 방법', '매 턴마다 덱 또는 버린 더미에서 카드 1장을 뽑고, 등록 또는 버리기를 합니다.', Icons.play_arrow, titleSize, textSize),
                      const SizedBox(height: 16),
                      _buildGuideSection('멜드 종류', '• Run: 같은 무늬의 연속된 숫자 3장 이상 (예: ♠3-4-5)\n• Group: 같은 숫자 다른 무늬 3장 이상 (예: ♠7-♥7-♦7)', Icons.style, titleSize, textSize),
                      const SizedBox(height: 16),
                      _buildGuideSection('7의 특수 규칙', '7은 단독으로 등록할 수 있습니다.', Icons.star, titleSize, textSize, Colors.amber),
                      const SizedBox(height: 16),
                      _buildGuideSection('땡큐', '버린 더미에서 7을 뽑으면 "땡큐"를 외치고 특별한 등록을 할 수 있습니다.', Icons.celebration, titleSize, textSize, Colors.cyan),
                      const SizedBox(height: 16),
                      _buildGuideSection('스톱', '언제든 스톱을 외쳐 게임을 끝낼 수 있습니다.\n남은 카드 점수가 가장 적은 사람이 승리합니다.', Icons.stop_circle, titleSize, textSize, Colors.red),
                      const SizedBox(height: 16),
                      _buildGuideSection('카드 점수', 'A=1점, 2~9=숫자점, J=10점, Q=11점, K=12점', Icons.style, titleSize, textSize),
                      const SizedBox(height: 16),
                      _buildGuideSection('점수 계산', '• 승자: 다른 플레이어 손패와의 차이 합계를 획득\n• 패자: 승자와의 손패 차이만큼 감점\n• 훌라(등록 없이 승리): 점수 2배', Icons.calculate, titleSize, textSize, Colors.lightGreenAccent),
                      const SizedBox(height: 16),
                      _buildGuideSection('스톱 실패 페널티', '스톱을 외쳤지만 최저 점수가 아닌 경우:\n• 승자가 받을 점수 전부를 스톱한 사람이 부담\n• 다른 플레이어는 감점 없음', Icons.warning, titleSize, textSize, Colors.orange),
                    ],
                  ),
                ),
              ),
              // 닫기 버튼
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '확인',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuideSection(String title, String content, IconData icon, double titleSize, double textSize, [Color? titleColor]) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: titleColor ?? Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: titleColor ?? Colors.amber,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: textSize,
              color: Colors.white,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
