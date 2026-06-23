import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/plan/domain/home_setup_state.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class InitialHomeWelcome extends StatefulWidget {
  final HomeSetupState setup;
  final double bottomPadding;
  final bool animateEntrance;
  final ValueChanged<HomeSetupStep> onSetupStepTap;
  final VoidCallback onExplore;
  final VoidCallback onCalculateCwa;
  final VoidCallback onFocusSession;
  final VoidCallback onExploreTimetable;

  const InitialHomeWelcome({
    super.key,
    required this.setup,
    required this.bottomPadding,
    required this.animateEntrance,
    required this.onSetupStepTap,
    required this.onExplore,
    required this.onCalculateCwa,
    required this.onFocusSession,
    required this.onExploreTimetable,
  });

  @override
  State<InitialHomeWelcome> createState() => _InitialHomeWelcomeState();
}

class _InitialHomeWelcomeState extends State<InitialHomeWelcome>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      value: widget.animateEntrance ? 0 : 1,
    );
    if (widget.animateEntrance) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final animation = disableAnimations
        ? const AlwaysStoppedAnimation<double>(1)
        : CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    final greeting = _greeting(widget.setup);

    return CustomScrollView(
      key: const ValueKey('initial-home-welcome'),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            0,
          ),
          sliver: SliverList.list(
            children: [
              _Entrance(
                animation: animation,
                interval: const Interval(0, 0.45),
                child: const _SemesterSetupHero(),
              ),
              const SizedBox(height: AppSpacing.lg),
              _Entrance(
                animation: animation,
                interval: const Interval(0.16, 0.72),
                child: _WelcomeGreeting(
                  greeting: greeting,
                  isFirstVisit: widget.animateEntrance,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _Entrance(
                animation: animation,
                interval: const Interval(0.36, 1),
                child: _HomeSetupChecklist(
                  setup: widget.setup,
                  onStepTap: widget.onSetupStepTap,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              _HomeQuickActions(
                onCalculateCwa: widget.onCalculateCwa,
                onFocusSession: widget.onFocusSession,
                onExploreTimetable: widget.onExploreTimetable,
              ),
              SizedBox(height: widget.bottomPadding),
            ],
          ),
        ),
      ],
    );
  }

  String _greeting(HomeSetupState setup) {
    final firstName = setup.firstName?.trim();
    final nameSuffix =
        firstName == null || firstName.isEmpty ? '' : ', $firstName';
    if (widget.animateEntrance) return 'Welcome to UniMate$nameSuffix';

    final hour = DateTime.now().hour;
    final salutation = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';
    return '$salutation$nameSuffix';
  }
}

class _Entrance extends StatelessWidget {
  final Animation<double> animation;
  final Interval interval;
  final Widget child;

  const _Entrance({
    required this.animation,
    required this.interval,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: interval);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

class _WelcomeGreeting extends StatelessWidget {
  final String greeting;
  final bool isFirstVisit;

  const _WelcomeGreeting({
    required this.greeting,
    required this.isFirstVisit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          key: const ValueKey('initial-home-greeting'),
          style: theme.textTheme.headlineLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w800,
            height: 1.08,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isFirstVisit
              ? 'Your academic life is about to become easier.'
              : 'Let’s finish setting up your semester.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SemesterSetupHero extends StatelessWidget {
  const _SemesterSetupHero();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.xl)),
        gradient: LinearGradient(
          colors: [Color(0xFF10203F), Color(0xFF1C3564)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xxl,
        ),
        child: Center(
          child: Text(
            'Welcome to UniMate',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeSetupChecklist extends StatelessWidget {
  final HomeSetupState setup;
  final ValueChanged<HomeSetupStep> onStepTap;

  const _HomeSetupChecklist({
    required this.setup,
    required this.onStepTap,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      (
        step: HomeSetupStep.university,
        title: 'University and grading system',
        helper: null,
        icon: LucideIcons.school,
        complete: setup.hasUniversityAndGradingSystem,
        optional: false,
      ),
      (
        step: HomeSetupStep.courses,
        title: 'Add your current courses',
        helper: 'Helps UniMate calculate your semester results',
        icon: LucideIcons.bookOpen,
        complete: setup.hasCurrentCourses,
        optional: false,
      ),
      (
        step: HomeSetupStep.timetable,
        title: 'Import or create your timetable',
        helper: null,
        icon: LucideIcons.calendarDays,
        complete: setup.hasTimetable,
        optional: false,
      ),
      (
        step: HomeSetupStep.academicHistory,
        title: 'Add academic history',
        helper: null,
        icon: LucideIcons.history,
        complete: setup.hasAcademicHistory,
        optional: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final progress = Text(
              '${setup.completedStepCount} of 4 completed',
              key: const ValueKey('home-setup-progress'),
              style: Theme.of(context).textTheme.bodyMedium,
            );
            if (constraints.maxWidth < 380) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Get UniMate ready',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  progress,
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: Text(
                    'Get UniMate ready',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                progress,
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: AppRadii.card,
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            boxShadow: AppShadows.soft,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var index = 0; index < steps.length; index++) ...[
                _SetupChecklistItem(
                  step: steps[index].step,
                  title: steps[index].title,
                  helper: steps[index].helper,
                  icon: steps[index].icon,
                  isComplete: steps[index].complete,
                  isActive: steps[index].step == setup.nextSetupStep,
                  isOptional: steps[index].optional,
                  onTap: () => onStepTap(steps[index].step),
                ),
                if (index < steps.length - 1)
                  Divider(
                    height: 1,
                    indent: AppSpacing.md,
                    endIndent: AppSpacing.md,
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SetupChecklistItem extends StatelessWidget {
  final HomeSetupStep step;
  final String title;
  final String? helper;
  final IconData icon;
  final bool isComplete;
  final bool isActive;
  final bool isOptional;
  final VoidCallback onTap;

  const _SetupChecklistItem({
    required this.step,
    required this.title,
    required this.helper,
    required this.icon,
    required this.isComplete,
    required this.isActive,
    required this.isOptional,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final successBackground = Color.alphaBlend(
      AppColors.success.withValues(alpha: 0.1),
      colorScheme.surface,
    );
    final activeBackground = Color.alphaBlend(
      AppColors.gold.withValues(alpha: 0.08),
      colorScheme.surface,
    );

    return Semantics(
      button: true,
      label: '$title${isOptional ? ', optional' : ''}',
      child: Material(
        color: isComplete
            ? successBackground
            : isActive
                ? activeBackground
                : colorScheme.surface,
        child: InkWell(
          key: ValueKey('home-setup-${step.name}'),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 68),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isComplete
                          ? AppColors.success
                          : isActive
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHighest,
                    ),
                    child: Icon(
                      isComplete ? LucideIcons.check : icon,
                      color: isComplete || isActive
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                      size: AppIconSizes.xl,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: colorScheme.onSurface,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w600,
                                  ),
                        ),
                        if (helper != null && isActive) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Text(
                            helper!,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                        if (isOptional && !isComplete) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                              vertical: AppSpacing.xxs,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: AppRadii.pill,
                            ),
                            child: Text(
                              'Optional',
                              style: Theme.of(context).textTheme.labelSmall,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  if (isComplete)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xs,
                        vertical: AppSpacing.xxs2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: AppRadii.pill,
                      ),
                      child: Text(
                        'Completed',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.success,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    )
                  else
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive
                            ? colorScheme.primary
                            : colorScheme.surfaceContainerHighest,
                      ),
                      child: Icon(
                        LucideIcons.chevronRight,
                        color: isActive
                            ? colorScheme.onPrimary
                            : colorScheme.onSurfaceVariant,
                        size: AppIconSizes.lg,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeQuickActions extends StatelessWidget {
  final VoidCallback onCalculateCwa;
  final VoidCallback onFocusSession;
  final VoidCallback onExploreTimetable;

  const _HomeQuickActions({
    required this.onCalculateCwa,
    required this.onFocusSession,
    required this.onExploreTimetable,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      _QuickActionData(
        title: 'Calculate CWA',
        icon: LucideIcons.calculator,
        onTap: onCalculateCwa,
      ),
      _QuickActionData(
        title: 'Focus session',
        icon: LucideIcons.timer,
        onTap: onFocusSession,
      ),
      _QuickActionData(
        title: 'Explore timetable',
        icon: LucideIcons.calendarDays,
        onTap: onExploreTimetable,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Try UniMate now',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = (constraints.maxWidth - AppSpacing.sm) / 2;
            return Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (var i = 0; i < cards.length; i++)
                  SizedBox(
                    width: i == cards.length - 1
                        ? constraints.maxWidth
                        : cardWidth,
                    height: 120,
                    child: _HomeQuickActionCard(data: cards[i]),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _QuickActionData {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionData({
    required this.title,
    required this.icon,
    required this.onTap,
  });
}

class _HomeQuickActionCard extends StatelessWidget {
  final _QuickActionData data;

  const _HomeQuickActionCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.card,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: AppRadii.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Icon(
                  data.icon,
                  color: AppColors.goldSoft,
                  size: AppIconSizes.xxl,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                data.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
