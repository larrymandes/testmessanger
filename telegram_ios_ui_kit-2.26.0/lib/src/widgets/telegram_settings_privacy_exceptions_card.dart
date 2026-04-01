import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_settings_privacy_exception.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsPrivacyExceptionsCard extends StatelessWidget {
  const TelegramSettingsPrivacyExceptionsCard({
    super.key,
    required this.items,
    this.title = 'Privacy Exceptions',
    this.description,
    this.onSelected,
    this.onManageTap,
    this.manageLabel = 'Manage',
    this.emptyLabel = 'No privacy exceptions configured',
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final List<TelegramSettingsPrivacyException> items;
  final String title;
  final String? description;
  final ValueChanged<TelegramSettingsPrivacyException>? onSelected;
  final VoidCallback? onManageTap;
  final String manageLabel;
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
              if (items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: TelegramSpacing.s,
                  ),
                  child: Text(
                    emptyLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.subtitleTextColor,
                    ),
                  ),
                )
              else
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      for (var index = 0; index < items.length; index++)
                        _PrivacyExceptionTile(
                          item: items[index],
                          showDivider: index < items.length - 1,
                          onTap: onSelected == null || !items[index].enabled
                              ? null
                              : () => onSelected!(items[index]),
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

class _PrivacyExceptionTile extends StatelessWidget {
  const _PrivacyExceptionTile({
    required this.item,
    required this.showDivider,
    this.onTap,
  });

  final TelegramSettingsPrivacyException item;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final foregroundColor = item.destructive
        ? colors.destructiveTextColor
        : colors.textColor;
    final subtitleColor = onTap == null
        ? colors.subtitleTextColor.withValues(alpha: 0.7)
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
              if (item.icon != null) ...[
                Icon(item.icon, size: 16, color: foregroundColor),
                const SizedBox(width: TelegramSpacing.s),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: foregroundColor,
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
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (item.countLabel != null && item.countLabel!.isNotEmpty) ...[
                _CountBadge(
                  label: item.countLabel!,
                  color: item.destructive
                      ? colors.destructiveTextColor
                      : colors.linkColor,
                ),
                const SizedBox(width: TelegramSpacing.s),
              ],
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

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.label, required this.color});

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
