import 'dart:async';

import 'package:flutter/cupertino.dart';

import '../models/telegram_action_item.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramChatActionToolbar extends StatelessWidget {
  const TelegramChatActionToolbar({
    super.key,
    required this.actions,
    this.title,
    this.selectedCount,
    this.leading,
    this.trailing,
    this.showBottomDivider = true,
  });

  final List<TelegramActionItem> actions;
  final String? title;
  final int? selectedCount;
  final Widget? leading;
  final Widget? trailing;
  final bool showBottomDivider;

  String _resolveTitle() {
    if (title != null && title!.trim().isNotEmpty) {
      return title!;
    }
    if (selectedCount != null) {
      return '$selectedCount selected';
    }
    return 'Actions';
  }

  void _handleAction(TelegramActionItem action) {
    final callback = action.onPressed;
    if (callback != null) {
      unawaited(callback());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = context.telegramTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        TelegramSpacing.s,
        TelegramSpacing.s,
        TelegramSpacing.s,
        TelegramSpacing.s,
      ),
      decoration: BoxDecoration(
        color: theme.colors.headerBgColor,
        border: showBottomDivider
            ? Border(
                bottom: BorderSide(
                  color: theme.colors.separatorColor,
                  width: 0.5,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            leading!,
            const SizedBox(width: TelegramSpacing.s),
          ],
          Text(
            _resolveTitle(),
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colors.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          for (var index = 0; index < actions.length; index++) ...[
            _ToolbarActionButton(
              action: actions[index],
              onPressed: () => _handleAction(actions[index]),
            ),
            if (index < actions.length - 1) const SizedBox(width: 6),
          ],
          if (trailing != null) ...[
            const SizedBox(width: TelegramSpacing.s),
            trailing!,
          ],
        ],
      ),
    );
  }
}

class _ToolbarActionButton extends StatelessWidget {
  const _ToolbarActionButton({required this.action, required this.onPressed});

  final TelegramActionItem action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final color = action.isDestructive
        ? theme.colors.destructiveTextColor
        : theme.colors.linkColor;

    return CupertinoButton(
      minimumSize: const Size(24, 24),
      padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.s),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (action.icon != null) ...[
            Icon(action.icon, size: 16, color: color),
            const SizedBox(width: TelegramSpacing.xs),
          ],
          Text(
            action.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
