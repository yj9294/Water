import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppIconImage extends StatelessWidget {
  const AppIconImage({
    required this.asset,
    required this.size,
    this.width,
    this.height,
    this.color,
    super.key,
  });

  final String asset;
  final double size;
  final double? width;
  final double? height;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (asset.endsWith('.svg')) {
      return SvgPicture.asset(
        asset,
        width: width ?? size,
        height: height ?? size,
        fit: BoxFit.contain,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
      );
    }

    return Image.asset(
      asset,
      width: width ?? size,
      height: height ?? size,
      color: color,
      filterQuality: FilterQuality.high,
    );
  }
}
