# CampusIQ — PHASE5.md
## Streak System — Consistency Tracking + Engagement Mechanics
**Builds on**: Phase 4 complete | **Package**: com.wesleyconsults.campusiq
**Streak types**: Study + Per-course + Attendance
**Milestones**: 3, 7, 14, 21, 30, 40, 50, 60, 70, 80, 90, 100 days
**Location**: New dedicated Streak tab (4th bottom nav item)

---

## HOW TO USE THIS FILE

Drive this in three Claude Code sessions. Each session ends at a checkpoint.
Open a **fresh Claude Code terminal session** for Phase 5.

**Start each session with:**
> "Read `_dev/PHASE5.md`. [Session instruction below.]"

---

## ARCHITECTURE DECISION — Read before starting

### No new Isar schema needed

Streak state is **computed entirely from existing data**:
- Study streak → reads `StudySessionModel` records (Phase 4)
- Per-course streak → reads `StudySessionModel` filtered by courseCode
- Attendance streak → reads `TimetableSlotModel` + a lightweight attended-days
  list stored as a simple Isar `UserPrefsModel` (one row, JSON-encoded list)

We add **one** new Isar collection: `UserPrefsModel` — a single-row key/value
store for lightweight persistent flags (attended days, last opened date, etc.).
This is simpler than adding a full attendance schema.

### Streak calculation

All streak logic lives in a pure Dart `StreakCalculator` class.
It receives a sorted `List<DateTime>` of active days and returns the current
streak, longest streak, and which milestones have been reached.

**Edge case handled**: if the student hasn't studied TODAY but studied
yesterday, their streak is still alive (it hasn't been broken yet — the
day isn't over). The calculator uses `isStreakAlive` to distinguish
"active and intact" from "broken".

### Milestone system

Milestones are value objects — no Isar collection. A milestone is
"unlocked" if `longestStreak >= milestone.days`. Unlocked milestones
are computed on every provider rebuild from the streak data.

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
Phase 5 — Streak System

## Routes live
/cwa        → CWA Target Planner
/timetable  → Class + Personal Timetable (swipe layers)
/sessions   → Session Tracker + Analytics Dashboard
/streak     → Streak System (new)
```

---

---

# SESSION 1 — UserPrefs Model + Streak Calculator + Domain Logic

**Claude Code instruction:**
> "Read `_dev/PHASE5.md`. Execute Session 1 steps 1 through 8 only. After Step 8 run build_runner and flutter analyze. Stop at Checkpoint 1 and report back."

---

## STEP 1 — UserPrefs Isar Model

Create `lib/core/data/models/user_prefs_model.dart`:

```dart
import 'package:isar/isar.dart';

part 'user_prefs_model.g.dart';

/// Single-row key/value store for lightweight persistent app preferences.
/// Only one instance ever exists (id = 1).
@collection
class UserPrefsModel {
  Id id = 1; // always 1 — single row

  /// JSON-encoded list of ISO date strings the student marked attendance.
  /// e.g. '["2024-11-04","2024-11-05"]'
  String attendedDatesJson = '[]';

  /// Last date the app was opened — used for streak alive check.
  DateTime? lastOpenedDate;

  UserPrefsModel();
}
```

---

## STEP 2 — Run Codegen

```bash
dart run build_runner build --delete-conflicting-outputs
```

Confirm `user_prefs_model.g.dart` was generated.

---

## STEP 3 — Update Isar Provider

Update `lib/core/providers/isar_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';
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
      UserPrefsModelSchema,
    ],
    directory: dir.path,
  );
});
```

---

## STEP 4 — UserPrefs Repository

Create `lib/core/data/repositories/user_prefs_repository.dart`:

```dart
import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';

class UserPrefsRepository {
  final Isar _isar;
  UserPrefsRepository(this._isar);

  Future<UserPrefsModel> _getOrCreate() async {
    final existing = await _isar.userPrefsModels.get(1);
    if (existing != null) return existing;
    final prefs = UserPrefsModel();
    await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
    return prefs;
  }

  Stream<UserPrefsModel?> watchPrefs() {
    return _isar.userPrefsModels.watchObject(1, fireImmediately: true);
  }

  /// Returns the list of dates the student marked attendance.
  Future<List<DateTime>> getAttendedDates() async {
    final prefs = await _getOrCreate();
    final List<dynamic> decoded = jsonDecode(prefs.attendedDatesJson);
    return decoded
        .map((s) => DateTime.tryParse(s as String))
        .whereType<DateTime>()
        .toList();
  }

  /// Toggles attendance for a date (adds if absent, removes if present).
  Future<void> toggleAttendance(DateTime date) async {
    final prefs = await _getOrCreate();
    final dates = await getAttendedDates();
    final dateStr = _toStr(date);
    final strList = dates.map(_toStr).toList();

    if (strList.contains(dateStr)) {
      strList.remove(dateStr);
    } else {
      strList.add(dateStr);
    }

    prefs.attendedDatesJson = jsonEncode(strList);
    await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
  }

  Future<void> updateLastOpened(DateTime date) async {
    final prefs = await _getOrCreate();
    prefs.lastOpenedDate = date;
    await _isar.writeTxn(() => _isar.userPrefsModels.put(prefs));
  }

  static String _toStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}
```

---

## STEP 5 — Milestone Value Object

Create `lib/features/streak/domain/milestone.dart`:

```dart
/// A streak milestone — unlocked when longestStreak >= days.
class Milestone {
  final int days;
  final String label;
  final String emoji;

  const Milestone({
    required this.days,
    required this.label,
    required this.emoji,
  });

  /// All milestones in the app — ordered ascending.
  static const List<Milestone> all = [
    Milestone(days: 3,   label: '3-Day Starter',     emoji: '🌱'),
    Milestone(days: 7,   label: 'One Week',           emoji: '🔥'),
    Milestone(days: 14,  label: 'Two Weeks',          emoji: '⚡'),
    Milestone(days: 21,  label: 'Three Weeks',        emoji: '💪'),
    Milestone(days: 30,  label: 'One Month',          emoji: '🏆'),
    Milestone(days: 40,  label: '40-Day Grind',       emoji: '🦁'),
    Milestone(days: 50,  label: 'Halfway to 100',     emoji: '🚀'),
    Milestone(days: 60,  label: '60-Day Scholar',     emoji: '🎓'),
    Milestone(days: 70,  label: '70-Day Warrior',     emoji: '⚔️'),
    Milestone(days: 80,  label: '80-Day Champion',    emoji: '🥇'),
    Milestone(days: 90,  label: '90-Day Legend',      emoji: '👑'),
    Milestone(days: 100, label: '100-Day Master',     emoji: '💯'),
  ];

  /// Next milestone the student hasn't reached yet.
  static Milestone? nextAfter(int currentStreak) {
    try {
      return all.firstWhere((m) => m.days > currentStreak);
    } catch (_) {
      return null; // all milestones unlocked
    }
  }
}
```

---

## STEP 6 — Streak Result Value Object

Create `lib/features/streak/domain/streak_result.dart`:

```dart
import 'package:campusiq/features/streak/domain/milestone.dart';

class StreakResult {
  /// Current active streak in days
  final int currentStreak;

  /// All-time longest streak
  final int longestStreak;

  /// True if the streak is still alive (studied today OR yesterday and
  /// today isn't over yet)
  final bool isAlive;

  /// True if studied today already
  final bool studiedToday;

  /// Milestones unlocked so far (longestStreak >= milestone.days)
  final List<Milestone> unlockedMilestones;

  /// Next milestone to aim for
  final Milestone? nextMilestone;

  /// Days remaining to next milestone
  final int daysToNextMilestone;

  const StreakResult({
    required this.currentStreak,
    required this.longestStreak,
    required this.isAlive,
    required this.studiedToday,
    required this.unlockedMilestones,
    required this.nextMilestone,
    required this.daysToNextMilestone,
  });

  /// Loss-aversion message shown when streak is alive but not studied today.
  String? get lossAversionMessage {
    if (studiedToday || currentStreak == 0) return null;
    if (currentStreak == 1) return "Study today to start your streak!";
    return "Don't lose your $currentStreak-day streak — study something today!";
  }

  /// Motivational message for the streak card header.
  String get statusMessage {
    if (currentStreak == 0) return 'Start your streak today!';
    if (studiedToday && currentStreak >= 7) return 'On fire! Keep going 🔥';
    if (studiedToday) return 'Great — streak intact!';
    return 'Study today to keep your streak alive';
  }
}
```

---

## STEP 7 — Streak Calculator (Pure Domain Logic)

Create `lib/features/streak/domain/streak_calculator.dart`:

```dart
import 'package:campusiq/features/streak/domain/milestone.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

class StreakCalculator {
  /// Computes a StreakResult from a list of dates on which the student
  /// performed the tracked activity (studied, attended, etc.).
  ///
  /// [activeDates] — the dates to analyse (unsorted is fine)
  /// [today]       — inject for testability; defaults to DateTime.now()
  static StreakResult calculate({
    required List<DateTime> activeDates,
    DateTime? today,
  }) {
    final now = today ?? DateTime.now();
    final todayNorm = _norm(now);

    if (activeDates.isEmpty) {
      return StreakResult(
        currentStreak: 0,
        longestStreak: 0,
        isAlive: false,
        studiedToday: false,
        unlockedMilestones: [],
        nextMilestone: Milestone.all.first,
        daysToNextMilestone: Milestone.all.first.days,
      );
    }

    // Deduplicate and sort descending
    final unique = activeDates.map(_norm).toSet().toList()
      ..sort((a, b) => b.compareTo(a));

    final studiedToday = unique.first == todayNorm;

    // Current streak: walk backwards from today (or yesterday if not
    // studied today — streak is still alive until midnight)
    int current = 0;
    DateTime cursor = studiedToday
        ? todayNorm
        : todayNorm.subtract(const Duration(days: 1));

    for (final date in unique) {
      if (date == cursor) {
        current++;
        cursor = cursor.subtract(const Duration(days: 1));
      } else if (date.isBefore(cursor)) {
        break; // gap found
      }
    }

    // Longest streak: sliding window over sorted unique dates (ascending)
    final asc = unique.reversed.toList();
    int longest = 0;
    int run = 1;
    for (int i = 1; i < asc.length; i++) {
      final diff = asc[i].difference(asc[i - 1]).inDays;
      if (diff == 1) {
        run++;
        if (run > longest) longest = run;
      } else {
        run = 1;
      }
    }
    if (longest == 0 && asc.isNotEmpty) longest = 1;
    // current might exceed historical longest (it IS the new longest)
    if (current > longest) longest = current;

    final isAlive = current > 0;
    final unlocked = Milestone.all.where((m) => longest >= m.days).toList();
    final next = Milestone.nextAfter(longest);
    final daysToNext = next == null ? 0 : next.days - current;

    return StreakResult(
      currentStreak: current,
      longestStreak: longest,
      isAlive: isAlive,
      studiedToday: studiedToday,
      unlockedMilestones: unlocked,
      nextMilestone: next,
      daysToNextMilestone: daysToNext,
    );
  }

  /// Normalise a DateTime to midnight for date-only comparison.
  static DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);
}
```

---

## STEP 8 — Streak Providers

Create `lib/features/streak/presentation/providers/streak_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/streak/domain/streak_calculator.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

/// UserPrefs repository provider
final userPrefsRepositoryProvider = Provider<UserPrefsRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => UserPrefsRepository(isar));
});

/// Live stream of attended dates from UserPrefs
final attendedDatesProvider = StreamProvider<List<DateTime>>((ref) async* {
  final repo = ref.watch(userPrefsRepositoryProvider);
  if (repo == null) return;

  await for (final _ in repo.watchPrefs()) {
    final dates = await repo.getAttendedDates();
    yield dates;
  }
});

/// Study streak — derived from session records
final studyStreakProvider = Provider<StreakResult>((ref) {
  final sessions = ref.watch(allSessionsProvider).valueOrNull ?? [];

  final activeDates = sessions.map((s) => s.startTime).toList();
  return StreakCalculator.calculate(activeDates: activeDates);
});

/// Per-course streak map — courseCode → StreakResult
final perCourseStreakProvider = Provider<Map<String, StreakResult>>((ref) {
  final sessions = ref.watch(allSessionsProvider).valueOrNull ?? [];
  final courses  = ref.watch(coursesProvider).valueOrNull ?? [];

  final result = <String, StreakResult>{};
  for (final course in courses) {
    final courseDates = sessions
        .where((s) => s.courseCode == course.code)
        .map((s) => s.startTime)
        .toList();
    result[course.code] = StreakCalculator.calculate(activeDates: courseDates);
  }
  return result;
});

/// Attendance streak — derived from manually marked attended dates
final attendanceStreakProvider = Provider<StreakResult>((ref) {
  final datesAsync = ref.watch(attendedDatesProvider);
  final dates = datesAsync.valueOrNull ?? [];
  return StreakCalculator.calculate(activeDates: dates);
});
```

---

## ⛳ CHECKPOINT 1

Verify all three:

- [ ] `lib/core/data/models/user_prefs_model.g.dart` exists
- [ ] `build_runner` exited with code 0
- [ ] `flutter analyze` shows 0 errors

```bash
git add .
git commit -m "feat(streak): UserPrefsModel + StreakCalculator + milestone system + providers"
```

**Tell Claude Code:** "Checkpoint 1 passed. Ready for Session 2."

---

---

# SESSION 2 — Streak UI Widgets

**Claude Code instruction:**
> "Read `_dev/PHASE5.md`. Checkpoint 1 is done. Execute Session 2 steps 9 through 16 only. After Step 16 run flutter analyze and confirm zero errors. Stop at Checkpoint 2 and report back."

---

## STEP 9 — Streak Hero Card Widget

Create `lib/features/streak/presentation/widgets/streak_hero_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

/// The large flame card at the top of the Streak screen.
class StreakHeroCard extends StatelessWidget {
  final StreakResult streak;
  final String title;

  const StreakHeroCard({
    super.key,
    required this.streak,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isAlive = streak.isAlive && streak.currentStreak > 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isAlive ? AppTheme.primary : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Flame + count
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isAlive ? '🔥' : '💤',
                style: const TextStyle(fontSize: 40),
              ),
              const SizedBox(width: 8),
              Text(
                '${streak.currentStreak}',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w800,
                  color: isAlive ? AppTheme.accent : Colors.grey.shade400,
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  ' days',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: isAlive ? Colors.white70 : Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            streak.statusMessage,
            style: TextStyle(
              fontSize: 14,
              color: isAlive ? Colors.white70 : Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),

          // Loss aversion banner
          if (streak.lossAversionMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppTheme.warning.withOpacity(0.4),
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      streak.lossAversionMessage!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isAlive
                            ? Colors.white
                            : AppTheme.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _Stat(
                label: 'Best streak',
                value: '${streak.longestStreak}d',
                color: isAlive ? AppTheme.accent : Colors.grey.shade500,
              ),
              _Divider(isAlive: isAlive),
              _Stat(
                label: 'Milestones',
                value: '${streak.unlockedMilestones.length}',
                color: isAlive ? Colors.white : Colors.grey.shade500,
              ),
              _Divider(isAlive: isAlive),
              _Stat(
                label: 'Next badge',
                value: streak.nextMilestone == null
                    ? 'All done!'
                    : '${streak.daysToNextMilestone}d',
                color: isAlive ? Colors.white : Colors.grey.shade500,
              ),
            ],
          ),
        ],
      ),
    );
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
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.white54)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  final bool isAlive;
  const _Divider({required this.isAlive});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 36,
      color: isAlive
          ? Colors.white.withOpacity(0.2)
          : Colors.grey.shade300,
    );
  }
}
```

---

## STEP 10 — Milestone Badge Grid Widget

Create `lib/features/streak/presentation/widgets/milestone_grid.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/streak/domain/milestone.dart';

class MilestoneGrid extends StatelessWidget {
  final List<Milestone> unlocked;
  final int currentStreak;

  const MilestoneGrid({
    super.key,
    required this.unlocked,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Badges',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Text(
                  '${unlocked.length} / ${Milestone.all.length}',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
              ),
              itemCount: Milestone.all.length,
              itemBuilder: (context, i) {
                final milestone = Milestone.all[i];
                final isUnlocked = unlocked.contains(milestone);
                final isNext = !isUnlocked &&
                    (i == 0 ||
                        unlocked.contains(Milestone.all[i - 1]));

                return _BadgeTile(
                  milestone: milestone,
                  isUnlocked: isUnlocked,
                  isNext: isNext,
                  currentStreak: currentStreak,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final Milestone milestone;
  final bool isUnlocked;
  final bool isNext;
  final int currentStreak;

  const _BadgeTile({
    required this.milestone,
    required this.isUnlocked,
    required this.isNext,
    required this.currentStreak,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isUnlocked ? 1.0 : 0.35,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked
              ? AppTheme.accent.withOpacity(0.1)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked
                ? AppTheme.accent.withOpacity(0.4)
                : isNext
                    ? AppTheme.primary.withOpacity(0.3)
                    : Colors.grey.shade200,
            width: isNext ? 1.5 : 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isUnlocked ? milestone.emoji : '🔒',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 4),
            Text(
              '${milestone.days}d',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isUnlocked ? AppTheme.primary : Colors.grey.shade400,
              ),
            ),
            if (isNext) ...[
              const SizedBox(height: 2),
              Text(
                '${milestone.days - currentStreak} left',
                style: const TextStyle(
                    fontSize: 9, color: AppTheme.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## STEP 11 — Per-Course Streak List Widget

Create `lib/features/streak/presentation/widgets/course_streak_list.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

class CourseStreakList extends StatelessWidget {
  /// courseCode → StreakResult
  final Map<String, StreakResult> streaks;

  const CourseStreakList({super.key, required this.streaks});

  @override
  Widget build(BuildContext context) {
    if (streaks.isEmpty) {
      return const SizedBox.shrink();
    }

    final sorted = streaks.entries.toList()
      ..sort((a, b) => b.value.currentStreak.compareTo(a.value.currentStreak));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Per-course streaks',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            ...sorted.map((entry) => _CourseStreakRow(
                  courseCode: entry.key,
                  result: entry.value,
                )),
          ],
        ),
      ),
    );
  }
}

class _CourseStreakRow extends StatelessWidget {
  final String courseCode;
  final StreakResult result;

  const _CourseStreakRow({
    required this.courseCode,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final isAlive = result.isAlive && result.currentStreak > 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: isAlive
                ? AppTheme.primary.withOpacity(0.1)
                : Colors.grey.shade100,
            child: Text(
              courseCode.length >= 2
                  ? courseCode.substring(0, 2)
                  : courseCode,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isAlive ? AppTheme.primary : Colors.grey.shade400,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(courseCode,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text(
                  result.studiedToday
                      ? 'Studied today ✓'
                      : result.currentStreak > 0
                          ? 'Last studied — keep going!'
                          : 'No streak yet',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                isAlive ? '🔥' : '💤',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 4),
              Text(
                '${result.currentStreak}d',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isAlive ? AppTheme.primary : Colors.grey.shade400,
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

## STEP 12 — Attendance Tracker Widget

Create `lib/features/streak/presentation/widgets/attendance_tracker.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

/// 7-day attendance row — student taps each day to mark attendance.
class AttendanceTracker extends StatelessWidget {
  final StreakResult attendanceStreak;
  final List<DateTime> attendedDates;
  final void Function(DateTime date) onToggle;

  const AttendanceTracker({
    super.key,
    required this.attendanceStreak,
    required this.attendedDates,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final days = List.generate(7, (i) {
      return DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: 6 - i));
    });
    final dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Attendance streak',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
                const Spacer(),
                Row(
                  children: [
                    const Text('🎓', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${attendanceStreak.currentStreak}d',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap a day to mark class attendance',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((day) {
                final isToday = day.day == today.day &&
                    day.month == today.month &&
                    day.year == today.year;
                final isFuture = day.isAfter(today);
                final isAttended = attendedDates.any((d) =>
                    d.year == day.year &&
                    d.month == day.month &&
                    d.day == day.day);
                final label = dayLabels[day.weekday - 1];

                return GestureDetector(
                  onTap: isFuture ? null : () => onToggle(day),
                  child: Column(
                    children: [
                      Text(
                        label.substring(0, 1),
                        style: TextStyle(
                          fontSize: 11,
                          color: isToday
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                          fontWeight: isToday
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isAttended
                              ? AppTheme.primary
                              : isFuture
                                  ? Colors.grey.shade100
                                  : Colors.grey.shade200,
                          shape: BoxShape.circle,
                          border: isToday
                              ? Border.all(
                                  color: AppTheme.primary, width: 2)
                              : null,
                        ),
                        alignment: Alignment.center,
                        child: isAttended
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isFuture
                                      ? Colors.grey.shade300
                                      : AppTheme.textSecondary,
                                ),
                              ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## STEP 13 — Streak Summary Mini Widget

Create `lib/features/streak/presentation/widgets/streak_summary_mini.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

/// Compact streak summary — used as a row of three streak types.
class StreakSummaryRow extends StatelessWidget {
  final StreakResult study;
  final StreakResult attendance;
  final int totalCourseStreaks;

  const StreakSummaryRow({
    super.key,
    required this.study,
    required this.attendance,
    required this.totalCourseStreaks,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _MiniCard(emoji: '🔥', label: 'Study', days: study.currentStreak, isAlive: study.isAlive)),
        const SizedBox(width: 8),
        Expanded(child: _MiniCard(emoji: '🎓', label: 'Attendance', days: attendance.currentStreak, isAlive: attendance.isAlive)),
        const SizedBox(width: 8),
        Expanded(child: _MiniCard(emoji: '📚', label: 'Courses', days: totalCourseStreaks, isAlive: totalCourseStreaks > 0)),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String emoji;
  final String label;
  final int days;
  final bool isAlive;

  const _MiniCard({
    required this.emoji,
    required this.label,
    required this.days,
    required this.isAlive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 0.5),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            '$days${label == 'Courses' ? '' : 'd'}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isAlive ? AppTheme.primary : Colors.grey.shade400,
            ),
          ),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
```

---

## STEP 14 — Calendar Heatmap Widget

Create `lib/features/streak/presentation/widgets/activity_heatmap.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';

/// 4-week rolling activity heatmap — darker = more sessions that day.
class ActivityHeatmap extends StatelessWidget {
  /// date → number of sessions that day
  final Map<DateTime, int> activityByDay;

  const ActivityHeatmap({super.key, required this.activityByDay});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayNorm = DateTime(today.year, today.month, today.day);

    // Build 28-day grid (4 weeks), starting from 27 days ago
    final days = List.generate(28, (i) {
      return todayNorm.subtract(Duration(days: 27 - i));
    });

    final maxActivity = activityByDay.values.fold(0, (a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Last 4 weeks',
                style:
                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(4, (week) {
                return Expanded(
                  child: Column(
                    children: List.generate(7, (day) {
                      final index = week * 7 + day;
                      final date = days[index];
                      final norm = DateTime(date.year, date.month, date.day);
                      final count = activityByDay[norm] ?? 0;
                      final isToday = norm == todayNorm;

                      double intensity = 0;
                      if (maxActivity > 0 && count > 0) {
                        intensity = (count / maxActivity).clamp(0.2, 1.0);
                      }

                      return Padding(
                        padding: const EdgeInsets.all(2),
                        child: Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: count == 0
                                ? Colors.grey.shade100
                                : AppTheme.primary.withOpacity(intensity),
                            borderRadius: BorderRadius.circular(3),
                            border: isToday
                                ? Border.all(
                                    color: AppTheme.accent, width: 1.5)
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text('Less',
                    style: TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary)),
                const SizedBox(width: 4),
                ...List.generate(4, (i) {
                  return Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(right: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.primary
                          .withOpacity(0.15 + i * 0.25),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
                const SizedBox(width: 4),
                const Text('More',
                    style: TextStyle(
                        fontSize: 10, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## STEP 15 — Next Milestone Progress Card

Create `lib/features/streak/presentation/widgets/next_milestone_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';

class NextMilestoneCard extends StatelessWidget {
  final StreakResult streak;

  const NextMilestoneCard({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final next = streak.nextMilestone;
    if (next == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: const [
              Text('💯', style: TextStyle(fontSize: 28)),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'All milestones unlocked. You are a legend.',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final progress = streak.longestStreak / next.days;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(next.emoji, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(next.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                      Text(
                        '${streak.daysToNextMilestone} day${streak.daysToNextMilestone == 1 ? '' : 's'} to unlock',
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${next.days}d',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppTheme.accent),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${streak.longestStreak} / ${next.days} days',
              style: const TextStyle(
                  fontSize: 11, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## STEP 16 — flutter analyze

```bash
flutter analyze
```

Must show 0 errors before continuing.

---

## ⛳ CHECKPOINT 2

Verify both:

- [ ] `flutter analyze` shows 0 errors
- [ ] No import errors in any widget created in Steps 9–15

```bash
git add .
git commit -m "feat(streak): streak hero card, milestone grid, course streaks, attendance tracker, heatmap"
```

**Tell Claude Code:** "Checkpoint 2 passed. Ready for Session 3."

---

---

# SESSION 3 — Streak Screen + Navigation Integration

**Claude Code instruction:**
> "Read `_dev/PHASE5.md`. Checkpoints 1 and 2 are done. Execute Session 3 steps 17 through 22. Run the app and confirm all test items pass. Then stop and report back."

---

## STEP 17 — Streak Screen

Create `lib/features/streak/presentation/screens/streak_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/session/data/models/study_session_model.dart';
import 'package:campusiq/features/session/presentation/providers/session_provider.dart';
import 'package:campusiq/features/streak/domain/streak_result.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';
import 'package:campusiq/features/streak/presentation/widgets/activity_heatmap.dart';
import 'package:campusiq/features/streak/presentation/widgets/attendance_tracker.dart';
import 'package:campusiq/features/streak/presentation/widgets/course_streak_list.dart';
import 'package:campusiq/features/streak/presentation/widgets/milestone_grid.dart';
import 'package:campusiq/features/streak/presentation/widgets/next_milestone_card.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_hero_card.dart';
import 'package:campusiq/features/streak/presentation/widgets/streak_summary_mini.dart';

class StreakScreen extends ConsumerWidget {
  const StreakScreen({super.key});

  /// Builds a day → session count map for the heatmap
  Map<DateTime, int> _buildActivityMap(List<StudySessionModel> sessions) {
    final map = <DateTime, int>{};
    for (final s in sessions) {
      final norm = DateTime(
          s.startTime.year, s.startTime.month, s.startTime.day);
      map[norm] = (map[norm] ?? 0) + 1;
    }
    return map;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final studyStreak      = ref.watch(studyStreakProvider);
    final attendanceStreak = ref.watch(attendanceStreakProvider);
    final perCourseStreaks  = ref.watch(perCourseStreakProvider);
    final attendedDates    = ref.watch(attendedDatesProvider).valueOrNull ?? [];
    final sessions         = ref.watch(allSessionsProvider).valueOrNull ?? [];
    final prefsRepo        = ref.watch(userPrefsRepositoryProvider);

    final activityMap = _buildActivityMap(sessions);
    final activeCourseStreaks = perCourseStreaks.values
        .where((r) => r.currentStreak > 0)
        .length;

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Streaks',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: CustomScrollView(
        slivers: [
          // ── Summary mini row ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: StreakSummaryRow(
                study: studyStreak,
                attendance: attendanceStreak,
                totalCourseStreaks: activeCourseStreaks,
              ),
            ),
          ),

          // ── Study streak hero ─────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: StreakHeroCard(
                streak: studyStreak,
                title: 'Study streak',
              ),
            ),
          ),

          // ── Next milestone ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: NextMilestoneCard(streak: studyStreak),
            ),
          ),

          // ── Milestone badge grid ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: MilestoneGrid(
                unlocked: studyStreak.unlockedMilestones,
                currentStreak: studyStreak.currentStreak,
              ),
            ),
          ),

          // ── Attendance tracker ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: AttendanceTracker(
                attendanceStreak: attendanceStreak,
                attendedDates: attendedDates,
                onToggle: (date) => prefsRepo?.toggleAttendance(date),
              ),
            ),
          ),

          // ── Per-course streaks ────────────────────────────────────────
          if (perCourseStreaks.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: CourseStreakList(streaks: perCourseStreaks),
              ),
            ),

          // ── Activity heatmap ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: ActivityHeatmap(activityByDay: activityMap),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
```

---

## STEP 18 — Update Go Router (add Streak route + 4th nav item)

Replace the full contents of `lib/core/router/app_router.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_screen.dart';
import 'package:campusiq/features/timetable/presentation/screens/timetable_screen.dart';
import 'package:campusiq/features/session/presentation/screens/session_screen.dart';
import 'package:campusiq/features/session/presentation/providers/active_session_provider.dart';
import 'package:campusiq/features/session/presentation/widgets/floating_mini_timer.dart';
import 'package:campusiq/features/streak/presentation/screens/streak_screen.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

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
        GoRoute(
          path: '/streak',
          name: 'streak',
          builder: (context, state) => const StreakScreen(),
        ),
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
    if (location.startsWith('/sessions'))  return 2;
    if (location.startsWith('/streak'))    return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSessionActive = ref.watch(activeSessionProvider) != null;
    final studyStreak     = ref.watch(studyStreakProvider);
    final hasLossRisk     = studyStreak.lossAversionMessage != null;

    return Scaffold(
      body: Stack(
        children: [
          child,
          if (isSessionActive)
            FloatingMiniTimer(onTap: () => context.go('/sessions')),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _locationToIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/cwa');
            case 1: context.go('/timetable');
            case 2: context.go('/sessions');
            case 3: context.go('/streak');
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
          NavigationDestination(
            icon: hasLossRisk
                ? Badge(
                    label: const Text('!'),
                    child: const Icon(Icons.local_fire_department_outlined),
                  )
                : const Icon(Icons.local_fire_department_outlined),
            selectedIcon: const Icon(Icons.local_fire_department),
            label: 'Streak',
          ),
        ],
      ),
    );
  }
}
```

---

## STEP 19 — Update CLAUDE.md

```
## Current phase
Phase 5 complete — MVP DONE 🎉

## MVP feature set
- CWA Target Planner (offline, live calculation)
- Dual-layer Timetable (class + personal, swipe view, full recurrence)
- Study Session Tracker (DateTime anchor timer, planned vs actual)
- Streak System (study + per-course + attendance, milestones, heatmap)

## Phase 6 (future)
AI timetable scanning (Google ML Kit OCR)
Smart study scheduler
Study Connect (social feature)
Firebase sync + push notifications
```

---

## STEP 20 — Final Build Check

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

---

## STEP 21 — Test Checklist

**Navigation**
- [ ] 4th tab "Streak" appears in bottom nav with flame icon
- [ ] Streak tab shows a red badge `!` when streak is alive but not studied today
- [ ] Tapping Streak tab opens StreakScreen

**Summary row**
- [ ] Three mini cards show Study / Attendance / Courses streak counts
- [ ] Counts update after recording a study session

**Study streak hero card**
- [ ] Shows current streak count with 🔥 when alive, 💤 when zero
- [ ] Shows correct status message
- [ ] Loss-aversion warning visible when streak is alive but not studied today
- [ ] Best streak, milestones count, next badge stats correct
- [ ] Progress bar visible

**Milestone grid**
- [ ] 12 badges displayed in 4-column grid
- [ ] Locked badges show 🔒 at reduced opacity
- [ ] Unlocked badges show their emoji at full opacity
- [ ] Next badge shows "X days left" label
- [ ] Studying more days unlocks badges correctly

**Next milestone card**
- [ ] Shows correct next milestone emoji and label
- [ ] Progress bar fills based on current streak / target
- [ ] Shows "All milestones unlocked" when all 12 done

**Attendance tracker**
- [ ] 7-day row shows last 7 days
- [ ] Today has a highlighted border
- [ ] Tapping a past day marks it attended (checkmark, navy fill)
- [ ] Tapping again un-marks it
- [ ] Attendance streak count updates correctly after marking

**Per-course streaks**
- [ ] Lists all CWA courses with their individual streaks
- [ ] Courses sorted by streak length descending
- [ ] Shows 🔥 for alive streaks, 💤 for zero

**Activity heatmap**
- [ ] 4-week grid visible with 28 cells
- [ ] Days with sessions show darker navy fill
- [ ] Days with more sessions are darker than days with fewer
- [ ] Today has a gold border
- [ ] Legend shows less → more gradient

**Persistence**
- [ ] Hot restart preserves all streak data
- [ ] Attended dates persist across restarts

---

## ⛳ CHECKPOINT 3 — Phase 5 Complete — MVP Done

All test items above must pass.

```bash
git add .
git commit -m "feat: Phase 5 complete — Streak System. CampusIQ MVP done."
git push origin main
```

---

## Phase 5 Summary

| What was built | Location |
|---|---|
| UserPrefsModel Isar schema (single row) | `core/data/models/` |
| UserPrefs repository (attended dates) | `core/data/repositories/` |
| Milestone value objects (12 badges) | `features/streak/domain/` |
| StreakResult value object | `features/streak/domain/` |
| StreakCalculator pure Dart (edge-case safe) | `features/streak/domain/` |
| Streak providers (study + per-course + attendance) | `features/streak/presentation/providers/` |
| StreakHeroCard (flame + loss aversion) | `features/streak/presentation/widgets/` |
| MilestoneGrid (12 badges, lock/unlock) | `features/streak/presentation/widgets/` |
| CourseStreakList | `features/streak/presentation/widgets/` |
| AttendanceTracker (7-day tap row) | `features/streak/presentation/widgets/` |
| ActivityHeatmap (28-day rolling grid) | `features/streak/presentation/widgets/` |
| NextMilestoneCard (progress bar) | `features/streak/presentation/widgets/` |
| StreakSummaryRow (3 mini cards) | `features/streak/presentation/widgets/` |
| StreakScreen | `features/streak/presentation/screens/` |
| AppShell updated (4th nav + loss badge) | `core/router/` |

---

## 🎉 CampusIQ MVP — Complete

| Phase | Feature | Status |
|---|---|---|
| 1 | CWA Target Planner | ✅ |
| 2 | Class Timetable + Free Time Detection | ✅ |
| 3 | Personal Timetable + Dual Layer View | ✅ |
| 4 | Study Session Tracking + Analytics | ✅ |
| 5 | Streak System | ✅ |

**Next steps after MVP:**
1. Test with real KNUST students — get feedback
2. Fix pain points from real usage
3. Add Firebase Auth + Firestore sync (Phase 6 foundation)
4. Google ML Kit OCR for AI timetable scanning (Phase 6)
5. Play Store listing — target KNUST student groups on WhatsApp/Twitter

---

*CampusIQ · PHASE5.md · WesleyConsults Dev · April 2026*
