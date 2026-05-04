import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/ai/domain/context_builder.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/whatif_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/whatif_explain_chip.dart';
import 'package:campusiq/features/cwa/presentation/widgets/whatif_result_card.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';
import 'package:campusiq/shared/widgets/campus_chip.dart';

class CourseCard extends ConsumerStatefulWidget {
  final CourseModel course;
  final bool isHighImpact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<double> onScoreChanged;

  const CourseCard({
    super.key,
    required this.course,
    required this.isHighImpact,
    required this.onEdit,
    required this.onDelete,
    required this.onScoreChanged,
  });

  @override
  ConsumerState<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends ConsumerState<CourseCard> {
  late double _sliderValue;
  late double
      _savedScore; // score at the time this card was mounted — does not change during drag
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.course.expectedScore;
    _savedScore = widget.course.expectedScore;
  }

  @override
  void didUpdateWidget(CourseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.course.id != widget.course.id) {
      // Entirely different course — full reset
      _sliderValue = widget.course.expectedScore;
      _savedScore = widget.course.expectedScore;
    } else if (widget.course.expectedScore != _savedScore) {
      // Same course but score changed externally (e.g., edit sheet saved)
      final userIsDragging = (_sliderValue - _savedScore).abs() >= 1.0;
      _savedScore = widget.course.expectedScore;
      if (!userIsDragging) {
        // Not mid-drag — sync slider to the newly saved value
        _sliderValue = widget.course.expectedScore;
      }
    }
  }

  String get _courseId => widget.course.id.toString();
  bool get _isAdjusted => (_sliderValue - _savedScore).abs() >= 1.0;

  @override
  Widget build(BuildContext context) {
    final whatifState = ref.watch(whatifProvider);
    final explanation = whatifState.explanations[_courseId];
    final isLoading = whatifState.isLoading[_courseId] ?? false;
    final gradeColor = _scoreTone(_sliderValue);
    final scoreLabel = '${_sliderValue.toInt()}%';

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 4),
      child: CampusCard(
        padding: const EdgeInsets.all(AppSpacing.md),
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
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              widget.course.code,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          if (widget.isHighImpact) ...[
                            const SizedBox(width: AppSpacing.xs),
                            CampusChip(
                              label: 'High impact',
                              backgroundColor:
                                  AppTheme.accent.withValues(alpha: 0.16),
                              foregroundColor: AppTheme.accent,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs2),
                      Text(
                        widget.course.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          height: 1.25,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${widget.course.creditHours.toInt()} cr',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: 'Course options',
                      padding: EdgeInsets.zero,
                      icon: const Icon(
                        Icons.more_horiz,
                        color: AppTheme.textSecondary,
                      ),
                      onSelected: (v) {
                        if (v == 'edit') {
                          widget.onEdit();
                        } else if (v == 'delete') {
                          widget.onDelete();
                        } else if (v == 'workspace') {
                          context.push('/course/${widget.course.code}');
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'workspace',
                          child: Row(
                            children: [
                              Icon(LucideIcons.bookOpen, size: AppIconSizes.md),
                              SizedBox(width: AppSpacing.xs),
                              Text('Open Workspace'),
                            ],
                          ),
                        ),
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _CompactInfoBlock(
                    label: 'Expected score',
                    value: scoreLabel,
                    valueColor: gradeColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _CompactInfoBlock(
                    label: 'Status',
                    value: widget.isHighImpact ? 'High impact' : 'On watch',
                    valueColor: widget.isHighImpact
                        ? AppTheme.accent
                        : AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.tune,
                    size: AppIconSizes.md,
                  ),
                  label:
                      Text(_expanded ? 'Hide score control' : 'Adjust score'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
                const Spacer(),
                if (_isAdjusted)
                  const Text(
                    'Projection updated',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success,
                    ),
                  ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Expected score',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          scoreLabel,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: gradeColor,
                          ),
                        ),
                      ],
                    ),
                    Slider(
                      value: _sliderValue,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      activeColor: AppTheme.primary,
                      inactiveColor: AppColors.divider,
                      onChanged: (value) {
                        setState(() => _sliderValue = value);
                        ref.read(whatifProvider.notifier).setAdjustedScore(
                              _courseId,
                              value,
                              _savedScore,
                            );
                        widget.onScoreChanged(value);
                      },
                    ),
                    if (_isAdjusted)
                      WhatifExplainChip(
                        isLoading: isLoading,
                        onTap: () => _triggerExplain(),
                      ),
                    WhatifResultCard(explanation: explanation),
                  ],
                ),
              ),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 220),
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Color _scoreTone(double score) {
    if (score >= 70) return AppTheme.success;
    if (score >= 55) return AppTheme.accent;
    return AppTheme.warning;
  }

  void _triggerExplain() {
    final courses = ref.read(coursesProvider).valueOrNull ?? [];
    final pairs = courses
        .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
        .toList();
    final originalCwa = CwaCalculator.calculate(pairs);

    final courseIndex = courses.indexWhere((c) => c.id == widget.course.id);
    final newCwa = courseIndex >= 0
        ? CwaCalculator.whatIf(
            courses: pairs, index: courseIndex, newScore: _sliderValue)
        : originalCwa;

    final targetCwa = ref.read(targetCwaProvider);

    ref.read(whatifProvider.notifier).explainChange(
          _courseId,
          WhatIfInput(
            courseCode: widget.course.code,
            courseName: widget.course.name,
            creditHours: widget.course.creditHours.toInt(),
            originalScore: _savedScore,
            newScore: _sliderValue,
            originalCwa: originalCwa,
            newCwa: newCwa,
            targetCwa: targetCwa,
          ),
        );
  }
}

class _CompactInfoBlock extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _CompactInfoBlock({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
