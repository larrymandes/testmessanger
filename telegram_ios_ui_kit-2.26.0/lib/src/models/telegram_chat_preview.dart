import 'package:flutter/material.dart';

@immutable
class TelegramChatPreview {
  const TelegramChatPreview({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    this.unreadCount = 0,
    this.avatarImage,
    this.avatarFallback = '',
    this.isMuted = false,
    this.isPinned = false,
    this.isOnline = false,
    this.folderId = 'all',
  });

  final String id;
  final String title;
  final String subtitle;
  final String timeLabel;
  final int unreadCount;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final bool isMuted;
  final bool isPinned;
  final bool isOnline;
  final String folderId;
}
