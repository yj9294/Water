import 'package:flutter/cupertino.dart';

class AppIconImage extends StatelessWidget {
  const AppIconImage({
    required this.asset,
    required this.size,
    this.color,
    super.key,
  });

  final String asset;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      color: color,
      filterQuality: FilterQuality.high,
    );
  }
}
