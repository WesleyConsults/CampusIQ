import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/connectivity_provider.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/ai/data/models/weekly_review_model.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_providers.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

class WeeklyReviewState {
  final WeeklyReviewModel? review;
  final bool isLoading;
  final String? error;
  final bool hasReviewThisWeek;
  final bool hasViewedReview;

  const WeeklyReviewState({
    this.review,
    this.isLoading = false,
    this.error,
    this.hasReviewThisWeek = false,
    this.hasViewedReview = false,
  });

  WeeklyReviewState copyWith({
    WeeklyReviewModel? review,
    bool? isLoading,
    String? error,
    bool clearError = false,
    bool? hasReviewThisWeek,
    bool? hasViewedReview,
  }) {
    return WeeklyReviewState(
      review: review ?? this.review,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      hasReviewThisWeek: hasReviewThisWeek ?? this.hasReviewThisWeek,
      hasViewedReview: hasViewedReview ?? this.hasViewedReview,
    );
  }
}

String currentMondayDate() {
  final now = DateTime.now();
  final monday = now.subtract(Duration(days: now.weekday - 1));
  return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
}

class WeeklyReviewNotifier extends StateNotifier<WeeklyReviewState> {
  final Ref _ref;

  WeeklyReviewNotifier(this._ref) : super(const WeeklyReviewState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final mondayDate = currentMondayDate();
      final isar = await _ref.read(isarProvider.future);

      final existing =
          await isar.weeklyReviewModels.getByWeekStartDate(mondayDate);

      if (existing != null) {
        final userPrefsRepo = _ref.read(userPrefsRepositoryProvider);
        final prefs = await userPrefsRepo?.getPrefs();
        final viewed = prefs?.lastReviewShownWeek == mondayDate;

        state = state.copyWith(
          review: existing,
          hasReviewThisWeek: true,
          hasViewedReview: viewed,
        );
        return;
      }

      await _generateReview();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not load weekly review.',
      );
    }
  }

  Future<void> _generateReview() async {
    final isOnline = await _ref.read(isOnlineProvider.future);
    if (!isOnline) {
      state = state.copyWith(
        isLoading: false,
        error: 'You are offline. AI features require a connection.',
      );
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final builder = await _ref.read(contextBuilderProvider.future);
      final prompt = await builder.buildWeeklyReviewPrompt();

      final client = await _ref.read(deepseekClientProvider.future);
      final response = await client.complete(
        systemPrompt: prompt,
        messages: const [
          {'role': 'user', 'content': 'Write my weekly review.'}
        ],
        maxTokens: 500,
      );

      final review = _parseReview(response);
      review.weekStartDate = currentMondayDate();
      review.generatedAt = DateTime.now();

      final isar = await _ref.read(isarProvider.future);
      await isar.writeTxn(() => isar.weeklyReviewModels.put(review));

      state = state.copyWith(
        review: review,
        isLoading: false,
        hasReviewThisWeek: true,
        hasViewedReview: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Could not generate your weekly review. Try again later.',
      );
    }
  }

  Future<void> markViewed() async {
    final mondayDate = currentMondayDate();
    final userPrefsRepo = _ref.read(userPrefsRepositoryProvider);
    await userPrefsRepo?.setLastReviewShownWeek(mondayDate);
    state = state.copyWith(hasViewedReview: true);
  }

  WeeklyReviewModel _parseReview(String jsonString) {
    final cleaned = jsonString
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();
    final map = jsonDecode(cleaned) as Map<String, dynamic>;
    return WeeklyReviewModel()
      ..summaryText = map['summary'] as String
      ..wellText = map['well'] as String
      ..watchText = map['watch'] as String
      ..focusText = map['focus'] as String;
  }
}

final weeklyReviewProvider =
    StateNotifierProvider<WeeklyReviewNotifier, WeeklyReviewState>((ref) {
  return WeeklyReviewNotifier(ref);
});
