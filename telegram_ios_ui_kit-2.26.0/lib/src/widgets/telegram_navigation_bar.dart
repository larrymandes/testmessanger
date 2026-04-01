import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramNavigationBar extends StatelessWidget {
  const TelegramNavigationBar({
    super.key,
    required this.title,
    this.leading,
    this.trailing,
    this.largeTitle = false,
  });

  final String title;
  final Widget? leading;
  final Widget? trailing;
  final bool largeTitle;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;

    return Container(
      color: colors.headerBgColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: theme.navBarHeight,
          padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.s),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colors.separatorColor, width: 0.5),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 80,
                child: Align(alignment: Alignment.centerLeft, child: leading),
              ),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style:
                      (largeTitle
                              ? theme.textTheme.headlineSmall
                              : theme.textTheme.titleLarge)
                          ?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textColor,
                          ),
                ),
              ),
              SizedBox(
                width: 80,
                child: Align(alignment: Alignment.centerRight, child: trailing),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
