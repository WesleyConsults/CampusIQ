# CampusIQ — PHASE2.md
## Manual Class Timetable + Free Time Detection
**Builds on**: Phase 1 complete | **Package**: com.wesleyconsults.campusiq
**Grid**: Paged (one day at a time, swipe) | **Time range**: 6AM–8PM | **Add slot**: FAB + tap empty cell

---

## HOW TO USE THIS FILE

Drive this in three Claude Code sessions. Each session ends at a checkpoint.
Do not cross a checkpoint without verifying it first.

**Start each session with:**
> "Read `_dev/PHASE2.md`. [Session instruction below.]"

---

## PRE-FLIGHT — Before Session 1

Confirm Phase 1 is clean:

```bash
cd /media/edwin/18FC2827FC28021C/projects/campusiq
flutter analyze          # must show 0 errors
git status               # must be clean
```

Update `_dev/CLAUDE.md` — change the current phase line to:

```
## Current phase
Phase 2 — Manual Class Timetable + Free Time Detection
```

---

---

# SESSION 1 — Isar Model + Repository + Providers

**Claude Code instruction:**
> "Read `_dev/PHASE2.md`. Execute Session 1 steps 1 through 6 only. After Step 6 run build_runner and flutter analyze. Stop at Checkpoint 1 and report back."

---

## STEP 1 — Update Isar Provider to include TimetableSlot schema

We are adding a new Isar collection. The Isar provider must register it.

Update `lib/core/providers/isar_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';

/// Single shared Isar instance for all features.
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [CourseModelSchema, TimetableSlotModelSchema],
    directory: dir.path,
  );
});
```

---

## STEP 2 — TimetableSlot Isar Model

Create `lib/features/timetable/data/models/timetable_slot_model.dart`:

```dart
import 'package:isar/isar.dart';

part 'timetable_slot_model.g.dart';

/// Represents one class slot in the student's official university timetable.
/// This is Layer 1 of the dual timetable system.
@collection
class TimetableSlotModel {
  Id id = Isar.autoIncrement;

  /// 0 = Monday, 1 = Tuesday ... 5 = Saturday (KNUST runs Mon–Sat)
  late int dayIndex;

  late String courseCode;
  late String courseName;
  late String venue;

  /// Minutes from midnight. e.g. 8:30AM = 510
  late int startMinutes;
  late int endMinutes;

  /// "Lecture" | "Practical" | "Tutorial"
  late String slotType;

  /// Color hex stored as int for Isar compatibility. e.g. 0xFF2196F3
  late int colorValue;

  /// Semester key — matches CWA courses. e.g. "2024-Sem2"
  late String semesterKey;

  DateTime createdAt = DateTime.now();

  TimetableSlotModel();

  /// Convenience: duration in minutes
  int get durationMinutes => endMinutes - startMinutes;

  /// Convenience: human-readable start time e.g. "8:30 AM"
  String get startTimeLabel => _minutesToLabel(startMinutes);
  String get endTimeLabel => _minutesToLabel(endMinutes);

  static String _minutesToLabel(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final suffix = h < 12 ? 'AM' : 'PM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${hour.toString()}:${m.toString().padLeft(2, '0')} $suffix';
  }
}
```

---

## STEP 3 — Run Codegen

```bash
dart run build_runner build --delete-conflicting-outputs
```

Confirm `timetable_slot_model.g.dart` was generated before continuing.

---

## STEP 4 — Timetable Constants

Create `lib/features/timetable/domain/timetable_constants.dart`:

```dart
import 'package:flutter/material.dart';

class TimetableConstants {
  /// Days shown in the timetable grid. KNUST runs Monday to Saturday.
  static const List<String> dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  static const List<String> dayFullLabels = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'
  ];

  /// Grid time range: 6AM to 8PM
  static const int gridStartHour = 6;   // 6AM = 360 minutes
  static const int gridEndHour = 20;    // 8PM = 1200 minutes
  static const int gridStartMinutes = gridStartHour * 60;
  static const int gridEndMinutes = gridEndHour * 60;
  static const int totalGridMinutes = gridEndMinutes - gridStartMinutes; // 840

  /// Height in pixels per minute in the grid
  static const double pixelsPerMinute = 1.5;

  /// Total grid height in pixels
  static const double totalGridHeight = totalGridMinutes * pixelsPerMinute; // 1260px

  /// Width of the time label column on the left
  static const double timeLabelWidth = 52.0;

  /// Height of each hour row label
  static const double hourRowHeight = 60.0 * pixelsPerMinute; // 90px

  /// Slot type options
  static const List<String> slotTypes = ['Lecture', 'Practical', 'Tutorial'];

  /// Preset slot colors (one per course, cycles through this list)
  static const List<int> slotColorValues = [
    0xFF1565C0, // Deep blue
    0xFF2E7D32, // Deep green
    0xFF6A1B9A, // Deep purple
    0xFFC62828, // Deep red
    0xFF00838F, // Deep cyan
    0xFFE65100, // Deep orange
    0xFF4527A0, // Deep indigo
    0xFF558B2F, // Light green dark
  ];

  /// Returns a color value for a new slot based on how many slots exist
  static int colorForIndex(int index) =>
      slotColorValues[index % slotColorValues.length];
}
```

---

## STEP 5 — Free Time Detection Domain Logic

Create `lib/features/timetable/domain/free_time_detector.dart`:

```dart
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// Represents a gap between class slots — a free block the student can use.
class FreeBlock {
  final int startMinutes;
  final int endMinutes;
  final int dayIndex;

  const FreeBlock({
    required this.startMinutes,
    required this.endMinutes,
    required this.dayIndex,
  });

  int get durationMinutes => endMinutes - startMinutes;
  String get startLabel => TimetableSlotModel._minutesToLabel(startMinutes);
  String get endLabel => TimetableSlotModel._minutesToLabel(endMinutes);

  /// Only surface free blocks of 30 minutes or more
  bool get isUsable => durationMinutes >= 30;
}

class FreeTimeDetector {
  /// Returns all usable free blocks for a given day's slots.
  /// Slots must be sorted by startMinutes before calling this.
  static List<FreeBlock> detect({
    required int dayIndex,
    required List<TimetableSlotModel> slots,
    int gridStart = TimetableConstants.gridStartMinutes,
    int gridEnd = TimetableConstants.gridEndMinutes,
  }) {
    if (slots.isEmpty) return [];

    final sorted = [...slots]..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    final blocks = <FreeBlock>[];

    // Gap before first class
    if (sorted.first.startMinutes > gridStart) {
      final block = FreeBlock(
        startMinutes: gridStart,
        endMinutes: sorted.first.startMinutes,
        dayIndex: dayIndex,
      );
      if (block.isUsable) blocks.add(block);
    }

    // Gaps between classes
    for (int i = 0; i < sorted.length - 1; i++) {
      final gapStart = sorted[i].endMinutes;
      final gapEnd = sorted[i + 1].startMinutes;
      if (gapEnd > gapStart) {
        final block = FreeBlock(
          startMinutes: gapStart,
          endMinutes: gapEnd,
          dayIndex: dayIndex,
        );
        if (block.isUsable) blocks.add(block);
      }
    }

    // Gap after last class
    if (sorted.last.endMinutes < gridEnd) {
      final block = FreeBlock(
        startMinutes: sorted.last.endMinutes,
        endMinutes: gridEnd,
        dayIndex: dayIndex,
      );
      if (block.isUsable) blocks.add(block);
    }

    return blocks;
  }
}
```

---

## STEP 6 — Timetable Repository

Create `lib/features/timetable/data/repositories/timetable_repository.dart`:

```dart
import 'package:isar/isar.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';

class TimetableRepository {
  final Isar _isar;
  TimetableRepository(this._isar);

  /// Live stream of all slots for a semester — re-emits on any change.
  Stream<List<TimetableSlotModel>> watchAllSlots(String semesterKey) {
    return _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .watch(fireImmediately: true);
  }

  /// Live stream filtered to one day.
  Stream<List<TimetableSlotModel>> watchSlotsForDay(String semesterKey, int dayIndex) {
    return _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .and()
        .dayIndexEqualTo(dayIndex)
        .watch(fireImmediately: true);
  }

  Future<void> addSlot(TimetableSlotModel slot) async {
    await _isar.writeTxn(() => _isar.timetableSlotModels.put(slot));
  }

  Future<void> updateSlot(TimetableSlotModel slot) async {
    await _isar.writeTxn(() => _isar.timetableSlotModels.put(slot));
  }

  Future<void> deleteSlot(Id id) async {
    await _isar.writeTxn(() => _isar.timetableSlotModels.delete(id));
  }

  Future<List<TimetableSlotModel>> getSlotsForDayOnce(String semesterKey, int dayIndex) async {
    return _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .and()
        .dayIndexEqualTo(dayIndex)
        .findAll();
  }

  /// Returns how many slots exist — used to assign next color.
  Future<int> countSlots(String semesterKey) async {
    return _isar.timetableSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .count();
  }
}
```

---

## ⛳ CHECKPOINT 1

Verify all three:

- [ ] `lib/features/timetable/data/models/timetable_slot_model.g.dart` exists
- [ ] `build_runner` exited with code 0
- [ ] `flutter analyze` shows 0 errors

**If any check fails, fix before continuing.**

```bash
git add .
git commit -m "feat(timetable): TimetableSlot Isar model + repository + free time detector"
```

**Tell Claude Code:** "Checkpoint 1 passed. Ready for Session 2."

---

---

# SESSION 2 — Providers + Grid Widgets

**Claude Code instruction:**
> "Read `_dev/PHASE2.md`. Checkpoint 1 is done. Execute Session 2 steps 7 through 13 only. After Step 13 run flutter analyze and confirm zero errors. Stop at Checkpoint 2 and report back."

---

## STEP 7 — Timetable Riverpod Providers

Create `lib/features/timetable/presentation/providers/timetable_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/data/repositories/timetable_repository.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';

/// Currently viewed day index (0=Mon … 5=Sat). Drives the paged grid.
final activeDayProvider = StateProvider<int>((ref) {
  /// Default to today if it's a weekday, otherwise Monday.
  final weekday = DateTime.now().weekday; // 1=Mon … 7=Sun
  if (weekday >= 1 && weekday <= 6) return weekday - 1;
  return 0;
});

/// Repository provider.
final timetableRepositoryProvider = Provider<TimetableRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => TimetableRepository(isar));
});

/// Live stream of ALL slots for the active semester.
final allSlotsProvider = StreamProvider<List<TimetableSlotModel>>((ref) {
  final repo = ref.watch(timetableRepositoryProvider);
  final semester = ref.watch(activeSemesterProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchAllSlots(semester);
});

/// Slots filtered to the active day — what the grid renders.
final activeDaySlotsProvider = Provider<List<TimetableSlotModel>>((ref) {
  final allSlots = ref.watch(allSlotsProvider).valueOrNull ?? [];
  final day = ref.watch(activeDayProvider);
  final sorted = allSlots.where((s) => s.dayIndex == day).toList()
    ..sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
  return sorted;
});

/// Free blocks for the active day, derived from class slots.
final activeDayFreeBlocksProvider = Provider<List<FreeBlock>>((ref) {
  final slots = ref.watch(activeDaySlotsProvider);
  final day = ref.watch(activeDayProvider);
  return FreeTimeDetector.detect(dayIndex: day, slots: slots);
});

/// Slot count for color assignment.
final slotCountProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(timetableRepositoryProvider);
  final semester = ref.watch(activeSemesterProvider);
  if (repo == null) return 0;
  return repo.countSlots(semester);
});
```

---

## STEP 8 — Day Selector Widget

Create `lib/features/timetable/presentation/widgets/day_selector.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';

/// Horizontal scrollable day pill selector shown above the grid.
class DaySelector extends ConsumerWidget {
  const DaySelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDay = ref.watch(activeDayProvider);
    final allSlots = ref.watch(allSlotsProvider).valueOrNull ?? [];

    return SizedBox(
      height: 56,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: TimetableConstants.dayLabels.length,
        itemBuilder: (context, i) {
          final isActive = i == activeDay;
          final hasSlots = allSlots.any((s) => s.dayIndex == i);

          return GestureDetector(
            onTap: () => ref.read(activeDayProvider.notifier).state = i,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppTheme.primary : Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    TimetableConstants.dayLabels[i],
                    style: TextStyle(
                      color: isActive ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                  if (hasSlots) ...[
                    const SizedBox(width: 4),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white60 : AppTheme.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
```

---

## STEP 9 — Timetable Slot Card Widget

Create `lib/features/timetable/presentation/widgets/timetable_slot_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// A positioned slot card rendered inside the timetable grid.
/// Uses absolute positioning based on startMinutes/endMinutes.
class TimetableSlotCard extends StatelessWidget {
  final TimetableSlotModel slot;
  final double columnWidth;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TimetableSlotCard({
    super.key,
    required this.slot,
    required this.columnWidth,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final topOffset = (slot.startMinutes - TimetableConstants.gridStartMinutes) *
        TimetableConstants.pixelsPerMinute;
    final height = slot.durationMinutes * TimetableConstants.pixelsPerMinute;
    final color = Color(slot.colorValue);
    final isShort = height < 40;

    return Positioned(
      top: topOffset,
      left: 2,
      right: 2,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: isShort
              ? Text(
                  slot.courseCode,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    overflow: TextOverflow.ellipsis,
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.courseCode,
                      style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (!isShort) ...[
                      Text(
                        slot.courseName,
                        style: TextStyle(
                          color: color.withOpacity(0.8),
                          fontSize: 10,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                      const Spacer(),
                      Text(
                        '${slot.startTimeLabel} · ${slot.slotType}',
                        style: TextStyle(
                          color: color.withOpacity(0.7),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}
```

---

## STEP 10 — Free Block Indicator Widget

Create `lib/features/timetable/presentation/widgets/free_block_indicator.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// A tappable free-time indicator rendered inside the grid.
/// Tapping pre-fills the add slot form with this time range.
class FreeBlockIndicator extends StatelessWidget {
  final FreeBlock block;
  final VoidCallback onTap;

  const FreeBlockIndicator({super.key, required this.block, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final topOffset = (block.startMinutes - TimetableConstants.gridStartMinutes) *
        TimetableConstants.pixelsPerMinute;
    final height = block.durationMinutes * TimetableConstants.pixelsPerMinute;

    // Only show label if there's enough room
    final showLabel = height >= 30;

    return Positioned(
      top: topOffset,
      left: 2,
      right: 2,
      height: height,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.success.withOpacity(0.06),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: AppTheme.success.withOpacity(0.25),
              width: 0.5,
            ),
          ),
          alignment: Alignment.center,
          child: showLabel
              ? Text(
                  'Free · ${block.durationMinutes}min',
                  style: TextStyle(
                    color: AppTheme.success.withOpacity(0.7),
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
```

---

## STEP 11 — Timetable Grid Widget

Create `lib/features/timetable/presentation/widgets/timetable_grid.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/widgets/timetable_slot_card.dart';
import 'package:campusiq/features/timetable/presentation/widgets/free_block_indicator.dart';

/// The main scrollable daily grid. Renders time labels + slot cards + free blocks.
class TimetableGrid extends StatelessWidget {
  final List<TimetableSlotModel> slots;
  final List<FreeBlock> freeBlocks;
  final void Function(TimetableSlotModel) onSlotTap;
  final void Function(TimetableSlotModel) onSlotLongPress;
  final void Function(FreeBlock) onFreeBlockTap;
  final VoidCallback onEmptyCellTap;

  const TimetableGrid({
    super.key,
    required this.slots,
    required this.freeBlocks,
    required this.onSlotTap,
    required this.onSlotLongPress,
    required this.onFreeBlockTap,
    required this.onEmptyCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time label column
          _TimeLabels(),
          // Slot column
          Expanded(
            child: GestureDetector(
              onTap: onEmptyCellTap,
              child: SizedBox(
                height: TimetableConstants.totalGridHeight,
                child: Stack(
                  children: [
                    // Hour separator lines
                    _HourLines(),
                    // Free blocks (rendered below slots)
                    ...freeBlocks.map((b) => FreeBlockIndicator(
                          block: b,
                          onTap: () => onFreeBlockTap(b),
                        )),
                    // Class slots
                    ...slots.map((s) => TimetableSlotCard(
                          slot: s,
                          columnWidth: double.infinity,
                          onTap: () => onSlotTap(s),
                          onLongPress: () => onSlotLongPress(s),
                        )),
                    // Current time indicator
                    _CurrentTimeIndicator(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Renders hour labels on the left column.
class _TimeLabels extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hours = List.generate(
      TimetableConstants.gridEndHour - TimetableConstants.gridStartHour,
      (i) => TimetableConstants.gridStartHour + i,
    );

    return SizedBox(
      width: TimetableConstants.timeLabelWidth,
      height: TimetableConstants.totalGridHeight,
      child: Stack(
        children: hours.map((hour) {
          final topOffset = (hour - TimetableConstants.gridStartHour) *
              TimetableConstants.hourRowHeight;
          final label = hour == 0
              ? '12 AM'
              : hour < 12
                  ? '$hour AM'
                  : hour == 12
                      ? '12 PM'
                      : '${hour - 12} PM';
          return Positioned(
            top: topOffset - 6,
            left: 0,
            right: 4,
            child: Text(
              label,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Horizontal lines at each hour boundary.
class _HourLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hours = TimetableConstants.gridEndHour - TimetableConstants.gridStartHour;
    return SizedBox(
      height: TimetableConstants.totalGridHeight,
      child: Stack(
        children: List.generate(hours, (i) {
          final topOffset = i * TimetableConstants.hourRowHeight;
          return Positioned(
            top: topOffset,
            left: 0,
            right: 0,
            child: Divider(height: 0.5, color: Colors.grey.shade200),
          );
        }),
      ),
    );
  }
}

/// Red line showing the current time. Only visible if today is the active day.
class _CurrentTimeIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowMinutes = now.hour * 60 + now.minute;

    if (nowMinutes < TimetableConstants.gridStartMinutes ||
        nowMinutes > TimetableConstants.gridEndMinutes) {
      return const SizedBox.shrink();
    }

    final topOffset = (nowMinutes - TimetableConstants.gridStartMinutes) *
        TimetableConstants.pixelsPerMinute;

    return Positioned(
      top: topOffset,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Container(height: 1, color: Colors.red.withOpacity(0.6)),
          ),
        ],
      ),
    );
  }
}
```

---

## STEP 12 — Add Slot Bottom Sheet

Create `lib/features/timetable/presentation/widgets/add_slot_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

class AddSlotSheet extends StatefulWidget {
  final int dayIndex;
  final String semesterKey;
  final int colorValue;
  final TimetableSlotModel? existing;
  /// If opened from a free block, pre-fill these times
  final int? prefillStartMinutes;
  final int? prefillEndMinutes;

  const AddSlotSheet({
    super.key,
    required this.dayIndex,
    required this.semesterKey,
    required this.colorValue,
    this.existing,
    this.prefillStartMinutes,
    this.prefillEndMinutes,
  });

  @override
  State<AddSlotSheet> createState() => _AddSlotSheetState();
}

class _AddSlotSheetState extends State<AddSlotSheet> {
  final _codeController = TextEditingController();
  final _nameController = TextEditingController();
  final _venueController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late int _startMinutes;
  late int _endMinutes;
  late String _slotType;
  late int _dayIndex;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _codeController.text = existing.courseCode;
      _nameController.text = existing.courseName;
      _venueController.text = existing.venue;
      _startMinutes = existing.startMinutes;
      _endMinutes = existing.endMinutes;
      _slotType = existing.slotType;
      _dayIndex = existing.dayIndex;
    } else {
      _startMinutes = widget.prefillStartMinutes ?? TimetableConstants.gridStartMinutes + 120; // 8AM default
      _endMinutes = widget.prefillEndMinutes ?? _startMinutes + 120; // 2hr default
      _slotType = TimetableConstants.slotTypes.first;
      _dayIndex = widget.dayIndex;
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _venueController.dispose();
    super.dispose();
  }

  String _minutesToTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = TimeOfDay(
      hour: (isStart ? _startMinutes : _endMinutes) ~/ 60,
      minute: (isStart ? _startMinutes : _endMinutes) % 60,
    );
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;
    final totalMinutes = picked.hour * 60 + picked.minute;
    setState(() {
      if (isStart) {
        _startMinutes = totalMinutes;
        if (_endMinutes <= _startMinutes) _endMinutes = _startMinutes + 60;
      } else {
        _endMinutes = totalMinutes;
      }
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_endMinutes <= _startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }

    final slot = widget.existing ?? TimetableSlotModel();
    slot.courseCode = _codeController.text.trim().toUpperCase();
    slot.courseName = _nameController.text.trim();
    slot.venue = _venueController.text.trim();
    slot.startMinutes = _startMinutes;
    slot.endMinutes = _endMinutes;
    slot.slotType = _slotType;
    slot.dayIndex = _dayIndex;
    slot.semesterKey = widget.semesterKey;
    slot.colorValue = widget.colorValue;

    Navigator.of(context).pop(slot);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.existing == null ? 'Add Class' : 'Edit Class',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Day selector
              DropdownButtonFormField<int>(
                value: _dayIndex,
                decoration: const InputDecoration(labelText: 'Day'),
                items: List.generate(
                  TimetableConstants.dayFullLabels.length,
                  (i) => DropdownMenuItem(value: i, child: Text(TimetableConstants.dayFullLabels[i])),
                ),
                onChanged: (v) => setState(() => _dayIndex = v!),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Course code (e.g. COE 456)'),
                textCapitalization: TextCapitalization.characters,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Course name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _venueController,
                decoration: const InputDecoration(labelText: 'Venue (e.g. Hall 3)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Time pickers
              Row(
                children: [
                  Expanded(
                    child: _TimeTile(
                      label: 'Start time',
                      value: _minutesToTime(_startMinutes),
                      onTap: () => _pickTime(true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeTile(
                      label: 'End time',
                      value: _minutesToTime(_endMinutes),
                      onTap: () => _pickTime(false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Slot type
              DropdownButtonFormField<String>(
                value: _slotType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: TimetableConstants.slotTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _slotType = v!),
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(widget.existing == null ? 'Add Class' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeTile({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
```

---

## STEP 13 — Slot Detail Bottom Sheet

Create `lib/features/timetable/presentation/widgets/slot_detail_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// Shows full details of a slot. Options: edit or delete.
class SlotDetailSheet extends StatelessWidget {
  final TimetableSlotModel slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const SlotDetailSheet({
    super.key,
    required this.slot,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final color = Color(slot.colorValue);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                slot.courseCode,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  slot.slotType,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(slot.courseName, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
          const SizedBox(height: 16),
          _DetailRow(icon: Icons.access_time, label: '${slot.startTimeLabel} – ${slot.endTimeLabel}'),
          const SizedBox(height: 8),
          _DetailRow(icon: Icons.location_on_outlined, label: slot.venue),
          const SizedBox(height: 8),
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: TimetableConstants.dayFullLabels[slot.dayIndex],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onDelete();
                  },
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red, width: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    onEdit();
                  },
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
      ],
    );
  }
}
```

---

## ⛳ CHECKPOINT 2

Verify both:

- [ ] `flutter analyze` shows 0 errors
- [ ] No import errors in any file created in Steps 7–13

**If any check fails, fix before continuing.**

```bash
git add .
git commit -m "feat(timetable): providers, grid widgets, slot cards, add/detail sheets"
```

**Tell Claude Code:** "Checkpoint 2 passed. Ready for Session 3."

---

---

# SESSION 3 — Timetable Screen + Navigation Integration

**Claude Code instruction:**
> "Read `_dev/PHASE2.md`. Checkpoints 1 and 2 are done. Execute Session 3 steps 14 through 19. Run the app and confirm all test items pass. Then stop and report back."

---

## STEP 14 — Timetable Screen

Create `lib/features/timetable/presentation/screens/timetable_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/features/timetable/presentation/widgets/day_selector.dart';
import 'package:campusiq/features/timetable/presentation/widgets/timetable_grid.dart';
import 'package:campusiq/features/timetable/presentation/widgets/add_slot_sheet.dart';
import 'package:campusiq/features/timetable/presentation/widgets/slot_detail_sheet.dart';

class TimetableScreen extends ConsumerWidget {
  const TimetableScreen({super.key});

  Future<void> _openAddSheet(
    BuildContext context,
    WidgetRef ref, {
    TimetableSlotModel? existing,
    int? prefillStart,
    int? prefillEnd,
  }) async {
    final day = ref.read(activeDayProvider);
    final semester = ref.read(activeSemesterProvider);
    final slotCount = await ref.read(slotCountProvider.future);
    final colorValue = TimetableConstants.colorForIndex(slotCount);

    if (!context.mounted) return;

    final result = await showModalBottomSheet<TimetableSlotModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddSlotSheet(
        dayIndex: day,
        semesterKey: semester,
        colorValue: existing?.colorValue ?? colorValue,
        existing: existing,
        prefillStartMinutes: prefillStart,
        prefillEndMinutes: prefillEnd,
      ),
    );

    if (result == null) return;
    final repo = ref.read(timetableRepositoryProvider);
    if (repo == null) return;

    existing == null ? await repo.addSlot(result) : await repo.updateSlot(result);
  }

  void _openDetailSheet(BuildContext context, WidgetRef ref, TimetableSlotModel slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SlotDetailSheet(
        slot: slot,
        onEdit: () => _openAddSheet(context, ref, existing: slot),
        onDelete: () {
          final repo = ref.read(timetableRepositoryProvider);
          repo?.deleteSlot(slot.id);
        },
      ),
    );
  }

  void _onFreeBlockTap(BuildContext context, WidgetRef ref, FreeBlock block) {
    _openAddSheet(
      context,
      ref,
      prefillStart: block.startMinutes,
      prefillEnd: block.endMinutes,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(activeDaySlotsProvider);
    final freeBlocks = ref.watch(activeDayFreeBlocksProvider);
    final activeDay = ref.watch(activeDayProvider);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Timetable', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add class',
            onPressed: () => _openAddSheet(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          const DaySelector(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  TimetableConstants.dayFullLabels[activeDay],
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const Spacer(),
                if (freeBlocks.isNotEmpty)
                  Text(
                    '${freeBlocks.length} free block${freeBlocks.length > 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.success.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: slots.isEmpty
                ? _EmptyDay(onAdd: () => _openAddSheet(context, ref))
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: TimetableGrid(
                      slots: slots,
                      freeBlocks: freeBlocks,
                      onSlotTap: (s) => _openDetailSheet(context, ref, s),
                      onSlotLongPress: (s) => _openDetailSheet(context, ref, s),
                      onFreeBlockTap: (b) => _onFreeBlockTap(context, ref, b),
                      onEmptyCellTap: () => _openAddSheet(context, ref),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddSheet(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Class'),
      ),
    );
  }
}

class _EmptyDay extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyDay({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 56, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          const Text('No classes today', style: TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: 4),
          const Text('Tap + to add a class slot', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Add Class'),
          ),
        ],
      ),
    );
  }
}
```

---

## STEP 15 — Update Go Router

Update `lib/core/router/app_router.dart` to add the timetable route and bottom navigation shell:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_screen.dart';
import 'package:campusiq/features/timetable/presentation/screens/timetable_screen.dart';

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
        // Phase 4: /sessions
        // Phase 5: /streak
      ],
    ),
  ],
);

class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  int _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/timetable')) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _locationToIndex(context),
        onDestinationSelected: (i) {
          switch (i) {
            case 0: context.go('/cwa');
            case 1: context.go('/timetable');
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school),
            label: 'CWA',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Timetable',
          ),
        ],
      ),
    );
  }
}
```

---

## STEP 16 — Update app.dart to remove duplicate Scaffold

Since the ShellRoute now owns the bottom nav Scaffold, update `lib/app.dart` to ensure no double-Scaffold issues:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/router/app_router.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/core/constants/app_constants.dart';

class CampusIQApp extends StatelessWidget {
  const CampusIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
```

---

## STEP 17 — Update CLAUDE.md

Update `_dev/CLAUDE.md` — add the timetable folder to the architecture note:

```
## Current phase
Phase 2 complete — Phase 3 next (Personal Timetable + Dual View)

## Routes live
/cwa        → CWA Target Planner
/timetable  → Class Timetable
```

---

## STEP 18 — Final Verification

Run in order:

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

---

## STEP 19 — Test Checklist

**Test every item on your device/emulator:**

- [ ] Bottom nav shows CWA and Timetable tabs — switching works
- [ ] Timetable screen opens on today's day by default
- [ ] Day selector pills at top — tapping changes active day
- [ ] Days with slots show a gold dot in the day selector
- [ ] FAB opens Add Class sheet
- [ ] Add icon in AppBar also opens Add Class sheet
- [ ] Tapping an empty area on grid opens Add Class sheet
- [ ] Adding a class slot renders it on the grid at the correct time position
- [ ] Slot card shows course code, name, start time, and type
- [ ] Tapping a slot opens the detail sheet with edit / delete options
- [ ] Editing a slot updates it in place on the grid
- [ ] Deleting a slot removes it from the grid
- [ ] Free blocks appear as green indicators between class slots
- [ ] Tapping a free block opens Add Class sheet pre-filled with that time range
- [ ] Red current-time line visible if running during 6AM–8PM
- [ ] Adding slots on multiple days — each day shows its own slots
- [ ] Hot restart preserves all slots (Isar persistence confirmed)

---

## ⛳ CHECKPOINT 3 — Phase 2 Complete

All 17 test items above must pass.

**If anything fails**, paste the error or describe the broken behaviour to Claude Code. Do not commit broken code.

When all pass:

```bash
git add .
git commit -m "feat: Phase 2 complete — Class Timetable + Free Time Detection"
git push origin main
```

---

## Phase 2 Summary

| What was built | Location |
|---|---|
| TimetableSlot Isar schema | `features/timetable/data/models/` |
| Timetable repository | `features/timetable/data/repositories/` |
| Free time detector (pure Dart) | `features/timetable/domain/` |
| Timetable constants (grid config) | `features/timetable/domain/` |
| Riverpod providers | `features/timetable/presentation/providers/` |
| Day selector pill widget | `features/timetable/presentation/widgets/` |
| Scrollable time grid | `features/timetable/presentation/widgets/` |
| Slot card (absolute positioned) | `features/timetable/presentation/widgets/` |
| Free block indicator | `features/timetable/presentation/widgets/` |
| Add slot bottom sheet | `features/timetable/presentation/widgets/` |
| Slot detail sheet | `features/timetable/presentation/widgets/` |
| Full timetable screen | `features/timetable/presentation/screens/` |
| Bottom nav shell via Go Router | `core/router/` |

**Phase 3 next:** Personal Timetable + Dual Layer View

---

*CampusIQ · PHASE2.md · WesleyConsults Dev · April 2026*
