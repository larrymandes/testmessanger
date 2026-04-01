import 'package:flutter/cupertino.dart';

import '../models/telegram_search_execution.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchExecutionTile extends StatelessWidget {
  const TelegramSearchExecutionTile({
    super.key,
    required this.execution,
    this.onTap,
    this.onRetry,
    this.showDivider = false,
    this.retryLabel = 'Retry',
  });

  final TelegramSearchExecution execution;
  final ValueChanged<TelegramSearchExecution>? onTap;
  final ValueChanged<TelegramSearchExecution>? onRetry;
  final bool showDivider;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final statusColor = _resolveStatusColor(theme);
    final metadata = _buildMetadata();
    final stats = _buildStats();

    final content = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.m,
        vertical: TelegramSpacing.s,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: TelegramSpacing.xxs),
            child: Icon(_resolveStatusIcon(), size: 16, color: statusColor),
          ),
          const SizedBox(width: TelegramSpacing.s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  execution.query.trim().isEmpty
                      ? 'All Messages'
                      : execution.query,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colors.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (metadata.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: TelegramSpacing.xxs),
                    child: Text(
                      metadata.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colors.subtitleTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (execution.errorMessage != null &&
                    execution.errorMessage!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: TelegramSpacing.xxs),
                    child: Text(
                      execution.errorMessage!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colors.destructiveTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (stats.isNotEmpty || _canRetry)
            const SizedBox(width: TelegramSpacing.s),
          if (stats.isNotEmpty || _canRetry)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (stats.isNotEmpty)
                  Text(
                    stats.join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                if (_canRetry)
                  CupertinoButton(
                    padding: const EdgeInsets.only(top: TelegramSpacing.xxs),
                    minimumSize: const Size(24, 20),
                    onPressed: () => onRetry?.call(execution),
                    child: Text(
                      retryLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colors.linkColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );

    final child = onTap == null
        ? content
        : CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () => onTap?.call(execution),
            child: content,
          );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: theme.colors.separatorColor,
                  width: 0.8,
                ),
              )
            : null,
      ),
      child: child,
    );
  }

  List<String> _buildMetadata() {
    final values = <String>[execution.statusLabel];
    if (execution.scopeLabel != null &&
        execution.scopeLabel!.trim().isNotEmpty) {
      values.add(execution.scopeLabel!);
    }
    if (execution.dateRangeLabel != null &&
        execution.dateRangeLabel!.trim().isNotEmpty) {
      values.add(execution.dateRangeLabel!);
    }
    if (execution.startedAtLabel != null &&
        execution.startedAtLabel!.trim().isNotEmpty) {
      values.add(execution.startedAtLabel!);
    }
    return values;
  }

  List<String> _buildStats() {
    final stats = <String>[];
    if (execution.resultCount != null) {
      stats.add('${execution.resultCount} hits');
    }
    if (execution.durationMs != null) {
      stats.add('${execution.durationMs}ms');
    }
    if (execution.fromCache) {
      stats.add('Cache');
    }
    return stats;
  }

  bool get _canRetry => execution.isFailure && onRetry != null;

  IconData _resolveStatusIcon() {
    if (execution.isSuccess) {
      return CupertinoIcons.checkmark_seal_fill;
    }
    if (execution.isFailure) {
      return CupertinoIcons.exclamationmark_triangle_fill;
    }
    if (execution.isRunning) {
      return CupertinoIcons.arrow_2_circlepath_circle_fill;
    }
    return CupertinoIcons.clock_fill;
  }

  Color _resolveStatusColor(TelegramThemeData theme) {
    if (execution.isSuccess) {
      return theme.colors.unreadBadgeColor;
    }
    if (execution.isFailure) {
      return theme.colors.destructiveTextColor;
    }
    if (execution.isRunning) {
      return theme.colors.linkColor;
    }
    return theme.colors.subtitleTextColor;
  }
}
