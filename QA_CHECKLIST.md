# CampusIQ — Compact Scale QA Checklist

Run this checklist after changing scale tokens. Verify each screen at compact (~80%), default (100%), and comfortable (~120%) scale.

## Quick Setup

1. Open `lib/core/theme/app_tokens.dart`
2. Change the AppSpacing raw values, AppRadii, and AppIconSizes for your target profile
3. Change font sizes in `lib/core/theme/app_theme.dart` textTheme
4. Hot reload
5. Work through this checklist

---

## 1. Timetable

| Check | Compact | Default | Comfortable |
|-------|---------|---------|-------------|
| Slot text remains readable (no text < ~8px) | ☐ | ☐ | ☐ |
| Course code visible in all slot sizes | ☐ | ☐ | ☐ |
| Course name truncates cleanly in short slots | ☐ | ☐ | ☐ |
| No vertical clipping in long/dense days | ☐ | ☐ | ☐ |
| Day selector pills don't overlap | ☐ | ☐ | ☐ |
| Time labels (left gutter) don't clip | ☐ | ☐ | ☐ |
| Swipe between class/both/personal works | ☐ | ☐ | ☐ |

**Scaling note:** If using compact mode, reduce `TimetableConstants.pixelsPerMinute` to ~0.8. This shrinks the grid proportionally.

---

## 2. CWA Screen

| Check | Compact | Default | Comfortable |
|-------|---------|---------|-------------|
| Quick stat grid cards don't overflow | ☐ | ☐ | ☐ |
| View toggle (Semester / Cumulative) fits | ☐ | ☐ | ☐ |
| Course history rows — no pill clip/overlap | ☐ | ☐ | ☐ |
| Score pills and grade pills remain distinct | ☐ | ☐ | ☐ |
| Import button and menu stay accessible | ☐ | ☐ | ☐ |
| Target CWA dialog renders cleanly | ☐ | ☐ | ☐ |

---

## 3. Plan Screen

| Check | Compact | Default | Comfortable |
|-------|---------|---------|-------------|
| Academic Pulse grid — no text clip in tiles | ☐ | ☐ | ☐ |
| Today at a Glance card renders fully | ☐ | ☐ | ☐ |
| Task tiles — metadata doesn't overflow | ☐ | ☐ | ☐ |
| Progress bar labels stay inside bounds | ☐ | ☐ | ☐ |
| Plan summary rows — icon + text alignment OK | ☐ | ☐ | ☐ |

---

## 4. Sessions Screen

| Check | Compact | Default | Comfortable |
|-------|---------|---------|-------------|
| Active timer — counter stays fully visible | ☐ | ☐ | ☐ |
| Duration stepper buttons are tappable | ☐ | ☐ | ☐ |
| Course picker sheet — tabs and list readable | ☐ | ☐ | ☐ |
| History tiles — no text clip or overlap | ☐ | ☐ | ☐ |
| Analytics summary cards render fully | ☐ | ☐ | ☐ |
| Floating mini timer (if active) — legible | ☐ | ☐ | ☐ |

---

## 5. Shell / Navigation

| Check | Compact | Default | Comfortable |
|-------|---------|---------|-------------|
| Bottom nav bar — icons and labels visible | ☐ | ☐ | ☐ |
| AI FAB — not clipping into nav or content | ☐ | ☐ | ☐ |
| Mini timer (if active) — clears FAB and nav | ☐ | ☐ | ☐ |
| Bottom sheets open with correct height | ☐ | ☐ | ☐ |
| Safe area insets respected (notch, home bar) | ☐ | ☐ | ☐ |

---

## Known Risk Hotspots (check these first)

- **Timetable slot card**: fontSize 9, 10, 11 — at -20% these hit ~7-9px. Keep above 8px floor.
- **Timetable grid**: `pixelsPerMinute` must scale with the profile or slots look sparse/tight.
- **CWA history rows**: 5 elements on one line — verify pills don't collide.
- **Plan metric grid**: `childAspectRatio: 1.5` — verify labels fit inside tiles.
- **Session stepper**: fixed 34×34 button — verify still tappable at compact scale.

---

## After QA

- [ ] No overflow in any screen at the target scale
- [ ] No text below `AppFloors.minCaptionFontSize` (8px)
- [ ] All tap targets ≥ `AppFloors.minTapTarget` (40px) visual area
- [ ] `flutter analyze` passes with zero new issues
- [ ] Token guardrail script (`scripts/check_tokens.sh`) reviewed
