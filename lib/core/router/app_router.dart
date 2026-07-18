import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_screen.dart';
import 'package:campusiq/features/plan/presentation/screens/plan_screen.dart';
import 'package:campusiq/features/settings/presentation/screens/settings_screen.dart';
import 'package:campusiq/features/timetable/presentation/screens/timetable_screen.dart';
import 'package:campusiq/features/session/presentation/screens/session_screen.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/session/presentation/widgets/floating_mini_timer.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/insights/presentation/screens/insights_screen.dart';
import 'package:campusiq/features/streak/presentation/screens/streak_screen.dart';

import 'package:campusiq/features/ai/presentation/screens/weekly_review_screen.dart';
import 'package:campusiq/features/course_hub/presentation/screens/course_hub_screen.dart';
import 'package:campusiq/features/timetable/presentation/screens/timetable_import_screen.dart';
import 'package:campusiq/features/timetable/presentation/screens/course_reminders_screen.dart';
import 'package:campusiq/features/timetable/presentation/screens/timetable_notification_diagnostics_screen.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_manual_entry_screen.dart';
import 'package:campusiq/features/cwa/presentation/screens/past_semesters_screen.dart';
import 'package:campusiq/features/cwa/presentation/screens/registration_slip_import_screen.dart';
import 'package:campusiq/features/cwa/presentation/screens/result_slip_import_screen.dart';
import 'package:campusiq/features/onboarding/presentation/providers/onboarding_provider.dart';
import 'package:campusiq/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

final appRouter = GoRouter(
  initialLocation: '/plan',
  redirect: (context, state) {
    final uri = state.uri.toString();
    final container = ProviderScope.containerOf(context);
    final hasCompleted = container.read(onboardingCompletedProvider);
    if (hasCompleted == null) return null;
    if (uri == '/onboarding' && hasCompleted) return '/plan';
    if (uri == '/onboarding') return null;
    if (hasCompleted == false) return '/onboarding';
    return null;
  },
  routes: [
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const TrackedScreen(
        screenName: 'onboarding',
        child: OnboardingScreen(),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/plan',
          name: 'plan',
          builder: (context, state) => const TrackedScreen(
            screenName: 'today',
            child: PlanScreen(),
          ),
        ),
        GoRoute(
          path: '/cwa',
          name: 'cwa',
          builder: (context, state) => const TrackedScreen(
            screenName: 'planner',
            child: CwaScreen(),
          ),
        ),
        GoRoute(
          path: '/timetable',
          name: 'timetable',
          builder: (context, state) => const TrackedScreen(
            screenName: 'timetable',
            child: TimetableScreen(),
          ),
        ),
        GoRoute(
          path: '/sessions',
          name: 'sessions',
          builder: (context, state) => const TrackedScreen(
            screenName: 'sessions',
            child: SessionScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/ai/weekly-review',
      name: 'weekly-review',
      builder: (context, state) => const TrackedScreen(
        screenName: 'weekly_review',
        child: WeeklyReviewScreen(),
      ),
    ),
    GoRoute(
      path: '/streak',
      name: 'streak',
      builder: (context, state) => const TrackedScreen(
        screenName: 'streak',
        child: StreakScreen(),
      ),
    ),
    GoRoute(
      path: '/insights',
      name: 'insights',
      builder: (context, state) => const TrackedScreen(
        screenName: 'insights',
        child: InsightsScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const TrackedScreen(
        screenName: 'settings',
        child: SettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/course/:courseCode',
      name: 'course-hub',
      builder: (context, state) {
        final courseCode = state.pathParameters['courseCode'] ?? '';
        if (courseCode.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Course not found.')),
            );
            GoRouter.of(context).go('/cwa');
          });
          return const Scaffold(body: SizedBox.shrink());
        }
        return TrackedScreen(
          screenName: 'course_hub',
          child: CourseHubScreen(courseCode: courseCode),
        );
      },
    ),
    GoRoute(
      path: '/timetable/import',
      name: 'timetable-import',
      builder: (context, state) {
        final source = state.uri.queryParameters['source'];
        return TrackedScreen(
          screenName: 'timetable_import',
          child: TimetableImportScreen(initialSource: source),
        );
      },
    ),
    GoRoute(
      path: '/timetable/reminders',
      name: 'course-reminders',
      builder: (context, state) => const TrackedScreen(
        screenName: 'course_reminders',
        child: CourseRemindersScreen(),
      ),
    ),
    GoRoute(
      path: '/settings/timetable-notifications',
      name: 'timetable-notification-diagnostics',
      builder: (context, state) => const TrackedScreen(
        screenName: 'timetable_notification_diagnostics',
        child: TimetableNotificationDiagnosticsScreen(),
      ),
    ),
    GoRoute(
      path: '/cwa/manual-entry',
      name: 'cwa-manual-entry',
      builder: (context, state) {
        final mode = state.uri.queryParameters['mode'] ?? 'semester';
        return TrackedScreen(
          screenName: 'manual_entry',
          child: CwaManualEntryScreen(mode: mode),
        );
      },
    ),
    GoRoute(
      path: '/cwa/history',
      name: 'cwa-history',
      builder: (context, state) => const TrackedScreen(
        screenName: 'past_semesters',
        child: PastSemestersScreen(),
      ),
    ),
    GoRoute(
      path: '/cwa/import/registration',
      name: 'cwa-import-registration',
      builder: (context, state) {
        final source = state.uri.queryParameters['source'];
        return TrackedScreen(
          screenName: 'registration_import',
          child: RegistrationSlipImportScreen(initialSource: source),
        );
      },
    ),
    GoRoute(
      path: '/cwa/import/results',
      name: 'cwa-import-results',
      builder: (context, state) {
        final source = state.uri.queryParameters['source'];
        return TrackedScreen(
          screenName: 'result_import',
          child: ResultSlipImportScreen(initialSource: source),
        );
      },
    ),
  ],
);

class _AppShell extends ConsumerWidget {
  static const double _navHeight = AppSpacing.navHeight;
  static const double _navBottomMargin = AppSpacing.navBottomMargin;
  static const double _navHorizontalMargin = AppSpacing.navHorizontalMargin;
  static const double _timerGap = AppSpacing.timerGap;
  static const double _timerEstimatedHeight = AppSpacing.timerHeight;

  final Widget child;
  const _AppShell({required this.child});

  int? _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/plan')) return 0;
    if (location.startsWith('/cwa')) return 1;
    if (location.startsWith('/timetable')) return 2;
    if (location.startsWith('/sessions')) return 3;
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gradingSystem = ref.watch(gradingSystemProvider);
    final isSessionActive = ref.watch(activeSessionProvider) != null;
    final selectedIndex = _locationToIndex(context);
    final usesShellNav = selectedIndex != null;
    final isSessionsTab = selectedIndex == 3;
    final mediaQuery = MediaQuery.of(context);
    final navBottomOffset = mediaQuery.padding.bottom + _navBottomMargin;
    final shellBottomInset = mediaQuery.padding.bottom +
        _navBottomMargin +
        _navHeight +
        AppSpacing.xl;
    final timerBottomOffset = navBottomOffset + _navHeight + _timerGap;
    final childBottomInset = usesShellNav
        ? 0.0
        : shellBottomInset +
            (isSessionActive
                ? _timerEstimatedHeight + _timerGap + AppSpacing.md
                : 0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            right: 0,
            bottom: childBottomInset,
            child: MediaQuery(
              data: mediaQuery,
              child: ColoredBox(
                color: theme.scaffoldBackgroundColor,
                child: _ShellTabTransition(
                  selectedIndex: selectedIndex,
                  child: child,
                ),
              ),
            ),
          ),
          if (isSessionActive)
            Positioned(
              left: _navHorizontalMargin,
              right: _navHorizontalMargin,
              bottom: timerBottomOffset,
              child: _ActiveSessionTimerSlot(
                compact: !isSessionsTab,
                onTap: () => context.go('/sessions'),
              ),
            ),
          Positioned(
            left: _navHorizontalMargin,
            right: _navHorizontalMargin,
            bottom: navBottomOffset,
            child: _ShellBottomNav(
              selectedIndex: selectedIndex,
              isSessionActive: isSessionActive,
              gradesLabel: gradingSystem.label,
              onDestinationSelected: (i) {
                switch (i) {
                  case 0:
                    context.go('/plan');
                    return;
                  case 1:
                    context.go('/cwa');
                    return;
                  case 2:
                    context.go('/timetable');
                    return;
                  case 3:
                    context.go('/sessions');
                    return;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShellTabTransition extends StatefulWidget {
  final int? selectedIndex;
  final Widget child;

  const _ShellTabTransition({
    required this.selectedIndex,
    required this.child,
  });

  @override
  State<_ShellTabTransition> createState() => _ShellTabTransitionState();
}

class _ShellTabTransitionState extends State<_ShellTabTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Offset _beginOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant _ShellTabTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    final previousIndex = oldWidget.selectedIndex;
    final nextIndex = widget.selectedIndex;
    if (previousIndex == null ||
        nextIndex == null ||
        previousIndex == nextIndex) {
      return;
    }

    _beginOffset = Offset(nextIndex > previousIndex ? 1 : -1, 0);
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SlideTransition(
        position: Tween<Offset>(
          begin: _beginOffset,
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}

class _ActiveSessionTimerSlot extends StatelessWidget {
  final bool compact;
  final VoidCallback onTap;

  const _ActiveSessionTimerSlot({
    required this.compact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSpacing.timerHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final timerWidth = compact ? 58.0 : constraints.maxWidth;

          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 120),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              child: SizedBox(
                key: ValueKey<bool>(compact),
                width: timerWidth,
                height: compact ? 58 : null,
                child: FloatingMiniTimer(
                  compact: compact,
                  onTap: onTap,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ShellBottomNav extends StatelessWidget {
  final int? selectedIndex;
  final bool isSessionActive;
  final String gradesLabel;
  final ValueChanged<int> onDestinationSelected;

  const _ShellBottomNav({
    required this.selectedIndex,
    required this.isSessionActive,
    required this.gradesLabel,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = colorScheme.brightness == Brightness.dark;
    final lucide = theme.extension<AppLucideTheme>();
    final destinations = [
      (
        label: 'Home',
        icon: lucide?.home ?? LucideIcons.house,
        selectedIcon: lucide?.homeFilled ?? LucideIcons.house,
      ),
      (
        label: gradesLabel,
        icon: lucide?.analytics ?? LucideIcons.chartColumn,
        selectedIcon: lucide?.analyticsFilled ?? LucideIcons.chartColumn,
      ),
      (
        label: 'Table',
        icon: lucide?.timetable ?? LucideIcons.calendarDays,
        selectedIcon: lucide?.timetableFilled ?? LucideIcons.calendarDays,
      ),
      (
        label: 'Sessions',
        icon: lucide?.sessions ?? LucideIcons.timer,
        selectedIcon: lucide?.sessionsFilled ?? LucideIcons.timer,
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface.withValues(alpha: isDark ? 0.92 : 0.96),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.08),
            blurRadius: isDark ? 30 : 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: List.generate(destinations.length, (index) {
            final destination = destinations[index];
            final isSelected = selectedIndex == index;
            final iconColor =
                isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;
            final baseIcon =
                isSelected ? destination.selectedIcon : destination.icon;
            final icon = index == 3 && isSessionActive
                ? (lucide?.sessionsFilled ?? LucideIcons.timer)
                : baseIcon;

            return Expanded(
              child: Semantics(
                button: true,
                selected: isSelected,
                label: 'Open ${destination.label}',
                child: InkWell(
                  borderRadius: AppRadii.pill,
                  onTap: () => onDestinationSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.pill,
                      color: isSelected
                          ? colorScheme.primary
                              .withValues(alpha: isDark ? 0.18 : 0.08)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: AppIconSizes.xl,
                          color: iconColor,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          destination.label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: iconColor,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
