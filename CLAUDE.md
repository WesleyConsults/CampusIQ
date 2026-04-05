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
Phase 5 complete — MVP DONE

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

## Routes live
/cwa        → CWA Target Planner
/timetable  → Class + Personal Timetable (swipe layers)
/sessions   → Session Tracker + Analytics Dashboard
/streak     → Streak System

## Timetable views
Swipe left/right: Class Only ↔ Both ↔ Personal Only
Page 0 = classOnly, Page 1 = both (default), Page 2 = personalOnly

## Global state
activeSessionProvider — lives above ShellRoute, survives tab switches
Timer uses DateTime anchor (not Stopwatch) for Android reliability

## Do not
- Use Hive (we chose Isar)
- Use setState in screens (use Riverpod ConsumerWidget)
- Put logic in widgets
- Skip build_runner after editing any @collection or @riverpod annotated file
