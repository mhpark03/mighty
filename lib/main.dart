import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/game_controller.dart';
import 'services/stats_service.dart';
import 'services/seven_card/seven_card_controller.dart';
import 'services/seven_card/seven_card_stats_service.dart';
import 'services/hi_lo/hi_lo_controller.dart';
import 'services/hi_lo/hi_lo_stats_service.dart';
import 'services/hula/hula_stats_service.dart';
import 'services/onecard/onecard_stats_service.dart';
import 'services/hearts/hearts_stats_service.dart';
import 'services/ad_service.dart';
import 'screens/game_selection_screen.dart';

void main() {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 전체 화면 모드 설정 (상태바 숨기기)
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  // AdMob 초기화 (비동기로 진행하여 스플래시 화면 먼저 표시)
  MobileAds.instance.initialize().then((_) {
    AdService().loadRewardedAd();
  });

  runApp(const MightyApp());
}

class MightyApp extends StatelessWidget {
  const MightyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StatsService()..loadStats()),
        ChangeNotifierProvider(create: (context) => SevenCardStatsService()..loadStats()),
        ChangeNotifierProvider(create: (context) => HiLoStatsService()..loadStats()),
        ChangeNotifierProvider(create: (context) => HulaStatsService()..loadStats()),
        ChangeNotifierProvider(create: (context) => OneCardStatsService()..loadStats()),
        ChangeNotifierProvider(create: (context) => HeartsStatsService()..loadStats()),
        ChangeNotifierProvider(create: (context) => GameController()),
        ChangeNotifierProvider(create: (context) => SevenCardController()),
        ChangeNotifierProvider(create: (context) => HiLoController()),
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
