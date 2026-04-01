import 'package:flutter/material.dart';

@immutable
class TelegramSearchFilterOption {
  const TelegramSearchFilterOption({
    required this.id,
    required this.label,
    this.selected = false,
    this.description,
    this.icon,
    this.locked = false,
  });

  final String id;
  final String label;
  final bool selected;
  final String? description;
  final IconData? icon;
  final bool locked;

  TelegramSearchFilterOption copyWith({
    String? id,
    String? label,
    bool? selected,
    String? description,
    IconData? icon,
    bool? locked,
  }) {
    return TelegramSearchFilterOption(
      id: id ?? this.id,
      label: label ?? this.label,
      selected: selected ?? this.selected,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      locked: locked ?? this.locked,
    );
  }
}
