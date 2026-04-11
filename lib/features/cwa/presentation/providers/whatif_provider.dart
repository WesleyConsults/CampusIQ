import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/features/ai/domain/context_builder.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_providers.dart';
import 'package:campusiq/features/ai/data/repositories/ai_usage_repository.dart';

class WhatIfState {
  final Map<String, String?> explanations; // courseId → explanation text
  final Map<String, bool> isLoading;       // courseId → loading state
  final Map<String, double> adjustedScores; // courseId → current slider value
  final String? error;

  const WhatIfState({
    this.explanations = const {},
    this.isLoading = const {},
    this.adjustedScores = const {},
    this.error,
  });

  WhatIfState copyWith({
    Map<String, String?>? explanations,
    Map<String, bool>? isLoading,
    Map<String, double>? adjustedScores,
    String? error,
    bool clearError = false,
  }) {
    return WhatIfState(
      explanations: explanations ?? this.explanations,
      isLoading: isLoading ?? this.isLoading,
      adjustedScores: adjustedScores ?? this.adjustedScores,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WhatIfNotifier extends StateNotifier<WhatIfState> {
  final Ref _ref;

  WhatIfNotifier(this._ref) : super(const WhatIfState());

  void setAdjustedScore(String courseId, double value, double savedScore) {
    final newScores = Map<String, double>.from(state.adjustedScores);
    final newExplanations = Map<String, String?>.from(state.explanations);

    if ((value - savedScore).abs() < 0.01) {
      // Slider returned to original — clear everything for this course
      newScores.remove(courseId);
      newExplanations[courseId] = null;
    } else {
      newScores[courseId] = value;
    }

    state = state.copyWith(
      adjustedScores: newScores,
      explanations: newExplanations,
    );
  }

  Future<void> explainChange(String courseId, WhatIfInput input) async {
    // Avoid re-calling if we already have an explanation for the same slider value
    final cached = state.explanations[courseId];
    final currentAdjusted = state.adjustedScores[courseId];
    if (cached != null && currentAdjusted != null &&
        (currentAdjusted - input.newScore).abs() < 0.01) {
      return;
    }

    final AiUsageRepository usageRepo;
    try {
      usageRepo = await _ref.read(aiUsageRepositoryProvider.future);
    } catch (_) {
      return;
    }

    final isPremium = await _ref.read(isPremiumProvider.future);
    final underLimit = isPremium || await usageRepo.isUnderLimit('whatif', 2);

    if (!underLimit) {
      final newExplanations = Map<String, String?>.from(state.explanations);
      newExplanations[courseId] = '__limit_reached__';
      state = state.copyWith(explanations: newExplanations, clearError: true);
      return;
    }

    // Set loading
    final newLoading = Map<String, bool>.from(state.isLoading);
    newLoading[courseId] = true;
    state = state.copyWith(isLoading: newLoading, clearError: true);

    try {
      final builder = await _ref.read(contextBuilderProvider.future);
      final prompt = await builder.buildWhatIfPrompt(input);

      final client = await _ref.read(deepseekClientProvider.future);
      final explanation = await client.complete(
        systemPrompt: prompt,
        messages: const [
          {'role': 'user', 'content': 'Explain the impact of this score change.'}
        ],
        maxTokens: 120,
      );

      await usageRepo.incrementUsage('whatif');

      final updatedExplanations = Map<String, String?>.from(state.explanations);
      updatedExplanations[courseId] = explanation;
      final updatedLoading = Map<String, bool>.from(state.isLoading);
      updatedLoading[courseId] = false;

      state = state.copyWith(
        explanations: updatedExplanations,
        isLoading: updatedLoading,
      );
    } catch (e) {
      final updatedLoading = Map<String, bool>.from(state.isLoading);
      updatedLoading[courseId] = false;
      state = state.copyWith(
        isLoading: updatedLoading,
        error: 'Could not get explanation.',
      );
    }
  }
}

final whatifProvider = StateNotifierProvider<WhatIfNotifier, WhatIfState>((ref) {
  return WhatIfNotifier(ref);
});
