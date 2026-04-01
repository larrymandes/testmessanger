import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramLargeTitleHeader extends StatelessWidget {
  const TelegramLargeTitleHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      TelegramSpacing.s,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
    this.showBottomDivider = true,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool showBottomDivider;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Container(
      color: theme.colors.headerBgColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              height: theme.navBarHeight,
              child: Row(
                children: [
                  SizedBox(
                    width: 88,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: leading,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 88,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: trailing,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: padding,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: theme.colors.textColor,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.6,
                        height: 1.04,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: TelegramSpacing.xs),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colors.subtitleTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (showBottomDivider)
              Divider(
                height: 0.5,
                thickness: 0.5,
                color: theme.colors.separatorColor,
              ),
          ],
        ),
      ),
    );
  }
}

class TelegramCollapsibleLargeTitle extends StatelessWidget {
  const TelegramCollapsibleLargeTitle({
    super.key,
    required this.title,
    required this.minExtent,
    required this.maxExtent,
    this.leading,
    this.trailing,
    this.pinned = true,
  });

  final String title;
  final double minExtent;
  final double maxExtent;
  final Widget? leading;
  final Widget? trailing;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return SliverPersistentHeader(
      pinned: pinned,
      delegate: _TelegramLargeTitleDelegate(
        title: title,
        minExtent: minExtent,
        maxExtent: maxExtent,
        leading: leading,
        trailing: trailing,
        theme: theme,
      ),
    );
  }
}

class _TelegramLargeTitleDelegate extends SliverPersistentHeaderDelegate {
  _TelegramLargeTitleDelegate({
    required this.title,
    required this.minExtent,
    required this.maxExtent,
    required this.theme,
    this.leading,
    this.trailing,
  });

  final String title;
  @override
  final double minExtent;
  @override
  final double maxExtent;
  final Widget? leading;
  final Widget? trailing;
  final TelegramThemeData theme;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final progress = (shrinkOffset / (maxExtent - minExtent)).clamp(0.0, 1.0);
    final titleScale = Tween<double>(begin: 1.0, end: 0.74).transform(progress);
    final titleOpacity = Tween<double>(
      begin: 1.0,
      end: 0.92,
    ).transform(progress);

    return Container(
      color: theme.colors.headerBgColor,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.l),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              leading ?? const SizedBox(width: 28),
              const SizedBox(width: TelegramSpacing.m),
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Opacity(
                    opacity: titleOpacity,
                    child: Transform.scale(
                      scale: titleScale,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: theme.colors.textColor,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: TelegramSpacing.m),
              trailing ?? const SizedBox(width: 28),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TelegramLargeTitleDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.minExtent != minExtent ||
        oldDelegate.maxExtent != maxExtent ||
        oldDelegate.leading != leading ||
        oldDelegate.trailing != trailing ||
        oldDelegate.theme != theme;
  }
}
