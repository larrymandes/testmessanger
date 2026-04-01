import 'package:flutter/foundation.dart';

@immutable
class TelegramLinkPreview {
  const TelegramLinkPreview({
    required this.url,
    required this.title,
    required this.description,
    this.domain,
    this.siteName,
    this.thumbnailLabel,
  });

  final String url;
  final String title;
  final String description;
  final String? domain;
  final String? siteName;
  final String? thumbnailLabel;

  TelegramLinkPreview copyWith({
    String? url,
    String? title,
    String? description,
    String? domain,
    String? siteName,
    String? thumbnailLabel,
  }) {
    return TelegramLinkPreview(
      url: url ?? this.url,
      title: title ?? this.title,
      description: description ?? this.description,
      domain: domain ?? this.domain,
      siteName: siteName ?? this.siteName,
      thumbnailLabel: thumbnailLabel ?? this.thumbnailLabel,
    );
  }
}
