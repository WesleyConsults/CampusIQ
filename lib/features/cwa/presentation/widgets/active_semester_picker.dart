import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';

class ActiveSemesterSelection {
  final int startYear;
  final int semesterNumber;

  const ActiveSemesterSelection({
    required this.startYear,
    required this.semesterNumber,
  });

  factory ActiveSemesterSelection.fromKey(String key) {
    final match = RegExp(r'^(\d{4})-Sem([12])$').firstMatch(key.trim());
    if (match == null) {
      return const ActiveSemesterSelection(startYear: 2024, semesterNumber: 2);
    }

    return ActiveSemesterSelection(
      startYear: int.parse(match.group(1)!),
      semesterNumber: int.parse(match.group(2)!),
    );
  }

  String get key => '$startYear-Sem$semesterNumber';

  String get academicYearLabel => '$startYear/${startYear + 1}';

  String get semesterLabel =>
      semesterNumber == 1 ? 'First Semester' : 'Second Semester';

  String get displayLabel => '$academicYearLabel • $semesterLabel';

  ActiveSemesterSelection get next {
    if (semesterNumber == 1) {
      return ActiveSemesterSelection(
        startYear: startYear,
        semesterNumber: 2,
      );
    }

    return ActiveSemesterSelection(
      startYear: startYear + 1,
      semesterNumber: 1,
    );
  }
}

String formatActiveSemesterLabel(String semesterKey) {
  return ActiveSemesterSelection.fromKey(semesterKey).displayLabel;
}

Future<void> showActiveSemesterDialog(
  BuildContext context,
  WidgetRef ref,
  String currentSemesterKey,
) async {
  final currentSelection = ActiveSemesterSelection.fromKey(currentSemesterKey);
  int selectedStartYear = currentSelection.startYear;
  int selectedSemesterNumber = currentSelection.semesterNumber;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Change Active Semester'),
      content: StatefulBuilder(
        builder: (ctx, setState) {
          final yearOptions = _academicYearStartOptions(selectedStartYear);

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This semester is used for current CWA courses, timetable entries, and study sessions.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<int>(
                initialValue: selectedStartYear,
                decoration: const InputDecoration(
                  labelText: 'Academic Year',
                  border: OutlineInputBorder(),
                ),
                items: yearOptions
                    .map(
                      (year) => DropdownMenuItem<int>(
                        value: year,
                        child: Text('$year/${year + 1}'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedStartYear = value);
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<int>(
                initialValue: selectedSemesterNumber,
                decoration: const InputDecoration(
                  labelText: 'Semester',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem<int>(
                    value: 1,
                    child: Text('First Semester'),
                  ),
                  DropdownMenuItem<int>(
                    value: 2,
                    child: Text('Second Semester'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  setState(() => selectedSemesterNumber = value);
                },
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () async {
            final repo = ref.read(cwaPrefsRepositoryProvider);
            if (repo == null) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Your semester settings are not ready yet. Please try again.',
                    ),
                  ),
                );
              }
              Navigator.pop(ctx);
              return;
            }

            final selection = ActiveSemesterSelection(
              startYear: selectedStartYear,
              semesterNumber: selectedSemesterNumber,
            );

            try {
              await repo.setActiveSemesterKey(selection.key);
              if (ctx.mounted) Navigator.pop(ctx);
            } catch (e) {
              debugPrint('🔴 showActiveSemesterDialog failed: $e');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not update the active semester. Please try again.',
                    ),
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

List<int> _academicYearStartOptions(int anchorStartYear) {
  final now = DateTime.now();
  final currentAcademicStartYear = now.month >= 8 ? now.year : now.year - 1;
  final options = <int>{
    anchorStartYear,
    currentAcademicStartYear,
  };

  for (var year = currentAcademicStartYear - 4;
      year <= currentAcademicStartYear + 4;
      year++) {
    options.add(year);
  }

  final sorted = options.toList()..sort();
  return sorted;
}
