import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/services/analytics_service.dart';
import 'package:campusiq/core/services/crash_reporting_service.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/data/models/past_semester_model.dart';
import 'package:campusiq/features/cwa/domain/academic_term.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/grade_value_dropdown.dart';
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
  late String _initialAcademicYear;
  late String _initialSemesterLabel;
  late String _initialProgramme;
  late String _initialLevel;
  String _academicYear = _academicYears.first;
  String _semesterLabel = _semesters.first;
  String _programme = '';
  String _level = _levels.last;
  bool _isSaving = false;
  bool _isDraftRestored = false;
  bool _showDuplicateWarning = false;
  int _activeCourseIndex = 0;
  int _cumulativeStep = 0;
  bool _showCourseSavedActions = false;

  GradingSystem get _gradingSystem => ref.read(gradingSystemProvider);

  static const _academicYears = [
    '2023/2024',
    '2024/2025',
    '2025/2026',
    '2026/2027',
  ];

  static const _semesters = [
    'First Semester',
    'Second Semester',
    'Supplementary Semester',
  ];

  static const _levels = ['100', '200', '300', '400', '500'];

  @override
  void initState() {
    super.initState();
    _mode = widget.mode == 'cumulative'
        ? CwaViewMode.cumulative
        : CwaViewMode.semester;
    _initialMode = _mode;
    _syncSemesterMetadataFromActiveKey(ref.read(activeSemesterProvider));
    _initialAcademicYear = _academicYear;
    _initialSemesterLabel = _semesterLabel;
    _initialProgramme = _programme;
    _initialLevel = _level;
    _courses.add(
      _CourseDraft(
        defaultScore: _gradingSystem.defaultTarget,
        startWithScore: false,
      )..addListener(_refreshDerivedState),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreDraft());
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
        _academicYear != _initialAcademicYear ||
        _semesterLabel != _initialSemesterLabel ||
        _programme != _initialProgramme ||
        _level != _initialLevel ||
        _courses.length > 1) {
      return true;
    }

    final firstCourse = _courses.first;
    return firstCourse.codeController.text.trim().isNotEmpty ||
        firstCourse.titleController.text.trim().isNotEmpty ||
        firstCourse.creditsController.text.trim().isNotEmpty ||
        firstCourse.scoreController.text.trim().isNotEmpty;
  }

  bool get _isSemesterMode => _mode == CwaViewMode.semester;

  List<_CourseDraft> get _savedCourses {
    return _courses.where((course) {
      return course.isSaved && course.hasContent && _isCourseComplete(course);
    }).toList();
  }

  int get _coursesAdded => _savedCourses.length;

  _CourseDraft get _activeCourse {
    if (_activeCourseIndex >= _courses.length) {
      _activeCourseIndex = _courses.length - 1;
    }
    return _courses[_activeCourseIndex];
  }

  double get _totalCredits {
    return _savedCourses.fold<double>(0, (sum, course) {
      return sum + (double.tryParse(course.creditsController.text.trim()) ?? 0);
    });
  }

  double get _estimatedCwa {
    final pairs = <({double creditHours, double score})>[];
    for (final course in _savedCourses) {
      final credits = double.tryParse(course.creditsController.text.trim());
      final score = _scoreForCourse(course);
      if (credits == null || credits <= 0) continue;
      pairs
          .add((creditHours: credits, score: _gradingSystem.clampScore(score)));
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

  void _handleActiveCourseChanged() {
    if (!mounted) return;
    setState(() {
      _activeCourse.isSaved = false;
      _showCourseSavedActions = false;
      _showDuplicateWarning = _hasDuplicateCodes;
    });
  }

  void _addCourse() {
    setState(() {
      _courses.add(
        _CourseDraft(
          defaultScore: _gradingSystem.defaultTarget,
          startWithScore: false,
        )..addListener(_refreshDerivedState),
      );
      _activeCourseIndex = _courses.length - 1;
      _showCourseSavedActions = false;
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
      if (_activeCourseIndex >= _courses.length) {
        _activeCourseIndex = _courses.length - 1;
      }
      _showDuplicateWarning = _hasDuplicateCodes;
    });
  }

  void _onModeChanged(CwaViewMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _cumulativeStep = mode == CwaViewMode.cumulative ? 0 : 0;
      _activeCourseIndex = 0;
      _showCourseSavedActions = false;
    });
  }

  void _syncCwaMode() {
    ref.read(cwaViewModeProvider.notifier).state = _mode;
  }

  Future<void> _restoreDraft() async {
    if (_isDraftRestored || !mounted) return;
    _isDraftRestored = true;

    final repo = ref.read(cwaPrefsRepositoryProvider);
    if (repo == null) return;

    try {
      final raw = await repo.getManualCwaDraftJson();
      if (raw.trim().isEmpty || !mounted) return;

      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;

      final courses = (decoded['courses'] as List?)
          ?.whereType<Map>()
          .map((entry) => Map<String, dynamic>.from(entry))
          .toList();
      if (courses == null || courses.isEmpty) return;

      final restoredMode = decoded['mode'] == CwaViewMode.cumulative.name
          ? CwaViewMode.cumulative
          : CwaViewMode.semester;
      final restoredCourses = courses
          .map(
            (course) => _CourseDraft.fromJson(
              course,
              defaultScore: _gradingSystem.defaultTarget,
            ),
          )
          .toList();

      setState(() {
        for (final course in _courses) {
          course.dispose();
        }
        _courses
          ..clear()
          ..addAll(
            restoredCourses.map(
              (course) => course..addListener(_refreshDerivedState),
            ),
          );
        _mode = restoredMode;
        _academicYear =
            _validOrDefault(decoded['academicYear'], _academicYears);
        _semesterLabel = _validOrDefault(decoded['semesterLabel'], _semesters);
        final p = decoded['programme'];
        _programme = p is String ? p.trim() : '';
        _level = _validOrDefault(decoded['level'], _levels);
        _activeCourseIndex = _courses.length - 1;
        _cumulativeStep = _mode == CwaViewMode.cumulative ? 0 : 0;
        _showCourseSavedActions = false;
        _showDuplicateWarning = _hasDuplicateCodes;
      });
      _showMessage('Draft restored.');
    } catch (e) {
      debugPrint('🔴 CwaManualEntryScreen _restoreDraft failed: $e');
    }
  }

  String _validOrDefault(Object? value, List<String> options) {
    final text = value is String ? value : '';
    return options.contains(text) ? text : options.first;
  }

  Map<String, dynamic> _draftJson() {
    return {
      'mode': _mode.name,
      'academicYear': _academicYear,
      'semesterLabel': _semesterLabel,
      'programme': _programme,
      'level': _level,
      'courses': _courses.map((course) => course.toJson()).toList(),
      'savedAt': DateTime.now().toIso8601String(),
    };
  }

  void _syncSemesterMetadataFromActiveKey(String semesterKey) {
    final selection = ActiveSemesterSelection.fromKey(semesterKey);
    final startYear = selection.startYear;
    _academicYear = '$startYear/${startYear + 1}';
    _semesterLabel = selection.semesterLabel;
  }

  String _formatSemesterKey(String semesterKey) {
    return formatAcademicTermLabel(semesterKey);
  }

  Future<void> _saveCourses() async {
    FocusScope.of(context).unfocus();
    final isValid = _formKey.currentState?.validate() ?? true;
    final hasDuplicates = _hasDuplicateCodes;

    setState(() {
      _showDuplicateWarning = hasDuplicates;
    });

    if (!isValid || !_validateCoursesForSave()) return;
    if (hasDuplicates) {
      _showMessage('Duplicate course codes found. Please fix them first.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final bool saved;
      if (_mode == CwaViewMode.semester) {
        saved = await _saveSemesterCourses();
      } else {
        saved = await _saveCumulativeRecord();
      }

      if (!saved) return;
      if (!mounted) return;
      _syncCwaMode();
      ref.invalidate(coursesProvider);
      ref.invalidate(pastSemestersProvider);
      ref.invalidate(projectedCwaProvider);
      ref.invalidate(cwaGapProvider);
      ref.invalidate(cumulativeCwaProvider);
      ref.invalidate(totalCreditsProvider);
      ref.invalidate(cumulativeGapProvider);
      await ref.read(cwaPrefsRepositoryProvider)?.clearManualCwaDraft();
      await AnalyticsService.instance.logCourseSaved(
        action: 'created',
        source: _mode == CwaViewMode.semester
            ? 'manual_entry_semester'
            : 'manual_entry_cumulative',
        gradingSystem: ref.read(gradingSystemProvider).id,
        count: _savedCourses.length,
      );
      _showMessage('Courses saved successfully.');
      _closeToCwa();
    } on StateError catch (e) {
      _showMessage(e.message);
    } catch (e, stackTrace) {
      await CrashReportingService.instance.recordNonFatalError(
        e,
        stackTrace,
        reason: 'manual_entry_save_failed',
        context: {
          'mode': _mode.name,
          'course_count': _savedCourses.length,
        },
      );
      _showMessage('Could not save courses. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<bool> _saveSemesterCourses() async {
    final repo = ref.read(cwaRepositoryProvider);
    if (repo == null) throw Exception('CWA repository unavailable');

    final semesterKey = ref.read(activeSemesterProvider);
    final gradingSystem = ref.read(gradingSystemProvider);
    final normalizedCodes = _savedCourses
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

    for (final course in _savedCourses) {
      final credits = double.parse(course.creditsController.text.trim());
      final score = _scoreForCourse(course);
      await repo.addCourse(
        CourseModel.create(
          name: course.titleController.text.trim(),
          code: course.codeController.text.trim().toUpperCase(),
          creditHours: credits,
          expectedScore: gradingSystem.clampScore(score),
          semesterKey: semesterKey,
          gradingSystemId: gradingSystem.id,
        ),
      );
    }
    return true;
  }

  Future<bool> _saveCumulativeRecord() async {
    final repo = ref.read(pastResultRepositoryProvider);
    if (repo == null) throw Exception('Past result repository unavailable');
    final semesterKey = _buildSemesterKey();
    final gradingSystem = ref.read(gradingSystemProvider);

    final entries = _savedCourses.map((course) {
      final credits = double.parse(course.creditsController.text.trim());
      final score = _scoreForCourse(course);
      return PastCourseEntry.create(
        courseCode: course.codeController.text.trim().toUpperCase(),
        courseName: course.titleController.text.trim(),
        creditHours: credits,
        grade: gradeForScore(score, gradingSystem),
        mark: score,
      );
    }).toList();

    final record = PastSemesterModel.create(
      semesterLabel: _buildSemesterLabel(),
      semesterKey: semesterKey,
      gradingSystemId: gradingSystem.id,
      courses: entries,
    );

    final existing = await repo.findBySemesterKey(semesterKey);
    if (existing != null) {
      if (!mounted) return false;
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
      if (!shouldReplace) return false;
      await repo.replaceForSemesterKey(semesterKey, record);
      return true;
    }

    await repo.add(record);
    return true;
  }

  String _buildSemesterKey() {
    final year = int.parse(_academicYear.split('/').first);
    final termType = AcademicTermType.fromLabel(_semesterLabel);
    return ActiveSemesterSelection(
      startYear: year,
      termType: termType,
    ).key;
  }

  String _buildSemesterLabel() {
    return '$_academicYear • $_semesterLabel • L$_level • $_programme';
  }

  double _scoreForCourse(_CourseDraft course) {
    final raw = course.scoreController.text.trim();
    final parsed = double.tryParse(raw);
    return _gradingSystem.clampScore(parsed ?? _gradingSystem.defaultTarget);
  }

  bool _validateCoursesForSave() {
    final validCourses = _savedCourses;
    if (validCourses.isEmpty) {
      _showMessage('Add at least one course before saving.');
      return false;
    }

    for (final course in validCourses) {
      if (!_isCourseComplete(course)) {
        _showMessage('Complete each course before saving.');
        return false;
      }
    }
    return true;
  }

  bool _isCourseComplete(_CourseDraft course) {
    final credits = double.tryParse(course.creditsController.text.trim());
    final score = double.tryParse(course.scoreController.text.trim());
    final hasScore = course.scoreController.text.trim().isNotEmpty;
    final scoreIsValid = _isSemesterMode
        ? !hasScore ||
            (score != null &&
                score >= _gradingSystem.minScore &&
                score <= _gradingSystem.maxScore)
        : score != null &&
            score >= _gradingSystem.minScore &&
            score <= _gradingSystem.maxScore;

    return course.codeController.text.trim().isNotEmpty &&
        course.titleController.text.trim().isNotEmpty &&
        credits != null &&
        credits > 0 &&
        scoreIsValid;
  }

  bool _validateActiveCourse() {
    final isValid = _formKey.currentState?.validate() ?? true;
    setState(() {
      _showDuplicateWarning = _hasDuplicateCodes;
    });
    if (!isValid) return false;
    if (_hasDuplicateCodes) {
      _showMessage('Duplicate course codes found. Please fix them first.');
      return false;
    }
    if (!_isCourseComplete(_activeCourse)) {
      _showMessage('Complete this course before continuing.');
      return false;
    }
    return true;
  }

  void _saveActiveCourseDraft() {
    FocusScope.of(context).unfocus();
    if (!_validateActiveCourse()) return;
    setState(() {
      _activeCourse.isSaved = true;
      _showCourseSavedActions = true;
    });
  }

  void _addAnotherCourse() {
    _addCourse();
  }

  void _editCourse(_CourseDraft course) {
    setState(() {
      _activeCourseIndex = _courses.indexOf(course);
      _cumulativeStep = _mode == CwaViewMode.cumulative ? 1 : 0;
      _showCourseSavedActions = false;
    });
  }

  void _goToCumulativeCoursesStep() {
    if (_programme.trim().isEmpty) {
      _showMessage('Add your programme name before continuing.');
      return;
    }
    setState(() {
      _cumulativeStep = 1;
      _showCourseSavedActions = false;
    });
  }

  void _goToCumulativeReview() {
    if (!_showCourseSavedActions && !_validateActiveCourse()) return;
    if (_savedCourses.isEmpty) {
      _showMessage('Save at least one course before reviewing.');
      return;
    }
    setState(() {
      _cumulativeStep = 2;
      _showCourseSavedActions = false;
    });
  }

  Future<void> _saveDraft() async {
    final repo = ref.read(cwaPrefsRepositoryProvider);
    if (repo == null) {
      _showMessage('Draft storage is not ready yet. Please try again.');
      return;
    }

    try {
      await repo.setManualCwaDraftJson(jsonEncode(_draftJson()));
      if (!mounted) return;
      _showMessage('Draft saved.');
    } catch (e) {
      debugPrint('🔴 CwaManualEntryScreen _saveDraft failed: $e');
      _showMessage('Could not save draft. Please try again.');
    }
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
    final activeSemesterKey = ref.watch(activeSemesterProvider);
    final activeSemesterDisplay = _formatSemesterKey(activeSemesterKey);
    final navigator = Navigator.of(context);
    final router = GoRouter.of(context);
    final title = _isSemesterMode
        ? 'Add current semester courses'
        : 'Add past semester results';
    final helperText = _isSemesterMode
        ? 'Add the courses you are taking this semester to estimate your ${_gradingSystem.label}.'
        : 'Save one completed semester at a time so your cumulative ${_gradingSystem.label} stays accurate.';

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
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: BackButton(onPressed: _cancel),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w700),
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
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      120,
                    ),
                    children: [
                      _ModeSwitcher(
                        mode: _mode,
                        onChanged: _onModeChanged,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _IntroCard(
                        title: title,
                        body: helperText,
                        stepLabel: _isSemesterMode
                            ? 'One course at a time'
                            : 'Step ${_cumulativeStep + 1} of 3',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      if (_isSemesterMode)
                        _buildSemesterManualFlow(
                          context,
                          activeSemesterDisplay,
                        )
                      else
                        _buildCumulativeManualFlow(context),
                    ],
                  ),
                ),
                SafeArea(
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSemesterManualFlow(
    BuildContext context,
    String activeSemesterDisplay,
  ) {
    return Column(
      children: [
        _SectionCard(
          title: 'Active semester',
          child: _ActiveSemesterInfo(label: activeSemesterDisplay),
        ),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Add one course',
          child: _CourseEntryStep(
            course: _activeCourse,
            gradingSystem: _gradingSystem,
            scoreRequired: false,
            hasDuplicateCode:
                _duplicateCodes.contains(_activeCourse.normalizedCode),
            onChanged: _handleActiveCourseChanged,
            onSaveCourse: _saveActiveCourseDraft,
            savedActions: _showCourseSavedActions
                ? _SavedCourseActions(
                    primaryLabel: 'Add Another Course',
                    secondaryLabel: 'Done',
                    onPrimary: _addAnotherCourse,
                    onSecondary: _saveCourses,
                  )
                : null,
          ),
        ),
        if (_showDuplicateWarning) ...[
          const SizedBox(height: AppSpacing.xs),
          const _DuplicateWarning(),
        ],
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Current summary',
          child: _ManualSummary(
            coursesAdded: _coursesAdded,
            totalCredits: _totalCredits,
            estimatedLabel: 'Projected ${_gradingSystem.label}',
            estimatedValue: _gradingSystem.formatScore(_estimatedCwa),
          ),
        ),
        if (_coursesAdded > 0) ...[
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'Added courses',
            child: _CompactCourseList(
              courses: _savedCourses,
              gradingSystem: _gradingSystem,
              onEdit: _editCourse,
              onRemove: _courses.length > 1 ? _removeCourse : null,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCumulativeManualFlow(BuildContext context) {
    return Column(
      children: [
        _StepIndicator(currentStep: _cumulativeStep),
        const SizedBox(height: AppSpacing.md),
        if (_cumulativeStep == 0)
          _SectionCard(
            title: 'Semester information',
            child: _SemesterInfoStep(
              academicYear: _academicYear,
              semesterLabel: _semesterLabel,
              programme: _programme,
              level: _level,
              academicYears: _academicYears,
              semesters: _semesters,
              levels: _levels,
              onAcademicYearChanged: (value) =>
                  setState(() => _academicYear = value),
              onSemesterChanged: (value) =>
                  setState(() => _semesterLabel = value),
              onProgrammeChanged: (value) =>
                  setState(() => _programme = value.trim()),
              onLevelChanged: (value) => setState(() => _level = value),
              onContinue: _goToCumulativeCoursesStep,
            ),
          )
        else if (_cumulativeStep == 1)
          _SectionCard(
            title: 'Add course results',
            child: _CourseEntryStep(
              course: _activeCourse,
              gradingSystem: _gradingSystem,
              scoreRequired: true,
              hasDuplicateCode:
                  _duplicateCodes.contains(_activeCourse.normalizedCode),
              onChanged: _handleActiveCourseChanged,
              onSaveCourse: _saveActiveCourseDraft,
              savedActions: _showCourseSavedActions
                  ? _SavedCourseActions(
                      primaryLabel: 'Add Another Course',
                      secondaryLabel: 'Review Semester',
                      onPrimary: _addAnotherCourse,
                      onSecondary: _goToCumulativeReview,
                    )
                  : null,
            ),
          )
        else
          _SectionCard(
            title: 'Review and save',
            child: _ReviewStep(
              semesterLabel: _buildSemesterLabel(),
              courses: _savedCourses,
              gradingSystem: _gradingSystem,
              coursesAdded: _coursesAdded,
              totalCredits: _totalCredits,
              estimatedValue: _gradingSystem.formatScore(_estimatedCwa),
              onEdit: _editCourse,
              onRemove: _courses.length > 1 ? _removeCourse : null,
              onSave: _saveCourses,
            ),
          ),
        if (_showDuplicateWarning && _cumulativeStep != 2) ...[
          const SizedBox(height: AppSpacing.xs),
          const _DuplicateWarning(),
        ],
      ],
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
        color: colorScheme.surfaceContainerHighest,
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
                        : colorScheme.onSurfaceVariant,
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

class _IntroCard extends StatelessWidget {
  final String title;
  final String body;
  final String stepLabel;

  const _IntroCard({
    required this.title,
    required this.body,
    required this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.18),
                borderRadius: AppRadii.pill,
              ),
              child: Text(
                stepLabel,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.78),
                    height: 1.4,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActiveSemesterInfo extends StatelessWidget {
  final String label;

  const _ActiveSemesterInfo({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Change this from the CWA dashboard when you move into a new semester.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
        ),
      ],
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;

  const _StepIndicator({required this.currentStep});

  static const _labels = [
    'Semester info',
    'Add courses',
    'Review',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (var index = 0; index < _labels.length; index++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: index == currentStep
                    ? colorScheme.primary
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadii.sm),
                border: Border.all(
                  color: index == currentStep
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Text(
                _labels[index],
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: index == currentStep
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ),
          if (index != _labels.length - 1) const SizedBox(width: AppSpacing.xs),
        ],
      ],
    );
  }
}

class _SemesterInfoStep extends StatelessWidget {
  final String academicYear;
  final String semesterLabel;
  final String programme;
  final String level;
  final List<String> academicYears;
  final List<String> semesters;
  final List<String> levels;
  final ValueChanged<String> onAcademicYearChanged;
  final ValueChanged<String> onSemesterChanged;
  final ValueChanged<String> onProgrammeChanged;
  final ValueChanged<String> onLevelChanged;
  final VoidCallback onContinue;

  const _SemesterInfoStep({
    required this.academicYear,
    required this.semesterLabel,
    required this.programme,
    required this.level,
    required this.academicYears,
    required this.semesters,
    required this.levels,
    required this.onAcademicYearChanged,
    required this.onSemesterChanged,
    required this.onProgrammeChanged,
    required this.onLevelChanged,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        _DropdownField(
          label: 'Academic Year',
          value: academicYear,
          items: academicYears,
          onChanged: onAcademicYearChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _DropdownField(
          label: 'Semester type',
          value: semesterLabel,
          items: semesters,
          onChanged: onSemesterChanged,
        ),
        if (semesterLabel == AcademicTermType.supplementarySemester.label) ...[
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Use this for resits, failed courses, deferred papers, or results released outside the normal semester.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
        ],
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          initialValue: programme,
          decoration: const InputDecoration(
            labelText: 'Programme name',
            hintText: 'e.g. Civil Engineering',
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: onProgrammeChanged,
        ),
        const SizedBox(height: AppSpacing.sm),
        _DropdownField(
          label: 'Level',
          value: level,
          items: levels,
          onChanged: onLevelChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onContinue,
            child: const Text('Continue'),
          ),
        ),
      ],
    );
  }
}

class _CourseEntryStep extends StatelessWidget {
  final _CourseDraft course;
  final GradingSystem gradingSystem;
  final bool scoreRequired;
  final bool hasDuplicateCode;
  final VoidCallback onChanged;
  final VoidCallback onSaveCourse;
  final Widget? savedActions;

  const _CourseEntryStep({
    required this.course,
    required this.gradingSystem,
    required this.scoreRequired,
    required this.hasDuplicateCode,
    required this.onChanged,
    required this.onSaveCourse,
    this.savedActions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CourseEditorCard(
          key: ValueKey(course.id),
          course: course,
          gradingSystem: gradingSystem,
          scoreRequired: scoreRequired,
          canRemove: false,
          hasDuplicateCode: hasDuplicateCode,
          onChanged: onChanged,
          onRemove: () {},
        ),
        const SizedBox(height: AppSpacing.md),
        if (savedActions == null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onSaveCourse,
              icon: const Icon(LucideIcons.check),
              label: const Text('Save Course'),
            ),
          )
        else
          savedActions!,
      ],
    );
  }
}

class _SavedCourseActions extends StatelessWidget {
  final String primaryLabel;
  final String secondaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback onSecondary;

  const _SavedCourseActions({
    required this.primaryLabel,
    required this.secondaryLabel,
    required this.onPrimary,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onPrimary,
            icon: const Icon(LucideIcons.plus),
            label: Text(primaryLabel),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ElevatedButton(
            onPressed: onSecondary,
            child: Text(secondaryLabel),
          ),
        ),
      ],
    );
  }
}

class _ManualSummary extends StatelessWidget {
  final int coursesAdded;
  final double totalCredits;
  final String estimatedLabel;
  final String estimatedValue;

  const _ManualSummary({
    required this.coursesAdded,
    required this.totalCredits,
    required this.estimatedLabel,
    required this.estimatedValue,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: 140,
          child: _SummaryStat(
            label: 'Courses added',
            value: '$coursesAdded',
          ),
        ),
        SizedBox(
          width: 140,
          child: _SummaryStat(
            label: 'Total credits',
            value: totalCredits.toStringAsFixed(1),
          ),
        ),
        SizedBox(
          width: 140,
          child: _SummaryStat(
            label: estimatedLabel,
            value: estimatedValue,
          ),
        ),
      ],
    );
  }
}

class _CompactCourseList extends StatelessWidget {
  final List<_CourseDraft> courses;
  final GradingSystem gradingSystem;
  final ValueChanged<_CourseDraft> onEdit;
  final ValueChanged<_CourseDraft>? onRemove;

  const _CompactCourseList({
    required this.courses,
    required this.gradingSystem,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) {
      return Text(
        'Saved courses will appear here as you add them.',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      );
    }
    return Column(
      children: [
        for (final course in courses) ...[
          _CompactCourseTile(
            course: course,
            gradingSystem: gradingSystem,
            onEdit: () => onEdit(course),
            onRemove: onRemove == null ? null : () => onRemove!(course),
          ),
          if (course != courses.last) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _CompactCourseTile extends StatelessWidget {
  final _CourseDraft course;
  final GradingSystem gradingSystem;
  final VoidCallback onEdit;
  final VoidCallback? onRemove;

  const _CompactCourseTile({
    required this.course,
    required this.gradingSystem,
    required this.onEdit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final score = double.tryParse(course.scoreController.text.trim());
    final scoreText = score == null
        ? 'Uses target ${gradingSystem.formatScore(gradingSystem.defaultTarget)}'
        : gradingSystem.formatScore(gradingSystem.clampScore(score));
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadii.sm2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.normalizedCode.isEmpty
                      ? 'Course code'
                      : course.normalizedCode,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs2),
                Text(
                  course.titleController.text.trim().isEmpty
                      ? 'Course title'
                      : course.titleController.text.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.xxs2),
                Text(
                  '${course.creditsController.text.trim()} credits • $scoreText',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onEdit,
            child: const Text('Edit'),
          ),
          if (onRemove != null)
            IconButton(
              tooltip: 'Remove course',
              onPressed: onRemove,
              icon: const Icon(LucideIcons.trash2),
              color: AppTheme.warning,
            ),
        ],
      ),
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final String semesterLabel;
  final List<_CourseDraft> courses;
  final GradingSystem gradingSystem;
  final int coursesAdded;
  final double totalCredits;
  final String estimatedValue;
  final ValueChanged<_CourseDraft> onEdit;
  final ValueChanged<_CourseDraft>? onRemove;
  final VoidCallback onSave;

  const _ReviewStep({
    required this.semesterLabel,
    required this.courses,
    required this.gradingSystem,
    required this.coursesAdded,
    required this.totalCredits,
    required this.estimatedValue,
    required this.onEdit,
    required this.onRemove,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          semesterLabel,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Check the courses before saving this semester.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ManualSummary(
          coursesAdded: coursesAdded,
          totalCredits: totalCredits,
          estimatedLabel: 'Semester ${gradingSystem.label}',
          estimatedValue: estimatedValue,
        ),
        const SizedBox(height: AppSpacing.md),
        _CompactCourseList(
          courses: courses,
          gradingSystem: gradingSystem,
          onEdit: onEdit,
          onRemove: onRemove,
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onSave,
            icon: const Icon(LucideIcons.save),
            label: const Text('Save Semester'),
          ),
        ),
      ],
    );
  }
}

class _DuplicateWarning extends StatelessWidget {
  const _DuplicateWarning();

  @override
  Widget build(BuildContext context) {
    return const Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Duplicate course codes detected. Each course code should be unique.',
        style: TextStyle(
          fontSize: 12,
          color: AppTheme.warning,
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
  final GradingSystem gradingSystem;
  final bool scoreRequired;
  final bool canRemove;
  final bool hasDuplicateCode;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  const _CourseEditorCard({
    super.key,
    required this.course,
    required this.gradingSystem,
    required this.scoreRequired,
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
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.sm2),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Course details',
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
            decoration: const InputDecoration(labelText: 'Course name'),
            onChanged: (_) => onChanged(),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Course name cannot be empty.';
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
          if (gradingSystem.usesLetterGrades) ...[
            GradeValueDropdown(
              gradingSystem: gradingSystem,
              value: gradingSystem.clampScore(
                double.tryParse(course.scoreController.text.trim()) ??
                    gradingSystem.defaultTarget,
              ),
              onChanged: (value) {
                course.scoreController.text = gradingSystem.formatScore(value);
                onChanged();
              },
            ),
            const SizedBox(height: AppSpacing.xxs2),
            _ScoreHelperText(
              text: scoreRequired
                  ? 'Choose the grade from your result slip.'
                  : 'This starts at your default target. Change it if you expect a different grade.',
            ),
          ] else ...[
            TextFormField(
              controller: course.scoreController,
              decoration: InputDecoration(
                labelText: scoreRequired
                    ? gradingSystem.scoreInputLabel
                    : '${gradingSystem.scoreInputLabel}, optional',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => onChanged(),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  if (!scoreRequired) return null;
                  return 'Score must be numeric.';
                }
                final score = double.tryParse(value.trim());
                if (score == null) {
                  return 'Score must be numeric.';
                }
                if (score < gradingSystem.minScore ||
                    score > gradingSystem.maxScore) {
                  return 'Score must be between ${gradingSystem.minScore.toStringAsFixed(0)} and ${gradingSystem.maxScore.toStringAsFixed(0)}.';
                }
                return null;
              },
            ),
            const SizedBox(height: AppSpacing.xxs2),
            _ScoreHelperText(
              text: scoreRequired
                  ? 'Enter the mark from your result slip.'
                  : 'Leave this blank to estimate with your default target of ${gradingSystem.formatScore(gradingSystem.defaultTarget)}.',
            ),
          ],
        ],
      ),
    );
  }
}

class _ScoreHelperText extends StatelessWidget {
  final String text;

  const _ScoreHelperText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
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
                  color: colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }
}

class _CourseDraft {
  _CourseDraft({
    required double defaultScore,
    bool startWithScore = true,
  })  : id = UniqueKey().toString(),
        codeController = TextEditingController(),
        titleController = TextEditingController(),
        creditsController = TextEditingController(),
        scoreController = TextEditingController(
          text: startWithScore ? defaultScore.toStringAsFixed(1) : '',
        ),
        isSaved = false {
    codeController.addListener(_notify);
    titleController.addListener(_notify);
    creditsController.addListener(_notify);
    scoreController.addListener(_notify);
  }

  _CourseDraft.fromJson(
    Map<String, dynamic> json, {
    required double defaultScore,
  })  : id = UniqueKey().toString(),
        codeController = TextEditingController(
          text: json['code'] is String ? json['code'] as String : '',
        ),
        titleController = TextEditingController(
          text: json['title'] is String ? json['title'] as String : '',
        ),
        creditsController = TextEditingController(
          text: json['credits'] is String ? json['credits'] as String : '',
        ),
        scoreController = TextEditingController(
          text: json['score'] is String
              ? json['score'] as String
              : defaultScore.toStringAsFixed(1),
        ),
        isSaved = json['isSaved'] == true {
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
  bool isSaved;

  String get normalizedCode => codeController.text.trim().toUpperCase();

  bool get hasContent {
    return codeController.text.trim().isNotEmpty ||
        titleController.text.trim().isNotEmpty ||
        creditsController.text.trim().isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'code': codeController.text,
      'title': titleController.text,
      'credits': creditsController.text,
      'score': scoreController.text,
      'isSaved': isSaved,
    };
  }

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
