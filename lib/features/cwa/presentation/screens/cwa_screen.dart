import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/constants/app_constants.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/cwa/domain/cwa_calculator.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/cwa/presentation/widgets/cwa_summary_bar.dart';
import 'package:campusiq/features/cwa/presentation/widgets/course_card.dart';
import 'package:campusiq/features/cwa/presentation/widgets/add_course_sheet.dart';

class CwaScreen extends ConsumerWidget {
  const CwaScreen({super.key});

  Future<void> _openAddSheet(BuildContext context, WidgetRef ref, {CourseModel? existing}) async {
    final result = await showModalBottomSheet<CourseModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddCourseSheet(
        semesterKey: ref.read(activeSemesterProvider),
        existing: existing,
      ),
    );

    if (result == null) return;
    final repo = ref.read(cwaRepositoryProvider);
    if (repo == null) return;

    existing == null ? await repo.addCourse(result) : await repo.updateCourse(result);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);
    final projected = ref.watch(projectedCwaProvider);
    final target = ref.watch(targetCwaProvider);
    final gap = ref.watch(cwaGapProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text(AppConstants.appName, style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: 'Set target CWA',
            onPressed: () => _showTargetDialog(context, ref, target),
          ),
        ],
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (courses) {
          final pairs = courses
              .map((c) => (creditHours: c.creditHours, score: c.expectedScore))
              .toList();
          final highImpactIdx = CwaCalculator.highestImpactCourseIndex(pairs);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: CwaSummaryBar(projected: projected, target: target, gap: gap),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('My Courses', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text('${courses.length} courses', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
              ),
              if (courses.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.school_outlined, size: 56, color: AppTheme.textSecondary),
                        SizedBox(height: 12),
                        Text('No courses yet', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
                        SizedBox(height: 4),
                        Text('Tap + to add your first course', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final course = courses[i];
                      final repo = ref.read(cwaRepositoryProvider);
                      return CourseCard(
                        course: course,
                        isHighImpact: i == highImpactIdx,
                        onEdit: () => _openAddSheet(context, ref, existing: course),
                        onDelete: () => repo?.deleteCourse(course.id),
                        onScoreChanged: (newScore) async {
                          course.expectedScore = newScore;
                          await repo?.updateCourse(course);
                        },
                      );
                    },
                    childCount: courses.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Course'),
      ),
    );
  }

  void _showTargetDialog(BuildContext context, WidgetRef ref, double current) {
    double temp = current;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Target CWA'),
        content: StatefulBuilder(
          builder: (ctx, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${temp.toInt()}',
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700, color: AppTheme.primary),
              ),
              Slider(
                value: temp,
                min: 40,
                max: 100,
                divisions: 60,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => temp = v),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(targetCwaProvider.notifier).state = temp;
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}
