import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/shared/widgets/campus_modal_action_row.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';

class AddSlotSheet extends ConsumerStatefulWidget {
  final int dayIndex;
  final String semesterKey;
  final int colorValue;
  final TimetableSlotModel? existing;

  /// If opened from a free block, pre-fill these times
  final int? prefillStartMinutes;
  final int? prefillEndMinutes;

  const AddSlotSheet({
    super.key,
    required this.dayIndex,
    required this.semesterKey,
    required this.colorValue,
    this.existing,
    this.prefillStartMinutes,
    this.prefillEndMinutes,
  });

  @override
  ConsumerState<AddSlotSheet> createState() => _AddSlotSheetState();
}

class _AddSlotSheetState extends ConsumerState<AddSlotSheet> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _venueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late int _startMinutes;
  late int _endMinutes;
  late String _slotType;
  late int _dayIndex;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _codeController.text = existing.courseCode;
      _nameController.text = existing.courseName;
      _venueController.text = existing.venue;
      _startMinutes = existing.startMinutes;
      _endMinutes = existing.endMinutes;
      _slotType = existing.slotType;
      _dayIndex = existing.dayIndex;
    } else {
      _startMinutes = widget.prefillStartMinutes ??
          TimetableConstants.gridStartMinutes + 120;
      _endMinutes = widget.prefillEndMinutes ?? _startMinutes + 120;
      _slotType = TimetableConstants.slotTypes.first;
      _dayIndex = widget.dayIndex;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  Future<void> _pickTime(bool isStart) async {
    final currentMinutes = isStart ? _startMinutes : _endMinutes;
    final initial =
        TimeOfDay(hour: currentMinutes ~/ 60, minute: currentMinutes % 60);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    int total = picked.hour * 60 + picked.minute;
    final openedInAm = currentMinutes < 12 * 60;
    if (total < TimetableConstants.gridStartMinutes && openedInAm) {
      total += 12 * 60;
    }

    setState(() {
      if (isStart) {
        _startMinutes = total;
        if (_endMinutes <= _startMinutes) _endMinutes = _startMinutes + 60;
      } else {
        _endMinutes = total;
        if (_endMinutes <= _startMinutes) _endMinutes = _startMinutes + 60;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_endMinutes <= _startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final slot = widget.existing ?? TimetableSlotModel();
    slot.courseCode = _codeController.text.trim().toUpperCase();
    slot.courseName = _nameController.text.trim();
    slot.venue = _venueController.text.trim();
    slot.startMinutes = _startMinutes;
    slot.endMinutes = _endMinutes;
    slot.slotType = _slotType;
    slot.dayIndex = _dayIndex;
    slot.semesterKey = widget.semesterKey;
    slot.colorValue = widget.colorValue;

    Navigator.of(context).pop(slot);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existing != null;
    final isPrefilled =
        !isEditing &&
        widget.prefillStartMinutes != null &&
        widget.prefillEndMinutes != null;

    return Form(
      key: _formKey,
      child: CampusModalSheet(
        title: isEditing ? 'Edit Class' : 'Add Class',
        subtitle: isPrefilled
            ? 'You opened a free block, so the time is already prefilled.'
            : 'Add the class details so your timetable stays calm and easy to scan.',
        leading: const _ModalIcon(),
        scrollable: true,
        maxHeightFactor: 0.94,
        bottomBar: CampusModalActionRow(
          primaryLabel: isEditing ? 'Save Changes' : 'Add Class',
          onPrimaryPressed: _submit,
          secondaryLabel: 'Cancel',
          onSecondaryPressed: () => Navigator.of(context).pop(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isPrefilled) ...[
              _PrefillNotice(
                startLabel: TimetableConstants.minutesToLabel(_startMinutes),
                endLabel: TimetableConstants.minutesToLabel(_endMinutes),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
            ref.watch(coursesProvider).when(
                  data: (courses) {
                    if (courses.isEmpty) return const SizedBox.shrink();

                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: AppRadii.button,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick fill from your CWA courses',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            'Tap a course to prefill the code and title.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.xs,
                            runSpacing: AppSpacing.xs,
                            children: courses.map((course) {
                              return ActionChip(
                                label: Text(course.code),
                                avatar: const Icon(
                                  LucideIcons.bookOpen,
                                  size: AppIconSizes.sm,
                                  color: AppTheme.primary,
                                ),
                                backgroundColor: AppColors.surface,
                                side: const BorderSide(color: AppColors.border),
                                labelStyle: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(color: AppTheme.primary),
                                onPressed: () {
                                  setState(() {
                                    _codeController.text = course.code;
                                    _nameController.text = course.name;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<int>(
              key: ValueKey(_dayIndex),
              initialValue: _dayIndex,
              decoration: const InputDecoration(labelText: 'Day'),
              items: List.generate(
                TimetableConstants.dayFullLabels.length,
                (i) => DropdownMenuItem(
                  value: i,
                  child: Text(TimetableConstants.dayFullLabels[i]),
                ),
              ),
              onChanged: (v) => setState(() => _dayIndex = v!),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Course code',
                hintText: 'COE 456',
              ),
              textCapitalization: TextCapitalization.characters,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Course name',
                hintText: 'Signals and Systems',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sm),
            TextFormField(
              controller: _venueController,
              decoration: const InputDecoration(
                labelText: 'Venue',
                hintText: 'Hall 3',
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Time',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Pick the start and end time for this class block.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _TimeTile(
                    label: 'Start time',
                    value: TimetableConstants.minutesToLabel(_startMinutes),
                    icon: LucideIcons.clock3,
                    onTap: () => _pickTime(true),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _TimeTile(
                    label: 'End time',
                    value: TimetableConstants.minutesToLabel(_endMinutes),
                    icon: LucideIcons.clock4,
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            _DurationBadge(minutes: _endMinutes - _startMinutes),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              key: ValueKey(_slotType),
              initialValue: _slotType,
              decoration: const InputDecoration(labelText: 'Type'),
              items: TimetableConstants.slotTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) => setState(() => _slotType = v!),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.button,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadii.button,
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: AppIconSizes.md,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(value, style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModalIcon extends StatelessWidget {
  const _ModalIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: AppRadii.button,
      ),
      child: const Icon(
        LucideIcons.calendarPlus2,
        color: AppTheme.primary,
        size: AppIconSizes.xl,
      ),
    );
  }
}

class _PrefillNotice extends StatelessWidget {
  final String startLabel;
  final String endLabel;

  const _PrefillNotice({
    required this.startLabel,
    required this.endLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.goldSoft,
        borderRadius: AppRadii.button,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            LucideIcons.sparkles,
            size: AppIconSizes.md,
            color: AppTheme.primary,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Free block detected from $startLabel to $endLabel. We kept that timing ready for you.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.primary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationBadge extends StatelessWidget {
  final int minutes;

  const _DurationBadge({required this.minutes});

  @override
  Widget build(BuildContext context) {
    final hours = minutes / 60;
    final hasFraction = minutes % 60 != 0;
    final label = hasFraction
        ? '${hours.toStringAsFixed(1)} hr session'
        : '${hours.toStringAsFixed(0)} hr session';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.pill,
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.primary,
            ),
      ),
    );
  }
}
