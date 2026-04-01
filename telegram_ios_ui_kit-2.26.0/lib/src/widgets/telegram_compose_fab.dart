import 'package:flutter/material.dart';

import '../theme/telegram_theme.dart';

class TelegramComposeFab extends StatelessWidget {
  const TelegramComposeFab({
    super.key,
    this.label = 'Compose',
    this.icon = Icons.edit_rounded,
    this.extended = true,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool extended;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    if (extended) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: theme.colors.linkColor,
        foregroundColor: theme.colors.buttonTextColor,
        icon: Icon(icon),
        label: Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colors.buttonTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: theme.colors.linkColor,
      foregroundColor: theme.colors.buttonTextColor,
      child: Icon(icon),
    );
  }
}
