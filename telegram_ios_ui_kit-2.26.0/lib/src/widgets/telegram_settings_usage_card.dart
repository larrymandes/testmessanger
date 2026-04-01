import 'package:flutter/cupertino.dart';

import '../models/telegram_settings_usage_segment.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramSettingsUsageCard extends StatelessWidget {
  const TelegramSettingsUsageCard({
    super.key,
    required this.totalLabel,
    required this.segments,
    this.title = 'Storage',
    this.onManageTap,
    this.manageLabel = 'Manage',
    this.emptyLabel = 'No storage usage data',
    this.margin = const EdgeInsets.fromLTRB(
      TelegramSpacing.l,
      0,
      TelegramSpacing.l,
      TelegramSpacing.m,
    ),
  });

  final String title;
  final String totalLabel;
  final List<TelegramSettingsUsageSegment> segments;
  final VoidCallback? onManageTap;
  final String manageLabel;
  final String emptyLabel;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;
    final resolvedSegments = _resolveSegments();

    return Padding(
      padding: margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.sectionBgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            TelegramSpacing.m,
            TelegramSpacing.m,
            TelegramSpacing.m,
            TelegramSpacing.m,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (onManageTap != null)
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(24, 20),
                      onPressed: onManageTap,
                      child: Text(
                        manageLabel,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.linkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: TelegramSpacing.xs),
              Text(
                totalLabel,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: colors.textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: TelegramSpacing.m),
              _UsageProgressRail(
                segments: resolvedSegments,
                trackColor: colors.secondaryBgColor,
              ),
              const SizedBox(height: TelegramSpacing.m),
              if (resolvedSegments.isEmpty)
                Text(
                  emptyLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.subtitleTextColor,
                  ),
                )
              else
                for (final segment in resolvedSegments) ...[
                  _UsageLegendRow(segment: segment),
                  if (segment != resolvedSegments.last)
                    const SizedBox(height: TelegramSpacing.s),
                ],
            ],
          ),
        ),
      ),
    );
  }

  List<_ResolvedUsageSegment> _resolveSegments() {
    if (segments.isEmpty) {
      return const [];
    }

    const fallbackColors = [
      Color(0xFF007AFF),
      Color(0xFF34C759),
      Color(0xFFFF9500),
      Color(0xFFAF52DE),
      Color(0xFFFF3B30),
    ];

    final usableSegments = segments
        .where((segment) => segment.ratio > 0)
        .toList(growable: false);
    if (usableSegments.isEmpty) {
      return const [];
    }
    final ratioTotal = usableSegments.fold<double>(
      0,
      (total, segment) => total + segment.ratio,
    );

    return List<_ResolvedUsageSegment>.generate(usableSegments.length, (index) {
      final segment = usableSegments[index];
      final normalizedRatio = ratioTotal <= 0
          ? 0.0
          : segment.ratio / ratioTotal;
      return _ResolvedUsageSegment(
        label: segment.label,
        valueLabel: segment.valueLabel,
        ratio: normalizedRatio,
        color: segment.color ?? fallbackColors[index % fallbackColors.length],
      );
    });
  }
}

class _UsageProgressRail extends StatelessWidget {
  const _UsageProgressRail({required this.segments, required this.trackColor});

  final List<_ResolvedUsageSegment> segments;
  final Color trackColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 10,
        child: ColoredBox(
          color: trackColor,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (segments.isEmpty || constraints.maxWidth <= 0) {
                return const SizedBox.expand();
              }
              final maxWidth = constraints.maxWidth;

              return Row(
                children: [
                  for (final segment in segments)
                    SizedBox(
                      width: maxWidth * segment.ratio,
                      child: ColoredBox(color: segment.color),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _UsageLegendRow extends StatelessWidget {
  const _UsageLegendRow({required this.segment});

  final _ResolvedUsageSegment segment;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final colors = theme.colors;

    return Row(
      children: [
        Container(
          height: 8,
          width: 8,
          decoration: BoxDecoration(
            color: segment.color,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        const SizedBox(width: TelegramSpacing.s),
        Expanded(
          child: Text(
            segment.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.textColor,
            ),
          ),
        ),
        Text(
          segment.valueLabel,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colors.subtitleTextColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

@immutable
class _ResolvedUsageSegment {
  const _ResolvedUsageSegment({
    required this.label,
    required this.valueLabel,
    required this.ratio,
    required this.color,
  });

  final String label;
  final String valueLabel;
  final double ratio;
  final Color color;
}
