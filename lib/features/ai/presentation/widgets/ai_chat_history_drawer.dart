import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/ai/presentation/providers/ai_chat_provider.dart';
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';

class AiChatHistoryDrawer extends ConsumerWidget {
  const AiChatHistoryDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(aiChatProvider);

    return Drawer(
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: AppColors.goldSoft,
                      borderRadius: AppRadii.button,
                    ),
                    child: const Icon(
                      LucideIcons.messagesSquare,
                      color: AppTheme.primary,
                      size: AppIconSizes.xl,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conversation history',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Reopen recent chats or start a fresh one.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: AppIconSizes.xl),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(aiChatProvider.notifier).createNewChat();
                  },
                  icon: const Icon(
                    LucideIcons.squarePen,
                    size: AppIconSizes.md,
                  ),
                  label: const Text('New chat'),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            const Divider(height: 1),
            Expanded(
              child: chatState.sessions.isEmpty
                  ? const _HistoryEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      itemCount: chatState.sessions.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (context, index) {
                        final session = chatState.sessions[index];
                        final isSelected =
                            session.id == chatState.currentSessionId;

                        return _HistoryTile(
                          title: session.title.isNotEmpty
                              ? session.title
                              : 'New chat',
                          isSelected: isSelected,
                          onTap: () {
                            Navigator.of(context).pop();
                            if (!isSelected) {
                              ref
                                  .read(aiChatProvider.notifier)
                                  .switchSession(session.id);
                            }
                          },
                          onDelete: () async {
                            final confirm = await showCampusConfirmDialog(
                              context: context,
                              title: 'Delete chat?',
                              message:
                                  'This removes the saved chat history for this conversation.',
                              confirmLabel: 'Delete',
                              destructive: true,
                            );

                            if (confirm == true) {
                              ref
                                  .read(aiChatProvider.notifier)
                                  .deleteSession(session.id);
                            }
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _HistoryTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : AppColors.surfaceMuted,
            borderRadius: AppRadii.card,
            border: Border.all(
              color: isSelected ? AppTheme.primary : AppColors.border,
            ),
            boxShadow: isSelected ? AppShadows.soft : null,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primary.withValues(alpha: 0.12)
                      : AppColors.surface,
                  borderRadius: AppRadii.button,
                ),
                child: Icon(
                  isSelected ? LucideIcons.sparkles : LucideIcons.messageSquare,
                  size: AppIconSizes.md,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(
                  LucideIcons.trash2,
                  size: AppIconSizes.md,
                  color: AppTheme.textSecondary,
                ),
                tooltip: 'Delete chat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.messagesSquare,
              size: AppIconSizes.status,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'No previous chats yet',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            SizedBox(height: AppSpacing.xxs),
            Text(
              'Start your first conversation and it will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
