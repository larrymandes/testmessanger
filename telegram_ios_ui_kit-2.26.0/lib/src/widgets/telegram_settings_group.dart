import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsGroup extends StatelessWidget {
  const TelegramSettingsGroup({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.backgroundColor,
    this.clipBehavior = Clip.antiAlias,
  });

  final List<Widget> children;
  final Widget? header;
  final Widget? footer;
  final EdgeInsets margin;
  final BorderRadius borderRadius;
  final Color? backgroundColor;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final resolvedBackgroundColor =
        backgroundColor ?? theme.colors.sectionBgColor;

    return Padding(
      padding: margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...[header].whereType<Widget>(),
          ClipRRect(
            borderRadius: borderRadius,
            clipBehavior: clipBehavior,
            child: DecoratedBox(
              decoration: BoxDecoration(color: resolvedBackgroundColor),
              child: Column(mainAxisSize: MainAxisSize.min, children: children),
            ),
          ),
          ...[footer].whereType<Widget>(),
        ],
      ),
    );
  }
}
