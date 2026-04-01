import 'package:flutter/foundation.dart';

enum TelegramMessageStatus { sending, sent, delivered, read }

@immutable
class TelegramMessage {
  const TelegramMessage({
    required this.id,
    required this.text,
    required this.timeLabel,
    required this.isOutgoing,
    this.status = TelegramMessageStatus.sent,
    this.isEdited = false,
  });

  final String id;
  final String text;
  final String timeLabel;
  final bool isOutgoing;
  final TelegramMessageStatus status;
  final bool isEdited;
}
