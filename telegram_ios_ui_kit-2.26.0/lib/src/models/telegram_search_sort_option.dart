import 'package:flutter/material.dart';

@immutable
class TelegramSearchSortOption {
  const TelegramSearchSortOption({
    required this.id,
    required this.label,
    this.icon,
  });

  final String id;
  final String label;
  final IconData? icon;
}
