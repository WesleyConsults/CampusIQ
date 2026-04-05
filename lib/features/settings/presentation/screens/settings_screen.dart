import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/settings/presentation/providers/settings_provider.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Notification Settings',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (prefs) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Notification toggles ────────────────────────────────────
            Card(
              child: Column(
                children: [
                  _NotifTile(
                    title: 'Study reminders',
                    subtitle: 'Free block and daily study alerts',
                    value: prefs.notifyStudyReminders,
                    onChanged: (v) async {
                      final repo = ref.read(userPrefsRepositoryProvider);
                      await repo?.setNotifyStudyReminders(v);
                      if (!v) {
                        for (int i = 100; i < 200; i++) {
                          await NotificationService.instance
                              .cancelNotification(i);
                        }
                        await NotificationService.instance
                            .cancelNotification(201);
                      }
                      ref.invalidate(notificationPrefsProvider);
                    },
                  ),
                  const Divider(height: 1),
                  _NotifTile(
                    title: 'Streak alerts',
                    subtitle: 'Notified when your streak is at risk',
                    value: prefs.notifyStreakAlerts,
                    onChanged: (v) async {
                      final repo = ref.read(userPrefsRepositoryProvider);
                      await repo?.setNotifyStreakAlerts(v);
                      if (!v) {
                        await NotificationService.instance
                            .cancelNotification(200);
                      }
                      ref.invalidate(notificationPrefsProvider);
                    },
                  ),
                  const Divider(height: 1),
                  _NotifTile(
                    title: 'Milestone alerts',
                    subtitle: 'Notified when a streak milestone is near',
                    value: prefs.notifyMilestoneAlerts,
                    onChanged: (v) async {
                      final repo = ref.read(userPrefsRepositoryProvider);
                      await repo?.setNotifyMilestoneAlerts(v);
                      if (!v) {
                        await NotificationService.instance
                            .cancelNotification(300);
                      }
                      ref.invalidate(notificationPrefsProvider);
                    },
                  ),
                  const Divider(height: 1),
                  _NotifTile(
                    title: 'Weekly review prompt',
                    subtitle: 'Monday morning summary reminder',
                    value: prefs.notifyWeeklyReview,
                    onChanged: (v) async {
                      final repo = ref.read(userPrefsRepositoryProvider);
                      await repo?.setNotifyWeeklyReview(v);
                      if (!v) {
                        await NotificationService.instance
                            .cancelNotification(400);
                      }
                      ref.invalidate(notificationPrefsProvider);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Daily reminder time ──────────────────────────────────────
            Card(
              child: ListTile(
                title: const Text('Daily study reminder time',
                    style: TextStyle(fontWeight: FontWeight.w500)),
                subtitle: Text(
                  _formatTime(prefs.dailyReminderHour,
                      prefs.dailyReminderMinute),
                  style: const TextStyle(color: AppTheme.textSecondary),
                ),
                trailing: const Icon(Icons.access_time_rounded,
                    color: AppTheme.textSecondary),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay(
                      hour: prefs.dailyReminderHour,
                      minute: prefs.dailyReminderMinute,
                    ),
                  );
                  if (picked == null) return;
                  final repo = ref.read(userPrefsRepositoryProvider);
                  await repo?.setDailyReminderTime(
                      picked.hour, picked.minute);
                  ref.invalidate(notificationPrefsProvider);
                },
              ),
            ),

            const SizedBox(height: 32),

            // ── Cancel all button ────────────────────────────────────────
            OutlinedButton.icon(
              onPressed: () async {
                await NotificationService.instance.cancelAllReminders();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('All notifications cancelled')),
                  );
                }
              },
              icon: const Icon(Icons.notifications_off_outlined),
              label: const Text('Cancel all scheduled notifications'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int hour, int minute) {
    final suffix = hour < 12 ? 'AM' : 'PM';
    final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '${h.toString()}:${minute.toString().padLeft(2, '0')} $suffix';
  }
}

class _NotifTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 12, color: AppTheme.textSecondary)),
      value: value,
      onChanged: onChanged,
    );
  }
}
