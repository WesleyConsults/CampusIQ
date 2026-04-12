import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/ai/data/models/ai_message_model.dart';
import 'package:campusiq/features/ai/data/models/ai_chat_session_model.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'ai_providers.dart';

class AiChatState {
  final List<AiMessageModel> messages;
  final List<AiChatSessionModel> sessions;
  final int? currentSessionId;
  final bool isLoading;
  final String? error;
  final bool isAtLimit;

  const AiChatState({
    this.messages = const [],
    this.sessions = const [],
    this.currentSessionId,
    this.isLoading = false,
    this.error,
    this.isAtLimit = false,
  });

  AiChatState copyWith({
    List<AiMessageModel>? messages,
    List<AiChatSessionModel>? sessions,
    int? currentSessionId,
    bool? isLoading,
    String? error,
    bool? isAtLimit,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      sessions: sessions ?? this.sessions,
      currentSessionId: currentSessionId ?? this.currentSessionId,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAtLimit: isAtLimit ?? this.isAtLimit,
    );
  }

  // Helper to clear session but keep other state
  AiChatState clearSession() {
    return AiChatState(
      messages: const [],
      sessions: sessions,
      currentSessionId: null,
      isLoading: false,
      error: null,
      isAtLimit: isAtLimit,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  static const String _feature = 'chat';
  static const int _freeLimitPerDay = 3;
  final Ref ref;

  AiChatNotifier(this.ref) : super(const AiChatState());

  Future<void> loadSessions() async {
    try {
      final chatRepo = await ref.read(aiChatRepositoryProvider.future);
      final sessions = await chatRepo.getSessions(_feature);
      state = state.copyWith(sessions: sessions);
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> switchSession(int sessionId) async {
    try {
      final chatRepo = await ref.read(aiChatRepositoryProvider.future);
      final messages = await chatRepo.getMessages(_feature, sessionId: sessionId);
      state = AiChatState(
        sessions: state.sessions,
        messages: messages,
        currentSessionId: sessionId,
      );
    } catch (e) {
      // Silent fail
    }
  }

  Future<void> createNewChat() async {
    state = state.clearSession();
    await loadSessions();
  }

  Future<void> deleteSession(int sessionId) async {
    try {
      final chatRepo = await ref.read(aiChatRepositoryProvider.future);
      await chatRepo.deleteSession(sessionId);
      if (state.currentSessionId == sessionId) {
        state = state.clearSession();
      }
      await loadSessions();
    } catch (e) {
      // ignore
    }
  }

  Future<void> sendMessage(String userText) async {
    final isPremium = await ref.read(isPremiumProvider.future);

    if (!isPremium) {
      final usageRepo = await ref.read(aiUsageRepositoryProvider.future);
      final isUnder = await usageRepo.isUnderLimit(_feature, _freeLimitPerDay);
      if (!isUnder) {
        state = state.copyWith(isAtLimit: true);
        return;
      }
    }

    // 1. Assign session or create if new
    final chatRepo = await ref.read(aiChatRepositoryProvider.future);
    int? sessionId = state.currentSessionId;
    
    if (sessionId == null) {
      // Create short title from user input
      String title = userText;
      if (title.length > 30) {
        title = '${title.substring(0, 27)}...';
      }
      sessionId = await chatRepo.createSession(_feature, title);
      state = state.copyWith(currentSessionId: sessionId);
      
      // reload sessions list to show it cleanly
      final sessions = await chatRepo.getSessions(_feature);
      state = state.copyWith(sessions: sessions);
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
      error: null,
    );

    try {
      await chatRepo.saveMessage(userMsg);

      final contextBuilder = await ref.read(contextBuilderProvider.future);
      const semesterKey = 'current';
      final academicContext = await contextBuilder.buildAcademicContext(semesterKey);

      final recentMessages = state.messages;
      final lastMessages = recentMessages.skip(max(0, recentMessages.length - 6)).toList();
      final messagesList = lastMessages
          .map((m) => {'role': m.role, 'content': m.content})
          .cast<Map<String, String>>()
          .toList();

      final client = await ref.read(deepseekClientProvider.future);
      final response = await client.complete(
        systemPrompt: academicContext,
        messages: messagesList,
      );

      final assistantMsg = AiMessageModel()
        ..feature = _feature
        ..sessionId = sessionId
        ..role = 'assistant'
        ..content = response
        ..createdAt = DateTime.now();

      await chatRepo.saveMessage(assistantMsg);

      final usageRepo = await ref.read(aiUsageRepositoryProvider.future);
      await usageRepo.incrementUsage(_feature);

      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isLoading: false,
      );
      
      // refresh sessions to update list timing
      loadSessions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to send message: $e');
    }
  }

  /// Seeds the chat with coaching advice as the first assistant message so
  /// the AI has full context when the user asks a follow-up question.
  Future<void> seedWithCoachingContext(String advice) async {
    final chatRepo = await ref.read(aiChatRepositoryProvider.future);
    final sessionId = await chatRepo.createSession(_feature, 'CWA Coaching Follow-up');

    final assistantMsg = AiMessageModel()
      ..feature = _feature
      ..sessionId = sessionId
      ..role = 'assistant'
      ..content = advice
      ..createdAt = DateTime.now();

    await chatRepo.saveMessage(assistantMsg);

    final sessions = await chatRepo.getSessions(_feature);
    state = AiChatState(
      sessions: sessions,
      messages: [assistantMsg],
      currentSessionId: sessionId,
    );
  }

  // Maintained for backward compat, though `deleteSession` replaces this
  Future<void> clearChat() async {
    await createNewChat();
  }
}

int max(int a, int b) => a > b ? a : b;

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier(ref);
});
