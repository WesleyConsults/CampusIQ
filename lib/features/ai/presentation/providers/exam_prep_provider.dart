import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/ai/domain/exam_prep_models.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_providers.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';

// Free users: 1 exam prep generation per day (shared 'chat' pool)
const _freeLimit = 1;
const _feature = 'exam_prep';

class ExamPrepState {
  final String? selectedCourseId;
  final String? selectedCourseCode;
  final String? selectedCourseName;
  final String questionType; // 'mcq' | 'short' | 'flash'
  final String topic;
  final List<ExamQuestion> questions;
  final Map<int, bool> revealed;
  final Map<int, String?> selectedAnswer;
  final bool isLoading;
  final String? error;
  final bool isAtLimit;

  const ExamPrepState({
    this.selectedCourseId,
    this.selectedCourseCode,
    this.selectedCourseName,
    this.questionType = 'mcq',
    this.topic = '',
    this.questions = const [],
    this.revealed = const {},
    this.selectedAnswer = const {},
    this.isLoading = false,
    this.error,
    this.isAtLimit = false,
  });

  ExamPrepState copyWith({
    String? selectedCourseId,
    String? selectedCourseCode,
    String? selectedCourseName,
    String? questionType,
    String? topic,
    List<ExamQuestion>? questions,
    Map<int, bool>? revealed,
    Map<int, String?>? selectedAnswer,
    bool? isLoading,
    String? error,
    bool? isAtLimit,
    bool clearError = false,
    bool clearCourse = false,
  }) {
    return ExamPrepState(
      selectedCourseId: clearCourse ? null : (selectedCourseId ?? this.selectedCourseId),
      selectedCourseCode: clearCourse ? null : (selectedCourseCode ?? this.selectedCourseCode),
      selectedCourseName: clearCourse ? null : (selectedCourseName ?? this.selectedCourseName),
      questionType: questionType ?? this.questionType,
      topic: topic ?? this.topic,
      questions: questions ?? this.questions,
      revealed: revealed ?? this.revealed,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAtLimit: isAtLimit ?? this.isAtLimit,
    );
  }
}

class ExamPrepNotifier extends StateNotifier<ExamPrepState> {
  final Ref _ref;

  ExamPrepNotifier(this._ref) : super(const ExamPrepState());

  void selectCourse(String id, String code, String name) {
    state = state.copyWith(
      selectedCourseId: id,
      selectedCourseCode: code,
      selectedCourseName: name,
      clearError: true,
    );
  }

  void setQuestionType(String type) {
    state = state.copyWith(questionType: type, clearError: true);
  }

  void setTopic(String topic) {
    state = state.copyWith(topic: topic);
  }

  Future<void> generate() async {
    if (state.selectedCourseCode == null) {
      state = state.copyWith(error: 'Please select a course first.');
      return;
    }

    // Check quota
    final isPremium = await _ref.read(isPremiumProvider.future);
    if (!isPremium) {
      final usageRepo = await _ref.read(aiUsageRepositoryProvider.future);
      final underLimit = await usageRepo.isUnderLimit(_feature, _freeLimit);
      if (!underLimit) {
        state = state.copyWith(isAtLimit: true);
        return;
      }
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final client = await _ref.read(deepseekClientProvider.future);
      final prompt = _buildPrompt();

      final raw = await client.complete(
        systemPrompt: 'You are an exam preparation assistant for university students.',
        messages: [{'role': 'user', 'content': prompt}],
        maxTokens: 1500,
      );

      final newQuestions = _parseQuestions(raw);

      final updatedRevealed = Map<int, bool>.from(state.revealed);
      final updatedSelected = Map<int, String?>.from(state.selectedAnswer);

      state = state.copyWith(
        questions: [...state.questions, ...newQuestions],
        revealed: updatedRevealed,
        selectedAnswer: updatedSelected,
        isLoading: false,
      );

      // Increment usage for free users
      if (!isPremium) {
        final usageRepo = await _ref.read(aiUsageRepositoryProvider.future);
        await usageRepo.incrementUsage(_feature);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to generate questions. Please try again.',
      );
    }
  }

  void revealAnswer(int index) {
    final updated = Map<int, bool>.from(state.revealed);
    updated[index] = true;
    state = state.copyWith(revealed: updated);
  }

  void selectMcqOption(int index, String option) {
    final updatedSelected = Map<int, String?>.from(state.selectedAnswer);
    updatedSelected[index] = option;
    final updatedRevealed = Map<int, bool>.from(state.revealed);
    updatedRevealed[index] = true;
    state = state.copyWith(
      selectedAnswer: updatedSelected,
      revealed: updatedRevealed,
    );
  }

  void clearQuestions() {
    state = state.copyWith(
      questions: [],
      revealed: {},
      selectedAnswer: {},
      isAtLimit: false,
      clearError: true,
    );
  }

  String _buildPrompt() {
    final type = state.questionType;
    final code = state.selectedCourseCode!;
    final name = state.selectedCourseName!;
    final topic = state.topic.trim();

    final typeLabel = switch (type) {
      'mcq' => 'multiple choice (MCQ)',
      'short' => 'short answer',
      'flash' => 'flash card',
      _ => 'multiple choice (MCQ)',
    };

    final topicLine = topic.isNotEmpty
        ? 'Topic focus: $topic'
        : 'Cover general/important concepts in this course';

    final formatSpec = switch (type) {
      'mcq' =>
        '{"type": "mcq", "question": "...", "options": ["A. ...", "B. ...", "C. ...", "D. ..."], "answer": "A", "explanation": "..."}',
      'short' => '{"type": "short", "question": "...", "answer": "..."}',
      'flash' => '{"type": "flash", "front": "...", "back": "..."}',
      _ =>
        '{"type": "mcq", "question": "...", "options": ["A. ...", "B. ...", "C. ...", "D. ..."], "answer": "A", "explanation": "..."}',
    };

    return '''Generate 5 $typeLabel exam practice questions for a university student.
Course: $name ($code)
$topicLine

Return ONLY a JSON array. No text before or after.

Each item must follow this format:
$formatSpec

Questions should be exam-level difficulty, specific, and test real understanding.''';
  }

  List<ExamQuestion> _parseQuestions(String raw) {
    // Strip markdown code fences if present
    final cleaned = raw
        .replaceAll(RegExp(r'```json\s*'), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    final list = jsonDecode(cleaned) as List;
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return switch (map['type'] as String) {
        'mcq' => McqQuestion(
            question: map['question'] as String,
            options: List<String>.from(map['options'] as List),
            answer: map['answer'] as String,
            explanation: map['explanation'] as String,
          ),
        'short' => ShortAnswerQuestion(
            question: map['question'] as String,
            answer: map['answer'] as String,
          ),
        'flash' => FlashCard(
            front: map['front'] as String,
            back: map['back'] as String,
          ),
        _ => throw FormatException('Unknown question type: ${map['type']}'),
      };
    }).toList();
  }
}

final examPrepProvider =
    StateNotifierProvider<ExamPrepNotifier, ExamPrepState>(
  (ref) => ExamPrepNotifier(ref),
);
