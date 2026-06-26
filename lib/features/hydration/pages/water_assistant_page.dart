import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/ads/rewarded_ad_service.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_icon_image.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_toast.dart';
import '../providers/hydration_provider.dart';
import '../widgets/ios_nav_bar.dart';
import '../widgets/soft_card.dart';
import '../widgets/water_drop.dart';

class WaterAssistantPage extends StatefulWidget {
  const WaterAssistantPage({super.key});

  @override
  State<WaterAssistantPage> createState() => _WaterAssistantPageState();
}

class _WaterAssistantPageState extends State<WaterAssistantPage> {
  final TextEditingController _customAmountController = TextEditingController();

  @override
  void dispose() {
    _customAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HydrationProvider>();
    final progress = provider.todayProgress.clamp(0.0, 1.0);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pageX,
          58,
          AppSpacing.pageX,
          AppSpacing.pageBottomWithTab,
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
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.mutedText,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Did you drink\nwater today?',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 27),
                ),
                const Spacer(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "Today's goal",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: provider.quickAmounts.asMap().entries.map((entry) {
              final amount = entry.value;
              final color = switch (amount) {
                <= 150 => AppColors.aqua,
                <= 250 => AppColors.mint,
                _ => AppColors.warm,
              };
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: entry.key == provider.quickAmounts.length - 1
                        ? 0
                        : 10,
                  ),
                  child: _QuickAmountButton(
                    amount: amount,
                    color: color,
                    onTap: () async {
                      HapticFeedback.selectionClick();
                      await _recordWater(amount);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          _CustomAmountCard(
            controller: _customAmountController,
            onAdd: _addCustomAmount,
          ),
          const SizedBox(height: 14),
          SoftCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  child: const AppIconImage(
                    asset: AppAssets.iconCalculationSvg,
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
                        'Intelligent target calculation',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: const Color(0xFFFFE6A3),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'A personal tracking estimate. It is not medical advice.',
                        maxLines: 3,
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
            height: 98,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            child: _WeekChart(values: provider.weekProgress),
          ),
        ],
      ),
    );
  }

  Future<void> _addCustomAmount() async {
    final raw = _customAmountController.text.trim();
    final amount = int.tryParse(raw);
    if (amount == null || amount < 50 || amount > 2000) {
      AppToast.show(context, 'Enter 50-2000 ml.');
      return;
    }

    final saved = await _recordWater(amount);
    if (!saved) return;

    _customAmountController.clear();
    if (!mounted) return;
    FocusScope.of(context).unfocus();
  }

  Future<bool> _recordWater(int amount) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final ads = context.read<RewardedAdService>();
    final provider = context.read<HydrationProvider>();

    final adResult = await AppLoading.run(
      context,
      ads.showIfNeeded,
      message: ads.shouldShowRewardedAd ? 'Loading reward...' : 'Saving...',
    );
    if (!mounted) return false;

    switch (adResult) {
      case RewardedAdResult.failed:
        AppToast.show(context, 'Reward ad failed to load. Please try again.');
        return false;
      case RewardedAdResult.dismissed:
        AppToast.show(context, 'Watch the reward ad to save this record.');
        return false;
      case RewardedAdResult.rewarded:
        await provider.addWater(amount);
        if (!mounted) return false;
        AppToast.show(context, 'Added $amount ml');
        return true;
      case RewardedAdResult.notRequired:
        await provider.addWater(amount);
        if (!mounted) return false;
        ads.markRecordSavedWithoutAd();
        AppToast.show(context, 'Added $amount ml');
        return true;
    }
  }
}

class _CustomAmountCard extends StatelessWidget {
  const _CustomAmountCard({required this.controller, required this.onAdd});

  final TextEditingController controller;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom amount',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C2239),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2B668C)),
                  ),
                  child: CupertinoTextField.borderless(
                    controller: controller,
                    padding: EdgeInsets.zero,
                    textAlignVertical: TextAlignVertical.center,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    textInputAction: TextInputAction.done,
                    placeholder: 'Enter ml',
                    placeholderStyle: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                    suffix: Padding(
                      padding: const EdgeInsets.only(right: 2),
                      child: Center(
                        widthFactor: 1,
                        child: Text(
                          'ml',
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.aqua,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                    onSubmitted: (_) => onAdd(),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onAdd,
                child: Container(
                  width: 76,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.aqua,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Add',
                    style: TextStyle(
                      color: AppColors.bg,
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
      children: List.generate(7, (index) {
        final value = values[index].clamp(0.12, 1.0);
        return Expanded(
          child: Column(
            children: [
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: FractionallySizedBox(
                    heightFactor: value,
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      width: 32,
                      constraints: const BoxConstraints(minHeight: 14),
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
                  ),
                ),
              ),
              const SizedBox(height: 5),
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
