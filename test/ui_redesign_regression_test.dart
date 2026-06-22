import 'dart:async';

import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/core/router/app_router.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_manual_entry_screen.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_screen.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/session/presentation/widgets/floating_mini_timer.dart';
import 'package:campusiq/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    appRouter.go('/plan');
  });

  testWidgets('shell navigation still exposes core destinations',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWith((ref) async => throw UnimplementedError()),
          cwaRepositoryProvider.overrideWithValue(null),
          pastResultRepositoryProvider.overrideWithValue(null),
          isPremiumProvider.overrideWith((ref) async => false),
          notificationPrefsProvider
              .overrideWith((ref) async => UserPrefsModel()),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );

    await _pumpFrames(tester);

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('CWA'), findsOneWidget);
    expect(find.text('Table'), findsOneWidget);
    expect(find.text('Sessions'), findsOneWidget);
    expect(find.byTooltip('AI Assistant'), findsNothing);

    await tester.tap(find.text('CWA'));
    await _pumpFrames(tester);
    expect(find.text('CWA'), findsWidgets);
    expect(
      _navigationDestinationContainer(tester, 'CWA'),
      isNotNull,
    );

    await tester.tap(find.text('Home'));
    await _pumpFrames(tester);
    expect(find.text('Today'), findsWidgets);
  });

  testWidgets('cwa import sheet shows all redesign options', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWith((ref) async => throw UnimplementedError()),
          cwaRepositoryProvider.overrideWithValue(null),
          pastResultRepositoryProvider.overrideWithValue(null),
          coursesProvider.overrideWith((ref) => Stream.value(const [])),
          pastSemestersProvider.overrideWith((ref) => Stream.value(const [])),
          manualAcademicBaselineProvider
              .overrideWith((ref) => Stream.value(null)),
          cwaSetupTargetConfirmedProvider
              .overrideWith((ref) => Stream.value(false)),
        ],
        child: const MaterialApp(home: CwaScreen()),
      ),
    );

    await _pumpFrames(tester);

    expect(find.text('Let’s set up your CWA'), findsOneWidget);
    expect(find.text('0/3 completed'), findsOneWidget);
    await tester.tap(find.text('Start with my courses'));
    await _pumpFrames(tester);

    expect(find.text('Use Timetable'), findsOneWidget);
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Upload Image'), findsOneWidget);
    expect(find.text('Choose PDF'), findsOneWidget);
    expect(find.text('Enter Manually'), findsOneWidget);
  });

  testWidgets('cwa setup animates a newly completed step once', (tester) async {
    final coursesController = StreamController<List<CourseModel>>();
    addTearDown(coursesController.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWith((ref) async => throw UnimplementedError()),
          cwaRepositoryProvider.overrideWithValue(null),
          pastResultRepositoryProvider.overrideWithValue(null),
          coursesProvider.overrideWith((ref) async* {
            yield const [];
            yield* coursesController.stream;
          }),
          pastSemestersProvider.overrideWith((ref) => Stream.value(const [])),
          manualAcademicBaselineProvider
              .overrideWith((ref) => Stream.value(null)),
          cwaSetupTargetConfirmedProvider
              .overrideWith((ref) => Stream.value(false)),
        ],
        child: const MaterialApp(home: CwaScreen()),
      ),
    );

    await _pumpFrames(tester);

    const instructionsKey = ValueKey('cwa-setup-step-1-instructions');
    const confirmationKey = ValueKey('cwa-setup-step-1-confirmation');
    expect(
      tester
          .widget<SizeTransition>(find.byKey(instructionsKey))
          .sizeFactor
          .value,
      1,
    );
    expect(
      tester
          .widget<SizeTransition>(find.byKey(confirmationKey))
          .sizeFactor
          .value,
      0,
    );

    coursesController.add([
      CourseModel.create(
        name: 'Engineering Mathematics',
        code: 'MATH101',
        creditHours: 3,
        expectedScore: 72,
        semesterKey: '2026-Sem1',
      ),
    ]);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 813));

    final collapsingInstructions =
        tester.widget<SizeTransition>(find.byKey(instructionsKey));
    final appearingConfirmation =
        tester.widget<SizeTransition>(find.byKey(confirmationKey));
    expect(collapsingInstructions.sizeFactor.value, inExclusiveRange(0, 1));
    expect(appearingConfirmation.sizeFactor.value, inExclusiveRange(0, 1));
    expect(find.text('1/3 completed'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1000));
    expect(
      tester
          .widget<SizeTransition>(find.byKey(instructionsKey))
          .sizeFactor
          .value,
      0,
    );
    expect(
      tester
          .widget<SizeTransition>(find.byKey(confirmationKey))
          .sizeFactor
          .value,
      1,
    );
    expect(find.text('Current courses added'), findsOneWidget);
  });

  testWidgets('completed cwa steps do not replay animation on revisit',
      (tester) async {
    final existingCourse = CourseModel.create(
      name: 'Engineering Mathematics',
      code: 'MATH101',
      creditHours: 3,
      expectedScore: 72,
      semesterKey: '2026-Sem1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWith((ref) async => throw UnimplementedError()),
          cwaRepositoryProvider.overrideWithValue(null),
          pastResultRepositoryProvider.overrideWithValue(null),
          coursesProvider.overrideWith((ref) => Stream.value([existingCourse])),
          pastSemestersProvider.overrideWith((ref) => Stream.value(const [])),
          manualAcademicBaselineProvider
              .overrideWith((ref) => Stream.value(null)),
          cwaSetupTargetConfirmedProvider
              .overrideWith((ref) => Stream.value(false)),
        ],
        child: const MaterialApp(home: CwaScreen()),
      ),
    );

    await _pumpFrames(tester);

    expect(
      tester
          .widget<SizeTransition>(
            find.byKey(
              const ValueKey('cwa-setup-step-1-instructions'),
            ),
          )
          .sizeFactor
          .value,
      0,
    );
    expect(
      tester
          .widget<SizeTransition>(
            find.byKey(
              const ValueKey('cwa-setup-step-1-confirmation'),
            ),
          )
          .sizeFactor
          .value,
      1,
    );
  });

  testWidgets('cwa completion waits until a covering route is dismissed',
      (tester) async {
    final coursesController = StreamController<List<CourseModel>>();
    addTearDown(coursesController.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWith((ref) async => throw UnimplementedError()),
          cwaRepositoryProvider.overrideWithValue(null),
          pastResultRepositoryProvider.overrideWithValue(null),
          coursesProvider.overrideWith((ref) async* {
            yield const [];
            yield* coursesController.stream;
          }),
          pastSemestersProvider.overrideWith((ref) => Stream.value(const [])),
          manualAcademicBaselineProvider
              .overrideWith((ref) => Stream.value(null)),
          cwaSetupTargetConfirmedProvider
              .overrideWith((ref) => Stream.value(false)),
        ],
        child: const MaterialApp(home: CwaScreen()),
      ),
    );

    await _pumpFrames(tester);

    final navigator = Navigator.of(tester.element(find.byType(CwaScreen)));
    navigator.push<void>(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const Scaffold(
          body: Center(child: Text('Covered workflow')),
        ),
      ),
    );
    await tester.pump();

    coursesController.add([
      CourseModel.create(
        name: 'Engineering Mathematics',
        code: 'MATH101',
        creditHours: 3,
        expectedScore: 72,
        semesterKey: '2026-Sem1',
      ),
    ]);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));

    final hiddenInstructions = find.byKey(
      const ValueKey('cwa-setup-step-1-instructions'),
      skipOffstage: false,
    );
    final hiddenConfirmation = find.byKey(
      const ValueKey('cwa-setup-step-1-confirmation'),
      skipOffstage: false,
    );
    expect(
      tester.widget<SizeTransition>(hiddenInstructions).sizeFactor.value,
      1,
    );
    expect(
      tester.widget<SizeTransition>(hiddenConfirmation).sizeFactor.value,
      0,
    );
    expect(
      find.text('0/3 completed', skipOffstage: false),
      findsOneWidget,
    );

    navigator.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 813));

    expect(
      tester.widget<SizeTransition>(hiddenInstructions).sizeFactor.value,
      inExclusiveRange(0, 1),
    );
    expect(
      tester.widget<SizeTransition>(hiddenConfirmation).sizeFactor.value,
      inExclusiveRange(0, 1),
    );
    expect(find.text('1/3 completed'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1000));
    expect(
      tester.widget<SizeTransition>(hiddenInstructions).sizeFactor.value,
      0,
    );
    expect(
      tester.widget<SizeTransition>(hiddenConfirmation).sizeFactor.value,
      1,
    );
  });

  testWidgets(
      'final cwa completion remains visible before dashboard transition',
      (tester) async {
    final targetController = StreamController<bool>();
    addTearDown(targetController.close);
    final existingCourse = CourseModel.create(
      name: 'Engineering Mathematics',
      code: 'MATH101',
      creditHours: 3,
      expectedScore: 72,
      semesterKey: '2026-Sem1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWith((ref) async => throw UnimplementedError()),
          cwaRepositoryProvider.overrideWithValue(null),
          pastResultRepositoryProvider.overrideWithValue(null),
          coursesProvider.overrideWith((ref) => Stream.value([existingCourse])),
          pastSemestersProvider.overrideWith((ref) => Stream.value(const [])),
          manualAcademicBaselineProvider.overrideWith(
            (ref) => Stream.value(
              const ManualAcademicBaseline(
                score: 68,
                credits: 45,
                gradingSystemId: 'cwa',
              ),
            ),
          ),
          cwaSetupTargetConfirmedProvider.overrideWith((ref) async* {
            yield false;
            yield* targetController.stream;
          }),
        ],
        child: const MaterialApp(home: CwaScreen()),
      ),
    );

    await _pumpFrames(tester);

    final navigator = Navigator.of(tester.element(find.byType(CwaScreen)));
    navigator.push<void>(
      PageRouteBuilder(
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (_, __, ___) => const Scaffold(
          body: Center(child: Text('Target dialog placeholder')),
        ),
      ),
    );
    await tester.pump();

    targetController.add(true);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    expect(
      find.byKey(const ValueKey('cwa-setup'), skipOffstage: false),
      findsOneWidget,
    );

    navigator.pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1750));

    expect(find.byKey(const ValueKey('cwa-setup')), findsOneWidget);
    expect(find.text('Target confirmed'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1375));
    expect(find.byKey(const ValueKey('cwa-dashboard')), findsOneWidget);
  });

  testWidgets('manual entry screen renders safely on a small display',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 560));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final router = GoRouter(
      initialLocation: '/manual',
      routes: [
        GoRoute(
          path: '/manual',
          builder: (context, state) =>
              const CwaManualEntryScreen(mode: 'semester'),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cwaRepositoryProvider.overrideWithValue(null),
          pastResultRepositoryProvider.overrideWithValue(null),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await _pumpFrames(tester);

    expect(find.text('Add current semester courses'), findsWidgets);
    expect(find.text('One course at a time'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.byTooltip('AI Assistant'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('floating mini timer appears when a session is active',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          isarProvider.overrideWith((ref) async => throw UnimplementedError()),
          cwaRepositoryProvider.overrideWithValue(null),
          pastResultRepositoryProvider.overrideWithValue(null),
          isPremiumProvider.overrideWith((ref) async => false),
          notificationPrefsProvider
              .overrideWith((ref) async => UserPrefsModel()),
          activeSessionProvider.overrideWith((ref) {
            final notifier = ActiveSessionNotifier();
            notifier.startSession(
              courseCode: 'MATH101',
              courseName: 'Engineering Maths',
              courseSource: 'manual',
            );
            return notifier;
          }),
        ],
        child: MaterialApp.router(routerConfig: appRouter),
      ),
    );

    appRouter.go('/cwa');
    await _pumpFrames(tester);

    expect(find.byType(FloatingMiniTimer), findsOneWidget);
  });
}

Future<void> _pumpFrames(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 120));
  }
}

Finder? _navigationDestinationContainer(WidgetTester tester, String label) {
  final labelFinder = find.text(label);
  if (labelFinder.evaluate().isEmpty) {
    return null;
  }
  return find.ancestor(
    of: labelFinder.first,
    matching: find.byType(AnimatedContainer),
  );
}
