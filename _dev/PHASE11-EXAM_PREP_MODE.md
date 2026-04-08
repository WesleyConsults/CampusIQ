# PHASE 11 — Exam Prep Mode (Exam Mode Activation)

## Context

Phases 6-10 are complete. Now add the **Exam Mode transformation** — a high-impact visual event that signals the student is entering an intensive study period.

---

## The Vision

**Before Exam Mode:** "Exam? Let me check the plan..."  
**After Exam Mode:** 🔥 **EXAM MODE ACTIVATED** — app transforms, Plan tab renamed, intensive scheduling kicks in.

Two triggers:
1. **Manual:** "Enter Exam Mode" button on Plan screen (big, prominent)
2. **Automatic:** 14 days before the first exam date (notification + auto-activate)

Visual cue: Animated transition with color shift, icon, and tab rename.

---

## Step 1 — Extend `CourseModel`

File: `lib/features/cwa/data/models/course_model.dart`

Add field to `CourseModel`:
```dart
@collection
class CourseModel {
  Id id = Isar.autoIncrement;
  
  String courseCode;
  String courseName;
  int creditHours;
  double expectedScore;
  
  // NEW:
  DateTime? examDate;  // nullable — set when exam is scheduled
}
```

Run `build_runner` after adding this field.

---

## Step 2 — Create `ExamModel`

File: `lib/features/plan/data/models/exam_model.dart`

```dart
@collection
class ExamModel {
  Id id = Isar.autoIncrement;
  
  String courseCode;
  String courseName;
  DateTime examDate;       // e.g. 2026-05-14
  int examStartHour;       // 9 (9 AM)
  int creditHours;
  
  String? examHall;        // nullable
  String? topicsJson;      // JSON array of topics (see Step 3)
  
  bool isComplete;         // marked true after exam day
  DateTime createdAt;
}
```

---

## Step 3 — Create `ExamModels` & Domain Logic

File: `lib/features/plan/domain/exam_prep_planner.dart`

```dart
// Value object for topics
class ExamTopic {
  final String name;
  final String priority;  // 'high' | 'medium' | 'low'
  
  ExamTopic({required this.name, required this.priority});
}

// Main planner class
class ExamPrepPlanner {
  ExamPrepPlanner({
    required List<ExamModel> upcomingExams,
    required List<CourseModel> courses,
    required List<StudySessionModel> recentSessions,
    required int examWeekStudyGoalMinutes,
    required DateTime currentDate,
  });

  /// Generate spaced-repetition study tasks for the next 14 days
  List<PlanTask> generateExamWeekPlan(DateTime date) {
    // 1. Sort exams by date
    final sortedExams = upcomingExams..sort((a, b) => a.examDate.compareTo(b.examDate));
    
    // 2. For each exam:
    //    - 4+ credits → 3 study sessions (spaced 3–4 days apart)
    //    - 3 credits → 2 sessions
    //    - <3 credits → 1 session
    
    // 3. Assign topics to sessions (hardest topics first)
    
    // 4. Allocate to free time blocks (assume exam week = no classes)
    
    // 5. Prefer 90–120 min blocks (not 30 min fragments)
    
    // 6. Return List<PlanTask>
  }

  bool _isExamWeek(DateTime date) {
    // Returns true if date is within 14 days of any exam
  }

  List<PlanTask> _generateNormalPlan(DateTime date) {
    // Fallback to normal PlanGenerator logic
  }
}
```

---

## Step 4 — Create `ExamModeProvider`

File: `lib/features/plan/presentation/providers/exam_mode_provider.dart`

```dart
@riverpod
class ExamModeActive extends _$ExamModeActive {
  @override
  Future<bool> build() async {
    final prefs = await ref.watch(userPrefsProvider.future);
    return prefs.data?['exam_mode_active'] ?? false;
  }

  Future<void> activateExamMode({
    required DateTime examStart,
    required DateTime examEnd,
    required int dailyGoalMinutes,  // e.g. 480 (8h)
  }) async {
    final repo = ref.read(userPrefsRepository);
    await repo.updateExamModeSettings(
      isActive: true,
      examStart: examStart,
      examEnd: examEnd,
      dailyGoal: dailyGoalMinutes,
    );
    state = const AsyncValue.data(true);
  }

  Future<void> deactivateExamMode() async {
    final repo = ref.read(userPrefsRepository);
    await repo.updateExamModeSettings(isActive: false);
    state = const AsyncValue.data(false);
  }
}

// Check if auto-activate needed (called on app open)
@riverpod
Future<bool> shouldAutoActivateExamMode(ref) async {
  final exams = await ref.watch(examsProvider.future);
  if (exams.isEmpty) return false;
  
  final firstExam = exams.first;
  final daysTilExam = firstExam.examDate.difference(DateTime.now()).inDays;
  
  return daysTilExam <= 14 && daysTilExam > 0;
}
```

---

## Step 5 — UI Transformation: `ExamModeActivationSheet`

File: `lib/features/plan/presentation/widgets/exam_mode_activation_sheet.dart`

When user taps **"Enter Exam Mode"** button (or auto-triggered):

```
┌─────────────────────────────────────┐
│                                     │
│       🔥 EXAM MODE INCOMING          │
│                                     │
│    You have 3 exams in 14 days      │
│                                     │
│    First exam: Physics (May 14)     │
│                                     │
│    ┌───────────────────────────┐   │
│    │ Daily study goal:         │   │
│    │ ○ 2h (normal)             │   │
│    │ ◉ 6h (intensive) ← default│   │
│    │ ○ 8h (max)                │   │
│    └───────────────────────────┘   │
│                                     │
│       [ACTIVATE EXAM MODE]           │
│                                     │
│         [Maybe later]               │
│                                     │
└─────────────────────────────────────┘
```

After tapping **ACTIVATE**:
- Animated transition (0.8s):
  - Background shifts to darker/warmer tone (Material 3 secondary color)
  - Shield 🛡️ or Flame 🔥 icon appears and scales in
  - Entire screen fades to "Exam Mode"
- Plan tab renamed: "Plan" → "Exam Mode"
- Banner appears on Plan screen (stays until exam period ends)

---

## Step 6 — Visual: Exam Mode Banner & Tab

### Plan Tab Transformation

**Normal:**
```
    CWA | Timetable | Plan | Sessions | Streak
                      ↓
```

**Exam Mode:**
```
    CWA | Timetable | 🔥 Exam Mode | Sessions | Streak
                            ↓
                    (glowing border effect)
```

### Exam Mode Screen (modified Plan screen)

```
┌─────────────────────────────────────┐
│ 🔥 EXAM MODE — Physics Next (8 days)│
├─────────────────────────────────────┤
│ Daily Goal: 6h / 360 min available  │
│ ███████░░ 70% allocated             │
├─────────────────────────────────────┤
│                                     │
│ CRITICAL (Next 3 days)              │
│ ├─ Physics — Circuits (past papers) │
│ │  ⏰ Today 2:00 PM (120 min)       │
│ │  [✓ Mark done] [Reschedule]      │
│ │                                   │
│ ├─ Physics — Oscillations (notes)   │
│ │  ⏰ Tomorrow 10:00 AM (90 min)    │
│ │                                   │
│ UPCOMING (Days 4–8)                 │
│ ├─ Chemistry — Bonding (May 8)      │
│ │  ⏰ 3:00 PM (120 min)             │
│ │                                   │
│ ├─ Math — Calculus Review (May 10)  │
│ │  ⏰ 10:00 AM (90 min)             │
│ │                                   │
├─────────────────────────────────────┤
│ [Exit Exam Mode] (only shows before │
│                   first exam)       │
│                                     │
│ Exam Progress:                      │
│ Physics: ██░ 2/3 prep sessions done │
│ Chemistry: █░ 1/2 done              │
│ Math: ░░░ 0/2 done                  │
│                                     │
└─────────────────────────────────────┘
```

---

## Step 7 — Activation Flow

### Manual Activation

**On Plan Screen:**

```dart
FloatingActionButton(
  heroTag: 'exam_mode',
  child: Icon(Icons.whatshot),  // Flame icon
  onPressed: () {
    // Check if exams exist
    final exams = ref.watch(examsProvider);
    if (exams.isEmpty) {
      ScaffoldMessenger.show("Add exams first");
      return;
    }
    
    // Show activation sheet
    showModalBottomSheet(
      context: context,
      builder: (_) => ExamModeActivationSheet(),
    );
  },
)
```

### Automatic Activation

**In `app.dart` lifecycle:**

```dart
@override
void didChangeAppLifecycleState(AppLifecycleState state) {
  if (state == AppLifecycleState.resumed) {
    // Check if exam mode should auto-activate
    ref.read(shouldAutoActivateExamModeProvider).then((shouldActivate) {
      if (shouldActivate && !examModeCurrentlyActive) {
        // Show notification
        NotificationService.instance.showNotification(
          title: '🔥 Exam Mode Incoming',
          body: 'Your first exam is in 14 days. Ready to prep?',
        );
        
        // After 1 second, show sheet
        Future.delayed(Duration(seconds: 1), () {
          showModalBottomSheet(
            context: context,
            builder: (_) => ExamModeActivationSheet(isAutoTriggered: true),
          );
        });
      }
    });
  }
}
```

---

## Step 8 — Animation Sequence (flutter_animate)

File: `lib/features/plan/presentation/widgets/exam_mode_transition.dart`

When activated, show overlay:

```dart
.animate()
  .fade(duration: 300.ms)              // Fade in overlay
  .then()
  .scale(begin: 0.5, end: 1.0, duration: 400.ms)  // Flame icon scales
  .then()
  .custom(
    duration: 500.ms,
    builder: (context, value, child) {
      // Background color lerps from default to exam mode color
      return Container(
        color: Color.lerp(
          Colors.white,
          Colors.deepOrange[700],
          value,
        ),
        child: child,
      );
    },
  );
```

---

## Step 9 — Exam Manager UI

File: `lib/features/plan/presentation/widgets/exam_manager_sheet.dart`

Accessible from Exam Mode or from a gear icon:

```
┌─────────────────────────────────────┐
│ Manage Exams                        │
├─────────────────────────────────────┤
│ [+ Add Exam]                        │
│                                     │
│ Physics 101 — May 14 @ 9 AM         │
│ 4 credits | Great Hall              │
│ ├─ Circuits & Oscillations (high)   │
│ ├─ Thermodynamics (medium)          │
│ └─ Waves (low)                      │
│ [Edit] [Delete]                     │
│                                     │
│ Chemistry 151 — May 15 @ 2 PM       │
│ 4 credits | Lab Building            │
│ [Edit] [Delete]                     │
│                                     │
│ Math 151 — May 20 @ 10 AM           │
│ 3 credits | Lecture Theatre         │
│ [Edit] [Delete]                     │
│                                     │
└─────────────────────────────────────┘
```

When adding exam:
1. Select course (from CourseModel list)
2. Pick exam date + time
3. Enter exam hall
4. (Optional) Break down into topics
5. Save → Isar persists, auto-triggers 14-day countdown

---

## Step 10 — Integration Points

### Modified `generatePlanProvider`

```dart
@riverpod
Future<void> generatePlanProvider(ref, DateTime date) async {
  final examModeActive = await ref.watch(examModeActiveProvider.future);
  final exams = await ref.watch(examsProvider.future);
  
  List<PlanTask> tasks;
  
  if (examModeActive && _isInExamWindow(date, exams)) {
    // Use exam planner
    final planner = ExamPrepPlanner(...);
    tasks = planner.generateExamWeekPlan(date);
  } else {
    // Use normal planner
    final planner = PlanGenerator(...);
    tasks = planner.generate(date);
  }
  
  await repo.saveTasks(...);
}
```

### Modified `appRouter`

Rename Plan tab dynamically:

```dart
examModeActive 
  ? "🔥 Exam Mode" 
  : "Plan"
```

---

## Step 11 — Run & Verify

```bash
flutter analyze
flutter run
```

Checklist:
- ✅ Add exam opens Exam Manager
- ✅ First exam date triggers auto-activation (manually set system date to test)
- ✅ Manual "Enter Exam Mode" button works
- ✅ Activation sheet shows correct exam count
- ✅ Animated transition plays smoothly (background, icon, tab rename)
- ✅ Exam Mode tab shows task list (spaced repetition)
- ✅ Exam progress cards update as tasks are marked done
- ✅ Exiting exam mode (after last exam) reverts UI

---

## Step 12 — Commit

```
feat: Phase 11 complete — Exam Mode with animated activation and spaced-repetition scheduling
```

---

## Summary

**Exam Mode is not a toggle — it's an event.**

| Aspect | Detail |
|---|---|
| **Triggers** | Manual button + Auto (14 days before first exam) |
| **Visual** | Animated transition: background shift, flame icon, tab rename to "Exam Mode" |
| **Planning** | Spaced-repetition generator (2–3 study sessions per course, intelligently spaced) |
| **Duration** | Exam period start → last exam date |
| **Intensity** | Bumped daily goal (e.g. 2h → 6h) |
| **Exam Mgmt** | Add exams with topics, dates, halls; Isar persists |
| **Progress** | Visual cards show per-exam prep completion |

**Feels like:** A gear shift into high intensity. Students see "Exam Mode activated" and know exams are coming. The app transforms to match the mood.
