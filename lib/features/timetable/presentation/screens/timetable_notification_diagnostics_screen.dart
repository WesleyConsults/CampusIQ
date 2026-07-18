import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/timetable/data/models/scheduled_timetable_notification_model.dart';
import 'package:campusiq/features/timetable/data/models/course_reminder_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/data/repositories/course_reminder_repository.dart';
import 'package:campusiq/features/timetable/data/repositories/scheduled_timetable_notification_repository.dart';
import 'package:campusiq/features/timetable/data/repositories/timetable_repository.dart';
import 'package:campusiq/features/timetable/domain/course_code_normalizer.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/domain/timetable_notification_coordinator.dart';

class TimetableNotificationDiagnosticsScreen extends ConsumerStatefulWidget {
  const TimetableNotificationDiagnosticsScreen({super.key});

  @override
  ConsumerState<TimetableNotificationDiagnosticsScreen> createState() =>
      _TimetableNotificationDiagnosticsScreenState();
}

class _TimetableNotificationDiagnosticsScreenState
    extends ConsumerState<TimetableNotificationDiagnosticsScreen> {
  late Future<_DiagnosticsSnapshot> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<_DiagnosticsSnapshot> _load() async {
    final isar = await ref.read(isarProvider.future);
    return _DiagnosticsSnapshot.load(isar);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _syncNow() async {
    final isar = await ref.read(isarProvider.future);
    final result = await TimetableNotificationCoordinator(isar: isar).reconcile(
      reason: 'diagnostics_sync_now',
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.summary)),
    );
    _reload();
  }

  Future<void> _sendTest() async {
    await NotificationService.instance.showTimetableTestReminder();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Test reminder sent.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Timetable Alert Reliability')),
      body: FutureBuilder<_DiagnosticsSnapshot>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              _Section(
                title: 'Status',
                rows: [
                  _InfoRow('Notification permission', data.permissionStatus),
                  _InfoRow('Exact alarm access', data.exactAlarmStatus),
                  _InfoRow('Reminder channel', data.reminderChannelStatus),
                  _InfoRow('Alarm channel', data.alarmChannelStatus),
                  _InfoRow('Active semester', data.activeSemester),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              _Section(
                title: 'Timetable Sync',
                rows: [
                  _InfoRow('Timetable slots', '${data.slotCount}'),
                  _InfoRow('Enabled reminders', '${data.enabledReminderCount}'),
                  _InfoRow('Desired alerts', '${data.desiredCount}'),
                  _InfoRow('Registered alerts', '${data.registeredCount}'),
                  _InfoRow('Pending alerts', '${data.pendingCount}'),
                  _InfoRow('Next reminder', data.nextReminder),
                  _InfoRow('Last sync', data.lastSync),
                  _InfoRow('Last result', data.lastResult),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (data.warnings.isNotEmpty)
                _MessageList(title: 'Warnings', messages: data.warnings),
              if (data.failures.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                _MessageList(title: 'Failures', messages: data.failures),
              ],
              const SizedBox(height: AppSpacing.md),
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  FilledButton.icon(
                    onPressed: _syncNow,
                    icon: const Icon(LucideIcons.refreshCcw),
                    label: const Text('Synchronize now'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _sendTest,
                    icon: const Icon(LucideIcons.bellRing),
                    label: const Text('Send test'),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        NotificationService.instance.openNotificationSettings,
                    icon: const Icon(LucideIcons.settings),
                    label: const Text('Notification settings'),
                  ),
                  OutlinedButton.icon(
                    onPressed:
                        NotificationService.instance.openExactAlarmSettings,
                    icon: const Icon(LucideIcons.alarmClock),
                    label: const Text('Exact alarms'),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              ExpansionTile(
                title: const Text('Scheduled timetable reminders'),
                children: [
                  if (data.scheduled.isEmpty)
                    const ListTile(
                        title: Text('No registered timetable alerts')),
                  for (final item in data.scheduled)
                    ListTile(
                      title: Text(item.title),
                      subtitle: Text(
                        '${item.semesterKey} · ${item.normalizedCourseCode} · ${TimetableConstants.dayLabels[item.scheduledWeekday - 1]} ${item.scheduledHour.toString().padLeft(2, '0')}:${item.scheduledMinute.toString().padLeft(2, '0')}',
                      ),
                      trailing: Text(item.isAlarm ? 'Alarm' : 'Reminder'),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DiagnosticsSnapshot {
  const _DiagnosticsSnapshot({
    required this.permissionStatus,
    required this.exactAlarmStatus,
    required this.reminderChannelStatus,
    required this.alarmChannelStatus,
    required this.activeSemester,
    required this.slotCount,
    required this.enabledReminderCount,
    required this.desiredCount,
    required this.registeredCount,
    required this.pendingCount,
    required this.nextReminder,
    required this.lastSync,
    required this.lastResult,
    required this.warnings,
    required this.failures,
    required this.scheduled,
  });

  final String permissionStatus;
  final String exactAlarmStatus;
  final String reminderChannelStatus;
  final String alarmChannelStatus;
  final String activeSemester;
  final int slotCount;
  final int enabledReminderCount;
  final int desiredCount;
  final int registeredCount;
  final int pendingCount;
  final String nextReminder;
  final String lastSync;
  final String lastResult;
  final List<String> warnings;
  final List<String> failures;
  final List<ScheduledTimetableNotificationModel> scheduled;

  static Future<_DiagnosticsSnapshot> load(Isar isar) async {
    final prefsRepo = UserPrefsRepository(isar);
    final timetableRepo = TimetableRepository(isar);
    final reminderRepo = CourseReminderRepository(isar);
    final registryRepo = ScheduledTimetableNotificationRepository(isar);
    final prefs = await prefsRepo.getPrefs();
    final activeSemester = await prefsRepo.getActiveSemesterKey();
    final slots = await timetableRepo.getAllSlotsOnce(activeSemester);
    final reminders = await reminderRepo.getReminders(activeSemester);
    final registry = await registryRepo.getAll();
    final pendingIds =
        (await NotificationService.instance.pendingNotifications())
            .map((request) => request.id)
            .toSet();
    final channelDiagnostics =
        await NotificationService.instance.timetableChannelDiagnostics();
    final enabled =
        await NotificationService.instance.areNotificationsEnabled();
    final exact = await NotificationService.instance.canScheduleExactAlarms();
    final desiredCount = _desiredCount(slots, reminders);
    final activeRegistry =
        registry.where((item) => item.semesterKey == activeSemester).toList()
          ..sort((a, b) {
            final day = a.scheduledWeekday.compareTo(b.scheduledWeekday);
            if (day != 0) return day;
            final hour = a.scheduledHour.compareTo(b.scheduledHour);
            if (hour != 0) return hour;
            return a.scheduledMinute.compareTo(b.scheduledMinute);
          });
    final pendingCount = activeRegistry
        .where((item) => pendingIds.contains(item.notificationId))
        .length;

    return _DiagnosticsSnapshot(
      permissionStatus: enabled ? 'Allowed' : 'Permission required',
      exactAlarmStatus: exact ? 'Available' : 'Access required',
      reminderChannelStatus: channelDiagnostics.reminderChannelStatus,
      alarmChannelStatus: channelDiagnostics.alarmChannelStatus,
      activeSemester: activeSemester,
      slotCount: slots.length,
      enabledReminderCount: reminders.where((r) => r.isEnabled).length,
      desiredCount: desiredCount,
      registeredCount: activeRegistry.length,
      pendingCount: pendingCount,
      nextReminder: activeRegistry.isEmpty
          ? 'None'
          : _formatRegistryReminder(activeRegistry.first),
      lastSync: _formatLastSync(prefs),
      lastResult: prefs.lastTimetableNotificationSyncSummary.isEmpty
          ? 'No sync recorded'
          : prefs.lastTimetableNotificationSyncSummary,
      warnings: pendingCount < activeRegistry.length
          ? ['Some registered timetable alerts are missing from the OS queue.']
          : const [],
      failures: const [],
      scheduled: activeRegistry,
    );
  }

  static int _desiredCount(
    List<TimetableSlotModel> slots,
    List<CourseReminderModel> reminders,
  ) {
    var count = 0;
    for (final reminder in reminders.where((r) => r.isEnabled)) {
      final code = normalizeCourseCode(reminder.courseCode);
      count += slots
          .where((slot) =>
              normalizeCourseCode(slot.courseCode) == code &&
              slot.endMinutes > slot.startMinutes)
          .length;
    }
    return count;
  }

  static String _formatRegistryReminder(
    ScheduledTimetableNotificationModel item,
  ) {
    final day = TimetableConstants.dayLabels[item.scheduledWeekday - 1];
    final time =
        '${item.scheduledHour.toString().padLeft(2, '0')}:${item.scheduledMinute.toString().padLeft(2, '0')}';
    return '$day $time · ${item.normalizedCourseCode}';
  }

  static String _formatLastSync(UserPrefsModel prefs) {
    final syncAt = prefs.lastTimetableNotificationSyncAt;
    if (syncAt == null) return 'Never';
    return syncAt.toLocal().toString();
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.rows});

  final String title;
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final row in rows) row,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.title, required this.messages});

  final String title;
  final List<String> messages;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final message in messages)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(message),
              ),
          ],
        ),
      ),
    );
  }
}
