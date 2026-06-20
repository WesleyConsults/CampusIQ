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

class StudyPlanState {
  final StudyPlanModel? plan;
  final List<StudyPlanSlotModel> slots;
  final bool isLoading;
  final String? error;
  final bool isGenerated;

  const StudyPlanState({
    this.plan,
    this.slots = const [],
    this.isLoading = false,
    this.error,
    this.isGenerated = false,
  });

  StudyPlanState copyWith({
    StudyPlanModel? plan,
    List<StudyPlanSlotModel>? slots,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? isGenerated,
  }) {
    return StudyPlanState(
      plan: plan ?? this.plan,
      slots: slots ?? this.slots,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isGenerated: isGenerated ?? this.isGenerated,
    );
  }
}

class StudyPlanNotifier extends StateNotifier<StudyPlanState> {
  final Ref _ref;

  StudyPlanNotifier(this._ref) : super(const StudyPlanState()) {
    loadPlan();
  }

  Future<Isar> get _isar => _ref.read(isarProvider.future);

  Future<void> loadPlan() async {
    try {
      final isar = await _isar;
      final plan = await isar.studyPlanModels.get(1);
      if (plan == null) {
        state = state.copyWith(isGenerated: false, slots: []);
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
          plan: plan, slots: slots, isGenerated: true, clearError: true);
    } catch (e, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'study_plan_load_failed',
      );
      state = state.copyWith(error: 'Failed to load study plan.');
    }
  }

  Future<void> generatePlan() async {
    final isOnline = await _ref.read(isOnlineProvider.future);
    if (!isOnline) {
      await AnalyticsService.instance.logAiGenerationFailed(
        feature: 'ai_study_plan',
        reason: 'offline',
      );
      state = state.copyWith(
        isLoading: false,
        error: "You're offline. Connect to use features.",
      );
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final builder = await _ref.read(contextBuilderProvider.future);
      final prompt = await builder.buildStudyPlanPrompt();

      final client = await _ref.read(deepseekClientProvider.future);
      final response = await client.complete(
        systemPrompt: prompt,
        messages: const [
          {'role': 'user', 'content': 'Generate my study plan.'}
        ],
        maxTokens: 1000,
      );

      final newSlots = _parseSlots(response);

      final isar = await _isar;
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

      await loadPlan();
      await AnalyticsService.instance.logAiGenerationSucceeded(
        feature: 'ai_study_plan',
        itemCount: newSlots.length,
      );
    } catch (e, stackTrace) {
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
        isLoading: false,
        error:
            'Could not generate plan. ${e.toString().contains('JSON') ? 'AI returned unexpected format — try again.' : 'Check your connection and try again.'}',
      );
    }
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
}

final studyPlanProvider =
    StateNotifierProvider<StudyPlanNotifier, StudyPlanState>((ref) {
  return StudyPlanNotifier(ref);
});
