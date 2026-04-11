import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_chat_provider.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_usage_provider.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_message_bubble.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_typing_indicator.dart';
import 'package:campusiq/features/ai/presentation/widgets/usage_counter_chip.dart';
import 'package:campusiq/features/ai/presentation/widgets/premium_gate_widget.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_chat_history_drawer.dart';
import 'package:campusiq/features/ai/presentation/widgets/weekly_review_banner.dart';

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
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final isPremiumAsync = ref.watch(isPremiumProvider);
    final usageAsync = ref.watch(aiUsageTodayProvider('chat'));

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
            const Text('AI Coach'),
            const SizedBox(width: 8),
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
          const WeeklyReviewBanner(),
          const _ExamPrepCard(),
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
          if (chatState.isAtLimit)
            const PremiumGateWidget()
          else
            Column(
              children: [
                usageAsync.when(
                  data: (used) => isPremiumAsync.when(
                    data: (isPremium) {
                      if (isPremium) return const SizedBox.shrink();
                      final remaining = (3 - used).clamp(0, 3);
                      return UsageCounterChip(remaining: remaining, limit: 3);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
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
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: chatState.isLoading ? null : _handleSend,
                        icon: const Icon(Icons.send),
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

// ── Exam Prep feature card ────────────────────────────────────────────────────

class _ExamPrepCard extends StatelessWidget {
  const _ExamPrepCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/ai/exam-prep'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.indigo.shade100),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.indigo.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.quiz_outlined,
                  size: 18, color: Colors.indigo.shade700),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Exam Prep',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.indigo.shade800,
                    ),
                  ),
                  Text(
                    'Generate practice questions for any course',
                    style: TextStyle(
                        fontSize: 11, color: Colors.indigo.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.indigo.shade400),
          ],
        ),
      ),
    );
  }
}
