import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/shared/extensions/double_extensions.dart';

class CwaSummaryBar extends StatelessWidget {
  final double projected;
  final double target;
  final double gap;

  /// Label shown above the projected CWA value. Defaults to 'Projected CWA'.
  final String label;
  final String? eyebrow;
  final bool hasData;
  final String? emptyStateMessage;

  const CwaSummaryBar({
    super.key,
    required this.projected,
    required this.target,
    required this.gap,
    this.label = 'Projected CWA',
    this.eyebrow,
    this.hasData = true,
    this.emptyStateMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isOnTrack = gap <= 0;
    final progressTarget = target <= 0 ? 1.0 : target;
    final progressValue =
        hasData ? (projected / progressTarget).clamp(0.0, 1.0) : 0.0;
    final gapColor = isOnTrack ? AppTheme.success : AppTheme.accent;
    final heroValue = hasData ? projected.toCwaString() : '--';
    final gapValue = !hasData
        ? '--'
        : isOnTrack
            ? 'On track'
            : gap.toCwaString();
    final insight = !hasData
        ? (emptyStateMessage ?? 'Add your data to see how you are performing.')
        : isOnTrack
            ? 'Your current projection is meeting your target. Keep this rhythm steady.'
            : 'You are ${gap.toCwaString()} points away from your target. A small improvement can close the gap.';

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navySoft],
        ),
        borderRadius: AppRadii.card,
        boxShadow: AppShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!,
              style: const TextStyle(
                color: AppColors.goldSoft,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            heroValue,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 38,
              fontWeight: FontWeight.w800,
              height: 0.94,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _DetailStat(
                  label: 'Target',
                  value: target.toCwaString(),
                  valueColor: AppTheme.accent,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _DetailStat(
                  label: 'Gap',
                  value: gapValue,
                  valueColor: gapColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(gapColor),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            insight,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _DetailStat(
      {required this.label, required this.value, required this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: valueColor, fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
