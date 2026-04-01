import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramBadge extends StatelessWidget {
  const TelegramBadge({
    super.key,
    required this.count,
    this.color,
    this.textColor,
    this.maxCount = 99,
  });

  final int count;
  final Color? color;
  final Color? textColor;
  final int maxCount;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) {
      return const SizedBox.shrink();
    }

    final theme = context.telegramTheme;
    final bg = color ?? theme.colors.unreadBadgeColor;
    final fg = textColor ?? theme.colors.buttonTextColor;
    final label = count > maxCount ? '$maxCount+' : '$count';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.s,
        vertical: TelegramSpacing.xs,
      ),
      constraints: const BoxConstraints(minHeight: 20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
