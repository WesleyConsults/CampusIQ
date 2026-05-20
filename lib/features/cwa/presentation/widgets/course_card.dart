import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/presentation/widgets/grade_value_dropdown.dart';
import 'package:campusiq/shared/widgets/campus_card.dart';

class CourseCard extends StatefulWidget {
  final CourseModel course;
  final GradingSystem gradingSystem;
  final bool isHighImpact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<double> onScoreChanged;
  final ValueChanged<double>? onDragEnd;

  const CourseCard({
    super.key,
    required this.course,
    this.gradingSystem = GradingSystem.cwa,
    required this.isHighImpact,
    required this.onEdit,
    required this.onDelete,
    required this.onScoreChanged,
    this.onDragEnd,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  late double _sliderValue;
  late double
      _savedScore; // score at the time this card was mounted — does not change during drag
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.gradingSystem.clampScore(widget.course.expectedScore);
    _savedScore = _sliderValue;
  }

  @override
  void didUpdateWidget(CourseCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.course.id != widget.course.id) {
      // Entirely different course — full reset
      _sliderValue =
          widget.gradingSystem.clampScore(widget.course.expectedScore);
      _savedScore = _sliderValue;
    } else if (widget.course.expectedScore != _savedScore) {
      // Same course but score changed externally (e.g., edit sheet saved)
      final userIsDragging = _isAdjusted;
      _savedScore =
          widget.gradingSystem.clampScore(widget.course.expectedScore);
      if (!userIsDragging) {
        // Not mid-drag — sync slider to the newly saved value
        _sliderValue = _savedScore;
      }
    }
  }

  bool get _isAdjusted =>
      (_sliderValue - _savedScore).abs() >=
      (widget.gradingSystem.maxScore <= 5 ? 0.1 : 1.0);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final gradeColor = _scoreTone(_sliderValue);
    final scoreLabel = _scoreLabel(_sliderValue);

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 2),
      child: CampusCard(
        padding: const EdgeInsets.all(AppSpacing.sm),
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
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          if (widget.isHighImpact) ...[
                            const SizedBox(width: AppSpacing.xs),
                            const _ImpactPill(),
                          ],
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xxs2),
                      Text(
                        widget.course.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
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
                    PopupMenuButton<String>(
                      tooltip: 'Course options',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: AppFloors.minTapTarget,
                        minHeight: AppFloors.minTapTarget,
                      ),
                      icon: Icon(
                        Icons.more_horiz,
                        size: AppIconSizes.xl,
                        color: colorScheme.onSurfaceVariant,
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
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Expanded(
                  child: _CompactInfoBlock(
                    label: widget.gradingSystem.scoreInputLabel,
                    value: scoreLabel,
                    valueColor: gradeColor,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs2),
                Expanded(
                  child: _CompactInfoBlock(
                    label: 'Credits',
                    value: '${widget.course.creditHours.toInt()} cr',
                    valueColor: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xxs2),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  icon: Icon(
                    _expanded ? Icons.expand_less : Icons.tune,
                    size: AppIconSizes.md,
                  ),
                  label: Text(_expanded ? 'Hide control' : 'Adjust'),
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 30),
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
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.gradingSystem.scoreInputLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
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
                    if (widget.gradingSystem.usesLetterGrades)
                      GradeValueDropdown(
                        gradingSystem: widget.gradingSystem,
                        value: _sliderValue,
                        onChanged: (value) {
                          setState(() => _sliderValue = value);
                          widget.onScoreChanged(value);
                          widget.onDragEnd?.call(value);
                        },
                      )
                    else
                      Slider(
                        value: _sliderValue,
                        min: widget.gradingSystem.minScore,
                        max: widget.gradingSystem.maxScore,
                        divisions: widget.gradingSystem.sliderDivisions,
                        activeColor: colorScheme.primary,
                        inactiveColor: colorScheme.outlineVariant,
                        onChanged: (value) {
                          setState(() => _sliderValue = value);
                          widget.onScoreChanged(value);
                        },
                        onChangeEnd: (value) {
                          widget.onDragEnd?.call(value);
                        },
                      ),
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
    final normalized = widget.gradingSystem.maxScore == 0
        ? 0.0
        : score / widget.gradingSystem.maxScore;
    if (normalized >= 0.7) return AppTheme.success;
    if (normalized >= 0.55) return AppTheme.accent;
    return AppTheme.warning;
  }

  String _scoreLabel(double score) {
    final formatted =
        widget.gradingSystem.formatScore(score, includeUnit: true);
    final letter = widget.gradingSystem.letterForScore(score);
    if (letter == null || !widget.gradingSystem.usesLetterGrades) {
      return formatted;
    }
    return '$formatted · $letter';
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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(
        minWidth: 128,
        minHeight: 48,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadii.md),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.onSurfaceVariant,
              height: 1.15,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImpactPill extends StatelessWidget {
  const _ImpactPill();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.accent.withValues(alpha: 0.14),
        borderRadius: AppRadii.pill,
      ),
      child: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs2,
        ),
        child: Text(
          'High impact',
          style: TextStyle(
            color: AppTheme.accent,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
