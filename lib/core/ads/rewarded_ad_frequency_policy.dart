class RewardedAdFrequencyPolicy {
  RewardedAdFrequencyPolicy({this.interval = 3}) : _mustShowOnNextRecord = true;

  final int interval;

  bool _mustShowOnNextRecord;
  int _recordsSinceRewardedAd = 0;

  bool get shouldShowRewardedAd =>
      _mustShowOnNextRecord || _recordsSinceRewardedAd >= interval;

  void markRecordSavedWithoutAd() {
    _mustShowOnNextRecord = false;
    _recordsSinceRewardedAd += 1;
  }

  void markRewardEarned() {
    _mustShowOnNextRecord = false;
    _recordsSinceRewardedAd = 0;
  }
}
