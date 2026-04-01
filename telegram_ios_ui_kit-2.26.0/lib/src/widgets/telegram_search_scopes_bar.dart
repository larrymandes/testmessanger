import 'package:flutter/cupertino.dart';

import '../models/telegram_search_scope.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchScopesBar extends StatelessWidget {
  const TelegramSearchScopesBar({
    super.key,
    required this.scopes,
    required this.selectedId,
    this.onSelected,
    this.showCount = true,
  });

  final List<TelegramSearchScope> scopes;
  final String selectedId;
  final ValueChanged<TelegramSearchScope>? onSelected;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    if (scopes.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: scopes.length,
        separatorBuilder: (_, _) => const SizedBox(width: TelegramSpacing.xs),
        itemBuilder: (context, index) {
          final scope = scopes[index];
          final selected = scope.id == selectedId;
          final textColor = selected
              ? theme.colors.buttonTextColor
              : theme.colors.textColor;
          final backgroundColor = selected
              ? theme.colors.linkColor
              : theme.colors.sectionBgColor;

          return CupertinoButton(
            minimumSize: const Size(24, 24),
            padding: const EdgeInsets.symmetric(
              horizontal: TelegramSpacing.s,
              vertical: TelegramSpacing.xs,
            ),
            borderRadius: BorderRadius.circular(999),
            color: backgroundColor,
            onPressed: onSelected == null ? null : () => onSelected!(scope),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (scope.icon != null) ...[
                  Icon(scope.icon, size: 13, color: textColor),
                  const SizedBox(width: TelegramSpacing.xxs),
                ],
                Text(
                  scope.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (showCount && scope.count > 0) ...[
                  const SizedBox(width: TelegramSpacing.xxs),
                  Text(
                    '${scope.count}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: textColor.withValues(alpha: 0.92),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
