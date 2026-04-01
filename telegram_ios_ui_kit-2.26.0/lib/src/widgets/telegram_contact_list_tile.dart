import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_contact.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';

class TelegramContactListTile extends StatelessWidget {
  const TelegramContactListTile({
    super.key,
    required this.contact,
    this.onTap,
    this.trailing,
  });

  final TelegramContact contact;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final subtitle = contact.subtitle;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: TelegramSpacing.l,
          vertical: TelegramSpacing.s,
        ),
        decoration: BoxDecoration(
          color: theme.colors.sectionBgColor,
          border: Border(
            bottom: BorderSide(color: theme.colors.separatorColor, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            TelegramAvatar(
              image: contact.avatarImage,
              fallbackText: contact.avatarFallback.isNotEmpty
                  ? contact.avatarFallback
                  : contact.name,
              isOnline: contact.isOnline,
            ),
            const SizedBox(width: TelegramSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: theme.colors.textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (contact.isVerified)
                        Icon(
                          CupertinoIcons.checkmark_seal_fill,
                          size: 16,
                          color: theme.colors.linkColor,
                        ),
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: TelegramSpacing.xs),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colors.subtitleTextColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: TelegramSpacing.s),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
