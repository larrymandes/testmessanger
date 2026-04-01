import 'package:flutter/material.dart';

import 'telegram_search_result.dart';

@immutable
class TelegramSearchResultGroup {
  const TelegramSearchResultGroup({
    required this.id,
    required this.label,
    required this.results,
    this.icon,
  });

  final String id;
  final String label;
  final List<TelegramSearchResult> results;
  final IconData? icon;
}
