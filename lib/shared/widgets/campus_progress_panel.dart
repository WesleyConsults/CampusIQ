import 'package:flutter/material.dart';

import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';

class CampusProgressPanel extends StatelessWidget {
  final String message;
  final String? detail;
  final double? progress;

  const CampusProgressPanel({
    super.key,
    required this.message,
    this.detail,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Semantics(
          liveRegion: true,
          label: message,
          value: progress == null ? null : '${(progress! * 100).round()}%',
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: CampusCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  LinearProgressIndicator(
                    value: progress,
                    minHeight: AppSpacing.xs,
                    borderRadius: AppRadii.pill,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    message,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      detail!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
