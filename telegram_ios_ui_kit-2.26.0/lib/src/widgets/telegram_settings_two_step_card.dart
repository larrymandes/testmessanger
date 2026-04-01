import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_settings_security_action.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsTwoStepCard extends StatelessWidget {
  const TelegramSettingsTwoStepCard({
    super.key,
    required this.enabled,
    required this.actions,
    this.title = 'Two-Step Verification',
    this.description,
    this.enabledLabel = 'Enabled',
    this.disabledLabel = 'Disabled',
    this.onManageTap,
    this.manageLabel = 'Manage',
    this.onActionSelected,
    this.emptyLabel = 'No verification actions available',
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final bool enabled;
  final List<TelegramSettingsSecurityAction> actions;
  final String title;
  final String? description;
  final String enabledLabel;
  final String disabledLabel;
  final VoidCallback? onManageTap;
  final String manageLabel;
  final ValueChanged<TelegramSettingsSecurityAction>? onActionSelected;
  final String emptyLabel;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final statusColor = enabled
        ? colors.onlineIndicatorColor
        : colors.destructiveTextColor;
    final statusLabel = enabled ? enabledLabel : disabledLabel;

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
                  _StatusBadge(label: statusLabel, color: statusColor),
                  if (onManageTap != null) ...[
                    const SizedBox(width: TelegramSpacing.s),
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
                ],
              ),
              if (description != null && description!.isNotEmpty) ...[
                const SizedBox(height: TelegramSpacing.xs),
                Text(
                  description!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtitleTextColor,
                  ),
                ),
              ],
              const SizedBox(height: TelegramSpacing.s),
              if (actions.isEmpty)
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
                      for (var index = 0; index < actions.length; index++)
                        _SecurityActionTile(
                          action: actions[index],
                          showDivider: index < actions.length - 1,
                          onTap:
                              onActionSelected == null ||
                                  !actions[index].enabled
                              ? null
                              : () => onActionSelected!(actions[index]),
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

class _SecurityActionTile extends StatelessWidget {
  const _SecurityActionTile({
    required this.action,
    required this.showDivider,
    this.onTap,
  });

  final TelegramSettingsSecurityAction action;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final foregroundColor = action.destructive
        ? colors.destructiveTextColor
        : colors.textColor;
    final subtitleColor = onTap == null
        ? colors.subtitleTextColor.withValues(alpha: 0.72)
        : colors.subtitleTextColor;

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
                  color: foregroundColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, size: 16, color: foregroundColor),
              ),
              const SizedBox(width: TelegramSpacing.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (action.subtitle != null &&
                        action.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: TelegramSpacing.xxs),
                      Text(
                        action.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
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
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
