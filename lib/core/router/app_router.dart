import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_screen.dart';
import 'package:campusiq/features/timetable/presentation/screens/timetable_screen.dart';
import 'package:campusiq/features/session/presentation/screens/session_screen.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/session/presentation/widgets/floating_mini_timer.dart';
import 'package:campusiq/features/streak/presentation/screens/streak_screen.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

final appRouter = GoRouter(
  initialLocation: '/cwa',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
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
      ],
    ),
  ],
);

class _AppShell extends ConsumerWidget {
  final Widget child;
  const _AppShell({required this.child});

  int _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/timetable')) return 1;
    if (location.startsWith('/sessions'))  return 2;
    if (location.startsWith('/streak'))    return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSessionActive = ref.watch(activeSessionProvider) != null;
    final studyStreak     = ref.watch(studyStreakProvider);
    final hasLossRisk     = studyStreak.lossAversionMessage != null;

    return Scaffold(
      body: Stack(
        children: [
          child,
          if (isSessionActive)
            FloatingMiniTimer(onTap: () => context.go('/sessions')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _locationToIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/cwa');
            case 1: context.go('/timetable');
            case 2: context.go('/sessions');
            case 3: context.go('/streak');
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'CWA',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Timetable',
          ),
          NavigationDestination(
            icon: isSessionActive
                ? const Icon(Icons.timer, color: Colors.red)
                : const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: 'Sessions',
          ),
          NavigationDestination(
            icon: hasLossRisk
                ? const Badge(
                    label: Text('!'),
                    child: Icon(Icons.local_fire_department_outlined),
                  )
                : const Icon(Icons.local_fire_department_outlined),
            selectedIcon: const Icon(Icons.local_fire_department),
            label: 'Streak',
          ),
        ],
      ),
    );
  }
}
