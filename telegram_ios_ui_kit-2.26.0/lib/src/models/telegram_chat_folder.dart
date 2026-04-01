import 'package:flutter/foundation.dart';

@immutable
class TelegramChatFolder {
  const TelegramChatFolder({
    required this.id,
    required this.title,
    this.unreadCount = 0,
  });

  final String id;
  final String title;
  final int unreadCount;
}
