import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/plan/domain/home_setup_state.dart';
import 'package:campusiq/features/plan/presentation/providers/home_setup_provider.dart';
import 'package:campusiq/features/plan/presentation/providers/plan_provider.dart';
import 'package:campusiq/features/plan/presentation/screens/plan_screen.dart';
import 'package:campusiq/features/plan/presentation/widgets/plan_progress_bar.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  Future<GoRouter> showHome(WidgetTester tester,
      {bool hasTask = true, bool compact = false}) async {
    await tester.binding.setSurfaceSize(
      compact ? const Size(320, 568) : const Size(430, 1000),
    );
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final task = DailyPlanTaskModel()
      ..id = 1
      ..date = DateTime.now()
      ..taskType = 'study'
      ..label = 'Review circuits'
      ..courseCode = 'EE 301'
      ..durationMinutes = 60
      ..sortOrder = 0;
    final router = GoRouter(initialLocation: '/', routes: [
      GoRoute(path: '/', builder: (_, __) => const PlanScreen()),
      GoRoute(
          path: '/cwa',
          builder: (_, __) => const Scaffold(body: Text('Grades detail'))),
      GoRoute(
          path: '/streak',
          builder: (_, __) => const Scaffold(body: Text('Streak detail'))),
    ]);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: [
        homeSetupStateProvider.overrideWithValue(const HomeSetupState(
          hasUniversityAndGradingSystem: true,
          hasCurrentCourses: true,
          hasTimetable: true,
          hasAcademicHistory: false,
          hasSeenInitialWelcome: true,
        )),
        todayPlanProvider
            .overrideWith((ref) => Stream.value(hasTask ? [task] : [])),
        allSlotsProvider.overrideWith((ref) => Stream.value([])),
        activeSessionProvider.overrideWith((ref) => ActiveSessionNotifier()),
        userPrefsRepositoryProvider.overrideWithValue(null),
        planRepositoryProvider.overrideWithValue(null),
        gradingSystemProvider.overrideWithValue(GradingSystem.cwa),
        projectedCwaProvider.overrideWithValue(72),
        targetCwaProvider.overrideWithValue(75),
        studyStreakProvider.overrideWithValue(const StreakResult(
          currentStreak: 3,
          longestStreak: 3,
          isAlive: true,
          studiedToday: true,
          unlockedMilestones: [],
          nextMilestone: null,
          daysToNextMilestone: 0,
        )),
      ],
      child: MaterialApp.router(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: compact ? ThemeMode.dark : ThemeMode.light,
        routerConfig: router,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(compact ? 1.3 : 1),
          ),
          child: child!,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return router;
  }

  testWidgets('Home puts tasks before grades with a single progress indicator',
      (tester) async {
    await showHome(tester);
    expect(find.byType(PlanProgressBar), findsOneWidget);
    expect(find.text('Today at a glance'), findsNothing);
    expect(find.text("Today's Progress"), findsNothing);
    expect(tester.getTopLeft(find.text('Review circuits')).dy,
        lessThan(tester.getTopLeft(find.text('Grades & streaks')).dy));
    await tester.tap(find.textContaining('Projected CWA:'));
    await tester.pumpAndSettle();
    expect(find.text('Grades detail'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Empty Home offers planning actions and access to streak details',
      (tester) async {
    await showHome(tester, hasTask: false);
    expect(find.text('No classes today'), findsOneWidget);
    expect(find.text('No tasks yet'), findsOneWidget);
    expect(find.text('Generate plan'), findsOneWidget);
    expect(find.text('Add task'), findsOneWidget);
    expect(find.byType(PlanProgressBar), findsNothing);
    await tester.scrollUntilVisible(
      find.text('3-day study streak'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('3-day study streak'));
    await tester.pumpAndSettle();
    expect(find.text('Streak detail'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Home stays usable on a small dark screen with larger text',
      (tester) async {
    await showHome(tester, compact: true);
    await tester.scrollUntilVisible(
      find.text('3-day study streak'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('3-day study streak').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
