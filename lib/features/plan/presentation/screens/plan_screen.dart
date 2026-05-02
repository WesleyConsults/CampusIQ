import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/plan/data/models/daily_plan_task_model.dart';
import 'package:campusiq/features/plan/presentation/providers/plan_provider.dart';
import 'package:campusiq/features/plan/presentation/widgets/add_manual_task_sheet.dart';
import 'package:campusiq/features/plan/presentation/widgets/plan_progress_bar.dart';
import 'package:campusiq/features/plan/presentation/widgets/plan_task_tile.dart';
import 'package:campusiq/features/session/domain/active_session_state.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_action_button.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_summary_mini.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';

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
      if (mounted) {
        setState(() => _isGenerating = false);
      }
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

  void _navigateFromDrawer(String route, {bool push = false}) {
    Navigator.of(context).pop();
    Future.microtask(() {
      if (!mounted) {
        return;
      }
      if (push) {
        context.push(route);
      } else {
        context.go(route);
      }
    });
  }

  String _greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) {
      return 'Good morning';
    }
    if (hour < 17) {
      return 'Good afternoon';
    }
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(todayPlanProvider);
    final (completed, total) = ref.watch(planProgressProvider);
    final activeSession = ref.watch(activeSessionProvider);
    final studyStreak = ref.watch(studyStreakProvider);
    final attendanceStreak = ref.watch(attendanceStreakProvider);
    final perCourseStreaks = ref.watch(perCourseStreakProvider);
    final projectedCwa = ref.watch(projectedCwaProvider);
    final targetCwa = ref.watch(targetCwaProvider);
    final allSlots = ref.watch(allSlotsProvider).valueOrNull ?? [];

    final now = DateTime.now();
    final dateLabel = DateFormat('EEEE, d MMMM').format(now);
    final greeting = _greetingFor(now);
    final isDone = total > 0 && completed >= total;
    final todayIndex = now.weekday <= 6 ? now.weekday - 1 : 0;
    final todaySlots = allSlots
        .where((slot) => slot.dayIndex == todayIndex)
        .toList()
      ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    final freeBlocks = FreeTimeDetector.detect(
      dayIndex: todayIndex,
      slots: todaySlots,
    );

    return Scaffold(
      backgroundColor: AppTheme.surface,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(color: AppTheme.primary),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.home_rounded, color: Colors.white, size: 32),
                    SizedBox(height: 12),
                    Text(
                      'CampusIQ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Today is your home base',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _DrawerItem(
                icon: Icons.today_outlined,
                label: 'Today',
                onTap: () => _navigateFromDrawer('/plan'),
              ),
              _DrawerItem(
                icon: Icons.local_fire_department_outlined,
                label: 'Streak',
                onTap: () => _navigateFromDrawer('/streak', push: true),
              ),
              _DrawerItem(
                icon: Icons.auto_graph_outlined,
                label: 'Insights',
                onTap: () => _navigateFromDrawer('/insights', push: true),
              ),
              _DrawerItem(
                icon: Icons.rate_review_outlined,
                label: 'Weekly Review',
                onTap: () =>
                    _navigateFromDrawer('/ai/weekly-review', push: true),
              ),
              _DrawerItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () => _navigateFromDrawer('/settings', push: true),
              ),
              _DrawerItem(
                icon: Icons.workspace_premium_outlined,
                label: 'Subscribe',
                onTap: () => _navigateFromDrawer('/subscribe', push: true),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            tooltip: 'Open menu',
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            Text(
              dateLabel,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          const StreakActionButton(),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            tooltip: 'Notification settings',
            onPressed: () => context.push('/settings'),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : OutlinedButton.icon(
                    onPressed: _generatePlan,
                    icon: const Icon(
                      Icons.auto_awesome,
                      size: 16,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Generate',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white54),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      minimumSize: Size.zero,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_task',
        onPressed: _showAddSheet,
        tooltip: 'Add task manually',
        child: const Icon(Icons.add),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) => _buildBody(
          tasks: tasks,
          completed: completed,
          total: total,
          isDone: isDone,
          greeting: greeting,
          dateLabel: dateLabel,
          activeSession: activeSession,
          studyStreak: studyStreak,
          attendanceStreak: attendanceStreak,
          totalCourseStreaks: perCourseStreaks.values
              .where((result) => result.currentStreak > 0)
              .length,
          projectedCwa: projectedCwa,
          targetCwa: targetCwa,
          todaySlots: todaySlots,
          freeBlocks: freeBlocks,
        ),
      ),
    );
  }

  Widget _buildBody({
    required List<DailyPlanTaskModel> tasks,
    required int completed,
    required int total,
    required bool isDone,
    required String greeting,
    required String dateLabel,
    required ActiveSessionState? activeSession,
    required StreakResult studyStreak,
    required StreakResult attendanceStreak,
    required int totalCourseStreaks,
    required double projectedCwa,
    required double targetCwa,
    required List<TimetableSlotModel> todaySlots,
    required List<FreeBlock> freeBlocks,
  }) {
    final attendTasks = tasks.where((t) => t.taskType == 'attend').toList();
    final studyTasks = tasks.where((t) => t.taskType == 'study').toList();
    final personalTasks = tasks.where((t) => t.taskType == 'personal').toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: _GreetingCard(
              greeting: greeting,
              dateLabel: dateLabel,
              studyStreak: studyStreak,
              classCount: todaySlots.length,
            ),
          ),
        ),
        if (activeSession != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _ActiveSessionResumeCard(session: activeSession),
            ),
          ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _SectionCard(
              title: 'Streak Summary',
              subtitle: studyStreak.statusMessage,
              child: StreakSummaryRow(
                study: studyStreak,
                attendance: attendanceStreak,
                totalCourseStreaks: totalCourseStreaks,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _CwaSnapshotCard(
              projectedCwa: projectedCwa,
              targetCwa: targetCwa,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _TodayClassesCard(slots: todaySlots),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _FreeBlocksCard(freeBlocks: freeBlocks),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    PlanProgressBar(completed: completed, total: total),
                    if (isDone) ...[
                      const SizedBox(height: 10),
                      const Text(
                        'You crushed it today',
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
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 8),
                      const Text(
                        'Generate a plan or add tasks to shape your day.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        if (tasks.isEmpty)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _EmptyPlanCard(),
            ),
          )
        else ...[
          if (attendTasks.isNotEmpty) ...[
            const _SectionHeader(
              label: 'Planned Classes',
              color: Color(0xFF1565C0),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  child: Card(child: PlanTaskTile(task: attendTasks[i])),
                ),
                childCount: attendTasks.length,
              ),
            ),
          ],
          if (studyTasks.isNotEmpty) ...[
            const _SectionHeader(
              label: 'Suggested Study Tasks',
              color: Color(0xFF1D9E75),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  child: Card(child: PlanTaskTile(task: studyTasks[i])),
                ),
                childCount: studyTasks.length,
              ),
            ),
          ],
          if (personalTasks.isNotEmpty) ...[
            const _SectionHeader(
              label: 'Personal',
              color: Color(0xFFF59E0B),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
                  child: Card(child: PlanTaskTile(task: personalTasks[i])),
                ),
                childCount: personalTasks.length,
              ),
            ),
          ],
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textPrimary),
      title: Text(label),
      onTap: onTap,
    );
  }
}

class _GreetingCard extends StatelessWidget {
  final String greeting;
  final String dateLabel;
  final StreakResult studyStreak;
  final int classCount;

  const _GreetingCard({
    required this.greeting,
    required this.dateLabel,
    required this.studyStreak,
    required this.classCount,
  });

  @override
  Widget build(BuildContext context) {
    final message = classCount == 0
        ? 'No classes on the calendar today. Use the free time well.'
        : '$classCount class${classCount == 1 ? '' : 'es'} on deck today.';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, Color(0xFF3A7C6B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            dateLabel,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            studyStreak.statusMessage,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveSessionResumeCard extends StatelessWidget {
  final ActiveSessionState session;

  const _ActiveSessionResumeCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final subtitle = session.isPomodoroMode
        ? 'Pomodoro in progress for ${session.courseCode}'
        : 'Study session in progress for ${session.courseCode}';

    return _SectionCard(
      title: 'Resume Active Session',
      subtitle: subtitle,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.courseName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Started at ${DateFormat('h:mm a').format(session.startTime)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          FilledButton.icon(
            onPressed: () => context.go('/sessions'),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Resume'),
          ),
        ],
      ),
    );
  }
}

class _CwaSnapshotCard extends StatelessWidget {
  final double projectedCwa;
  final double targetCwa;

  const _CwaSnapshotCard({
    required this.projectedCwa,
    required this.targetCwa,
  });

  @override
  Widget build(BuildContext context) {
    final gap = targetCwa - projectedCwa;
    final helperText = gap <= 0
        ? 'You are on track for your target.'
        : '${gap.toStringAsFixed(1)} points below target right now.';

    return _SectionCard(
      title: 'Current CWA Snapshot',
      subtitle: helperText,
      child: Row(
        children: [
          Expanded(
            child: _MetricChip(
              label: 'Projected',
              value: projectedCwa.toStringAsFixed(1),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricChip(
              label: 'Target',
              value: targetCwa.toStringAsFixed(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayClassesCard extends StatelessWidget {
  final List<TimetableSlotModel> slots;

  const _TodayClassesCard({required this.slots});

  @override
  Widget build(BuildContext context) {
    if (slots.isEmpty) {
      return const _SectionCard(
        title: 'Today\'s Classes',
        subtitle: 'No timetable entries for today.',
        child: _MutedBodyText(
            'Your day is open. You can lean on your plan tasks.'),
      );
    }

    return _SectionCard(
      title: 'Today\'s Classes',
      subtitle:
          '${slots.length} class${slots.length == 1 ? '' : 'es'} scheduled',
      child: Column(
        children: [
          for (final slot in slots.take(3)) ...[
            _InfoRow(
              title: slot.courseCode,
              subtitle:
                  '${slot.startTimeLabel} - ${slot.endTimeLabel} • ${slot.venue}',
            ),
            if (slot != slots.take(3).last)
              const Divider(height: 16, color: Color(0xFFE5E7EB)),
          ],
          if (slots.length > 3) ...[
            const SizedBox(height: 8),
            const _MutedBodyText('Open Table for the full timetable.'),
          ],
        ],
      ),
    );
  }
}

class _FreeBlocksCard extends StatelessWidget {
  final List<FreeBlock> freeBlocks;

  const _FreeBlocksCard({required this.freeBlocks});

  @override
  Widget build(BuildContext context) {
    if (freeBlocks.isEmpty) {
      return const _SectionCard(
        title: 'Free Time Blocks',
        subtitle: 'No major free blocks detected today.',
        child: _MutedBodyText(
          'If you still have short gaps, use them for quick review or admin tasks.',
        ),
      );
    }

    return _SectionCard(
      title: 'Free Time Blocks',
      subtitle: 'Best windows for study or errands',
      child: Column(
        children: [
          for (final block in freeBlocks.take(3)) ...[
            _InfoRow(
              title: '${block.startLabel} - ${block.endLabel}',
              subtitle: '${block.durationMinutes} min available',
            ),
            if (block != freeBlocks.take(3).last)
              const Divider(height: 16, color: Color(0xFFE5E7EB)),
          ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  final String label;
  final String value;

  const _MetricChip({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 4),
          decoration: const BoxDecoration(
            color: AppTheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MutedBodyText extends StatelessWidget {
  final String text;

  const _MutedBodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary),
    );
  }
}

class _EmptyPlanCard extends StatelessWidget {
  const _EmptyPlanCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.checklist_rounded,
              size: 52,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No plan tasks yet',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'Tap Generate to build today\'s plan or use + to add tasks manually.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
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
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
