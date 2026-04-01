import 'package:flutter/foundation.dart';

@immutable
class TelegramPollOption {
  const TelegramPollOption({
    required this.id,
    required this.label,
    this.votes = 0,
    this.selected = false,
    this.isCorrect = false,
  });

  final String id;
  final String label;
  final int votes;
  final bool selected;
  final bool isCorrect;

  TelegramPollOption copyWith({
    String? id,
    String? label,
    int? votes,
    bool? selected,
    bool? isCorrect,
  }) {
    return TelegramPollOption(
      id: id ?? this.id,
      label: label ?? this.label,
      votes: votes ?? this.votes,
      selected: selected ?? this.selected,
      isCorrect: isCorrect ?? this.isCorrect,
    );
  }
}
