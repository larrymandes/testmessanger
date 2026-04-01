import 'package:flutter/cupertino.dart';

import '../models/telegram_search_query_token.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchQueryTokensBar extends StatelessWidget {
  const TelegramSearchQueryTokensBar({
    super.key,
    required this.tokens,
    this.onTap,
    this.onRemove,
    this.onClearAll,
    this.clearLabel = 'Clear Tokens',
  });

  final List<TelegramSearchQueryToken> tokens;
  final ValueChanged<TelegramSearchQueryToken>? onTap;
  final ValueChanged<TelegramSearchQueryToken>? onRemove;
  final VoidCallback? onClearAll;
  final String clearLabel;

  @override
  Widget build(BuildContext context) {
    if (tokens.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: tokens.length,
            separatorBuilder: (_, _) => const SizedBox(width: TelegramSpacing.xs),
            itemBuilder: (context, index) {
              final token = tokens[index];
              return _TokenChip(
                token: token,
                onTap: onTap,
                onRemove: onRemove,
              );
            },
          ),
        ),
        if (onClearAll != null)
          Padding(
            padding: const EdgeInsets.only(top: TelegramSpacing.xxs),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size(24, 20),
              onPressed: onClearAll,
              child: Text(
                clearLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colors.subtitleTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _TokenChip extends StatelessWidget {
  const _TokenChip({
    required this.token,
    this.onTap,
    this.onRemove,
  });

  final TelegramSearchQueryToken token;
  final ValueChanged<TelegramSearchQueryToken>? onTap;
  final ValueChanged<TelegramSearchQueryToken>? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final foregroundColor = token.isOperator
        ? theme.colors.linkColor
        : theme.colors.textColor;
    final backgroundColor = token.isOperator
        ? theme.colors.linkColor.withValues(alpha: 0.14)
        : theme.colors.sectionBgColor;

    return CupertinoButton(
      minimumSize: const Size(24, 24),
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.s,
        vertical: TelegramSpacing.xs,
      ),
      color: backgroundColor,
      borderRadius: BorderRadius.circular(999),
      onPressed: onTap == null ? null : () => onTap!(token),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (token.icon != null) ...[
            Icon(token.icon, size: 13, color: foregroundColor),
            const SizedBox(width: TelegramSpacing.xxs),
          ],
          Text(
            token.label ?? token.value,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: TelegramSpacing.xxs),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onRemove!(token),
              child: Icon(
                CupertinoIcons.xmark_circle_fill,
                size: 13,
                color: foregroundColor.withValues(alpha: 0.75),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
