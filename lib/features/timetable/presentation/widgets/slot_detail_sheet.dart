import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';

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

    return CampusModalSheet(
      title: slot.courseCode,
      subtitle: slot.courseName,
      leading: _SlotIcon(color: color),
      trailing: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(LucideIcons.x, size: AppIconSizes.xl),
        tooltip: 'Close',
      ),
      bottomBar: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                final navigator = Navigator.of(context);
                final router = GoRouter.of(context);
                navigator.pop();
                router.push('/course/${slot.courseCode}');
              },
              icon: const Icon(LucideIcons.arrowUpRight, size: AppIconSizes.md),
              label: const Text('Open Workspace'),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showCampusConfirmDialog(
                      context: context,
                      title: 'Delete timetable slot?',
                      message:
                          'Remove ${slot.courseCode} from your timetable? This will only delete this saved slot.',
                      confirmLabel: 'Delete',
                      destructive: true,
                    );
                    if (confirm != true || !context.mounted) return;
                    Navigator.of(context).pop();
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
                    Navigator.of(context).pop();
                    onEdit();
                  },
                  icon: const Icon(LucideIcons.pencilLine, size: AppIconSizes.md),
                  label: const Text('Edit'),
                ),
              ),
            ],
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              _MetaPill(
                label: slot.slotType,
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
              ),
              _MetaPill(
                label: TimetableConstants.dayFullLabels[slot.dayIndex],
                backgroundColor: AppColors.surfaceMuted,
                foregroundColor: AppTheme.textSecondary,
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
                const _DetailRow(
                  icon: LucideIcons.briefcase,
                  label:
                      'Open the workspace for notes, sessions, and planning tied to this course.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotIcon extends StatelessWidget {
  final Color color;

  const _SlotIcon({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: AppRadii.button,
      ),
      child: Icon(
        LucideIcons.bookOpen,
        color: color,
        size: AppIconSizes.xl,
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color foregroundColor;

  const _MetaPill({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppRadii.pill,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: foregroundColor,
          fontWeight: FontWeight.w700,
        ),
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
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
