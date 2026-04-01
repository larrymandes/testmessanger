import 'package:flutter/material.dart';

@immutable
class TelegramStory {
  const TelegramStory({
    required this.id,
    required this.title,
    this.avatarImage,
    this.avatarFallback = '',
    this.hasUnseenStories = true,
  });

  final String id;
  final String title;
  final ImageProvider<Object>? avatarImage;
  final String avatarFallback;
  final bool hasUnseenStories;
}
