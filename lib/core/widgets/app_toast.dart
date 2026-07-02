import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppToast {
  const AppToast._();

  static OverlayEntry? _activeEntry;

  static void show(
    BuildContext context,
    String message, {
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    dismiss();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        message: message,
        duration: duration,
        onDismiss: dismiss,
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    final entry = _activeEntry;
    _activeEntry = null;
    if (entry?.mounted ?? false) {
      entry!.remove();
    }
  }
}

class _ToastOverlay extends StatefulWidget {
  const _ToastOverlay({
    required this.message,
    required this.duration,
    required this.onDismiss,
  });

  final String message;
  final Duration duration;
  final VoidCallback onDismiss;

  @override
  State<_ToastOverlay> createState() => _ToastOverlayState();
}

class _ToastOverlayState extends State<_ToastOverlay> {
  Timer? _fadeTimer;
  Timer? _dismissTimer;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    final fadeDuration = const Duration(milliseconds: 180);
    final fadeStart = widget.duration > fadeDuration
        ? widget.duration - fadeDuration
        : Duration.zero;
    _fadeTimer = Timer(fadeStart, () {
      if (mounted) {
        setState(() => _visible = false);
      }
    });
    _dismissTimer = Timer(widget.duration, widget.onDismiss);
  }

  @override
  void dispose() {
    _fadeTimer?.cancel();
    _dismissTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      left: 28,
      right: 28,
      bottom:
          safeBottom +
          AppSpacing.tabBottom +
          AppSpacing.tabHeight +
          AppSpacing.tabGap,
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _visible ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xF0061326),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.stroke),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(
                widget.message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.aqua,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
