import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/providers/subscription_provider.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_chat_provider.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_providers.dart';
import 'package:campusiq/features/ai/presentation/widgets/premium_gate_widget.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';

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

      if (!mounted) return;
      setState(() {
        _advice = advice;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CampusModalSheet(
      title: 'AI Coach',
      subtitle: 'Personal guidance based on your current CWA outlook.',
      leading: Container(
        width: 48,
        height: 48,
        decoration: const BoxDecoration(
          color: AppColors.goldSoft,
          borderRadius: AppRadii.button,
        ),
        child: const Icon(
          LucideIcons.sparkles,
          color: AppTheme.primary,
          size: AppIconSizes.xl,
        ),
      ),
      trailing: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(LucideIcons.x, size: AppIconSizes.xl),
        tooltip: 'Close',
      ),
      scrollable: true,
      maxHeightFactor: 0.88,
      child: _buildContent(context),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxxl),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadii.card,
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.md),
            Text(
              'Building your CWA coaching notes…',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_isAtLimit) {
      return const PremiumGateWidget();
    }

    if (_error != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: AppRadii.card,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const Icon(
              LucideIcons.circleAlert,
              size: AppIconSizes.status,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadAdvice();
              },
              icon: const Icon(LucideIcons.refreshCcw, size: AppIconSizes.md),
              label: const Text('Try again'),
            ),
          ],
        ),
      );
    }

    if (_advice == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadii.card,
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            _advice!,
            style: const TextStyle(
              fontSize: 15,
              height: 1.65,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
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
            icon: const Icon(LucideIcons.arrowRight, size: AppIconSizes.md),
            label: const Text('Ask a follow-up'),
          ),
        ),
      ],
    );
  }
}
