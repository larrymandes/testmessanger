import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramDateSeparator extends StatelessWidget {
  const TelegramDateSeparator({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TelegramSpacing.s),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TelegramSpacing.s,
            vertical: TelegramSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: theme.colors.secondaryBgColor,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colors.subtitleTextColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
