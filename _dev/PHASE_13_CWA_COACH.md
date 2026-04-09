# CampusIQ — Phase 12: Smart CWA Coach + What-If AI Explainer

---

## Session Overview

**Phase:** 12 of 16  
**Sessions required:** 1  
**Depends on:** Phase 11 complete (DeepSeek client, context builder, usage quota, subscription provider all working)  
**Unlocks:** Phase 13

**What this phase delivers:**
- AI-powered CWA coach accessible from the existing CWA screen
- AI-powered what-if explainer that wraps the existing `CwaCalculator.whatIf()` domain method
- Both features enforce free/premium quota rules
- Zero new Isar collections — reads entirely from existing `CourseModel` data

**What this phase does NOT touch:**
- The AI chat screen (Phase 11)
- Timetable, sessions, or streak features
- Any new routes

---

## Project Context

Read `CLAUDE.md` before starting. Key facts:
- Phase 11 is complete — `DeepSeekClient`, `ContextBuilder`, `AiUsageRepository`, `isPremiumProvider` are all available
- `CwaCalculator` exists at `lib/features/cwa/domain/cwa_calculator.dart` with a `whatIf()` method
- `CourseModel` is the Isar schema for courses — read from `CwaRepository`
- Quota rules: free users share a pool of 3 AI calls/day for `feature: 'chat'`; what-if has its own counter `feature: 'whatif'` with a limit of 2/day
- Run `dart run build_runner build --delete-conflicting-outputs` only if new Riverpod annotations are added (no new Isar models this phase)

---

## Feature A — Smart CWA Coach

### User Experience (exactly what the user sees and does)

1. User opens the CWA screen (`/cwa`) — existing screen, no layout changes to the main content
2. A new **"Get AI Coaching"** `TextButton` with a sparkle icon sits below the `CwaSummaryBar` widget, above the course list
3. User taps it
4. A `DraggableScrollableSheet` (bottom sheet) slides up — **not** a full-screen navigation
5. Inside the sheet:
   - Header: "AI Coach" with a small close button
   - If premium or under limit: loading indicator appears, then 3–5 lines of coaching advice render
   - A "Ask a follow-up →" link at the bottom navigates to `/ai` (the existing AI chat screen)
   - If free user is over limit: `PremiumGateWidget` (from Phase 11) renders inside the sheet instead of the advice
6. Sheet is dismissable by swiping down

### What the AI Receives

Extend `ContextBuilder` with a new method: `Future<String> buildCwaCoachPrompt()`.

This method calls `buildAcademicContext()` and appends a task instruction:

```
[base context from buildAcademicContext()]

Task: Give this student 3 specific, actionable recommendations about their CWA situation.
Rules:
- Identify which course has the most credit-hour leverage on their CWA
- State whether the target CWA is achievable given current projections
- Give one concrete study priority for this week
- Do NOT repeat the numbers back — the student can already see them on screen
- Do NOT use bullet points or markdown — write in plain flowing sentences
- Maximum 4 sentences total
```

`maxTokens: 300` — keep it short.

### Quota Enforcement

- Counts against `feature: 'chat'` (shared pool with the AI chat screen)
- Free limit: 3 per day total across chat + coach
- Check `isUnderLimit('chat', 3)` before calling DeepSeek
- If over limit: show `PremiumGateWidget` inside the bottom sheet
- After successful call: `incrementUsage('chat')`
- Premium users: skip limit check entirely

### New Files

```
lib/features/cwa/presentation/
└── widgets/
    └── cwa_coach_sheet.dart
```

#### `cwa_coach_sheet.dart`

`ConsumerStatefulWidget`. Opens as a bottom sheet via `showModalBottomSheet` (or `DraggableScrollableSheet`).

State: `isLoading`, `advice` (String?), `error` (String?), `isAtLimit` (bool)

`initState` / `didChangeDependencies`:
1. Read `isPremiumProvider` and `aiUsageRemainingProvider('chat', 3)`
2. If at limit and not premium: set `isAtLimit = true`, skip API call
3. Otherwise: call `ContextBuilder.buildCwaCoachPrompt()` → call `DeepSeekClient.complete()` → set `advice`
4. On success: call `AiUsageRepository.incrementUsage('chat')`

Renders:
- Loading: `CircularProgressIndicator` centered
- Success: `Text(advice)` with comfortable padding + "Ask a follow-up →" `TextButton`
- Error: error message + "Try again" button
- At limit: `PremiumGateWidget`

### CWA Screen Update

In `cwa_screen.dart`, add the "Get AI Coaching" button. Place it between `CwaSummaryBar` and the course list. On tap:

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  builder: (_) => const CwaCoachSheet(),
);
```

No other changes to `cwa_screen.dart`.

---

## Feature B — What-If CWA Explainer

### User Experience (exactly what the user sees and does)

1. User is on the CWA screen, looking at their courses
2. Existing behavior: dragging the score slider updates the projected CWA in real time
3. **New behavior:** After the user adjusts a slider (i.e., the slider value differs from the saved score), a small **"Explain this change ↗"** chip appears below that course's slider
4. User taps the chip
5. An inline card expands below the slider (not a sheet, not a new screen) showing a 1–2 sentence AI explanation
6. The explanation card disappears if the slider is returned to its original position
7. If the user adjusts a different course's slider, that course gets its own chip; the previous card collapses

### What the AI Receives

New method in `ContextBuilder`: `Future<String> buildWhatIfPrompt(WhatIfInput input)`

```dart
class WhatIfInput {
  final String courseCode;
  final String courseName;
  final int creditHours;
  final double originalScore;
  final double newScore;
  final double originalCwa;
  final double newCwa;
  final double targetCwa;
}
```

Prompt assembled:
```
[base persona only — no full context needed, keep tokens minimal]

The student changed their expected score for [courseName] ([creditHours] credit hours) 
from [originalScore] to [newScore].
This changes their projected CWA from [originalCwa] to [newCwa]. Their target is [targetCwa].

Explain the impact in exactly 1–2 sentences. 
Focus on: does this help reach the target? Is this course high or low leverage?
Plain English only. No markdown.
```

`maxTokens: 120` — deliberately short.

**Important implementation note:** Call `CwaCalculator.whatIf()` FIRST (it's already in the domain layer) to compute `newCwa`. Then pass the result into the prompt. DeepSeek only explains — it does not calculate.

### Quota Enforcement

- Uses `feature: 'whatif'` counter, separate from the chat pool
- Free limit: 2 per day
- Check `isUnderLimit('whatif', 2)` before calling DeepSeek
- If at limit: show a small inline message "Daily limit reached — upgrade for unlimited" instead of the chip
- Premium users: no limit, chip always available

### Caching

Cache the last explanation in the provider state — if the slider hasn't moved since the last explanation, do not re-call the API. Only call again when the slider value changes.

### New Files

```
lib/features/cwa/presentation/
├── providers/
│   └── whatif_provider.dart
└── widgets/
    ├── whatif_explain_chip.dart
    └── whatif_result_card.dart
```

#### `whatif_provider.dart`

State:
```dart
class WhatIfState {
  final Map<String, String?> explanations; // courseId → explanation text
  final Map<String, bool> isLoading;       // courseId → loading state
  final Map<String, double> adjustedScores; // courseId → current slider value
  final String? error;
}
```

Method: `Future<void> explainChange(String courseId, WhatIfInput input)`
1. Check quota
2. Check cache (`explanations[courseId]` already set for current slider value — skip if same)
3. Call DeepSeek
4. Store in `explanations[courseId]`
5. Increment usage

#### `whatif_explain_chip.dart`

Tiny chip (like a `FilterChip`) with a sparkle icon and "Explain this ↗" label.
- Shows when `sliderValue != course.expectedScore`
- Hides when slider returns to original
- Disabled (greyed) while `isLoading[courseId] == true`

#### `whatif_result_card.dart`

Animated expanding card (use `AnimatedSize` or `flutter_animate`).
- Shows `explanations[courseId]` text
- Muted background, smaller font than the main course card
- Collapses to zero height when `explanations[courseId]` is null

### Course Card Update

In `course_card.dart`, integrate both new widgets. The card already has the slider. Add below the slider:
```
[slider — existing]
[WhatifExplainChip — new, conditional]
[WhatifResultCard — new, animated]
```

Pass slider value changes to `WhatIfProvider` via `ref.read(whatifProvider.notifier).setAdjustedScore(courseId, value)`.

---

## Acceptance Criteria

### CWA Coach
- [ ] "Get AI Coaching" button visible on CWA screen below the summary bar
- [ ] Bottom sheet opens and displays AI advice after loading
- [ ] Advice is contextually accurate — references the student's actual courses and gap
- [ ] "Ask a follow-up" link navigates to `/ai` chat screen
- [ ] Free users see `PremiumGateWidget` after using 3 daily AI calls
- [ ] Premium users have no limit and see no quota UI
- [ ] Sheet is dismissable by swiping

### What-If Explainer
- [ ] Chip appears when slider value differs from saved score
- [ ] Chip disappears when slider returns to original value
- [ ] AI explanation renders in an inline expanding card
- [ ] Explanation references the course name and CWA change accurately
- [ ] `CwaCalculator.whatIf()` is called first — DeepSeek only explains the result
- [ ] Free users limited to 2 what-if explanations per day
- [ ] Caching works — same slider position does not re-call API
- [ ] No new Isar schemas added

### General
- [ ] `flutter analyze` clean
- [ ] No regressions on existing CWA screen behavior (add/edit/delete courses, live CWA update)

---

## Commit

`feat: Phase 12 complete — CWA AI coach + what-if explainer`

Update `CLAUDE.md` with:
- `CwaCoachSheet` location and how to open it
- `WhatIfProvider` state structure
- Context builder methods added: `buildCwaCoachPrompt()`, `buildWhatIfPrompt()`
