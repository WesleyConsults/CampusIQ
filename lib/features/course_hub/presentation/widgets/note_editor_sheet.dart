import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/course_hub/data/models/course_note_model.dart';
import 'package:campusiq/features/course_hub/presentation/providers/course_note_provider.dart';
import 'package:campusiq/shared/widgets/campus_modal_action_row.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';

class NoteEditorSheet extends ConsumerStatefulWidget {
  final String courseCode;
  final CourseNoteModel? note;

  const NoteEditorSheet({
    super.key,
    required this.courseCode,
    this.note,
  });

  @override
  ConsumerState<NoteEditorSheet> createState() => _NoteEditorSheetState();
}

class _NoteEditorSheetState extends ConsumerState<NoteEditorSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();
    if (title.isEmpty && body.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSaving = true);
    final repo = ref.read(courseNoteRepositoryProvider);
    if (repo == null) {
      setState(() => _isSaving = false);
      return;
    }

    final now = DateTime.now();
    final note = widget.note ?? CourseNoteModel();
    note
      ..courseCode = widget.courseCode
      ..title = title.isEmpty ? 'Untitled' : title
      ..body = body
      ..updatedAt = now;

    if (widget.note == null) {
      note.createdAt = now;
    }

    await repo.saveNote(note);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isEditing = widget.note != null;
    final titleText = isEditing ? 'Edit note' : 'New note';
    final subtitleText = isEditing
        ? 'Refine your course note and keep the latest version saved.'
        : 'Capture a quick thought, summary, or reminder for this course.';

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return CampusModalSheet(
          title: titleText,
          subtitle: subtitleText,
          expandBody: true,
          maxHeightFactor: 0.95,
          trailing: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Close',
            icon: const Icon(LucideIcons.x, size: AppIconSizes.xl),
          ),
          bottomBar: CampusModalActionRow(
            primaryLabel: isEditing ? 'Save changes' : 'Save note',
            onPrimaryPressed: _isSaving ? null : _save,
            secondaryLabel: 'Cancel',
            onSecondaryPressed:
                _isSaving ? null : () => Navigator.of(context).pop(),
            isPrimaryLoading: _isSaving,
          ),
          child: Scrollbar(
            controller: scrollController,
            thumbVisibility: false,
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldShell(
                    child: TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        hintText: 'Title',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: textTheme.headlineSmall,
                      textInputAction: TextInputAction.next,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _FieldShell(
                    minHeight: 260,
                    alignment: Alignment.topLeft,
                    child: TextField(
                      controller: _bodyController,
                      decoration: const InputDecoration(
                        hintText: 'Start writing...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        filled: false,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: textTheme.bodyLarge?.copyWith(
                        height: 1.55,
                      ),
                      minLines: 10,
                      maxLines: null,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FieldShell extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry alignment;
  final double? minHeight;

  const _FieldShell({
    required this.child,
    this.alignment = Alignment.centerLeft,
    this.minHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: minHeight == null
          ? null
          : BoxConstraints(minHeight: minHeight!),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: AppRadii.card,
        border: Border.all(color: AppColors.border),
      ),
      child: Align(
        alignment: alignment,
        child: child,
      ),
    );
  }
}
