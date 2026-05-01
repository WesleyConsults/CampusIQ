import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
            body: const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.school_outlined,
                        size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Course not found',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add this course in the CWA tab first.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    course.code,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white),
                  ),
                  Text(
                    course.name,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.white70),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              bottom: const TabBar(
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                indicatorColor: Colors.white,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(
                    icon: Icon(Icons.dashboard_outlined, size: 18),
                    text: 'Overview',
                  ),
                  Tab(
                    icon: Icon(Icons.timer_outlined, size: 18),
                    text: 'Sessions',
                  ),
                  Tab(
                    icon: Icon(Icons.notes_outlined, size: 18),
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
