import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

enum TelegramMiniAppButtonType { webApp, textCommands, closeApp }

class TelegramMiniAppButton extends StatelessWidget {
  const TelegramMiniAppButton({
    super.key,
    required this.label,
    required this.type,
    this.onPressed,
  });

  final String label;
  final TelegramMiniAppButtonType type;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;

    return CupertinoButton(
      onPressed: onPressed,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.l,
          vertical: TelegramSpacing.s,
        ),
        decoration: BoxDecoration(
          color: colors.sectionBgColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: colors.separatorColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(_icon(type), size: 18, color: colors.linkColor),
            const SizedBox(width: TelegramSpacing.s),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.linkColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _icon(TelegramMiniAppButtonType type) {
    switch (type) {
      case TelegramMiniAppButtonType.webApp:
        return CupertinoIcons.globe;
      case TelegramMiniAppButtonType.textCommands:
        return CupertinoIcons.command;
      case TelegramMiniAppButtonType.closeApp:
        return CupertinoIcons.xmark;
    }
  }
}
