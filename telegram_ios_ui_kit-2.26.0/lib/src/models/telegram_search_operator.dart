import 'package:flutter/material.dart';

@immutable
class TelegramSearchOperator {
  const TelegramSearchOperator({
    required this.id,
    required this.label,
    required this.token,
    this.description,
    this.example,
    this.icon,
  });

  final String id;
  final String label;
  final String token;
  final String? description;
  final String? example;
  final IconData? icon;

  TelegramSearchOperator copyWith({
    String? id,
    String? label,
    String? token,
    String? description,
    String? example,
    IconData? icon,
  }) {
    return TelegramSearchOperator(
      id: id ?? this.id,
      label: label ?? this.label,
      token: token ?? this.token,
      description: description ?? this.description,
      example: example ?? this.example,
      icon: icon ?? this.icon,
    );
  }
}
