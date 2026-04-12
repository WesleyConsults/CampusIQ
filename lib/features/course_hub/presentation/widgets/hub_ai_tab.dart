import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_message_bubble.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_typing_indicator.dart';
import 'package:campusiq/features/ai/presentation/widgets/usage_counter_chip.dart';
import 'package:campusiq/features/ai/presentation/widgets/premium_gate_widget.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_usage_provider.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/features/course_hub/presentation/providers/hub_ai_provider.dart';

class HubAiTab extends ConsumerStatefulWidget {
  final CourseModel course;

  const HubAiTab({super.key, required this.course});

  @override
  ConsumerState<HubAiTab> createState() => _HubAiTabState();
}

class _HubAiTabState extends ConsumerState<HubAiTab> {
  late TextEditingController _textController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _scrollController = ScrollController();
    Future.microtask(() {
      ref
          .read(hubAiProvider(widget.course.code).notifier)
          .loadSession();
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
    ref
        .read(hubAiProvider(widget.course.code).notifier)
        .sendMessage(text);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(hubAiProvider(widget.course.code));
    final isPremiumAsync = ref.watch(isPremiumProvider);
    final usageAsync = ref.watch(aiUsageTodayProvider('chat'));

    ref.listen<HubAiState>(hubAiProvider(widget.course.code),
        (previous, next) {
      if (next.messages.length !=
          (previous?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Column(
      children: [
        // Course context chip
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: Colors.indigo.shade50,
          child: Row(
            children: [
              Icon(Icons.school_outlined,
                  size: 14, color: Colors.indigo.shade600),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Focused on ${widget.course.code} — ${widget.course.name}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.indigo.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: chatState.messages.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.smart_toy_outlined,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          'Ask me about ${widget.course.name}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15, color: Colors.grey.shade600),
                        ),
                      ],
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
            padding: const EdgeInsets.all(8),
            child: Material(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  chatState.error!,
                  style: TextStyle(
                      color: Colors.red.shade700, fontSize: 12),
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
                    return UsageCounterChip(
                        remaining: remaining, limit: 3);
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
                          hintText: 'Ask about ${widget.course.code}...',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 10),
                        ),
                        minLines: 1,
                        maxLines: 3,
                        onSubmitted: (_) =>
                            chatState.isLoading ? null : _handleSend(),
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
    );
  }
}
