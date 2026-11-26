import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_dimens.dart';

const _maxWidth = 420.0;
const _visible = Duration(seconds: 3);
const _fade = Duration(milliseconds: 160);

OverlayEntry? _current;
Timer? _timer;

void showMettleSnackBar(BuildContext context, String message) {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay != null) showMettleSnackBarIn(overlay, message);
}

void showMettleSnackBarIn(OverlayState overlay, String message) {
  if (!overlay.mounted) return;

  dismissMettleSnackBar();

  final entry = OverlayEntry(builder: (_) => _Toast(message: message));
  _current = entry;
  overlay.insert(entry);
  _timer = Timer(_visible, dismissMettleSnackBar);
}

void dismissMettleSnackBar() {
  _timer?.cancel();
  _timer = null;

  final entry = _current;
  _current = null;
  if (entry != null && entry.mounted) entry.remove();
}

class _Toast extends StatefulWidget {
  const _Toast({required this.message});

  final String message;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: _fade)..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final available = MediaQuery.sizeOf(context).width - AppDimens.md * 2;

    return IgnorePointer(
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: AppDimens.lg),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -0.35),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeOut),
              ),
              child: FadeTransition(
                opacity: _controller,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: math.max(math.min(_maxWidth, available), 0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimens.lg,
                        vertical: AppDimens.md,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.inverseSurface,
                        borderRadius: BorderRadius.circular(
                          AppDimens.radiusCard,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 28,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onInverseSurface,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
