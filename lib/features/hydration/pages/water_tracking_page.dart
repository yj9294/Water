import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/daily_hydration_summary.dart';
import '../providers/hydration_provider.dart';
import '../widgets/ios_nav_bar.dart';
import '../widgets/soft_card.dart';

class WaterTrackingPage extends StatelessWidget {
  const WaterTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HydrationProvider>();
    final summaries = provider.historicalSummaries;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageX,
        58,
        AppSpacing.pageX,
        AppSpacing.pageBottomWithTab,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        const IosNavBar(title: 'Water Tracking', showBack: false),
        const SizedBox(height: 10),
        SoftCard(
          radius: 26,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 210,
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(190, 190),
                      painter: _RingPainter(provider.todayProgress.clamp(0, 1)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 130,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${(provider.todayProgress * 100).round()}%',
                              maxLines: 1,
                              style: const TextStyle(
                                fontSize: 44,
                                height: 1,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          'Completion rate',
                          style: AppTextStyles.label.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _StatBlock(
                      label: 'Target',
                      value: '${provider.dailyTargetMl}',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _StatBlock(
                      label: 'Consumed',
                      value: '${provider.todayConsumedMl}',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Historical record', style: AppTextStyles.sectionTitle),
        const SizedBox(height: 10),
        if (summaries.isEmpty)
          const SoftCard(
            child: Text('No hydration records yet.', style: AppTextStyles.body),
          )
        else
          ...summaries.take(8).map(_RecordRow.new),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2 - 18;
    final track = Paint()
      ..color = const Color(0xFF506B8B)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24;
    final fill = Paint()
      ..color = AppColors.aqua
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.butt;
    canvas.drawCircle(center, radius, track);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi * progress,
      false,
      fill,
    );
    canvas.drawCircle(
      center,
      radius - 30,
      Paint()..color = const Color(0xFF082553),
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 86,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF40516C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF536780)),
      ),
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
            height: 28,
            child: Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                  ),
                ),
              ),
            ),
          ),
          Text(
            'ml',
            style: AppTextStyles.label.copyWith(color: AppColors.mint),
          ),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  const _RecordRow(this.summary);

  final DailyHydrationSummary summary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SoftCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    summary.dateKey,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Weight: ${summary.weightKg.round()} kg',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.label,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 122),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  '${summary.consumedMl}/${summary.targetMl}',
                  maxLines: 1,
                  style: const TextStyle(
                    color: AppColors.aqua,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
