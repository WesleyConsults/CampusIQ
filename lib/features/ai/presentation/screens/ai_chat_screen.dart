import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
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
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/features/ai/domain/notification_scheduler.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

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
      _maybeShowNotificationPermissionDialog();
    });
  }

  Future<void> _maybeShowNotificationPermissionDialog() async {
    final prefsRepo = ref.read(userPrefsRepositoryProvider);
    if (prefsRepo == null) return;

    final prefs = await prefsRepo.getPrefs();
    if (prefs.notificationPermissionAsked) return;

    // Mark as asked immediately so we never show again
    await prefsRepo.setNotificationPermissionAsked(true);

    if (!mounted) return;

    final allowed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.notifications_outlined, size: AppIconSizes.status),
        title: const Text('Stay on track with CampusIQ',
            textAlign: TextAlign.center),
        content: const Text(
          "We'll remind you when your streak is at risk, "
          "when you have a free study block, and when your "
          "weekly review is ready.",
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.spaceEvenly,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Allow notifications →'),
          ),
        ],
      ),
    );

    if (allowed == true) {
      await NotificationService.instance.requestPermission();
      await NotificationScheduler.scheduleStreakRiskCheck();
    }
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
            const SizedBox(width: AppSpacing.xs),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(AppRadii.xs),
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
                  padding: const EdgeInsets.all(AppSpacing.sm),
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
                              borderRadius: BorderRadius.circular(AppSpacing.xs),
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
                      const SizedBox(width: AppSpacing.xs),
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
