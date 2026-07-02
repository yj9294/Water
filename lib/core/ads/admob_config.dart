import 'dart:io';

import 'package:flutter/foundation.dart';

class AdMobConfig {
  const AdMobConfig._();

  static const androidTestAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const iosTestAppId = 'ca-app-pub-3940256099942544~1458002511';

  static const androidTestRewardedUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const iosTestRewardedUnitId = 'ca-app-pub-3940256099942544/1712485313';

  static const _androidReleaseRewardedUnitId = String.fromEnvironment(
    'ADMOB_ANDROID_REWARDED_ID',
  );
  static const _iosReleaseRewardedUnitId = String.fromEnvironment(
    'ADMOB_IOS_REWARDED_ID',
    defaultValue: 'ca-app-pub-5299142433513130/2292959136',
  );

  static String get rewardedAdUnitId {
    if (kDebugMode || kProfileMode) {
      return Platform.isIOS ? iosTestRewardedUnitId : androidTestRewardedUnitId;
    }

    final releaseId = Platform.isIOS
        ? _iosReleaseRewardedUnitId
        : _androidReleaseRewardedUnitId;
    if (releaseId.isEmpty) {
      throw StateError(
        'Missing release AdMob rewarded unit id. Pass '
        '--dart-define=ADMOB_ANDROID_REWARDED_ID=... and '
        '--dart-define=ADMOB_IOS_REWARDED_ID=... for release builds.',
      );
    }
    return releaseId;
  }
}
