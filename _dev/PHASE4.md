# CampusIQ — PHASE4.md
## Study Session Tracking
**Builds on**: Phase 3 complete | **Package**: com.wesleyconsults.campusiq
**Course picker**: CWA courses + today's timetable slots
**Timer location**: New bottom nav tab + floating mini-timer when active
**Analytics**: Full dashboard — daily, weekly, planned vs actual

---

## HOW TO USE THIS FILE

Drive this in three Claude Code sessions. Each session ends at a checkpoint.
Open a **fresh Claude Code terminal session** for Phase 4.

**Start each session with:**
> "Read `_dev/PHASE4.md`. [Session instruction below.]"

---

## ARCHITECTURE DECISION — Read before starting

### Timer reliability on Android

Never use a `Stopwatch` or increment a counter in a `Timer.periodic`. Android
will kill background isolates and the count becomes wrong the moment the user
switches apps.

**The correct approach**: store `sessionStartTime` as a `DateTime` in the
global provider. The UI reads `DateTime.now().difference(sessionStartTime)` on
every tick. Even if Android pauses the app for 10 minutes, the next tick
produces the correct elapsed time because it always diffs against the wall
clock anchor.

### Global session state

The active session provider must live **above** the `ShellRoute` so it
survives tab switches. It is a `StateNotifier` held in `ProviderScope` —
not scoped to the Sessions screen. The floating mini-timer widget reads
the same provider and renders inside the `_AppShell` body, overlaid with
a `Stack`.

### Planned vs actual

A study session is "planned" if a timetable slot (class or personal Study)
exists for that course at that time of day. The `PlannedActualAnalyser`
compares session records against timetable slots to produce the comparison.
This is pure Dart — no Flutter dependency.

---

## PRE-FLIGHT — Before Session 1

```bash
cd /media/edwin/18FC2827FC28021C/projects/campusiq
flutter analyze          # must show 0 errors
git status               # must be clean
```

Update `_dev/CLAUDE.md`:

```
## Current phase
Phase 4 — Study Session Tracking

## Routes live
/cwa        → CWA Target Planner
/timetable  → Class + Personal Timetable (swipe layers)
/sessions   → Session Tracker + Analytics Dashboard
```

---

---

# SESSION 1 — Isar Model + Domain Logic + Global Timer State

**Claude Code instruction:**
> "Read `_dev/PHASE4.md`. Execute Session 1 steps 1 through 8 only. After Step 8 run build_runner and flutter analyze. Stop at Checkpoint 1 and report back."

---

## STEP 1 — StudySession Isar Model

Create `lib/features/session/data/models/study_session_model.dart`:

```dart
import 'package:isar/isar.dart';

part 'study_session_model.g.dart';

/// A completed or in-progress study session.
@collection
class StudySessionModel {
  Id id = Isar.autoIncrement;

  /// Course code this session was for e.g. "COE 456"
  late String courseCode;
  late String courseName;

  late DateTime startTime;
  late DateTime endTime;

  /// Duration in minutes — stored for fast querying
  late int durationMinutes;

  /// Was this session planned (matched a timetable slot) or spontaneous?
  late bool wasPlanned;

  /// Source: "cwa" | "timetable" | "custom"
  late String courseSource;

  late String semesterKey;

  StudySessionModel();

  /// Convenience
  String get formattedDuration {
    final h = durationMinutes ~/ 60;
    final m = durationMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
```

---

## STEP 2 — Run Codegen

```bash
dart run build_runner build --delete-conflicting-outputs
```

Confirm `study_session_model.g.dart` was generated.

---

## STEP 3 — Update Isar Provider

Update `lib/core/providers/isar_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [
      CourseModelSchema,
      TimetableSlotModelSchema,
      PersonalSlotModelSchema,
      StudySessionModelSchema,
    ],
    directory: dir.path,
  );
});
```

---

## STEP 4 — Session Repository

Create `lib/features/session/data/repositories/session_repository.dart`:

```dart
import 'package:isar/isar.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';

class SessionRepository {
  final Isar _isar;
  SessionRepository(this._isar);

  /// Save a completed session
  Future<void> saveSession(StudySessionModel session) async {
    await _isar.writeTxn(() => _isar.studySessionModels.put(session));
  }

  /// All sessions for a semester, newest first
  Stream<List<StudySessionModel>> watchAllSessions(String semesterKey) {
    return _isar.studySessionModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .sortByStartTimeDesc()
        .watch(fireImmediately: true);
  }

  /// Sessions on a specific date
  Future<List<StudySessionModel>> getSessionsForDate(
      String semesterKey, DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return _isar.studySessionModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .startTimeBetween(start, end)
        .findAll();
  }

  /// Sessions within a date range — used for weekly analytics
  Future<List<StudySessionModel>> getSessionsForRange(
      String semesterKey, DateTime from, DateTime to) async {
    return _isar.studySessionModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .startTimeBetween(from, to)
        .findAll();
  }

  Future<void> deleteSession(Id id) async {
    await _isar.writeTxn(() => _isar.studySessionModels.delete(id));
  }
}
```

---

## STEP 5 — Planned vs Actual Analyser (Pure Domain Logic)

Create `lib/features/session/domain/planned_actual_analyser.dart`:

```dart
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/domain/personal_slot_category.dart';

class CourseStats {
  final String courseCode;
  final String courseName;
  final int actualMinutes;
  final int plannedMinutes;

  const CourseStats({
    required this.courseCode,
    required this.courseName,
    required this.actualMinutes,
    required this.plannedMinutes,
  });

  int get gapMinutes => plannedMinutes - actualMinutes;
  bool get isOverStudied => actualMinutes > plannedMinutes;
  double get completionRate =>
      plannedMinutes == 0 ? 1.0 : (actualMinutes / plannedMinutes).clamp(0, 2);

  String get formattedActual {
    final h = actualMinutes ~/ 60;
    final m = actualMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  String get formattedPlanned {
    final h = plannedMinutes ~/ 60;
    final m = plannedMinutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class DayAnalytics {
  final DateTime date;
  final List<StudySessionModel> sessions;
  final int totalActualMinutes;
  final int totalPlannedMinutes;
  final List<CourseStats> perCourse;

  const DayAnalytics({
    required this.date,
    required this.sessions,
    required this.totalActualMinutes,
    required this.totalPlannedMinutes,
    required this.perCourse,
  });

  int get sessionCount => sessions.length;
  double get completionRate => totalPlannedMinutes == 0
      ? 1.0
      : (totalActualMinutes / totalPlannedMinutes).clamp(0, 2);
}

class WeeklyAnalytics {
  final List<DayAnalytics> days;
  final int totalActualMinutes;
  final String mostStudiedCourse;
  final String leastStudiedCourse;

  const WeeklyAnalytics({
    required this.days,
    required this.totalActualMinutes,
    required this.mostStudiedCourse,
    required this.leastStudiedCourse,
  });
}

class PlannedActualAnalyser {
  /// Computes planned minutes from timetable slots for a given date/dayIndex.
  static Map<String, int> _plannedMinutesByCourse({
    required List<TimetableSlotModel> classSlots,
    required List<PersonalSlotModel> personalSlots,
    required int dayIndex,
  }) {
    final planned = <String, int>{};

    for (final s in classSlots.where((s) => s.dayIndex == dayIndex)) {
      planned[s.courseCode] = (planned[s.courseCode] ?? 0) + s.durationMinutes;
    }

    // Personal Study slots count as planned study time
    for (final s in personalSlots) {
      if (PersonalSlotCategory.fromString(s.categoryName) == PersonalSlotCategory.study) {
        const key = 'Personal Study';
        planned[key] = (planned[key] ?? 0) + s.durationMinutes;
      }
    }

    return planned;
  }

  static DayAnalytics analyseDay({
    required DateTime date,
    required List<StudySessionModel> sessions,
    required List<TimetableSlotModel> classSlots,
    required List<PersonalSlotModel> personalSlots,
  }) {
    final dayIndex = date.weekday - 1; // Mon=0 … Sat=5
    final planned = _plannedMinutesByCourse(
      classSlots: classSlots,
      personalSlots: personalSlots,
      dayIndex: dayIndex,
    );

    // Aggregate actual minutes per course
    final actual = <String, int>{};
    final names  = <String, String>{};
    for (final s in sessions) {
      actual[s.courseCode] = (actual[s.courseCode] ?? 0) + s.durationMinutes;
      names[s.courseCode]  = s.courseName;
    }

    // Merge keys from both planned and actual
    final allCodes = {...planned.keys, ...actual.keys};
    final perCourse = allCodes.map((code) => CourseStats(
      courseCode: code,
      courseName: names[code] ?? code,
      actualMinutes: actual[code] ?? 0,
      plannedMinutes: planned[code] ?? 0,
    )).toList()
      ..sort((a, b) => b.actualMinutes.compareTo(a.actualMinutes));

    return DayAnalytics(
      date: date,
      sessions: sessions,
      totalActualMinutes: actual.values.fold(0, (s, v) => s + v),
      totalPlannedMinutes: planned.values.fold(0, (s, v) => s + v),
      perCourse: perCourse,
    );
  }

  static WeeklyAnalytics analyseWeek({
    required List<StudySessionModel> allSessions,
    required List<TimetableSlotModel> classSlots,
    required List<PersonalSlotModel> personalSlots,
    required DateTime weekStart, // Monday of the week
  }) {
    final days = <DayAnalytics>[];
    for (int i = 0; i < 6; i++) {
      final date = weekStart.add(Duration(days: i));
      final daySessions = allSessions.where((s) {
        final d = s.startTime;
        return d.year == date.year && d.month == date.month && d.day == date.day;
      }).toList();
      days.add(analyseDay(
        date: date,
        sessions: daySessions,
        classSlots: classSlots,
        personalSlots: personalSlots,
      ));
    }

    // Course totals across the week
    final weekActual = <String, int>{};
    final weekNames  = <String, String>{};
    for (final s in allSessions) {
      weekActual[s.courseCode] = (weekActual[s.courseCode] ?? 0) + s.durationMinutes;
      weekNames[s.courseCode]  = s.courseName;
    }

    String mostStudied  = '';
    String leastStudied = '';
    if (weekActual.isNotEmpty) {
      final sorted = weekActual.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      mostStudied  = weekNames[sorted.first.key] ?? sorted.first.key;
      leastStudied = weekNames[sorted.last.key]  ?? sorted.last.key;
    }

    return WeeklyAnalytics(
      days: days,
      totalActualMinutes: weekActual.values.fold(0, (s, v) => s + v),
      mostStudiedCourse: mostStudied,
      leastStudiedCourse: leastStudied,
    );
  }
}
```

---

## STEP 6 — Active Session State Model

Create `lib/features/session/domain/active_session_state.dart`:

```dart
/// Represents an in-progress session held in global provider state.
/// Uses DateTime anchor — never a running counter — for Android reliability.
class ActiveSessionState {
  final String courseCode;
  final String courseName;
  final String courseSource; // "cwa" | "timetable" | "custom"
  final DateTime startTime;

  const ActiveSessionState({
    required this.courseCode,
    required this.courseName,
    required this.courseSource,
    required this.startTime,
  });

  /// Always accurate regardless of app backgrounding
  Duration get elapsed => DateTime.now().difference(startTime);

  int get elapsedMinutes => elapsed.inMinutes;

  String get formattedElapsed {
    final h = elapsed.inHours;
    final m = elapsed.inMinutes % 60;
    final s = elapsed.inSeconds % 60;
    if (h > 0) return '${h.toString().padLeft(2,'0')}:${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
    return '${m.toString().padLeft(2,'0')}:${s.toString().padLeft(2,'0')}';
  }
}
```

---

## STEP 7 — Global Active Session Notifier

Create `lib/features/session/presentation/providers/active_session_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/features/session/domain/active_session_state.dart';

/// Global session state — lives above the nav shell, survives tab switches.
/// null = no session active.
class ActiveSessionNotifier extends StateNotifier<ActiveSessionState?> {
  ActiveSessionNotifier() : super(null);

  void startSession({
    required String courseCode,
    required String courseName,
    required String courseSource,
  }) {
    state = ActiveSessionState(
      courseCode: courseCode,
      courseName: courseName,
      courseSource: courseSource,
      startTime: DateTime.now(),
    );
  }

  /// Returns the completed session data then clears state.
  ActiveSessionState? stopSession() {
    final completed = state;
    state = null;
    return completed;
  }

  void cancelSession() => state = null;

  bool get isActive => state != null;
}

final activeSessionProvider =
    StateNotifierProvider<ActiveSessionNotifier, ActiveSessionState?>(
  (ref) => ActiveSessionNotifier(),
);
```

---

## STEP 8 — Session Riverpod Providers

Create `lib/features/session/presentation/providers/session_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/session/data/repositories/session_repository.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/features/timetable/presentation/providers/personal_slot_provider.dart';

final sessionRepositoryProvider = Provider<SessionRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => SessionRepository(isar));
});

/// Live stream of all sessions newest first
final allSessionsProvider = StreamProvider<List<StudySessionModel>>((ref) {
  final repo     = ref.watch(sessionRepositoryProvider);
  final semester = ref.watch(activeSemesterProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchAllSessions(semester);
});

/// Today's analytics — recomputed whenever sessions or timetable changes
final todayAnalyticsProvider = Provider<DayAnalytics?>((ref) {
  final sessions    = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final classSlots  = ref.watch(allSlotsProvider).valueOrNull ?? [];
  final personalSlots = ref.watch(allPersonalSlotsProvider).valueOrNull ?? [];

  final today = DateTime.now();
  final todaySessions = sessions.where((s) {
    final d = s.startTime;
    return d.year == today.year && d.month == today.month && d.day == today.day;
  }).toList();

  return PlannedActualAnalyser.analyseDay(
    date: today,
    sessions: todaySessions,
    classSlots: classSlots,
    personalSlots: personalSlots,
  );
});

/// This week's analytics
final weeklyAnalyticsProvider = Provider<WeeklyAnalytics?>((ref) {
  final sessions      = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final classSlots    = ref.watch(allSlotsProvider).valueOrNull ?? [];
  final personalSlots = ref.watch(allPersonalSlotsProvider).valueOrNull ?? [];

  if (sessions.isEmpty) return null;

  final now       = DateTime.now();
  // Monday of the current week
  final weekStart = now.subtract(Duration(days: now.weekday - 1));
  final monday    = DateTime(weekStart.year, weekStart.month, weekStart.day);

  return PlannedActualAnalyser.analyseWeek(
    allSessions: sessions,
    classSlots: classSlots,
    personalSlots: personalSlots,
    weekStart: monday,
  );
});
```

---

## ⛳ CHECKPOINT 1

Verify all three:

- [ ] `lib/features/session/data/models/study_session_model.g.dart` exists
- [ ] `build_runner` exited with code 0
- [ ] `flutter analyze` shows 0 errors

```bash
git add .
git commit -m "feat(session): StudySession Isar model + domain analyser + global timer state"
```

**Tell Claude Code:** "Checkpoint 1 passed. Ready for Session 2."

---

---

# SESSION 2 — UI Widgets + Floating Mini-Timer

**Claude Code instruction:**
> "Read `_dev/PHASE4.md`. Checkpoint 1 is done. Execute Session 2 steps 9 through 16 only. After Step 16 run flutter analyze and confirm zero errors. Stop at Checkpoint 2 and report back."

---

## STEP 9 — Course Picker Widget

Create `lib/features/session/presentation/widgets/course_picker_sheet.dart`:

```dart
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
    final cwaCourses   = ref.watch(coursesProvider).valueOrNull ?? [];
    final todaySlots   = ref.watch(activeDaySlotsProvider);

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
            labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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
                    ? const Center(child: Text('No CWA courses added yet',
                        style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView(
                        children: cwaCourses.map((c) => ListTile(
                          leading: const Icon(Icons.school_outlined,
                              color: AppTheme.primary),
                          title: Text(c.code,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(c.name),
                          onTap: () => _pick(PickedCourse(
                            courseCode: c.code,
                            courseName: c.name,
                            source: 'cwa',
                          )),
                        )).toList(),
                      ),

                // Today's timetable slots
                todaySlots.isEmpty
                    ? const Center(child: Text("No classes scheduled today",
                        style: TextStyle(color: AppTheme.textSecondary)))
                    : ListView(
                        children: todaySlots.map((s) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(s.colorValue).withOpacity(0.15),
                            child: Text(s.courseCode.substring(0, 1),
                                style: TextStyle(
                                    color: Color(s.colorValue),
                                    fontWeight: FontWeight.w700)),
                          ),
                          title: Text(s.courseCode,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${s.startTimeLabel} · ${s.venue}'),
                          onTap: () => _pick(PickedCourse(
                            courseCode: s.courseCode,
                            courseName: s.courseName,
                            source: 'timetable',
                          )),
                        )).toList(),
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
                        decoration: const InputDecoration(
                            labelText: 'Course name'),
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
```

---

## STEP 10 — Floating Mini-Timer Widget

Create `lib/features/session/presentation/widgets/floating_mini_timer.dart`:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';

/// Floating pill shown at the bottom of every screen when a session is active.
/// Positioned above the bottom nav bar inside the AppShell Stack.
class FloatingMiniTimer extends ConsumerStatefulWidget {
  final VoidCallback onTap;
  const FloatingMiniTimer({super.key, required this.onTap});

  @override
  ConsumerState<FloatingMiniTimer> createState() => _FloatingMiniTimerState();
}

class _FloatingMiniTimerState extends ConsumerState<FloatingMiniTimer> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Tick every second to update the elapsed display
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(activeSessionProvider);
    if (session == null) return const SizedBox.shrink();

    return Positioned(
      left: 16,
      right: 16,
      bottom: 12,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Pulsing red dot
              _PulsingDot(),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      session.courseCode,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      session.courseName,
                      style: const TextStyle(color: Colors.white60, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Text(
                session.formattedElapsed,
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.white54, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
      ),
    );
  }
}
```

---

## STEP 11 — Update AppShell in app_router.dart to Include Floating Timer

Update `lib/core/router/app_router.dart` — replace the full file:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_screen.dart';
import 'package:campusiq/features/timetable/presentation/screens/timetable_screen.dart';
import 'package:campusiq/features/session/presentation/screens/session_screen.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/session/presentation/widgets/floating_mini_timer.dart';

final appRouter = GoRouter(
  initialLocation: '/cwa',
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: '/cwa',
          name: 'cwa',
          builder: (context, state) => const CwaScreen(),
        ),
        GoRoute(
          path: '/timetable',
          name: 'timetable',
          builder: (context, state) => const TimetableScreen(),
        ),
        GoRoute(
          path: '/sessions',
          name: 'sessions',
          builder: (context, state) => const SessionScreen(),
        ),
        // Phase 5: /streak
      ],
    ),
  ],
);

class _AppShell extends ConsumerWidget {
  final Widget child;
  const _AppShell({required this.child});

  int _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/timetable')) return 1;
    if (location.startsWith('/sessions')) return 2;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSessionActive = ref.watch(activeSessionProvider) != null;

    return Scaffold(
      body: Stack(
        children: [
          child,
          // Floating mini-timer overlays all screens when session is active
          if (isSessionActive)
            FloatingMiniTimer(
              onTap: () => context.go('/sessions'),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _locationToIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/cwa');
            case 1: context.go('/timetable');
            case 2: context.go('/sessions');
          }
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'CWA',
          ),
          const NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Timetable',
          ),
          NavigationDestination(
            icon: isSessionActive
                ? const Icon(Icons.timer, color: Colors.red)
                : const Icon(Icons.timer_outlined),
            selectedIcon: const Icon(Icons.timer),
            label: 'Sessions',
          ),
        ],
      ),
    );
  }
}
```

---

## STEP 12 — Session History Tile Widget

Create `lib/features/session/presentation/widgets/session_tile.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';

class SessionTile extends StatelessWidget {
  final StudySessionModel session;
  final VoidCallback onDelete;

  const SessionTile({super.key, required this.session, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final hour = session.startTime.hour;
    final suffix = hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    final timeLabel =
        '$displayHour:${session.startTime.minute.toString().padLeft(2, '0')} $suffix';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primary.withOpacity(0.1),
        child: Text(
          session.courseCode.length >= 2
              ? session.courseCode.substring(0, 2)
              : session.courseCode,
          style: const TextStyle(
            color: AppTheme.primary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      title: Text(session.courseCode,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(
        '$timeLabel · ${session.wasPlanned ? "Planned" : "Spontaneous"}',
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            session.formattedDuration,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.textSecondary),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
```

---

## STEP 13 — Analytics Summary Card

Create `lib/features/session/presentation/widgets/analytics_summary_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final DayAnalytics analytics;

  const AnalyticsSummaryCard({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final rate = (analytics.completionRate * 100).clamp(0, 200).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Today',
              style: TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Stat(
                label: 'Studied',
                value: _fmt(analytics.totalActualMinutes),
                color: Colors.white,
              ),
              _Stat(
                label: 'Planned',
                value: _fmt(analytics.totalPlannedMinutes),
                color: AppTheme.accent,
              ),
              _Stat(
                label: 'Sessions',
                value: '${analytics.sessionCount}',
                color: Colors.white,
              ),
              _Stat(
                label: 'Completion',
                value: '$rate%',
                color: rate >= 100
                    ? AppTheme.success
                    : AppTheme.warning,
              ),
            ],
          ),
          if (analytics.totalPlannedMinutes > 0) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: analytics.completionRate.clamp(0, 1),
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  rate >= 100 ? AppTheme.success : AppTheme.accent,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _Stat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
```

---

## STEP 14 — Course Breakdown Widget

Create `lib/features/session/presentation/widgets/course_breakdown_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';

class CourseBreakdownCard extends StatelessWidget {
  final List<CourseStats> courses;

  const CourseBreakdownCard({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    if (courses.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('By course',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            ...courses.map((c) => _CourseRow(stats: c)),
          ],
        ),
      ),
    );
  }
}

class _CourseRow extends StatelessWidget {
  final CourseStats stats;
  const _CourseRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    final barFill = stats.completionRate.clamp(0.0, 1.0);
    final isOver  = stats.isOverStudied;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(stats.courseCode,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
              Text(
                stats.plannedMinutes > 0
                    ? '${stats.formattedActual} / ${stats.formattedPlanned}'
                    : stats.formattedActual,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: barFill,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOver
                    ? AppTheme.success
                    : barFill > 0.7
                        ? AppTheme.accent
                        : AppTheme.warning,
              ),
            ),
          ),
          if (stats.plannedMinutes > 0) ...[
            const SizedBox(height: 3),
            Text(
              isOver
                  ? 'Extra study — great!'
                  : 'Need ${_fmt(stats.gapMinutes)} more',
              style: TextStyle(
                fontSize: 10,
                color: isOver
                    ? AppTheme.success
                    : AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}
```

---

## STEP 15 — Weekly Bar Chart Widget

Create `lib/features/session/presentation/widgets/weekly_bar_chart.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';

/// Simple custom bar chart — no external charting library needed.
class WeeklyBarChart extends StatelessWidget {
  final WeeklyAnalytics weekly;

  const WeeklyBarChart({super.key, required this.weekly});

  @override
  Widget build(BuildContext context) {
    final maxMinutes = weekly.days
        .map((d) => d.totalActualMinutes)
        .fold(0, (a, b) => a > b ? a : b);
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('This week',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Text(
                  _fmt(weekly.totalActualMinutes),
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: List.generate(weekly.days.length, (i) {
                  final day = weekly.days[i];
                  final fill = maxMinutes == 0
                      ? 0.0
                      : day.totalActualMinutes / maxMinutes;
                  final isToday = day.date.weekday == DateTime.now().weekday;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (day.totalActualMinutes > 0)
                            Text(
                              _fmt(day.totalActualMinutes),
                              style: const TextStyle(
                                  fontSize: 8,
                                  color: AppTheme.textSecondary),
                              textAlign: TextAlign.center,
                            ),
                          const SizedBox(height: 2),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 400),
                            height: (fill * 70).clamp(4, 70),
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppTheme.primary
                                  : AppTheme.primary.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            dayLabels[i],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isToday
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: isToday
                                  ? AppTheme.primary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            if (weekly.mostStudiedCourse.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 0.5),
              const SizedBox(height: 12),
              Row(
                children: [
                  _Insight(
                    icon: Icons.trending_up,
                    label: 'Most studied',
                    value: weekly.mostStudiedCourse,
                    color: AppTheme.success,
                  ),
                  const SizedBox(width: 16),
                  _Insight(
                    icon: Icons.trending_down,
                    label: 'Least studied',
                    value: weekly.leastStudiedCourse,
                    color: AppTheme.warning,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }
}

class _Insight extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _Insight({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppTheme.textSecondary)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## STEP 16 — Active Timer Card Widget

Create `lib/features/session/presentation/widgets/active_timer_card.dart`:

```dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/domain/active_session_state.dart';

/// Large timer card shown at the top of the Sessions screen when active.
class ActiveTimerCard extends StatefulWidget {
  final ActiveSessionState session;
  final VoidCallback onStop;
  final VoidCallback onCancel;

  const ActiveTimerCard({
    super.key,
    required this.session,
    required this.onStop,
    required this.onCancel,
  });

  @override
  State<ActiveTimerCard> createState() => _ActiveTimerCardState();
}

class _ActiveTimerCardState extends State<ActiveTimerCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            widget.session.courseCode,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            widget.session.courseName,
            style: const TextStyle(color: Colors.white60, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Text(
            widget.session.formattedElapsed,
            style: const TextStyle(
              color: AppTheme.accent,
              fontSize: 52,
              fontWeight: FontWeight.w700,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Session in progress',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white54,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: widget.onStop,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: AppTheme.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Stop & Save',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## ⛳ CHECKPOINT 2

Verify both:

- [ ] `flutter analyze` shows 0 errors
- [ ] No import errors in any widget created in Steps 9–16

```bash
git add .
git commit -m "feat(session): course picker, timer widgets, analytics cards, floating mini-timer"
```

**Tell Claude Code:** "Checkpoint 2 passed. Ready for Session 3."

---

---

# SESSION 3 — Session Screen + Full Integration

**Claude Code instruction:**
> "Read `_dev/PHASE4.md`. Checkpoints 1 and 2 are done. Execute Session 3 steps 17 through 21. Run the app and confirm all test items pass. Then stop and report back."

---

## STEP 17 — Session Screen

Create `lib/features/session/presentation/screens/session_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/session/domain/planned_actual_analyser.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/session/presentation/widgets/active_timer_card.dart';
import 'package:campusiq/features/session/presentation/widgets/analytics_summary_card.dart';
import 'package:campusiq/features/session/presentation/widgets/course_breakdown_card.dart';
import 'package:campusiq/features/session/presentation/widgets/course_picker_sheet.dart';
import 'package:campusiq/features/session/presentation/widgets/session_tile.dart';
import 'package:campusiq/features/session/presentation/widgets/weekly_bar_chart.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  Future<void> _startSession(BuildContext context, WidgetRef ref) async {
    final picked = await showModalBottomSheet<PickedCourse>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const CoursePickerSheet(),
    );

    if (picked == null || !context.mounted) return;

    ref.read(activeSessionProvider.notifier).startSession(
      courseCode: picked.courseCode,
      courseName: picked.courseName,
      courseSource: picked.source,
    );
  }

  Future<void> _stopSession(WidgetRef ref, String semesterKey) async {
    final notifier   = ref.read(activeSessionProvider.notifier);
    final completed  = notifier.stopSession();
    if (completed == null) return;

    final durationMins = completed.elapsedMinutes;
    if (durationMins < 1) return; // ignore < 1 min sessions

    // Check if session was planned (timetable slot exists for this course today)
    final todaySlots = ref.read(activeDaySlotsProvider);
    final wasPlanned = todaySlots.any(
      (s) => s.courseCode == completed.courseCode,
    );

    final session = StudySessionModel()
      ..courseCode      = completed.courseCode
      ..courseName      = completed.courseName
      ..startTime       = completed.startTime
      ..endTime         = DateTime.now()
      ..durationMinutes = durationMins
      ..wasPlanned      = wasPlanned
      ..courseSource    = completed.courseSource
      ..semesterKey     = semesterKey;

    final repo = ref.read(sessionRepositoryProvider);
    await repo?.saveSession(session);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession  = ref.watch(activeSessionProvider);
    final sessionsAsync  = ref.watch(allSessionsProvider);
    final todayAnalytics = ref.watch(todayAnalyticsProvider);
    final weeklyAnalytics = ref.watch(weeklyAnalyticsProvider);
    final semester       = ref.watch(activeSemesterProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Study Sessions',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Active timer or start button ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: activeSession != null
                  ? ActiveTimerCard(
                      session: activeSession,
                      onStop: () => _stopSession(ref, semester),
                      onCancel: () =>
                          ref.read(activeSessionProvider.notifier).cancelSession(),
                    )
                  : _StartCard(onStart: () => _startSession(context, ref)),
            ),
          ),

          // ── Today's analytics summary ─────────────────────────────────
          if (todayAnalytics != null && todayAnalytics.sessionCount > 0)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnalyticsSummaryCard(analytics: todayAnalytics),
              ),
            ),

          // ── Per-course breakdown ──────────────────────────────────────
          if (todayAnalytics != null && todayAnalytics.perCourse.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: CourseBreakdownCard(courses: todayAnalytics.perCourse),
              ),
            ),

          // ── Weekly bar chart ──────────────────────────────────────────
          if (weeklyAnalytics != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: WeeklyBarChart(weekly: weeklyAnalytics),
              ),
            ),

          // ── Session history ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text('History',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const Spacer(),
                  sessionsAsync.whenOrNull(
                        data: (s) => Text('${s.length} sessions',
                            style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.textSecondary)),
                      ) ??
                      const SizedBox.shrink(),
                ],
              ),
            ),
          ),

          sessionsAsync.when(
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(child: Text('Error: $e')),
            ),
            data: (sessions) {
              if (sessions.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('No sessions yet — start studying!',
                          style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final session = sessions[i];
                    return SessionTile(
                      session: session,
                      onDelete: () =>
                          ref.read(sessionRepositoryProvider)?.deleteSession(session.id),
                    );
                  },
                  childCount: sessions.length,
                ),
              );
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _StartCard extends StatelessWidget {
  final VoidCallback onStart;
  const _StartCard({required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        children: [
          const Icon(Icons.timer_outlined, size: 48, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          const Text('Ready to study?',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Pick a course and start your session',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Session',
                  style: TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## STEP 18 — Update CLAUDE.md

```
## Current phase
Phase 4 complete — Phase 5 next (Streak System)

## Global state
activeSessionProvider — lives above ShellRoute, survives tab switches
Timer uses DateTime anchor (not Stopwatch) for Android reliability
```

---

## STEP 19 — Final Build Check

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

---

## STEP 20 — Behavioral Feedback Strings

After the app runs cleanly, ask Claude Code to add this helper to
`lib/features/session/domain/planned_actual_analyser.dart`:

```dart
/// Generates a plain-language feedback string for the student.
static String feedbackForDay(DayAnalytics analytics) {
  if (analytics.sessionCount == 0) return 'No study sessions recorded today.';

  final rate = analytics.completionRate;
  final total = analytics.totalActualMinutes;
  final h = total ~/ 60;
  final m = total % 60;
  final timeStr = h > 0 ? '${h}h ${m}m' : '${m}m';

  if (analytics.totalPlannedMinutes == 0) {
    return 'You studied $timeStr today — great spontaneous effort!';
  }

  if (rate >= 1.0) return 'You hit your study target today. $timeStr studied. Keep it up!';
  if (rate >= 0.7) return 'Almost there — $timeStr studied, ${((1 - rate) * 100).toInt()}% left to hit your plan.';

  // Find most under-studied course
  final worst = analytics.perCourse
      .where((c) => c.plannedMinutes > 0 && c.actualMinutes < c.plannedMinutes)
      .fold<CourseStats?>(null, (prev, c) =>
          prev == null || c.gapMinutes > prev.gapMinutes ? c : prev);

  if (worst != null) {
    return 'You are under-studying ${worst.courseCode} — ${worst.formattedPlanned} planned, only ${worst.formattedActual} done.';
  }
  return 'Keep going — $timeStr studied today.';
}
```

---

## STEP 21 — Test Checklist

Test every item on your device/emulator:

**Session start**
- [ ] Sessions tab shows "Ready to study?" start card when idle
- [ ] Tapping "Start Session" opens course picker sheet with 3 tabs
- [ ] CWA Courses tab lists courses from CWA planner
- [ ] Today's Classes tab lists timetable slots for today
- [ ] Custom tab — typing code + name and tapping start works
- [ ] Selecting any course starts the session

**Active timer**
- [ ] Active timer card appears on Sessions screen with pulsing elapsed time
- [ ] Floating mini-timer pill appears above bottom nav on all screens
- [ ] Switching to CWA or Timetable tab — mini-timer remains visible
- [ ] Sessions tab icon turns red when session is active
- [ ] Tapping mini-timer navigates to Sessions screen
- [ ] Timer shows correct elapsed time after switching tabs and returning
- [ ] Cancel clears the session without saving
- [ ] "Stop & Save" saves the session and clears the timer

**Analytics**
- [ ] Today's summary card shows studied / planned / sessions / completion %
- [ ] Completion progress bar fills correctly
- [ ] Course breakdown shows per-course bars with actual vs planned
- [ ] Weekly bar chart shows bars for each day with today highlighted
- [ ] Most/least studied courses shown in weekly insights
- [ ] Session history list shows all past sessions newest first
- [ ] Delete on a session removes it and updates analytics

**Planned vs actual**
- [ ] Session for a course that has a timetable slot → `wasPlanned = true`
- [ ] Session for a custom course → `wasPlanned = false`
- [ ] Planned label shows correctly in session tile

**Persistence**
- [ ] Hot restart preserves all sessions and analytics

---

## ⛳ CHECKPOINT 3 — Phase 4 Complete

All test items must pass.

```bash
git add .
git commit -m "feat: Phase 4 complete — Study Session Tracking + Analytics Dashboard"
git push origin main
```

---

## Phase 4 Summary

| What was built | Location |
|---|---|
| StudySession Isar schema | `features/session/data/models/` |
| Session repository | `features/session/data/repositories/` |
| PlannedActualAnalyser (pure Dart) | `features/session/domain/` |
| ActiveSessionState (DateTime anchor) | `features/session/domain/` |
| ActiveSessionNotifier (global) | `features/session/presentation/providers/` |
| Session + analytics providers | `features/session/presentation/providers/` |
| CoursePickerSheet (CWA + timetable + custom) | `features/session/presentation/widgets/` |
| FloatingMiniTimer (above nav shell) | `features/session/presentation/widgets/` |
| ActiveTimerCard | `features/session/presentation/widgets/` |
| AnalyticsSummaryCard | `features/session/presentation/widgets/` |
| CourseBreakdownCard (planned vs actual bars) | `features/session/presentation/widgets/` |
| WeeklyBarChart (custom, no library) | `features/session/presentation/widgets/` |
| SessionTile | `features/session/presentation/widgets/` |
| SessionScreen | `features/session/presentation/screens/` |
| AppShell updated with floating timer + Sessions tab | `core/router/` |

**Phase 5 next:** Streak System — consistency tracking + engagement mechanics

---

*CampusIQ · PHASE4.md · WesleyConsults Dev · April 2026*
