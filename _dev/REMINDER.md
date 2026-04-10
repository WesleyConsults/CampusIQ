# ⚠️ PRE-LAUNCH REMINDER — Re-enable AI Quota Gate

## What was changed (and why)

During Phase 12 testing, the 3-message daily limit on the AI chat was
bypassed to allow unrestricted testing without hitting the quota gate.

**File modified:**
`lib/features/ai/data/repositories/ai_usage_repository.dart`

**Change made:**
```dart
Future<bool> isUnderLimit(String feature, int freeLimit) async {
  if (kDebugMode) return true;   // <-- ADDED FOR TESTING — REMOVE BEFORE RELEASE
  final usage = await getUsageToday(feature);
  return usage < freeLimit;
}
```

---

## ✅ Action required before going live

Remove the `if (kDebugMode) return true;` line (and the `foundation.dart`
import if it is no longer used elsewhere) so that the real quota limits
are enforced for all users in production.

**Target state (restore to this):**
```dart
Future<bool> isUnderLimit(String feature, int freeLimit) async {
  final usage = await getUsageToday(feature);
  return usage < freeLimit;
}
```

---

## Checklist

- [ ] Remove `if (kDebugMode) return true;` from `isUnderLimit`
- [ ] Remove `import 'package:flutter/foundation.dart';` if unused
- [ ] Run `flutter analyze` — confirm no issues
- [ ] Do a release build (`flutter build apk --release`) and manually
      verify the quota gate triggers after 3 AI messages
- [ ] Commit with message: `restore AI quota gate for production`

---

_Added: 2026-04-10 | Reason: Phase 12 debug testing bypass_
