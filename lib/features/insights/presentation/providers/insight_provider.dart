import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/insights/domain/insight.dart';
import 'package:campusiq/features/insights/domain/insight_analyser.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';

final insightsProvider = Provider<List<Insight>>((ref) {
  final sessions = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final courses = ref.watch(coursesProvider).valueOrNull ?? [];
  return InsightAnalyser(sessions: sessions, courses: courses).analyse();
});
