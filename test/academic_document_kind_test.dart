import 'package:campusiq/features/cwa/domain/academic_document_kind.dart';
import 'package:campusiq/features/cwa/presentation/widgets/wrong_academic_document_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('classifies common academic document labels', () {
    expect(
      AcademicDocumentKind.fromValue('result_slip'),
      AcademicDocumentKind.resultSlip,
    );
    expect(
      AcademicDocumentKind.fromValue('course_registration'),
      AcademicDocumentKind.registrationSlip,
    );
    expect(
      AcademicDocumentKind.fromValue('unclear'),
      AcademicDocumentKind.unknown,
    );
  });

  testWidgets('wrong document warning explains and offers correction',
      (tester) async {
    var switched = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WrongAcademicDocumentView(
            detectedLabel: 'a completed result slip',
            expectedLabel: 'Current Semester Courses',
            actionLabel: 'Open Past Results',
            onSwitch: () => switched = true,
            onTryAgain: () {},
          ),
        ),
      ),
    );

    expect(
        find.text('This looks like a completed result slip'), findsOneWidget);
    expect(find.text('Open Past Results'), findsOneWidget);
    await tester.tap(find.text('Open Past Results'));
    expect(switched, isTrue);
  });
}
