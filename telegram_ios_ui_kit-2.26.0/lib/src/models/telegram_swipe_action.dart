import 'package:flutter/cupertino.dart';

typedef TelegramSwipeActionCallback = Future<void> Function();

class TelegramSwipeAction {
  const TelegramSwipeAction({
    required this.label,
    this.icon,
    this.destructive = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final bool destructive;
  final TelegramSwipeActionCallback? onTap;
}
