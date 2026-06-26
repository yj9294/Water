import 'package:flutter/cupertino.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_icon_image.dart';

class WaterDrop extends StatelessWidget {
  const WaterDrop({
    this.color = AppColors.aqua,
    this.width = 42,
    this.height = 52,
    super.key,
  });

  final Color color;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AppIconImage(
      asset: AppAssets.iconDropSvg,
      size: height,
      width: width,
      height: height,
      color: color,
    );
  }
}
