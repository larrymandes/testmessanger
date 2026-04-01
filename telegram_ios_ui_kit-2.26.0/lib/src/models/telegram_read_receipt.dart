import 'package:flutter/material.dart';

@immutable
class TelegramReadReceipt {
  const TelegramReadReceipt({
    required this.id,
    required this.name,
    this.avatarImage,
    this.avatarFallback = '',
    this.seenAtLabel,
  });

  final String id;
  final String name;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final String? seenAtLabel;
}
