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
  final bool compact;
  final bool centerHero;
  final bool showInsight;

  const CwaSummaryBar({
    super.key,
    required this.projected,
    required this.target,
    required this.gap,
    this.label = 'Projected CWA',
    this.eyebrow,
    this.hasData = true,
    this.emptyStateMessage,
    this.compact = false,
    this.centerHero = false,
    this.showInsight = true,
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
    final insight = _buildInsight(isOnTrack);
    final horizontalPadding = compact ? AppSpacing.sm2 : AppSpacing.md;
    final topPadding = compact ? AppSpacing.sm2 : AppSpacing.md;
    final bottomPadding = compact ? AppSpacing.sm2 : AppSpacing.sm;
    final heroSpacing = compact ? AppSpacing.xxs : AppSpacing.sm;
    final shouldCenterContent = compact && !showInsight;

    return Container(
      padding: EdgeInsets.fromLTRB(
        horizontalPadding,
        topPadding,
        horizontalPadding,
        bottomPadding,
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
        mainAxisAlignment: shouldCenterContent
            ? MainAxisAlignment.center
            : MainAxisAlignment.start,
        crossAxisAlignment:
            centerHero ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (eyebrow != null) ...[
            Text(
              eyebrow!,
              textAlign: centerHero ? TextAlign.center : TextAlign.start,
              maxLines: compact ? 2 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
              style: TextStyle(
                color: AppColors.goldSoft,
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs2),
          ],
          Text(
            heroValue,
            textAlign: centerHero ? TextAlign.center : TextAlign.start,
            style: TextStyle(
              color: Colors.white,
              fontSize: compact ? 29 : 34,
              fontWeight: FontWeight.w800,
              height: 0.94,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            textAlign: centerHero ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: heroSpacing),
          Row(
            children: [
              Expanded(
                child: _DetailStat(
                  label: 'Target',
                  value: target.toCwaString(),
                  valueColor: AppTheme.accent,
                  compact: compact,
                  centered: centerHero,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _DetailStat(
                  label: 'Gap',
                  value: gapValue,
                  valueColor: gapColor,
                  compact: compact,
                  centered: centerHero,
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? AppSpacing.xs2 : AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(gapColor),
              minHeight: compact ? 4 : 5,
            ),
          ),
          if (showInsight && insight != null) ...[
            const SizedBox(height: AppSpacing.xxs2),
            Text(
              insight,
              textAlign: centerHero ? TextAlign.center : TextAlign.start,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                height: 1.3,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String? _buildInsight(bool isOnTrack) {
    if (!hasData) {
      return emptyStateMessage;
    }

    if (isOnTrack) {
      return switch (_insightVariant(4)) {
        0 => 'Your current projection is meeting your target.',
        1 => 'You are on track for your target CWA.',
        2 => 'Your projected CWA is holding above target.',
        _ => 'Your target is within reach from this projection.',
      };
    }

    final gapText = gap.toCwaString();
    return switch (_insightVariant(5)) {
      0 => 'You are $gapText points away from your target.',
      1 => 'Only $gapText points separate you from your target.',
      2 => 'Your current gap is $gapText points from target.',
      3 => 'You need $gapText more points to meet your target.',
      _ => 'Your target is $gapText points above this projection.',
    };
  }

  int _insightVariant(int count) {
    final seed = (projected * 10).round() +
        (target * 10).round() +
        (gap.abs() * 10).round();
    return seed.abs() % count;
  }
}

class _DetailStat extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool compact;
  final bool centered;

  const _DetailStat({
    required this.label,
    required this.value,
    required this.valueColor,
    this.compact = false,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(label,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style:
                TextStyle(color: Colors.white54, fontSize: compact ? 10 : 11)),
        const SizedBox(height: AppSpacing.xxxs),
        Text(value,
            textAlign: centered ? TextAlign.center : TextAlign.start,
            style: TextStyle(
                color: valueColor,
                fontSize: compact ? 14 : 15,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
