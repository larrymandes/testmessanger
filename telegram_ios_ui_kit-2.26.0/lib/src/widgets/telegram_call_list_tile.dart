import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/telegram_call_log.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';

class TelegramCallListTile extends StatelessWidget {
  const TelegramCallListTile({
    super.key,
    required this.call,
    this.onTap,
    this.onInfoTap,
  });

  final TelegramCallLog call;
  final VoidCallback? onTap;
  final VoidCallback? onInfoTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final directionColor = switch (call.direction) {
      TelegramCallDirection.missed => theme.colors.destructiveTextColor,
      _ => theme.colors.linkColor,
    };
    final directionIcon = switch (call.direction) {
      TelegramCallDirection.incoming => CupertinoIcons.arrow_down_left,
      TelegramCallDirection.outgoing => CupertinoIcons.arrow_up_right,
      TelegramCallDirection.missed => CupertinoIcons.phone_down_fill,
    };

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
              fallbackText: call.avatarFallback.isNotEmpty
                  ? call.avatarFallback
                  : call.name,
            ),
            const SizedBox(width: TelegramSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    call.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: call.direction == TelegramCallDirection.missed
                          ? theme.colors.destructiveTextColor
                          : theme.colors.textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: TelegramSpacing.xs),
                  Row(
                    children: [
                      Icon(directionIcon, size: 14, color: directionColor),
                      const SizedBox(width: TelegramSpacing.xs),
                      Flexible(
                        child: Text(
                          [
                            call.timeLabel,
                            if (call.durationLabel != null) call.durationLabel!,
                          ].join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colors.subtitleTextColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: TelegramSpacing.s),
            Icon(
              call.type == TelegramCallType.video
                  ? CupertinoIcons.video_camera_solid
                  : CupertinoIcons.phone_fill,
              size: 20,
              color: theme.colors.linkColor,
            ),
            const SizedBox(width: TelegramSpacing.s),
            CupertinoButton(
              onPressed: onInfoTap,
              padding: EdgeInsets.zero,
              minimumSize: const Size(20, 20),
              child: Icon(
                CupertinoIcons.info_circle,
                size: 20,
                color: theme.colors.subtitleTextColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
