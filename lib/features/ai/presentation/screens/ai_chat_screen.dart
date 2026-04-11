import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_chat_provider.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_usage_provider.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_message_bubble.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_typing_indicator.dart';
import 'package:campusiq/features/ai/presentation/widgets/usage_counter_chip.dart';
import 'package:campusiq/features/ai/presentation/widgets/premium_gate_widget.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_chat_history_drawer.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen();

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  late TextEditingController _textController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();

    // Load chat history/sessions on init
    Future.microtask(() {
      ref.read(aiChatProvider.notifier).loadSessions();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    ref.read(aiChatProvider.notifier).sendMessage(text);
    // First scroll — user message will appear immediately via state update
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final isPremiumAsync = ref.watch(isPremiumProvider);
    final usageAsync = ref.watch(aiUsageTodayProvider('chat'));

    // Scroll to bottom whenever the message list grows (user msg or AI reply)
    ref.listen<AiChatState>(aiChatProvider, (previous, next) {
      if (next.messages.length != (previous?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      endDrawer: const AiChatHistoryDrawer(),
      appBar: AppBar(
        title: Row(
          children: [
            Text('AI Coach'),
            SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'BETA',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber.shade900,
                ),
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.history),
              tooltip: 'Chat History',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chatState.messages.isEmpty
                ? Center(
                    child: Text(
                      'Start a conversation!',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: chatState.messages.length +
                        (chatState.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == chatState.messages.length) {
                        return const AiTypingIndicator();
                      }
                      return AiMessageBubble(
                        message: chatState.messages[index],
                      );
                    },
                  ),
          ),
          // Error message
          if (chatState.error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Material(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    chatState.error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                  ),
                ),
              ),
            ),
          // Premium gate or input area
          if (chatState.isAtLimit)
            const PremiumGateWidget()
          else
            Column(
              children: [
                // Usage counter (hidden for premium)
                usageAsync.when(
                  data: (used) {
                    return isPremiumAsync.when(
                      data: (isPremium) {
                        if (isPremium) return SizedBox.shrink();
                        final remaining = (3 - used).clamp(0, 3);
                        return UsageCounterChip(
                          remaining: remaining,
                          limit: 3,
                        );
                      },
                      loading: () => SizedBox.shrink(),
                      error: (_, __) => SizedBox.shrink(),
                    );
                  },
                  loading: () => SizedBox.shrink(),
                  error: (_, __) => SizedBox.shrink(),
                ),
                // Input area
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          enabled: !chatState.isLoading,
                          decoration: InputDecoration(
                            hintText: 'Ask me anything...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                          ),
                          minLines: 1,
                          maxLines: 3,
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        onPressed: chatState.isLoading ? null : _handleSend,
                        icon: Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
