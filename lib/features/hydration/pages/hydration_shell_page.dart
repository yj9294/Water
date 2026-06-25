import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/hydration_provider.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/water_background.dart';
import 'home_page.dart';
import 'smart_target_page.dart';
import 'water_assistant_page.dart';
import 'water_tracking_page.dart';

class HydrationShellPage extends StatefulWidget {
  const HydrationShellPage({super.key});

  @override
  State<HydrationShellPage> createState() => _HydrationShellPageState();
}

class _HydrationShellPageState extends State<HydrationShellPage> {
  WaterTab _tab = WaterTab.home;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppColors.bg,
      child: WaterBackground(
        child: SafeArea(
          top: false,
          child: Consumer<HydrationProvider>(
            builder: (context, provider, _) {
              return Stack(
                children: [
                  Positioned.fill(child: _buildCurrentPage(provider)),
                  BottomTabBar(
                    current: _tab,
                    onChanged: (tab) => setState(() => _tab = tab),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPage(HydrationProvider provider) {
    return switch (_tab) {
      WaterTab.home => HomePage(onOpenTab: (tab) => setState(() => _tab = tab)),
      WaterTab.log => const WaterAssistantPage(),
      WaterTab.insights => const WaterTrackingPage(),
      WaterTab.target => const SmartTargetPage(),
    };
  }
}
