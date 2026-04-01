import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_settings_connected_app.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsConnectedAppsCard extends StatelessWidget {
  const TelegramSettingsConnectedAppsCard({
    super.key,
    required this.apps,
    this.title = 'Connected Apps',
    this.onSelected,
    this.onManageTap,
    this.manageLabel = 'Manage',
    this.onRevokeTap,
    this.revokeLabel = 'Revoke',
    this.emptyLabel = 'No connected apps',
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final List<TelegramSettingsConnectedApp> apps;
  final String title;
  final ValueChanged<TelegramSettingsConnectedApp>? onSelected;
  final VoidCallback? onManageTap;
  final String manageLabel;
  final ValueChanged<TelegramSettingsConnectedApp>? onRevokeTap;
  final String revokeLabel;
  final String emptyLabel;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;

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
                  if (onManageTap != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(24, 20),
                      onPressed: onManageTap,
                      child: Text(
                        manageLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.linkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: TelegramSpacing.s),
              if (apps.isEmpty)
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
                      for (var index = 0; index < apps.length; index++)
                        _ConnectedAppTile(
                          app: apps[index],
                          showDivider: index < apps.length - 1,
                          onTap: onSelected == null || !apps[index].enabled
                              ? null
                              : () => onSelected!(apps[index]),
                          onRevokeTap:
                              onRevokeTap == null || !apps[index].enabled
                              ? null
                              : () => onRevokeTap!(apps[index]),
                          revokeLabel: revokeLabel,
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

class _ConnectedAppTile extends StatelessWidget {
  const _ConnectedAppTile({
    required this.app,
    required this.showDivider,
    required this.revokeLabel,
    this.onTap,
    this.onRevokeTap,
  });

  final TelegramSettingsConnectedApp app;
  final bool showDivider;
  final String revokeLabel;
  final VoidCallback? onTap;
  final VoidCallback? onRevokeTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final enabledTextColor = onTap == null
        ? colors.subtitleTextColor
        : colors.textColor;

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
                  color: colors.secondaryBgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(app.icon, size: 16, color: colors.linkColor),
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
                            app.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: enabledTextColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (app.verified)
                          Icon(
                            CupertinoIcons.checkmark_seal_fill,
                            size: 14,
                            color: colors.linkColor,
                          ),
                      ],
                    ),
                    const SizedBox(height: TelegramSpacing.xxs),
                    Text(
                      _subtitle(app),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.subtitleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (app.warningCount > 0) ...[
                _WarningBadge(count: app.warningCount),
                const SizedBox(width: TelegramSpacing.xs),
              ],
              if (onRevokeTap != null) ...[
                CupertinoButton(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TelegramSpacing.s,
                  ),
                  minimumSize: const Size(24, 24),
                  onPressed: onRevokeTap,
                  child: Text(
                    revokeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.destructiveTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ] else ...[
                Icon(
                  CupertinoIcons.chevron_forward,
                  size: 14,
                  color: colors.subtitleTextColor,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _subtitle(TelegramSettingsConnectedApp app) {
    final subtitle = app.subtitle;
    if (subtitle != null && subtitle.isNotEmpty) {
      return '$subtitle · ${app.lastUsedLabel}';
    }
    return app.lastUsedLabel;
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
          '$count',
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
