import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
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

    return notesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (notes) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openEditor(context),
            tooltip: 'Add note',
            child: const Icon(Icons.add),
          ),
          body: notes.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.notes_outlined,
                            size: 48, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text(
                          'No notes yet',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Tap + to add your first note for this course.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 80),
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return Dismissible(
                      key: ValueKey(note.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child:
                            const Icon(Icons.delete_outline, color: Colors.red),
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

class _NoteTile extends StatelessWidget {
  final CourseNoteModel note;
  final VoidCallback onTap;

  const _NoteTile({required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd MMM · HH:mm').format(note.updatedAt);
    final preview =
        note.body.isNotEmpty ? note.body.replaceAll('\n', ' ') : 'Empty note';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                preview,
                style: const TextStyle(
                    fontSize: 13, color: AppTheme.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                dateLabel,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
