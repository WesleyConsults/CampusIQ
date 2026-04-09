# CampusIQ — Phase 14: Exam Prep Generator + Smart Notifications

---

## Session Overview

**Phase:** 14 of 16  
**Sessions required:** 2  
**Depends on:** Phase 11 (AI infrastructure), Phase 13 (weekly review pattern for notification scheduling)  
**Unlocks:** Phase 15

**What this phase delivers:**
- Exam prep question generator with 3 formats: MCQ, Short Answer, Flash Cards
- Smart local notifications: streak-at-risk, study reminder, weekly review ready, milestone unlocked
- AI-personalized streak notification messages
- Background task scheduling via `workmanager`
- New screen: `/ai/exam-prep`
- No new Isar schemas needed (questions are ephemeral; notifications use existing data)

**What this phase does NOT touch:**
- CWA, timetable, sessions, or streak screens
- Payment or subscription management
- Onboarding

---

## Project Context

Read `CLAUDE.md` before starting. Key facts:
- `flutter_animate` is already in the project — use it for the flashcard flip animation
- `StreakCalculator` is in `lib/features/streak/domain/streak_calculator.dart`
- `StudySessionModel` records are in Isar — read today's sessions to check if streak is at risk
- `TimetableRepository` provides free blocks (via `FreeTimeDetector`) for reminder scheduling
- `isPremiumProvider` and `AiUsageRepository` from Phase 11 handle quota
- Exam prep uses `feature: 'chat'` quota (shared pool, 1 generation = 1 use for free users)
- Run `dart run build_runner build --delete-conflicting-outputs` if any new Riverpod annotations added

---

## Session 1 — Exam Prep Question Generator

### User Experience

1. User taps "AI Coach" tab → sees a new "Exam Prep" entry card in the AI tab (below the chat input area or as a prominent feature card before the chat)
2. Tapping navigates to `/ai/exam-prep`
3. On the exam prep screen:
   - Step 1: Course picker — chips for each CWA course, tap to select one
   - Step 2: Question type selector — three buttons: "Multiple Choice", "Short Answer", "Flash Cards"
   - Step 3: Optional topic field — `TextField` with hint "e.g. Thevenin's Theorem, or leave blank for general"
   - "Generate 5 Questions" primary button
4. Loading state while AI processes
5. Questions render below the controls:
   - **MCQ:** question text → 4 options (A–D) as tappable tiles → tap to reveal if correct + explanation
   - **Short Answer:** question text → "Show Answer" button → answer reveals with animation
   - **Flash Cards:** front side (question) shown → tap card → flip animation → back side (answer)
6. "Generate 5 more" button at the bottom — appends 5 new questions to the existing list
7. Free users: 1 generation per day (using `feature: 'chat'` shared pool). Show gate after limit hit.
8. Premium users: unlimited generations

### What the AI Receives

New method in `ContextBuilder`: `Future<String> buildExamPrepPrompt(ExamPrepRequest request)`

```dart
class ExamPrepRequest {
  final String courseCode;
  final String courseName;
  final String questionType; // 'mcq' | 'short' | 'flash'
  final String? topic;       // optional
  final int count;           // always 5
}
```

Prompt:
```
Generate [count] [questionType] exam practice questions for a university student.
Course: [courseName] ([courseCode])
[If topic provided: "Topic focus: [topic]"]
[If no topic: "Cover general/important concepts in this course"]

Return ONLY a JSON array. No text before or after.

For MCQ format, each item:
{"type": "mcq", "question": "...", "options": ["A. ...", "B. ...", "C. ...", "D. ..."], "answer": "A", "explanation": "..."}

For short answer format, each item:
{"type": "short", "question": "...", "answer": "..."}

For flash card format, each item:
{"type": "flash", "front": "...", "back": "..."}

Questions should be exam-level difficulty, specific, and test real understanding (not trivial facts).
```

`maxTokens: 1500` — questions can be lengthy.

---

### Data Models (Value Objects — No Isar)

Questions are ephemeral — held in provider state only. Not persisted.

```dart
// In lib/features/ai/domain/exam_prep_models.dart

sealed class ExamQuestion {}

class McqQuestion extends ExamQuestion {
  final String question;
  final List<String> options;
  final String answer;        // 'A' | 'B' | 'C' | 'D'
  final String explanation;
  McqQuestion({required this.question, required this.options, required this.answer, required this.explanation});
}

class ShortAnswerQuestion extends ExamQuestion {
  final String question;
  final String answer;
  ShortAnswerQuestion({required this.question, required this.answer});
}

class FlashCard extends ExamQuestion {
  final String front;
  final String back;
  FlashCard({required this.front, required this.back});
}
```

---

### Exam Prep Provider

```
lib/features/ai/presentation/providers/exam_prep_provider.dart
```

State:
```dart
class ExamPrepState {
  final String? selectedCourseId;
  final String? selectedCourseCode;
  final String? selectedCourseName;
  final String questionType;           // 'mcq' | 'short' | 'flash'
  final String topic;
  final List<ExamQuestion> questions;
  final Map<int, bool> revealed;       // index → whether answer is revealed
  final Map<int, String?> selectedAnswer; // MCQ: index → selected option
  final bool isLoading;
  final String? error;
  final bool isAtLimit;
}
```

Notifier methods:
- `void selectCourse(String id, String code, String name)`
- `void setQuestionType(String type)`
- `void setTopic(String topic)`
- `Future<void> generate()` — calls API, parses JSON, appends to `questions`
- `void revealAnswer(int index)` — sets `revealed[index] = true`
- `void selectMcqOption(int index, String option)` — records selection, auto-reveals answer
- `void clearQuestions()` — resets questions list (for new generation from scratch)

JSON parser (private, in notifier):
```dart
List<ExamQuestion> _parseQuestions(String json) {
  final list = jsonDecode(json.trim()) as List;
  return list.map((item) {
    final map = item as Map<String, dynamic>;
    switch (map['type']) {
      case 'mcq':
        return McqQuestion(
          question: map['question'],
          options: List<String>.from(map['options']),
          answer: map['answer'],
          explanation: map['explanation'],
        );
      case 'short':
        return ShortAnswerQuestion(question: map['question'], answer: map['answer']);
      case 'flash':
        return FlashCard(front: map['front'], back: map['back']);
      default:
        throw FormatException('Unknown question type: ${map['type']}');
    }
  }).toList();
}
```

---

### New Files

```
lib/features/ai/presentation/
├── screens/
│   └── exam_prep_screen.dart
└── widgets/
    ├── question_type_selector.dart
    ├── mcq_card.dart
    ├── short_answer_card.dart
    └── flashcard_widget.dart
```

#### `exam_prep_screen.dart`

Layout:
- AppBar: "Exam Prep"
- Course picker — horizontal scrollable `Wrap` of `FilterChip`s (one per CWA course)
- `QuestionTypeSelectorWidget`
- Topic `TextField`
- "Generate 5 Questions" `FilledButton`
- `ListView` of question cards (rendered based on type)
- "Generate 5 more" `TextButton` at bottom (only shows if `questions.isNotEmpty`)
- `PremiumGateWidget` at bottom when `isAtLimit == true`

#### `question_type_selector.dart`

Three segmented-button-style options. Use Flutter's built-in `SegmentedButton<String>` widget.
Options: "Multiple Choice" | "Short Answer" | "Flash Cards"

#### `mcq_card.dart`

```
[Question text]

[A. Option text]   ← tappable tile
[B. Option text]   ← tappable tile
[C. Option text]   ← tappable tile
[D. Option text]   ← tappable tile

[Explanation — visible after tap, animated reveal]
```

After user taps:
- Correct option gets a green background
- Selected wrong option gets a red background
- All options become non-tappable
- Explanation text fades in below

Use `flutter_animate` for the reveal animations.

#### `short_answer_card.dart`

```
[Question text]

[Show Answer]  ← button

[Answer text — fades in after button tap]
```

Button changes to "Hide Answer" after reveal. Toggle is fine.

#### `flashcard_widget.dart`

```
Front face: question text, centered
Back face: answer text, centered, different background color

Tap → flip animation (rotate Y axis 180°)
```

Use `flutter_animate`'s rotation effect or `AnimationController` with `Transform`. The card should feel physical — flip takes ~300ms.

---

### AI Tab Update

In `ai_chat_screen.dart`, add a feature card ABOVE the message list (or as a persistent header):

```
[Exam prep icon]  Generate practice questions for any course  [→]
```

Tappable → navigates to `/ai/exam-prep`. Style it as a compact info card, not an interruptive banner.

---

### Router Update

```dart
GoRoute(
  path: '/ai/exam-prep',
  builder: (context, state) => const ExamPrepScreen(),
),
```

---

### Session 1 Checkpoint

Commit: `feat(phase-14): exam prep — screen, 3 question types, MCQ/short/flashcard widgets`

Verify:
- [ ] All 3 question types generate from real DeepSeek responses
- [ ] MCQ: tapping an option reveals correct/wrong state and explanation
- [ ] Short answer: show/hide answer toggles correctly
- [ ] Flash card: flip animation works on tap
- [ ] "Generate 5 more" appends correctly without replacing existing questions
- [ ] Free user sees gate after 1 generation
- [ ] Premium user has unlimited generations
- [ ] `flutter analyze` clean

---

## Session 2 — Smart Notifications

### Packages to Add

```yaml
dependencies:
  flutter_local_notifications: ^17.0.0
  timezone: ^0.9.4
  workmanager: ^0.5.0
```

Run `flutter pub get` after adding.

---

### Android Setup (Required)

In `android/app/src/main/AndroidManifest.xml`, add inside `<application>`:
```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
  <intent-filter>
    <action android:name="android.intent.action.BOOT_COMPLETED"/>
    <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
  </intent-filter>
</receiver>
```

Also add permissions inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

For Workmanager, add inside `<application>`:
```xml
<service
  android:name="androidx.work.impl.background.systemalarm.SystemAlarmService"
  android:exported="false" />
```

---

### Notification Types

| ID | Name | Trigger | Message |
|---|---|---|---|
| 1 | Streak at risk | 8pm daily if no session today and streak > 0 | AI-generated, personalized |
| 2 | Study reminder | Based on first free block today | "Free block at [time] — good time for [course]" |
| 3 | Weekly review ready | Monday 8am | Fixed message |
| 4 | Milestone unlocked | On app open, after streak milestone crossed | Fixed message |

---

### New Domain File

```
lib/features/ai/domain/notification_scheduler.dart
```

Pure Dart class (no Flutter imports except for the notification plugin calls which must happen in a `@pragma('vm:entry-point')` top-level function for Workmanager).

Responsibilities:
- `Future<void> scheduleStreakRiskCheck()` — registers a daily Workmanager task at 8pm
- `Future<void> scheduleStudyReminder(String time, String course)` — schedules a one-time notification
- `Future<void> fireWeeklyReviewNotification()` — schedules Monday 8am notification
- `Future<void> fireMilestoneNotification(String milestoneName)` — immediate notification

---

### Notification Initialisation

Create `lib/core/services/notification_service.dart`:

```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Accra')); // Ghana timezone

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));
  }

  static Future<bool> requestPermission() async {
    final result = await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    return result ?? false;
  }

  static Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
  }) async {
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'campusiq_general',
          'CampusIQ Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );
  }

  static Future<void> scheduleAt({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledTime,
  }) async {
    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'campusiq_general',
          'CampusIQ Notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}
```

Call `NotificationService.init()` in `main.dart` before `runApp`.

---

### Workmanager Setup

In `main.dart`, initialise Workmanager after Isar and notifications:
```dart
await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
```

Top-level callback (must be `@pragma('vm:entry-point')`):
```dart
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    switch (taskName) {
      case 'streak_risk_check':
        await _handleStreakRiskCheck();
        break;
    }
    return true;
  });
}
```

`_handleStreakRiskCheck()` (top-level function):
1. Open Isar (must re-open in background isolate — Workmanager runs in a separate isolate)
2. Read today's `StudySessionModel` records — if any exist, do nothing (streak safe)
3. Read current streak from `UserPrefsModel` — if streak == 0, do nothing
4. Call `DeepSeekClient.complete()` with a short streak risk prompt to generate personalized message
5. Fire notification via `NotificationService.showImmediate()`

**Streak risk prompt:**
```
Write a 1-sentence motivational notification for a student whose study streak of [N] days is at risk.
They haven't studied yet today. Be warm and direct. No markdown. Under 15 words.
```
`maxTokens: 40`

---

### Scheduling Logic

In `notification_scheduler.dart`:

#### Daily streak check at 8pm:
```dart
Future<void> scheduleStreakRiskCheck() async {
  await Workmanager().registerPeriodicTask(
    'streak_risk_check',
    'streak_risk_check',
    frequency: const Duration(hours: 24),
    initialDelay: _timeUntil8pm(),
    constraints: Constraints(networkType: NetworkType.connected),
  );
}

Duration _timeUntil8pm() {
  final now = DateTime.now();
  final eightPm = DateTime(now.year, now.month, now.day, 20, 0);
  if (now.isAfter(eightPm)) {
    return eightPm.add(const Duration(days: 1)).difference(now);
  }
  return eightPm.difference(now);
}
```

#### Study reminder (called when timetable is loaded):
```dart
Future<void> scheduleStudyReminder({
  required String freeBlockTime, // 'HH:mm'
  required String courseCode,
}) async {
  // Parse time, schedule for today at that time
  // Only schedule if it's still in the future
  // Message: "Free block coming up — good time for [courseCode]"
}
```

Call `scheduleStudyReminder` from the timetable provider when the day's free blocks are loaded. Schedule for the first free block of today only.

#### Monday weekly review notification:
```dart
Future<void> scheduleWeeklyReviewNotification() async {
  // Schedule for next Monday 8am
  // Use tz.TZDateTime for Ghana timezone
  // ID: 3
  // Title: "Week in Review ready 📋"
  // Body: "See how your week went — open CampusIQ"
}
```

Call from `WeeklyReviewProvider` after successfully generating a review.

#### Milestone notification (immediate):
Called from `StreakProvider` when a new milestone is crossed. Check by comparing old streak count to new streak count and seeing if a milestone threshold was crossed.

```dart
Future<void> fireMilestoneNotification(int streakDays) async {
  await NotificationService.showImmediate(
    id: 4,
    title: '$streakDays Day Streak! 🔥',
    body: 'You\'ve hit the $streakDays day milestone. Keep it going!',
  );
}
```

---

### Notification Permission Screen

Before registering any notifications, check if permission has been granted. Store `notificationPermissionAsked` in `UserPrefsModel`.

On first launch after Phase 16 onboarding is complete (or on first AI tab open in this phase), show a simple `AlertDialog`:

```
[bell icon]
Stay on track with CampusIQ

We'll remind you when your streak is at risk, 
when you have a free study block, and when your 
weekly review is ready.

[Not now]   [Allow notifications →]
```

Only show once. If user taps "Allow notifications", call `NotificationService.requestPermission()` then schedule tasks. If "Not now", set `notificationPermissionAsked = true` in `UserPrefsModel` and do not ask again.

---

### Session 2 Checkpoint

Commit: `feat(phase-14): smart notifications — workmanager, streak risk, study reminder, milestone`

Verify:
- [ ] `NotificationService.init()` runs without error on cold start
- [ ] Permission dialog shows once, never again after dismissed
- [ ] Streak risk notification fires at 8pm when no session logged (test by temporarily reducing delay)
- [ ] Study reminder uses real timetable free block time
- [ ] Weekly review notification scheduled correctly after review generation
- [ ] Milestone notification fires when streak crosses a milestone threshold
- [ ] No crash when notifications fire while app is closed

---

## Phase 14 Done — Final Commit

`feat: Phase 14 complete — exam prep generator + smart notifications`

Update `CLAUDE.md` with:
- `NotificationService` location and `init()` call in `main.dart`
- `callbackDispatcher` top-level function location
- Workmanager task names
- `ExamPrepScreen` at `/ai/exam-prep`
- `ExamQuestion` sealed class location
- Notification IDs: 1 (streak risk), 2 (study reminder), 3 (weekly review), 4 (milestone)
