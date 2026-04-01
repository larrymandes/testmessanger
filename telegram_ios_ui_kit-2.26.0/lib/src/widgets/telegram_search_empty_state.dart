import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchEmptyState extends StatelessWidget {
  const TelegramSearchEmptyState({
    super.key,
    this.icon = CupertinoIcons.search,
    this.title = 'No Results',
    this.message = 'Try another keyword or clear current filters.',
    this.actionLabel,
    this.onActionPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TelegramSpacing.l),
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 24, color: theme.colors.subtitleTextColor),
          const SizedBox(height: TelegramSpacing.s),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colors.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TelegramSpacing.xxs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colors.subtitleTextColor,
            ),
          ),
          if (actionLabel != null &&
              actionLabel!.trim().isNotEmpty &&
              onActionPressed != null) ...[
            const SizedBox(height: TelegramSpacing.m),
            CupertinoButton(
              minimumSize: const Size(24, 24),
              padding: const EdgeInsets.symmetric(
                horizontal: TelegramSpacing.m,
                vertical: TelegramSpacing.s,
              ),
              color: theme.colors.linkColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
              onPressed: onActionPressed,
              child: Text(
                actionLabel!,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colors.linkColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
