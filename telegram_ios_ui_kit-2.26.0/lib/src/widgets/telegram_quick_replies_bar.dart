import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramQuickRepliesBar extends StatelessWidget {
  const TelegramQuickRepliesBar({
    super.key,
    required this.replies,
    this.onReplyTap,
  });

  final List<String> replies;
  final ValueChanged<String>? onReplyTap;

  @override
  Widget build(BuildContext context) {
    if (replies.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.s),
        itemCount: replies.length,
        separatorBuilder: (_, index) =>
            const SizedBox(width: TelegramSpacing.xs),
        itemBuilder: (context, index) {
          final reply = replies[index];
          return ActionChip(
            backgroundColor: theme.colors.secondaryBgColor,
            side: BorderSide(color: theme.colors.separatorColor),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
            label: Text(
              reply,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colors.textColor,
              ),
            ),
            onPressed: onReplyTap == null ? null : () => onReplyTap!(reply),
          );
        },
      ),
    );
  }
}
