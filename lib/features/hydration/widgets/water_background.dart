import 'package:flutter/cupertino.dart';

import '../../../core/theme/app_colors.dart';

class WaterBackground extends StatelessWidget {
  const WaterBackground({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0B335F), AppColors.screenTop, AppColors.bg],
          stops: [0, .42, 1],
        ),
      ),
      child: child,
    );
  }
}
