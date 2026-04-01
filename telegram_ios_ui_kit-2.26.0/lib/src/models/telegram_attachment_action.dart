import 'package:flutter/material.dart';

typedef TelegramAttachmentActionCallback = Future<void> Function();

class TelegramAttachmentAction {
  const TelegramAttachmentAction({
    required this.label,
    required this.icon,
    this.color,
    this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color? color;
  final TelegramAttachmentActionCallback? onPressed;
}
