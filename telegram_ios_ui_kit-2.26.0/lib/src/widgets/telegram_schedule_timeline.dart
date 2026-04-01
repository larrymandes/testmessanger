import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_timeline_event.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramScheduleTimeline extends StatelessWidget {
  const TelegramScheduleTimeline({
    super.key,
    required this.events,
    this.title,
    this.onEventTap,
  });

  final List<TelegramTimelineEvent> events;
  final String? title;
  final ValueChanged<TelegramTimelineEvent>? onEventTap;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = context.telegramTheme;
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colors.separatorColor, width: 0.5),
      ),
      padding: const EdgeInsets.all(TelegramSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colors.textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: TelegramSpacing.s),
          ],
          for (var index = 0; index < events.length; index++) ...[
            _TimelineEventTile(
              event: events[index],
              isLast: index == events.length - 1,
              onTap: onEventTap,
            ),
            if (index < events.length - 1)
              const SizedBox(height: TelegramSpacing.s),
          ],
        ],
      ),
    );
  }
}

class _TimelineEventTile extends StatelessWidget {
  const _TimelineEventTile({
    required this.event,
    required this.isLast,
    this.onTap,
  });

  final TelegramTimelineEvent event;
  final bool isLast;
  final ValueChanged<TelegramTimelineEvent>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final accentColor =
        event.accentColor ??
        (event.completed
            ? theme.colors.onlineIndicatorColor
            : event.current
            ? theme.colors.linkColor
            : theme.colors.separatorColor);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap == null ? null : () => onTap!(event),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.xs,
          vertical: TelegramSpacing.xs,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 16,
              child: Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 36,
                      margin: const EdgeInsets.only(top: 2),
                      color: theme.colors.separatorColor,
                    ),
                ],
              ),
            ),
            const SizedBox(width: TelegramSpacing.s),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colors.textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: TelegramSpacing.s),
                      Text(
                        event.timeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colors.subtitleTextColor,
                        ),
                      ),
                    ],
                  ),
                  if (event.subtitle != null) ...[
                    const SizedBox(height: TelegramSpacing.xxs),
                    Text(
                      event.subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colors.subtitleTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (event.completed)
              Padding(
                padding: const EdgeInsets.only(left: TelegramSpacing.xs),
                child: Icon(
                  CupertinoIcons.check_mark_circled_solid,
                  size: 16,
                  color: theme.colors.onlineIndicatorColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
