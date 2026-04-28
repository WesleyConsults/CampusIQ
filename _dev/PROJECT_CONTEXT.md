# CampusIQ Project Context (v1.0 Lean)

This document provides a concise technical overview of CampusIQ for AI agents and developers.

## 1. Overview
CampusIQ is an Android-first academic productivity app for Ghanaian university students (KNUST target). It centralizes CWA tracking, timetable management, study sessions, and AI-powered assistance.

## 2. Tech Stack
- **Framework:** Flutter (Material 3)
- **State Management:** Riverpod (Generator-based)
- **Database:** Isar (Local-only, NoSQL)
- **Navigation:** GoRouter
- **AI:** DeepSeek (API via HTTP), OpenAI Vision (for image parsing)
- **Background Tasks:** Workmanager

## 3. Architecture Pattern
Strict three-layer structure per feature:
- `data/`: Isar schemas (`models/`) and repositories (`repositories/`).
- `domain/`: Pure Dart business logic (calculators, analysers, value objects).
- `presentation/`: Riverpod providers, screens, and widgets.

## 4. Core Features (v1.0)
1.  **CWA Planner:** Manual entry + registration slip import (AI Vision). Supports Semester and Cumulative tracking.
2.  **Timetable:** Single-layer class grid. Supports image import (AI Vision) and free-time detection.
3.  **Study Sessions:** Count-up (Normal) and Count-down (Pomodoro) timers. Tracks focus time only.
4.  **Course Hub:** Per-course workspace with Notes (Markdown), Files (PDF/Image), and Source-Grounded AI (RAG-lite via local PDF text extraction).
5.  **Daily Plan:** AI-generated task list based on timetable free blocks.
6.  **Insights & Reviews:** Automated analytics and AI-generated narrative weekly reviews.
7.  **Streak System:** Daily study and attendance tracking with milestone rewards.

## 5. Key Data Models (Isar)
- `CourseModel`: CWA courses, credits, scores.
- `TimetableSlotModel`: Class times, venues, types.
- `StudySessionModel`: Session logs (duration, course, type).
- `UserPrefsModel`: Global flags (streak, notifications, attendance).
- `CourseNoteModel` / `CourseFileModel`: Course-specific materials.
- `AiMessageModel` / `AiChatSessionModel`: Chat history.
- `DailyPlanTaskModel`: Generated tasks for the current day.
- `PastSemesterModel`: Archived result data for cumulative CWA.

## 6. Critical Implementation Notes
- **Timer Logic:** Stores a `DateTime` anchor (`startTime`). Elapsed time is `now.difference(startTime)` to survive app pauses.
- **AI Context:** Uses a `ContextBuilder` to inject academic stats, notes, and session history into system prompts for personalized coaching.
- **RAG-lite:** Local PDF text extraction via `syncfusion_flutter_pdf`. Text is stored in `CourseFileModel` and injected into AI context when "From My Notes" mode is active.
- **Lean Build:** Personal Timetable, Exam Mode, and Exam Prep Generator were removed in v1.0 to prioritize stability.

## 7. Key File Locations
- `lib/core/`: Providers (Isar, connectivity, notification), Router, and Theme.
- `lib/features/`: Feature-specific code.
- `lib/shared/`: Reusable widgets and extensions.
- `_dev/`: Documentation (MVP report, E2E checklist).
