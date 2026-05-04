import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/theme/app_tokens.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/shared/widgets/campus_modal_action_row.dart';
import 'package:campusiq/shared/widgets/campus_modal_sheet.dart';

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

    return CampusModalSheet(
      title: 'Choose course',
      subtitle: 'Pick what you want to study.',
      trailing: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close, size: AppIconSizes.xl),
        color: AppTheme.textSecondary,
        tooltip: 'Close',
      ),
      expandBody: true,
      maxHeightFactor: 0.82,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxs),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: AppRadii.pill,
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tabs,
              dividerColor: Colors.transparent,
              padding: EdgeInsets.zero,
              labelPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              indicator: const BoxDecoration(
                color: AppTheme.primary,
                borderRadius: AppRadii.pill,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
              tabs: const [
                Tab(text: 'Courses'),
                Tab(text: 'Today'),
                Tab(text: 'Custom'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                cwaCourses.isEmpty
                    ? const _EmptyPickerState(
                        icon: Icons.menu_book_outlined,
                        title: 'No CWA courses yet',
                        subtitle:
                            'Add courses in CWA and they will appear here for quick session starts.',
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: cwaCourses.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final course = cwaCourses[index];
                          return _PickerListTile(
                            leading: const Icon(
                              Icons.school_outlined,
                              color: AppTheme.primary,
                              size: AppIconSizes.xl,
                            ),
                            title: course.code,
                            subtitle: course.name,
                            onTap: () => _pick(
                              PickedCourse(
                                courseCode: course.code,
                                courseName: course.name,
                                source: 'cwa',
                              ),
                            ),
                          );
                        },
                      ),
                todaySlots.isEmpty
                    ? const _EmptyPickerState(
                        icon: Icons.event_busy_outlined,
                        title: 'No classes scheduled today',
                        subtitle:
                            'You can still use the Custom tab if you want to start a session anyway.',
                      )
                    : ListView.separated(
                        padding: EdgeInsets.zero,
                        itemCount: todaySlots.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final slot = todaySlots[index];
                          final slotColor = Color(slot.colorValue);
                          return _PickerListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  slotColor.withValues(alpha: 0.15),
                              child: Text(
                                slot.courseCode.substring(0, 1),
                                style: TextStyle(
                                  color: slotColor,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            title: slot.courseCode,
                            subtitle: '${slot.startTimeLabel} · ${slot.venue}',
                            onTap: () => _pick(
                              PickedCourse(
                                courseCode: slot.courseCode,
                                courseName: slot.courseName,
                                source: 'timetable',
                              ),
                            ),
                          );
                        },
                      ),
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Column(
                    children: [
                      TextField(
                        controller: _customCodeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Course code (e.g. MATH 101)',
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextField(
                        controller: _customNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Course name',
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      CampusModalActionRow(
                        primaryLabel: 'Start studying',
                        onPrimaryPressed: () {
                          final code = _customCodeCtrl.text.trim();
                          final name = _customNameCtrl.text.trim();
                          if (code.isEmpty || name.isEmpty) return;
                          _pick(PickedCourse(
                            courseCode: code.toUpperCase(),
                            courseName: name,
                            source: 'custom',
                          ));
                        },
                        secondaryLabel: 'Cancel',
                        onSecondaryPressed: () => Navigator.of(context).pop(),
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

class _PickerListTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PickerListTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.button,
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: AppRadii.button,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: AppIconSizes.sm,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyPickerState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyPickerState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppIconSizes.status, color: AppTheme.textSecondary),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
