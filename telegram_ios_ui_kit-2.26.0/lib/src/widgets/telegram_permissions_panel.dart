import 'package:flutter/cupertino.dart';

import '../models/telegram_permission_toggle.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

typedef TelegramPermissionToggleChanged =
    void Function(TelegramPermissionToggle toggle, bool value);

class TelegramPermissionsPanel extends StatelessWidget {
  const TelegramPermissionsPanel({
    super.key,
    required this.toggles,
    this.onToggleChanged,
    this.title,
  });

  final List<TelegramPermissionToggle> toggles;
  final TelegramPermissionToggleChanged? onToggleChanged;
  final String? title;

  @override
  Widget build(BuildContext context) {
    if (toggles.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;

    return Container(
      decoration: BoxDecoration(
        color: theme.colors.sectionBgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colors.separatorColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null && title!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TelegramSpacing.m,
                TelegramSpacing.m,
                TelegramSpacing.m,
                TelegramSpacing.s,
              ),
              child: Text(
                title!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colors.textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          for (var i = 0; i < toggles.length; i++)
            _PermissionRow(
              toggle: toggles[i],
              showDivider: i < toggles.length - 1,
              onChanged: onToggleChanged,
            ),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({
    required this.toggle,
    required this.showDivider,
    required this.onChanged,
  });

  final TelegramPermissionToggle toggle;
  final bool showDivider;
  final TelegramPermissionToggleChanged? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final destructiveColor = theme.colors.destructiveTextColor;
    final titleColor = toggle.destructive
        ? destructiveColor
        : theme.colors.textColor;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: TelegramSpacing.m,
        vertical: TelegramSpacing.s,
      ),
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: theme.colors.separatorColor,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (toggle.icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                toggle.icon,
                size: 16,
                color: toggle.destructive
                    ? destructiveColor
                    : theme.colors.linkColor,
              ),
            ),
            const SizedBox(width: TelegramSpacing.s),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  toggle.label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (toggle.description != null &&
                    toggle.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: TelegramSpacing.xxs),
                  Text(
                    toggle.description!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: TelegramSpacing.s),
          if (toggle.locked)
            Icon(
              CupertinoIcons.lock_fill,
              size: 16,
              color: theme.colors.subtitleTextColor,
            )
          else
            CupertinoSwitch(
              value: toggle.enabled,
              onChanged: onChanged == null
                  ? null
                  : (value) => onChanged!(toggle, value),
            ),
        ],
      ),
    );
  }
}
