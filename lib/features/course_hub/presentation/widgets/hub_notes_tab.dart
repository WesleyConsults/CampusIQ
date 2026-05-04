import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/course_hub/data/models/course_note_model.dart';
import 'package:campusiq/features/course_hub/presentation/providers/course_note_provider.dart';
import 'package:campusiq/features/course_hub/presentation/widgets/note_editor_sheet.dart';
import 'package:intl/intl.dart';

class HubNotesTab extends ConsumerWidget {
  final String courseCode;

  const HubNotesTab({super.key, required this.courseCode});

  void _openEditor(BuildContext context, {CourseNoteModel? note}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (_) => NoteEditorSheet(
        courseCode: courseCode,
        note: note,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(courseNotesProvider(courseCode));
    final repo = ref.read(courseNoteRepositoryProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final bottomContentPadding =
        bottomInset + AppSpacing.fabSize + AppSpacing.xxl;

    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (notes) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openEditor(context),
            tooltip: 'Add note',
            icon: const Icon(LucideIcons.plus),
            label: const Text('Add note'),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.endFloat,
          body: notes.isEmpty
              ? ListView(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    bottomContentPadding,
                  ),
                  children: [
                    _EmptyNotesState(
                      onCreate: () => _openEditor(context),
                    ),
                  ],
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    bottomContentPadding,
                  ),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Dismissible(
                      key: ValueKey(note.id),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text('Delete note?'),
                                  content: Text(
                                    'Remove "${note.title}" from $courseCode notes?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        dialogContext,
                                      ).pop(false),
                                      child: const Text('Keep'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(
                                        dialogContext,
                                      ).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.warning,
                                      ),
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                );
                              },
                            ) ??
                            false;
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        margin: const EdgeInsets.only(
                            bottom: AppSpacing.md),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceMuted,
                          borderRadius: AppRadii.card,
                          border: Border.all(
                            color: AppTheme.warning
                                .withValues(alpha: 0.18),
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warning
                                .withValues(alpha: 0.1),
                            borderRadius: AppRadii.pill,
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                LucideIcons.trash2,
                                color: AppTheme.warning,
                                size: AppIconSizes.md,
                              ),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                'Delete',
                                style: TextStyle(
                                  color: AppTheme.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      onDismissed: (_) => repo?.deleteNote(note.id),
                      child: _NoteTile(
                        note: note,
                        onTap: () => _openEditor(context, note: note),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

class _EmptyNotesState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyNotesState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.soft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.goldSoft,
              borderRadius: AppRadii.button,
            ),
            child: const Icon(
              LucideIcons.stickyNote,
              color: AppTheme.primary,
              size: AppIconSizes.hero,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Start a calm course notebook',
            style: textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Capture lecture takeaways, reminders, and ideas in one place so this course stays easy to revisit.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onCreate,
            icon: const Icon(LucideIcons.plus),
            label: const Text('Create first note'),
          ),
        ],
      ),
    );
  }
}

class _NoteTile extends StatelessWidget {
  final CourseNoteModel note;
  final VoidCallback onTap;

  const _NoteTile({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final dateLabel =
        DateFormat('dd MMM · HH:mm').format(note.updatedAt);
    final preview = note.body.isNotEmpty
        ? note.body.replaceAll('\n', ' ')
        : 'Empty note';

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.card,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: AppRadii.card,
            border: Border.all(color: AppColors.border),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.surfaceMuted,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadii.pill,
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      dateLabel,
                      style: textTheme.labelSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                preview,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(
                    LucideIcons.pencil,
                    size: AppIconSizes.sm,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Tap to open',
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
