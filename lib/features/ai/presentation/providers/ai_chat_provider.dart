import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/ai/data/models/ai_message_model.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'ai_providers.dart';

class AiChatState {
  final List<AiMessageModel> messages;
  final bool isLoading;
  final String? error;
  final bool isAtLimit;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isAtLimit = false,
  });

  AiChatState copyWith({
    List<AiMessageModel>? messages,
    bool? isLoading,
    String? error,
    bool? isAtLimit,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isAtLimit: isAtLimit ?? this.isAtLimit,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  static const String _feature = 'chat';
  static const int _freeLimitPerDay = 3;
  final Ref ref;

  AiChatNotifier(this.ref) : super(const AiChatState());

  Future<void> loadHistory() async {
    try {
      final chatRepo = await ref.read(aiChatRepositoryProvider.future);
      final messages = await chatRepo.getMessages(_feature);
      state = state.copyWith(messages: messages);
    } catch (e) {
      // Silent fail on history load
    }
  }

  Future<void> sendMessage(String userText) async {
    // Check if user is premium
    final isPremium = await ref.read(isPremiumProvider.future);

    // Check daily limit for free users
    if (!isPremium) {
      final usageRepo = await ref.read(aiUsageRepositoryProvider.future);
      final isUnder = await usageRepo.isUnderLimit(_feature, _freeLimitPerDay);
      if (!isUnder) {
        state = state.copyWith(isAtLimit: true);
        return;
      }
    }

    // Build the user message object immediately
    final userMsg = AiMessageModel()
      ..feature = _feature
      ..role = 'user'
      ..content = userText
      ..createdAt = DateTime.now();

    // 1. Add user message to UI state RIGHT AWAY and show typing indicator
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
      error: null,
    );

    try {
      // Persist user message to Isar in the background
      final chatRepo = await ref.read(aiChatRepositoryProvider.future);
      await chatRepo.saveMessage(userMsg);

      // Build academic context
      final contextBuilder = await ref.read(contextBuilderProvider.future);
      const semesterKey = 'current'; // Placeholder — would come from prefs
      final academicContext = await contextBuilder.buildAcademicContext(semesterKey);

      // Get recent messages for context (last 6 to keep token usage low)
      final recentMessages = state.messages;
      final lastMessages = recentMessages.skip(max(0, recentMessages.length - 6)).toList();
      final messagesList = lastMessages
          .map((m) => {'role': m.role, 'content': m.content})
          .cast<Map<String, String>>()
          .toList();

      // 2. Call DeepSeek API
      final client = await ref.read(deepseekClientProvider.future);
      final response = await client.complete(
        systemPrompt: academicContext,
        messages: messagesList,
      );

      // Build assistant message
      final assistantMsg = AiMessageModel()
        ..feature = _feature
        ..role = 'assistant'
        ..content = response
        ..createdAt = DateTime.now();

      // Persist assistant message
      await chatRepo.saveMessage(assistantMsg);

      // Increment usage counter
      final usageRepo = await ref.read(aiUsageRepositoryProvider.future);
      await usageRepo.incrementUsage(_feature);

      // 3. Append assistant reply to state and clear loading
      state = state.copyWith(
        messages: [...state.messages, assistantMsg],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Failed to send message: $e');
    }
  }
}

int max(int a, int b) => a > b ? a : b;

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier(ref);
});
