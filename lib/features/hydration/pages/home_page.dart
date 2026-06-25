import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../providers/hydration_provider.dart';
import '../widgets/bottom_tab_bar.dart';
import '../widgets/soft_card.dart';
import '../widgets/water_drop.dart';

class HomePage extends StatelessWidget {
  const HomePage({required this.onOpenTab, super.key});

  final ValueChanged<WaterTab> onOpenTab;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HydrationProvider>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageX,
        88,
        AppSpacing.pageX,
        112,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HydraPal', style: AppTextStyles.largeTitle),
                  const SizedBox(height: 6),
                  Text(
                    'Good morning. Keep your hydration gentle and steady.',
                    style: AppTextStyles.body.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            _SettingsButton(onTap: () => onOpenTab(WaterTab.target)),
          ],
        ),
        const SizedBox(height: 18),
        _HomeHero(onTap: () => onOpenTab(WaterTab.log)),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: "Today's goal",
                value: '${provider.dailyTargetMl} ml',
                note: 'WHO based',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Consumed',
                value: '${provider.todayConsumedMl} ml',
                note: '+${provider.quickAmounts[1]} ml at noon',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _MenuRow(
          title: 'Quick hydration',
          subtitle: 'Log 150, 250, or 500 ml in one tap.',
          icon: const WaterDrop(width: 22, height: 26),
          onTap: () => onOpenTab(WaterTab.log),
        ),
        _MenuRow(
          title: 'Water tracking',
          subtitle: 'Review completion rate and daily records.',
          icon: const Icon(
            CupertinoIcons.chart_bar_alt_fill,
            color: AppColors.aqua,
            size: 23,
          ),
          onTap: () => onOpenTab(WaterTab.insights),
        ),
        _MenuRow(
          title: 'Smart target',
          subtitle: 'Calculate goals with weight and activity.',
          icon: const Icon(
            CupertinoIcons.scope,
            color: AppColors.aqua,
            size: 23,
          ),
          onTap: () => onOpenTab(WaterTab.target),
        ),
      ],
    );
  }
}

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFF2A5279).withValues(alpha: .75),
          borderRadius: BorderRadius.circular(21),
          border: Border.all(color: const Color(0xFF3D6388)),
        ),
        child: const Icon(
          CupertinoIcons.gear_alt,
          color: AppColors.text,
          size: 22,
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        height: 210,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBlue, Color(0xFF0E5FB8)],
          ),
          borderRadius: BorderRadius.circular(AppSpacing.heroRadius),
          border: Border.all(color: const Color(0xFF3C92E8)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -4,
              bottom: -6,
              child: WaterDrop(
                color: const Color(0xFFB8F8FF),
                width: 116,
                height: 142,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today feels\nlighter with\nwater.',
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 26),
                ),
                const Spacer(),
                Text(
                  '32% done. Three small sips\ncan move the day.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.text,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.aqua,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: const Text(
                    'Start sipping',
                    style: TextStyle(
                      color: AppColors.bg,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.note,
  });

  final String label;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          const Spacer(),
          FittedBox(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            style: AppTextStyles.label.copyWith(color: AppColors.mint),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: SoftCard(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF214964),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: icon,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
