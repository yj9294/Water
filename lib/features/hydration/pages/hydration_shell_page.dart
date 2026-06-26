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
  late final List<Widget> _pages = [
    HomePage(onOpenTab: _openTab),
    const WaterAssistantPage(),
    const WaterTrackingPage(),
    const SmartTargetPage(),
  ];

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
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      child: KeyedSubtree(
                        key: ValueKey(_tab),
                        child: IndexedStack(
                          index: _tab.index,
                          children: _pages,
                        ),
                      ),
                    ),
                  ),
                  BottomTabBar(current: _tab, onChanged: _openTab),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _openTab(WaterTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
  }
}
