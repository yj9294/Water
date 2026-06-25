import 'package:flutter/cupertino.dart';
import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static CupertinoThemeData get theme => const CupertinoThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.aqua,
    scaffoldBackgroundColor: AppColors.bg,
    textTheme: CupertinoTextThemeData(
      primaryColor: AppColors.text,
      textStyle: TextStyle(
        fontFamily: '.SF Pro Text',
        color: AppColors.text,
        letterSpacing: 0,
      ),
    ),
  );
}
