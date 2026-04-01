import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchGroupHeader extends StatelessWidget {
  const TelegramSearchGroupHeader({
    super.key,
    required this.label,
    this.count,
    this.icon,
    this.padding = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      TelegramSpacing.s,
      TelegramSpacing.l,
      TelegramSpacing.xs,
    ),
  });

  final String label;
  final int? count;
  final IconData? icon;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: theme.colors.subtitleTextColor),
            const SizedBox(width: TelegramSpacing.xs),
          ],
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colors.subtitleTextColor,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (count != null)
            Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colors.subtitleTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }
}
