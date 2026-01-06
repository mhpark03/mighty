import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../services/seven_card/seven_card_controller.dart';
import '../../widgets/banner_ad_widget.dart';
import 'seven_card_game_screen.dart';

class SevenCardHomeScreen extends StatelessWidget {
  const SevenCardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height - mediaQuery.padding.top - mediaQuery.padding.bottom;
    final isSmallScreen = screenHeight < 600;

    return ChangeNotifierProvider(
      create: (context) => SevenCardController(),
      child: Consumer<SevenCardController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.blue[900],
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 뒤로가기 버튼
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                            ),
                          ),
                          const Spacer(),

                          // 타이틀
                          Icon(
                            Icons.casino,
                            size: isSmallScreen ? 60 : 80,
                            color: Colors.amber,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Text(
                            l10n.sevenCardTitle,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 32 : 42,
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
                          SizedBox(height: isSmallScreen ? 4 : 8),
                          Text(
                            l10n.sevenCardSubtitle,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              color: Colors.white70,
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 32 : 48),

                          // 게임 시작 버튼
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                controller.startNewGame();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChangeNotifierProvider.value(
                                      value: controller,
                                      child: const SevenCardGameScreen(),
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                                size: isSmallScreen ? 24 : 28,
                              ),
                              label: Text(
                                l10n.startGame,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 14 : 18),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),

                          const Spacer(),

                          // 게임 설명
                          Container(
                            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.info_outline, color: Colors.amber, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.sevenCardRules,
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.amber,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: isSmallScreen ? 8 : 12),
                                Text(
                                  l10n.sevenCardRulesText,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.white,
                                    height: 1.5,
                                  ),
                                ),
                              ],
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
      ),
    );
  }
}
