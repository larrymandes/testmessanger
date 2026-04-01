import 'package:flutter/cupertino.dart';

import '../theme/telegram_spacing.dart';
import '../theme/telegram_theme.dart';

class TelegramVoiceMessageTile extends StatelessWidget {
  const TelegramVoiceMessageTile({
    super.key,
    required this.durationLabel,
    required this.timeLabel,
    this.progress = 0,
    this.isPlaying = false,
    this.isOutgoing = false,
    this.waveform = const [2, 4, 6, 5, 4, 7, 5, 3, 6, 4, 3, 5, 7, 4],
    this.onPlayToggle,
  });

  final String durationLabel;
  final String timeLabel;
  final double progress;
  final bool isPlaying;
  final bool isOutgoing;
  final List<int> waveform;
  final VoidCallback? onPlayToggle;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    final bubbleColor = isOutgoing
        ? theme.colors.outgoingBubbleColor
        : theme.colors.incomingBubbleColor;
    final normalizedProgress = progress.clamp(0.0, 1.0);
    final activeBars = (normalizedProgress * waveform.length).round();

    return Align(
      alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 286),
        child: Container(
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(theme.messageBubbleRadius.x),
          ),
          padding: const EdgeInsets.fromLTRB(
            TelegramSpacing.s,
            TelegramSpacing.s,
            TelegramSpacing.m,
            TelegramSpacing.s,
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CupertinoButton(
                    minimumSize: const Size.square(34),
                    padding: EdgeInsets.zero,
                    onPressed: onPlayToggle,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: theme.colors.linkColor.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isPlaying
                            ? CupertinoIcons.pause_solid
                            : CupertinoIcons.play_fill,
                        size: 15,
                        color: theme.colors.linkColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: TelegramSpacing.s),
                  Expanded(
                    child: SizedBox(
                      height: 26,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          for (var index = 0; index < waveform.length; index++)
                            _WaveBar(
                              height: waveform[index].toDouble() + 6,
                              active: index < activeBars,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TelegramSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    durationLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                  Text(
                    timeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colors.subtitleTextColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaveBar extends StatelessWidget {
  const _WaveBar({required this.height, required this.active});

  final double height;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = context.telegramTheme;
    return Container(
      width: 3,
      height: height,
      decoration: BoxDecoration(
        color: active ? theme.colors.linkColor : theme.colors.separatorColor,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}
