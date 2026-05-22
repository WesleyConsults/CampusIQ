import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

class OnboardingNotificationsScreen extends ConsumerWidget {
  const OnboardingNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = ref.watch(onboardingProvider);
    final notifier = ref.read(onboardingProvider.notifier);
    final setupDestination = switch (state.startAction) {
      OnboardingStartAction.importCourses => '/cwa/import/registration',
      OnboardingStartAction.addTimetable => '/timetable/import',
      null => null,
    };
    final hasSetupShortcut = state.startAction != null;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              OnboardingProgressDots(currentStep: state.step),
              IconButton(
                onPressed: notifier.goBack,
                icon: const Icon(LucideIcons.arrowLeft),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  children: [
                    Text(
                      'Stay on track from day one',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Choose the reminders you want. You can open a setup step now or add everything later from the app.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _ToggleRow(
                      icon: LucideIcons.bell,
                      title: 'Study reminders',
                      subtitle: 'Free block and daily study alerts',
                      value: state.notifyStudyReminders,
                      onChanged: notifier.setNotifyStudyReminders,
                    ),
                    const Divider(height: 1),
                    _ToggleRow(
                      icon: LucideIcons.flame,
                      title: 'Streak alerts',
                      subtitle: 'Notified when your streak is at risk',
                      value: state.notifyStreakAlerts,
                      onChanged: notifier.setNotifyStreakAlerts,
                    ),
                    const Divider(height: 1),
                    _ToggleRow(
                      icon: LucideIcons.trophy,
                      title: 'Milestone alerts',
                      subtitle: 'Notified when a streak milestone is near',
                      value: state.notifyMilestoneAlerts,
                      onChanged: notifier.setNotifyMilestoneAlerts,
                    ),
                    const Divider(height: 1),
                    _ToggleRow(
                      icon: LucideIcons.fileText,
                      title: 'Weekly review',
                      subtitle: 'Monday morning summary of your past week',
                      value: state.notifyWeeklyReview,
                      onChanged: notifier.setNotifyWeeklyReview,
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Set up now, or do it later',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      'Tap a selected card again to skip setup for now.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _StartActionTile(
                      icon: LucideIcons.fileUp,
                      title: 'Import my courses',
                      subtitle:
                          'Open the slip importer and build your planner.',
                      selected: state.startAction ==
                          OnboardingStartAction.importCourses,
                      onTap: () => notifier.toggleStartAction(
                        OnboardingStartAction.importCourses,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _StartActionTile(
                      icon: LucideIcons.calendarPlus,
                      title: 'Add my timetable',
                      subtitle: 'Import or create your class schedule.',
                      selected: state.startAction ==
                          OnboardingStartAction.addTimetable,
                      onTap: () => notifier.toggleStartAction(
                        OnboardingStartAction.addTimetable,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: state.isLoading
                      ? null
                      : () async {
                          await notifier.complete();
                          if (!context.mounted) return;
                          context.go('/plan');
                          if (setupDestination == null) return;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (context.mounted) {
                              context.push(setupDestination);
                            }
                          });
                        },
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          hasSetupShortcut
                              ? 'Finish and open setup'
                              : 'Finish and go to Today',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _StartActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _StartActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.md),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primaryContainer.withValues(alpha: 0.32)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(AppRadii.md),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? colorScheme.primary.withValues(alpha: 0.12)
                    : colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.55,
                      ),
                borderRadius: BorderRadius.circular(AppRadii.sm),
              ),
              child: Icon(
                icon,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? LucideIcons.circleCheck : LucideIcons.circle,
              color:
                  selected ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SwitchListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      secondary: Icon(icon, color: colorScheme.onSurfaceVariant),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
      value: value,
      activeTrackColor: colorScheme.primary,
      onChanged: onChanged,
    );
  }
}
