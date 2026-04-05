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
Phase 2 complete — Phase 3 next (Personal Timetable + Dual View)

## Routes live
/cwa        → CWA Target Planner
/timetable  → Class Timetable

## Do not
- Use Hive (we chose Isar)
- Use setState in screens (use Riverpod ConsumerWidget)
- Put logic in widgets
- Skip build_runner after editing any @collection or @riverpod annotated file
