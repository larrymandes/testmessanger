import 'package:flutter/material.dart';

@immutable
class TelegramSearchQueryToken {
  const TelegramSearchQueryToken({
    required this.id,
    required this.value,
    this.label,
    this.icon,
    this.isOperator = false,
  });

  final String id;
  final String value;
  final String? label;
  final IconData? icon;
  final bool isOperator;

  TelegramSearchQueryToken copyWith({
    String? id,
    String? value,
    String? label,
    IconData? icon,
    bool? isOperator,
  }) {
    return TelegramSearchQueryToken(
      id: id ?? this.id,
      value: value ?? this.value,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      isOperator: isOperator ?? this.isOperator,
    );
  }
}
