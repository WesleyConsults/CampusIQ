# CampusIQ — Claude Code Project Brief

## What this is
Flutter academic planning app for Ghanaian university students (KNUST first).
Package ID: com.wesleyconsults.campusiq

## Tech stack
- Flutter + Dart (Android-first)
- State: Riverpod (riverpod_annotation + riverpod_generator)
- Storage: Isar (NOT Hive)
- Navigation: Go Router
- Fonts: Google Fonts (Inter)

## Architecture rule
Every feature follows: data/ → domain/ → presentation/ (screens, widgets, providers)
Never mix business logic into widgets. Domain layer is pure Dart only.

## Dev machine
Ubuntu 24, external HDD at /media/edwin/18FC2827FC28021C/projects/
Flutter SDK: [add your path]
Android emulator or physical device: [add your device]

## Build commands
flutter pub get
dart run build_runner build --delete-conflicting-outputs   ← run after ANY model change
flutter analyze
flutter run

## Current phase
Phase 14 complete — Exam Prep + Smart Notifications

## MVP feature set
- CWA Target Planner (offline, live calculation)
- Dual-layer Timetable (class + personal, swipe view, full recurrence)
- Study Session Tracker (DateTime anchor timer, planned vs actual)
- Streak System (study + per-course + attendance, milestones, heatmap)
- AI Coach (DeepSeek integration, context-aware chat, history)
- Exam Prep Generator (MCQ, Short Answer, Flashcards)
- Smart Notifications (Workmanager, streak protection, personalized alerts)

## Phase 15 (next)
Weekly review — Isar schema, generation, screen, free gate, AI tab banner

## Routes live
/cwa          → CWA Target Planner
/timetable    → Class + Personal Timetable (swipe layers)
/sessions     → Session Tracker + Analytics Dashboard
/streak       → Streak System
/ai_chat      → AI Coach & Academic Assistant Chatbot
/ai/exam-prep → AI Exam Prep Question Generator

## Timetable views
Swipe left/right: Class Only ↔ Both ↔ Personal Only
Page 0 = classOnly, Page 1 = both (default), Page 2 = personalOnly

## Global state / Services
- activeSessionProvider — lives above ShellRoute, survives tab switches
- NotificationService — singleton for local notifications & permissions
- callbackDispatcher — top-level entry point for Workmanager tasks
- Timer uses DateTime anchor (not Stopwatch) for Android reliability

## Notification IDs
- 100: Streak Secured (Immediate)
- 200: Streak at Risk (Background/AI-personalized)
- 300: Study Reminder (Scheduled)
- 400: Weekly Review ready (Scheduled)
- 500: Milestone unlocked (Immediate)

## Do not
- Use Hive (we chose Isar)
- Use setState in screens (use Riverpod ConsumerWidget)
- Put logic in widgets
- Skip build_runner after editing any @collection or @riverpod annotated file
