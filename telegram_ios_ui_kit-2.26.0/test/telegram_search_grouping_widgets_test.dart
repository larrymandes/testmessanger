import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telegram_ios_ui_kit/telegram_ios_ui_kit.dart';

Widget _wrap(Widget child) {
  final theme = TelegramThemeData.light();
  return TelegramTheme(
    data: theme,
    child: MaterialApp(
      theme: theme.toThemeData(),
      home: Scaffold(body: child),
    ),
  );
}

Iterable<TextSpan> _flattenTextSpans(TextSpan span) sync* {
  yield span;
  final children = span.children;
  if (children == null) {
    return;
  }
  for (final child in children) {
    if (child is TextSpan) {
      yield* _flattenTextSpans(child);
    }
  }
}

void main() {
  testWidgets('TelegramHighlightedText applies highlight style', (
    tester,
  ) async {
    const highlightStyle = TextStyle(
      color: Colors.red,
      fontWeight: FontWeight.w900,
    );
    await tester.pumpWidget(
      _wrap(
        const TelegramHighlightedText(
          text: 'Search video moderation update',
          query: 'video',
          highlightStyle: highlightStyle,
        ),
      ),
    );

    final richText = tester.widget<RichText>(find.byType(RichText).first);
    final root = richText.text as TextSpan;
    final spans = _flattenTextSpans(root).toList(growable: false);
    final highlighted = spans.where(
      (span) =>
          span.text?.toLowerCase() == 'video' && span.style == highlightStyle,
    );
    expect(highlighted.length, 1);
  });

  testWidgets('TelegramSearchGroupHeader renders uppercase label and count', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSearchGroupHeader(
          label: 'Moderation',
          count: 3,
          icon: CupertinoIcons.shield_fill,
        ),
      ),
    );

    expect(find.text('MODERATION'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('TelegramStickySearchGroupHeader displays inside sliver', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        CustomScrollView(
          slivers: [
            const TelegramStickySearchGroupHeader(
              label: 'Media',
              count: 2,
              icon: CupertinoIcons.photo_fill_on_rectangle_fill,
            ),
            SliverList(
              delegate: SliverChildListDelegate.fixed(const [
                SizedBox(height: 40),
                SizedBox(height: 40),
              ]),
            ),
          ],
        ),
      ),
    );

    expect(find.text('MEDIA'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });

  testWidgets('TelegramSearchResultTile highlights query in snippet', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const TelegramSearchResultTile(
          result: TelegramSearchResult(
            id: 'search_1',
            title: 'Media Review',
            snippet: 'Two video previews and one photo were approved.',
            sectionLabel: '#media',
            timeLabel: '09:32',
            avatarFallback: 'MR',
          ),
          highlightQuery: 'video',
        ),
      ),
    );

    expect(find.text('09:32'), findsOneWidget);
    final richTexts = tester
        .widgetList<RichText>(find.byType(RichText))
        .toList();
    var foundHighlighted = false;
    for (final richText in richTexts) {
      final root = richText.text;
      if (root is! TextSpan) {
        continue;
      }
      for (final span in _flattenTextSpans(root)) {
        if (span.text?.toLowerCase() == 'video' &&
            span.style?.fontWeight == FontWeight.w700) {
          foundHighlighted = true;
          break;
        }
      }
      if (foundHighlighted) {
        break;
      }
    }
    expect(foundHighlighted, isTrue);
  });
}
