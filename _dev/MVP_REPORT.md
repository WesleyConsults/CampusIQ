# CampusIQ — MVP Completion & Roadmap Report

**Date:** 2026-04-11
**Package:** com.wesleyconsults.campusiq
**Status:** Roadmap Phase 15 Complete (Study Plan & Weekly Review)

---

## Overview

CampusIQ is an advanced academic performance system built Android-first for Ghanaian university students (KNUST target audience). Beyond the core MVP (CWA, Timetable, Sessions, Streaks), the system now integrates powerful AI capabilities for academic coaching, exam preparation, automated study planning, and smart behavioral notifications.

---

## Tech Stack

| Layer | Choice | Version |
|---|---|---|
| Framework | Flutter (Android-first) | 3.x |
| State management | Riverpod (Annotations + Codegen) | ^2.5.1 |
| Local storage | Isar (NoSql) | ^3.1.0+1 |
| Navigation | Go Router | ^14.2.0 |
| AI Integration | DeepSeek API | (Direct HTTP) |
| Notifications | Flutter Local Notifications | ^21.0.0 |
| Background Tasks | Workmanager | ^0.9.0 |
| Fonts | Google Fonts (Inter) | ^6.2.1 |

---

## Architecture

The project adheres to a strict **Feature-Based Data/Domain/Presentation** architecture. Business logic is isolated in the domain layer as pure Dart, ensuring testability and reliability in background isolates.

```
lib/
├── core/                  — Global infrastructure (Router, Theme, Providers, Services)
├── shared/                — Cross-feature utilities and widgets
└── features/
    ├── ai/                — AI Infrastructure, Chat, History, Exam Prep
    ├── cwa/               — CWA Tracker and Calculator
    ├── insights/          — Performance Analyser and Insights
    ├── plan/              — Daily Task Planner and Exam Mode
    ├── review/            — Weekly Review system
    ├── session/           — Study Session Tracker
    ├── settings/          — App configuration and testing hooks
    ├── streak/            — Streak calculator and Milestone system
    └── timetable/         — Dual-layer timetable components
```

---

## Routes

| Route | Feature | Access |
|---|---|---|
| `/plan` | Daily Task Planner / Exam Mode | Bottom Nav |
| `/cwa` | CWA Target Planner | Bottom Nav |
| `/timetable` | Dual-layer Timetable | Bottom Nav |
| `/sessions` | Study Session Tracker | Bottom Nav |
| `/streak` | Streak & Milestones | Bottom Nav |
| `/ai` | AI Coach Chatbot | Bottom Nav |
| `/insights` | Academic Insights | Side menu / Plan tab |
| `/settings` | App Settings | Top bar |
| `/ai/exam-prep` | MCQ / Flashcard Generator | AI Tab |
| `/ai/weekly-review`| Monday Performance Review | AI Tab |
| `/subscribe` | Premium Subscription Stub | Gate triggers |

---

## Phase Summaries

### Phases 1–5: The Core MVP
*   **Phase 1 (CWA)**: Course tracking with live projected CWA calculations.
*   **Phase 2 (Class Table)**: Official lecture schedules with fast-select course chips.
*   **Phase 3 (Personal Table)**: Recurring personal slots (Gym, Study) on a dual-layer grid.
*   **Phase 4 (Sessions)**: Time tracking with DateTime anchors and Mini-Timer persistence.
*   **Phase 5 (Streak)**: Milestone-driven study streaks with activity heatmaps and loss aversion alerts.

### Phase 11: Exam Mode Transformation
*   **Dynamic UI**: The "Plan" tab transforms into "Exam Mode" with orange styling and countdown banners.
*   **Activation**: Triggered manually or automatically when exams are identified in the roadmap.
*   **Exam Manager**: Dedicated interface for tracking exam dates, venues, and specific study targets.

### Phase 12: AI Infrastructure & Chat
*   **DeepSeek Integration**: Direct REST API integration with environment variable isolation.
*   **Context Injection**: `ContextBuilder` gathers real academic data (CWA, Streaks, Schedule) to personalise AI responses.
*   **Session History**: Chat sessions are persisted in Isar with a history drawer for switching conversations.

### Phase 13: CWA AI Coach
*   **What-if Explainer**: AI explains how specific grades in upcoming courses will impact the overall CWA.
*   **Academic Advice**: Goal-oriented coaching based on current performance gaps.

### Phase 14: Exam Prep & Smart Notifications
*   **Generator**: AI creates MCQs (with explanations), Short Answers, and Flashcards (with 3D-flip animations).
*   **Workmanager**: background isolate handles daily streak checks and personalized motivation.
*   **Notification System**: Permission-guarded alerts for streak-at-risk (fired at 8pm), study reminders, and milestones.

### Phase 15: Study Plan & Weekly Review
*   **Automated Planning**: AI generates a full daily schedule combining classes, study habits, and personal goals.
*   **Weekly Review**: Every Monday morning, AI evaluates the previous week's performance, logs it in Isar, and presents a summary sheet.
*   **Performance Insights**: `InsightAnalyser` identifies best study windows and neglected subjects.

---

## Isar Collections (Full List)

| Collection | Context | Purpose |
|---|---|---|
| `CourseModel` | CWA | Academic courses, credits, and target grades. |
| `TimetableSlotModel` | Timetable | Official university class schedules. |
| `PersonalSlotModel` | Timetable | Recurring personal tasks and study blocks. |
| `StudySessionModel` | Sessions | Logged study time records. |
| `UserPrefsModel` | Core | App state, attendance tracker, and featured flags. |
| `AiMessageModel` | AI | Persistent chat message history. |
| `AiChatSessionModel` | AI | Container for unified chat threads. |
| `AiUsageModel` | AI | Daily rate-limiting for free-tier users. |
| `StudyPlanModel` | Plan | Container for AI-generated daily study schedules. |
| `StudyPlanSlotModel` | Plan | Individual tasks within an AI study plan. |
| `DailyPlanTaskModel` | Plan | Unified task list items (Classes + Study + Manual). |
| `ExamModel` | Plan | Exam event tracker with dates and venues. |
| `WeeklyReviewModel` | Review | Weekly performance evaluations stored as history. |
| `SubscriptionModel` | Payments | User premium status and entitlement data. |

---

## Dependencies

| Package | Version | Layer |
|---|---|---|
| `flutter_riverpod` | ^2.5.1 | State Management |
| `isar` | ^3.1.0+1 | Local Database |
| `go_router` | ^14.2.0 | Navigation |
| `flutter_animate` | ^4.5.0 | Dynamic UI |
| `flutter_local_notifications`| ^21.0.0 | System Alerts |
| `workmanager` | ^0.9.0 | Background Tasks |
| `http` | ^1.2.0 | Networking |
| `flutter_dotenv` | ^5.1.0 | Environment Config |
| `timezone` | ^0.11.0 | Scheduling Logic |

---

## Key Engineering Decisions

### 1-7: MVP Core Decisions
*(See previous reports for details on Timer Reliability, ShellRoute Mini-Timers, and Recurrence Expansion)*

### 8. Background Isolation Strategy
Workmanager tasks run in a separate entry-point isolate. We re-open Isar in the background to access session history for streak checks, and re-load `.env` for DeepSeek API calls. This ensures background notifications are truly personalised without relying on a running UI thread.

### 9. Unified Plan Screen (Exam Mode)
Rather than a separate route, the Plan tab dynamically morphs into Exam Mode. This ensures the student remains focused on their priority tasks (exams) without losing access to their daily routine.

### 10. AI Contextual Awareness
The `ContextBuilder` transforms raw Isar data into prompt-friendly markdown strings. The AI "sees" the student's entire academic profile before answering, preventing generic "hallucinations" and providing Ghanaian-specific advice.

---

## Build Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

---

## Git History (Milestones)

| Commit | Summary |
|---|---|
| Phase 1-5 | MVP Core (CWA, Table, Sessions, Streak) |
| Phase 12 | AI Infrastructure & Context-Aware Chat |
| Phase 13 | CWA AI Coach & Goal Analysis |
| Phase 14 | Exam Prep & Workmanager Notifications |
| Phase 15 | AI Study Planning & Weekly Performance Reviews |
