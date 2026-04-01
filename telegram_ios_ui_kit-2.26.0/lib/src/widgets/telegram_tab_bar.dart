import 'package:flutter/material.dart';

import '../theme/telegram_theme.dart';

@immutable
class TelegramTabItem {
  const TelegramTabItem({
    required this.icon,
    required this.label,
    this.activeIcon,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
}

class TelegramBottomTabBar extends StatelessWidget {
  const TelegramBottomTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<TelegramTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Container(
      decoration: BoxDecoration(
        color: theme.colors.headerBgColor,
        border: Border(
          top: BorderSide(color: theme.colors.separatorColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 56,
          child: Row(
            children: [
              for (var index = 0; index < items.length; index++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(index),
                    child: _TelegramTabItemView(
                      item: items[index],
                      selected: index == currentIndex,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TelegramTabItemView extends StatelessWidget {
  const _TelegramTabItemView({required this.item, required this.selected});

  final TelegramTabItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final color = selected
        ? theme.colors.linkColor
        : theme.colors.subtitleTextColor;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          selected ? (item.activeIcon ?? item.icon) : item.icon,
          size: 22,
          color: color,
        ),
        const SizedBox(height: 2),
        Text(
          item.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
