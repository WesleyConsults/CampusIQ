import 'package:flutter/material.dart';

import 'package:campusiq/core/domain/grading_system.dart';
import 'package:campusiq/core/theme/app_tokens.dart';

const Map<String, Color> kGradeColors = {
  'A+': Color(0xFF1B5E20),
  'A': Color(0xFF2E7D32),
  'B+': Color(0xFF0D47A1),
  'B': Color(0xFF1565C0),
  'C+': Color(0xFF6A1B9A),
  'C': Color(0xFFF57F17),
  'D+': Color(0xFFEF6C00),
  'D': Color(0xFFE65100),
  'E': Color(0xFF8D6E63),
  'F': Color(0xFFC62828),
};

Color gradeColor(String grade, Color fallback) {
  return kGradeColors[grade.trim().toUpperCase()] ?? fallback;
}

String normalizedGradeForSystem(String grade, GradingSystem gradingSystem) {
  final available = gradingSystem.gradeScale?.availableGrades;
  if (available == null || available.isEmpty) {
    return grade.trim().toUpperCase();
  }
  final normalized = grade.trim().toUpperCase();
  return available.contains(normalized) ? normalized : available.last;
}

double scoreForGrade(String grade, GradingSystem gradingSystem) {
  return gradingSystem.scoreForGrade(grade);
}

String gradeForScore(double score, GradingSystem gradingSystem) {
  return gradingSystem.gradeForScore(score);
}

class GradeValueDropdown extends StatelessWidget {
  final GradingSystem gradingSystem;
  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  const GradeValueDropdown({
    super.key,
    required this.gradingSystem,
    required this.value,
    required this.onChanged,
    this.label = 'Expected grade',
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final grades = gradingSystem.gradeScale?.availableGrades ??
        const ['A', 'B', 'C', 'D', 'F'];
    final selectedGrade = normalizedGradeForSystem(
      gradeForScore(value, gradingSystem),
      gradingSystem,
    );

    return DropdownButtonFormField<String>(
      key: ValueKey('${gradingSystem.id}-$selectedGrade-$label'),
      initialValue: selectedGrade,
      isExpanded: true,
      decoration: InputDecoration(labelText: label),
      items: grades.map((grade) {
        final points = scoreForGrade(grade, gradingSystem);
        final color = gradeColor(grade, colorScheme.primary);
        return DropdownMenuItem<String>(
          value: grade,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.xxxs,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadii.xs),
                ),
                child: Text(
                  grade,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  gradingSystem.formatScore(points, includeUnit: true),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (grade) {
        if (grade == null) return;
        onChanged(scoreForGrade(grade, gradingSystem));
      },
    );
  }
}

class CompactGradeDropdown extends StatelessWidget {
  final String grade;
  final GradingSystem gradingSystem;
  final ValueChanged<String> onChanged;

  const CompactGradeDropdown({
    super.key,
    required this.grade,
    required this.gradingSystem,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final grades = gradingSystem.gradeScale?.availableGrades ??
        const ['A', 'B', 'C', 'D', 'F'];
    final selectedGrade = normalizedGradeForSystem(grade, gradingSystem);
    final color = gradeColor(selectedGrade, colorScheme.primary);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.xs),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedGrade,
          isDense: true,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: color,
          ),
          dropdownColor: colorScheme.surface,
          items: grades.map((item) {
            final itemColor = gradeColor(item, colorScheme.primary);
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: itemColor,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}
