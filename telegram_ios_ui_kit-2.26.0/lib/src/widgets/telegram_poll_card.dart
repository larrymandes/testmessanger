import 'package:flutter/material.dart';

import '../models/telegram_poll_option.dart';
import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramPollCard extends StatelessWidget {
  const TelegramPollCard({
    super.key,
    required this.question,
    required this.options,
    this.totalVotersLabel,
    this.isOutgoing = false,
    this.showResults = true,
    this.onOptionTap,
  });

  final String question;
  final List<TelegramPollOption> options;
  final String? totalVotersLabel;
  final bool isOutgoing;
  final bool showResults;
  final ValueChanged<TelegramPollOption>? onOptionTap;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = context.telegramTheme;
    final bubbleColor = isOutgoing
        ? theme.colors.outgoingBubbleColor
        : theme.colors.incomingBubbleColor;
    final maxVotes = options.fold<int>(
      0,
      (previous, option) => option.votes > previous ? option.votes : previous,
    );
    final totalVotes = options.fold<int>(
      0,
      (previous, option) => previous + option.votes,
    );

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Container(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(theme.messageBubbleRadius.x),
          ),
          padding: const EdgeInsets.all(TelegramSpacing.m),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colors.textColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TelegramSpacing.m),
              for (var index = 0; index < options.length; index++) ...[
                _PollOptionTile(
                  option: options[index],
                  maxVotes: maxVotes,
                  showResult: showResults,
                  onTap: onOptionTap,
                ),
                if (index < options.length - 1)
                  const SizedBox(height: TelegramSpacing.s),
              ],
              const SizedBox(height: TelegramSpacing.s),
              Text(
                totalVotersLabel ?? '$totalVotes votes',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colors.subtitleTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PollOptionTile extends StatelessWidget {
  const _PollOptionTile({
    required this.option,
    required this.maxVotes,
    required this.showResult,
    this.onTap,
  });

  final TelegramPollOption option;
  final int maxVotes;
  final bool showResult;
  final ValueChanged<TelegramPollOption>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final ratio = maxVotes == 0 ? 0.0 : option.votes / maxVotes;
    final fillColor = option.selected
        ? theme.colors.linkColor.withValues(alpha: 0.22)
        : theme.colors.secondaryBgColor;
    final borderColor = option.selected
        ? theme.colors.linkColor.withValues(alpha: 0.55)
        : theme.colors.separatorColor;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap == null ? null : () => onTap!(option),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colors.secondaryBgColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: borderColor, width: 0.7),
        ),
        child: Stack(
          children: [
            if (showResult)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(
                      decoration: BoxDecoration(
                        color: fillColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: TelegramSpacing.s,
                vertical: TelegramSpacing.s,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colors.textColor,
                        fontWeight: option.selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: TelegramSpacing.s),
                  Text(
                    '${option.votes}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
