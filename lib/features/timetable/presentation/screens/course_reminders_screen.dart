import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/timetable/data/models/course_reminder_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/course_code_normalizer.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/providers/course_reminder_provider.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/shared/widgets/campus_button.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_section_header.dart';
import 'package:campusiq/shared/widgets/error_retry_widget.dart';
import 'package:campusiq/shared/widgets/campus_feedback.dart';

const _reminderOffsetOptions = [10, 15, 30, 60, 120];

class CourseRemindersScreen extends ConsumerWidget {
  const CourseRemindersScreen({super.key});

  Future<void> _openReminderSheet(
    BuildContext context,
    WidgetRef ref, {
    CourseReminderModel? existing,
  }) async {
    final slots = ref.read(allSlotsProvider).valueOrNull ?? [];
    final options = _courseOptionsFromSlots(slots);

    var result = await showModalBottomSheet<_ReminderDraft>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CourseReminderSheet(
        options: options,
        existing: existing,
      ),
    );

    if (result == null || !context.mounted) return;

    final repo = ref.read(courseReminderRepositoryProvider);
    if (repo == null) {
      _showMessage(context, 'Could not save reminder. Please try again.');
      return;
    }

    try {
      result = await _preparePermissionsForDraft(context, ref, result);
      if (result == null) return;
      final semester = ref.read(activeSemesterProvider);
      final existingForCourse = existing ??
          await repo.findByCourse(
            semesterKey: semester,
            courseCode: result.course.courseCode,
          );

      final reminder = existingForCourse ??
          CourseReminderModel.create(
            semesterKey: semester,
            courseCode: result.course.courseCode,
            courseName: result.course.courseName,
            offsetMinutes: result.offsetMinutes,
            isAlarm: result.isAlarm,
          );
      reminder.courseCode = result.course.courseCode;
      reminder.courseName = result.course.courseName;
      reminder.offsetMinutes = result.offsetMinutes;
      reminder.isAlarm = result.isAlarm;
      reminder.isEnabled = true;

      await repo.saveReminder(reminder);
      final syncResult = await refreshCourseReminderNotifications(
        ref,
        reason: 'reminder_saved',
      );

      if (context.mounted) {
        if (syncResult.hasPermissionFailure ||
            syncResult.hasExactAlarmFailure) {
          CampusFeedback.showWarning(
            context,
            message: syncResult.summary,
          );
        } else {
          CampusFeedback.showSuccess(
            context,
            message:
                '${result.course.courseCode} reminder scheduled ${result.offsetMinutes} minutes before class',
          );
        }
        if (syncResult.hasPermissionFailure) {
          await _showPermissionRequiredDialog(context);
        } else if (syncResult.hasExactAlarmFailure) {
          await _showExactAlarmRequiredDialog(context);
        }
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Could not save reminder. Please try again.');
      }
    }
  }

  Future<void> _openAllRemindersSheet(
    BuildContext context,
    WidgetRef ref,
    List<_CourseOption> options,
  ) async {
    final offsetMinutes = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AllCourseRemindersSheet(courseCount: options.length),
    );

    if (offsetMinutes == null || !context.mounted) return;

    final repo = ref.read(courseReminderRepositoryProvider);
    if (repo == null) {
      _showMessage(context, 'Could not save reminders. Please try again.');
      return;
    }

    try {
      final granted = await _requestNotificationPermission(ref);
      if (!granted && context.mounted) {
        _showMessage(context, 'Notification permission is required.');
      }
      final semester = ref.read(activeSemesterProvider);

      for (final option in options) {
        final existing = await repo.findByCourse(
          semesterKey: semester,
          courseCode: option.courseCode,
        );
        final reminder = existing ??
            CourseReminderModel.create(
              semesterKey: semester,
              courseCode: option.courseCode,
              courseName: option.courseName,
              offsetMinutes: offsetMinutes,
            );
        reminder.courseCode = option.courseCode;
        reminder.courseName = option.courseName;
        reminder.offsetMinutes = offsetMinutes;
        reminder.isEnabled = true;
        await repo.saveReminder(reminder);
      }

      final syncResult = await refreshCourseReminderNotifications(
        ref,
        reason: 'all_reminders_enabled',
      );

      if (context.mounted) {
        _showMessage(context, syncResult.summary);
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Could not save reminders. Please try again.');
      }
    }
  }

  Future<void> _toggleReminder(
    BuildContext context,
    WidgetRef ref,
    CourseReminderModel reminder,
    bool enabled,
  ) async {
    final repo = ref.read(courseReminderRepositoryProvider);
    if (repo == null) return;

    try {
      if (enabled) {
        final granted = await _requestNotificationPermission(ref);
        if (!granted && context.mounted) {
          _showMessage(context, 'Notification permission is required.');
        }
      }
      reminder.isEnabled = enabled;
      await repo.saveReminder(reminder);
      final result = await refreshCourseReminderNotifications(
        ref,
        reason: enabled ? 'reminder_enabled' : 'reminder_disabled',
      );
      if (context.mounted) _showMessage(context, result.summary);
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Could not update reminder. Please try again.');
      }
    }
  }

  Future<void> _deleteReminder(
    BuildContext context,
    WidgetRef ref,
    CourseReminderModel reminder,
  ) async {
    final repo = ref.read(courseReminderRepositoryProvider);
    if (repo == null) return;

    try {
      await repo.deleteReminder(reminder.id);
      await refreshCourseReminderNotifications(ref, reason: 'reminder_deleted');
      if (context.mounted) {
        _showMessage(context, 'Reminder removed.');
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'Could not remove reminder. Please try again.');
      }
    }
  }

  void _showMessage(BuildContext context, String message) {
    CampusFeedback.showInfo(context, message: message);
  }

  Future<bool> _requestNotificationPermission(WidgetRef ref) async {
    final granted = await NotificationService.instance.requestPermission();
    final repo = ref.read(userPrefsRepositoryProvider);
    await repo?.setNotificationPermissionAsked(true);
    return granted;
  }

  Future<_ReminderDraft?> _preparePermissionsForDraft(
    BuildContext context,
    WidgetRef ref,
    _ReminderDraft draft,
  ) async {
    final notificationsGranted = await _requestNotificationPermission(ref);
    if (!notificationsGranted) return draft;
    if (!draft.isAlarm) return draft;

    if (await NotificationService.instance.canScheduleExactAlarms()) {
      return draft;
    }
    if (!context.mounted) return null;
    return _showExactAlarmChoiceDialog(context, draft);
  }

  Future<_ReminderDraft?> _showExactAlarmChoiceDialog(
    BuildContext context,
    _ReminderDraft draft,
  ) {
    return showDialog<_ReminderDraft?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exact alarm access required'),
        content: const Text(
          'Alarm mode needs exact alarm access. You can enable it in system settings, use a standard reminder, or cancel.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_ReminderDraft(
              course: draft.course,
              offsetMinutes: draft.offsetMinutes,
              isAlarm: false,
            )),
            child: const Text('Use reminder'),
          ),
          FilledButton(
            onPressed: () async {
              await NotificationService.instance.openExactAlarmSettings();
              if (context.mounted) Navigator.of(context).pop(draft);
            },
            child: const Text('Enable'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPermissionRequiredDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification permission required'),
        content: const Text(
          'Your reminder preference was saved, but UniMate cannot schedule timetable alerts until notifications are allowed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () async {
              await NotificationService.instance.openNotificationSettings();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _showExactAlarmRequiredDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exact alarm access required'),
        content: const Text(
          'Alarm reminders were saved, but exact alarm access is disabled. Enable it or switch the course to a standard reminder.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () async {
              await NotificationService.instance.openExactAlarmSettings();
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(courseRemindersProvider);
    final slotsAsync = ref.watch(allSlotsProvider);
    final slots = slotsAsync.valueOrNull ?? [];
    final options = _courseOptionsFromSlots(slots);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Course Reminders'),
      ),
      body: SafeArea(
        top: false,
        child: remindersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: ErrorRetryWidget(
              message: 'We could not load your reminders right now.',
              onRetry: () => ref.invalidate(courseRemindersProvider),
            ),
          ),
          data: (reminders) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.md,
                AppSpacing.xl,
                AppSpacing.xxxl,
              ),
              children: [
                CampusSectionHeader(
                  title: 'Always-on class alerts',
                  subtitle:
                      'Pick a course once and UniMate will remind you before every matching timetable class.',
                  trailing: IconButton.filled(
                    tooltip: 'Add reminder',
                    icon: const Icon(LucideIcons.plus),
                    onPressed: options.isEmpty
                        ? null
                        : () => _openReminderSheet(context, ref),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (options.isEmpty)
                  const _EmptyReminderState(
                    title: 'No timetable courses yet',
                    message:
                        'Add classes to your table first, then set recurring reminders for them here.',
                    actionLabel: null,
                    onAction: null,
                  )
                else ...[
                  _TurnOnAllCard(
                    courseCount: options.length,
                    onTap: () => _openAllRemindersSheet(
                      context,
                      ref,
                      options,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  if (reminders.isEmpty)
                    _EmptyReminderState(
                      title: 'No reminders set',
                      message:
                          'Create your first course reminder and it will repeat every week for that course.',
                      actionLabel: 'Add Reminder',
                      onAction: () => _openReminderSheet(context, ref),
                    )
                  else ...[
                    Text(
                      'Active reminders',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    for (final reminder in reminders) ...[
                      _ReminderTile(
                        reminder: reminder,
                        slots: slots
                            .where((slot) =>
                                normalizeCourseCode(slot.courseCode) ==
                                normalizeCourseCode(reminder.courseCode))
                            .toList(),
                        onEdit: () => _openReminderSheet(
                          context,
                          ref,
                          existing: reminder,
                        ),
                        onToggle: (value) =>
                            _toggleReminder(context, ref, reminder, value),
                        onDelete: () => _deleteReminder(context, ref, reminder),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                  ],
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ReminderTile extends StatelessWidget {
  final CourseReminderModel reminder;
  final List<TimetableSlotModel> slots;
  final VoidCallback onEdit;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  const _ReminderTile({
    required this.reminder,
    required this.slots,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final schedule = _scheduleSummary(slots);

    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: reminder.isEnabled
                      ? colorScheme.secondaryContainer
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  reminder.isAlarm ? LucideIcons.alarmClock : LucideIcons.bell,
                  color: reminder.isEnabled
                      ? colorScheme.onSecondaryContainer
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.courseCode,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      reminder.courseName,
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Switch(
                value: reminder.isEnabled,
                onChanged: onToggle,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${reminder.offsetLabel} every class ${reminder.isAlarm ? "(Alarm)" : "(Notification)"}',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            schedule,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(LucideIcons.pencil, size: 18),
                label: const Text('Edit'),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Delete reminder',
                onPressed: onDelete,
                icon: const Icon(LucideIcons.trash2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TurnOnAllCard extends StatelessWidget {
  final int courseCount;
  final VoidCallback onTap;

  const _TurnOnAllCard({
    required this.courseCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Icon(
                  LucideIcons.bellRing,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Turn on all',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$courseCount timetable course${courseCount == 1 ? '' : 's'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onTap,
              icon: const Icon(LucideIcons.clock, size: 18),
              label: const Text(
                'Choose Time',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AllCourseRemindersSheet extends StatefulWidget {
  final int courseCount;

  const _AllCourseRemindersSheet({
    required this.courseCount,
  });

  @override
  State<_AllCourseRemindersSheet> createState() =>
      _AllCourseRemindersSheetState();
}

class _AllCourseRemindersSheetState extends State<_AllCourseRemindersSheet> {
  int _offsetMinutes = 30;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor ??
            colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Turn On All Reminders',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Choose one reminder time for every course currently on your timetable.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: Text(
                  '${widget.courseCount} course${widget.courseCount == 1 ? '' : 's'} will be turned on.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Remind me',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final minutes in _reminderOffsetOptions)
                    ChoiceChip(
                      label: Text(_offsetLabel(minutes)),
                      selected: _offsetMinutes == minutes,
                      onSelected: (_) =>
                          setState(() => _offsetMinutes = minutes),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: CampusButton(
                  onPressed: () => Navigator.of(context).pop(_offsetMinutes),
                  icon: const Icon(LucideIcons.bellRing),
                  child: const Text('Turn On All'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseReminderSheet extends StatefulWidget {
  final List<_CourseOption> options;
  final CourseReminderModel? existing;

  const _CourseReminderSheet({
    required this.options,
    this.existing,
  });

  @override
  State<_CourseReminderSheet> createState() => _CourseReminderSheetState();
}

class _CourseReminderSheetState extends State<_CourseReminderSheet> {
  late _CourseOption? _selectedCourse;
  late int _offsetMinutes;
  late bool _isAlarm;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _selectedCourse = existing == null
        ? (widget.options.isEmpty ? null : widget.options.first)
        : widget.options.firstWhere(
            (option) =>
                normalizeCourseCode(option.courseCode) ==
                normalizeCourseCode(existing.courseCode),
            orElse: () => _CourseOption(
              courseCode: existing.courseCode,
              courseName: existing.courseName,
              slotCount: 0,
              scheduleSummary: 'No matching class slots right now',
            ),
          );
    _offsetMinutes = existing?.offsetMinutes ?? 30;
    _isAlarm = existing?.isAlarm ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final editing = widget.existing != null;
    final dropdownOptions = _dropdownOptions;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: Theme.of(context).bottomSheetTheme.backgroundColor ??
            colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                editing ? 'Edit Reminder' : 'Add Reminder',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'UniMate will remind you before every scheduled class for this course.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppSpacing.lg),
              DropdownButtonFormField<_CourseOption>(
                isExpanded: true,
                initialValue: _selectedCourse,
                decoration: const InputDecoration(labelText: 'Course'),
                selectedItemBuilder: (context) => dropdownOptions
                    .map(
                      (option) => Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _courseOptionLabel(option),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                items: dropdownOptions
                    .map(
                      (option) => DropdownMenuItem(
                        value: option,
                        child: Text(
                          _courseOptionLabel(option),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: editing
                    ? null
                    : (value) => setState(() => _selectedCourse = value),
              ),
              if (_selectedCourse != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _selectedCourse!.scheduleSummary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Remind me',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  for (final minutes in _reminderOffsetOptions)
                    ChoiceChip(
                      label: Text(_offsetLabel(minutes)),
                      selected: _offsetMinutes == minutes,
                      onSelected: (_) =>
                          setState(() => _offsetMinutes = minutes),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Alarm Mode',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Use exact timing with alarm sound and vibration',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isAlarm,
                    onChanged: (value) => setState(() => _isAlarm = value),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: CampusButton(
                  onPressed: _selectedCourse == null
                      ? null
                      : () => Navigator.of(context).pop(
                            _ReminderDraft(
                              course: _selectedCourse!,
                              offsetMinutes: _offsetMinutes,
                              isAlarm: _isAlarm,
                            ),
                          ),
                  icon: const Icon(LucideIcons.bell),
                  child: Text(editing ? 'Save Reminder' : 'Add Reminder'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<_CourseOption> get _dropdownOptions {
    final selected = _selectedCourse;
    if (selected == null) return widget.options;

    final containsSelected = widget.options.any(
      (option) =>
          normalizeCourseCode(option.courseCode) ==
          normalizeCourseCode(selected.courseCode),
    );
    if (containsSelected) return widget.options;
    return [selected, ...widget.options];
  }
}

class _EmptyReminderState extends StatelessWidget {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _EmptyReminderState({
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CampusCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(LucideIcons.bellPlus, size: 32),
          const SizedBox(height: AppSpacing.md),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: AppSpacing.lg),
            CampusButton(
              onPressed: onAction,
              icon: const Icon(LucideIcons.plus),
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReminderDraft {
  final _CourseOption course;
  final int offsetMinutes;
  final bool isAlarm;

  const _ReminderDraft({
    required this.course,
    required this.offsetMinutes,
    required this.isAlarm,
  });
}

class _CourseOption {
  final String courseCode;
  final String courseName;
  final int slotCount;
  final String scheduleSummary;

  const _CourseOption({
    required this.courseCode,
    required this.courseName,
    required this.slotCount,
    required this.scheduleSummary,
  });
}

List<_CourseOption> _courseOptionsFromSlots(List<TimetableSlotModel> slots) {
  final grouped = <String, List<TimetableSlotModel>>{};
  for (final slot in slots) {
    final normalized = normalizeCourseCode(slot.courseCode);
    if (normalized.isEmpty) continue;
    grouped.putIfAbsent(normalized, () => []).add(slot);
  }

  final options = grouped.entries.map((entry) {
    final courseSlots = entry.value
      ..sort((a, b) {
        final day = a.dayIndex.compareTo(b.dayIndex);
        if (day != 0) return day;
        return a.startMinutes.compareTo(b.startMinutes);
      });
    final first = courseSlots.first;
    return _CourseOption(
      courseCode: first.courseCode,
      courseName: first.courseName,
      slotCount: courseSlots.length,
      scheduleSummary: _scheduleSummary(courseSlots),
    );
  }).toList()
    ..sort((a, b) => a.courseCode.compareTo(b.courseCode));

  return options;
}

String _scheduleSummary(List<TimetableSlotModel> slots) {
  if (slots.isEmpty) return 'No matching class slots right now';

  final sorted = [...slots]..sort((a, b) {
      final day = a.dayIndex.compareTo(b.dayIndex);
      if (day != 0) return day;
      return a.startMinutes.compareTo(b.startMinutes);
    });

  final parts = sorted.take(3).map((slot) {
    final day = TimetableConstants.dayLabels[slot.dayIndex];
    final start = TimetableConstants.minutesToLabel(slot.startMinutes);
    return '$day $start';
  }).join(', ');
  final extra = sorted.length > 3 ? ' +${sorted.length - 3} more' : '';
  return '$parts$extra';
}

String _offsetLabel(int minutes) {
  if (minutes == 60) return '1 hour';
  if (minutes == 120) return '2 hours';
  return '$minutes min';
}

String _courseOptionLabel(_CourseOption option) {
  return '${option.courseCode} · ${option.courseName}';
}
