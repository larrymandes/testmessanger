import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

@immutable
class TelegramChannelStatItem {
  const TelegramChannelStatItem({
    required this.label,
    required this.value,
    this.icon,
    this.accentColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final Color? accentColor;
}

class TelegramChannelStatsGrid extends StatelessWidget {
  const TelegramChannelStatsGrid({
    super.key,
    required this.items,
    this.crossAxisCount = 3,
    this.onItemTap,
  });

  final List<TelegramChannelStatItem> items;
  final int crossAxisCount;
  final ValueChanged<TelegramChannelStatItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = context.telegramTheme;
    final effectiveColumns = crossAxisCount.clamp(2, 4);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: effectiveColumns,
        crossAxisSpacing: TelegramSpacing.s,
        mainAxisSpacing: TelegramSpacing.s,
        childAspectRatio: 1.28,
      ),
      itemBuilder: (context, index) {
        final item = items[index];
        final accentColor = item.accentColor ?? theme.colors.linkColor;
        return InkWell(
          onTap: onItemTap == null ? null : () => onItemTap!(item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colors.sectionBgColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colors.separatorColor,
                width: 0.5,
              ),
            ),
            padding: const EdgeInsets.all(TelegramSpacing.s),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (item.icon != null) ...[
                  Icon(item.icon, size: 15, color: accentColor),
                  const SizedBox(height: TelegramSpacing.xs),
                ],
                Text(
                  item.value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colors.textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: TelegramSpacing.xxs),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colors.subtitleTextColor,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
