import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchQueryInspectorCard extends StatelessWidget {
  const TelegramSearchQueryInspectorCard({
    super.key,
    required this.query,
    required this.resultCount,
    this.keyword,
    this.operatorCount = 0,
    this.tokenCount = 0,
    this.scopeLabel,
    this.dateRangeLabel,
    this.sortLabel,
    this.title = 'Query Inspector',
  });

  final String query;
  final String? keyword;
  final int resultCount;
  final int operatorCount;
  final int tokenCount;
  final String? scopeLabel;
  final String? dateRangeLabel;
  final String? sortLabel;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final normalizedQuery = query.trim();
    final normalizedKeyword = keyword?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(TelegramSpacing.s),
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colors.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: TelegramSpacing.xxs),
          Text(
            normalizedQuery.isEmpty ? 'No query' : normalizedQuery,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colors.subtitleTextColor,
            ),
          ),
          const SizedBox(height: TelegramSpacing.xs),
          Wrap(
            spacing: TelegramSpacing.xs,
            runSpacing: TelegramSpacing.xxs,
            children: [
              _InspectorBadge(label: 'Results: $resultCount'),
              _InspectorBadge(label: 'Tokens: $tokenCount'),
              _InspectorBadge(label: 'Operators: $operatorCount'),
              if (normalizedKeyword.isNotEmpty)
                _InspectorBadge(label: 'Keyword: $normalizedKeyword'),
              if (scopeLabel != null && scopeLabel!.trim().isNotEmpty)
                _InspectorBadge(label: 'Scope: ${scopeLabel!}'),
              if (dateRangeLabel != null && dateRangeLabel!.trim().isNotEmpty)
                _InspectorBadge(label: 'Range: ${dateRangeLabel!}'),
              if (sortLabel != null && sortLabel!.trim().isNotEmpty)
                _InspectorBadge(label: 'Sort: ${sortLabel!}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InspectorBadge extends StatelessWidget {
  const _InspectorBadge({required this.label});

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
