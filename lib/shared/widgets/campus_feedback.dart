import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/theme/app_tokens.dart';

enum CampusFeedbackType { success, error, warning, info }

abstract final class CampusFeedback {
  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSuccess(
    BuildContext context, {
    required String message,
  }) {
    return _show(
      context,
      message: message,
      type: CampusFeedbackType.success,
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showError(
    BuildContext context, {
    required String message,
  }) {
    return _show(
      context,
      message: message,
      type: CampusFeedbackType.error,
      duration: const Duration(seconds: 4),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showWarning(
    BuildContext context, {
    required String message,
  }) {
    return _show(
      context,
      message: message,
      type: CampusFeedbackType.warning,
      duration: const Duration(seconds: 4),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showInfo(
    BuildContext context, {
    required String message,
  }) {
    return _show(context, message: message, type: CampusFeedbackType.info);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showUndoable(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
  }) {
    return _show(
      context,
      message: message,
      type: CampusFeedbackType.success,
      duration: const Duration(seconds: 5),
      action: SnackBarAction(label: 'Undo', onPressed: onUndo),
    );
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> _show(
    BuildContext context, {
    required String message,
    required CampusFeedbackType type,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        duration: duration,
        showCloseIcon: action == null,
        content: Semantics(
          liveRegion: true,
          label: message,
          excludeSemantics: true,
          child: Row(
            children: [
              Icon(_iconFor(type), color: Colors.white, size: AppIconSizes.xl),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: _colorFor(type),
        action: action,
      ),
    );
  }

  static IconData _iconFor(CampusFeedbackType type) => switch (type) {
        CampusFeedbackType.success => LucideIcons.circleCheck,
        CampusFeedbackType.error => LucideIcons.circleX,
        CampusFeedbackType.warning => LucideIcons.triangleAlert,
        CampusFeedbackType.info => LucideIcons.info,
      };

  static Color _colorFor(CampusFeedbackType type) => switch (type) {
        CampusFeedbackType.success => AppColors.success,
        CampusFeedbackType.error => AppColors.warning,
        CampusFeedbackType.warning => AppColors.warning,
        CampusFeedbackType.info => AppColors.navySoft,
      };
}
