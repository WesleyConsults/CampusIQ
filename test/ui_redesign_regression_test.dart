import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/core/router/app_router.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_manual_entry_screen.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_screen.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
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
    expect(find.byTooltip('AI Assistant'), findsOneWidget);

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
        ],
        child: const MaterialApp(home: CwaScreen()),
      ),
    );

    await _pumpFrames(tester);

    await tester.tap(find.widgetWithText(TextButton, 'Import').first);
    await _pumpFrames(tester);

    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Upload Image'), findsOneWidget);
    expect(find.text('Choose PDF'), findsOneWidget);
    expect(find.text('Enter Manually'), findsOneWidget);
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

    expect(find.text('Enter Courses Manually'), findsOneWidget);
    expect(find.text('Save Courses'), findsOneWidget);
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

    expect(find.text('MATH101'), findsOneWidget);
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
