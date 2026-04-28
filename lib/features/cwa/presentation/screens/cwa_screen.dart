import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/constants/app_constants.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/cwa_summary_bar.dart';
import 'package:campusiq/features/cwa/presentation/widgets/course_card.dart';
import 'package:campusiq/features/cwa/presentation/widgets/add_course_sheet.dart';
import 'package:campusiq/features/cwa/presentation/widgets/cwa_coach_sheet.dart';
import 'package:campusiq/features/cwa/presentation/screens/registration_slip_import_screen.dart';
import 'package:campusiq/features/cwa/presentation/screens/past_semesters_screen.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_action_button.dart';

class CwaScreen extends ConsumerWidget {
  const CwaScreen({super.key});

  Future<void> _openAddSheet(BuildContext context, WidgetRef ref,
      {CourseModel? existing}) async {
    final result = await showModalBottomSheet<CourseModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddCourseSheet(
        semesterKey: ref.read(activeSemesterProvider),
        existing: existing,
      ),
    );

    if (result == null) return;
    final repo = ref.read(cwaRepositoryProvider);
    if (repo == null) return;

    try {
      existing == null
          ? await repo.addCourse(result)
          : await repo.updateCourse(result);
    } catch (e) {
      debugPrint('🔴 CwaScreen _openAddSheet failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not save course. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(cwaViewModeProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(AppConstants.appName,
            style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          const StreakActionButton(),
          if (viewMode == CwaViewMode.semester) ...[
            IconButton(
              icon: const Icon(Icons.document_scanner_outlined),
              tooltip: 'Scan registration slip',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const RegistrationSlipImportScreen(),
                ),
              ),
            ),
          ],
          if (viewMode == CwaViewMode.cumulative) ...[
            IconButton(
              icon: const Icon(Icons.history_edu_outlined),
              tooltip: 'Manage result history',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const PastSemestersScreen(),
                ),
              ),
            ),
          ],
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Set target CWA',
            onPressed: () => _showTargetDialog(
              context,
              ref,
              ref.read(targetCwaProvider),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Mode toggle ──────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: _ViewToggle(
              mode: viewMode,
              onChanged: (m) =>
                  ref.read(cwaViewModeProvider.notifier).state = m,
            ),
          ),
          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: viewMode == CwaViewMode.semester
                ? _SemesterView(onOpenAddSheet: _openAddSheet)
                : const _CumulativeView(),
          ),
        ],
      ),
      floatingActionButton: viewMode == CwaViewMode.semester
          ? FloatingActionButton.extended(
              onPressed: () => _openAddSheet(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Add Course'),
            )
          : FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const PastSemestersScreen()),
              ),
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Add Semester'),
            ),
    );
  }

  void _showTargetDialog(
      BuildContext context, WidgetRef ref, double current) {
    double temp = current;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Target CWA'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    color: AppTheme.primary,
                    iconSize: 32,
                    onPressed: temp > 40
                        ? () => setState(
                            () => temp = (temp - 1).clamp(40, 100))
                        : null,
                  ),
                  Text(
                    '${temp.toInt()}',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    color: AppTheme.primary,
                    iconSize: 32,
                    onPressed: temp < 100
                        ? () => setState(
                            () => temp = (temp + 1).clamp(40, 100))
                        : null,
                  ),
                ],
              ),
              Slider(
                value: temp,
                min: 40,
                max: 100,
                divisions: 60,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => temp = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(targetCwaProvider.notifier).state = temp;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}

// ─── Toggle widget ────────────────────────────────────────────────────────────

class _ViewToggle extends StatelessWidget {
  final CwaViewMode mode;
  final ValueChanged<CwaViewMode> onChanged;

  const _ViewToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _ToggleTab(
            label: 'Semester',
            active: mode == CwaViewMode.semester,
            onTap: () => onChanged(CwaViewMode.semester),
          ),
          _ToggleTab(
            label: 'Cumulative',
            active: mode == CwaViewMode.cumulative,
            onTap: () => onChanged(CwaViewMode.cumulative),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleTab(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Semester view (existing behaviour) ──────────────────────────────────────

class _SemesterView extends ConsumerWidget {
  final Future<void> Function(BuildContext, WidgetRef, {CourseModel? existing})
      onOpenAddSheet;

  const _SemesterView({required this.onOpenAddSheet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final projected = ref.watch(projectedCwaProvider);
    final target = ref.watch(targetCwaProvider);
    final gap = ref.watch(cwaGapProvider);

    return coursesAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (courses) {
        final pairs = courses
            .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
            .toList();
        final highImpactIndices =
            CwaCalculator.highestImpactCourseIndices(pairs);

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child:
                    CwaSummaryBar(projected: projected, target: target, gap: gap),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextButton.icon(
                  onPressed: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const CwaCoachSheet(),
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Get AI Coaching'),
                  style:
                      TextButton.styleFrom(foregroundColor: AppTheme.primary),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('My Courses',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    Text('${courses.length} courses',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13)),
                  ],
                ),
              ),
            ),
            if (courses.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.school_outlined,
                          size: 56, color: AppTheme.textSecondary),
                      SizedBox(height: 12),
                      Text('No courses yet',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 15)),
                      SizedBox(height: 4),
                      Text('Tap + to add your first course',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final course = courses[i];
                    final repo = ref.read(cwaRepositoryProvider);
                    return CourseCard(
                      course: course,
                      isHighImpact: highImpactIndices.contains(i),
                      onEdit: () =>
                          onOpenAddSheet(context, ref, existing: course),
                      onDelete: () async {
                        try {
                          await repo?.deleteCourse(course.id);
                        } catch (e) {
                          debugPrint('🔴 CwaScreen deleteCourse failed: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Could not delete course. Please try again.')),
                            );
                          }
                        }
                      },
                      onScoreChanged: (newScore) async {
                        course.expectedScore = newScore;
                        await repo?.updateCourse(course);
                      },
                    );
                  },
                  childCount: courses.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 80)),
          ],
        );
      },
    );
  }
}

// ─── Cumulative view ──────────────────────────────────────────────────────────

class _CumulativeView extends ConsumerWidget {
  const _CumulativeView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semestersAsync = ref.watch(pastSemestersProvider);
    final currentCoursesAsync = ref.watch(coursesProvider);
    final cumulativeCwa = ref.watch(cumulativeCwaProvider);
    final totalCredits = ref.watch(totalCreditsProvider);
    final target = ref.watch(targetCwaProvider);
    final gap = ref.watch(cumulativeGapProvider);

    return semestersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (semesters) {
        final currentCourses =
            currentCoursesAsync.valueOrNull ?? [];

        final hasPast = semesters.isNotEmpty;
        final hasCurrent = currentCourses.isNotEmpty;

        return CustomScrollView(
          slivers: [
            // ── Cumulative summary bar ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CwaSummaryBar(
                  projected: cumulativeCwa,
                  target: target,
                  gap: gap,
                  label: 'Cumulative CWA',
                ),
              ),
            ),
            // ── Total credits pill ───────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${totalCredits.toInt()} total credit hours',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${semesters.length + (hasCurrent ? 1 : 0)} semester${semesters.length + (hasCurrent ? 1 : 0) == 1 ? '' : 's'}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ),

            // ── No history banner ────────────────────────────────────────
            if (!hasPast)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: _NoHistoryBanner(
                    onAdd: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const PastSemestersScreen()),
                    ),
                  ),
                ),
              ),

            // ── Past semesters ───────────────────────────────────────────
            if (hasPast) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text(
                    'Past Semesters',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: _PastSemesterSummaryCard(semester: semesters[i]),
                  ),
                  childCount: semesters.length,
                ),
              ),
            ],

            // ── Current semester ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Text(
                      'Current Semester',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'In progress',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!hasCurrent)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'No courses added yet. Switch to Semester view to add courses.',
                    style: TextStyle(
                        fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final c = currentCourses[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 3),
                      child: _CurrentCourseRow(course: c),
                    );
                  },
                  childCount: currentCourses.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }
}

// ─── Past semester summary card (read-only, collapsible) ─────────────────────

class _PastSemesterSummaryCard extends StatefulWidget {
  final PastSemesterModel semester;
  const _PastSemesterSummaryCard({required this.semester});

  @override
  State<_PastSemesterSummaryCard> createState() =>
      _PastSemesterSummaryCardState();
}

class _PastSemesterSummaryCardState extends State<_PastSemesterSummaryCard> {
  bool _expanded = false;

  double get _semCwa {
    if (widget.semester.courses.isEmpty) return 0;
    double w = 0, cr = 0;
    for (final c in widget.semester.courses) {
      w += c.creditHours * c.score;
      cr += c.creditHours;
    }
    return cr == 0 ? 0 : w / cr;
  }

  @override
  Widget build(BuildContext context) {
    final cwa = _semCwa;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      elevation: 0.5,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.semester.semesterLabel,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.textPrimary),
                        ),
                        Text(
                          '${widget.semester.courses.length} courses'
                          '${widget.semester.reportedSemesterCwa != null ? ' • Slip: ${widget.semester.reportedSemesterCwa!.toStringAsFixed(2)}' : ''}',
                          style: const TextStyle(
                              fontSize: 12, color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      cwa.toStringAsFixed(1),
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.primary),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1, indent: 14, endIndent: 14),
            ...widget.semester.courses.map(
              (c) => Padding(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 2),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.courseCode,
                              style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary,
                                  letterSpacing: 0.4)),
                          Text(c.courseName,
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Text(
                      '${c.creditHours.toInt()}cr',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(width: 8),
                    // Show the actual score used in CWA calculation.
                    // If mark is null the code falls back to a grade midpoint —
                    // flag that so the user knows to enter the real mark.
                    _ScorePill(mark: c.mark, score: c.score),
                    const SizedBox(width: 6),
                    _GradePill(grade: c.grade),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

// ─── Current course row (read-only in cumulative view) ────────────────────────

class _CurrentCourseRow extends StatelessWidget {
  final CourseModel course;
  const _CurrentCourseRow({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.code,
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                      letterSpacing: 0.4),
                ),
                Text(
                  course.name,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            '${course.creditHours.toInt()}cr',
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
          const SizedBox(width: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${course.expectedScore.toInt()}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Score pill (shows exact mark or grade approximation with warning) ────────

class _ScorePill extends StatelessWidget {
  /// Null means no mark was imported; [score] is then a grade midpoint estimate.
  final double? mark;
  final double score;

  const _ScorePill({required this.mark, required this.score});

  @override
  Widget build(BuildContext context) {
    final isApprox = mark == null;
    return Tooltip(
      message: isApprox
          ? 'Estimated from grade — enter the exact mark in Result History for accuracy'
          : 'Exact mark used in CWA calculation',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: isApprox
              ? const Color(0xFFF57F17).withValues(alpha: 0.10)
              : AppTheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: isApprox
                ? const Color(0xFFF57F17).withValues(alpha: 0.35)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isApprox
                    ? const Color(0xFFF57F17)
                    : AppTheme.primary,
              ),
            ),
            if (isApprox) ...[
              const SizedBox(width: 2),
              const Icon(Icons.warning_amber_rounded,
                  size: 10, color: Color(0xFFF57F17)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Grade pill ───────────────────────────────────────────────────────────────

class _GradePill extends StatelessWidget {
  final String grade;

  static const _colors = {
    'A': Color(0xFF2E7D32),
    'B': Color(0xFF1565C0),
    'C': Color(0xFFF57F17),
    'D': Color(0xFFE65100),
    'F': Color(0xFFC62828),
  };

  const _GradePill({required this.grade});

  @override
  Widget build(BuildContext context) {
    final color = _colors[grade.toUpperCase()] ?? AppTheme.textSecondary;
    return Container(
      width: 28,
      height: 24,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
      ),
      alignment: Alignment.center,
      child: Text(
        grade.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// ─── No history banner ────────────────────────────────────────────────────────

class _NoHistoryBanner extends StatelessWidget {
  final VoidCallback onAdd;
  const _NoHistoryBanner({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Import past result slips to see your true CWA across all years.',
              style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
            ),
          ),
          TextButton(
            onPressed: onAdd,
            child: const Text('Import',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }
}
