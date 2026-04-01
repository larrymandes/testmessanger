import 'package:flutter/material.dart';

@immutable
class TelegramSearchDateRange {
  const TelegramSearchDateRange({
    required this.id,
    required this.label,
    this.description,
    this.icon,
  });

  final String id;
  final String label;
  final String? description;
  final IconData? icon;

  TelegramSearchDateRange copyWith({
    String? id,
    String? label,
    String? description,
    IconData? icon,
  }) {
    return TelegramSearchDateRange(
      id: id ?? this.id,
      label: label ?? this.label,
      description: description ?? this.description,
      icon: icon ?? this.icon,
    );
  }
}
