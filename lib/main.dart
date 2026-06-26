import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/ads/rewarded_ad_service.dart';
import 'core/storage/app_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/hydration/pages/hydration_shell_page.dart';
import 'features/hydration/providers/hydration_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  runApp(WaterApp(storage: AppStorage(prefs)));
}

class WaterApp extends StatelessWidget {
  const WaterApp({required this.storage, this.rewardedAdService, super.key});

  final AppStorage storage;
  final RewardedAdService? rewardedAdService;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => rewardedAdService ?? RewardedAdService()),
        ChangeNotifierProvider(create: (_) => HydrationProvider(storage)),
      ],
      child: CupertinoApp(
        title: 'HydraPal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              textScaler: media.textScaler.clamp(
                minScaleFactor: 1,
                maxScaleFactor: 1.18,
              ),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const HydrationShellPage(),
      ),
    );
  }
}
