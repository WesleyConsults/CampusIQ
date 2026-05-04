import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/shared/widgets/error_retry_widget.dart';
import 'package:campusiq/features/course_hub/presentation/widgets/hub_overview_tab.dart';
import 'package:campusiq/features/course_hub/presentation/widgets/hub_sessions_tab.dart';
import 'package:campusiq/features/course_hub/presentation/widgets/hub_notes_tab.dart';

class CourseHubScreen extends ConsumerWidget {
  final String courseCode;

  const CourseHubScreen({super.key, required this.courseCode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return coursesAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(courseCode)),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(courseCode)),
        body: ErrorRetryWidget(
          message: 'Could not load course. Please try again.',
          onRetry: () => ref.invalidate(coursesProvider),
        ),
      ),
      data: (courses) {
        final course =
            courses.where((c) => c.code == courseCode).firstOrNull;

        if (course == null) {
          return Scaffold(
            appBar: AppBar(title: Text(courseCode)),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.bookOpen,
                        size: AppIconSizes.alert, color: AppColors.textSecondary),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Course not found',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    const Text(
                      'Add this course in the CWA tab first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              titleSpacing: 0,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    course.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${course.code}  ·  ${course.creditHours.toInt()} credits',
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              bottom: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: const [
                  Tab(
                    icon: Icon(LucideIcons.layoutDashboard,
                        size: AppIconSizes.lg),
                    text: 'Overview',
                  ),
                  Tab(
                    icon: Icon(LucideIcons.timer, size: AppIconSizes.lg),
                    text: 'Sessions',
                  ),
                  Tab(
                    icon: Icon(LucideIcons.stickyNote, size: AppIconSizes.lg),
                    text: 'Notes',
                  ),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                HubOverviewTab(course: course),
                HubSessionsTab(courseCode: course.code),
                HubNotesTab(courseCode: course.code),
              ],
            ),
          ),
        );
      },
    );
  }
}
