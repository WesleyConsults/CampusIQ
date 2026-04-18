import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/ai/data/models/ai_message_model.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_providers.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/course_hub/data/models/course_note_model.dart';
import 'package:campusiq/features/course_hub/domain/course_hub_context_builder.dart';
import 'package:campusiq/features/course_hub/data/models/course_file_model.dart';
import 'package:campusiq/features/course_hub/presentation/providers/course_file_provider.dart';
import 'package:campusiq/features/course_hub/presentation/providers/course_note_provider.dart';

class HubAiState {
  final List<AiMessageModel> messages;
  final int? currentSessionId;
  final bool isLoading;
  final String? error;
  final bool isAtLimit;
  final bool isSourceGrounded;

  const HubAiState({
    this.messages = const [],
    this.currentSessionId,
    this.isLoading = false,
    this.error,
    this.isAtLimit = false,
    this.isSourceGrounded = false,
  });

  HubAiState copyWith({
    List<AiMessageModel>? messages,
    int? currentSessionId,
    bool? isLoading,
    String? error,
    bool? isAtLimit,
    bool? isSourceGrounded,
    bool clearError = false,
  }) {
    return HubAiState(
      messages: messages ?? this.messages,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isAtLimit: isAtLimit ?? this.isAtLimit,
      isSourceGrounded: isSourceGrounded ?? this.isSourceGrounded,
    );
  }
}

class HubAiNotifier extends StateNotifier<HubAiState> {
  static const int _freeLimitPerDay = 3;
  static const String _quotaFeature = 'chat';

  final String courseCode;
  final Ref _ref;

  List<CourseFileModel> _extractableFiles = [];

  HubAiNotifier(this.courseCode, this._ref) : super(const HubAiState());

  String get _feature => 'course_$courseCode';

  List<CourseFileModel> get extractableFiles => _extractableFiles;

  void toggleSourceGrounded() {
    state = state.copyWith(isSourceGrounded: !state.isSourceGrounded);
  }

  Future<void> loadSession() async {
    try {
      final chatRepo = await _ref.read(aiChatRepositoryProvider.future);
      final sessions = await chatRepo.getSessions(_feature);
      if (sessions.isNotEmpty) {
        final session = sessions.first;
        final messages =
            await chatRepo.getMessages(_feature, sessionId: session.id);
        state = state.copyWith(
          messages: messages,
          currentSessionId: session.id,
        );
      }

      final fileRepo = _ref.read(courseFileRepositoryProvider);
      if (fileRepo != null) {
        _extractableFiles = await fileRepo.getExtractableFiles(courseCode);
      }
    } catch (_) {
      // Silent fail — start fresh
    }
  }

  Future<void> sendMessage(String userText) async {
    final isPremium = await _ref.read(isPremiumProvider.future);

    if (!isPremium) {
      final usageRepo = await _ref.read(aiUsageRepositoryProvider.future);
      final isUnder =
          await usageRepo.isUnderLimit(_quotaFeature, _freeLimitPerDay);
      if (!isUnder) {
        state = state.copyWith(isAtLimit: true);
        return;
      }
    }

    // Refresh extractable files so deleted files are excluded from context
    if (state.isSourceGrounded) {
      final fileRepo = _ref.read(courseFileRepositoryProvider);
      if (fileRepo != null) {
        _extractableFiles = await fileRepo.getExtractableFiles(courseCode);
      }
    }

    final chatRepo = await _ref.read(aiChatRepositoryProvider.future);
    int? sessionId = state.currentSessionId;

    if (sessionId == null) {
      String title = userText;
      if (title.length > 30) title = '${title.substring(0, 27)}...';
      sessionId = await chatRepo.createSession(_feature, title,
          courseCode: courseCode);
      state = state.copyWith(currentSessionId: sessionId);
    }

    final userMsg = AiMessageModel()
      ..feature = _feature
      ..sessionId = sessionId
      ..role = 'user'
      ..content = userText
      ..createdAt = DateTime.now();

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      clearError: true,
    );

    try {
      await chatRepo.saveMessage(userMsg);

      final systemPrompt = await _buildSystemPrompt();
      final lastMessages = state.messages
          .skip(_clamp(state.messages.length - 6, 0))
          .map((m) => {'role': m.role, 'content': m.content})
          .cast<Map<String, String>>()
          .toList();

      final client = await _ref.read(deepseekClientProvider.future);
      final response = await client.complete(
        systemPrompt: systemPrompt,
        messages: lastMessages,
      );

      final assistantMsg = AiMessageModel()
        ..feature = _feature
        ..sessionId = sessionId
        ..role = 'assistant'
        ..content = response
        ..createdAt = DateTime.now();

      await chatRepo.saveMessage(assistantMsg);

      if (!isPremium) {
        final usageRepo = await _ref.read(aiUsageRepositoryProvider.future);
        await usageRepo.incrementUsage(_quotaFeature);
      }

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to send message: $e');
    }
  }

  Future<String> _buildSystemPrompt() async {
    final courses = _ref.read(coursesProvider).valueOrNull ?? [];
    final course = courses.where((c) => c.code == courseCode).firstOrNull;
    final notes = _ref.read(courseNotesProvider(courseCode)).valueOrNull
        ?? <CourseNoteModel>[];

    if (state.isSourceGrounded) {
      final hasNotes = notes.isNotEmpty;
      final hasFiles = _extractableFiles.isNotEmpty;

      if (!hasNotes && !hasFiles) {
        return '__EMPTY_SOURCE_CONTEXT__';
      }

      final context = CourseHubContextBuilder().buildSourceGroundedContext(
        notes: notes,
        extractableFiles: _extractableFiles,
        course: course!,
      );

      final courseName = course.name;
      return '''You are a focused academic assistant for ${course.code} — $courseName.
Answer ONLY using the student's materials provided below.
Do NOT use general knowledge from your training.
If the answer is not found in the materials, respond with:
"I don't see this in your notes. Try switching to General mode for a broader answer."
Always mention which note title or PDF filename your answer came from.

STUDENT MATERIALS:
$context''';
    }

    final allSessions = _ref.read(allSessionsProvider).valueOrNull ?? [];
    final courseSessions =
        allSessions.where((s) => s.courseCode == courseCode).toList();
    final perCourseStreak = _ref.read(perCourseStreakProvider);
    final fallbackStreak = _ref.read(studyStreakProvider);
    final courseStreak = perCourseStreak[courseCode] ?? fallbackStreak;

    final courseName = course?.name ?? courseCode;
    String courseContext = '';
    if (course != null) {
      courseContext = '\n${CourseHubContextBuilder.build(
        course: course,
        sessions: courseSessions,
        notes: notes,
        courseStreak: courseStreak,
      )}';
    }

    return '''You are a focused academic study assistant for $courseName ($courseCode).
Help the student understand concepts, review their notes, solve problems, and prepare for exams in this subject only. Be specific and concise.$courseContext''';
  }

  int _clamp(int value, int min) => value < min ? min : value;
}

final hubAiProvider =
    StateNotifierProvider.family<HubAiNotifier, HubAiState, String>(
  (ref, courseCode) => HubAiNotifier(courseCode, ref),
);
