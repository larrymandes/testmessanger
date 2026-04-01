import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsSectionFooter extends StatelessWidget {
  const TelegramSettingsSectionFooter({
    super.key,
    required this.message,
    this.icon = CupertinoIcons.info_circle,
    this.padding = const EdgeInsets.fromLTRB(
      TelegramSpacing.s,
      TelegramSpacing.s,
      TelegramSpacing.s,
      0,
    ),
  });

  final String message;
  final IconData icon;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: theme.colors.subtitleTextColor),
          const SizedBox(width: TelegramSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colors.subtitleTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
