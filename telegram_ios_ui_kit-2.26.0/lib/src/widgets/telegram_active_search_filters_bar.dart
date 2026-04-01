import 'package:flutter/cupertino.dart';

import '../models/telegram_search_filter_option.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramActiveSearchFiltersBar extends StatelessWidget {
  const TelegramActiveSearchFiltersBar({
    super.key,
    required this.filters,
    this.onRemove,
    this.onClearAll,
    this.title = 'Active Filters',
    this.clearLabel = 'Clear',
  });

  final List<TelegramSearchFilterOption> filters;
  final ValueChanged<TelegramSearchFilterOption>? onRemove;
  final VoidCallback? onClearAll;
  final String title;
  final String clearLabel;

  @override
  Widget build(BuildContext context) {
    final activeFilters = filters
        .where((filter) => filter.selected)
        .toList(growable: false);
    if (activeFilters.isEmpty) {
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
                  clearLabel,
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
            itemCount: activeFilters.length,
            separatorBuilder: (_, _) =>
                const SizedBox(width: TelegramSpacing.xs),
            itemBuilder: (context, index) {
              final filter = activeFilters[index];
              return CupertinoButton(
                minimumSize: const Size(24, 24),
                padding: const EdgeInsets.symmetric(
                  horizontal: TelegramSpacing.s,
                ),
                color: theme.colors.linkColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
                onPressed: onRemove == null ? null : () => onRemove!(filter),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      filter.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colors.linkColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: TelegramSpacing.xxs),
                    Icon(
                      CupertinoIcons.xmark,
                      size: 12,
                      color: theme.colors.linkColor,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
