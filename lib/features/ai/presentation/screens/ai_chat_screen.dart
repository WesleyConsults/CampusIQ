import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/core/services/notification_service.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/ai/domain/notification_scheduler.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_chat_provider.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_usage_provider.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_chat_history_drawer.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_message_bubble.dart';
import 'package:campusiq/features/ai/presentation/widgets/ai_typing_indicator.dart';
import 'package:campusiq/features/ai/presentation/widgets/premium_gate_widget.dart';
import 'package:campusiq/features/ai/presentation/widgets/usage_counter_chip.dart';
import 'package:campusiq/features/ai/presentation/widgets/weekly_review_banner.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  static const _starterPrompts = <String>[
    'Explain this topic',
    'Make practice questions',
    'Plan my revision',
    'Summarize my notes',
  ];

  late final TextEditingController _textController;
  late final ScrollController _scrollController;

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

    await prefsRepo.setNotificationPermissionAsked(true);
    if (!mounted) return;

    final allowed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadii.card),
        titlePadding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.sm,
        ),
        contentPadding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.lg,
        ),
        actionsPadding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          0,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: AppRadii.button,
              ),
              child: const Icon(
                LucideIcons.bell,
                size: AppIconSizes.xl,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  'Stay on track with CampusIQ',
                  style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'We can remind you when your streak is at risk, when you have a free study block, and when your weekly review is ready.',
          style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text('Not now'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text('Allow notifications'),
                ),
              ),
            ],
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

  void _sendText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    _textController.clear();
    ref.read(aiChatProvider.notifier).sendMessage(trimmed);
    _scrollToBottom();
  }

  void _handleSend() => _sendText(_textController.text);

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
      backgroundColor: AppColors.background,
      endDrawer: const AiChatHistoryDrawer(),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft, size: AppIconSizes.xl),
          tooltip: 'Back',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('CampusIQ AI'),
            SizedBox(height: AppSpacing.xxs),
            Text(
              'Study coach and academic assistant',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(LucideIcons.history, size: AppIconSizes.lg),
              tooltip: 'History',
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: Column(
        children: [
          const WeeklyReviewBanner(),
          Expanded(
            child: chatState.messages.isEmpty
                ? _AiEmptyState(
                    prompts: _starterPrompts,
                    onPromptTap: _sendText,
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      AppSpacing.md,
                      0,
                      AppSpacing.lg,
                    ),
                    itemCount:
                        chatState.messages.length + (chatState.isLoading ? 1 : 0),
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                0,
                AppSpacing.xl,
                AppSpacing.sm,
              ),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppTheme.warning.withValues(alpha: 0.08),
                  borderRadius: AppRadii.button,
                  border: Border.all(
                    color: AppTheme.warning.withValues(alpha: 0.24),
                  ),
                ),
                child: Text(
                  chatState.error!,
                  style: const TextStyle(
                    color: AppTheme.warning,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          if (chatState.isAtLimit)
            const PremiumGateWidget()
          else
            Column(
              mainAxisSize: MainAxisSize.min,
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
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      0,
                      AppSpacing.lg,
                      AppSpacing.lg,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.card,
                        border: Border.all(color: AppColors.border),
                        boxShadow: AppShadows.soft,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                enabled: !chatState.isLoading,
                                minLines: 1,
                                maxLines: 4,
                                onSubmitted: (_) {
                                  if (!chatState.isLoading) {
                                    _handleSend();
                                  }
                                },
                                decoration: const InputDecoration(
                                  hintText:
                                      'Ask about your courses, notes, or study plan...',
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  filled: false,
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: AppSpacing.sm,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            FilledButton(
                              onPressed: chatState.isLoading ? null : _handleSend,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(52, 52),
                                padding: EdgeInsets.zero,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadii.button,
                                ),
                              ),
                              child: const Icon(
                                LucideIcons.arrowUp,
                                size: AppIconSizes.md,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AiEmptyState extends StatelessWidget {
  final List<String> prompts;
  final ValueChanged<String> onPromptTap;

  const _AiEmptyState({
    required this.prompts,
    required this.onPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.goldSoft,
                borderRadius: AppRadii.card,
              ),
              child: const Icon(
                LucideIcons.sparkles,
                size: AppIconSizes.hero,
                color: AppTheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'How can I help you study today?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Ask me to explain a topic, build practice questions, plan revision, or summarize your notes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: prompts
                  .map(
                    (prompt) => _StarterPromptCard(
                      label: prompt,
                      onTap: () => onPromptTap(prompt),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarterPromptCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _StarterPromptCard({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.button,
        child: Ink(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm2,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppRadii.button,
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.messageSquarePlus,
                size: AppIconSizes.md,
                color: AppTheme.primary,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
