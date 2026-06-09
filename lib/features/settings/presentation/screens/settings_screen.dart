import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/active_semester_picker.dart';
import 'package:campusiq/features/settings/presentation/providers/settings_provider.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

// ── Static URLs ────────────────────────────────────────────────────────────
const _privacyUrl = 'https://uni-mate-privacy-policy.vercel.app/privacy.html';
const _termsUrl = 'https://uni-mate-privacy-policy.vercel.app/terms.html';
const _feedbackEmail = 'wesleyconsults@gmail.com';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(notificationPrefsProvider);
    final activeSemesterKey = ref.watch(activeSemesterProvider);
    final gradingSystem = ref.watch(gradingSystemProvider);
    final layoutIndex = ref.watch(timetableGridLayoutProvider).valueOrNull ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (prefs) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            // ── Academic ───────────────────────────────────────────────────
            const _SectionLabel(title: 'Academic'),
            const SizedBox(height: AppSpacing.xs),
            _Card(children: [
              _RowTile(
                leading: LucideIcons.calendarDays,
                title: 'Active semester',
                subtitle: formatActiveSemesterLabel(activeSemesterKey),
                onTap: () => showActiveSemesterDialog(
                  context,
                  ref,
                  activeSemesterKey,
                ),
              ),
              const Divider(height: 1),
              _RowTile(
                leading: LucideIcons.graduationCap,
                title: 'Grading system',
                subtitle:
                    '${gradingSystem.plannerTitle} · ${gradingSystem.minScore.toStringAsFixed(0)}-${gradingSystem.maxScore.toStringAsFixed(0)}${gradingSystem.scoreUnit == '%' ? '%' : ' pts'}',
                onTap: () => _showGradingSystemPicker(
                  context,
                  ref,
                  gradingSystem.id,
                ),
              ),
            ]),

            const SizedBox(height: AppSpacing.lg),

            // ── Timer Feedback ─────────────────────────────────────────────
            const _SectionLabel(title: 'Timer Feedback'),
            const SizedBox(height: AppSpacing.xs),
            _Card(children: [
              _SwitchTile(
                title: 'Vibrate on phase end',
                subtitle: 'Phone vibrates when a focus or break phase finishes',
                value: prefs.vibrateOnTimerEnd,
                onChanged: (v) async {
                  final repo = ref.read(userPrefsRepositoryProvider);
                  await repo?.setVibrateOnTimerEnd(v);
                  ref.invalidate(notificationPrefsProvider);
                },
              ),
              const Divider(height: 1),
              _SwitchTile(
                title: 'Sound on phase end',
                subtitle: 'Notification sound when a timer phase finishes',
                value: prefs.playSoundOnTimerEnd,
                onChanged: (v) async {
                  final repo = ref.read(userPrefsRepositoryProvider);
                  await repo?.setPlaySoundOnTimerEnd(v);
                  ref.invalidate(notificationPrefsProvider);
                },
              ),
            ]),

            const SizedBox(height: AppSpacing.lg),

            // ── Notifications ──────────────────────────────────────────────
            const _SectionLabel(title: 'Notifications'),
            const SizedBox(height: AppSpacing.xs),
            _Card(children: [
              _SwitchTile(
                title: 'Study reminders',
                subtitle: 'Free block and daily study alerts',
                value: prefs.notifyStudyReminders,
                onChanged: (v) async {
                  final repo = ref.read(userPrefsRepositoryProvider);
                  await repo?.setNotifyStudyReminders(v);
                  await AnalyticsService.instance.setCoreUserProperties(
                    notificationsEnabled: v ||
                        prefs.notifyStreakAlerts ||
                        prefs.notifyMilestoneAlerts ||
                        prefs.notifyWeeklyReview,
                  );
                  if (!v) {
                    for (int i = 100; i < 200; i++) {
                      await NotificationService.instance.cancelNotification(i);
                    }
                    await NotificationService.instance.cancelNotification(201);
                  }
                  ref.invalidate(notificationPrefsProvider);
                },
              ),
              const Divider(height: 1),
              _SwitchTile(
                title: 'Streak alerts',
                subtitle: 'Notified when your streak is at risk',
                value: prefs.notifyStreakAlerts,
                onChanged: (v) async {
                  final repo = ref.read(userPrefsRepositoryProvider);
                  await repo?.setNotifyStreakAlerts(v);
                  await AnalyticsService.instance.setCoreUserProperties(
                    notificationsEnabled: prefs.notifyStudyReminders ||
                        v ||
                        prefs.notifyMilestoneAlerts ||
                        prefs.notifyWeeklyReview,
                  );
                  if (!v) {
                    await NotificationService.instance.cancelNotification(200);
                  }
                  ref.invalidate(notificationPrefsProvider);
                },
              ),
              const Divider(height: 1),
              _SwitchTile(
                title: 'Milestone alerts',
                subtitle: 'Notified when a streak milestone is near',
                value: prefs.notifyMilestoneAlerts,
                onChanged: (v) async {
                  final repo = ref.read(userPrefsRepositoryProvider);
                  await repo?.setNotifyMilestoneAlerts(v);
                  await AnalyticsService.instance.setCoreUserProperties(
                    notificationsEnabled: prefs.notifyStudyReminders ||
                        prefs.notifyStreakAlerts ||
                        v ||
                        prefs.notifyWeeklyReview,
                  );
                  if (!v) {
                    await NotificationService.instance.cancelNotification(300);
                  }
                  ref.invalidate(notificationPrefsProvider);
                },
              ),
              const Divider(height: 1),
              _SwitchTile(
                title: 'Weekly review prompt',
                subtitle: 'Monday morning summary reminder',
                value: prefs.notifyWeeklyReview,
                onChanged: (v) async {
                  final repo = ref.read(userPrefsRepositoryProvider);
                  await repo?.setNotifyWeeklyReview(v);
                  await AnalyticsService.instance.setCoreUserProperties(
                    notificationsEnabled: prefs.notifyStudyReminders ||
                        prefs.notifyStreakAlerts ||
                        prefs.notifyMilestoneAlerts ||
                        v,
                  );
                  if (!v) {
                    await NotificationService.instance.cancelNotification(400);
                  }
                  ref.invalidate(notificationPrefsProvider);
                },
              ),
            ]),

            const SizedBox(height: AppSpacing.md),

            _Card(children: [
              _RowTile(
                leading: LucideIcons.clock,
                title: 'Daily study reminder time',
                subtitle: _formatTime(
                    prefs.dailyReminderHour, prefs.dailyReminderMinute),
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
                  await repo?.setDailyReminderTime(picked.hour, picked.minute);
                  ref.invalidate(notificationPrefsProvider);
                },
              ),
            ]),

            const SizedBox(height: AppSpacing.sm),

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
              icon: const Icon(LucideIcons.bellOff),
              label: const Text('Cancel all scheduled notifications'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Appearance ─────────────────────────────────────────────────
            const _SectionLabel(title: 'Appearance'),
            const SizedBox(height: AppSpacing.xs),
            _Card(children: [
              _RowTile(
                leading: LucideIcons.sunMoon,
                title: 'Theme',
                subtitle: _themeLabel(prefs.themeModeIndex),
                onTap: () =>
                    _showThemePicker(context, ref, prefs.themeModeIndex),
              ),
              const Divider(height: 1),
              _RowTile(
                leading: LucideIcons.calendarDays,
                title: 'Timetable grid layout',
                subtitle: _layoutLabel(layoutIndex),
                onTap: () =>
                    _showLayoutPicker(context, ref, layoutIndex),
              ),
            ]),

            const SizedBox(height: AppSpacing.lg),

            // ── About ──────────────────────────────────────────────────────
            const _SectionLabel(title: 'About'),
            const SizedBox(height: AppSpacing.xs),
            _Card(children: [
              _RowTile(
                leading: LucideIcons.info,
                title: 'About UniMate',
                subtitle: 'App info, version, and licenses',
                onTap: () => showAboutDialog(
                  context: context,
                  applicationName: 'UniMate',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(
                    LucideIcons.graduationCap,
                    size: 48,
                  ),
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
              const Divider(height: 1),
              _RowTile(
                leading: LucideIcons.shield,
                title: 'Privacy policy',
                onTap: () => _launchUrl(context, _privacyUrl),
              ),
              const Divider(height: 1),
              _RowTile(
                leading: LucideIcons.fileText,
                title: 'Terms of service',
                onTap: () => _launchUrl(context, _termsUrl),
              ),
              const Divider(height: 1),
              _RowTile(
                leading: LucideIcons.mail,
                title: 'Send feedback',
                subtitle: _feedbackEmail,
                onTap: () => _launchUrl(context, 'mailto:$_feedbackEmail'),
              ),
            ]),

            const SizedBox(height: AppSpacing.lg),

            // ── Dev ──────────────────────────────────────────────────────────
            const _SectionLabel(title: 'Dev'),
            const SizedBox(height: AppSpacing.xs),
            _Card(children: [
              _RowTile(
                leading: LucideIcons.rotateCcw,
                title: 'Reset onboarding',
                subtitle: 'Restart the first-run experience',
                onTap: () async {
                  final repo = ref.read(userPrefsRepositoryProvider);
                  await repo?.setHasCompletedOnboarding(false);
                  await repo?.setUniversityName(null);
                  await repo?.setProgrammeName(null);
                  ref.invalidate(notificationPrefsProvider);
                  if (context.mounted) {
                    context.go('/onboarding');
                  }
                },
              ),
            ]),

            const SizedBox(height: AppSpacing.xxl),
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

  void _showGradingSystemPicker(
    BuildContext context,
    WidgetRef ref,
    String currentId,
  ) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.lg,
          ),
          children: [
            Text(
              'Grading system',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'New courses and labels will use this system. Existing records keep the system they were created with.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: AppSpacing.sm),
            for (final system in GradingSystem.all)
              ListTile(
                leading: Icon(
                  system.id == currentId
                      ? LucideIcons.circleCheck
                      : LucideIcons.circle,
                ),
                title: Text(system.plannerTitle),
                subtitle: Text(
                  '${system.targetLabel} default: ${system.formatScore(system.defaultTarget, includeUnit: true)}',
                ),
                onTap: () async {
                  final repo = ref.read(userPrefsRepositoryProvider);
                  await repo?.setGradingSystemId(system.id);
                  await AnalyticsService.instance.logGradingSystemSelected(
                    system.id,
                  );
                  await AnalyticsService.instance.setCoreUserProperties(
                    gradingSystem: system.id,
                  );
                  if (sheetContext.mounted) {
                    Navigator.of(sheetContext).pop();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }

  String _themeLabel(int index) {
    switch (index) {
      case 0:
        return 'System';
      case 2:
        return 'Dark';
      default:
        return 'Light';
    }
  }
}

// ── Theme Picker Bottom Sheet ──────────────────────────────────────────────

Future<void> _showThemePicker(
  BuildContext context,
  WidgetRef ref,
  int currentIndex,
) async {
  int selected = currentIndex;

  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return _CampusBottomSheet(
            title: 'Theme',
            child: RadioGroup<int>(
              groupValue: selected,
              onChanged: (v) {
                if (v == null) return;
                setSheetState(() => selected = v);
                unawaited(_saveThemeMode(ctx, ref, v));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final entry in [
                    (index: 1, icon: LucideIcons.sun, label: 'Light'),
                    (index: 2, icon: LucideIcons.moon, label: 'Dark'),
                    (index: 0, icon: LucideIcons.sunMoon, label: 'System'),
                  ])
                    RadioListTile<int>(
                      value: entry.index,
                      title: Row(
                        children: [
                          Icon(entry.icon, size: AppIconSizes.lg),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text(entry.label)),
                        ],
                      ),
                      activeColor: Theme.of(ctx).colorScheme.primary,
                    ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _saveThemeMode(
    BuildContext context, WidgetRef ref, int value) async {
  final repo = ref.read(userPrefsRepositoryProvider);
  await repo?.setThemeModeIndex(value);
  await AnalyticsService.instance.logThemeChanged(_themeModeKey(value));
  await AnalyticsService.instance.setCoreUserProperties(
    themeMode: _themeModeKey(value),
  );
  ref.invalidate(notificationPrefsProvider);
  ref.invalidate(themeModeProvider);
  if (!context.mounted) return;
  Navigator.of(context).pop();
}

String _themeModeKey(int index) {
  switch (index) {
    case 1:
      return 'light';
    case 2:
      return 'dark';
    default:
      return 'system';
  }
}

String _layoutLabel(int index) {
  switch (index) {
    case 1:
      return 'Weekly Grid (Horizontal)';
    default:
      return 'Daily Grid (Vertical)';
  }
}

Future<void> _showLayoutPicker(
  BuildContext context,
  WidgetRef ref,
  int currentIndex,
) async {
  int selected = currentIndex;

  await showModalBottomSheet(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return _CampusBottomSheet(
            title: 'Timetable grid layout',
            child: RadioGroup<int>(
              groupValue: selected,
              onChanged: (v) {
                if (v == null) return;
                setSheetState(() => selected = v);
                unawaited(_saveLayoutMode(ctx, ref, v));
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final entry in [
                    (index: 0, icon: LucideIcons.calendarDays, label: 'Daily Grid (Vertical)'),
                    (index: 1, icon: LucideIcons.calendarRange, label: 'Weekly Grid (Horizontal)'),
                  ])
                    RadioListTile<int>(
                      value: entry.index,
                      title: Row(
                        children: [
                          Icon(entry.icon, size: AppIconSizes.lg),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(child: Text(entry.label)),
                        ],
                      ),
                      activeColor: Theme.of(ctx).colorScheme.primary,
                    ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

Future<void> _saveLayoutMode(
    BuildContext context, WidgetRef ref, int value) async {
  final repo = ref.read(userPrefsRepositoryProvider);
  await repo?.setTimetableGridLayoutIndex(value);
  ref.invalidate(notificationPrefsProvider);
  ref.invalidate(timetableGridLayoutProvider);
  if (!context.mounted) return;
  Navigator.of(context).pop();
}

// ── Shared bottom sheet wrapper ────────────────────────────────────────────

class _CampusBottomSheet extends StatelessWidget {
  final String title;
  final Widget child;

  const _CampusBottomSheet({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color:
            theme.bottomSheetTheme.backgroundColor ?? theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Settings row tiles ─────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding:
          const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.xxs),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;

  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Column(children: children),
    );
  }
}

class _RowTile extends StatelessWidget {
  final IconData leading;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _RowTile({
    required this.leading,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(leading, color: colorScheme.onSurfaceVariant),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            )
          : null,
      trailing: onTap != null
          ? Icon(
              LucideIcons.chevronRight,
              color: colorScheme.onSurfaceVariant,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      title: Text(title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              )),
      subtitle: Text(subtitle,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              )),
      value: value,
      onChanged: onChanged,
    );
  }
}

// ── URL launcher helper ────────────────────────────────────────────────────

Future<void> _launchUrl(BuildContext context, String url) async {
  final uri = Uri.parse(url);
  final didLaunch = await launchUrl(
    uri,
    mode: LaunchMode.externalApplication,
  );

  if (!didLaunch) {
    await Clipboard.setData(ClipboardData(text: url));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Copied to clipboard: $url')),
      );
    }
  }
}
