import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/storage/app_storage.dart';
import 'core/theme/app_theme.dart';
import 'features/hydration/pages/hydration_shell_page.dart';
import 'features/hydration/providers/hydration_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(WaterApp(storage: AppStorage(prefs)));
}

class WaterApp extends StatelessWidget {
  const WaterApp({required this.storage, super.key});

  final AppStorage storage;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HydrationProvider(storage),
      child: CupertinoApp(
        title: 'HydraPal',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const HydrationShellPage(),
      ),
    );
  }
}
