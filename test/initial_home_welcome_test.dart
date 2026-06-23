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
    expect(onboardingOnly.nextSetupStep, HomeSetupStep.courses);

    const coursesAdded = HomeSetupState(
      hasUniversityAndGradingSystem: true,
      hasCurrentCourses: true,
      hasTimetable: false,
      hasAcademicHistory: false,
      hasSeenInitialWelcome: true,
    );
    expect(coursesAdded.completedStepCount, 2);
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
      HomeSetupStep.academicHistory,
    );
  });

  testWidgets('welcome renders onboarding progress and safe name fallback',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: InitialHomeWelcome(
            setup: onboardingOnly,
            bottomPadding: 120,
            animateEntrance: true,
            onSetupStepTap: (_) {},
            onExplore: () {},
            onCalculateCwa: () {},
            onFocusSession: () {},
            onExploreTimetable: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Welcome to UniMate'), findsNWidgets(2));
    expect(find.textContaining('null'), findsNothing);
    expect(find.text('1 of 4 completed'), findsOneWidget);
    expect(find.text('University and grading system'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Add your current courses'), findsOneWidget);
    expect(find.text('Optional'), findsOneWidget);

    expect(find.text('Your semester starts here'), findsNothing);
    expect(find.text('Set up my semester'), findsNothing);
    expect(find.text('Explore UniMate'), findsNothing);
  });

  testWidgets('checklist routes each row through its setup callback',
      (tester) async {
    final tappedSteps = <HomeSetupStep>[];

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: InitialHomeWelcome(
            setup: onboardingOnly,
            bottomPadding: 100,
            animateEntrance: false,
            onSetupStepTap: tappedSteps.add,
            onExplore: () {},
            onCalculateCwa: () {},
            onFocusSession: () {},
            onExploreTimetable: () {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final step in HomeSetupStep.values) {
      final item = find.byKey(ValueKey('home-setup-${step.name}'));
      await tester.ensureVisible(item);
      await tester.pumpAndSettle();
      await tester.tap(item);
      await tester.pump();
    }

    expect(tappedSteps, HomeSetupStep.values);
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
              setup: onboardingOnly,
              bottomPadding: 120,
              animateEntrance: false,
              onSetupStepTap: (_) {},
              onExplore: () {},
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
