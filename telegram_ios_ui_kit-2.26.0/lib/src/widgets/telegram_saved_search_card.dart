import 'package:flutter/cupertino.dart';

import '../models/telegram_saved_search.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSavedSearchCard extends StatelessWidget {
  const TelegramSavedSearchCard({
    super.key,
    required this.search,
    this.selected = false,
    this.onApply,
    this.onDelete,
    this.applyLabel = 'Run Search',
    this.deleteLabel = 'Remove',
  });

  final TelegramSavedSearch search;
  final bool selected;
  final ValueChanged<TelegramSavedSearch>? onApply;
  final ValueChanged<TelegramSavedSearch>? onDelete;
  final String applyLabel;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final borderColor = selected
        ? theme.colors.linkColor.withValues(alpha: 0.24)
        : theme.colors.separatorColor;
    final scopeLabel = search.scopeLabel?.trim();
    final sortLabel = search.sortLabel?.trim();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      padding: const EdgeInsets.all(TelegramSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (search.icon != null) ...[
                Icon(search.icon, size: 16, color: theme.colors.linkColor),
                const SizedBox(width: TelegramSpacing.xs),
              ],
              Expanded(
                child: Text(
                  search.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colors.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (search.expectedCount != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TelegramSpacing.xs,
                    vertical: TelegramSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colors.linkColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${search.expectedCount}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colors.linkColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: TelegramSpacing.xxs),
          Text(
            search.query,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colors.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (search.description != null &&
              search.description!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: TelegramSpacing.xxs),
              child: Text(
                search.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colors.subtitleTextColor,
                ),
              ),
            ),
          const SizedBox(height: TelegramSpacing.s),
          Wrap(
            spacing: TelegramSpacing.xs,
            runSpacing: TelegramSpacing.xxs,
            children: [
              if (scopeLabel != null && scopeLabel.isNotEmpty)
                _MetaBadge(label: 'Scope: $scopeLabel'),
              if (sortLabel != null && sortLabel.isNotEmpty)
                _MetaBadge(label: 'Sort: $sortLabel'),
              if (search.filterIds.isNotEmpty)
                _MetaBadge(label: 'Filters: ${search.filterIds.length}'),
            ],
          ),
          if (onApply != null || onDelete != null) ...[
            const SizedBox(height: TelegramSpacing.s),
            Row(
              children: [
                if (onApply != null)
                  CupertinoButton(
                    minimumSize: const Size(24, 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: TelegramSpacing.m,
                      vertical: TelegramSpacing.xs,
                    ),
                    borderRadius: BorderRadius.circular(999),
                    color: theme.colors.linkColor,
                    onPressed: () => onApply!(search),
                    child: Text(
                      applyLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colors.buttonTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                if (onApply != null && onDelete != null)
                  const SizedBox(width: TelegramSpacing.xs),
                if (onDelete != null)
                  CupertinoButton(
                    minimumSize: const Size(24, 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: TelegramSpacing.s,
                      vertical: TelegramSpacing.xs,
                    ),
                    onPressed: () => onDelete!(search),
                    child: Text(
                      deleteLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colors.destructiveTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ],
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
