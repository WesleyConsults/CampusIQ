import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:campusiq/features/plan/presentation/providers/exam_mode_provider.dart';
import 'package:campusiq/features/plan/presentation/widgets/exam_mode_transition.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

class ExamModeActivationSheet extends ConsumerStatefulWidget {
  /// When true the sheet was triggered automatically (14-day countdown).
  final bool isAutoTriggered;

  const ExamModeActivationSheet({super.key, this.isAutoTriggered = false});

  @override
  ConsumerState<ExamModeActivationSheet> createState() =>
      _ExamModeActivationSheetState();
}

class _ExamModeActivationSheetState
    extends ConsumerState<ExamModeActivationSheet> {
  int _selectedGoalMinutes = 360; // 6 h default
  bool _activating = false;

  static const _goals = [
    (label: '2h (normal)', minutes: 120),
    (label: '6h (intensive)', minutes: 360),
    (label: '8h (max)', minutes: 480),
  ];

  @override
  Widget build(BuildContext context) {
    final exams = ref.watch(upcomingExamsProvider);

    if (exams.isEmpty) {
      return const _EmptyExamsSheet();
    }

    final firstExam = exams.first;
    final daysAway = firstExam.examDate.difference(DateTime.now()).inDays;
    final examLabel =
        '${firstExam.courseName} (${DateFormat('MMM d').format(firstExam.examDate)})';
    final within14 = exams
        .where((e) =>
            e.examDate.difference(DateTime.now()).inDays <= 14 &&
            e.examDate.isAfter(DateTime.now()))
        .length;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ────────────────────────────────────────────────────────
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // ── Icon + title ─────────────────────────────────────────────────
          const Text('🔥', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          const Text(
            'EXAM MODE INCOMING',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: Color(0xFFBF360C),
            ),
          ),
          const SizedBox(height: 16),

          // ── Info ─────────────────────────────────────────────────────────
          Text(
            within14 > 0
                ? 'You have $within14 exam${within14 > 1 ? 's' : ''} in the next 14 days'
                : 'First exam: $examLabel',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          if (within14 > 0) ...[
            const SizedBox(height: 4),
            Text(
              'First exam: $examLabel ($daysAway days away)',
              style:
                  const TextStyle(fontSize: 13, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),

          // ── Goal picker ──────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              border:
                  Border.all(color: Colors.deepOrange.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Daily study goal:',
                      style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                RadioGroup<int>(
                  groupValue: _selectedGoalMinutes,
                  onChanged: (v) =>
                      setState(() => _selectedGoalMinutes = v ?? _selectedGoalMinutes),
                  child: Column(
                    children: _goals
                        .map((g) => RadioListTile<int>(
                              dense: true,
                              title: Text(g.label,
                                  style: const TextStyle(fontSize: 13)),
                              value: g.minutes,
                              activeColor: Colors.deepOrange,
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Activate button ──────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.deepOrange[700],
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _activating ? null : _activate,
              child: _activating
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text(
                      'ACTIVATE EXAM MODE',
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          letterSpacing: 0.5),
                    ),
            ),
          ),
          const SizedBox(height: 8),

          // ── Dismiss ──────────────────────────────────────────────────────
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Maybe later',
                style: TextStyle(color: Colors.black45)),
          ),
        ],
      ),
    );
  }

  Future<void> _activate() async {
    setState(() => _activating = true);

    final exams = ref.read(upcomingExamsProvider);
    if (exams.isEmpty) return;

    final firstExam = exams.first;
    final lastExam = exams.last;

    final repo = ref.read(userPrefsRepositoryProvider);
    if (repo == null) {
      setState(() => _activating = false);
      return;
    }

    await repo.updateExamModeSettings(
      isActive: true,
      examStart: DateTime.now(),
      examEnd: lastExam.examDate,
      dailyGoal: _selectedGoalMinutes,
    );

    if (!mounted) return;
    Navigator.of(context).pop();

    // Show animated transition overlay
    await showDialog<void>(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      builder: (_) => ExamModeTransition(
        firstExamName: firstExam.courseName,
      ),
    );
  }
}

class _EmptyExamsSheet extends StatelessWidget {
  const _EmptyExamsSheet();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📚', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 12),
          const Text(
            'No exams added yet',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the manage icon to add your upcoming exams first.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
