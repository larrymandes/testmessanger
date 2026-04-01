import 'package:flutter/cupertino.dart';

import '../models/telegram_settings_option.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsOptionTile extends StatelessWidget {
  const TelegramSettingsOptionTile({
    super.key,
    required this.option,
    this.selected = false,
    this.onTap,
    this.showDivider = false,
  });

  final TelegramSettingsOption option;
  final bool selected;
  final ValueChanged<TelegramSettingsOption>? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final foregroundColor = option.destructive
        ? theme.colors.destructiveTextColor
        : theme.colors.textColor;

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
        onPressed: option.enabled
            ? (onTap == null ? null : () => onTap?.call(option))
            : null,
        child: Row(
          children: [
            if (option.icon != null) ...[
              Icon(
                option.icon,
                size: 16,
                color: option.enabled
                    ? foregroundColor
                    : theme.colors.subtitleTextColor,
              ),
              const SizedBox(width: TelegramSpacing.s),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: option.enabled
                          ? foregroundColor
                          : theme.colors.subtitleTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (option.subtitle != null &&
                      option.subtitle!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: TelegramSpacing.xxs),
                      child: Text(
                        option.subtitle!,
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
            if (option.badgeLabel != null && option.badgeLabel!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: TelegramSpacing.xs),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TelegramSpacing.xs,
                    vertical: TelegramSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: option.destructive
                        ? theme.colors.destructiveTextColor.withValues(
                            alpha: 0.15,
                          )
                        : theme.colors.linkColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    option.badgeLabel!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: option.destructive
                          ? theme.colors.destructiveTextColor
                          : theme.colors.linkColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: TelegramSpacing.xs),
            Icon(
              selected ? CupertinoIcons.checkmark_alt : CupertinoIcons.circle,
              size: selected ? 18 : 16,
              color: selected
                  ? theme.colors.linkColor
                  : theme.colors.subtitleTextColor.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}
