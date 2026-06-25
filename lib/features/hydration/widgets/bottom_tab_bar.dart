import 'package:flutter/cupertino.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_icon_image.dart';

enum WaterTab { home, log, insights, target }

class BottomTabBar extends StatelessWidget {
  const BottomTabBar({
    required this.current,
    required this.onChanged,
    super.key,
  });

  final WaterTab current;
  final ValueChanged<WaterTab> onChanged;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: AppSpacing.tabBottom,
      child: Container(
        height: AppSpacing.tabHeight,
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
        decoration: BoxDecoration(
          color: AppColors.tabBar,
          borderRadius: BorderRadius.circular(AppSpacing.tabRadius),
          border: Border.all(color: AppColors.stroke.withValues(alpha: .7)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x55000000),
              blurRadius: 30,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: WaterTab.values.map((tab) {
            final active = tab == current;
            return Expanded(
              child: CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => onChanged(tab),
                child: _TabItem(tab: tab, active: active),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({required this.tab, required this.active});

  final WaterTab tab;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.aqua : AppColors.secondaryText;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppIconImage(asset: _asset, size: 23, color: color),
        const SizedBox(height: 4),
        Text(
          _label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 5),
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: active ? 36 : 0,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.aqua,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ],
    );
  }

  String get _label => switch (tab) {
    WaterTab.home => 'Home',
    WaterTab.log => 'Log',
    WaterTab.insights => 'Insights',
    WaterTab.target => 'Target',
  };

  String get _asset => switch (tab) {
    WaterTab.home => AppAssets.iconHome,
    WaterTab.log => AppAssets.iconLog,
    WaterTab.insights => AppAssets.iconInsights,
    WaterTab.target => AppAssets.iconTarget,
  };
}
