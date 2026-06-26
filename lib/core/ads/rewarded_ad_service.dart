import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'admob_config.dart';
import 'rewarded_ad_frequency_policy.dart';

enum RewardedAdResult { notRequired, rewarded, failed, dismissed }

class RewardedAdService {
  RewardedAdService({RewardedAdFrequencyPolicy? policy})
    : _policy = policy ?? RewardedAdFrequencyPolicy();

  final RewardedAdFrequencyPolicy _policy;

  bool get shouldShowRewardedAd => _policy.shouldShowRewardedAd;

  void markRecordSavedWithoutAd() => _policy.markRecordSavedWithoutAd();

  Future<RewardedAdResult> showIfNeeded() async {
    if (!_policy.shouldShowRewardedAd) {
      return RewardedAdResult.notRequired;
    }

    final ad = await _loadRewardedAd();
    if (ad == null) return RewardedAdResult.failed;

    final completer = Completer<RewardedAdResult>();
    var earnedReward = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(
            earnedReward
                ? RewardedAdResult.rewarded
                : RewardedAdResult.dismissed,
          );
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(RewardedAdResult.failed);
        }
      },
    );

    await ad.show(
      onUserEarnedReward: (adWithoutView, rewardItem) {
        earnedReward = true;
        _policy.markRewardEarned();
      },
    );

    return completer.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        ad.dispose();
        return earnedReward
            ? RewardedAdResult.rewarded
            : RewardedAdResult.failed;
      },
    );
  }

  Future<RewardedAd?> _loadRewardedAd() {
    final completer = Completer<RewardedAd?>();
    RewardedAd.load(
      adUnitId: AdMobConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: completer.complete,
        onAdFailedToLoad: (_) => completer.complete(null),
      ),
    );
    return completer.future;
  }
}
