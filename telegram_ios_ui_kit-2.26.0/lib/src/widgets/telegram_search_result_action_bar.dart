import 'package:flutter/cupertino.dart';

import '../models/telegram_search_result_action.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchResultActionBar extends StatelessWidget {
  const TelegramSearchResultActionBar({
    super.key,
    required this.actions,
    this.onSelected,
  });

  final List<TelegramSearchResultAction> actions;
  final ValueChanged<TelegramSearchResultAction>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: actions.length,
        separatorBuilder: (_, _) => const SizedBox(width: TelegramSpacing.xs),
        itemBuilder: (context, index) {
          final action = actions[index];
          final foregroundColor = action.destructive
              ? theme.colors.destructiveTextColor
              : theme.colors.textColor;
          final backgroundColor = action.destructive
              ? theme.colors.destructiveTextColor.withValues(alpha: 0.12)
              : theme.colors.sectionBgColor;

          return CupertinoButton(
            minimumSize: const Size(24, 24),
            padding: const EdgeInsets.symmetric(
              horizontal: TelegramSpacing.s,
              vertical: TelegramSpacing.xs,
            ),
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            onPressed: !action.enabled || onSelected == null
                ? null
                : () => onSelected!(action),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (action.icon != null) ...[
                  Icon(action.icon, size: 13, color: foregroundColor),
                  const SizedBox(width: TelegramSpacing.xxs),
                ],
                Text(
                  action.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: action.enabled
                        ? foregroundColor
                        : theme.colors.subtitleTextColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (action.badgeLabel != null && action.badgeLabel!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: TelegramSpacing.xxs),
                    child: Text(
                      action.badgeLabel!,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: action.enabled
                            ? foregroundColor.withValues(alpha: 0.84)
                            : theme.colors.subtitleTextColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
