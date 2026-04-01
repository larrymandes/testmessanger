import 'package:flutter/material.dart';

typedef TelegramKeyboardButtonCallback = Future<void> Function();

class TelegramKeyboardButton {
  const TelegramKeyboardButton({
    required this.label,
    this.icon,
    this.isPrimary = false,
    this.isDestructive = false,
    this.onPressed,
  });

  final String label;
  final IconData? icon;
  final bool isPrimary;
  final bool isDestructive;
  final TelegramKeyboardButtonCallback? onPressed;
}
