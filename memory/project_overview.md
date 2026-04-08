---
name: CampusIQ Project Overview
description: MVP complete with 5 phases; Flutter academic planning app for KNUST students
type: project
---

# CampusIQ — Project Status

**Phase:** MVP complete (Phases 1-5). Phases 6-10 are planned.

## Current features (MVP)
1. **CWA Target Planner** — track needed scores for target GPA
2. **Dual-layer Timetable** — class schedule + personal recurring schedule, swipe layers
3. **Study Session Tracker** — timer with wall-clock anchor (survives background), analytics
4. **Streak System** — track consecutive study days, per-course streaks, milestones, heatmap

## Tech Stack
- **Framework:** Flutter (Android-first)
- **State:** Riverpod (riverpod_annotation + riverpod_generator)
- **Storage:** Isar 3.x (NOT Hive)
- **Navigation:** Go Router + ShellRoute
- **Fonts:** Google Fonts (Inter)

## Architecture
Three-layer per feature: data/ → domain/ → presentation/. Business logic never in widgets. Domain = pure Dart.

## Isar Collections
- `CourseModel` — courses with credit hours + expected scores
- `TimetableSlotModel` — class slots
- `PersonalSlotModel` — recurring personal slots
- `StudySessionModel` — completed sessions
- `UserPrefsModel` — single-row key/value store

## Planned next (Phases 6-10)
- **Phase 6–7:** Daily Plan feature (auto-generate daily task list with smart scheduling)
- **Phase 8:** Smart Notifications (free blocks, streak alerts, milestones, weekly review)
- **Phase 9:** Smart Insights (data-driven analysis: best study times, neglected courses, trends)
- **Phase 10:** Weekly Review (summary modal, reflection notes, milestone tracking)
