# CampusIQ — PHASE3.md
## Personal Timetable + Dual Layer View
**Builds on**: Phase 2 complete | **Package**: com.wesleyconsults.campusiq
**Add personal slot**: Bottom sheet | **Layer toggle**: Swipe gesture (PageView)
**Recurring**: Full support — one-off, daily, weekly

---

## HOW TO USE THIS FILE

Drive this in three Claude Code sessions. Each session ends at a checkpoint.
Open a **fresh Claude Code terminal session** for Phase 3.

**Start each session with:**
> "Read `_dev/PHASE3.md`. [Session instruction below.]"

---

## ARCHITECTURE DECISION — Read before starting

### How dual-layer rendering works

The timetable grid `Stack` already renders class slots (Layer 1).
Phase 3 adds personal slots (Layer 2) to the same `Stack`, drawn **below** class slots with lighter opacity.

The three views (Class Only / Personal Only / Both) are implemented as a **`PageView` with 3 pages**, swiped horizontally. A page indicator shows which view is active. No toggle buttons needed.

### How recurring slots work

Recurring slots are stored **once** in Isar with a `recurrenceType` field.
A pure Dart `SlotExpander` reads stored slots and expands them into **concrete instances** for the active day before the grid renders them. This means:
- Isar stays clean — no duplicated rows
- The grid always receives a flat `List<PersonalSlotModel>` — no recurrence logic in widgets
- Phase 4's session tracker can reference the original slot ID for planned vs actual comparison

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
Phase 3 — Personal Timetable + Dual Layer View

## Routes live
/cwa        → CWA Target Planner
/timetable  → Class Timetable + Personal Timetable (dual layer, swiped)
```

---

---

# SESSION 1 — Isar Model + Recurrence Logic + Repository

**Claude Code instruction:**
> "Read `_dev/PHASE3.md`. Execute Session 1 steps 1 through 7 only. After Step 7 run build_runner and flutter analyze. Stop at Checkpoint 1 and report back."

---

## STEP 1 — Personal Slot Category Enum

Create `lib/features/timetable/domain/personal_slot_category.dart`:

```dart
/// Categories for personal timetable slots.
/// Stored as string in Isar for readability and forward compatibility.
enum PersonalSlotCategory {
  study,
  gym,
  rest,
  meal,
  sideProject,
  devotion,
  errand,
  custom;

  String get label {
    switch (this) {
      case study:      return 'Study';
      case gym:        return 'Gym';
      case rest:       return 'Rest';
      case meal:       return 'Meal';
      case sideProject: return 'Side Project';
      case devotion:   return 'Devotion';
      case errand:     return 'Errand';
      case custom:     return 'Custom';
    }
  }

  String get emoji {
    switch (this) {
      case study:      return '📚';
      case gym:        return '💪';
      case rest:       return '😴';
      case meal:       return '🍽️';
      case sideProject: return '💻';
      case devotion:   return '🙏';
      case errand:     return '🏃';
      case custom:     return '📌';
    }
  }

  /// Light background color value for this category
  int get colorValue {
    switch (this) {
      case study:      return 0xFF1565C0; // Blue
      case gym:        return 0xFF2E7D32; // Green
      case rest:       return 0xFF6A1B9A; // Purple
      case meal:       return 0xFFE65100; // Orange
      case sideProject: return 0xFF00838F; // Cyan
      case devotion:   return 0xFFC62828; // Red
      case errand:     return 0xFF558B2F; // Light green
      case custom:     return 0xFF4527A0; // Indigo
    }
  }

  static PersonalSlotCategory fromString(String value) {
    return PersonalSlotCategory.values.firstWhere(
      (e) => e.name == value,
      orElse: () => custom,
    );
  }
}
```

---

## STEP 2 — Recurrence Type Enum

Create `lib/features/timetable/domain/recurrence_type.dart`:

```dart
/// How a personal slot repeats.
enum RecurrenceType {
  /// Happens once on a specific date
  oneOff,

  /// Repeats every day
  daily,

  /// Repeats on specific days of the week (stored as List<int> in the model)
  weekly;

  String get label {
    switch (this) {
      case oneOff: return 'One-off';
      case daily:  return 'Every day';
      case weekly: return 'Weekly (specific days)';
    }
  }

  static RecurrenceType fromString(String value) {
    return RecurrenceType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => oneOff,
    );
  }
}
```

---

## STEP 3 — PersonalSlotModel Isar Schema

Create `lib/features/timetable/data/models/personal_slot_model.dart`:

```dart
import 'package:isar/isar.dart';

part 'personal_slot_model.g.dart';

/// A personal timetable slot — Layer 2 of the dual timetable system.
/// Stored once; the SlotExpander resolves recurring instances for display.
@collection
class PersonalSlotModel {
  Id id = Isar.autoIncrement;

  /// Category stored as string e.g. "study", "gym"
  late String categoryName;

  /// Custom label — used when categoryName == "custom", optional otherwise
  late String customLabel;

  /// Minutes from midnight
  late int startMinutes;
  late int endMinutes;

  /// Stored as string from RecurrenceType enum
  late String recurrenceTypeName;

  /// For one-off: the specific date (stored as ISO string "2024-11-04")
  /// For daily/weekly: null
  String? specificDate;

  /// For weekly recurrence: list of day indices (0=Mon … 5=Sat)
  /// Empty for one-off and daily
  late List<int> weeklyDays;

  late String semesterKey;

  DateTime createdAt = DateTime.now();

  PersonalSlotModel();

  /// Convenience getters
  int get durationMinutes => endMinutes - startMinutes;

  String get displayLabel {
    if (categoryName == 'custom' && customLabel.isNotEmpty) return customLabel;
    // Capitalise first letter
    return categoryName[0].toUpperCase() + categoryName.substring(1).replaceAll(
      RegExp(r'([A-Z])'), r' $1',
    );
  }

  static String _minutesToLabel(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final suffix = h < 12 ? 'AM' : 'PM';
    final hour = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    return '${hour.toString()}:${m.toString().padLeft(2, '0')} $suffix';
  }

  String get startTimeLabel => _minutesToLabel(startMinutes);
  String get endTimeLabel   => _minutesToLabel(endMinutes);
}
```

---

## STEP 4 — Run Codegen

```bash
dart run build_runner build --delete-conflicting-outputs
```

Confirm `personal_slot_model.g.dart` was generated before continuing.

---

## STEP 5 — Update Isar Provider

Update `lib/core/providers/isar_provider.dart` to register the new schema:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:campusiq/features/cwa/data/models/course_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [CourseModelSchema, TimetableSlotModelSchema, PersonalSlotModelSchema],
    directory: dir.path,
  );
});
```

---

## STEP 6 — Slot Expander (Pure Domain Logic)

Create `lib/features/timetable/domain/slot_expander.dart`:

```dart
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/domain/recurrence_type.dart';

/// Expands stored PersonalSlotModel records into concrete instances
/// for a given day. Keeps Isar clean — no duplicate rows for recurring slots.
class SlotExpander {
  /// Returns all personal slots that are active on [targetDate] with [dayIndex].
  /// [dayIndex] is 0=Mon … 5=Sat.
  static List<PersonalSlotModel> expandForDay({
    required List<PersonalSlotModel> stored,
    required DateTime targetDate,
    required int dayIndex,
  }) {
    final result = <PersonalSlotModel>[];
    final targetDateStr = _toDateStr(targetDate);

    for (final slot in stored) {
      final type = RecurrenceType.fromString(slot.recurrenceTypeName);
      switch (type) {
        case RecurrenceType.oneOff:
          if (slot.specificDate == targetDateStr) result.add(slot);
        case RecurrenceType.daily:
          result.add(slot);
        case RecurrenceType.weekly:
          if (slot.weeklyDays.contains(dayIndex)) result.add(slot);
      }
    }

    // Sort by start time
    result.sort((a, b) => a.startMinutes.compareTo(b.startMinutes));
    return result;
  }

  static String _toDateStr(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
```

---

## STEP 7 — Personal Slot Repository

Create `lib/features/timetable/data/repositories/personal_slot_repository.dart`:

```dart
import 'package:isar/isar.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';

class PersonalSlotRepository {
  final Isar _isar;
  PersonalSlotRepository(this._isar);

  /// Live stream of ALL personal slots for a semester.
  /// The provider layer runs SlotExpander on top of this.
  Stream<List<PersonalSlotModel>> watchAllSlots(String semesterKey) {
    return _isar.personalSlotModels
        .filter()
        .semesterKeyEqualTo(semesterKey)
        .watch(fireImmediately: true);
  }

  Future<void> addSlot(PersonalSlotModel slot) async {
    await _isar.writeTxn(() => _isar.personalSlotModels.put(slot));
  }

  Future<void> updateSlot(PersonalSlotModel slot) async {
    await _isar.writeTxn(() => _isar.personalSlotModels.put(slot));
  }

  Future<void> deleteSlot(Id id) async {
    await _isar.writeTxn(() => _isar.personalSlotModels.delete(id));
  }
}
```

---

## ⛳ CHECKPOINT 1

Verify all three:

- [ ] `lib/features/timetable/data/models/personal_slot_model.g.dart` exists
- [ ] `build_runner` exited with code 0
- [ ] `flutter analyze` shows 0 errors

**If any check fails, fix before continuing.**

```bash
git add .
git commit -m "feat(personal): PersonalSlotModel schema + SlotExpander + repository"
```

**Tell Claude Code:** "Checkpoint 1 passed. Ready for Session 2."

---

---

# SESSION 2 — Providers + Personal Slot Widgets

**Claude Code instruction:**
> "Read `_dev/PHASE3.md`. Checkpoint 1 is done. Execute Session 2 steps 8 through 14 only. After Step 14 run flutter analyze and confirm zero errors. Stop at Checkpoint 2 and report back."

---

## STEP 8 — Personal Slot Providers

Create `lib/features/timetable/presentation/providers/personal_slot_provider.dart`:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/data/repositories/personal_slot_repository.dart';
import 'package:campusiq/features/timetable/domain/slot_expander.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';

/// Repository provider
final personalSlotRepositoryProvider = Provider<PersonalSlotRepository?>((ref) {
  final isarAsync = ref.watch(isarProvider);
  return isarAsync.whenOrNull(data: (isar) => PersonalSlotRepository(isar));
});

/// Live stream of ALL stored personal slots for the semester
final allPersonalSlotsProvider = StreamProvider<List<PersonalSlotModel>>((ref) {
  final repo = ref.watch(personalSlotRepositoryProvider);
  final semester = ref.watch(activeSemesterProvider);
  if (repo == null) return const Stream.empty();
  return repo.watchAllSlots(semester);
});

/// Expanded personal slots for the active day — runs SlotExpander
final activeDayPersonalSlotsProvider = Provider<List<PersonalSlotModel>>((ref) {
  final allStored = ref.watch(allPersonalSlotsProvider).valueOrNull ?? [];
  final dayIndex  = ref.watch(activeDayProvider);

  // Derive the actual date for the active day this week
  final now = DateTime.now();
  // weekday: Mon=1 … Sun=7. dayIndex: Mon=0 … Sat=5
  final daysFromToday = dayIndex - (now.weekday - 1);
  final targetDate = now.add(Duration(days: daysFromToday));

  return SlotExpander.expandForDay(
    stored: allStored,
    targetDate: targetDate,
    dayIndex: dayIndex,
  );
});

/// Which timetable page is active: 0=Class, 1=Personal, 2=Both
final timetablePageProvider = StateProvider<int>((ref) => 2);
```

---

## STEP 9 — Personal Slot Card Widget

Create `lib/features/timetable/presentation/widgets/personal_slot_card.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/domain/personal_slot_category.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

/// Personal slot card rendered in the grid.
/// Lighter opacity than class slots — visually recedes behind them in dual view.
class PersonalSlotCard extends StatelessWidget {
  final PersonalSlotModel slot;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  /// When true (dual view), render at reduced opacity so class slots read first
  final bool isDimmed;

  const PersonalSlotCard({
    super.key,
    required this.slot,
    required this.onTap,
    required this.onLongPress,
    this.isDimmed = false,
  });

  @override
  Widget build(BuildContext context) {
    final category = PersonalSlotCategory.fromString(slot.categoryName);
    final color = Color(category.colorValue);
    final topOffset = (slot.startMinutes - TimetableConstants.gridStartMinutes) *
        TimetableConstants.pixelsPerMinute;
    final height = slot.durationMinutes * TimetableConstants.pixelsPerMinute;
    final isShort = height < 36;
    final opacity = isDimmed ? 0.45 : 1.0;

    return Positioned(
      top: topOffset,
      left: 2,
      right: 2,
      height: height,
      child: Opacity(
        opacity: opacity,
        child: GestureDetector(
          onTap: onTap,
          onLongPress: onLongPress,
          child: Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: color.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            child: isShort
                ? Text(
                    '${category.emoji} ${slot.displayLabel}',
                    style: TextStyle(
                      color: color,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${category.emoji} ${slot.displayLabel}',
                        style: TextStyle(
                          color: color,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        slot.startTimeLabel,
                        style: TextStyle(
                          color: color.withOpacity(0.7),
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
```

---

## STEP 10 — Add Personal Slot Bottom Sheet

Create `lib/features/timetable/presentation/widgets/add_personal_slot_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/domain/personal_slot_category.dart';
import 'package:campusiq/features/timetable/domain/recurrence_type.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';

class AddPersonalSlotSheet extends StatefulWidget {
  final int dayIndex;
  final String semesterKey;
  final PersonalSlotModel? existing;
  final int? prefillStartMinutes;
  final int? prefillEndMinutes;

  const AddPersonalSlotSheet({
    super.key,
    required this.dayIndex,
    required this.semesterKey,
    this.existing,
    this.prefillStartMinutes,
    this.prefillEndMinutes,
  });

  @override
  State<AddPersonalSlotSheet> createState() => _AddPersonalSlotSheetState();
}

class _AddPersonalSlotSheetState extends State<AddPersonalSlotSheet> {
  final _customLabelController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late PersonalSlotCategory _category;
  late RecurrenceType _recurrence;
  late int _startMinutes;
  late int _endMinutes;
  late List<int> _weeklyDays;
  DateTime? _specificDate;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _category    = PersonalSlotCategory.fromString(e.categoryName);
      _recurrence  = RecurrenceType.fromString(e.recurrenceTypeName);
      _startMinutes = e.startMinutes;
      _endMinutes   = e.endMinutes;
      _weeklyDays   = List.from(e.weeklyDays);
      _customLabelController.text = e.customLabel;
      if (e.specificDate != null) _specificDate = DateTime.tryParse(e.specificDate!);
    } else {
      _category     = PersonalSlotCategory.study;
      _recurrence   = RecurrenceType.oneOff;
      _startMinutes = widget.prefillStartMinutes ?? TimetableConstants.gridStartMinutes + 120;
      _endMinutes   = widget.prefillEndMinutes   ?? _startMinutes + 60;
      _weeklyDays   = [widget.dayIndex];
      _specificDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _customLabelController.dispose();
    super.dispose();
  }

  String _minutesToTime(int m) =>
      '${(m ~/ 60).toString().padLeft(2, '0')}:${(m % 60).toString().padLeft(2, '0')}';

  Future<void> _pickTime(bool isStart) async {
    final mins = isStart ? _startMinutes : _endMinutes;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: mins ~/ 60, minute: mins % 60),
    );
    if (picked == null) return;
    final total = picked.hour * 60 + picked.minute;
    setState(() {
      if (isStart) {
        _startMinutes = total;
        if (_endMinutes <= _startMinutes) _endMinutes = _startMinutes + 60;
      } else {
        _endMinutes = total;
      }
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _specificDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _specificDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_endMinutes <= _startMinutes) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time')),
      );
      return;
    }
    if (_recurrence == RecurrenceType.weekly && _weeklyDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one day')),
      );
      return;
    }

    final slot = widget.existing ?? PersonalSlotModel();
    slot.categoryName      = _category.name;
    slot.customLabel       = _customLabelController.text.trim();
    slot.startMinutes      = _startMinutes;
    slot.endMinutes        = _endMinutes;
    slot.recurrenceTypeName = _recurrence.name;
    slot.weeklyDays        = _recurrence == RecurrenceType.weekly ? _weeklyDays : [];
    slot.specificDate      = _recurrence == RecurrenceType.oneOff && _specificDate != null
        ? '${_specificDate!.year}-${_specificDate!.month.toString().padLeft(2,'0')}-${_specificDate!.day.toString().padLeft(2,'0')}'
        : null;
    slot.semesterKey = widget.semesterKey;

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
                widget.existing == null ? 'Add Personal Block' : 'Edit Personal Block',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),

              // Category chips
              const Text('Category', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: PersonalSlotCategory.values.map((cat) {
                  final isSelected = _category == cat;
                  final color = Color(cat.colorValue);
                  return GestureDetector(
                    onTap: () => setState(() => _category = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? color : Colors.grey.shade300,
                          width: isSelected ? 1.5 : 0.5,
                        ),
                      ),
                      child: Text(
                        '${cat.emoji} ${cat.label}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isSelected ? color : AppTheme.textSecondary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              // Custom label (only shown for custom category)
              if (_category == PersonalSlotCategory.custom) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _customLabelController,
                  decoration: const InputDecoration(labelText: 'Custom label'),
                  validator: (v) => (_category == PersonalSlotCategory.custom &&
                      (v == null || v.trim().isEmpty))
                      ? 'Enter a label'
                      : null,
                ),
              ],

              const SizedBox(height: 16),

              // Time pickers
              Row(
                children: [
                  Expanded(child: _TimeTile(label: 'Start', value: _minutesToTime(_startMinutes), onTap: () => _pickTime(true))),
                  const SizedBox(width: 12),
                  Expanded(child: _TimeTile(label: 'End', value: _minutesToTime(_endMinutes), onTap: () => _pickTime(false))),
                ],
              ),
              const SizedBox(height: 16),

              // Recurrence
              const Text('Repeat', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 8),
              ...RecurrenceType.values.map((type) => RadioListTile<RecurrenceType>(
                value: type,
                groupValue: _recurrence,
                title: Text(type.label, style: const TextStyle(fontSize: 13)),
                dense: true,
                activeColor: AppTheme.primary,
                contentPadding: EdgeInsets.zero,
                onChanged: (v) => setState(() => _recurrence = v!),
              )),

              // One-off date picker
              if (_recurrence == RecurrenceType.oneOff) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text(
                          _specificDate == null
                              ? 'Pick date'
                              : '${_specificDate!.day}/${_specificDate!.month}/${_specificDate!.year}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Weekly day picker
              if (_recurrence == RecurrenceType.weekly) ...[
                const SizedBox(height: 12),
                const Text('Days', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (i) {
                    final labels = ['M', 'T', 'W', 'T', 'F', 'S'];
                    final isSelected = _weeklyDays.contains(i);
                    return GestureDetector(
                      onTap: () => setState(() {
                        isSelected ? _weeklyDays.remove(i) : _weeklyDays.add(i);
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primary : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                            width: 0.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          labels[i],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],

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
                  child: Text(widget.existing == null ? 'Add Block' : 'Save Changes'),
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

## STEP 11 — Personal Slot Detail Sheet

Create `lib/features/timetable/presentation/widgets/personal_slot_detail_sheet.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/domain/personal_slot_category.dart';
import 'package:campusiq/features/timetable/domain/recurrence_type.dart';

class PersonalSlotDetailSheet extends StatelessWidget {
  final PersonalSlotModel slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const PersonalSlotDetailSheet({
    super.key,
    required this.slot,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final category = PersonalSlotCategory.fromString(slot.categoryName);
    final color = Color(category.colorValue);
    final recurrence = RecurrenceType.fromString(slot.recurrenceTypeName);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Text(
                slot.displayLabel,
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
                  recurrence.label,
                  style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Row(icon: Icons.access_time, label: '${slot.startTimeLabel} – ${slot.endTimeLabel}'),
          if (recurrence == RecurrenceType.oneOff && slot.specificDate != null) ...[
            const SizedBox(height: 8),
            _Row(icon: Icons.calendar_today_outlined, label: slot.specificDate!),
          ],
          if (recurrence == RecurrenceType.weekly && slot.weeklyDays.isNotEmpty) ...[
            const SizedBox(height: 8),
            _Row(
              icon: Icons.repeat,
              label: slot.weeklyDays
                  .map((d) => ['Mon','Tue','Wed','Thu','Fri','Sat'][d])
                  .join(', '),
            ),
          ],
          if (recurrence == RecurrenceType.daily) ...[
            const SizedBox(height: 8),
            const _Row(icon: Icons.repeat, label: 'Every day'),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () { Navigator.pop(context); onDelete(); },
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
                  onPressed: () { Navigator.pop(context); onEdit(); },
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

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Row({required this.icon, required this.label});

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

## STEP 12 — Dual Layer Grid Widget

Create `lib/features/timetable/presentation/widgets/dual_layer_grid.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/widgets/timetable_slot_card.dart';
import 'package:campusiq/features/timetable/presentation/widgets/personal_slot_card.dart';
import 'package:campusiq/features/timetable/presentation/widgets/free_block_indicator.dart';

/// Which layers to show.
enum GridLayerMode { classOnly, personalOnly, both }

/// Renders the combined timetable grid with configurable layer visibility.
class DualLayerGrid extends StatelessWidget {
  final List<TimetableSlotModel> classSlots;
  final List<PersonalSlotModel> personalSlots;
  final List<FreeBlock> freeBlocks;
  final GridLayerMode mode;
  final void Function(TimetableSlotModel) onClassSlotTap;
  final void Function(PersonalSlotModel) onPersonalSlotTap;
  final void Function(FreeBlock) onFreeBlockTap;
  final VoidCallback onEmptyTap;

  const DualLayerGrid({
    super.key,
    required this.classSlots,
    required this.personalSlots,
    required this.freeBlocks,
    required this.mode,
    required this.onClassSlotTap,
    required this.onPersonalSlotTap,
    required this.onFreeBlockTap,
    required this.onEmptyTap,
  });

  @override
  Widget build(BuildContext context) {
    final showClass    = mode == GridLayerMode.classOnly || mode == GridLayerMode.both;
    final showPersonal = mode == GridLayerMode.personalOnly || mode == GridLayerMode.both;
    final isDimmed     = mode == GridLayerMode.both;

    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TimeLabels(),
          Expanded(
            child: GestureDetector(
              onTap: onEmptyTap,
              child: SizedBox(
                height: TimetableConstants.totalGridHeight,
                child: Stack(
                  children: [
                    _HourLines(),

                    // Free blocks (only in class view or both)
                    if (showClass)
                      ...freeBlocks.map((b) => FreeBlockIndicator(
                            block: b,
                            onTap: () => onFreeBlockTap(b),
                          )),

                    // Personal slots — rendered first (below class slots)
                    if (showPersonal)
                      ...personalSlots.map((s) => PersonalSlotCard(
                            slot: s,
                            onTap: () => onPersonalSlotTap(s),
                            onLongPress: () => onPersonalSlotTap(s),
                            isDimmed: isDimmed,
                          )),

                    // Class slots — rendered on top
                    if (showClass)
                      ...classSlots.map((s) => TimetableSlotCard(
                            slot: s,
                            columnWidth: double.infinity,
                            onTap: () => onClassSlotTap(s),
                            onLongPress: () => onClassSlotTap(s),
                          )),

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

// ── Private helpers (copied from timetable_grid.dart for self-containment) ──

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
          final top = (hour - TimetableConstants.gridStartHour) * TimetableConstants.hourRowHeight;
          final label = hour == 0 ? '12 AM' : hour < 12 ? '$hour AM' : hour == 12 ? '12 PM' : '${hour - 12} PM';
          return Positioned(
            top: top - 6, left: 0, right: 4,
            child: Text(label, textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
          );
        }).toList(),
      ),
    );
  }
}

class _HourLines extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final hours = TimetableConstants.gridEndHour - TimetableConstants.gridStartHour;
    return SizedBox(
      height: TimetableConstants.totalGridHeight,
      child: Stack(
        children: List.generate(hours, (i) {
          final top = i * TimetableConstants.hourRowHeight;
          return Positioned(
            top: top, left: 0, right: 0,
            child: Divider(height: 0.5, color: Colors.grey.shade200),
          );
        }),
      ),
    );
  }
}

class _CurrentTimeIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final nowMins = now.hour * 60 + now.minute;
    if (nowMins < TimetableConstants.gridStartMinutes || nowMins > TimetableConstants.gridEndMinutes) {
      return const SizedBox.shrink();
    }
    final top = (nowMins - TimetableConstants.gridStartMinutes) * TimetableConstants.pixelsPerMinute;
    return Positioned(
      top: top, left: 0, right: 0,
      child: Row(children: [
        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
        Expanded(child: Container(height: 1, color: Colors.red.withOpacity(0.6))),
      ]),
    );
  }
}
```

---

## STEP 13 — Page Indicator Widget

Create `lib/features/timetable/presentation/widgets/timetable_page_indicator.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:campusiq/core/theme/app_theme.dart';

/// Three-dot page indicator showing Class / Both / Personal view.
class TimetablePageIndicator extends StatelessWidget {
  final int currentPage;

  const TimetablePageIndicator({super.key, required this.currentPage});

  static const _labels = ['Class', 'Both', 'Personal'];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_labels.length, (i) {
        final isActive = i == currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _labels[i],
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? AppTheme.primary : AppTheme.textSecondary,
            ),
          ),
        );
      }),
    );
  }
}
```

---

## STEP 14 — flutter analyze

```bash
flutter analyze
```

Must show 0 errors before continuing.

---

## ⛳ CHECKPOINT 2

Verify both:

- [ ] `flutter analyze` shows 0 errors
- [ ] No import errors in any file created in Steps 8–13

**If any check fails, fix before continuing.**

```bash
git add .
git commit -m "feat(personal): providers, personal slot widgets, dual layer grid, page indicator"
```

**Tell Claude Code:** "Checkpoint 2 passed. Ready for Session 3."

---

---

# SESSION 3 — Timetable Screen Upgrade + Full Integration

**Claude Code instruction:**
> "Read `_dev/PHASE3.md`. Checkpoints 1 and 2 are done. Execute Session 3 steps 15 through 20. Run the app and confirm all test items pass. Then stop and report back."

---

## STEP 15 — Replace Timetable Screen with Dual-Layer PageView Version

Replace the full contents of `lib/features/timetable/presentation/screens/timetable_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/theme/app_theme.dart';
import 'package:campusiq/features/cwa/presentation/providers/cwa_provider.dart';
import 'package:campusiq/features/timetable/data/models/personal_slot_model.dart';
import 'package:campusiq/features/timetable/data/models/timetable_slot_model.dart';
import 'package:campusiq/features/timetable/domain/free_time_detector.dart';
import 'package:campusiq/features/timetable/domain/timetable_constants.dart';
import 'package:campusiq/features/timetable/presentation/providers/personal_slot_provider.dart';
import 'package:campusiq/features/timetable/presentation/providers/timetable_provider.dart';
import 'package:campusiq/features/timetable/presentation/widgets/day_selector.dart';
import 'package:campusiq/features/timetable/presentation/widgets/dual_layer_grid.dart';
import 'package:campusiq/features/timetable/presentation/widgets/add_slot_sheet.dart';
import 'package:campusiq/features/timetable/presentation/widgets/add_personal_slot_sheet.dart';
import 'package:campusiq/features/timetable/presentation/widgets/slot_detail_sheet.dart';
import 'package:campusiq/features/timetable/presentation/widgets/personal_slot_detail_sheet.dart';
import 'package:campusiq/features/timetable/presentation/widgets/timetable_page_indicator.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  const TimetableScreen({super.key});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  late final PageController _pageController;

  /// Page order: 0=Class Only, 1=Both, 2=Personal Only
  static const _modeForPage = [
    GridLayerMode.classOnly,
    GridLayerMode.both,
    GridLayerMode.personalOnly,
  ];

  @override
  void initState() {
    super.initState();
    // Start on "Both" (page 1)
    _pageController = PageController(initialPage: 1);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timetablePageProvider.notifier).state = 1;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ── Class slot actions ──────────────────────────────────────────────────

  Future<void> _openAddClassSheet({TimetableSlotModel? existing, int? prefillStart, int? prefillEnd}) async {
    final day = ref.read(activeDayProvider);
    final semester = ref.read(activeSemesterProvider);
    final slotCount = await ref.read(slotCountProvider.future);
    final colorValue = TimetableConstants.colorForIndex(slotCount);

    if (!mounted) return;

    final result = await showModalBottomSheet<TimetableSlotModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => AddSlotSheet(
        dayIndex: day,
        semesterKey: semester,
        colorValue: existing?.colorValue ?? colorValue,
        existing: existing,
        prefillStartMinutes: prefillStart,
        prefillEndMinutes: prefillEnd,
      ),
    );

    if (result == null || !mounted) return;
    final repo = ref.read(timetableRepositoryProvider);
    existing == null ? await repo?.addSlot(result) : await repo?.updateSlot(result);
  }

  void _showClassDetail(TimetableSlotModel slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SlotDetailSheet(
        slot: slot,
        onEdit: () => _openAddClassSheet(existing: slot),
        onDelete: () => ref.read(timetableRepositoryProvider)?.deleteSlot(slot.id),
      ),
    );
  }

  // ── Personal slot actions ───────────────────────────────────────────────

  Future<void> _openAddPersonalSheet({PersonalSlotModel? existing, int? prefillStart, int? prefillEnd}) async {
    final day = ref.read(activeDayProvider);
    final semester = ref.read(activeSemesterProvider);

    final result = await showModalBottomSheet<PersonalSlotModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => AddPersonalSlotSheet(
        dayIndex: day,
        semesterKey: semester,
        existing: existing,
        prefillStartMinutes: prefillStart,
        prefillEndMinutes: prefillEnd,
      ),
    );

    if (result == null || !mounted) return;
    final repo = ref.read(personalSlotRepositoryProvider);
    existing == null ? await repo?.addSlot(result) : await repo?.updateSlot(result);
  }

  void _showPersonalDetail(PersonalSlotModel slot) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => PersonalSlotDetailSheet(
        slot: slot,
        onEdit: () => _openAddPersonalSheet(existing: slot),
        onDelete: () => ref.read(personalSlotRepositoryProvider)?.deleteSlot(slot.id),
      ),
    );
  }

  void _onFreeBlockTap(FreeBlock block) {
    // In Both/Class view → add class. In Personal view → add personal.
    final page = ref.read(timetablePageProvider);
    if (page == 2) {
      _openAddPersonalSheet(prefillStart: block.startMinutes, prefillEnd: block.endMinutes);
    } else {
      _openAddClassSheet(prefillStart: block.startMinutes, prefillEnd: block.endMinutes);
    }
  }

  void _onEmptyTap() {
    final page = ref.read(timetablePageProvider);
    page == 2 ? _openAddPersonalSheet() : _openAddClassSheet();
  }

  void _onFabTap() {
    final page = ref.read(timetablePageProvider);
    page == 2 ? _openAddPersonalSheet() : _openAddClassSheet();
  }

  @override
  Widget build(BuildContext context) {
    final classSlots    = ref.watch(activeDaySlotsProvider);
    final personalSlots = ref.watch(activeDayPersonalSlotsProvider);
    final freeBlocks    = ref.watch(activeDayFreeBlocksProvider);
    final activeDay     = ref.watch(activeDayProvider);
    final currentPage   = ref.watch(timetablePageProvider);

    final mode = _modeForPage[currentPage];
    final fabLabel = currentPage == 2 ? 'Add Block' : 'Add Class';

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Timetable', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _onFabTap,
          ),
        ],
      ),
      body: Column(
        children: [
          const DaySelector(),

          // Page indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: TimetablePageIndicator(currentPage: currentPage),
          ),

          // Day label + free block count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                Text(
                  TimetableConstants.dayFullLabels[activeDay],
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
                const Spacer(),
                if (freeBlocks.isNotEmpty && mode != GridLayerMode.personalOnly)
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

          // Swiped PageView — Class / Both / Personal
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: 3,
              onPageChanged: (page) =>
                  ref.read(timetablePageProvider.notifier).state = page,
              itemBuilder: (context, page) {
                final pageMode = _modeForPage[page];
                final isEmpty = (pageMode == GridLayerMode.classOnly && classSlots.isEmpty) ||
                    (pageMode == GridLayerMode.personalOnly && personalSlots.isEmpty) ||
                    (pageMode == GridLayerMode.both && classSlots.isEmpty && personalSlots.isEmpty);

                if (isEmpty) {
                  return _EmptyPage(
                    mode: pageMode,
                    onAdd: _onFabTap,
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DualLayerGrid(
                    classSlots: classSlots,
                    personalSlots: personalSlots,
                    freeBlocks: freeBlocks,
                    mode: pageMode,
                    onClassSlotTap: _showClassDetail,
                    onPersonalSlotTap: _showPersonalDetail,
                    onFreeBlockTap: _onFreeBlockTap,
                    onEmptyTap: _onEmptyTap,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabTap,
        icon: const Icon(Icons.add),
        label: Text(fabLabel),
      ),
    );
  }
}

class _EmptyPage extends StatelessWidget {
  final GridLayerMode mode;
  final VoidCallback onAdd;

  const _EmptyPage({required this.mode, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final message = switch (mode) {
      GridLayerMode.classOnly    => 'No classes today',
      GridLayerMode.personalOnly => 'No personal blocks today',
      GridLayerMode.both         => 'Nothing scheduled today',
    };
    final hint = switch (mode) {
      GridLayerMode.classOnly    => 'Tap + to add a class',
      GridLayerMode.personalOnly => 'Tap + to add a personal block',
      GridLayerMode.both         => 'Tap + to add a class or block',
    };

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.calendar_today_outlined, size: 56, color: AppTheme.textSecondary),
          const SizedBox(height: 12),
          Text(message, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15)),
          const SizedBox(height: 4),
          Text(hint, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          const SizedBox(height: 16),
          TextButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Add')),
        ],
      ),
    );
  }
}
```

---

## STEP 16 — Update CLAUDE.md

```
## Current phase
Phase 3 complete — Phase 4 next (Study Session Tracking)

## Timetable views
Swipe left/right: Class Only ↔ Both ↔ Personal Only
Page 0 = classOnly, Page 1 = both (default), Page 2 = personalOnly
```

---

## STEP 17 — Final Build Check

```bash
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter run
```

---

## STEP 18 — Remove Old timetable_grid.dart (optional cleanup)

The `DualLayerGrid` in Step 12 now handles all grid rendering.
`timetable_grid.dart` from Phase 2 is no longer used by any screen.

Ask Claude Code to check if anything still imports it:

```bash
grep -r "timetable_grid.dart\|TimetableGrid" lib/
```

If nothing imports `TimetableGrid` except the old file itself, delete it:

```bash
rm lib/features/timetable/presentation/widgets/timetable_grid.dart
flutter analyze   # confirm still 0 errors
```

---

## STEP 19 — Test Checklist

Test every item on your device/emulator:

**Layer switching**
- [ ] Timetable screen opens on "Both" view (middle page)
- [ ] Swiping left shows "Class Only" — page indicator updates
- [ ] Swiping right shows "Personal Only" — page indicator updates
- [ ] Page indicator labels (Class / Both / Personal) are visible below day selector

**Class slots (Phase 2 regression)**
- [ ] Class slots still render correctly in Class Only and Both views
- [ ] Class slots are NOT visible in Personal Only view
- [ ] Tapping a class slot opens the class detail sheet

**Personal slots**
- [ ] FAB label changes to "Add Block" when on Personal Only page
- [ ] Adding a personal slot with category Study renders on grid with 📚 emoji
- [ ] Adding a one-off slot on a specific date — only appears on that date
- [ ] Adding a daily slot — appears on every day when you swipe through days
- [ ] Adding a weekly slot (e.g. Mon + Wed) — appears only on those days
- [ ] Tapping a personal slot opens the personal detail sheet
- [ ] Edit and delete work correctly
- [ ] Custom category shows custom label

**Dual view**
- [ ] In Both view — personal slots render at lower opacity beneath class slots
- [ ] Class slots are visually dominant over personal slots in Both view
- [ ] Free blocks (green) visible in Both and Class Only views
- [ ] Tapping free block in Personal Only page → opens Add Personal Block sheet
- [ ] Tapping free block in Both/Class page → opens Add Class sheet

**Persistence**
- [ ] Hot restart preserves all class and personal slots
- [ ] Recurring slots still expand correctly after restart

---

## ⛳ CHECKPOINT 3 — Phase 3 Complete

All test items above must pass.

```bash
git add .
git commit -m "feat: Phase 3 complete — Personal Timetable + Dual Layer View"
git push origin main
```

---

## Phase 3 Summary

| What was built | Location |
|---|---|
| PersonalSlotCategory enum | `features/timetable/domain/` |
| RecurrenceType enum | `features/timetable/domain/` |
| PersonalSlotModel Isar schema | `features/timetable/data/models/` |
| SlotExpander (recurring → concrete) | `features/timetable/domain/` |
| Personal slot repository | `features/timetable/data/repositories/` |
| Personal slot Riverpod providers | `features/timetable/presentation/providers/` |
| PersonalSlotCard (dimmed in dual view) | `features/timetable/presentation/widgets/` |
| AddPersonalSlotSheet (full recurring UI) | `features/timetable/presentation/widgets/` |
| PersonalSlotDetailSheet | `features/timetable/presentation/widgets/` |
| DualLayerGrid (replaces TimetableGrid) | `features/timetable/presentation/widgets/` |
| TimetablePageIndicator | `features/timetable/presentation/widgets/` |
| TimetableScreen (PageView, 3 swipe pages) | `features/timetable/presentation/screens/` |

**Phase 4 next:** Study Session Tracking — planned vs actual effort visibility

---

*CampusIQ · PHASE3.md · WesleyConsults Dev · April 2026*
