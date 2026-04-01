import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_settings_security_event.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsSecurityEventsCard extends StatelessWidget {
  const TelegramSettingsSecurityEventsCard({
    super.key,
    required this.events,
    this.title = 'Recent Security Events',
    this.onEventTap,
    this.onReviewAllTap,
    this.reviewAllLabel = 'Review All',
    this.emptyLabel = 'No recent security events',
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final List<TelegramSettingsSecurityEvent> events;
  final String title;
  final ValueChanged<TelegramSettingsSecurityEvent>? onEventTap;
  final VoidCallback? onReviewAllTap;
  final String reviewAllLabel;
  final String emptyLabel;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final highRiskCount = events.where((event) => event.highRisk).length;

    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.sectionBgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TelegramSpacing.m,
            TelegramSpacing.m,
            TelegramSpacing.m,
            TelegramSpacing.m,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (highRiskCount > 0) ...[
                    _RiskBadge(count: highRiskCount),
                    const SizedBox(width: TelegramSpacing.s),
                  ],
                  if (onReviewAllTap != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(24, 20),
                      onPressed: onReviewAllTap,
                      child: Text(
                        reviewAllLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.linkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: TelegramSpacing.s),
              if (events.isEmpty)
                Text(
                  emptyLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtitleTextColor,
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      for (var index = 0; index < events.length; index++)
                        _SecurityEventTile(
                          event: events[index],
                          showDivider: index < events.length - 1,
                          onTap: onEventTap == null
                              ? null
                              : () => onEventTap!(events[index]),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SecurityEventTile extends StatelessWidget {
  const _SecurityEventTile({
    required this.event,
    required this.showDivider,
    this.onTap,
  });

  final TelegramSettingsSecurityEvent event;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final statusColor = event.highRisk
        ? colors.destructiveTextColor
        : colors.linkColor;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TelegramSpacing.s,
            vertical: TelegramSpacing.s,
          ),
          decoration: BoxDecoration(
            border: showDivider
                ? Border(
                    bottom: BorderSide(
                      color: colors.separatorColor,
                      width: 0.5,
                    ),
                  )
                : null,
          ),
          child: Row(
            children: [
              Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(event.icon, size: 16, color: statusColor),
              ),
              const SizedBox(width: TelegramSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (event.subtitle != null &&
                        event.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: TelegramSpacing.xxs),
                      Text(
                        event.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.subtitleTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: TelegramSpacing.s),
              Text(
                event.timeLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.subtitleTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: TelegramSpacing.xs),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 14,
                color: colors.subtitleTextColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RiskBadge extends StatelessWidget {
  const _RiskBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final color = theme.colors.destructiveTextColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.s,
          vertical: TelegramSpacing.xxs,
        ),
        child: Text(
          '$count Risk',
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
