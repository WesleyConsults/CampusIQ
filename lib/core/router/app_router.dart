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
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/plan/presentation/providers/exam_mode_provider.dart';
import 'package:campusiq/features/ai/presentation/screens/ai_chat_screen.dart';
import 'package:campusiq/features/ai/presentation/screens/subscribe_screen_stub.dart';

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
  ],
);

class _AppShell extends ConsumerWidget {
  final Widget child;
  const _AppShell({required this.child});

  int _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/cwa'))       return 1;
    if (location.startsWith('/timetable')) return 2;
    if (location.startsWith('/sessions'))  return 3;
    if (location.startsWith('/streak'))    return 4;
    if (location.startsWith('/ai'))        return 5;
    return 0; // /plan
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSessionActive = ref.watch(activeSessionProvider) != null;
    final studyStreak     = ref.watch(studyStreakProvider);
    final hasLossRisk     = studyStreak.lossAversionMessage != null;
    final examModeActive  =
        ref.watch(examModeActiveProvider).valueOrNull ?? false;

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
            case 0: context.go('/plan');
            case 1: context.go('/cwa');
            case 2: context.go('/timetable');
            case 3: context.go('/sessions');
            case 4: context.go('/streak');
            case 5: context.go('/ai');
          }
        },
        destinations: [
          NavigationDestination(
            icon: examModeActive
                ? const Icon(Icons.whatshot, color: Colors.deepOrange)
                : const Icon(Icons.checklist_rounded),
            selectedIcon: examModeActive
                ? const Icon(Icons.whatshot, color: Colors.deepOrange)
                : const Icon(Icons.checklist_rounded),
            label: examModeActive ? 'Exam Mode' : 'Plan',
          ),
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
          const NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'AI Coach',
          ),
        ],
      ),
    );
  }
}
