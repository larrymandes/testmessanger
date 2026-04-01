import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramMessageSelectionWrapper extends StatelessWidget {
  const TelegramMessageSelectionWrapper({
    super.key,
    required this.child,
    required this.isOutgoing,
    this.selectionMode = false,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  final Widget child;
  final bool isOutgoing;
  final bool selectionMode;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final indicator = AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: selectionMode ? 1 : 0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected
              ? theme.colors.linkColor
              : theme.colors.secondaryBgColor,
          border: Border.all(
            color: selected
                ? theme.colors.linkColor
                : theme.colors.subtitleTextColor.withValues(alpha: 0.45),
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          CupertinoIcons.check_mark,
          size: 12,
          color: selected ? theme.colors.buttonTextColor : Colors.transparent,
        ),
      ),
    );

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectionMode && !isOutgoing) ...[
            const SizedBox(width: TelegramSpacing.s),
            Padding(
              padding: const EdgeInsets.only(top: TelegramSpacing.s),
              child: indicator,
            ),
            const SizedBox(width: TelegramSpacing.s),
          ],
          Expanded(child: child),
          if (selectionMode && isOutgoing) ...[
            const SizedBox(width: TelegramSpacing.s),
            Padding(
              padding: const EdgeInsets.only(top: TelegramSpacing.s),
              child: indicator,
            ),
            const SizedBox(width: TelegramSpacing.s),
          ],
        ],
      ),
    );
  }
}
