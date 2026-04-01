import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsCell extends StatelessWidget {
  const TelegramSettingsCell({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.switchValue,
    this.onSwitchChanged,
    this.onTap,
    this.destructive = false,
    this.showChevron = true,
    this.showDivider = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showChevron;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final titleColor = destructive
        ? colors.destructiveTextColor
        : colors.textColor;
    final hasTap = onTap != null || switchValue != null;

    Widget trailingWidget() {
      if (switchValue != null) {
        return CupertinoSwitch(value: switchValue!, onChanged: onSwitchChanged);
      }
      if (trailing != null) {
        return trailing!;
      }
      if (subtitle != null) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              subtitle!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.subtitleTextColor,
              ),
            ),
            if (showChevron) ...[
              const SizedBox(width: TelegramSpacing.xs),
              Icon(
                CupertinoIcons.chevron_forward,
                size: 16,
                color: colors.subtitleTextColor,
              ),
            ],
          ],
        );
      }
      if (showChevron) {
        return Icon(
          CupertinoIcons.chevron_forward,
          size: 16,
          color: colors.subtitleTextColor,
        );
      }
      return const SizedBox.shrink();
    }

    return InkWell(
      onTap: hasTap ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.l,
          vertical: TelegramSpacing.m,
        ),
        decoration: BoxDecoration(
          color: colors.sectionBgColor,
          border: showDivider
              ? Border(
                  bottom: BorderSide(color: colors.separatorColor, width: 0.5),
                )
              : null,
        ),
        child: Row(
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: TelegramSpacing.m),
            ],
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(color: titleColor),
              ),
            ),
            const SizedBox(width: TelegramSpacing.s),
            trailingWidget(),
          ],
        ),
      ),
    );
  }
}
