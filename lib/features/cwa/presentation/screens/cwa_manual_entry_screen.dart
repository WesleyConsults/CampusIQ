import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/shared/widgets/campus_confirm_dialog.dart';

class CwaManualEntryScreen extends ConsumerStatefulWidget {
  final String mode;

  const CwaManualEntryScreen({
    super.key,
    required this.mode,
  });

  @override
  ConsumerState<CwaManualEntryScreen> createState() =>
      _CwaManualEntryScreenState();
}

class _CwaManualEntryScreenState extends ConsumerState<CwaManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final List<_CourseDraft> _courses = [];

  late CwaViewMode _mode;
  late CwaViewMode _initialMode;
  String _academicYear = _academicYears.first;
  String _semesterLabel = _semesters.first;
  String _programme = _programmes.first;
  String _level = _levels.last;
  bool _isSaving = false;
  bool _showDuplicateWarning = false;

  static const _academicYears = [
    '2023/2024',
    '2024/2025',
    '2025/2026',
    '2026/2027',
  ];

  static const _semesters = [
    'First Semester',
    'Second Semester',
  ];

  static const _programmes = [
    'Computer Engineering',
    'Electrical Engineering',
    'Mechanical Engineering',
    'Computer Science',
    'Information Technology',
  ];

  static const _levels = ['100', '200', '300', '400', '500'];

  @override
  void initState() {
    super.initState();
    _mode = widget.mode == 'cumulative'
        ? CwaViewMode.cumulative
        : CwaViewMode.semester;
    _initialMode = _mode;
    _courses.add(_CourseDraft()..addListener(_refreshDerivedState));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    for (final course in _courses) {
      course.dispose();
    }
    super.dispose();
  }

  bool get _hasDuplicateCodes {
    final seen = <String>{};
    for (final course in _courses) {
      final code = course.codeController.text.trim().toUpperCase();
      if (code.isEmpty) continue;
      if (!seen.add(code)) return true;
    }
    return false;
  }

  bool get _hasUnsavedChanges {
    if (_mode != _initialMode ||
        _academicYear != _academicYears.first ||
        _semesterLabel != _semesters.first ||
        _programme != _programmes.first ||
        _level != _levels.last ||
        _courses.length > 1) {
      return true;
    }

    final firstCourse = _courses.first;
    return firstCourse.codeController.text.trim().isNotEmpty ||
        firstCourse.titleController.text.trim().isNotEmpty ||
        firstCourse.creditsController.text.trim().isNotEmpty ||
        firstCourse.scoreController.text.trim() != '70';
  }

  int get _coursesAdded => _courses.length;

  double get _totalCredits {
    return _courses.fold<double>(0, (sum, course) {
      return sum + (double.tryParse(course.creditsController.text.trim()) ?? 0);
    });
  }

  double get _estimatedCwa {
    final pairs = <({double creditHours, double score})>[];
    for (final course in _courses) {
      final credits = double.tryParse(course.creditsController.text.trim());
      final score = double.tryParse(course.scoreController.text.trim());
      if (credits == null || score == null || credits <= 0) continue;
      pairs.add((creditHours: credits, score: score.clamp(0, 100)));
    }
    if (pairs.isEmpty) return 0;
    return CwaCalculator.calculate(pairs);
  }

  void _refreshDerivedState() {
    if (!mounted) return;
    setState(() {
      _showDuplicateWarning = _hasDuplicateCodes;
    });
  }

  void _addCourse() {
    setState(() {
      _courses.add(_CourseDraft()..addListener(_refreshDerivedState));
      _showDuplicateWarning = _hasDuplicateCodes;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
    });
  }

  void _removeCourse(_CourseDraft course) {
    if (_courses.length == 1) return;
    setState(() {
      _courses.remove(course);
      course.dispose();
      _showDuplicateWarning = _hasDuplicateCodes;
    });
  }

  void _onModeChanged(CwaViewMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
    });
  }

  void _syncCwaMode() {
    ref.read(cwaViewModeProvider.notifier).state = _mode;
  }

  Future<void> _saveCourses() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? false;
    final hasDuplicates = _hasDuplicateCodes;

    setState(() {
      _showDuplicateWarning = hasDuplicates;
    });

    if (!isValid) return;
    if (hasDuplicates) {
      _showMessage('Duplicate course codes found. Please fix them first.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_mode == CwaViewMode.semester) {
        await _saveSemesterCourses();
      } else {
        await _saveCumulativeRecord();
      }

      if (!mounted) return;
      _syncCwaMode();
      ref.invalidate(coursesProvider);
      ref.invalidate(pastSemestersProvider);
      ref.invalidate(projectedCwaProvider);
      ref.invalidate(cwaGapProvider);
      ref.invalidate(cumulativeCwaProvider);
      ref.invalidate(totalCreditsProvider);
      ref.invalidate(cumulativeGapProvider);
      _showMessage('Courses saved successfully.');
      _closeToCwa();
    } on StateError catch (e) {
      _showMessage(e.message);
    } catch (e) {
      _showMessage('Could not save courses. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveSemesterCourses() async {
    final repo = ref.read(cwaRepositoryProvider);
    if (repo == null) throw Exception('CWA repository unavailable');

    final semesterKey = ref.read(activeSemesterProvider);
    final normalizedCodes = _courses
        .map((course) => course.codeController.text.trim().toUpperCase())
        .toList();

    for (final code in normalizedCodes) {
      final exists = await repo.courseExistsByCode(code, semesterKey);
      if (exists) {
        throw StateError(
          '$code already exists in the current semester. Edit it from CWA instead of creating a duplicate.',
        );
      }
    }

    for (final course in _courses) {
      final credits = double.parse(course.creditsController.text.trim());
      final score = double.parse(course.scoreController.text.trim());
      await repo.addCourse(
        CourseModel.create(
          name: course.titleController.text.trim(),
          code: course.codeController.text.trim().toUpperCase(),
          creditHours: credits,
          expectedScore: score,
          semesterKey: semesterKey,
        ),
      );
    }
  }

  Future<void> _saveCumulativeRecord() async {
    final repo = ref.read(pastResultRepositoryProvider);
    if (repo == null) throw Exception('Past result repository unavailable');

    final entries = _courses.map((course) {
      final credits = double.parse(course.creditsController.text.trim());
      final score = double.parse(course.scoreController.text.trim());
      return PastCourseEntry.create(
        courseCode: course.codeController.text.trim().toUpperCase(),
        courseName: course.titleController.text.trim(),
        creditHours: credits,
        grade: _gradeFromScore(score),
        mark: score,
      );
    }).toList();

    await repo.add(
      PastSemesterModel.create(
        semesterLabel: _buildSemesterLabel(),
        courses: entries,
      ),
    );
  }

  String _buildSemesterLabel() {
    return '$_academicYear • $_semesterLabel • L$_level • $_programme';
  }

  String _gradeFromScore(double score) {
    if (score >= 80) return 'A';
    if (score >= 70) return 'B';
    if (score >= 60) return 'C';
    if (score >= 50) return 'D';
    return 'F';
  }

  void _saveDraft() {
    _showMessage('Draft saving is coming in a later phase.');
  }

  Future<void> _cancel() async {
    final shouldLeave = await _confirmDiscardIfNeeded();
    if (!shouldLeave || !mounted) return;
    _syncCwaMode();
    _closeToCwa();
  }

  Future<bool> _confirmDiscardIfNeeded() async {
    if (_isSaving || !_hasUnsavedChanges) return true;

    final shouldDiscard = await showCampusConfirmDialog(
          context: context,
          title: 'Discard changes?',
          message: 'Your manual course entries have not been saved yet.',
          confirmLabel: 'Discard',
          cancelLabel: 'Keep editing',
        ) ??
        false;

    return shouldDiscard;
  }

  void _closeToCwa() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/cwa');
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
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final helperText = _mode == CwaViewMode.semester
        ? 'Mode: Semester\nAdd your semester courses manually.'
        : 'Mode: Cumulative\nAdd courses from a completed semester.';
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        if (_isSaving) return;
        final shouldLeave = await _confirmDiscardIfNeeded();
        if (!shouldLeave) return;
        _syncCwaMode();
        if (navigator.canPop()) {
          navigator.pop();
          return;
        }
        router.go('/cwa');
      },
      child: Scaffold(
        backgroundColor: AppTheme.surface,
        appBar: AppBar(
          leading: BackButton(onPressed: _cancel),
          title: const Text(
            'Enter Courses Manually',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving ? null : _saveDraft,
              child: const Text('Save draft'),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    controller: _scrollController,
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      bottomInset > 0 ? AppSpacing.xl : 120,
                    ),
                    children: [
                      _ModeSwitcher(
                        mode: _mode,
                        onChanged: _onModeChanged,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        helperText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SectionCard(
                        title: 'Semester Information',
                        child: Column(
                          children: [
                            _DropdownField(
                              label: 'Academic Year',
                              value: _academicYear,
                              items: _academicYears,
                              onChanged: (value) =>
                                  setState(() => _academicYear = value),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _DropdownField(
                              label: 'Semester',
                              value: _semesterLabel,
                              items: _semesters,
                              onChanged: (value) =>
                                  setState(() => _semesterLabel = value),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _DropdownField(
                              label: 'Programme',
                              value: _programme,
                              items: _programmes,
                              onChanged: (value) =>
                                  setState(() => _programme = value),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _DropdownField(
                              label: 'Level',
                              value: _level,
                              items: _levels,
                              onChanged: (value) =>
                                  setState(() => _level = value),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SectionCard(
                        title: 'Courses',
                        child: Column(
                          children: [
                            for (final course in _courses) ...[
                              _CourseEditorCard(
                                key: ValueKey(course.id),
                                course: course,
                                canRemove: _courses.length > 1,
                                hasDuplicateCode: _duplicateCodes
                                    .contains(course.normalizedCode),
                                onChanged: _refreshDerivedState,
                                onRemove: () => _removeCourse(course),
                              ),
                              if (course != _courses.last)
                                const SizedBox(height: AppSpacing.sm),
                            ],
                            const SizedBox(height: AppSpacing.sm),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: OutlinedButton.icon(
                                onPressed: _addCourse,
                                icon: const Icon(LucideIcons.plus),
                                label: const Text('Add Another Course'),
                              ),
                            ),
                            if (_showDuplicateWarning) ...[
                              const SizedBox(height: AppSpacing.xs),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Duplicate course codes detected. Each course code should be unique.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.warning,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _SectionCard(
                        title: 'Live Summary',
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            SizedBox(
                              width: 140,
                              child: _SummaryStat(
                                label: 'Courses added',
                                value: '$_coursesAdded',
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: _SummaryStat(
                                label: 'Total credits',
                                value: _totalCredits.toStringAsFixed(1),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: _SummaryStat(
                                label: 'Estimated CWA',
                                value: _estimatedCwa.toStringAsFixed(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedPadding(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: EdgeInsets.only(bottom: bottomInset),
                  child: SafeArea(
                    top: false,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        border: Border(
                          top: BorderSide(color: colorScheme.outlineVariant),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              button: true,
                              label: 'Cancel manual course entry',
                              child: OutlinedButton(
                                onPressed: _isSaving ? null : _cancel,
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Semantics(
                              button: true,
                              label: 'Save courses',
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveCourses,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size.fromHeight(48),
                                ),
                                child: _isSaving
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Save Courses'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Set<String> get _duplicateCodes {
    final counts = <String, int>{};
    for (final course in _courses) {
      final code = course.normalizedCode;
      if (code.isEmpty) continue;
      counts[code] = (counts[code] ?? 0) + 1;
    }
    return counts.entries
        .where((entry) => entry.value > 1)
        .map((entry) => entry.key)
        .toSet();
  }
}

class _ModeSwitcher extends StatelessWidget {
  final CwaViewMode mode;
  final ValueChanged<CwaViewMode> onChanged;

  const _ModeSwitcher({
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm2),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          _ModeTab(
            label: 'Semester',
            active: mode == CwaViewMode.semester,
            onTap: () => onChanged(CwaViewMode.semester),
          ),
          _ModeTab(
            label: 'Cumulative',
            active: mode == CwaViewMode.cumulative,
            onTap: () => onChanged(CwaViewMode.cumulative),
          ),
        ],
      ),
    );
  }
}

class _ModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ModeTab({
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Semantics(
        button: true,
        selected: active,
        label: label,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: active ? colorScheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadii.sm2),
            ),
            alignment: Alignment.center,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: active
                        ? colorScheme.onPrimary
                        : AppColors.textSecondary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      key: ValueKey('$label-$value'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          onChanged(value);
        }
      },
    );
  }
}

class _CourseEditorCard extends StatelessWidget {
  final _CourseDraft course;
  final bool canRemove;
  final bool hasDuplicateCode;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _CourseEditorCard({
    super.key,
    required this.course,
    required this.canRemove,
    required this.hasDuplicateCode,
    required this.onChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(AppRadii.sm2),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Course',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (canRemove)
                Semantics(
                  button: true,
                  label: 'Remove course',
                  child: TextButton.icon(
                    onPressed: onRemove,
                    icon: const Icon(LucideIcons.trash2, size: AppIconSizes.lg),
                    label: const Text('Remove Course'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.warning,
                      minimumSize: const Size(0, 44),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          TextFormField(
            controller: course.codeController,
            decoration: InputDecoration(
              labelText: 'Course Code',
              errorText: hasDuplicateCode
                  ? 'This course code is duplicated in the list.'
                  : null,
            ),
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => onChanged(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Course code cannot be empty.';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: course.titleController,
            decoration: const InputDecoration(labelText: 'Course Title'),
            onChanged: (_) => onChanged(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Course title cannot be empty.';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: course.creditsController,
            decoration: const InputDecoration(labelText: 'Credits'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => onChanged(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Credits must be numeric.';
              }
              final credits = double.tryParse(value.trim());
              if (credits == null) {
                return 'Credits must be numeric.';
              }
              if (credits <= 0) {
                return 'Credits must be greater than 0.';
              }
              return null;
            },
          ),
          const SizedBox(height: AppSpacing.sm),
          TextFormField(
            controller: course.scoreController,
            decoration: const InputDecoration(labelText: 'Expected Score (%)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => onChanged(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Score must be numeric.';
              }
              final score = double.tryParse(value.trim());
              if (score == null) {
                return 'Score must be numeric.';
              }
              if (score < 0 || score > 100) {
                return 'Score must be between 0 and 100.';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadii.sm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall,
          ),
          const SizedBox(height: AppSpacing.xxs2),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class _CourseDraft {
  _CourseDraft()
      : id = UniqueKey().toString(),
        codeController = TextEditingController(),
        titleController = TextEditingController(),
        creditsController = TextEditingController(),
        scoreController = TextEditingController(text: '70') {
    codeController.addListener(_notify);
    titleController.addListener(_notify);
    creditsController.addListener(_notify);
    scoreController.addListener(_notify);
  }

  final String id;
  final TextEditingController codeController;
  final TextEditingController titleController;
  final TextEditingController creditsController;
  final TextEditingController scoreController;
  final List<VoidCallback> _listeners = [];

  String get normalizedCode => codeController.text.trim().toUpperCase();

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void _notify() {
    for (final listener in _listeners) {
      listener();
    }
  }

  void dispose() {
    codeController.dispose();
    titleController.dispose();
    creditsController.dispose();
    scoreController.dispose();
  }
}
