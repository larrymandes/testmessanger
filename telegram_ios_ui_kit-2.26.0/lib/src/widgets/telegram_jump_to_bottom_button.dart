import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/telegram_theme.dart';

class TelegramJumpToBottomButton extends StatelessWidget {
  const TelegramJumpToBottomButton({
    super.key,
    required this.onPressed,
    this.unreadCount = 0,
    this.visible = true,
    this.size = 38,
    this.icon = CupertinoIcons.chevron_down,
  });

  final VoidCallback onPressed;
  final int unreadCount;
  final bool visible;
  final double size;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final effectiveUnreadCount = unreadCount < 0 ? 0 : unreadCount;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        offset: visible ? Offset.zero : const Offset(0, 0.36),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          opacity: visible ? 1 : 0,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.square(size),
                  onPressed: onPressed,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      color: theme.colors.sectionBgColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colors.separatorColor,
                        width: 0.6,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(icon, size: 20, color: theme.colors.linkColor),
                  ),
                ),
              ),
              if (effectiveUnreadCount > 0)
                Positioned(
                  right: -4,
                  top: -4,
                  child: _UnreadBadge(count: effectiveUnreadCount),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final label = count > 99 ? '99+' : '$count';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      constraints: const BoxConstraints(minWidth: 18),
      decoration: BoxDecoration(
        color: theme.colors.unreadBadgeColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: theme.colors.sectionBgColor, width: 1.2),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colors.buttonTextColor,
          fontWeight: FontWeight.w700,
          height: 1.1,
        ),
      ),
    );
  }
}
