import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:firebase_core/firebase_core.dart';
import 'l10n/generated/app_localizations.dart';
import 'services/game_controller.dart';
import 'services/stats_service.dart';
import 'services/hula/hula_stats_service.dart';
import 'services/onecard/onecard_stats_service.dart';
import 'services/hearts/hearts_stats_service.dart';
import 'services/ad_service.dart';
import 'screens/game_selection_screen.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 전체 화면 모드 설정 (상태바 숨기기)
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [],
  );

  // Firebase 초기화 (모바일/웹만)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Firebase.initializeApp();
  }

  // AdMob 초기화 (모바일만)
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    _initAds();
  }

  runApp(const MightyApp());
}

Future<void> _initAds() async {
  await MobileAds.instance.initialize();
  RequestConfiguration configuration = RequestConfiguration(
    testDeviceIds: ["7e423abc-74c5-4cb7-9e7b-578adadeb80d"],
  );
  await MobileAds.instance.updateRequestConfiguration(configuration);
  AdService().loadRewardedAd();
}

class MightyApp extends StatelessWidget {
  const MightyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => StatsService()..loadStats()),
        ChangeNotifierProvider(create: (context) => HulaStatsService()..loadStats()),
        ChangeNotifierProvider(create: (context) => OneCardStatsService()..loadStats()),
        ChangeNotifierProvider(create: (context) => HeartsStatsService()..loadStats()),
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
