import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campusiq/core/providers/connectivity_provider.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_import_provider.dart';
import 'package:campusiq/features/timetable/presentation/widgets/import_slot_review_tile.dart';
import 'package:campusiq/features/timetable/data/models/course_reminder_model.dart';
import 'package:campusiq/features/timetable/data/repositories/course_reminder_repository.dart';
import 'package:campusiq/features/timetable/domain/course_code_normalizer.dart';
import 'package:campusiq/features/timetable/domain/timetable_notification_coordinator.dart';
import 'package:campusiq/features/timetable/domain/timetable_slot_import.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/shared/widgets/campus_button.dart';
import 'package:campusiq/shared/widgets/import_option_grid.dart';

class TimetableImportScreen extends ConsumerStatefulWidget {
  final String? initialSource;
  const TimetableImportScreen({this.initialSource, super.key});

  @override
  ConsumerState<TimetableImportScreen> createState() =>
      _TimetableImportScreenState();
}

class _TimetableImportScreenState extends ConsumerState<TimetableImportScreen> {
  @override
  void dispose() {
    final step = ref.read(timetableImportNotifierProvider).step;
    if (step != ImportStep.idle && step != ImportStep.done) {
      AnalyticsService.instance.logImportAbandoned(
        importType: 'timetable',
        step: step.name,
      );
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final source = widget.initialSource == 'camera'
            ? ImageSource.camera
            : ImageSource.gallery;
        _pickIfOnline(source);
      });
    }
  }

  Future<void> _pickIfOnline(ImageSource source) async {
    final isOnline = await ref.read(isOnlineProvider.future);
    if (!mounted) return;
    if (!isOnline) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You're offline. Connect to use features."),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    await ref
        .read(timetableImportNotifierProvider.notifier)
        .pickAndParse(source);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(timetableImportNotifierProvider);
    final notifier = ref.read(timetableImportNotifierProvider.notifier);

    // Auto-navigate / show dialog when done
    ref.listen(timetableImportNotifierProvider, (_, next) {
      if (next.step == ImportStep.done) {
        _showPostImportAlertsDialog(
            context, ref, next.slots, next.selectedIndexes, notifier);
      }
    });

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Import Timetable',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        leading: BackButton(
          onPressed: () {
            notifier.reset();
            context.pop();
          },
        ),
        actions: [
          if (state.step == ImportStep.reviewing)
            TextButton(
              onPressed: state.selectedIndexes.isNotEmpty
                  ? () => notifier.confirmImport()
                  : null,
              child: Text(
                'Import (${state.selectedIndexes.length})',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: switch (state.step) {
        ImportStep.idle => _IdleBody(onPick: _pickIfOnline),
        ImportStep.picking =>
          const _LoadingBody(message: 'Opening your timetable image…'),
        ImportStep.parsing =>
          const _LoadingBody(message: 'Uploading and reading class times…'),
        ImportStep.reviewing => _ReviewBody(state: state, notifier: notifier),
        ImportStep.saving =>
          _ReviewBody(state: state, notifier: notifier, isSaving: true),
        ImportStep.done =>
          const _LoadingBody(message: 'Preparing timetable reminders…'),
        ImportStep.error => _ErrorBody(
            message: state.errorMessage ?? 'Something went wrong.',
            onRetry: notifier.reset,
          ),
      },
    );
  }
}

// ── Idle ──────────────────────────────────────────────────────────────────────

class _IdleBody extends StatelessWidget {
  final void Function(ImageSource) onPick;

  const _IdleBody({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: ImportOptionGrid(
        options: [
          ImportOptionGridItem(
            icon: Icons.camera_alt_outlined,
            label: 'Take Photo',
            onTap: () => onPick(ImageSource.camera),
          ),
          ImportOptionGridItem(
            icon: Icons.photo_library_outlined,
            label: 'Upload Image',
            onTap: () => onPick(ImageSource.gallery),
          ),
        ],
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingBody extends StatelessWidget {
  final String message;

  const _LoadingBody({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: TextStyle(
              fontSize: 15,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Review ────────────────────────────────────────────────────────────────────

class _ReviewBody extends StatelessWidget {
  final TimetableImportState state;
  final TimetableImportNotifier notifier;
  final bool isSaving;

  const _ReviewBody({
    required this.state,
    required this.notifier,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final allSelected = state.selectedIndexes.length == state.slots.length;
    final colorScheme = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Column(
          children: [
            // Select all / deselect all bar
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              color: colorScheme.surfaceContainerHighest,
              child: Row(
                children: [
                  Text(
                    '${state.slots.length} slot${state.slots.length == 1 ? '' : 's'} found',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed:
                        allSelected ? notifier.deselectAll : notifier.selectAll,
                    child: Text(
                      allSelected ? 'Deselect All' : 'Select All',
                      style: TextStyle(
                        fontSize: 13,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Slot list
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: state.slots.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (_, i) => ImportSlotReviewTile(
                  index: i,
                  slot: state.slots[i],
                  isSelected: state.selectedIndexes.contains(i),
                ),
              ),
            ),

            // Bottom confirm bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.xs,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: state.selectedIndexes.isNotEmpty
                        ? () => notifier.confirmImport()
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      disabledBackgroundColor:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
                    child: Text(
                      state.selectedIndexes.isEmpty
                          ? 'Select slots to import'
                          : 'Import ${state.selectedIndexes.length} Slot${state.selectedIndexes.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Saving overlay
        if (isSaving)
          Container(
            color: Colors.black.withValues(alpha: 0.35),
            child: const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: AppSpacing.md),
                      Text('Saving slots…'),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Error ─────────────────────────────────────────────────────────────────────

class _ErrorBody extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorBody({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: colorScheme.error),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Try a clear, uncropped screenshot showing the days, course names, and class times. Avoid shadows or overlapping pages.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _showPostImportAlertsDialog(
  BuildContext context,
  WidgetRef ref,
  List<TimetableSlotImport> slots,
  Set<int> selectedIndexes,
  TimetableImportNotifier notifier,
) async {
  final uniqueImportedCourses = <({String code, String name})>[];
  final seen = <String>{};
  for (final index in selectedIndexes) {
    if (index < slots.length) {
      final slot = slots[index];
      final code = slot.courseCode.trim().toUpperCase();
      final normalized = normalizeCourseCode(code);
      if (normalized.isNotEmpty && !seen.contains(normalized)) {
        seen.add(normalized);
        uniqueImportedCourses.add((code: code, name: slot.courseName));
      }
    }
  }

  if (uniqueImportedCourses.isEmpty) {
    notifier.reset();
    if (context.mounted) {
      context.go('/timetable');
    }
    return;
  }

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogCtx) => _PostImportAlertsDialog(
      uniqueCourses: uniqueImportedCourses,
      onSkip: () {
        notifier.reset();
        Navigator.of(dialogCtx).pop();
        context.go('/timetable');
      },
      onSave: (isAlarm, offsetMinutes) async {
        try {
          final notificationsGranted =
              await NotificationService.instance.requestPermission();
          if (isAlarm &&
              notificationsGranted &&
              !await NotificationService.instance.canScheduleExactAlarms()) {
            await NotificationService.instance.openExactAlarmSettings();
          }
          final isar = await ref.read(isarProvider.future);
          final semesterKey = ref.read(activeSemesterProvider);
          final reminderRepo = CourseReminderRepository(isar);

          for (final course in uniqueImportedCourses) {
            final existing = await reminderRepo.findByCourse(
              semesterKey: semesterKey,
              courseCode: course.code,
            );
            final reminder = existing ??
                CourseReminderModel.create(
                  semesterKey: semesterKey,
                  courseCode: course.code,
                  courseName: course.name,
                  offsetMinutes: offsetMinutes,
                );
            reminder.courseName = course.name;
            reminder.courseCode = course.code;
            reminder.offsetMinutes = offsetMinutes;
            reminder.isAlarm = isAlarm;
            reminder.isEnabled = true;
            await reminderRepo.saveReminder(reminder);
          }

          final result =
              await TimetableNotificationCoordinator(isar: isar).reconcile(
            reason: 'post_import_alerts',
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result.summary)),
            );
          }
        } catch (_) {
          // Fail silently — import succeeded
        } finally {
          notifier.reset();
          if (dialogCtx.mounted) {
            Navigator.of(dialogCtx).pop();
          }
          if (context.mounted) {
            context.go('/timetable');
          }
        }
      },
    ),
  );
}

class _PostImportAlertsDialog extends StatefulWidget {
  final List<({String code, String name})> uniqueCourses;
  final VoidCallback onSkip;
  final Future<void> Function(bool isAlarm, int offsetMinutes) onSave;

  const _PostImportAlertsDialog({
    required this.uniqueCourses,
    required this.onSkip,
    required this.onSave,
  });

  @override
  State<_PostImportAlertsDialog> createState() =>
      _PostImportAlertsDialogState();
}

class _PostImportAlertsDialogState extends State<_PostImportAlertsDialog> {
  bool _isAlarm = false;
  int _offsetMinutes = 30;
  bool _saving = false;

  final List<int> _reminderOffsetOptions = const [10, 15, 30, 60, 120];

  String _offsetLabel(int minutes) {
    if (minutes == 60) return '1 hour';
    if (minutes == 120) return '2 hours';
    return '$minutes min';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md)),
      backgroundColor: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle_outline,
                    color: colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'Timetable Saved!',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Set up weekly class alerts for the ${widget.uniqueCourses.length} course${widget.uniqueCourses.length == 1 ? '' : 's'} you imported:',
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Alarm Mode',
                    style: textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Switch.adaptive(
                  value: _isAlarm,
                  activeThumbColor: colorScheme.secondary,
                  activeTrackColor: colorScheme.secondaryContainer,
                  onChanged:
                      _saving ? null : (val) => setState(() => _isAlarm = val),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Alert offset time',
              style:
                  textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final minutes in _reminderOffsetOptions)
                  ChoiceChip(
                    label: Text(
                      _offsetLabel(minutes),
                      style: const TextStyle(fontSize: 12),
                    ),
                    selected: _offsetMinutes == minutes,
                    onSelected: _saving
                        ? null
                        : (_) => setState(() => _offsetMinutes = minutes),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.xxs,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _saving ? null : widget.onSkip,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 48),
                      padding:
                          const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.sm),
                      ),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Skip for now',
                        maxLines: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _saving
                      ? const SizedBox(
                          height: 48,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : CampusButton(
                          onPressed: () async {
                            setState(() => _saving = true);
                            await widget.onSave(_isAlarm, _offsetMinutes);
                          },
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Set Alerts',
                              maxLines: 1,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
