import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const largeTitle = TextStyle(
    fontSize: 30,
    height: 1.08,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    letterSpacing: 0,
  );

  static const cardTitle = TextStyle(
    fontSize: 26,
    height: 1.05,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    letterSpacing: 0,
  );

  static const sectionTitle = TextStyle(
    fontSize: 20,
    height: 1.1,
    fontWeight: FontWeight.w800,
    color: AppColors.text,
    letterSpacing: 0,
  );

  static const body = TextStyle(
    fontSize: 14,
    height: 1.32,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
    letterSpacing: 0,
  );

  static const label = TextStyle(
    fontSize: 12,
    height: 1.15,
    fontWeight: FontWeight.w700,
    color: AppColors.secondaryText,
    letterSpacing: 0,
  );
}
