import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/utils/date_formatter.dart';
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
    final progressPercent = (provider.todayProgress * 100)
        .clamp(0, 999)
        .round();
    final latestRecord = provider.latestTodayRecord;
    final consumedNote = latestRecord == null
        ? 'First sip pending'
        : '+${latestRecord.amountMl} ml · ${DateFormatter.hm(latestRecord.createdAt)}';
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageX,
        88,
        AppSpacing.pageX,
        AppSpacing.pageBottomWithTab,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('HydraPal', style: AppTextStyles.largeTitle),
                  const SizedBox(height: 6),
                  Text(
                    'Good morning. Keep your hydration gentle and steady.',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body.copyWith(fontSize: 14),
                  ),
                ],
              ),
            ),
            _SettingsButton(onTap: () => onOpenTab(WaterTab.target)),
          ],
        ),
        const SizedBox(height: 18),
        _HomeHero(
          progressPercent: progressPercent,
          onTap: () => onOpenTab(WaterTab.log),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                label: "Today's goal",
                value: '${provider.dailyTargetMl} ml',
                note: 'Profile based',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Consumed',
                value: '${provider.todayConsumedMl} ml',
                note: consumedNote,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _MenuRow(
          title: 'Quick hydration',
          subtitle: 'Log ${provider.quickAmounts.join(', ')} ml in one tap.',
          iconAsset: AppAssets.iconQuickHydrationSvg,
          onTap: () => onOpenTab(WaterTab.log),
        ),
        _MenuRow(
          title: 'Water tracking',
          subtitle: 'Review completion rate and daily records.',
          iconAsset: AppAssets.iconMenuTrackingSvg,
          onTap: () => onOpenTab(WaterTab.insights),
        ),
        _MenuRow(
          title: 'Smart target',
          subtitle: 'Calculate goals with weight and activity.',
          iconAsset: AppAssets.iconMenuTargetSvg,
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
        child: const AppIconImage(
          asset: AppAssets.iconSettingsSvg,
          size: 22,
          color: AppColors.text,
        ),
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({required this.progressPercent, required this.onTap});

  final int progressPercent;
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
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: 28,
              top: 42,
              child: WaterDrop(
                color: const Color(0x99B8F8FF),
                width: 52,
                height: 66,
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
                  '$progressPercent% done. Three small sips\ncan move the day.',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.text,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  constraints: const BoxConstraints(minHeight: 38),
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
      height: 108,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label,
          ),
          const Spacer(),
          SizedBox(
            height: 34,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
    required this.iconAsset,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: SoftCard(
          height: 68,
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
                child: AppIconImage(
                  asset: iconAsset,
                  size: 23,
                  color: AppColors.aqua,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
