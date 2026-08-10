import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';
import 'package:campusiq/core/providers/connectivity_provider.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/features/ai/data/models/study_plan_model.dart';
import 'package:campusiq/features/ai/data/models/study_plan_slot_model.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_providers.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';

class StudyPlanState {
  final StudyPlanModel? plan;
  final List<StudyPlanSlotModel> slots;
  final bool isInitializing;
  final bool isGenerating;
  final bool isTakingLong;
  final String? error;
  final String? prerequisiteMessage;
  final bool isGenerated;

  const StudyPlanState({
    this.plan,
    this.slots = const [],
    this.isInitializing = true,
    this.isGenerating = false,
    this.isTakingLong = false,
    this.error,
    this.prerequisiteMessage,
    this.isGenerated = false,
  });

  bool get isLoading => isInitializing || isGenerating;

  StudyPlanState copyWith({
    StudyPlanModel? plan,
    List<StudyPlanSlotModel>? slots,
    bool? isInitializing,
    bool? isGenerating,
    bool? isTakingLong,
    String? error,
    bool clearError = false,
    String? prerequisiteMessage,
    bool clearPrerequisite = false,
    bool? isGenerated,
  }) {
    return StudyPlanState(
      plan: plan ?? this.plan,
      slots: slots ?? this.slots,
      isInitializing: isInitializing ?? this.isInitializing,
      isGenerating: isGenerating ?? this.isGenerating,
      isTakingLong: isTakingLong ?? this.isTakingLong,
      error: clearError ? null : (error ?? this.error),
      prerequisiteMessage: clearPrerequisite
          ? null
          : (prerequisiteMessage ?? this.prerequisiteMessage),
      isGenerated: isGenerated ?? this.isGenerated,
    );
  }
}

class StudyPlanNotifier extends StateNotifier<StudyPlanState> {
  final Ref _ref;
  Timer? _slowGenerationTimer;
  int _generationId = 0;

  StudyPlanNotifier(this._ref) : super(const StudyPlanState()) {
    loadPlan();
  }

  Future<Isar> get _isar => _ref.read(isarProvider.future);

  Future<void> loadPlan() async {
    try {
      final isar = await _isar;
      final plan = await isar.studyPlanModels.get(1);
      if (plan == null) {
        state = state.copyWith(
          isInitializing: false,
          isGenerated: false,
          slots: [],
        );
        return;
      }
      await plan.slots.load();
      final slots = plan.slots.toList()
        ..sort((a, b) {
          const order = [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday',
            'Sunday'
          ];
          final di = order.indexOf(a.day).compareTo(order.indexOf(b.day));
          if (di != 0) return di;
          return a.startTime.compareTo(b.startTime);
        });
      state = state.copyWith(
        plan: plan,
        slots: slots,
        isInitializing: false,
        isGenerated: true,
        clearError: true,
      );
    } catch (e, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'study_plan_load_failed',
      );
      state = state.copyWith(
        isInitializing: false,
        error: 'Failed to load study plan.',
      );
    }
  }

  Future<void> generatePlan() async {
    final generationId = ++_generationId;
    _slowGenerationTimer?.cancel();
    state = state.copyWith(
      isGenerating: true,
      isTakingLong: false,
      clearError: true,
      clearPrerequisite: true,
    );
    _slowGenerationTimer = Timer(const Duration(seconds: 12), () {
      if (generationId == _generationId && state.isGenerating) {
        state = state.copyWith(isTakingLong: true);
      }
    });
    final totalTimer = Stopwatch()..start();

    try {
      final isOnline = await _ref.read(isOnlineProvider.future);
      if (generationId != _generationId) return;
      if (!isOnline) {
        await AnalyticsService.instance.logAiGenerationFailed(
          feature: 'ai_study_plan',
          reason: 'offline',
        );
        state = state.copyWith(
          isGenerating: false,
          isTakingLong: false,
          error: "You're offline. Connect to use features.",
        );
        return;
      }

      final isar = await _isar;
      if (generationId != _generationId) return;
      final courses = await isar.courseModels.where().findAll();
      final timetableSlots = await isar.timetableSlotModels.where().findAll();
      if (generationId != _generationId) return;
      if (courses.isEmpty && timetableSlots.isEmpty) {
        state = state.copyWith(
          isGenerating: false,
          isTakingLong: false,
          clearError: true,
          prerequisiteMessage:
              'Add at least one course or timetable class before generating a study plan.',
        );
        return;
      }

      final promptTimer = Stopwatch()..start();
      final builder = await _ref.read(contextBuilderProvider.future);
      final prompt = await builder.buildStudyPlanPrompt();
      promptTimer.stop();
      if (generationId != _generationId) return;

      final client = await _ref.read(deepseekClientProvider.future);
      final apiTimer = Stopwatch()..start();
      final response = await client.complete(
        systemPrompt: prompt,
        messages: const [
          {'role': 'user', 'content': 'Generate my study plan.'}
        ],
        maxTokens: 1000,
      );
      apiTimer.stop();
      if (generationId != _generationId) return;

      final parsedSlots = _parseSlots(response);

      final knownCodes = <String>{};
      final codeToName = <String, String?>{};

      for (final c in courses) {
        knownCodes.add(c.code);
        if (c.name.trim().isNotEmpty) {
          codeToName[c.code] = c.name.trim();
        }
      }

      for (final s in timetableSlots) {
        knownCodes.add(s.courseCode);
        if (s.courseName.trim().isNotEmpty) {
          if (!codeToName.containsKey(s.courseCode) ||
              codeToName[s.courseCode] == null) {
            codeToName[s.courseCode] = s.courseName.trim();
          }
        }
      }

      final newSlots = <StudyPlanSlotModel>[];
      for (final slot in parsedSlots) {
        final code = slot.courseCode.trim();
        final name = slot.courseName.trim();

        if (knownCodes.contains(code)) {
          final exactName = codeToName[code];
          slot.courseCode = code;
          slot.courseName =
              exactName != null && exactName.isNotEmpty ? exactName : code;
          newSlots.add(slot);
        } else {
          final closestCode = _findClosestKnownCourseCode(
              code.isNotEmpty ? code : name, knownCodes.toList());
          if (closestCode != null) {
            final exactName = codeToName[closestCode];
            slot.courseCode = closestCode;
            slot.courseName = exactName != null && exactName.isNotEmpty
                ? exactName
                : closestCode;
            newSlots.add(slot);
          } else {
            // Fallback to a safe generic study task without invented course label
            slot.courseCode = 'STUDY';
            slot.courseName = 'Study Session';
            newSlots.add(slot);
          }
        }
      }

      final saveTimer = Stopwatch()..start();
      await isar.writeTxn(() async {
        // Delete all existing slots
        await isar.studyPlanSlotModels.clear();

        // Write new slots
        await isar.studyPlanSlotModels.putAll(newSlots);

        // Write/replace plan header (id = 1)
        final now = DateTime.now();
        final monday = now.subtract(Duration(days: now.weekday - 1));
        final weekStartDate =
            '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';

        final plan = StudyPlanModel()
          ..generatedAt = now
          ..weekStartDate = weekStartDate;
        await isar.studyPlanModels.put(plan);

        // Link slots
        final saved = await isar.studyPlanModels.get(1);
        if (saved != null) {
          saved.slots.addAll(newSlots);
          await saved.slots.save();
        }
      });
      saveTimer.stop();
      if (generationId != _generationId) return;

      await loadPlan();
      if (generationId != _generationId) return;
      state = state.copyWith(
        isGenerating: false,
        isTakingLong: false,
      );
      totalTimer.stop();
      unawaited(AnalyticsService.instance.logAiGenerationSucceeded(
        feature: 'ai_study_plan',
        itemCount: newSlots.length,
      ));
      unawaited(AnalyticsService.instance.logEvent(
        'ai_study_plan_timing',
        parameters: {
          'outcome': 'success',
          'prompt_ms': promptTimer.elapsedMilliseconds,
          'api_ms': apiTimer.elapsedMilliseconds,
          'save_ms': saveTimer.elapsedMilliseconds,
          'total_ms': totalTimer.elapsedMilliseconds,
          'item_count': newSlots.length,
        },
      ));
    } catch (e, stackTrace) {
      if (generationId != _generationId) return;
      totalTimer.stop();
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'study_plan_generate_failed',
      );
      await AnalyticsService.instance.logAiGenerationFailed(
        feature: 'ai_study_plan',
        reason: _aiFailureReason(e),
      );
      state = state.copyWith(
        isGenerating: false,
        isTakingLong: false,
        error:
            'Could not generate plan. ${e.toString().contains('JSON') ? 'AI returned unexpected format — try again.' : 'Check your connection and try again.'}',
      );
      unawaited(AnalyticsService.instance.logEvent(
        'ai_study_plan_timing',
        parameters: {
          'outcome': 'failed',
          'total_ms': totalTimer.elapsedMilliseconds,
        },
      ));
    } finally {
      if (generationId == _generationId) {
        _slowGenerationTimer?.cancel();
        _slowGenerationTimer = null;
      }
    }
  }

  void cancelGeneration() {
    if (!state.isGenerating) return;
    _generationId++;
    _slowGenerationTimer?.cancel();
    _slowGenerationTimer = null;
    state = state.copyWith(
      isGenerating: false,
      isTakingLong: false,
      clearError: true,
    );
    unawaited(AnalyticsService.instance.logEvent(
      'ai_study_plan_cancelled',
    ));
  }

  @override
  void dispose() {
    _slowGenerationTimer?.cancel();
    super.dispose();
  }

  String _aiFailureReason(Object error) {
    final message = error.toString();
    if (message.contains('JSON') || message.contains('FormatException')) {
      return 'invalid_ai_response';
    }
    return 'request_failed';
  }

  List<StudyPlanSlotModel> _parseSlots(String jsonString) {
    // Strip markdown code fences if AI wraps in ```json ... ```
    final cleaned = jsonString
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();
    final list = jsonDecode(cleaned) as List;
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return StudyPlanSlotModel()
        ..day = map['day'] as String
        ..courseCode = map['courseCode'] as String
        ..courseName = map['courseName'] as String
        ..startTime = map['startTime'] as String
        ..durationMinutes = map['durationMinutes'] as int
        ..reason = map['reason'] as String;
    }).toList();
  }

  String? _findClosestKnownCourseCode(String query, List<String> knownCodes) {
    if (knownCodes.isEmpty) return null;

    // 1. Prefer exact string match first
    if (knownCodes.contains(query)) {
      return query;
    }

    String clean(String s) =>
        s.replaceAll(RegExp(r'[\s\-]+'), '').toUpperCase();
    final cleanQuery = clean(query);
    if (cleanQuery.isEmpty) return null;

    // 2. Exact clean match (ignoring spaces/hyphens)
    final cleanMatches =
        knownCodes.where((code) => clean(code) == cleanQuery).toList();
    if (cleanMatches.length == 1) {
      return cleanMatches.first;
    } else if (cleanMatches.length > 1) {
      // Ambiguous clean matches, do not guess
      return null;
    }

    // 3. Fuzzy matches (Levenshtein distance <= 1 on clean strings)
    final fuzzyCandidates = <String>[];
    int minDistance = 999;
    for (final code in knownCodes) {
      final dist = _levenshtein(cleanQuery, clean(code));
      if (dist <= 1) {
        if (dist < minDistance) {
          minDistance = dist;
          fuzzyCandidates.clear();
          fuzzyCandidates.add(code);
        } else if (dist == minDistance) {
          fuzzyCandidates.add(code);
        }
      }
    }

    if (fuzzyCandidates.length == 1) {
      return fuzzyCandidates.first;
    }

    return null;
  }

  int _levenshtein(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);

    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }

    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;

      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = _min(v1[j] + 1, _min(v0[j + 1] + 1, v0[j] + cost));
      }

      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }

    return v0[t.length];
  }

  int _min(int a, int b) => a < b ? a : b;
}

final studyPlanProvider =
    StateNotifierProvider<StudyPlanNotifier, StudyPlanState>((ref) {
  return StudyPlanNotifier(ref);
});
