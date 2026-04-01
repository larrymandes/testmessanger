import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_action_item.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramContextMenu extends StatelessWidget {
  const TelegramContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.preview,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.enableHapticFeedback = true,
  });

  final Widget child;
  final List<TelegramActionItem> actions;
  final Widget? preview;
  final BorderRadius borderRadius;
  final bool enableHapticFeedback;

  @override
  Widget build(BuildContext context) {
    return CupertinoContextMenu.builder(
      enableHapticFeedback: enableHapticFeedback,
      actions: [
        for (final action in actions)
          CupertinoContextMenuAction(
            isDestructiveAction: action.isDestructive,
            trailingIcon: action.icon,
            onPressed: () async {
              Navigator.of(context).pop();
              await action.onPressed?.call();
            },
            child: Text(action.label),
          ),
      ],
      builder: (context, animation) {
        if (preview != null) {
          return ClipRRect(borderRadius: borderRadius, child: preview!);
        }
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                spreadRadius: -8,
                color: Colors.black.withValues(alpha: 0.22),
              ),
            ],
          ),
          child: child,
        );
      },
    );
  }
}

class TelegramContextMenuPreview extends StatelessWidget {
  const TelegramContextMenuPreview({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.all(TelegramSpacing.l),
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Container(
      color: theme.colors.sectionBgColor,
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: TelegramSpacing.m),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colors.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: TelegramSpacing.xs),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: TelegramSpacing.m),
            trailing!,
          ],
        ],
      ),
    );
  }
}
