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
import 'package:campusiq/features/insights/presentation/screens/insights_screen.dart';
import 'package:campusiq/features/streak/presentation/screens/streak_screen.dart';
import 'package:campusiq/features/ai/presentation/screens/ai_chat_screen.dart';
import 'package:campusiq/features/ai/presentation/screens/subscribe_screen_stub.dart';
import 'package:campusiq/features/ai/presentation/screens/weekly_review_screen.dart';
import 'package:campusiq/features/course_hub/presentation/screens/course_hub_screen.dart';
import 'package:campusiq/features/timetable/presentation/screens/timetable_import_screen.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_manual_entry_screen.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

final appRouter = GoRouter(
  initialLocation: '/plan',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/plan',
          name: 'plan',
          builder: (context, state) => const PlanScreen(),
        ),
        GoRoute(
          path: '/cwa',
          name: 'cwa',
          builder: (context, state) => const CwaScreen(),
        ),
        GoRoute(
          path: '/timetable',
          name: 'timetable',
          builder: (context, state) => const TimetableScreen(),
        ),
        GoRoute(
          path: '/sessions',
          name: 'sessions',
          builder: (context, state) => const SessionScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/subscribe',
      name: 'subscribe',
      builder: (context, state) => const SubscribeScreenStub(),
    ),
    GoRoute(
      path: '/ai/weekly-review',
      name: 'weekly-review',
      builder: (context, state) => const WeeklyReviewScreen(),
    ),
    GoRoute(
      path: '/streak',
      name: 'streak',
      builder: (context, state) => const StreakScreen(),
    ),
    GoRoute(
      path: '/insights',
      name: 'insights',
      builder: (context, state) => const InsightsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/ai',
      name: 'ai',
      builder: (context, state) => const AiChatScreen(),
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
        return CourseHubScreen(courseCode: courseCode);
      },
    ),
    GoRoute(
      path: '/timetable/import',
      name: 'timetable-import',
      builder: (context, state) => const TimetableImportScreen(),
    ),
    GoRoute(
      path: '/cwa/manual-entry',
      name: 'cwa-manual-entry',
      builder: (context, state) {
        final mode = state.uri.queryParameters['mode'] ?? 'semester';
        return CwaManualEntryScreen(mode: mode);
      },
    ),
  ],
);

class _AppShell extends ConsumerWidget {
  static const double _navHeight = 72;
  static const double _navBottomMargin = 14;
  static const double _navHorizontalMargin = 18;
  static const double _timerGap = 12;
  static const double _timerEstimatedHeight = 64;
  static const double _fabSize = 58;

  final Widget child;
  const _AppShell({required this.child});

  int? _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/plan') || location.startsWith('/today')) return 0;
    if (location.startsWith('/cwa')) return 1;
    if (location.startsWith('/timetable')) return 2;
    if (location.startsWith('/sessions')) return 3;
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSessionActive = ref.watch(activeSessionProvider) != null;
    final selectedIndex = _locationToIndex(context);
    final usesShellNav = selectedIndex != null;
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
      backgroundColor: AppTheme.surface,
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
                color: AppTheme.surface,
                child: child,
              ),
            ),
          ),
          if (isSessionActive)
            Positioned(
              left: _navHorizontalMargin,
              right: _navHorizontalMargin + _fabSize + AppSpacing.md,
              bottom: timerBottomOffset,
              child: FloatingMiniTimer(onTap: () => context.go('/sessions')),
            ),
          Positioned(
            left: _navHorizontalMargin,
            right: _navHorizontalMargin,
            bottom: navBottomOffset,
            child: _ShellBottomNav(
              selectedIndex: selectedIndex,
              isSessionActive: isSessionActive,
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
          Positioned(
            right: _navHorizontalMargin,
            bottom: navBottomOffset + _navHeight + AppSpacing.md,
            child: _AiFab(onPressed: () => context.push('/ai')),
          ),
        ],
      ),
    );
  }
}

class _ShellBottomNav extends StatelessWidget {
  final int? selectedIndex;
  final bool isSessionActive;
  final ValueChanged<int> onDestinationSelected;

  const _ShellBottomNav({
    required this.selectedIndex,
    required this.isSessionActive,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final lucide = theme.extension<AppLucideTheme>();
    final destinations = [
      (
        label: 'Home',
        icon: lucide?.home ?? LucideIcons.house,
        selectedIcon: lucide?.homeFilled ?? LucideIcons.house,
      ),
      (
        label: 'CWA',
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
        color: AppColors.surface.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.all(Radius.circular(30)),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.9)),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 26,
            offset: Offset(0, 10),
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
                isSelected ? AppTheme.primary : AppColors.textSecondary;
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
                          ? AppTheme.primary.withValues(alpha: 0.08)
                          : Colors.transparent,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 20,
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

class _AiFab extends StatelessWidget {
  final VoidCallback onPressed;

  const _AiFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final lucide = Theme.of(context).extension<AppLucideTheme>();

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadii.pill,
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: FloatingActionButton.small(
        onPressed: onPressed,
        tooltip: 'AI Assistant',
        backgroundColor: AppColors.goldSoft,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.pill),
        child: Icon(lucide?.ai ?? LucideIcons.sparkles, size: 18),
      ),
    );
  }
}
