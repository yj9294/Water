import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/activity_level.dart';
import '../providers/hydration_provider.dart';
import '../widgets/ios_nav_bar.dart';
import '../widgets/soft_card.dart';
import '../widgets/water_drop.dart';

class SmartTargetPage extends StatelessWidget {
  const SmartTargetPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HydrationProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageX,
        58,
        AppSpacing.pageX,
        112,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        const IosNavBar(title: 'Smart Target', showBack: false),
        const SizedBox(height: 10),
        _Hero(),
        const SizedBox(height: 14),
        const Text('Personal profile', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 8),
        SoftCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _ProfileRow(
                label: 'Weight',
                value: '${provider.weightKg.round()} kg',
                onTap: () => _showWeightPicker(context, provider),
              ),
              const _Divider(),
              _ProfileRow(
                label: 'Daily target',
                value: '${provider.dailyTargetMl} ml',
              ),
              const _Divider(),
              _ProfileRow(
                label: 'Apple Health',
                value: provider.healthEnabled ? 'On' : 'Off',
                onTap: () =>
                    provider.toggleHealthEnabled(!provider.healthEnabled),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Activity level', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 8),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose a coefficient for today's movement.",
                style: AppTextStyles.label,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ActivityLevel.values.map((level) {
                  final selected = level == provider.activityLevel;
                  return CupertinoButton(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.zero,
                    onPressed: () => provider.updateActivityLevel(level),
                    child: Container(
                      height: 30,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primaryBlue
                            : const Color(0xFF3A4D68),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: selected
                              ? AppColors.primaryBlue
                              : const Color(0xFF52657F),
                        ),
                      ),
                      child: Text(
                        level.label,
                        style: TextStyle(
                          color: selected
                              ? AppColors.bg
                              : AppColors.secondaryText,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        const Text('Quick amounts', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 8),
        Row(
          children: List.generate(provider.quickAmounts.length, (index) {
            final amount = provider.quickAmounts[index];
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index == provider.quickAmounts.length - 1 ? 0 : 10,
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () =>
                      _showQuickAmountPicker(context, provider, index),
                  child: Container(
                    height: 58,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF1E6383)),
                    ),
                    child: Text(
                      '$amount ml',
                      style: const TextStyle(
                        color: AppColors.text,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 18),
        Container(
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.aqua,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Text(
            'Save target',
            style: TextStyle(
              color: AppColors.bg,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  void _showWeightPicker(BuildContext context, HydrationProvider provider) {
    _showNumberPicker(
      context,
      title: 'Weight',
      values: List.generate(281, (index) => index + 20),
      initial: provider.weightKg.round(),
      suffix: 'kg',
      onSelected: (value) => provider.updateWeight(value.toDouble()),
    );
  }

  void _showQuickAmountPicker(
    BuildContext context,
    HydrationProvider provider,
    int index,
  ) {
    _showNumberPicker(
      context,
      title: 'Quick amount',
      values: List.generate(40, (i) => (i + 1) * 50),
      initial: provider.quickAmounts[index],
      suffix: 'ml',
      onSelected: (value) => provider.updateQuickAmount(index, value),
    );
  }

  void _showNumberPicker(
    BuildContext context, {
    required String title,
    required List<int> values,
    required int initial,
    required String suffix,
    required ValueChanged<int> onSelected,
  }) {
    var selectedIndex = values.indexOf(initial);
    if (selectedIndex < 0) selectedIndex = 0;
    showCupertinoModalPopup<void>(
      context: context,
      builder: (_) {
        return Container(
          height: 300,
          color: AppColors.bg,
          child: Column(
            children: [
              SizedBox(
                height: 48,
                child: Row(
                  children: [
                    const SizedBox(width: 16),
                    Text(title, style: AppTextStyles.sectionTitle),
                    const Spacer(),
                    CupertinoButton(
                      child: const Text('Done'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  itemExtent: 42,
                  scrollController: FixedExtentScrollController(
                    initialItem: selectedIndex,
                  ),
                  onSelectedItemChanged: (index) => onSelected(values[index]),
                  children: values
                      .map(
                        (value) => Center(
                          child: Text(
                            '$value $suffix',
                            style: const TextStyle(
                              color: AppColors.text,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryBlue, Color(0xFF0E5FB8)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF3C92E8)),
      ),
      child: Stack(
        children: [
          const Positioned(
            right: 4,
            bottom: -16,
            child: WaterDrop(color: AppColors.mint, width: 108, height: 130),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Build today's\ngoal",
                style: AppTextStyles.cardTitle.copyWith(fontSize: 25),
              ),
              const Spacer(),
              Text(
                'No blind 8 cups. Your body,\nyour rhythm.',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.text,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({required this.label, required this.value, this.onTap});

  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: SizedBox(
        height: 49,
        child: Row(
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppColors.text,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 74),
              child: Container(
                height: 28,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: const Color(0xFF2C5873),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.aqua,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: const Color(0xFF52627A).withValues(alpha: .55),
    );
  }
}
