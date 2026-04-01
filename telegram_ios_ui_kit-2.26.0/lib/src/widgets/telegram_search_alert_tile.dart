import 'package:flutter/cupertino.dart';

import '../models/telegram_search_alert.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchAlertTile extends StatelessWidget {
  const TelegramSearchAlertTile({
    super.key,
    required this.alert,
    this.onChanged,
    this.onTap,
    this.showDivider = false,
  });

  final TelegramSearchAlert alert;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final subtitleParts = <String>[
      if (alert.scopeLabel != null && alert.scopeLabel!.trim().isNotEmpty)
        alert.scopeLabel!.trim(),
      if (alert.triggerLabel != null && alert.triggerLabel!.trim().isNotEmpty)
        alert.triggerLabel!.trim(),
      if (alert.deliveryLabel != null && alert.deliveryLabel!.trim().isNotEmpty)
        alert.deliveryLabel!.trim(),
    ];
    final subtitle = subtitleParts.join(' · ');

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
      child: CupertinoButton(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.m,
          vertical: TelegramSpacing.s,
        ),
        onPressed: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (alert.icon != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  alert.icon,
                  size: 16,
                  color: theme.colors.linkColor,
                ),
              ),
              const SizedBox(width: TelegramSpacing.s),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colors.textColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (alert.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(
                            left: TelegramSpacing.xs,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: TelegramSpacing.xs,
                            vertical: TelegramSpacing.xxs,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colors.unreadBadgeColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${alert.unreadCount}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colors.buttonTextColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: TelegramSpacing.xxs),
                  Text(
                    alert.query,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.textColor,
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: TelegramSpacing.xxs),
                      child: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colors.subtitleTextColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: TelegramSpacing.s),
            CupertinoSwitch(
              value: alert.enabled,
              onChanged: onChanged,
              activeTrackColor: theme.colors.linkColor,
            ),
          ],
        ),
      ),
    );
  }
}
