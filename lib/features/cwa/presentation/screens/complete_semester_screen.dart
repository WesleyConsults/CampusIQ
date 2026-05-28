import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/data/repositories/past_result_repository.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/active_semester_picker.dart';
import 'package:campusiq/features/cwa/presentation/widgets/grade_value_dropdown.dart';
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';

class CompleteSemesterScreen extends ConsumerStatefulWidget {
  final String currentSemesterKey;
  final List<CourseModel> courses;

  const CompleteSemesterScreen({
    super.key,
    required this.currentSemesterKey,
    required this.courses,
  });

  @override
  ConsumerState<CompleteSemesterScreen> createState() =>
      _CompleteSemesterScreenState();
}

class _CompleteSemesterScreenState
    extends ConsumerState<CompleteSemesterScreen> {
  late final List<_CompletedCourseDraft> _courses;
  bool _isSaving = false;
  late int _nextStartYear;
  late int _nextSemesterNumber;

  ActiveSemesterSelection get _currentSemester =>
      ActiveSemesterSelection.fromKey(widget.currentSemesterKey);

  ActiveSemesterSelection get _nextSemester => ActiveSemesterSelection(
        startYear: _nextStartYear,
        semesterNumber: _nextSemesterNumber,
      );

  GradingSystem get _gradingSystem {
    if (widget.courses.isEmpty) return ref.read(gradingSystemProvider);
    return GradingSystem.byId(widget.courses.first.gradingSystemId);
  }

  List<int> get _yearOptions {
    final now = DateTime.now();
    final currentAcademicYear = now.month >= 8 ? now.year : now.year - 1;
    final options = {_nextStartYear, currentAcademicYear};
    for (var y = currentAcademicYear - 4; y <= currentAcademicYear + 4; y++) {
      options.add(y);
    }
    final sorted = options.toList()..sort();
    return sorted;
  }

  double get _previewCwa {
    final pairs = _courses
        .map((course) => (creditHours: course.creditHours, score: course.score))
        .toList();
    return CwaCalculator.calculate(pairs);
  }

  double get _totalCredits =>
      _courses.fold(0.0, (sum, course) => sum + course.creditHours);

  @override
  void initState() {
    super.initState();
    final autoNext =
        ActiveSemesterSelection.fromKey(widget.currentSemesterKey).next;
    _nextStartYear = autoNext.startYear;
    _nextSemesterNumber = autoNext.semesterNumber;

    final sortedCourses = [...widget.courses]
      ..sort((a, b) => a.code.compareTo(b.code));
    final gradingSystem = _gradingSystem;
    _courses = sortedCourses
        .map(
            (course) => _CompletedCourseDraft.fromCourse(course, gradingSystem))
        .toList();
  }

  bool get _hasAllMarks => _courses.every((course) => course.mark != null);

  Future<void> _saveOfficialResults() async {
    if (_isSaving || _courses.isEmpty) return;
    if (!_hasAllMarks) {
      _showMessage(
        _gradingSystem.usesLetterGrades
            ? 'Choose the actual grade for every course before saving official results.'
            : 'Enter the actual mark for every course before saving official results.',
      );
      return;
    }

    final shouldComplete = await showCampusConfirmDialog(
          context: context,
          title: 'Save official results?',
          message:
              'This will save your actual marks, clear the current projected courses, and move you to ${_nextSemester.displayLabel}.',
          confirmLabel: 'Save',
        ) ??
        false;
    if (!shouldComplete) return;

    final repo = ref.read(pastResultRepositoryProvider);
    if (repo == null) {
      _showMessage('Your semester history is not ready yet. Please try again.');
      return;
    }
    final replaceExisting = await _confirmReplaceExistingSemester(repo);
    if (replaceExisting == null) return;

    final gradingSystemId = widget.courses.isEmpty
        ? ref.read(gradingSystemProvider).id
        : widget.courses.first.gradingSystemId;
    setState(() => _isSaving = true);
    try {
      final completedSemester = PastSemesterModel.create(
        semesterLabel: formatActiveSemesterLabel(widget.currentSemesterKey),
        semesterKey: widget.currentSemesterKey,
        gradingSystemId: gradingSystemId,
        courses: _courses
            .map(
              (course) => PastCourseEntry.create(
                courseCode: course.code,
                courseName: course.name,
                creditHours: course.creditHours,
                grade: _gradingSystem.gradeForScore(course.mark!),
                mark: course.mark!,
              ),
            )
            .toList(),
      );

      await repo.transitionSemester(
        currentSemesterKey: widget.currentSemesterKey,
        nextSemesterKey: _nextSemester.key,
        archivedSemester: completedSemester,
        replaceExistingSemester: replaceExisting,
      );

      if (!mounted) return;
      ref.invalidate(coursesProvider);
      ref.invalidate(pastSemestersProvider);
      ref.invalidate(projectedCwaProvider);
      ref.invalidate(cwaGapProvider);
      ref.invalidate(cumulativeCwaProvider);
      ref.invalidate(officialRecordedCwaProvider);
      ref.invalidate(pendingPastSemestersProvider);
      ref.invalidate(officialPastSemestersProvider);
      ref.invalidate(totalCreditsProvider);
      ref.invalidate(cumulativeGapProvider);
      Navigator.of(context).pop(_nextSemester.displayLabel);
    } on StateError catch (e) {
      _showMessage(e.message);
    } catch (e) {
      debugPrint('🔴 CompleteSemesterScreen _save failed: $e');
      _showMessage('Could not complete this semester. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _startNextSemesterWithoutResults() async {
    if (_isSaving || _courses.isEmpty) return;

    final shouldArchive = await showCampusConfirmDialog(
          context: context,
          title: 'Start next semester now?',
          message:
              'This will archive ${_currentSemester.displayLabel} as awaiting official results, carry forward projected marks as placeholders, and move you to ${_nextSemester.displayLabel}.',
          confirmLabel: 'Start next semester',
        ) ??
        false;
    if (!shouldArchive) return;

    final repo = ref.read(pastResultRepositoryProvider);
    if (repo == null) {
      _showMessage('Your semester history is not ready yet. Please try again.');
      return;
    }
    final replaceExisting = await _confirmReplaceExistingSemester(repo);
    if (replaceExisting == null) return;

    final gradingSystemId = widget.courses.isEmpty
        ? ref.read(gradingSystemProvider).id
        : widget.courses.first.gradingSystemId;
    setState(() => _isSaving = true);
    try {
      final pendingSemester = PastSemesterModel.create(
        semesterLabel: formatActiveSemesterLabel(widget.currentSemesterKey),
        semesterKey: widget.currentSemesterKey,
        gradingSystemId: gradingSystemId,
        isPendingResults: true,
        courses: _courses
            .map(
              (course) => PastCourseEntry.create(
                courseCode: course.code,
                courseName: course.name,
                creditHours: course.creditHours,
                grade: _gradingSystem.gradeForScore(course.projectedScore),
                mark: course.projectedScore,
                isProjectedMark: true,
              ),
            )
            .toList(),
      );

      await repo.transitionSemester(
        currentSemesterKey: widget.currentSemesterKey,
        nextSemesterKey: _nextSemester.key,
        archivedSemester: pendingSemester,
        replaceExistingSemester: replaceExisting,
      );

      if (!mounted) return;
      ref.invalidate(coursesProvider);
      ref.invalidate(pastSemestersProvider);
      ref.invalidate(projectedCwaProvider);
      ref.invalidate(cwaGapProvider);
      ref.invalidate(cumulativeCwaProvider);
      ref.invalidate(officialRecordedCwaProvider);
      ref.invalidate(pendingPastSemestersProvider);
      ref.invalidate(officialPastSemestersProvider);
      ref.invalidate(totalCreditsProvider);
      ref.invalidate(cumulativeGapProvider);
      Navigator.of(context).pop(_nextSemester.displayLabel);
    } catch (e) {
      debugPrint('🔴 CompleteSemesterScreen _startNextSemester failed: $e');
      _showMessage('Could not archive this semester. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool?> _confirmReplaceExistingSemester(
    PastResultRepository repo,
  ) async {
    final existing = await repo.findBySemesterKey(widget.currentSemesterKey);
    if (existing == null) return false;
    if (!mounted) return null;

    final shouldReplace = await showCampusConfirmDialog(
          context: context,
          title: 'Replace existing semester?',
          message:
              'You already have results for "${existing.semesterLabel}". Replacing it prevents this semester from being counted twice.',
          confirmLabel: 'Replace',
          cancelLabel: 'Cancel',
          destructive: true,
        ) ??
        false;
    return shouldReplace ? true : null;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Complete Semester',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.md,
                  AppSpacing.md,
                  120,
                ),
                children: [
                  _SummaryCard(
                    currentSemesterLabel: _currentSemester.displayLabel,
                    nextSemesterRow: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xxs),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.arrowRight,
                                size: AppIconSizes.md,
                                color: colorScheme.primary,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                'Move to',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: _nextStartYear,
                                  isDense: true,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Year',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                  ),
                                  items: _yearOptions
                                      .map((y) => DropdownMenuItem<int>(
                                            value: y,
                                            child: Text(
                                              '$y/${y + 1}',
                                              overflow: TextOverflow.ellipsis,
                                              style:
                                                  const TextStyle(fontSize: 13),
                                            ),
                                          ))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _nextStartYear = v);
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Expanded(
                                child: DropdownButtonFormField<int>(
                                  initialValue: _nextSemesterNumber,
                                  isDense: true,
                                  isExpanded: true,
                                  decoration: const InputDecoration(
                                    labelText: 'Sem',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 10,
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 1,
                                      child: Text(
                                        'First',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    DropdownMenuItem(
                                      value: 2,
                                      child: Text(
                                        'Second',
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(fontSize: 13),
                                      ),
                                    ),
                                  ],
                                  onChanged: (v) {
                                    if (v != null) {
                                      setState(() => _nextSemesterNumber = v);
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    courseCount: _courses.length,
                    totalCredits: _totalCredits,
                    previewCwa: _previewCwa,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(AppRadii.sm),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                      ),
                    ),
                    child: Text(
                      _gradingSystem.usesLetterGrades
                          ? 'Grades are the source of truth here. Choose the actual grade for each course. If official results are not out yet, you can still archive this semester and move on.'
                          : 'Marks are the source of truth here. Enter the actual mark for each course and UniMate will derive the letter grade automatically. If official results are not out yet, you can still archive this semester and move on.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  for (final course in _courses) ...[
                    _CompletedCourseCard(
                      key: ValueKey(course.code),
                      course: course,
                      gradingSystem: _gradingSystem,
                      onMarkChanged: (mark) {
                        setState(() {
                          course.mark = mark;
                        });
                      },
                    ),
                    if (course != _courses.last)
                      const SizedBox(height: AppSpacing.sm),
                  ],
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveOfficialResults,
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(LucideIcons.badgeCheck),
                        label: Text(
                          _isSaving
                              ? 'Saving...'
                              : 'Save Official Results & Move On',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed:
                            _isSaving ? null : _startNextSemesterWithoutResults,
                        icon: const Icon(LucideIcons.arrowRight),
                        label: const Text(
                            'Start Next Semester Without Results Yet'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(
                            color: colorScheme.primary.withValues(alpha: 0.45),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Official save requires marks. The secondary action stores this semester as pending results and still moves you to ${_nextSemester.displayLabel}.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String currentSemesterLabel;
  final Widget nextSemesterRow;
  final int courseCount;
  final double totalCredits;
  final double previewCwa;

  const _SummaryCard({
    required this.currentSemesterLabel,
    required this.nextSemesterRow,
    required this.courseCount,
    required this.totalCredits,
    required this.previewCwa,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadii.sm2),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Semester handoff',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
            icon: LucideIcons.calendarRange,
            label: 'Completing',
            value: currentSemesterLabel,
          ),
          const SizedBox(height: AppSpacing.xs),
          nextSemesterRow,
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Courses',
                  value: '$courseCount',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  label: 'Credits',
                  value: '${totalCredits.toInt()} cr',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _MiniStat(
                  label: 'Preview CWA',
                  value: previewCwa.toStringAsFixed(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;

  const _MiniStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 96,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppIconSizes.md, color: colorScheme.primary),
        const SizedBox(width: AppSpacing.xs),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ).copyWith(color: colorScheme.onSurface),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    height: 1.4,
                  ).copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompletedCourseCard extends StatelessWidget {
  final _CompletedCourseDraft course;
  final GradingSystem gradingSystem;
  final ValueChanged<double?> onMarkChanged;

  const _CompletedCourseCard({
    super.key,
    required this.course,
    required this.gradingSystem,
    required this.onMarkChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadii.sm2),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
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
                      course.code,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ).copyWith(color: colorScheme.primary),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      course.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ).copyWith(color: colorScheme.onSurface),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xxs,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadii.sm),
                ),
                child: Text(
                  '${course.creditHours.toInt()} cr',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ).copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Projected ${gradingSystem.label}: ${gradingSystem.formatScore(course.projectedScore, includeUnit: true)}',
            style: const TextStyle(
              fontSize: 12,
            ).copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Derived Grade',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    course.derivedGrade,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: gradingSystem.usesLetterGrades
                    ? GradeValueDropdown(
                        gradingSystem: gradingSystem,
                        value: course.mark ?? course.projectedScore,
                        label: 'Actual Grade',
                        onChanged: onMarkChanged,
                      )
                    : _MarkField(
                        mark: course.mark,
                        onChanged: onMarkChanged,
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MarkField extends StatefulWidget {
  final double? mark;
  final ValueChanged<double?> onChanged;

  const _MarkField({
    required this.mark,
    required this.onChanged,
  });

  @override
  State<_MarkField> createState() => _MarkFieldState();
}

class _MarkFieldState extends State<_MarkField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.mark != null ? widget.mark!.toStringAsFixed(0) : '',
    );
  }

  @override
  void didUpdateWidget(covariant _MarkField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.mark != oldWidget.mark) {
      final nextText =
          widget.mark != null ? widget.mark!.toStringAsFixed(0) : '';
      if (_controller.text != nextText) {
        _controller.text = nextText;
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
    return TextField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: 'Actual Mark',
        border: OutlineInputBorder(),
      ),
      onChanged: (value) {
        final parsed = double.tryParse(value);
        if (parsed == null) {
          widget.onChanged(null);
          return;
        }
        widget.onChanged(parsed.clamp(0, 100).toDouble());
      },
    );
  }
}

class _CompletedCourseDraft {
  final String code;
  final String name;
  final double creditHours;
  final double projectedScore;
  final String gradingSystemId;
  double? mark;

  _CompletedCourseDraft({
    required this.code,
    required this.name,
    required this.creditHours,
    required this.projectedScore,
    required this.gradingSystemId,
    required this.mark,
  });

  factory _CompletedCourseDraft.fromCourse(
    CourseModel course,
    GradingSystem gradingSystem,
  ) {
    return _CompletedCourseDraft(
      code: course.code.trim().toUpperCase(),
      name: course.name.trim(),
      creditHours: course.creditHours,
      projectedScore: course.expectedScore,
      gradingSystemId: gradingSystem.id,
      mark: gradingSystem.usesLetterGrades ? course.expectedScore : null,
    );
  }

  String get derivedGrade =>
      GradingSystem.byId(gradingSystemId).gradeForScore(mark ?? projectedScore);

  double get score {
    return mark ?? projectedScore;
  }
}
