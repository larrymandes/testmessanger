import 'package:flutter/foundation.dart';

enum TelegramCallType { audio, video }

enum TelegramCallDirection { incoming, outgoing, missed }

@immutable
class TelegramCallLog {
  const TelegramCallLog({
    required this.id,
    required this.name,
    required this.timeLabel,
    required this.direction,
    this.type = TelegramCallType.audio,
    this.durationLabel,
    this.avatarFallback = '',
  });

  final String id;
  final String name;
  final String timeLabel;
  final TelegramCallDirection direction;
  final TelegramCallType type;
  final String? durationLabel;
  final String avatarFallback;
}
