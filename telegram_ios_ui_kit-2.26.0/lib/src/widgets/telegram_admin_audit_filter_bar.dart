import 'package:flutter/cupertino.dart';

import '../models/telegram_admin_audit_filter.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramAdminAuditFilterBar extends StatelessWidget {
  const TelegramAdminAuditFilterBar({
    super.key,
    required this.filters,
    required this.selectedId,
    this.onSelected,
    this.showCount = true,
  });

  final List<TelegramAdminAuditFilter> filters;
  final String selectedId;
  final ValueChanged<TelegramAdminAuditFilter>? onSelected;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: TelegramSpacing.xs),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = filter.id == selectedId;
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
            onPressed: onSelected == null ? null : () => onSelected!(filter),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (filter.icon != null) ...[
                  Icon(filter.icon, size: 14, color: textColor),
                  const SizedBox(width: TelegramSpacing.xs),
                ],
                Text(
                  filter.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (showCount && filter.count > 0) ...[
                  const SizedBox(width: TelegramSpacing.xs),
                  Text(
                    '${filter.count}',
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
