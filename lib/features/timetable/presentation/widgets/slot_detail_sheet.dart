import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// Shows full details of a slot. Options: edit or delete.
class SlotDetailSheet extends StatelessWidget {
  final TimetableSlotModel slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SlotDetailSheet({
    super.key,
    required this.slot,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(slot.colorValue);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        MediaQuery.paddingOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  borderRadius: AppRadii.button,
                ),
                child: Icon(
                  LucideIcons.bookOpen,
                  color: color,
                  size: AppIconSizes.xl,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.courseCode,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      slot.courseName,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: AppRadii.pill,
                ),
                child: Text(
                  slot.slotType,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.button,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _DetailRow(
                  icon: LucideIcons.clock3,
                  label: '${slot.startTimeLabel} - ${slot.endTimeLabel}',
                ),
                if (slot.venue.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _DetailRow(
                    icon: LucideIcons.mapPin,
                    label: slot.venue,
                  ),
                ],
                const SizedBox(height: AppSpacing.sm),
                _DetailRow(
                  icon: LucideIcons.calendarDays,
                  label: TimetableConstants.dayFullLabels[slot.dayIndex],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const _DetailRow(
            icon: LucideIcons.briefcase,
            label:
                'Open this course workspace for notes, sessions, and planning.',
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                context.push('/course/${slot.courseCode}');
              },
              icon: const Icon(LucideIcons.arrowUpRight, size: AppIconSizes.md),
              label: const Text('Open Workspace'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                  icon: const Icon(LucideIcons.trash2, size: AppIconSizes.md),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.warning,
                    side: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                  icon: const Icon(LucideIcons.pencilLine, size: AppIconSizes.md),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppIconSizes.md, color: AppTheme.textSecondary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
