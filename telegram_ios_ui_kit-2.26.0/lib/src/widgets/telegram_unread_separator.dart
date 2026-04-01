import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramUnreadSeparator extends StatelessWidget {
  const TelegramUnreadSeparator({super.key, this.label = 'Unread Messages'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TelegramSpacing.s),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: theme.colors.separatorColor, height: 1),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: TelegramSpacing.s),
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
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: theme.colors.separatorColor, height: 1),
          ),
        ],
      ),
    );
  }
}
