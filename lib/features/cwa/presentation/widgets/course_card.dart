import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/ai/domain/context_builder.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/whatif_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/whatif_explain_chip.dart';
import 'package:campusiq/features/cwa/presentation/widgets/whatif_result_card.dart';

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

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.course.code,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppTheme.textPrimary),
                          ),
                          if (widget.isHighImpact) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'High impact',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        AppTheme.accent.withValues(alpha: 0.9)),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(widget.course.name,
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.textSecondary)),
                    ],
                  ),
                ),
                Text(
                  '${widget.course.creditHours.toInt()} cr',
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500),
                ),
                PopupMenuButton<String>(
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
                            Icon(Icons.open_in_new, size: 16),
                            SizedBox(width: 8),
                            Text('Open Workspace'),
                          ],
                        )),
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Expected score:',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const Spacer(),
                Text('${_sliderValue.toInt()}%',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ],
            ),
            Slider(
              value: _sliderValue,
              min: 0,
              max: 100,
              divisions: 100,
              activeColor: AppTheme.primary,
              inactiveColor: Colors.grey.shade200,
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
            // What-if chip — only shows when slider differs from saved score
            if (_isAdjusted)
              WhatifExplainChip(
                isLoading: isLoading,
                onTap: () => _triggerExplain(),
              ),
            // Animated result card
            WhatifResultCard(explanation: explanation),
          ],
        ),
      ),
    );
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
