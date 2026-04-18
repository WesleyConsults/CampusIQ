import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_message_bubble.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_typing_indicator.dart';
import 'package:campusiq/features/ai/presentation/widgets/usage_counter_chip.dart';
import 'package:campusiq/features/ai/presentation/widgets/premium_gate_widget.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_usage_provider.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/features/course_hub/presentation/providers/course_note_provider.dart';
import 'package:campusiq/features/course_hub/presentation/providers/course_file_provider.dart';
import 'package:campusiq/features/course_hub/presentation/providers/hub_ai_provider.dart';

const _navyColor = Color(0xFF0A1F44);

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
    final notifier = ref.read(hubAiProvider(widget.course.code).notifier);
    final isPremiumAsync = ref.watch(isPremiumProvider);
    final usageAsync = ref.watch(aiUsageTodayProvider('chat'));

    final notesAsync = ref.watch(courseNotesProvider(widget.course.code));
    final notes = notesAsync.valueOrNull ?? [];
    final allFilesAsync = ref.watch(courseFilesProvider(widget.course.code));
    final allFiles = allFilesAsync.valueOrNull ?? [];
    final visualOnlyCount = allFiles
        .where((f) => f.fileType == 'pdf' && !f.isTextExtractable)
        .length;
    final noteCount = notes.length;
    final fileCount = notifier.extractableFiles.length;
    final isEmptyContext = noteCount == 0 && fileCount == 0;

    ref.listen<HubAiState>(hubAiProvider(widget.course.code),
        (previous, next) {
      if (next.messages.length != (previous?.messages.length ?? 0)) {
        _scrollToBottom();
      }
    });

    return Column(
      children: [
        // Mode selector chips
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: Row(
            children: [
              FilterChip(
                label: const Text('📚 From My Notes'),
                selected: chatState.isSourceGrounded,
                onSelected: (_) => notifier.toggleSourceGrounded(),
                selectedColor: _navyColor,
                labelStyle: TextStyle(
                  color: chatState.isSourceGrounded
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 13,
                ),
                showCheckmark: false,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('🌐 General'),
                selected: !chatState.isSourceGrounded,
                onSelected: (_) => notifier.toggleSourceGrounded(),
                selectedColor: _navyColor,
                labelStyle: TextStyle(
                  color: !chatState.isSourceGrounded
                      ? Colors.white
                      : Colors.black87,
                  fontSize: 13,
                ),
                showCheckmark: false,
              ),
            ],
          ),
        ),

        // Source summary strip
        if (chatState.isSourceGrounded && !isEmptyContext)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Text(
              'Reading: $noteCount notes · $fileCount PDFs indexed'
              '${visualOnlyCount > 0 ? ' ($visualOnlyCount visual only — not included)' : ''}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),

        // Empty state when grounded but no materials
        if (chatState.isSourceGrounded && isEmptyContext)
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.folder_open_outlined,
                        size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    const Text(
                      'No indexed materials for this course yet.',
                      style: TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add notes in the Notes tab, or attach a text-based PDF in the Files tab. Then come back here.',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
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
                            chatState.isSourceGrounded
                                ? 'Ask me about your notes for ${widget.course.name}'
                                : 'Ask me about ${widget.course.name}',
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
                          message: chatState.messages[index]);
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
                    style:
                        TextStyle(color: Colors.red.shade700, fontSize: 12),
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
                            hintText: chatState.isSourceGrounded
                                ? 'Ask about your notes...'
                                : 'Ask about ${widget.course.code}...',
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
                        onPressed:
                            chatState.isLoading ? null : _handleSend,
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
