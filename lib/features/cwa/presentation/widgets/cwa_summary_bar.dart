import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/shared/extensions/double_extensions.dart';

class CwaSummaryBar extends StatelessWidget {
  final double projected;
  final double target;
  final double gap;

  /// Label shown above the projected CWA value. Defaults to 'Projected CWA'.
  final String label;

  const CwaSummaryBar({
    super.key,
    required this.projected,
    required this.target,
    required this.gap,
    this.label = 'Projected CWA',
  });

  @override
  Widget build(BuildContext context) {
    final isOnTrack = gap <= 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatBox(
                  label: label,
                  value: projected.toCwaString(),
                  valueColor: Colors.white),
              _StatBox(
                  label: 'Target CWA',
                  value: target.toCwaString(),
                  valueColor: AppTheme.accent),
              _StatBox(
                label: 'Gap',
                value: isOnTrack ? 'On track' : gap.toCwaString(),
                valueColor: isOnTrack ? AppTheme.success : AppTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: projected.clamp(0, 100) / 100,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOnTrack ? AppTheme.success : AppTheme.accent,
              ),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isOnTrack
                ? 'Great! Your projected CWA meets your target.'
                : 'You need to improve by ${gap.toCwaString()} points.',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _StatBox(
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
                color: valueColor, fontSize: 20, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
