import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/screens/result_slip_import_screen.dart';

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
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) => _SemesterCard(
              semester: semesters[i],
              onDelete: () => _confirmDelete(context, ref, semesters[i]),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openImport(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Semester'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  void _openImport(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ResultSlipImportScreen()),
    );
  }

  void _confirmDelete(
      BuildContext context, WidgetRef ref, PastSemesterModel semester) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove semester?'),
        content: Text(
          'Remove "${semester.semesterLabel}" from your history? '
          'This will affect your cumulative CWA.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final repo = ref.read(pastResultRepositoryProvider);
              await repo?.delete(semester.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warning,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ─── Semester card ────────────────────────────────────────────────────────────

class _SemesterCard extends StatefulWidget {
  final PastSemesterModel semester;
  final VoidCallback onDelete;

  const _SemesterCard({required this.semester, required this.onDelete});

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
      borderRadius: BorderRadius.circular(14),
      elevation: 1,
      child: Column(
        children: [
          // Header row
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.semester.semesterLabel,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$courseCount course${courseCount == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        size: 20, color: AppTheme.textSecondary),
                    onPressed: widget.onDelete,
                    tooltip: 'Remove',
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          // Expanded course list
          if (_expanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...widget.semester.courses.map(
              (c) => _CourseRow(
                course: c,
                semesterId: widget.semester.id,
              ),
            ),
            const SizedBox(height: 8),
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

  const _CourseRow({required this.course, required this.semesterId});

  @override
  ConsumerState<_CourseRow> createState() => _CourseRowState();
}

class _CourseRowState extends ConsumerState<_CourseRow> {
  late String _grade;
  late double _credits;

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
  }

  Future<void> _save() async {
    final repo = ref.read(pastResultRepositoryProvider);
    if (repo == null) return;
    final all = await repo.getAll();
    final model = all.firstWhere((s) => s.id == widget.semesterId);

    final updatedCourses = model.courses.map((c) {
      if (c.courseCode == widget.course.courseCode &&
          c.courseName == widget.course.courseName) {
        return PastCourseEntry.create(
          courseCode: c.courseCode,
          courseName: c.courseName,
          creditHours: _credits,
          grade: _grade,
        );
      }
      return c;
    }).toList();

    model.courses = updatedCourses;
    await repo.update(model);
  }

  @override
  Widget build(BuildContext context) {
    final color = _gradeColors[_grade] ?? AppTheme.textSecondary;

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
          // Credits stepper (compact)
          Row(
            children: [
              GestureDetector(
                onTap: _credits > 1
                    ? () {
                        setState(() => _credits = (_credits - 1).clamp(1, 6));
                        _save();
                      }
                    : null,
                child: _MiniButton(
                  icon: Icons.remove,
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
                onTap: _credits < 6
                    ? () {
                        setState(() => _credits = (_credits + 1).clamp(1, 6));
                        _save();
                      }
                    : null,
                child: _MiniButton(
                  icon: Icons.add,
                  enabled: _credits < 6,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          // Grade dropdown
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: color.withValues(alpha: 0.3)),
            ),
            child: DropdownButtonHideUnderline(
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

  const _MiniButton({required this.icon, required this.enabled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: enabled
            ? AppTheme.primary.withValues(alpha: 0.1)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        icon,
        size: 13,
        color: enabled ? AppTheme.primary : AppTheme.textSecondary,
      ),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final VoidCallback onImport;
  const _EmptyState({required this.onImport});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_edu_outlined,
                size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No past results yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Import your previous semester result slips to unlock your true cumulative CWA.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.upload_file_outlined),
              label: const Text('Import First Result'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
