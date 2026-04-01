import 'package:flutter/cupertino.dart';

import '../models/telegram_search_command.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchCommandTile extends StatelessWidget {
  const TelegramSearchCommandTile({
    super.key,
    required this.command,
    this.onTap,
    this.showChevron = true,
    this.showDivider = false,
  });

  final TelegramSearchCommand command;
  final ValueChanged<TelegramSearchCommand>? onTap;
  final bool showChevron;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final foregroundColor = command.destructive
        ? theme.colors.destructiveTextColor
        : theme.colors.textColor;
    final subtitleColor = command.destructive
        ? theme.colors.destructiveTextColor.withValues(alpha: 0.82)
        : theme.colors.subtitleTextColor;

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
        onPressed: command.enabled
            ? (onTap == null ? null : () => onTap!(command))
            : null,
        child: Row(
          children: [
            if (command.icon != null) ...[
              Icon(
                command.icon,
                size: 16,
                color: command.enabled
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
                    command.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: command.enabled
                          ? foregroundColor
                          : theme.colors.subtitleTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (command.subtitle != null &&
                      command.subtitle!.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: TelegramSpacing.xxs),
                      child: Text(
                        command.subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: subtitleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (command.badgeLabel != null && command.badgeLabel!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: TelegramSpacing.xs),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TelegramSpacing.xs,
                    vertical: TelegramSpacing.xxs,
                  ),
                  decoration: BoxDecoration(
                    color: command.destructive
                        ? theme.colors.destructiveTextColor.withValues(
                            alpha: 0.15,
                          )
                        : theme.colors.linkColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    command.badgeLabel!,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: command.destructive
                          ? theme.colors.destructiveTextColor
                          : theme.colors.linkColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            if (showChevron) ...[
              const SizedBox(width: TelegramSpacing.xs),
              Icon(
                CupertinoIcons.chevron_right,
                size: 14,
                color: theme.colors.subtitleTextColor,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
