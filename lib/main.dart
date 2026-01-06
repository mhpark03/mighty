import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/game_controller.dart';
import 'services/stats_service.dart';
import 'services/ad_service.dart';
import 'screens/home_screen.dart';
import 'screens/game_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // 전체 화면 모드 설정 (상태바 숨기기)
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  // AdMob 초기화
  MobileAds.instance.initialize();

  // 보상형 광고 미리 로드
  AdService().loadRewardedAd();

  runApp(const MightyApp());
}

class MightyApp extends StatelessWidget {
  const MightyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StatsService()..loadStats()),
        ChangeNotifierProvider(create: (context) => GameController()),
      ],
      child: MaterialApp(
        title: 'Mighty',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('ko'),
          Locale('en'),
          Locale('ja'),
          Locale('zh'),
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        home: const GameSelectionScreen(),
      ),
    );
  }
}
