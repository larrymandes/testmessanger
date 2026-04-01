import 'package:flutter/cupertino.dart';

import '../models/telegram_search_execution.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchExecutionStatusCard extends StatelessWidget {
  const TelegramSearchExecutionStatusCard({
    super.key,
    required this.totalCount,
    required this.successCount,
    required this.failedCount,
    required this.averageDurationMs,
    this.latestExecution,
    this.onOpenHistory,
    this.onRerunLatest,
    this.title = 'Execution Status',
    this.historyLabel = 'History',
    this.rerunLabel = 'Re-run Last',
  });

  final int totalCount;
  final int successCount;
  final int failedCount;
  final int averageDurationMs;
  final TelegramSearchExecution? latestExecution;
  final VoidCallback? onOpenHistory;
  final VoidCallback? onRerunLatest;
  final String title;
  final String historyLabel;
  final String rerunLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final safeTotalCount = totalCount < 0 ? 0 : totalCount;
    final safeSuccessCount = successCount.clamp(0, safeTotalCount).toInt();
    final safeFailedCount = failedCount.clamp(0, safeTotalCount).toInt();
    final safeAverageDurationMs = averageDurationMs < 0 ? 0 : averageDurationMs;
    final statusColor = _resolveLatestStatusColor(theme);

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
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colors.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (onOpenHistory != null)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(24, 20),
                  onPressed: onOpenHistory,
                  child: Text(
                    historyLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colors.linkColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: TelegramSpacing.xxs),
          if (latestExecution == null)
            Text(
              'Run a search to see execution history.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colors.subtitleTextColor,
                fontWeight: FontWeight.w600,
              ),
            )
          else ...[
            Text(
              latestExecution!.query.trim().isEmpty
                  ? 'Latest query: All Messages'
                  : 'Latest query: ${latestExecution!.query}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colors.textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: TelegramSpacing.xxs),
            Text(
              'Status: ${latestExecution!.statusLabel}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: TelegramSpacing.xs),
          Wrap(
            spacing: TelegramSpacing.xs,
            runSpacing: TelegramSpacing.xs,
            children: [
              _buildMetricPill(
                context,
                label: 'Runs',
                value: '$safeTotalCount',
                color: theme.colors.linkColor,
              ),
              _buildMetricPill(
                context,
                label: 'Success',
                value: '$safeSuccessCount',
                color: theme.colors.unreadBadgeColor,
              ),
              _buildMetricPill(
                context,
                label: 'Failed',
                value: '$safeFailedCount',
                color: safeFailedCount == 0
                    ? theme.colors.subtitleTextColor
                    : theme.colors.destructiveTextColor,
              ),
              _buildMetricPill(
                context,
                label: 'Avg',
                value: '${safeAverageDurationMs}ms',
                color: theme.colors.subtitleTextColor,
              ),
            ],
          ),
          if (onRerunLatest != null && latestExecution != null)
            Padding(
              padding: const EdgeInsets.only(top: TelegramSpacing.xs),
              child: CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: TelegramSpacing.s,
                  vertical: TelegramSpacing.xs,
                ),
                color: theme.colors.secondaryBgColor,
                borderRadius: BorderRadius.circular(999),
                minimumSize: const Size(24, 24),
                onPressed: onRerunLatest,
                child: Text(
                  rerunLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colors.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricPill(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = context.telegramTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.s,
        vertical: TelegramSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Color _resolveLatestStatusColor(TelegramThemeData theme) {
    final latest = latestExecution;
    if (latest == null) {
      return theme.colors.subtitleTextColor;
    }
    if (latest.isSuccess) {
      return theme.colors.unreadBadgeColor;
    }
    if (latest.isFailure) {
      return theme.colors.destructiveTextColor;
    }
    if (latest.isRunning) {
      return theme.colors.linkColor;
    }
    return theme.colors.subtitleTextColor;
  }
}
