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
        112,
      ),
      physics: const BouncingScrollPhysics(),
      children: [
        const IosNavBar(title: 'Water Tracking', showBack: false),
        const SizedBox(height: 10),
        SoftCard(
          height: 350,
          radius: 26,
          child: Column(
            children: [
              SizedBox(
                width: 230,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size(210, 210),
                      painter: _RingPainter(provider.todayProgress.clamp(0, 1)),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(provider.todayProgress * 100).round()}%',
                          style: const TextStyle(
                            fontSize: 46,
                            height: 1,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
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
    return SoftCard(
      height: 94,
      color: const Color(0xFF40516C),
      borderColor: const Color(0xFF536780),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.label),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
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
        height: 64,
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
                    style: const TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Weight: ${summary.weightKg.round()} kg',
                    style: AppTextStyles.label,
                  ),
                ],
              ),
            ),
            Text(
              '${summary.consumedMl}/${summary.targetMl}',
              style: const TextStyle(
                color: AppColors.aqua,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
