import 'package:flutter/material.dart';

@immutable
class TelegramSearchExecution {
  const TelegramSearchExecution({
    required this.id,
    required this.query,
    required this.status,
    this.scopeLabel,
    this.dateRangeLabel,
    this.startedAtLabel,
    this.durationMs,
    this.resultCount,
    this.errorMessage,
    this.fromCache = false,
  });

  final String id;
  final String query;
  final String status;
  final String? scopeLabel;
  final String? dateRangeLabel;
  final String? startedAtLabel;
  final int? durationMs;
  final int? resultCount;
  final String? errorMessage;
  final bool fromCache;

  String get normalizedStatus => status.trim().toLowerCase();

  bool get isSuccess {
    return normalizedStatus == 'success' ||
        normalizedStatus == 'succeeded' ||
        normalizedStatus == 'completed' ||
        normalizedStatus == 'cached';
  }

  bool get isFailure {
    return normalizedStatus == 'failed' ||
        normalizedStatus == 'failure' ||
        normalizedStatus == 'error';
  }

  bool get isRunning {
    return normalizedStatus == 'running' ||
        normalizedStatus == 'queued' ||
        normalizedStatus == 'pending';
  }

  String get statusLabel {
    if (normalizedStatus.isEmpty) {
      return 'Unknown';
    }
    return normalizedStatus
        .split(RegExp(r'[_\s-]+'))
        .where((segment) => segment.isNotEmpty)
        .map((segment) => '${segment[0].toUpperCase()}${segment.substring(1)}')
        .join(' ');
  }

  TelegramSearchExecution copyWith({
    String? id,
    String? query,
    String? status,
    String? scopeLabel,
    String? dateRangeLabel,
    String? startedAtLabel,
    int? durationMs,
    int? resultCount,
    String? errorMessage,
    bool? fromCache,
  }) {
    return TelegramSearchExecution(
      id: id ?? this.id,
      query: query ?? this.query,
      status: status ?? this.status,
      scopeLabel: scopeLabel ?? this.scopeLabel,
      dateRangeLabel: dateRangeLabel ?? this.dateRangeLabel,
      startedAtLabel: startedAtLabel ?? this.startedAtLabel,
      durationMs: durationMs ?? this.durationMs,
      resultCount: resultCount ?? this.resultCount,
      errorMessage: errorMessage ?? this.errorMessage,
      fromCache: fromCache ?? this.fromCache,
    );
  }
}
