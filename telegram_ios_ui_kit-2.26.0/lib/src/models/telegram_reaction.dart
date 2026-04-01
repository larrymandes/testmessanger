import 'package:flutter/foundation.dart';

@immutable
class TelegramReaction {
  const TelegramReaction({
    required this.emoji,
    required this.count,
    this.selected = false,
  });

  final String emoji;
  final int count;
  final bool selected;

  TelegramReaction copyWith({String? emoji, int? count, bool? selected}) {
    return TelegramReaction(
      emoji: emoji ?? this.emoji,
      count: count ?? this.count,
      selected: selected ?? this.selected,
    );
  }
}
