import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/banner_ad_widget.dart';
import 'hula_screen.dart';

class HulaHomeScreen extends StatelessWidget {
  const HulaHomeScreen({super.key});

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
                    SizedBox(height: sectionGap),

                    // 타이틀
                    Icon(
                      Icons.style,
                      size: isSmallScreen ? 48 : 60,
                      color: Colors.amber,
                    ),
                    SizedBox(height: isSmallScreen ? 8 : 12),
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
                    SizedBox(height: sectionGap * 2),

                    // 게임 시작 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HulaScreen(
                                playerCount: 4,
                                difficulty: HulaDifficulty.hard,
                                resumeGame: false,
                              ),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.play_arrow,
                          color: Colors.black,
                          size: buttonIconSize,
                        ),
                        label: Text(
                          l10n.startGame,
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

                    // 게임 설명
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                Icons.people,
                                '4인용 / 어려움',
                                isSmallScreen,
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              _buildInfoRow(
                                Icons.info_outline,
                                '손패의 카드를 모두 등록하거나 버려서 가장 먼저 없애면 승리!',
                                isSmallScreen,
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              _buildInfoRow(
                                Icons.star,
                                '7은 단독으로 등록 가능',
                                isSmallScreen,
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              _buildInfoRow(
                                Icons.celebration,
                                '버린 더미에서 7을 뽑으면 "땡큐"!',
                                isSmallScreen,
                              ),
                              SizedBox(height: isSmallScreen ? 8 : 12),
                              _buildInfoRow(
                                Icons.stop_circle,
                                '언제든 스탑을 외쳐 게임 종료 가능',
                                isSmallScreen,
                              ),
                            ],
                          ),
                        ),
                      ),
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
            const BannerAdWidget(),
          ],
        ),
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
                      _buildGuideSection('땡큐 멜드', '버린 더미에서 7을 뽑으면 "땡큐"를 외치고 특별한 등록을 할 수 있습니다.', Icons.celebration, titleSize, textSize, Colors.cyan),
                      const SizedBox(height: 16),
                      _buildGuideSection('스탑', '언제든 스탑을 외쳐 게임을 끝낼 수 있습니다. 남은 카드 점수가 가장 적은 사람이 승리합니다.', Icons.stop_circle, titleSize, textSize, Colors.red),
                      const SizedBox(height: 16),
                      _buildGuideSection('점수 계산', 'A=1점, 2~9=숫자점, J=10점, Q=11점, K=12점', Icons.calculate, titleSize, textSize),
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
