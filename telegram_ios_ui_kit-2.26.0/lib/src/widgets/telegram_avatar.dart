import 'package:flutter/material.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramAvatar extends StatelessWidget {
  const TelegramAvatar({
    super.key,
    this.image,
    this.fallbackText = '',
    this.size = 44,
    this.isOnline = false,
  });

  final ImageProvider<Object>? image;
  final String fallbackText;
  final double size;
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final initials = _initials(fallbackText);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: size / 2,
            backgroundColor: theme.colors.secondaryBgColor,
            backgroundImage: image,
            child: image == null
                ? Text(
                    initials,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colors.textColor,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),
          if (isOnline)
            Positioned(
              right: -1,
              bottom: -1,
              child: Container(
                width: TelegramSpacing.m,
                height: TelegramSpacing.m,
                decoration: BoxDecoration(
                  color: theme.colors.onlineIndicatorColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: theme.colors.bgColor, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _initials(String value) {
    final words = value
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    if (words.isEmpty) {
      return '';
    }
    if (words.length == 1) {
      final word = words.first;
      return word.substring(0, word.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }
}
