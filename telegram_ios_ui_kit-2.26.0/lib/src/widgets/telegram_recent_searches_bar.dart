import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramRecentSearchesBar extends StatelessWidget {
  const TelegramRecentSearchesBar({
    super.key,
    required this.queries,
    this.title = 'Recent',
    this.onSelected,
    this.onRemove,
    this.onClearAll,
    this.clearAllLabel = 'Clear',
  });

  final List<String> queries;
  final String title;
  final ValueChanged<String>? onSelected;
  final ValueChanged<String>? onRemove;
  final VoidCallback? onClearAll;
  final String clearAllLabel;

  @override
  Widget build(BuildContext context) {
    if (queries.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = context.telegramTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colors.subtitleTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            if (onClearAll != null)
              CupertinoButton(
                minimumSize: const Size(24, 24),
                padding: EdgeInsets.zero,
                onPressed: onClearAll,
                child: Text(
                  clearAllLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colors.linkColor,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: TelegramSpacing.xs),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: queries.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: TelegramSpacing.xs),
            itemBuilder: (context, index) {
              final query = queries[index];
              return _RecentQueryChip(
                query: query,
                onTap: onSelected == null ? null : () => onSelected!(query),
                onRemove: onRemove == null ? null : () => onRemove!(query),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _RecentQueryChip extends StatelessWidget {
  const _RecentQueryChip({required this.query, this.onTap, this.onRemove});

  final String query;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return CupertinoButton(
      minimumSize: const Size(24, 24),
      padding: const EdgeInsets.only(
        left: TelegramSpacing.s,
        right: TelegramSpacing.xs,
      ),
      color: theme.colors.sectionBgColor,
      borderRadius: BorderRadius.circular(999),
      onPressed: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            query,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colors.textColor,
            ),
          ),
          if (onRemove != null) ...[
            const SizedBox(width: TelegramSpacing.xxs),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                CupertinoIcons.xmark,
                size: 12,
                color: theme.colors.subtitleTextColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
