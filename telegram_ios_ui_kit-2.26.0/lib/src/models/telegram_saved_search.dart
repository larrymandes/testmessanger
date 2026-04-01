import 'package:flutter/material.dart';

@immutable
class TelegramSavedSearch {
  const TelegramSavedSearch({
    required this.id,
    required this.label,
    required this.query,
    this.description,
    this.scopeId = 'all',
    this.scopeLabel,
    this.sortId = 'relevance',
    this.sortLabel,
    this.filterIds = const [],
    this.icon,
    this.expectedCount,
  });

  final String id;
  final String label;
  final String query;
  final String? description;
  final String scopeId;
  final String? scopeLabel;
  final String sortId;
  final String? sortLabel;
  final List<String> filterIds;
  final IconData? icon;
  final int? expectedCount;

  TelegramSavedSearch copyWith({
    String? id,
    String? label,
    String? query,
    String? description,
    String? scopeId,
    String? scopeLabel,
    String? sortId,
    String? sortLabel,
    List<String>? filterIds,
    IconData? icon,
    int? expectedCount,
  }) {
    return TelegramSavedSearch(
      id: id ?? this.id,
      label: label ?? this.label,
      query: query ?? this.query,
      description: description ?? this.description,
      scopeId: scopeId ?? this.scopeId,
      scopeLabel: scopeLabel ?? this.scopeLabel,
      sortId: sortId ?? this.sortId,
      sortLabel: sortLabel ?? this.sortLabel,
      filterIds: filterIds ?? this.filterIds,
      icon: icon ?? this.icon,
      expectedCount: expectedCount ?? this.expectedCount,
    );
  }
}
