import 'package:flutter/cupertino.dart';

import '../models/telegram_settings_shortcut.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsShortcutTile extends StatelessWidget {
  const TelegramSettingsShortcutTile({
    super.key,
    required this.shortcut,
    this.onTap,
  });

  final TelegramSettingsShortcut shortcut;
  final ValueChanged<TelegramSettingsShortcut>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final foregroundColor = shortcut.destructive
        ? theme.colors.destructiveTextColor
        : theme.colors.textColor;

    return CupertinoButton(
      padding: const EdgeInsets.all(TelegramSpacing.s),
      minimumSize: Size.zero,
      borderRadius: BorderRadius.circular(12),
      color: theme.colors.sectionBgColor,
      onPressed: shortcut.enabled
          ? (onTap == null ? null : () => onTap?.call(shortcut))
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              if (shortcut.icon != null)
                Icon(
                  shortcut.icon,
                  size: 16,
                  color: shortcut.enabled
                      ? foregroundColor
                      : theme.colors.subtitleTextColor,
                ),
              if (shortcut.icon != null)
                const SizedBox(width: TelegramSpacing.xs),
              Expanded(
                child: Text(
                  shortcut.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: shortcut.enabled
                        ? foregroundColor
                        : theme.colors.subtitleTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (shortcut.subtitle != null &&
              shortcut.subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: TelegramSpacing.xxs),
            Text(
              shortcut.subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colors.subtitleTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          if (shortcut.badgeLabel != null &&
              shortcut.badgeLabel!.trim().isNotEmpty) ...[
            const SizedBox(height: TelegramSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TelegramSpacing.xs,
                vertical: TelegramSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: shortcut.destructive
                    ? theme.colors.destructiveTextColor.withValues(alpha: 0.16)
                    : theme.colors.linkColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                shortcut.badgeLabel!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: shortcut.destructive
                      ? theme.colors.destructiveTextColor
                      : theme.colors.linkColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
