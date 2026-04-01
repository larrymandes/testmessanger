import 'package:flutter/cupertino.dart';

import '../models/telegram_search_date_range.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSearchDateRangesBar extends StatelessWidget {
  const TelegramSearchDateRangesBar({
    super.key,
    required this.ranges,
    required this.selectedId,
    this.onSelected,
  });

  final List<TelegramSearchDateRange> ranges;
  final String selectedId;
  final ValueChanged<TelegramSearchDateRange>? onSelected;

  @override
  Widget build(BuildContext context) {
    if (ranges.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: ranges.length,
        separatorBuilder: (_, _) => const SizedBox(width: TelegramSpacing.xs),
        itemBuilder: (context, index) {
          final range = ranges[index];
          final selected = range.id == selectedId;
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
            onPressed: onSelected == null ? null : () => onSelected!(range),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (range.icon != null) ...[
                  Icon(range.icon, size: 13, color: foregroundColor),
                  const SizedBox(width: TelegramSpacing.xxs),
                ],
                Text(
                  range.label,
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
