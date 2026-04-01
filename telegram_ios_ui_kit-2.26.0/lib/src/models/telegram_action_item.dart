import 'package:flutter/cupertino.dart';

typedef TelegramActionCallback = Future<void> Function();

class TelegramActionItem {
  const TelegramActionItem({
    required this.label,
    this.icon,
    this.isDestructive = false,
    this.onPressed,
  });

  final String label;
  final IconData? icon;
  final bool isDestructive;
  final TelegramActionCallback? onPressed;
}
