import 'package:flutter/material.dart';

import '../theme/telegram_theme.dart';

class TelegramHighlightedText extends StatelessWidget {
  const TelegramHighlightedText({
    super.key,
    required this.text,
    required this.query,
    this.style,
    this.highlightStyle,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textAlign,
  });

  final String text;
  final String query;
  final TextStyle? style;
  final TextStyle? highlightStyle;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
      );
    }

    final theme = context.telegramTheme;
    final defaultHighlightStyle =
        (style ?? theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
          color: theme.colors.linkColor,
          fontWeight: FontWeight.w700,
        );
    final spans = _buildHighlightedSpans(
      text: text,
      query: normalizedQuery,
      normalStyle: style,
      highlighted: highlightStyle ?? defaultHighlightStyle,
    );

    return RichText(
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign ?? TextAlign.start,
      text: TextSpan(style: style, children: spans),
    );
  }
}

List<TextSpan> _buildHighlightedSpans({
  required String text,
  required String query,
  TextStyle? normalStyle,
  required TextStyle highlighted,
}) {
  if (text.isEmpty) {
    return const [TextSpan(text: '')];
  }

  final expression = RegExp(RegExp.escape(query), caseSensitive: false);
  final matches = expression.allMatches(text).toList(growable: false);
  if (matches.isEmpty) {
    return [TextSpan(text: text, style: normalStyle)];
  }

  final spans = <TextSpan>[];
  var cursor = 0;
  for (final match in matches) {
    if (match.start > cursor) {
      spans.add(
        TextSpan(text: text.substring(cursor, match.start), style: normalStyle),
      );
    }
    spans.add(
      TextSpan(
        text: text.substring(match.start, match.end),
        style: highlighted,
      ),
    );
    cursor = match.end;
  }
  if (cursor < text.length) {
    spans.add(TextSpan(text: text.substring(cursor), style: normalStyle));
  }
  return spans;
}
