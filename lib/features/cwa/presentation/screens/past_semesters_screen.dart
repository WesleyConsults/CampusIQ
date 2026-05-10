import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';

class PastSemestersScreen extends ConsumerWidget {
  const PastSemestersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final semestersAsync = ref.watch(pastSemestersProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Result History'),
      ),
      body: semestersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (semesters) {
          if (semesters.isEmpty) {
            return _EmptyState(
              onImport: () => _openImport(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: semesters.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) => _SemesterCard(
              semester: semesters[i],
              onDelete: () => _confirmDelete(context, ref, semesters[i]),
              onFinalize: semesters[i].isPendingResults
                  ? () => _confirmFinalize(context, ref, semesters[i])
                  : null,
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openImport(context),
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add Semester'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _openImport(BuildContext context) {
    context.pushNamed('cwa-import-results');
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, PastSemesterModel semester) {
    showCampusConfirmDialog(
      context: context,
      title: 'Remove semester?',
      message:
          'Remove "${semester.semesterLabel}" from your history? This will affect your cumulative CWA.',
      confirmLabel: 'Remove',
      destructive: true,
    ).then((confirmed) async {
      if (confirmed != true) return;
      try {
        final repo = ref.read(pastResultRepositoryProvider);
        await repo?.delete(semester.id);
      } catch (e) {
        debugPrint('🔴 PastSemestersScreen delete failed: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not remove semester. Please try again.'),
            ),
          );
        }
      }
    });
  }

  void _confirmFinalize(
    BuildContext context,
    WidgetRef ref,
    PastSemesterModel semester,
  ) {
    showCampusConfirmDialog(
      context: context,
      title: 'Finalize official results?',
      message:
          'This will stop treating "${semester.semesterLabel}" as a pending estimate after every projected placeholder mark has been replaced with an official mark.',
      confirmLabel: 'Finalize',
    ).then((confirmed) async {
      if (confirmed != true) return;
      try {
        final repo = ref.read(pastResultRepositoryProvider);
        if (repo == null) return;
        final latest = await repo.getAll();
        final model = latest.firstWhere((s) => s.id == semester.id);
        final hasMissingMarks =
            model.courses.any((course) => course.mark == null);
        final hasProjectedMarks =
            model.courses.any((course) => course.isProjectedMark);
        if (hasMissingMarks || hasProjectedMarks) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Replace every projected placeholder with an official mark before finalizing.',
                ),
              ),
            );
          }
          return;
        }
        model.isPendingResults = false;
        await repo.update(model);
      } catch (e) {
        debugPrint('🔴 PastSemestersScreen finalize failed: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not finalize results. Please try again.'),
            ),
          );
        }
      }
    });
  }
}

// ─── Semester card ────────────────────────────────────────────────────────────

class _SemesterCard extends StatefulWidget {
  final PastSemesterModel semester;
  final VoidCallback onDelete;
  final VoidCallback? onFinalize;

  const _SemesterCard({
    required this.semester,
    required this.onDelete,
    this.onFinalize,
  });

  @override
  State<_SemesterCard> createState() => _SemesterCardState();
}

class _SemesterCardState extends State<_SemesterCard> {
  bool _expanded = false;

  double get _semCwa {
    if (widget.semester.courses.isEmpty) return 0;
    double totalWeighted = 0;
    double totalCredits = 0;
    for (final c in widget.semester.courses) {
      totalWeighted += c.creditHours * c.score;
      totalCredits += c.creditHours;
    }
    return totalCredits == 0 ? 0 : totalWeighted / totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    final cwa = _semCwa;
    final courseCount = widget.semester.courses.length;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(AppRadii.sm2),
      elevation: 1,
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(AppRadii.sm2),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.semester.semesterLabel,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xxxs),
                            Text(
                              '$courseCount course${courseCount == 1 ? '' : 's'}'
                              '${widget.semester.reportedSemesterCwa != null ? ' • Reported CWA: ${widget.semester.reportedSemesterCwa?.toStringAsFixed(2)}' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppRadii.md2),
                        ),
                        child: Text(
                          cwa.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xxs),
                      IconButton(
                        icon: const Icon(
                          LucideIcons.trash2,
                          size: AppIconSizes.xl,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: widget.onDelete,
                        tooltip: 'Remove',
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Icon(
                          _expanded
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (widget.semester.isPendingResults ||
                      widget.onFinalize != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (widget.semester.isPendingResults)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Text(
                              'Awaiting official marks',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        if (widget.onFinalize != null)
                          TextButton(
                            onPressed: widget.onFinalize,
                            child: const Text('Update Results'),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          // Expanded course list
          if (_expanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            if (widget.semester.isPendingResults)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Text(
                  'Projected marks are placeholders. Replace each one with the official mark from your result slip, then finalize the semester.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ),
            ...widget.semester.courses.map(
              (c) => _CourseRow(
                course: c,
                semesterId: widget.semester.id,
                isPendingResults: widget.semester.isPendingResults,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

// ─── Editable course row ──────────────────────────────────────────────────────

class _CourseRow extends ConsumerStatefulWidget {
  final PastCourseEntry course;
  final int semesterId;
  final bool isPendingResults;

  const _CourseRow({
    required this.course,
    required this.semesterId,
    required this.isPendingResults,
  });

  @override
  ConsumerState<_CourseRow> createState() => _CourseRowState();
}

class _CourseRowState extends ConsumerState<_CourseRow> {
  late String _grade;
  late double _credits;
  double? _mark;
  late bool _isProjectedMark;

  static const _grades = ['A', 'B', 'C', 'D', 'F'];
  static const _gradeColors = {
    'A': Color(0xFF2E7D32),
    'B': Color(0xFF1565C0),
    'C': Color(0xFFF57F17),
    'D': Color(0xFFE65100),
    'F': Color(0xFFC62828),
  };

  @override
  void initState() {
    super.initState();
    _grade = widget.course.grade.toUpperCase();
    _credits = widget.course.creditHours;
    _mark = widget.course.mark;
    _isProjectedMark = widget.course.isProjectedMark;
  }

  Future<void> _save() async {
    final repo = ref.read(pastResultRepositoryProvider);
    if (repo == null) return;
    try {
      final all = await repo.getAll();
      final model = all.firstWhere((s) => s.id == widget.semesterId);

      final updatedCourses = model.courses.map((c) {
        if (c.courseCode == widget.course.courseCode &&
            c.courseName == widget.course.courseName) {
          return PastCourseEntry.create(
            courseCode: c.courseCode,
            courseName: c.courseName,
            creditHours: _credits,
            grade: _mark != null ? _gradeFromScore(_mark!) : _grade,
            mark: _mark,
            isProjectedMark: _isProjectedMark,
          );
        }
        return c;
      }).toList();

      model.courses = updatedCourses;
      await repo.update(model);
    } catch (e) {
      debugPrint('🔴 PastSemestersScreen _save failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Could not save changes. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _gradeColors[_grade] ?? AppTheme.textSecondary;
    final gradeIsDerivedFromMark = _mark != null || widget.isPendingResults;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.course.courseCode,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                    letterSpacing: 0.4,
                  ),
                ),
                Text(
                  widget.course.courseName,
                  style: const TextStyle(
                      fontSize: 13, color: AppTheme.textPrimary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Mark input
          const SizedBox(width: AppSpacing.xs),
          _MarkInput(
            mark: _mark,
            isProjected: _isProjectedMark,
            onChanged: (val) {
              setState(() {
                _mark = val;
                _isProjectedMark = false;
                if (val != null) {
                  _grade = _gradeFromScore(val);
                }
              });
              _save();
            },
          ),
          const SizedBox(width: AppSpacing.xs),
          // Credits stepper (compact)
          Row(
            children: [
              GestureDetector(
                onTap: _credits > 1
                    ? () {
                        setState(() => _credits = (_credits - 1).clamp(1, 12));
                        _save();
                      }
                    : null,
                child: _MiniButton(
                  icon: LucideIcons.minus,
                  enabled: _credits > 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  '${_credits.toInt()}cr',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary),
                ),
              ),
              GestureDetector(
                onTap: _credits < 12
                    ? () {
                        setState(() => _credits = (_credits + 1).clamp(1, 12));
                        _save();
                      }
                    : null,
                child: _MiniButton(
                  icon: Icons.add,
                  enabled: _credits < 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.xs2),
          // Grade display / editor
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadii.xxs),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: gradeIsDerivedFromMark
                ? Text(
                    _grades.contains(_grade) ? _grade : 'F',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: color,
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _grades.contains(_grade) ? _grade : 'F',
                      isDense: true,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: color,
                      ),
                      dropdownColor: Colors.white,
                      items: _grades
                          .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(
                                  g,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: _gradeColors[g] ??
                                        AppTheme.textSecondary,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => _grade = v);
                          _save();
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _MiniButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;

  static const double _size = 22;

  const _MiniButton({required this.icon, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        color: enabled
            ? AppTheme.primary.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppRadii.xs),
      ),
      child: Icon(
        icon,
        size: 13,
        color: enabled ? AppTheme.primary : AppTheme.textSecondary,
      ),
    );
  }
}

class _MarkInput extends StatefulWidget {
  final double? mark;
  final bool isProjected;
  final ValueChanged<double?> onChanged;

  const _MarkInput({
    required this.mark,
    required this.isProjected,
    required this.onChanged,
  });

  @override
  State<_MarkInput> createState() => _MarkInputState();
}

class _MarkInputState extends State<_MarkInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.mark != null ? widget.mark!.toStringAsFixed(0) : '',
    );
  }

  @override
  void didUpdateWidget(covariant _MarkInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mark != oldWidget.mark) {
      final newText =
          widget.mark != null ? widget.mark!.toStringAsFixed(0) : '';
      if (_controller.text != newText) {
        _controller.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 28,
      child: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: widget.isProjected
              ? Colors.orange.withValues(alpha: 0.12)
              : AppTheme.primary.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadii.xxs),
            borderSide: BorderSide.none,
          ),
          hintText: widget.isProjected ? 'proj' : '-',
        ),
        onChanged: (val) {
          final number = double.tryParse(val);
          widget.onChanged(number);
        },
      ),
    );
  }
}

String _gradeFromScore(double score) {
  if (score >= 80) return 'A';
  if (score >= 70) return 'B';
  if (score >= 60) return 'C';
  if (score >= 50) return 'D';
  return 'F';
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onImport;
  const _EmptyState({required this.onImport});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.graduationCap,
                size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No past results yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Import your previous semester result slips to unlock your true cumulative CWA.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.xxl),
            ElevatedButton.icon(
              onPressed: onImport,
              icon: const Icon(LucideIcons.fileUp),
              label: const Text('Import First Result'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
