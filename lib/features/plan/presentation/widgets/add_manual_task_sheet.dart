import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/plan/presentation/providers/plan_provider.dart';

class AddManualTaskSheet extends ConsumerStatefulWidget {
  const AddManualTaskSheet({super.key});

  @override
  ConsumerState<AddManualTaskSheet> createState() => _AddManualTaskSheetState();
}

class _AddManualTaskSheetState extends ConsumerState<AddManualTaskSheet> {
  final _labelCtrl = TextEditingController();
  final _durationCtrl = TextEditingController(text: '30');
  final _formKey = GlobalKey<FormState>();

  String _taskType = 'study';
  CourseModel? _selectedCourse;
  TimeOfDay? _startTime;
  bool _saving = false;

  @override
  void dispose() {
    _labelCtrl.dispose();
    _durationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _startTime = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final duration = int.tryParse(_durationCtrl.text.trim()) ?? 30;

      DateTime? startTime;
      if (_startTime != null) {
        startTime = DateTime(
          today.year,
          today.month,
          today.day,
          _startTime!.hour,
          _startTime!.minute,
        );
      }

      final repo = ref.read(planRepositoryProvider);
      if (repo == null) return;

      final existing = await repo.getTasksForDate(today);

      final task = DailyPlanTaskModel()
        ..date = today
        ..taskType = _taskType
        ..label = _labelCtrl.text.trim()
        ..courseCode = _selectedCourse?.code
        ..durationMinutes = duration
        ..startTime = startTime
        ..isCompleted = false
        ..isManual = true
        ..sortOrder = existing.length;

      await repo.saveTask(task);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final courses = ref.watch(coursesProvider).valueOrNull ?? [];

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(AppRadii.xxxs),
                  ),
                ),
              ),
              const Text(
                'Add Task',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Label
              TextFormField(
                controller: _labelCtrl,
                decoration: const InputDecoration(labelText: 'Task label *'),
                textCapitalization: TextCapitalization.sentences,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Label is required'
                    : null,
              ),
              const SizedBox(height: AppSpacing.sm2),

              // Task type
              DropdownButtonFormField<String>(
                // ignore: deprecated_member_use
                value: _taskType,
                decoration: const InputDecoration(labelText: 'Task type'),
                items: const [
                  DropdownMenuItem(value: 'study', child: Text('Study')),
                  DropdownMenuItem(
                      value: 'attend', child: Text('Attend class')),
                  DropdownMenuItem(value: 'personal', child: Text('Personal')),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _taskType = v);
                },
              ),
              const SizedBox(height: AppSpacing.sm2),

              // Course picker (optional)
              if (courses.isNotEmpty)
                DropdownButtonFormField<CourseModel?>(
                  // ignore: deprecated_member_use
                  value: _selectedCourse,
                  decoration:
                      const InputDecoration(labelText: 'Course (optional)'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...courses.map(
                      (c) => DropdownMenuItem(
                        value: c,
                        child: Text('${c.code} — ${c.name}',
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _selectedCourse = v),
                ),
              if (courses.isNotEmpty) const SizedBox(height: AppSpacing.sm2),

              // Duration
              TextFormField(
                controller: _durationCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration:
                    const InputDecoration(labelText: 'Duration (minutes)'),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Enter a valid duration';
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.sm2),

              // Start time (optional)
              InkWell(
                onTap: _pickTime,
                borderRadius: BorderRadius.circular(AppRadii.xs2),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Start time (optional)',
                    suffixIcon: Icon(Icons.access_time),
                  ),
                  child: Text(
                    _startTime != null
                        ? _startTime!.format(context)
                        : 'Tap to set',
                    style: TextStyle(
                      color: _startTime != null
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadii.xs2)),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Add Task',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
