import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashReportingService {
  CrashReportingService._();

  static final CrashReportingService instance = CrashReportingService._();

  FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  Future<void> recordFlutterFatalError(FlutterErrorDetails details) async {
    await _guard(
      () => _crashlytics.recordFlutterFatalError(details),
      'recordFlutterFatalError',
    );
  }

  Future<void> recordFatalError(
    Object error,
    StackTrace stackTrace, {
    String? reason,
  }) async {
    await _recordError(
      error,
      stackTrace,
      fatal: true,
      reason: reason,
    );
  }

  Future<void> recordNonFatalError(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    Map<String, Object?> context = const {},
  }) async {
    for (final entry in context.entries) {
      await setCustomKey(entry.key, entry.value);
    }
    await _recordError(
      error,
      stackTrace,
      fatal: false,
      reason: reason,
    );
  }

  Future<void> setCustomKey(String key, Object? value) async {
    await _guard(
      () => _crashlytics.setCustomKey(key, value?.toString() ?? 'null'),
      'setCustomKey:$key',
    );
  }

  Future<void> _recordError(
    Object error,
    StackTrace stackTrace, {
    required bool fatal,
    String? reason,
  }) async {
    await _guard(
      () => _crashlytics.recordError(
        error,
        stackTrace,
        fatal: fatal,
        reason: reason,
      ),
      fatal ? 'recordFatalError' : 'recordNonFatalError',
    );
  }

  Future<void> _guard(
    Future<void> Function() action,
    String label,
  ) async {
    try {
      if (Firebase.apps.isEmpty) return;
      await action();
    } catch (error) {
      debugPrint('CrashReportingService $label failed: $error');
    }
  }
}
