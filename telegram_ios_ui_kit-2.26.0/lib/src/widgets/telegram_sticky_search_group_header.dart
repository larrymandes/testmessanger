import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramStickySearchGroupHeader extends StatelessWidget {
  const TelegramStickySearchGroupHeader({
    super.key,
    required this.label,
    this.count,
    this.icon,
    this.pinned = true,
    this.height = 34,
    this.backgroundOpacity = 0.96,
    this.backgroundColor,
    this.showBottomDivider = true,
  });

  final String label;
  final int? count;
  final IconData? icon;
  final bool pinned;
  final double height;
  final double backgroundOpacity;
  final Color? backgroundColor;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _TelegramStickySearchGroupHeaderDelegate(
        label: label,
        count: count,
        icon: icon,
        height: height,
        backgroundOpacity: backgroundOpacity,
        backgroundColor: backgroundColor,
        showBottomDivider: showBottomDivider,
      ),
    );
  }
}

class _TelegramStickySearchGroupHeaderDelegate
    extends SliverPersistentHeaderDelegate {
  const _TelegramStickySearchGroupHeaderDelegate({
    required this.label,
    required this.count,
    required this.icon,
    required this.height,
    required this.backgroundOpacity,
    required this.backgroundColor,
    required this.showBottomDivider,
  });

  final String label;
  final int? count;
  final IconData? icon;
  final double height;
  final double backgroundOpacity;
  final Color? backgroundColor;
  final bool showBottomDivider;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = context.telegramTheme;
    final color = (backgroundColor ?? theme.colors.bgColor).withValues(
      alpha: backgroundOpacity.clamp(0, 1).toDouble(),
    );
    final showShadow = overlapsContent || shrinkOffset > 0;
    final bottomBorder = showBottomDivider && showShadow
        ? Border(
            bottom: BorderSide(color: theme.colors.separatorColor, width: 0.5),
          )
        : null;

    return Container(
      decoration: BoxDecoration(color: color, border: bottomBorder),
      padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.l),
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: theme.colors.subtitleTextColor),
            const SizedBox(width: TelegramSpacing.xs),
          ],
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colors.subtitleTextColor,
                letterSpacing: 0.5,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TelegramSpacing.xs,
                vertical: TelegramSpacing.xxs,
              ),
              decoration: BoxDecoration(
                color: theme.colors.secondaryBgColor,
                borderRadius: BorderRadius.circular(999),
                boxShadow: showShadow
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                '$count',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colors.subtitleTextColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(
    covariant _TelegramStickySearchGroupHeaderDelegate oldDelegate,
  ) {
    return oldDelegate.label != label ||
        oldDelegate.count != count ||
        oldDelegate.icon != icon ||
        oldDelegate.height != height ||
        oldDelegate.backgroundOpacity != backgroundOpacity ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.showBottomDivider != showBottomDivider;
  }
}
