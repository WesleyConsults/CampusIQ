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

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              OnboardingProgressDots(currentStep: state.step),
              Row(
                children: [
                  IconButton(
                    onPressed: () => notifier.goBack(),
                    icon: const Icon(LucideIcons.arrowLeft),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Stay on track',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'We\'ll send helpful reminders. You can change these anytime in Settings.',
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
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton(
                          onPressed: state.isLoading
                              ? null
                              : () async {
                                  await notifier.complete();
                                  if (context.mounted) context.go('/plan');
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
                              : const Text('Finish',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
      title: Text(title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              )),
      subtitle: Text(subtitle,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              )),
      value: value,
      activeTrackColor: colorScheme.primary,
      onChanged: onChanged,
    );
  }
}
