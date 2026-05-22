import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/widgets/onboarding_progress_dots.dart';

class OnboardingTimetableImportScreen extends ConsumerWidget {
  const OnboardingTimetableImportScreen({super.key});

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
              IconButton(
                onPressed: notifier.goBack,
                icon: const Icon(LucideIcons.arrowLeft),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  children: [
                    Text(
                      'Turn your timetable into a daily plan',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Import a timetable image, see today clearly, and let UniMate find the free blocks you can use for study.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    const _TimetablePreviewCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const _FeatureRow(
                      icon: LucideIcons.imageUp,
                      title: 'Import from an image',
                      subtitle: 'Use a screenshot or photo of your timetable.',
                    ),
                    const _FeatureRow(
                      icon: LucideIcons.clock3,
                      title: 'See your day at a glance',
                      subtitle:
                          'Classes, free blocks, and next class stay clear.',
                    ),
                    const _FeatureRow(
                      icon: LucideIcons.bellRing,
                      title: 'Get class reminders',
                      subtitle: 'Set alerts before lectures and labs.',
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: notifier.goNext,
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

class _TimetablePreviewCard extends StatelessWidget {
  const _TimetablePreviewCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.calendarDays, color: colorScheme.primary),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Monday',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs2,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: AppRadii.pill,
                ),
                child: Text(
                  '3 classes',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const _SlotPreviewRow(
            time: '8:30',
            title: 'Data Structures',
            room: 'Lab 4',
            isClass: true,
          ),
          const _SlotPreviewRow(
            time: '10:30',
            title: 'Free block',
            room: '2h for study',
            isClass: false,
          ),
          const _SlotPreviewRow(
            time: '12:30',
            title: 'Statistics',
            room: 'LT B',
            isClass: true,
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Icon(
                LucideIcons.scanLine,
                size: AppIconSizes.lg,
                color: colorScheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  'Import image -> Review -> Save',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
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

class _SlotPreviewRow extends StatelessWidget {
  final String time;
  final String title;
  final String room;
  final bool isClass;

  const _SlotPreviewRow({
    required this.time,
    required this.title,
    required this.room,
    required this.isClass,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = isClass ? colorScheme.primary : AppColors.gold;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              time,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.xs2),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: isClass ? 0.1 : 0.16),
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(color: accent.withValues(alpha: 0.18)),
              ),
              child: Row(
                children: [
                  Icon(
                    isClass ? LucideIcons.bookOpen : LucideIcons.coffee,
                    size: AppIconSizes.lg,
                    color: accent,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          room,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(AppRadii.sm),
            ),
            child:
                Icon(icon, color: colorScheme.primary, size: AppIconSizes.xl),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }
}
