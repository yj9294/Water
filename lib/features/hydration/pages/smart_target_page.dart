import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_toast.dart';
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
        AppSpacing.pageBottomWithTab,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
        CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _saveTarget(context, provider),
          child: Container(
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.aqua,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Done',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppColors.bg,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const _OfficialSourcesCard(),
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

  Future<void> _saveTarget(
    BuildContext context,
    HydrationProvider provider,
  ) async {
    await provider.saveTargetSettings();
    if (!context.mounted) return;
    AppToast.show(
      context,
      'Settings saved. Daily target is ${provider.dailyTargetMl} ml.',
    );
  }
}

class _OfficialSourcesCard extends StatelessWidget {
  const _OfficialSourcesCard();

  static final Uri _cdc = Uri.parse(
    'https://www.cdc.gov/healthy-weight-growth/water-healthy-drinks/index.html',
  );
  static final Uri _nhs = Uri.parse(
    'https://www.nhs.uk/live-well/eat-well/food-guidelines-and-food-labels/water-drinks-nutrition/',
  );
  static final Uri _who = Uri.parse(
    'https://www.who.int/news-room/fact-sheets/detail/drinking-water',
  );

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Official sources',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 6),
          Text(
            'Hydration targets in this app are tracking estimates, not medical advice. For health guidance, refer to official public health sources.',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label,
          ),
          const SizedBox(height: 10),
          _SourceLink(label: 'CDC water and healthier drinks', uri: _cdc),
          _SourceLink(label: 'NHS water, drinks and nutrition', uri: _nhs),
          _SourceLink(label: 'WHO drinking-water fact sheet', uri: _who),
        ],
      ),
    );
  }
}

class _SourceLink extends StatelessWidget {
  const _SourceLink({required this.label, required this.uri});

  final String label;
  final Uri uri;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(vertical: 5),
      onPressed: () => launchUrl(uri, mode: LaunchMode.externalApplication),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.aqua,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const Text(
            'Open',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
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
        clipBehavior: Clip.none,
        children: [
          const Positioned(
            right: 12,
            bottom: 8,
            child: WaterDrop(color: Color(0x9973EFD0), width: 72, height: 90),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Build today's\ngoal",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 25),
              ),
              const Spacer(),
              Text(
                'No blind 8 cups. Your body,\nyour rhythm.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
