import 'package:flutter/cupertino.dart';

import '../models/telegram_search_sort_option.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchSortBar extends StatelessWidget {
  const TelegramSearchSortBar({
    super.key,
    required this.options,
    required this.selectedId,
    this.onSelected,
  });

  final List<TelegramSearchSortOption> options;
  final String selectedId;
  final ValueChanged<TelegramSearchSortOption>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: TelegramSpacing.xs),
        itemBuilder: (context, index) {
          final option = options[index];
          final selected = option.id == selectedId;
          final foregroundColor = selected
              ? theme.colors.buttonTextColor
              : theme.colors.textColor;
          final backgroundColor = selected
              ? theme.colors.linkColor
              : theme.colors.sectionBgColor;

          return CupertinoButton(
            minimumSize: const Size(24, 24),
            padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.s),
            color: backgroundColor,
            borderRadius: BorderRadius.circular(999),
            onPressed: onSelected == null ? null : () => onSelected!(option),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (option.icon != null) ...[
                  Icon(option.icon, size: 13, color: foregroundColor),
                  const SizedBox(width: TelegramSpacing.xxs),
                ],
                Text(
                  option.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: foregroundColor,
                    fontWeight: FontWeight.w700,
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
