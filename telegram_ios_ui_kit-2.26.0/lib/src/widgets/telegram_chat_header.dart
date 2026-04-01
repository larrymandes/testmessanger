import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';
import 'telegram_avatar.dart';

class TelegramChatHeader extends StatelessWidget {
  const TelegramChatHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.avatarImage,
    this.avatarFallback = '',
    this.onBack,
    this.onVoiceCall,
    this.onVideoCall,
  });

  final String title;
  final String subtitle;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final VoidCallback? onBack;
  final VoidCallback? onVoiceCall;
  final VoidCallback? onVideoCall;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Container(
      color: theme.colors.headerBgColor,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: theme.navBarHeight + 4,
          padding: const EdgeInsets.symmetric(horizontal: TelegramSpacing.s),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: theme.colors.separatorColor,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onBack,
                child: const Icon(CupertinoIcons.back, size: 22),
              ),
              const SizedBox(width: TelegramSpacing.xs),
              TelegramAvatar(
                image: avatarImage,
                fallbackText: avatarFallback.isNotEmpty
                    ? avatarFallback
                    : title,
                size: 32,
              ),
              const SizedBox(width: TelegramSpacing.s),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colors.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colors.subtitleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onVoiceCall,
                child: Icon(
                  CupertinoIcons.phone_fill,
                  color: theme.colors.linkColor,
                ),
              ),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: onVideoCall,
                child: Icon(
                  CupertinoIcons.video_camera_solid,
                  color: theme.colors.linkColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
