import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/plan/presentation/providers/exam_mode_provider.dart';
import 'package:campusiq/features/plan/presentation/providers/plan_provider.dart';
import 'package:campusiq/features/plan/presentation/widgets/add_manual_task_sheet.dart';
import 'package:campusiq/features/plan/presentation/widgets/exam_manager_sheet.dart';
import 'package:campusiq/features/plan/presentation/widgets/exam_mode_activation_sheet.dart';
import 'package:campusiq/features/plan/presentation/widgets/plan_progress_bar.dart';
import 'package:campusiq/features/plan/presentation/widgets/plan_task_tile.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_action_button.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

class PlanScreen extends ConsumerStatefulWidget {
  const PlanScreen({super.key});

  @override
  ConsumerState<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends ConsumerState<PlanScreen> {
  bool _isGenerating = false;

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      ref.invalidate(generatePlanProvider(today));
      await ref.read(generatePlanProvider(today).future);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  Future<void> _showAddSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddManualTaskSheet(),
    );
  }

  Future<void> _showExamManager() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ExamManagerSheet(),
    );
  }

  Future<void> _handleExamModeFab() async {
    final examModeActive =
        ref.read(examModeActiveProvider).valueOrNull ?? false;

    if (examModeActive) {
      // In exam mode → open manager
      await _showExamManager();
      return;
    }

    final exams = ref.read(upcomingExamsProvider);
    if (exams.isEmpty) {
      // No exams yet → open manager to add first
      await _showExamManager();
      return;
    }

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const ExamModeActivationSheet(),
    );
  }

  Future<void> _deactivateExamMode() async {
    final repo = ref.read(userPrefsRepositoryProvider);
    await repo?.updateExamModeSettings(isActive: false);
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(todayPlanProvider);
    final (completed, total) = ref.watch(planProgressProvider);
    final examModeActive =
        ref.watch(examModeActiveProvider).valueOrNull ?? false;
    final upcomingExams = ref.watch(upcomingExamsProvider);
    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE, d MMMM').format(now);
    final isDone = total > 0 && completed >= total;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              examModeActive ? '🔥 Exam Mode' : "Today's Plan",
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
            ),
            Text(
              dateLabel,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Colors.white70),
            ),
          ],
        ),
        actions: [
          const StreakActionButton(),
          // Exam manager gear icon
          IconButton(
            icon: const Icon(Icons.event_note_outlined, color: Colors.white),
            tooltip: 'Manage exams',
            onPressed: _showExamManager,
          ),
          IconButton(
            icon:
                const Icon(Icons.notifications_outlined, color: Colors.white),
            tooltip: 'Notification settings',
            onPressed: () => context.go('/settings'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : OutlinedButton.icon(
                    onPressed: _generatePlan,
                    icon: const Icon(Icons.auto_awesome,
                        size: 16, color: Colors.white),
                    label: const Text('Generate',
                        style:
                            TextStyle(color: Colors.white, fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      minimumSize: Size.zero,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'add_task',
            onPressed: _showAddSheet,
            tooltip: 'Add task manually',
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'exam_mode',
            onPressed: _handleExamModeFab,
            tooltip: examModeActive ? 'Manage exams' : 'Enter Exam Mode',
            backgroundColor:
                examModeActive ? Colors.deepOrange[700] : null,
            child: Icon(
              examModeActive ? Icons.manage_search : Icons.whatshot,
              color: examModeActive ? Colors.white : null,
            ),
          ),
        ],
      ),
      body: tasksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) => _buildBody(
          tasks: tasks,
          completed: completed,
          total: total,
          isDone: isDone,
          examModeActive: examModeActive,
          upcomingExams: upcomingExams,
        ),
      ),
    );
  }

  Widget _buildBody({
    required List<DailyPlanTaskModel> tasks,
    required int completed,
    required int total,
    required bool isDone,
    required bool examModeActive,
    required List upcomingExams,
  }) {
    final attendTasks =
        tasks.where((t) => t.taskType == 'attend').toList();
    final studyTasks =
        tasks.where((t) => t.taskType == 'study').toList();
    final personalTasks =
        tasks.where((t) => t.taskType == 'personal').toList();

    return CustomScrollView(
      slivers: [
        // ── Exam Mode banner ────────────────────────────────────────────
        if (examModeActive && upcomingExams.isNotEmpty)
          SliverToBoxAdapter(
            child: _ExamModeBanner(
              upcomingExams: upcomingExams,
              onExit: _deactivateExamMode,
            ),
          ),

        // ── Progress section ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    PlanProgressBar(completed: completed, total: total),
                    if (isDone) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'You crushed it today 🎉',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1D9E75),
                        ),
                      ),
                    ] else if (total > 0) ...[
                      const SizedBox(height: 8),
                      Text(
                        '$completed of $total tasks done',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Empty state ─────────────────────────────────────────────────
        if (tasks.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.checklist_rounded,
                        size: 56, color: AppTheme.textSecondary),
                    SizedBox(height: 16),
                    Text(
                      'No tasks yet',
                      style: TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "Tap Generate to build today's plan\nor use + to add tasks manually.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          )
        else ...[
          // ── Classes section ───────────────────────────────────────────
          if (attendTasks.isNotEmpty) ...[
            const _SectionHeader(
                label: 'Classes', color: Color(0xFF1565C0)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 3),
                  child: Card(child: PlanTaskTile(task: attendTasks[i])),
                ),
                childCount: attendTasks.length,
              ),
            ),
          ],

          // ── Study / Exam Prep section ─────────────────────────────────
          if (studyTasks.isNotEmpty) ...[
            _SectionHeader(
              label: examModeActive ? 'Exam Prep' : 'Study',
              color: examModeActive
                  ? const Color(0xFFBF360C)
                  : const Color(0xFF1D9E75),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 3),
                  child: Card(child: PlanTaskTile(task: studyTasks[i])),
                ),
                childCount: studyTasks.length,
              ),
            ),
          ],

          // ── Personal section ──────────────────────────────────────────
          if (personalTasks.isNotEmpty) ...[
            const _SectionHeader(
                label: 'Personal', color: Color(0xFFF59E0B)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 3),
                  child: Card(
                      child: PlanTaskTile(task: personalTasks[i])),
                ),
                childCount: personalTasks.length,
              ),
            ),
          ],

          // ── Exam progress ─────────────────────────────────────────────
          if (examModeActive && upcomingExams.isNotEmpty)
            SliverToBoxAdapter(
              child: _ExamProgressSection(
                  upcomingExams: upcomingExams, tasks: tasks),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ],
    );
  }
}

// ── Exam Mode banner ──────────────────────────────────────────────────────────

class _ExamModeBanner extends StatelessWidget {
  final List upcomingExams;
  final VoidCallback onExit;

  const _ExamModeBanner(
      {required this.upcomingExams, required this.onExit});

  @override
  Widget build(BuildContext context) {
    final first = upcomingExams.first;
    final daysAway = (first.examDate as DateTime)
        .difference(DateTime.now())
        .inDays;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange[800]!, Colors.deepOrange[600]!],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'EXAM MODE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '${first.courseName} in $daysAway day${daysAway == 1 ? '' : 's'}',
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (daysAway > 0)
            TextButton(
              onPressed: onExit,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white70,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Exit',
                  style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }
}

// ── Exam progress section ─────────────────────────────────────────────────────

class _ExamProgressSection extends StatelessWidget {
  final List upcomingExams;
  final List<DailyPlanTaskModel> tasks;

  const _ExamProgressSection(
      {required this.upcomingExams, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Exam Progress',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3),
              ),
              const SizedBox(height: 12),
              ...upcomingExams.map((exam) {
                final examTasks = tasks
                    .where((t) => t.courseCode == exam.courseCode)
                    .toList();
                final done = examTasks.where((t) => t.isCompleted).length;
                final total = examTasks.length;
                final progress =
                    total == 0 ? 0.0 : done / total.toDouble();
                final daysAway = (exam.examDate as DateTime)
                    .difference(DateTime.now())
                    .inDays;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            exam.courseName as String,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600),
                          ),
                          Text(
                            '$daysAway day${daysAway == 1 ? '' : 's'} away',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black45),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 6,
                          backgroundColor: Colors.grey[200],
                          color: Colors.deepOrange[700],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        total == 0
                            ? 'No prep sessions today'
                            : '$done/$total prep sessions done today',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.black45),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  final Color color;

  const _SectionHeader({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
