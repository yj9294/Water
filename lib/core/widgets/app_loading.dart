import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';

class AppLoading {
  const AppLoading._();

  static Future<T> run<T>(
    BuildContext context,
    Future<T> Function() task, {
    String message = 'Loading...',
  }) async {
    showCupertinoDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _AppLoadingDialog(message: message),
    );

    try {
      return await task();
    } finally {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }
}

class _AppLoadingDialog extends StatelessWidget {
  const _AppLoadingDialog({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 142,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: const Color(0xF0061326),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.stroke),
          boxShadow: const [
            BoxShadow(
              color: Color(0x66000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CupertinoActivityIndicator(color: AppColors.aqua, radius: 15),
            const SizedBox(height: 14),
            Text(
              message,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
