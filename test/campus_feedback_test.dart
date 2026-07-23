import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/shared/widgets/campus_button.dart';
import 'package:campusiq/shared/widgets/campus_feedback.dart';
import 'package:campusiq/shared/widgets/campus_progress_panel.dart';
import 'package:campusiq/shared/widgets/import_error_recovery.dart';
import 'package:campusiq/shared/widgets/import_safety_notice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('success feedback is visible and announced', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => CampusFeedback.showSuccess(
                context,
                message: 'Course added',
              ),
              child: const Text('Save'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();

    expect(find.text('Course added'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Course added' &&
            widget.properties.liveRegion == true,
      ),
      findsOneWidget,
    );
  });

  testWidgets('operation button explains its loading state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: CampusButton(
            onPressed: () {},
            isLoading: true,
            loadingLabel: 'Saving course…',
            child: const Text('Save course'),
          ),
        ),
      ),
    );

    expect(find.text('Saving course…'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull);
  });

  testWidgets('progress panel shows meaningful progress text', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: CampusProgressPanel(
            message: 'Reading result slip…',
            detail: 'Keep this screen open while we finish.',
            progress: 0.5,
          ),
        ),
      ),
    );

    expect(find.text('Reading result slip…'), findsOneWidget);
    expect(find.text('Keep this screen open while we finish.'), findsOneWidget);
    expect(
      tester
          .widget<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .value,
      0.5,
    );
  });

  testWidgets('import safety notice explains that data is still a draft',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(body: ImportSafetyNotice()),
      ),
    );

    expect(find.textContaining('Nothing has been saved yet'), findsOneWidget);
    expect(find.textContaining('before you confirm'), findsOneWidget);
  });

  testWidgets('import error provides data status and recovery actions',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: ImportErrorRecovery(
            title: 'Your reviewed results were not saved',
            explanation: 'The local database was unavailable.',
            dataStatus:
                'Nothing new was added. Your corrections are still available.',
            nextStep: 'Return to review and try saving again.',
            onTryAgain: () {},
            onReviewAgain: () {},
            onEnterManually: () {},
          ),
        ),
      ),
    );

    expect(find.text('Your data'), findsOneWidget);
    expect(find.text('What to do next'), findsOneWidget);
    expect(find.text('Return to Review'), findsOneWidget);
    expect(find.text('Start Over'), findsOneWidget);
    expect(find.text('Enter Manually'), findsOneWidget);
  });
}
