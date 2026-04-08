import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/plan/data/models/exam_model.dart';
import 'package:campusiq/features/plan/domain/exam_prep_planner.dart';
import 'package:campusiq/features/plan/presentation/providers/exam_mode_provider.dart';

class ExamManagerSheet extends ConsumerStatefulWidget {
  const ExamManagerSheet({super.key});

  @override
  ConsumerState<ExamManagerSheet> createState() => _ExamManagerSheetState();
}

class _ExamManagerSheetState extends ConsumerState<ExamManagerSheet> {
  @override
  Widget build(BuildContext context) {
    final examsAsync = ref.watch(examsProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // ── Handle + header ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Manage Exams',
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w700),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      tooltip: 'Add exam',
                      onPressed: () => _showAddExamForm(context),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16),

              // ── Exam list ────────────────────────────────────────────────
              Expanded(
                child: examsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) =>
                      Center(child: Text('Error: $e')),
                  data: (exams) {
                    if (exams.isEmpty) {
                      return const _EmptyExams();
                    }
                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                      itemCount: exams.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1),
                      itemBuilder: (_, i) =>
                          _ExamTile(exam: exams[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddExamForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _AddExamForm(),
    );
  }
}

// ── Individual exam tile ──────────────────────────────────────────────────────

class _ExamTile extends ConsumerWidget {
  final ExamModel exam;
  const _ExamTile({required this.exam});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateStr = DateFormat('MMM d @ h a').format(
        DateTime(exam.examDate.year, exam.examDate.month, exam.examDate.day,
            exam.examStartHour));
    final topics = _parseTopics(exam.topicsJson);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${exam.courseName} — $dateStr',
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Text(
                      '${exam.creditHours} credits'
                      '${exam.examHall != null ? ' | ${exam.examHall}' : ''}',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    size: 20, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          if (topics.isNotEmpty) ...[
            const SizedBox(height: 4),
            ...topics.map((t) => Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Row(
                    children: [
                      Icon(Icons.circle,
                          size: 6,
                          color: _priorityColor(t.priority)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${t.name} (${t.priority})',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }

  Color _priorityColor(String priority) => switch (priority) {
        'high' => Colors.red,
        'medium' => Colors.orange,
        _ => Colors.green,
      };

  List<ExamTopic> _parseTopics(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      return (jsonDecode(json) as List)
          .map((e) => ExamTopic.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete exam?'),
        content:
            Text('Remove ${exam.courseName} from your exam schedule?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Delete',
                  style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(examRepositoryProvider)?.delete(exam.id);
    }
  }
}

// ── Add exam form ─────────────────────────────────────────────────────────────

class _AddExamForm extends ConsumerStatefulWidget {
  const _AddExamForm();

  @override
  ConsumerState<_AddExamForm> createState() => _AddExamFormState();
}

class _AddExamFormState extends ConsumerState<_AddExamForm> {
  CourseModel? _selectedCourse;
  DateTime? _examDate;
  int _startHour = 9;
  final _hallController = TextEditingController();
  final _topics = <ExamTopic>[];
  bool _saving = false;

  @override
  void dispose() {
    _hallController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add Exam',
              style:
                  TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),

          // Course picker
          coursesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Error: $e'),
            data: (courses) {
              if (courses.isEmpty) {
                return const Text(
                  'No courses found. Add courses in CWA first.',
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                );
              }
              return DropdownButtonFormField<CourseModel>(
                decoration: const InputDecoration(
                  labelText: 'Course',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedCourse,
                items: courses
                    .map((c) => DropdownMenuItem(
                          value: c,
                          child: Text(
                              '${c.code} — ${c.name}',
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (c) => setState(() => _selectedCourse = c),
              );
            },
          ),
          const SizedBox(height: 12),

          // Exam date
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading:
                const Icon(Icons.calendar_today, color: Colors.deepOrange),
            title: Text(
              _examDate == null
                  ? 'Pick exam date'
                  : DateFormat('EEEE, d MMMM y').format(_examDate!),
              style: TextStyle(
                  fontSize: 14,
                  color: _examDate == null
                      ? Colors.black54
                      : Colors.black87),
            ),
            onTap: _pickDate,
          ),

          // Start hour
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.access_time, color: Colors.deepOrange),
            title: Text(
              'Start time: ${_formatHour(_startHour)}',
              style: const TextStyle(fontSize: 14),
            ),
            onTap: _pickTime,
          ),

          // Exam hall
          TextField(
            controller: _hallController,
            decoration: const InputDecoration(
              labelText: 'Exam hall (optional)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          // Topics
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Topics (optional)',
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w600)),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add topic'),
                onPressed: _addTopic,
              ),
            ],
          ),
          ..._topics.asMap().entries.map((entry) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.circle,
                    size: 8,
                    color: _priorityColor(entry.value.priority)),
                title: Text(entry.value.name,
                    style: const TextStyle(fontSize: 13)),
                subtitle: Text(entry.value.priority,
                    style: const TextStyle(fontSize: 11)),
                trailing: IconButton(
                  icon: const Icon(Icons.close, size: 16),
                  onPressed: () =>
                      setState(() => _topics.removeAt(entry.key)),
                ),
              )),
          const SizedBox(height: 16),

          // Save button
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Colors.deepOrange[700]),
              onPressed: _canSave && !_saving ? _save : null,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Exam'),
            ),
          ),
        ],
      ),
    );
  }

  bool get _canSave => _selectedCourse != null && _examDate != null;

  Color _priorityColor(String p) => switch (p) {
        'high' => Colors.red,
        'medium' => Colors.orange,
        _ => Colors.green,
      };

  String _formatHour(int h) {
    final dt = DateTime(2000, 1, 1, h);
    return DateFormat.jm().format(dt);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
    );
    if (picked != null) setState(() => _examDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _startHour, minute: 0),
    );
    if (picked != null) setState(() => _startHour = picked.hour);
  }

  Future<void> _addTopic() async {
    final result = await showDialog<ExamTopic>(
      context: context,
      builder: (_) => const _AddTopicDialog(),
    );
    if (result != null) setState(() => _topics.add(result));
  }

  Future<void> _save() async {
    if (_selectedCourse == null || _examDate == null) return;
    setState(() => _saving = true);

    final topicsJson = _topics.isEmpty
        ? null
        : jsonEncode(_topics.map((t) => t.toJson()).toList());

    final exam = ExamModel.create(
      courseCode: _selectedCourse!.code,
      courseName: _selectedCourse!.name,
      examDate: DateTime(
          _examDate!.year, _examDate!.month, _examDate!.day),
      examStartHour: _startHour,
      creditHours: _selectedCourse!.creditHours.round(),
      examHall: _hallController.text.trim().isEmpty
          ? null
          : _hallController.text.trim(),
      topicsJson: topicsJson,
    );

    await ref.read(examRepositoryProvider)?.save(exam);

    if (mounted) Navigator.of(context).pop();
  }
}

// ── Add topic dialog ──────────────────────────────────────────────────────────

class _AddTopicDialog extends StatefulWidget {
  const _AddTopicDialog();

  @override
  State<_AddTopicDialog> createState() => _AddTopicDialogState();
}

class _AddTopicDialogState extends State<_AddTopicDialog> {
  final _controller = TextEditingController();
  String _priority = 'medium';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Topic'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
              labelText: 'Topic name',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _priority,
            decoration: const InputDecoration(labelText: 'Priority'),
            items: const [
              DropdownMenuItem(value: 'high', child: Text('High')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'low', child: Text('Low')),
            ],
            onChanged: (v) => setState(() => _priority = v!),
          ),
        ],
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            final name = _controller.text.trim();
            if (name.isEmpty) return;
            Navigator.of(context)
                .pop(ExamTopic(name: name, priority: _priority));
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyExams extends StatelessWidget {
  const _EmptyExams();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.event_note_outlined,
                size: 56, color: Colors.black26),
            SizedBox(height: 16),
            Text(
              'No exams yet',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Tap + to add your upcoming exams.',
              style: TextStyle(color: Colors.black45, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
