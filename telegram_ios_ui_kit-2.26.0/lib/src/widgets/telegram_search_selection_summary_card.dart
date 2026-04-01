import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchSelectionSummaryCard extends StatelessWidget {
  const TelegramSearchSelectionSummaryCard({
    super.key,
    required this.selectedCount,
    required this.totalCount,
    this.onSelectAll,
    this.onClearSelection,
    this.onExit,
    this.selectAllLabel = 'Select All',
    this.clearLabel = 'Clear',
    this.exitLabel = 'Done',
  });

  final int selectedCount;
  final int totalCount;
  final VoidCallback? onSelectAll;
  final VoidCallback? onClearSelection;
  final VoidCallback? onExit;
  final String selectAllLabel;
  final String clearLabel;
  final String exitLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final safeSelectedCount = selectedCount.clamp(0, totalCount);
    final hasSelection = safeSelectedCount > 0;
    final canSelectAll = totalCount > 0 && safeSelectedCount < totalCount;

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
                  'Selected $safeSelectedCount of $totalCount',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colors.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onExit != null)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(24, 20),
                  onPressed: onExit,
                  child: Text(
                    exitLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colors.linkColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: TelegramSpacing.xxs),
          Wrap(
            spacing: TelegramSpacing.xs,
            children: [
              if (onSelectAll != null)
                CupertinoButton(
                  minimumSize: const Size(24, 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: TelegramSpacing.s,
                    vertical: TelegramSpacing.xs,
                  ),
                  color: theme.colors.secondaryBgColor,
                  borderRadius: BorderRadius.circular(999),
                  onPressed: canSelectAll ? onSelectAll : null,
                  child: Text(
                    selectAllLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: canSelectAll
                          ? theme.colors.textColor
                          : theme.colors.subtitleTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              if (onClearSelection != null)
                CupertinoButton(
                  minimumSize: const Size(24, 24),
                  padding: const EdgeInsets.symmetric(
                    horizontal: TelegramSpacing.s,
                    vertical: TelegramSpacing.xs,
                  ),
                  color: theme.colors.secondaryBgColor,
                  borderRadius: BorderRadius.circular(999),
                  onPressed: hasSelection ? onClearSelection : null,
                  child: Text(
                    clearLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: hasSelection
                          ? theme.colors.textColor
                          : theme.colors.subtitleTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
