import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  // 보상형 광고 ID (디버그 모드에서는 테스트 ID 사용)
  static String get _rewardedAdUnitId {
    if (kDebugMode) {
      // 테스트 광고 ID
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/5224354917'
          : 'ca-app-pub-3940256099942544/1712485313';
    }
    // 실제 광고 ID
    return 'ca-app-pub-8361977398389047/8967396668';
  }

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  bool get isRewardedAdReady => _isRewardedAdReady;

  /// 보상형 광고 로드
  void loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          debugPrint('RewardedAd loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('RewardedAd failed to load: $error');
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  /// 보상형 광고 표시
  /// [onRewarded] 광고 시청 완료 시 호출되는 콜백
  /// [onAdDismissed] 광고가 닫혔을 때 호출되는 콜백
  void showRewardedAd({
    required Function() onRewarded,
    Function()? onAdDismissed,
  }) {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      debugPrint('RewardedAd is not ready');
      // 광고가 준비되지 않았으면 바로 보상 지급
      onRewarded();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedAdReady = false;
        loadRewardedAd(); // 다음 광고 미리 로드
        onAdDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('RewardedAd failed to show: $error');
        ad.dispose();
        _isRewardedAdReady = false;
        loadRewardedAd();
        // 광고 표시 실패 시 보상 지급
        onRewarded();
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('User earned reward: ${reward.amount} ${reward.type}');
        onRewarded();
      },
    );
  }

  /// 리소스 정리
  void dispose() {
    _rewardedAd?.dispose();
  }
}
