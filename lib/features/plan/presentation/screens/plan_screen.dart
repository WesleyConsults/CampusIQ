import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/plan/presentation/providers/plan_provider.dart';
import 'package:campusiq/features/plan/presentation/widgets/add_manual_task_sheet.dart';
import 'package:campusiq/features/plan/presentation/widgets/plan_progress_bar.dart';
import 'package:campusiq/features/plan/presentation/widgets/plan_task_tile.dart';

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

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(todayPlanProvider);
    final (completed, total) = ref.watch(planProgressProvider);
    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE, d MMMM').format(now);
    final isDone = total > 0 && completed >= total;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Today's Plan",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
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
                        style: TextStyle(color: Colors.white, fontSize: 12)),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSheet,
        child: const Icon(Icons.add),
      ),
      body: tasksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) => _buildBody(tasks, completed, total, isDone),
      ),
    );
  }

  Widget _buildBody(
    List<DailyPlanTaskModel> tasks,
    int completed,
    int total,
    bool isDone,
  ) {
    final attendTasks =
        tasks.where((t) => t.taskType == 'attend').toList();
    final studyTasks =
        tasks.where((t) => t.taskType == 'study').toList();
    final personalTasks =
        tasks.where((t) => t.taskType == 'personal').toList();

    return CustomScrollView(
      slivers: [
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
                            fontSize: 12, color: AppTheme.textSecondary),
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
            const _SectionHeader(label: 'Classes', color: Color(0xFF1565C0)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 3),
                  child: Card(
                    child: PlanTaskTile(task: attendTasks[i]),
                  ),
                ),
                childCount: attendTasks.length,
              ),
            ),
          ],

          // ── Study section ─────────────────────────────────────────────
          if (studyTasks.isNotEmpty) ...[
            const _SectionHeader(label: 'Study', color: Color(0xFF1D9E75)),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 3),
                  child: Card(
                    child: PlanTaskTile(task: studyTasks[i]),
                  ),
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
                    child: PlanTaskTile(task: personalTasks[i]),
                  ),
                ),
                childCount: personalTasks.length,
              ),
            ),
          ],

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ],
    );
  }
}

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
