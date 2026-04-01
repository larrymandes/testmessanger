import 'package:flutter/material.dart';

import '../models/telegram_reaction.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramReactionBar extends StatelessWidget {
  const TelegramReactionBar({
    super.key,
    required this.reactions,
    this.onReactionTap,
  });

  final List<TelegramReaction> reactions;
  final ValueChanged<TelegramReaction>? onReactionTap;

  @override
  Widget build(BuildContext context) {
    if (reactions.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;
    return Wrap(
      spacing: TelegramSpacing.xs,
      runSpacing: TelegramSpacing.xs,
      children: [
        for (final reaction in reactions)
          InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onReactionTap == null
                ? null
                : () => onReactionTap!(reaction),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TelegramSpacing.s,
                vertical: TelegramSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: reaction.selected
                    ? theme.colors.linkColor.withValues(alpha: 0.14)
                    : theme.colors.secondaryBgColor,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: reaction.selected
                      ? theme.colors.linkColor.withValues(alpha: 0.5)
                      : theme.colors.separatorColor,
                ),
              ),
              child: Text(
                '${reaction.emoji} ${reaction.count}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colors.textColor,
                  fontWeight: reaction.selected
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
