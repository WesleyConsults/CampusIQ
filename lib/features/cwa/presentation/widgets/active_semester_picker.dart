import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/domain/academic_term.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';

export 'package:campusiq/features/cwa/domain/academic_term.dart';

String formatActiveSemesterLabel(String semesterKey) {
  return formatAcademicTermLabel(semesterKey);
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
    builder: (ctx) {
      final colorScheme = Theme.of(ctx).colorScheme;

      return AlertDialog(
        title: const Text('Change Active Semester'),
        content: StatefulBuilder(
          builder: (ctx, setState) {
            final yearOptions = _academicYearStartOptions(selectedStartYear);

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This semester is used for current CWA courses, timetable entries, and study sessions.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
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
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            child: const Text('Save'),
          ),
        ],
      );
    },
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
