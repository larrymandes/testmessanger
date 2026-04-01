import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_settings_sync_status_item.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsSyncStatusCard extends StatelessWidget {
  const TelegramSettingsSyncStatusCard({
    super.key,
    required this.items,
    this.title = 'Sync Status',
    this.summaryLabel,
    this.onItemTap,
    this.onSyncNowTap,
    this.syncNowLabel = 'Sync Now',
    this.emptyLabel = 'No sync status available',
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final List<TelegramSettingsSyncStatusItem> items;
  final String title;
  final String? summaryLabel;
  final ValueChanged<TelegramSettingsSyncStatusItem>? onItemTap;
  final VoidCallback? onSyncNowTap;
  final String syncNowLabel;
  final String emptyLabel;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final warningCount = items.where((item) => item.warning).length;

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
                  if (warningCount > 0) ...[
                    _WarningBadge(count: warningCount),
                    const SizedBox(width: TelegramSpacing.s),
                  ],
                  if (onSyncNowTap != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(24, 20),
                      onPressed: onSyncNowTap,
                      child: Text(
                        syncNowLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.linkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              if (summaryLabel != null && summaryLabel!.isNotEmpty) ...[
                const SizedBox(height: TelegramSpacing.xs),
                Text(
                  summaryLabel!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtitleTextColor,
                  ),
                ),
              ],
              const SizedBox(height: TelegramSpacing.s),
              if (items.isEmpty)
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
                      for (var index = 0; index < items.length; index++)
                        _SyncItemTile(
                          item: items[index],
                          showDivider: index < items.length - 1,
                          onTap: onItemTap == null || !items[index].enabled
                              ? null
                              : () => onItemTap!(items[index]),
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

class _SyncItemTile extends StatelessWidget {
  const _SyncItemTile({
    required this.item,
    required this.showDivider,
    this.onTap,
  });

  final TelegramSettingsSyncStatusItem item;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final statusColor = item.warning
        ? colors.destructiveTextColor
        : (item.inProgress ? colors.linkColor : colors.onlineIndicatorColor);
    final iconColor = item.enabled ? statusColor : colors.subtitleTextColor;

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
                child: Icon(item.icon, size: 16, color: iconColor),
              ),
              const SizedBox(width: TelegramSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: item.enabled
                            ? colors.textColor
                            : colors.subtitleTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (item.subtitle != null && item.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: TelegramSpacing.xxs),
                      Text(
                        item.subtitle!,
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
                item.statusLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w700,
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

class _WarningBadge extends StatelessWidget {
  const _WarningBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final color = theme.colors.destructiveTextColor;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.s,
          vertical: TelegramSpacing.xxs,
        ),
        child: Text(
          '$count Issue',
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
