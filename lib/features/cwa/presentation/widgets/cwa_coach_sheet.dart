import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_providers.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_chat_provider.dart';
import 'package:campusiq/features/ai/presentation/widgets/premium_gate_widget.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';

class CwaCoachSheet extends ConsumerStatefulWidget {
  const CwaCoachSheet({super.key});

  @override
  ConsumerState<CwaCoachSheet> createState() => _CwaCoachSheetState();
}

class _CwaCoachSheetState extends ConsumerState<CwaCoachSheet> {
  bool _isLoading = true;
  String? _advice;
  String? _error;
  bool _isAtLimit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAdvice());
  }

  Future<void> _loadAdvice() async {
    final isPremium = await ref.read(isPremiumProvider.future);
    final usageRepo = await ref.read(aiUsageRepositoryProvider.future);

    final underLimit = isPremium || await usageRepo.isUnderLimit('chat', 3);

    if (!underLimit) {
      setState(() {
        _isAtLimit = true;
        _isLoading = false;
      });
      return;
    }

    try {
      final semesterKey = ref.read(activeSemesterProvider);
      final builder = await ref.read(contextBuilderProvider.future);
      final prompt = await builder.buildCwaCoachPrompt(semesterKey);

      final client = await ref.read(deepseekClientProvider.future);
      final advice = await client.complete(
        systemPrompt: prompt,
        messages: const [
          {
            'role': 'user',
            'content': 'Give me coaching advice about my CWA situation.'
          }
        ],
        maxTokens: 300,
      );

      await usageRepo.incrementUsage('chat');

      if (mounted) {
        setState(() {
          _advice = advice;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Something went wrong. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome,
                        size: 20, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    const Text(
                      'AI Coach',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  child: _buildContent(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_isAtLimit) {
      return const PremiumGateWidget();
    }

    if (_error != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 24),
          Icon(Icons.error_outline, size: 40, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(_error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {
              setState(() {
                _isLoading = true;
                _error = null;
              });
              _loadAdvice();
            },
            child: const Text('Try again'),
          ),
        ],
      );
    }

    if (_advice != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _advice!,
            style: const TextStyle(
                fontSize: 15, height: 1.6, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () async {
              final nav = Navigator.of(context);
              final router = GoRouter.of(context);
              await ref
                  .read(aiChatProvider.notifier)
                  .seedWithCoachingContext(_advice!);
              if (!mounted) return;
              nav.pop();
              router.push('/ai');
            },
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: const Text('Ask a follow-up'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}
