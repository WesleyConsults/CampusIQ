import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';

class PickedCourse {
  final String courseCode;
  final String courseName;
  final String source; // "cwa" | "timetable" | "custom"

  const PickedCourse({
    required this.courseCode,
    required this.courseName,
    required this.source,
  });
}

/// Bottom sheet letting user pick a course from CWA list,
/// today's timetable, or type a custom name.
class CoursePickerSheet extends ConsumerStatefulWidget {
  const CoursePickerSheet({super.key});

  @override
  ConsumerState<CoursePickerSheet> createState() => _CoursePickerSheetState();
}

class _CoursePickerSheetState extends ConsumerState<CoursePickerSheet>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _customCodeCtrl = TextEditingController();
  final _customNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    _customCodeCtrl.dispose();
    _customNameCtrl.dispose();
    super.dispose();
  }

  void _pick(PickedCourse course) => Navigator.of(context).pop(course);

  @override
  Widget build(BuildContext context) {
    final cwaCourses = ref.watch(coursesProvider).valueOrNull ?? [];
    final todaySlots = ref.watch(activeDaySlotsProvider);

    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Text(
            'What are you studying?',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabs,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textSecondary,
            indicatorColor: AppTheme.primary,
            labelStyle:
                const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            tabs: const [
              Tab(text: 'CWA Courses'),
              Tab(text: "Today's Classes"),
              Tab(text: 'Custom'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                // CWA courses
                cwaCourses.isEmpty
                    ? const Center(
                        child: Text('No CWA courses added yet',
                            style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView(
                        children: cwaCourses
                            .map((c) => ListTile(
                                  leading: const Icon(Icons.school_outlined,
                                      color: AppTheme.primary),
                                  title: Text(c.code,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle: Text(c.name),
                                  onTap: () => _pick(PickedCourse(
                                    courseCode: c.code,
                                    courseName: c.name,
                                    source: 'cwa',
                                  )),
                                ))
                            .toList(),
                      ),

                // Today's timetable slots
                todaySlots.isEmpty
                    ? const Center(
                        child: Text("No classes scheduled today",
                            style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView(
                        children: todaySlots
                            .map((s) => ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Color(s.colorValue)
                                        .withValues(alpha: 0.15),
                                    child: Text(s.courseCode.substring(0, 1),
                                        style: TextStyle(
                                            color: Color(s.colorValue),
                                            fontWeight: FontWeight.w700)),
                                  ),
                                  title: Text(s.courseCode,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600)),
                                  subtitle:
                                      Text('${s.startTimeLabel} · ${s.venue}'),
                                  onTap: () => _pick(PickedCourse(
                                    courseCode: s.courseCode,
                                    courseName: s.courseName,
                                    source: 'timetable',
                                  )),
                                ))
                            .toList(),
                      ),

                // Custom
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: _customCodeCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Course code (e.g. MATH 101)'),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _customNameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Course name'),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final code = _customCodeCtrl.text.trim();
                            final name = _customNameCtrl.text.trim();
                            if (code.isEmpty || name.isEmpty) return;
                            _pick(PickedCourse(
                              courseCode: code.toUpperCase(),
                              courseName: name,
                              source: 'custom',
                            ));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text('Start Studying'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
