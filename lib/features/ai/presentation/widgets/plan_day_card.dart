import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/ai/data/models/study_plan_slot_model.dart';
import 'package:campusiq/features/ai/presentation/widgets/plan_slot_tile.dart';

class PlanDayCard extends StatelessWidget {
  final String day;
  final List<StudyPlanSlotModel> slots;

  const PlanDayCard({super.key, required this.day, required this.slots});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs2),
            if (slots.isEmpty)
              Text(
                'Rest day — no free blocks available',
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              )
            else
              ...slots.map((s) => PlanSlotTile(slot: s)),
          ],
        ),
      ),
    );
  }
}
