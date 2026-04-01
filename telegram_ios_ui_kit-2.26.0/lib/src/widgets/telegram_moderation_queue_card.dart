import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_moderation_request.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_badge.dart';

class TelegramModerationQueueCard extends StatelessWidget {
  const TelegramModerationQueueCard({
    super.key,
    required this.requests,
    this.title = 'Review Queue',
    this.reviewActionLabel = 'Review All',
    this.onReviewAll,
    this.onRequestTap,
    this.maxVisible = 3,
  });

  final List<TelegramModerationRequest> requests;
  final String title;
  final String reviewActionLabel;
  final VoidCallback? onReviewAll;
  final ValueChanged<TelegramModerationRequest>? onRequestTap;
  final int maxVisible;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final safeMaxVisible = maxVisible < 1 ? 1 : maxVisible;
    final visibleRequests = requests
        .take(safeMaxVisible)
        .toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colors.separatorColor, width: 0.5),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              TelegramSpacing.m,
              TelegramSpacing.m,
              TelegramSpacing.s,
              TelegramSpacing.s,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colors.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (requests.isNotEmpty)
                  TelegramBadge(count: requests.length, maxCount: 999),
                CupertinoButton(
                  minimumSize: const Size(28, 28),
                  padding: const EdgeInsets.symmetric(
                    horizontal: TelegramSpacing.s,
                  ),
                  onPressed: requests.isEmpty ? null : onReviewAll,
                  child: Text(
                    reviewActionLabel,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colors.linkColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (visibleRequests.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TelegramSpacing.m,
                0,
                TelegramSpacing.m,
                TelegramSpacing.m,
              ),
              child: Text(
                'No pending moderation requests.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colors.subtitleTextColor,
                ),
              ),
            )
          else
            for (var i = 0; i < visibleRequests.length; i++)
              _ModerationRequestRow(
                request: visibleRequests[i],
                showDivider: i < visibleRequests.length - 1,
                onTap: onRequestTap,
              ),
        ],
      ),
    );
  }
}

class _ModerationRequestRow extends StatelessWidget {
  const _ModerationRequestRow({
    required this.request,
    required this.showDivider,
    required this.onTap,
  });

  final TelegramModerationRequest request;
  final bool showDivider;
  final ValueChanged<TelegramModerationRequest>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final alertColor = request.highPriority
        ? theme.colors.destructiveTextColor
        : theme.colors.linkColor;

    return InkWell(
      onTap: onTap == null ? null : () => onTap!(request),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.m,
          vertical: TelegramSpacing.s,
        ),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(
                  bottom: BorderSide(
                    color: theme.colors.separatorColor,
                    width: 0.5,
                  ),
                )
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: alertColor.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                CupertinoIcons.flag_fill,
                color: alertColor,
                size: 13,
              ),
            ),
            const SizedBox(width: TelegramSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: TelegramSpacing.xxs),
                  Text(
                    request.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: TelegramSpacing.s),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  request.timeLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colors.subtitleTextColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (request.pendingCount > 0) ...[
                  const SizedBox(height: TelegramSpacing.xs),
                  TelegramBadge(count: request.pendingCount, maxCount: 999),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
