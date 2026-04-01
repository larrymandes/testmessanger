import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramServiceMessageBubble extends StatelessWidget {
  const TelegramServiceMessageBubble({
    super.key,
    required this.message,
    this.icon,
    this.maxWidth = 0.74,
    this.backgroundColor,
    this.textColor,
  });

  final String message;
  final IconData? icon;
  final double maxWidth;
  final Color? backgroundColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    if (message.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = context.telegramTheme;
    final bubbleColor =
        backgroundColor ??
        theme.colors.secondaryBgColor.withValues(alpha: 0.94);
    final foregroundColor = textColor ?? theme.colors.subtitleTextColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TelegramSpacing.s),
      child: Center(
        child: FractionallySizedBox(
          widthFactor: maxWidth.clamp(0.2, 1.0),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TelegramSpacing.m,
              vertical: TelegramSpacing.s,
            ),
            decoration: BoxDecoration(
              color: bubbleColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colors.separatorColor,
                width: 0.4,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 14, color: foregroundColor),
                  const SizedBox(width: TelegramSpacing.xs),
                ],
                Flexible(
                  child: Text(
                    message,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
