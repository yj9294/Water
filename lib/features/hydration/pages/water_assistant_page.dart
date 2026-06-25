import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../providers/hydration_provider.dart';
import '../widgets/ios_nav_bar.dart';
import '../widgets/soft_card.dart';
import '../widgets/water_drop.dart';

class WaterAssistantPage extends StatelessWidget {
  const WaterAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HydrationProvider>();
    final progress = provider.todayProgress.clamp(0.0, 1.0);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageX,
        58,
        AppSpacing.pageX,
        112,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        const IosNavBar(title: 'Drinking Assistant', showBack: false),
        const SizedBox(height: 10),
        SoftCard(
          height: 220,
          radius: 26,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DateFormatter.friendly(DateTime.now()),
                style: AppTextStyles.label.copyWith(color: AppColors.mutedText),
              ),
              const SizedBox(height: 12),
              Text(
                'Did you drink\nwater today?',
                style: AppTextStyles.cardTitle.copyWith(fontSize: 27),
              ),
              const Spacer(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "Today's goal",
                    style: AppTextStyles.sectionTitle.copyWith(fontSize: 15),
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${provider.todayConsumedMl} / ${provider.dailyTargetMl} ml',
                        style: const TextStyle(
                          color: AppColors.aqua,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  height: 10,
                  color: const Color(0xFF50627A),
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: progress,
                    child: Container(color: AppColors.aqua),
                  ),
                ),
              ),
              const SizedBox(height: 9),
              Text(
                'Progress ${(provider.todayProgress * 100).round()}%',
                style: AppTextStyles.label,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Quick hydration', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 10),
        Row(
          children: provider.quickAmounts.map((amount) {
            final color = switch (amount) {
              <= 150 => AppColors.aqua,
              <= 250 => AppColors.mint,
              _ => AppColors.warm,
            };
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: amount == provider.quickAmounts.last ? 0 : 10,
                ),
                child: _QuickAmountButton(
                  amount: amount,
                  color: color,
                  onTap: () =>
                      context.read<HydrationProvider>().addWater(amount),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        SoftCard(
          height: 86,
          color: const Color(0xFF2E3142),
          borderColor: const Color(0xFF665743),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF2B5C70),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'Σ',
                  style: TextStyle(
                    color: AppColors.aqua,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Intelligent target calculation',
                      style: AppTextStyles.sectionTitle.copyWith(
                        color: const Color(0xFFFFE6A3),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '35 ml × weight × activity coefficient, easy and transparent.',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text("This week's record", style: AppTextStyles.sectionTitle),
        const SizedBox(height: 10),
        SoftCard(
          height: 86,
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: _WeekChart(values: provider.weekProgress),
        ),
      ],
    );
  }
}

class _QuickAmountButton extends StatelessWidget {
  const _QuickAmountButton({
    required this.amount,
    required this.color,
    required this.onTap,
  });

  final int amount;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Container(
        height: 92,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: const Color(0xFF1E6383)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WaterDrop(color: color, width: 30, height: 36),
            const SizedBox(height: 8),
            Text(
              '$amount ml',
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeekChart extends StatelessWidget {
  const _WeekChart({required this.values});

  final List<double> values;

  @override
  Widget build(BuildContext context) {
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final value = values[index].clamp(0.12, 1.0);
        return Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: 32,
                height: 18 + value * 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: index > 4
                        ? const [Color(0xFF2A5A78), Color(0xFF2A5A78)]
                        : const [AppColors.aqua, AppColors.primaryBlue],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                labels[index],
                style: AppTextStyles.label.copyWith(fontSize: 10),
              ),
            ],
          ),
        );
      }),
    );
  }
}
