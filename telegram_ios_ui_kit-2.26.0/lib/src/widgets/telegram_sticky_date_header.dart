import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramStickyDateHeader extends StatelessWidget {
  const TelegramStickyDateHeader({
    super.key,
    required this.label,
    this.pinned = true,
    this.height = 34,
    this.backgroundOpacity = 0.94,
    this.backgroundColor,
    this.showBottomDivider = false,
  });

  final String label;
  final bool pinned;
  final double height;
  final double backgroundOpacity;
  final Color? backgroundColor;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _TelegramStickyDateHeaderDelegate(
        label: label,
        height: height,
        backgroundOpacity: backgroundOpacity,
        backgroundColor: backgroundColor,
        showBottomDivider: showBottomDivider,
      ),
    );
  }
}

class _TelegramStickyDateHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TelegramStickyDateHeaderDelegate({
    required this.label,
    required this.height,
    required this.backgroundOpacity,
    required this.backgroundColor,
    required this.showBottomDivider,
  });

  final String label;
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
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(vertical: TelegramSpacing.xs),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.s,
          vertical: TelegramSpacing.xs,
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
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colors.subtitleTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TelegramStickyDateHeaderDelegate oldDelegate) {
    return oldDelegate.label != label ||
        oldDelegate.height != height ||
        oldDelegate.backgroundOpacity != backgroundOpacity ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.showBottomDivider != showBottomDivider;
  }
}
