import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/ai'),
        tooltip: 'AI Assistant',
        child: const Icon(Icons.auto_awesome),
      ),
      body: Stack(
        children: [
          child,
          if (isSessionActive)
            FloatingMiniTimer(onTap: () => context.go('/sessions')),
        ],
      ),
      bottomNavigationBar: _ShellBottomNav(
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
    final colorScheme = theme.colorScheme;
    const destinations = [
      (
        label: 'Home',
        icon: Icons.home_outlined,
        selectedIcon: Icons.home,
      ),
      (
        label: 'CWA',
        icon: Icons.analytics_outlined,
        selectedIcon: Icons.analytics,
      ),
      (
        label: 'Table',
        icon: Icons.calendar_view_week_outlined,
        selectedIcon: Icons.calendar_view_week,
      ),
      (
        label: 'Sessions',
        icon: Icons.timer_outlined,
        selectedIcon: Icons.timer,
      ),
    ];

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: List.generate(destinations.length, (index) {
              final destination = destinations[index];
              final isSelected = selectedIndex == index;
              final iconColor = isSelected
                  ? Theme.of(context).colorScheme.primary
                  : const Color(0xFF6B7280);
              final baseIcon =
                  isSelected ? destination.selectedIcon : destination.icon;
              final icon =
                  index == 3 && isSessionActive ? Icons.timer : baseIcon;

              return Expanded(
                child: Semantics(
                  button: true,
                  selected: isSelected,
                  label: 'Open ${destination.label}',
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onDestinationSelected(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: isSelected
                            ? colorScheme.primary.withValues(alpha: 0.10)
                            : Colors.transparent,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            icon,
                            size: 20,
                            color: index == 3 && isSessionActive && !isSelected
                                ? Colors.red
                                : iconColor,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destination.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: iconColor,
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
      ),
    );
  }
}
