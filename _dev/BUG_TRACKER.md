# CampusIQ Bug Tracker

| ID | Title | Feature | Type | Severity | Status |
|---|---|---|---|---|---|
| BUG-001 | Target CWA slider needs +/− buttons | CWA Planner | UX Friction | Low | Closed |
| BUG-002 | High-impact badge shows only one course | CWA Planner | UX Friction | Medium | Closed |
| BUG-003 | Edit sheet does not save expected score changes | CWA Planner | Bug | High | Closed |
| BUG-004 | AI Coach follow-up loses coaching context in chat | AI Chat | Bug | High | Closed |
| BUG-005 | Timetable day picker missing Sunday | Timetable | Bug | Medium | Closed |
| BUG-006 | Timetable time grid rows too tall | Timetable | UX Friction | Low | Closed |
| BUG-007 | No AM/PM or time order validation on slot creation | Timetable | Bug | High | Closed |
| BUG-008 | Overlapping slots cause unreadable mixed text on grid | Timetable | Bug | High | Closed |
| BUG-009 | Personal and class slots overlap in Both view | Timetable | Bug | High | Closed |
| BUG-010 | Class slot grid shows no venue information | Timetable | Missing Feature | Medium | Open |
| BUG-011 | Swipe gesture switches days instead of views | Timetable | UX Friction | Medium | Open |
| ENH-001 | Pomodoro phase-end notification feels weak — upgrade to alarm-style | Session / Pomodoro | Enhancement | Medium | Open |

**Total: 11 bugs + 1 enhancement — 4 High, 4 Medium, 2 Low**

---

### ENH-001 — Pomodoro alarm-style notification

**Current behaviour:** Phase-end fires a standard high-priority notification via `flutter_local_notifications` (`zonedSchedule` + `exactAllowWhileIdle`). It arrives silently if the device is in DND or if the notification channel volume is low.

**Desired behaviour:** Feel like an actual timer alarm — plays a sound, bypasses DND, persists until dismissed or the student taps back into the app.

**Suggested approach:**
- Set `AndroidNotificationDetails.sound` to a custom bundled sound (short bell/chime in `android/app/src/main/res/raw/`)
- Set `fullScreenIntent: true` so it surfaces over the lock screen
- Set `category: AndroidNotificationCategory.alarm` — this bypasses DND on Android 10+
- Consider a second `showImmediate` call from the foreground when `_checkPhaseExpiry` fires, so the in-app alert is also prominent (vibrate + sound even while the screen is on)

Heavy concentration in **Timetable** (7 bugs) and **CWA Planner** (3 bugs). Good time to pause and fix before moving forward.
