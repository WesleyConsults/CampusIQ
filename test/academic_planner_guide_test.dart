import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_screen.dart';
import 'package:campusiq/features/cwa/presentation/widgets/course_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('planner setup teaches courses, target, and projection',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

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

    await tester.pump();
    await tester.pump();

    expect(find.text('Add your current courses'), findsOneWidget);
    expect(find.text('Confirm your target'), findsOneWidget);
    expect(find.text('Try a projected score'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    expect(
      find.text('Explore the planner without the guide'),
      findsOneWidget,
    );
  });

  testWidgets('dashboard explains the active calculation', (tester) async {
    final course = CourseModel.create(
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
          coursesProvider.overrideWith((ref) => Stream.value([course])),
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
          cwaSetupTargetConfirmedProvider
              .overrideWith((ref) => Stream.value(true)),
        ],
        child: const MaterialApp(home: CwaScreen()),
      ),
    );

    await tester.pump();
    await tester.pump();

    expect(find.text('Academic view'), findsOneWidget);
    expect(find.text('How is this calculated?'), findsOneWidget);

    await tester.tap(find.text('How is this calculated?'));
    await tester.pumpAndSettle();

    expect(find.text('How CWA is calculated'), findsOneWidget);
    expect(find.textContaining('MATH101: 72.00 × 3 credits'), findsOneWidget);
    expect(find.textContaining('Courses with more credits'), findsOneWidget);
  });

  testWidgets('course adjustment previews and commits a projected score',
      (tester) async {
    final course = CourseModel.create(
      name: 'Engineering Mathematics',
      code: 'MATH101',
      creditHours: 3,
      expectedScore: 70,
      semesterKey: '2026-Sem1',
    );
    double? previewed;
    double? committed;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CourseCard(
            course: course,
            gradingSystem: GradingSystem.cwa,
            isHighImpact: true,
            onEdit: () {},
            onDelete: () {},
            onScoreChanged: (value) => previewed = value,
            onDragEnd: (value) => committed = value,
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Adjust score'));
    await tester.pumpAndSettle();
    await tester.drag(find.byType(Slider), const Offset(80, 0));
    await tester.pump();

    expect(previewed, isNotNull);
    expect(committed, isNotNull);
    expect(previewed, committed);
  });

  test('new planner preferences default to a non-intrusive first run', () {
    final prefs = UserPrefsModel();
    expect(prefs.hasSeenAcademicPlannerIntro, isFalse);
    expect(prefs.hasAdjustedAcademicProjection, isFalse);
    expect(prefs.hasDismissedAcademicPlannerGuide, isFalse);
  });
}
