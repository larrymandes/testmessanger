import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchResultStatsBar extends StatelessWidget {
  const TelegramSearchResultStatsBar({
    super.key,
    required this.query,
    required this.resultCount,
    this.scopeLabel,
    this.dateRangeLabel,
    this.sortLabel,
    this.elapsedMs,
    this.activeFilterCount = 0,
  });

  final String query;
  final int resultCount;
  final String? scopeLabel;
  final String? dateRangeLabel;
  final String? sortLabel;
  final int? elapsedMs;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final normalizedQuery = query.trim();
    final queryText = normalizedQuery.isEmpty ? 'Search' : normalizedQuery;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        TelegramSpacing.s,
        TelegramSpacing.s,
        TelegramSpacing.s,
        TelegramSpacing.s,
      ),
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Results for "$queryText"',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colors.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: TelegramSpacing.xs),
              Text(
                '$resultCount',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colors.linkColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: TelegramSpacing.xxs),
          Wrap(
            spacing: TelegramSpacing.xs,
            runSpacing: TelegramSpacing.xxs,
            children: [
              if (scopeLabel != null && scopeLabel!.trim().isNotEmpty)
                _MetaBadge(label: 'Scope: ${scopeLabel!}'),
              if (dateRangeLabel != null && dateRangeLabel!.trim().isNotEmpty)
                _MetaBadge(label: 'Range: ${dateRangeLabel!}'),
              if (sortLabel != null && sortLabel!.trim().isNotEmpty)
                _MetaBadge(label: 'Sort: ${sortLabel!}'),
              if (activeFilterCount > 0)
                _MetaBadge(label: 'Filters: $activeFilterCount'),
              if (elapsedMs != null && elapsedMs! >= 0)
                _MetaBadge(label: '${elapsedMs!}ms'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  const _MetaBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.xs,
        vertical: TelegramSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: theme.colors.secondaryBgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colors.subtitleTextColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
