import 'package:campusiq/features/ai/data/models/study_plan_model.dart';
import 'package:campusiq/features/ai/data/models/study_plan_slot_model.dart';
import 'package:campusiq/features/ai/presentation/providers/study_plan_provider.dart';
import 'package:campusiq/features/ai/presentation/widgets/study_plan_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _WidgetStudyPlanNotifier extends StudyPlanNotifier {
  _WidgetStudyPlanNotifier(super.ref);

  @override
  Future<void> loadPlan() async {
    state = state.copyWith(isInitializing: false);
  }

  @override
  Future<void> generatePlan() async {
    state = state.copyWith(
      isGenerating: true,
      clearError: true,
      clearPrerequisite: true,
    );
    await Future<void>.delayed(const Duration(milliseconds: 1));

    final plan = StudyPlanModel()
      ..generatedAt = DateTime(2026, 8, 10)
      ..weekStartDate = '2026-08-10';
    final slot = StudyPlanSlotModel()
      ..day = 'Monday'
      ..courseCode = 'CS-101'
      ..courseName = 'Introduction to Computer Science'
      ..startTime = '10:00'
      ..durationMinutes = 90
      ..reason = 'Review this week\'s material';

    state = state.copyWith(
      plan: plan,
      slots: [slot],
      isInitializing: false,
      isGenerating: false,
      isGenerated: true,
    );
  }
}

void main() {
  testWidgets(
      'StudyPlanTab replaces the spinner with the generated plan after tapping generate',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          studyPlanProvider.overrideWith(_WidgetStudyPlanNotifier.new),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: StudyPlanTab(bottomContentPadding: 16),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.widgetWithText(
      ElevatedButton,
      'Generate My Study Plan',
    ));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.textContaining('Generated '), findsOneWidget);
    expect(find.text('Introduction to Computer Science'), findsOneWidget);
  });
}
