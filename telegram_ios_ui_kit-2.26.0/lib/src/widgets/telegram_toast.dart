import 'package:flutter/material.dart';

import '../theme/telegram_theme.dart';

class TelegramToast {
  const TelegramToast._();

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> show(
    BuildContext context, {
    required String message,
    String? actionLabel,
    VoidCallback? onActionPressed,
    Duration duration = const Duration(seconds: 2),
  }) {
    final theme = context.telegramTheme;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    return messenger.showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        backgroundColor: theme.colors.textColor.withValues(alpha: 0.92),
        content: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colors.bgColor,
          ),
        ),
        action: actionLabel == null
            ? null
            : SnackBarAction(
                label: actionLabel,
                textColor: theme.colors.linkColor,
                onPressed: onActionPressed ?? () {},
              ),
      ),
    );
  }
}
