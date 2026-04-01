import 'package:flutter/material.dart';

@immutable
class TelegramPermissionToggle {
  const TelegramPermissionToggle({
    required this.id,
    required this.label,
    required this.enabled,
    this.description,
    this.icon,
    this.locked = false,
    this.destructive = false,
  });

  final String id;
  final String label;
  final bool enabled;
  final String? description;
  final IconData? icon;
  final bool locked;
  final bool destructive;

  TelegramPermissionToggle copyWith({
    String? id,
    String? label,
    bool? enabled,
    String? description,
    IconData? icon,
    bool? locked,
    bool? destructive,
  }) {
    return TelegramPermissionToggle(
      id: id ?? this.id,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      locked: locked ?? this.locked,
      destructive: destructive ?? this.destructive,
    );
  }
}
