import 'package:flutter/material.dart';

@immutable
class TelegramSearchResult {
  const TelegramSearchResult({
    required this.id,
    required this.title,
    required this.snippet,
    this.subtitle,
    this.timeLabel = '',
    this.sectionLabel,
    this.avatarImage,
    this.avatarFallback = '',
    this.isVerified = false,
    this.unreadCount = 0,
  });

  final String id;
  final String title;
  final String snippet;
  final String? subtitle;
  final String timeLabel;
  final String? sectionLabel;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final bool isVerified;
  final int unreadCount;
}
