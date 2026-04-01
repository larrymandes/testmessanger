import 'package:flutter/cupertino.dart';

import '../models/telegram_saved_search.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSavedSearchesBar extends StatelessWidget {
  const TelegramSavedSearchesBar({
    super.key,
    required this.searches,
    this.selectedId,
    this.onSelected,
    this.onClearSelection,
    this.clearLabel = 'Clear',
  });

  final List<TelegramSavedSearch> searches;
  final String? selectedId;
  final ValueChanged<TelegramSavedSearch>? onSelected;
  final VoidCallback? onClearSelection;
  final String clearLabel;

  @override
  Widget build(BuildContext context) {
    if (searches.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;
    final showClearAction = selectedId != null && onClearSelection != null;
    final totalItems = searches.length + (showClearAction ? 1 : 0);

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: totalItems,
        separatorBuilder: (_, _) => const SizedBox(width: TelegramSpacing.xs),
        itemBuilder: (context, index) {
          if (showClearAction && index == totalItems - 1) {
            return CupertinoButton(
              minimumSize: const Size(24, 24),
              padding: const EdgeInsets.symmetric(
                horizontal: TelegramSpacing.s,
                vertical: TelegramSpacing.xs,
              ),
              color: theme.colors.sectionBgColor,
              borderRadius: BorderRadius.circular(999),
              onPressed: onClearSelection,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    CupertinoIcons.xmark_circle_fill,
                    size: 13,
                    color: theme.colors.subtitleTextColor,
                  ),
                  const SizedBox(width: TelegramSpacing.xxs),
                  Text(
                    clearLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            );
          }

          final search = searches[index];
          final selected = selectedId == search.id;
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
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            onPressed: onSelected == null ? null : () => onSelected!(search),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (search.icon != null) ...[
                  Icon(search.icon, size: 13, color: textColor),
                  const SizedBox(width: TelegramSpacing.xxs),
                ],
                Text(
                  search.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (search.expectedCount != null && search.expectedCount! > 0)
                  Padding(
                    padding: const EdgeInsets.only(left: TelegramSpacing.xxs),
                    child: Text(
                      '${search.expectedCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: textColor.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w600,
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
