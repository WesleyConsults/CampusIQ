import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/plan/domain/home_setup_state.dart';
import 'package:campusiq/features/plan/presentation/widgets/initial_home_welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const onboardingOnly = HomeSetupState(
    hasUniversityAndGradingSystem: true,
    hasCurrentCourses: false,
    hasTimetable: false,
    hasAcademicHistory: false,
    hasSeenInitialWelcome: false,
  );

  test('home setup state derives progress and next required action', () {
    expect(onboardingOnly.isInitialHomeSetup, isTrue);
    expect(onboardingOnly.completedStepCount, 1);
    expect(onboardingOnly.nextSetupStep, HomeSetupStep.timetable);

    const coursesAdded = HomeSetupState(
      hasUniversityAndGradingSystem: true,
      hasCurrentCourses: true,
      hasTimetable: false,
      hasAcademicHistory: false,
      hasSeenInitialWelcome: true,
    );
    expect(coursesAdded.completedStepCount, 1);
    expect(coursesAdded.nextSetupStep, HomeSetupStep.timetable);

    const requiredSetupComplete = HomeSetupState(
      hasUniversityAndGradingSystem: true,
      hasCurrentCourses: true,
      hasTimetable: true,
      hasAcademicHistory: false,
      hasSeenInitialWelcome: true,
    );
    expect(requiredSetupComplete.isInitialHomeSetup, isFalse);
    expect(
      requiredSetupComplete.nextSetupStep,
      isNull,
    );
  });

  testWidgets('welcome renders hero and hides setup checklist copy',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: InitialHomeWelcome(
            bottomPadding: 120,
            animateEntrance: true,
            onGetStarted: () {},
            onCalculateCwa: () {},
            onFocusSession: () {},
            onExploreTimetable: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to UniMate'), findsOneWidget);
    expect(
      find.text('Your academic companion for this semester.'),
      findsOneWidget,
    );
    expect(find.text('Track your progress'), findsNothing);
    expect(find.text('Manage your timetable'), findsNothing);
    expect(find.text('Stay focused'), findsNothing);
    expect(find.text('Get Started'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
    expect(
      find.text('Everything you need, right at your fingertips.'),
      findsOneWidget,
    );
    expect(find.textContaining('null'), findsNothing);
    expect(find.text('1 of 2 completed'), findsNothing);
    expect(find.text('University and grading system'), findsNothing);
    expect(find.text('Import or create your timetable'), findsNothing);
    expect(find.text('Completed'), findsNothing);
    expect(find.text('Add your current courses'), findsNothing);
    expect(find.text('Optional'), findsNothing);
    expect(find.text('Know where you stand academically.'), findsNothing);
    expect(find.text('Study with a distraction-free timer.'), findsNothing);
    expect(
      find.text('View, manage and stay on top of your classes.'),
      findsNothing,
    );

    expect(find.text('Your semester starts here'), findsNothing);
    expect(find.text('Set up my semester'), findsNothing);
    expect(find.text('Explore UniMate'), findsNothing);
  });

  testWidgets('welcome actions route through their callbacks', (tester) async {
    var getStarted = 0;
    var cwa = 0;
    var session = 0;
    var timetable = 0;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: InitialHomeWelcome(
            bottomPadding: 100,
            animateEntrance: false,
            onGetStarted: () => getStarted++,
            onCalculateCwa: () => cwa++,
            onFocusSession: () => session++,
            onExploreTimetable: () => timetable++,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('initial-home-get-started')));
    await tester.pump();
    await tester.tap(find.text('Calculate CWA'));
    await tester.pump();
    await tester.tap(find.text('Focus Session'));
    await tester.pump();
    await tester.ensureVisible(find.text('Explore Timetable'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Explore Timetable'));
    await tester.pump();

    expect(getStarted, 1);
    expect(cwa, 1);
    expect(session, 1);
    expect(timetable, 1);
  });

  testWidgets('welcome remains overflow-free on a small dark-mode display',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(1.3),
          ),
          child: Scaffold(
            body: InitialHomeWelcome(
              bottomPadding: 120,
              animateEntrance: false,
              onGetStarted: () {},
              onCalculateCwa: () {},
              onFocusSession: () {},
              onExploreTimetable: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('initial-home-welcome')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
