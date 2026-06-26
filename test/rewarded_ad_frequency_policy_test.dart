import 'package:flutter_test/flutter_test.dart';
import 'package:water/core/ads/rewarded_ad_frequency_policy.dart';

void main() {
  test('requires rewarded ad on first record after cold start', () {
    final policy = RewardedAdFrequencyPolicy();

    expect(policy.shouldShowRewardedAd, isTrue);
  });

  test('requires rewarded ad after every three saved records', () {
    final policy = RewardedAdFrequencyPolicy();

    policy.markRewardEarned();
    expect(policy.shouldShowRewardedAd, isFalse);

    policy.markRecordSavedWithoutAd();
    expect(policy.shouldShowRewardedAd, isFalse);

    policy.markRecordSavedWithoutAd();
    expect(policy.shouldShowRewardedAd, isFalse);

    policy.markRecordSavedWithoutAd();
    expect(policy.shouldShowRewardedAd, isTrue);
  });

  test('does not advance frequency when reward was not earned', () {
    final policy = RewardedAdFrequencyPolicy();

    expect(policy.shouldShowRewardedAd, isTrue);
    expect(policy.shouldShowRewardedAd, isTrue);
  });
}
