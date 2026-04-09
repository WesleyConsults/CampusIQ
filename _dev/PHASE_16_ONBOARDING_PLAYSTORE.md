# CampusIQ — Phase 16: Onboarding Flow + Play Store Readiness

---

## Session Overview

**Phase:** 16 of 16 — Final Phase  
**Sessions required:** 2  
**Depends on:** All phases 11–15 complete  
**Unlocks:** Public launch on Google Play Store

**What this phase delivers:**
- First-run onboarding flow (5 screens, gated by `hasCompletedOnboarding` flag)
- App icon generation (all Android DPI sizes)
- Splash screen
- Release AAB build configuration
- Play Store listing assets (short description, full description, privacy policy, release notes)
- Pre-launch checklist
- Final `CLAUDE.md` update covering the complete project

**What this phase does NOT touch:**
- Any AI features or payment logic
- Existing screens or providers

---

## Project Context

Read `CLAUDE.md` before starting. Key facts:
- `UserPrefsModel` is a single-row Isar key/value store — use it for `hasCompletedOnboarding`, `university`, `programme`, `targetCwa` flags
- `UserPrefsRepository` already has read/write methods — add new key constants, do not create new methods from scratch
- Target CWA is set in the CWA planner screen — onboarding should pre-fill it via the same provider
- Ghana timezone: `Africa/Accra`
- Package name: `com.wesleyconsults.campusiq`
- Run `dart run build_runner build --delete-conflicting-outputs` if any Riverpod annotations change

---

## Session 1 — Onboarding Flow

### Logic Gate

In `app.dart` or `app_router.dart`, on cold start:

```dart
final hasOnboarded = await userPrefsRepository.getBool('hasCompletedOnboarding') ?? false;
if (!hasOnboarded) {
  // redirect to /onboarding
}
```

Use GoRouter's `redirect` callback:
```dart
redirect: (context, state) async {
  final hasOnboarded = ref.read(hasOnboardedProvider);
  if (!hasOnboarded && state.matchedLocation != '/onboarding') {
    return '/onboarding';
  }
  return null;
},
```

Create `hasOnboardedProvider`:
```dart
@riverpod
Future<bool> hasOnboarded(Ref ref) async {
  final repo = await ref.watch(userPrefsRepositoryProvider.future);
  return await repo.getBool('hasCompletedOnboarding') ?? false;
}
```

After onboarding completes: call `ref.invalidate(hasOnboardedProvider)` to trigger the redirect to `/cwa`.

---

### New Files

```
lib/features/onboarding/
└── presentation/
    ├── screens/
    │   └── onboarding_screen.dart
    ├── providers/
    │   └── onboarding_provider.dart
    └── widgets/
        ├── onboarding_page.dart
        └── onboarding_progress_dots.dart
```

---

### `onboarding_provider.dart`

State:
```dart
class OnboardingState {
  final int currentPage;         // 0–4
  final String university;       // default: 'KNUST'
  final String programme;
  final double targetCwa;        // default: 3.0
  final bool notificationAsked;
  final bool isCompleting;
}
```

Notifier methods:
- `void nextPage()` — increments `currentPage`, capped at 4
- `void prevPage()` — decrements, capped at 0
- `void setUniversity(String value)`
- `void setProgramme(String value)`
- `void setTargetCwa(double value)`
- `Future<void> complete()`:
  1. Set `isCompleting = true`
  2. Write to `UserPrefsModel` via `UserPrefsRepository`:
     - `university` → `university`
     - `programme` → `programme`
     - `hasCompletedOnboarding` → `true`
  3. Write target CWA to the CWA planner (call `CwaRepository` or the CWA provider's `setTarget()` method — whatever method sets the target CWA in the existing CWA feature)
  4. Invalidate `hasOnboardedProvider`
  5. (Router redirect handles navigation to `/cwa` automatically)

---

### `onboarding_screen.dart`

`ConsumerStatefulWidget`. Uses a `PageController` to manage 5 pages.

```dart
final _pageController = PageController();
```

Sync `PageController` position with `onboardingProvider.currentPage`.

Outer layout:
```
Stack(
  children: [
    PageView(controller: _pageController, physics: NeverScrollableScrollPhysics(), ...)
    Positioned bottom: OnboardingProgressDots + nav buttons
  ]
)
```

Disable swipe navigation — only advance via buttons.

Nav buttons (bottom row):
- "Back" `TextButton` (hidden on page 0)
- Progress dots (centered)
- "Next" `FilledButton` (pages 0–3) or "Get Started" `FilledButton` (page 4)

On "Next" from page 4: call `onboardingProvider.complete()`.

---

### The 5 Onboarding Pages (`onboarding_page.dart`)

Each page follows this structure:
```
[illustration area — use flutter_animate or a simple SVG/Icon, 200px height]
[title — 22px, centered]
[subtitle — 16px, muted, centered, max 2 lines]
[input area — varies per page]
```

#### Page 0 — Welcome
- Title: "Welcome to CampusIQ"
- Subtitle: "Your AI academic coach for university"
- Large app icon or a simple animated sparkle icon (use `flutter_animate`)
- No input
- Next button: "Let's go →"

#### Page 1 — University
- Title: "Which university are you at?"
- Subtitle: "We'll tailor your experience to your programme"
- Input: `DropdownButtonFormField<String>` with options:
  ```
  KNUST, University of Ghana, UCC, UMAT, UDS, UEW, Ashesi, UPSA, Other
  ```
- Default selected: "KNUST"
- On change: `ref.read(onboardingProvider.notifier).setUniversity(value)`

#### Page 2 — Programme
- Title: "What are you studying?"
- Subtitle: "This helps us give you course-relevant AI coaching"
- Input: `TextField` with hint "e.g. Computer Engineering, Medicine, Law"
- `TextEditingController` bound to provider state
- Optional — user can skip by leaving blank

#### Page 3 — Target CWA
- Title: "What's your target CWA?"
- Subtitle: "You can change this anytime in the planner"
- Input: `Slider` from 1.0 to 4.0, step 0.1
- Below slider: large display of current value e.g. **3.0**
- Below value: label based on range:
  - 1.0–1.9: "Pass"
  - 2.0–2.9: "Credit / Lower Second"
  - 3.0–3.4: "Upper Second"
  - 3.5–4.0: "First Class / Distinction"
- Default: 3.0

#### Page 4 — Notifications
- Title: "Stay on track"
- Subtitle: "Get reminders when your streak is at risk and when your weekly review is ready"
- Three bullet points (icons + text, no actual bullet characters):
  - 🔔 Streak at-risk alerts at 8pm
  - 📅 Study reminders based on your free blocks
  - 📊 Weekly review every Monday
- Two buttons (stacked, not side-by-side):
  - `FilledButton`: "Allow notifications" → calls `NotificationService.requestPermission()` then schedules tasks, then calls `complete()`
  - `TextButton`: "Skip for now" → calls `complete()` without requesting permission
- Both buttons trigger completion — notification permission is not mandatory

---

### `onboarding_progress_dots.dart`

5 dots. Current page dot: larger + primary color. Other dots: smaller + muted color. Use `AnimatedContainer` for smooth size/color transitions.

---

### `UserPrefsRepository` — New Keys to Add

Add constants to `UserPrefsRepository` (or wherever key strings are managed):
```dart
static const String keyHasCompletedOnboarding = 'hasCompletedOnboarding';
static const String keyUniversity = 'university';
static const String keyProgramme = 'programme';
```

Add methods if not already present:
```dart
Future<String?> getString(String key);
Future<void> setString(String key, String value);
Future<bool?> getBool(String key);
Future<void> setBool(String key, bool value);
```

These operate on the existing `UserPrefsModel` key/value Isar store.

---

### Context Builder Update

Now that `university` and `programme` are stored, update `ContextBuilder.buildAcademicContext()` to include them:
```
Student context:
- University: KNUST | Programme: Computer Engineering
- ...rest of existing context...
```

---

### Session 1 Checkpoint

Commit: `feat(phase-16): onboarding flow — 5 screens, university/programme/CWA/notifications`

Verify:
- [ ] Onboarding shows on clean install (clear app data to simulate)
- [ ] Onboarding does NOT show on second launch
- [ ] University, programme, and target CWA are saved correctly
- [ ] Target CWA pre-fills in the CWA planner after onboarding
- [ ] "Allow notifications" page calls permission request
- [ ] "Skip" works and completes onboarding
- [ ] Navigation to `/cwa` after onboarding is immediate and smooth
- [ ] `flutter analyze` clean

---

## Session 2 — Play Store Readiness

### Packages to Add

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.0
  flutter_native_splash: ^2.4.0
```

---

### App Icon Setup

**Edwin must supply** a `1024x1024` PNG file named `app_icon.png` and place it at:
```
assets/images/app_icon.png
```

Add to `pubspec.yaml`:
```yaml
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/images/app_icon.png"
  adaptive_icon_background: "#FFFFFF"  # adjust to match app theme
  adaptive_icon_foreground: "assets/images/app_icon.png"
  min_sdk_android: 21
```

Run:
```bash
dart run flutter_launcher_icons
```

This generates all required Android DPI icon sizes in `android/app/src/main/res/`.

---

### Splash Screen Setup

Add to `pubspec.yaml`:
```yaml
flutter_native_splash:
  color: "#FFFFFF"                       # match app background color
  image: assets/images/app_icon.png
  android_12:
    image: assets/images/app_icon.png
    icon_background_color: "#FFFFFF"
  fullscreen: false
```

Run:
```bash
dart run flutter_native_splash:create
```

---

### `android/app/build.gradle.kts` — Release Config

Verify these values are correct (do not change if already set):
```kotlin
android {
    namespace = "com.wesleyconsults.campusiq"
    compileSdk = 34
    defaultConfig {
        applicationId = "com.wesleyconsults.campusiq"
        minSdk = 21
        targetSdk = 34
        versionCode = 1
        versionName = "1.0.0"
    }
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}
```

---

### ProGuard Rules

Create or update `android/app/proguard-rules.pro`:
```
# Isar
-keep class dev.isar.** { *; }
-dontwarn dev.isar.**

# Paystack
-keep class co.paystack.** { *; }
-dontwarn co.paystack.**

# Workmanager
-keep class androidx.work.** { *; }

# Flutter
-keep class io.flutter.** { *; }
-dontwarn io.flutter.**

# Keep all app classes
-keep class com.wesleyconsults.campusiq.** { *; }
```

---

### Store Listing Assets

Create folder: `store_assets/`

The agent writes all files below as plain text files:

---

#### `store_assets/short_description.txt`

Max 80 characters:
```
AI academic coach for university students. CWA planning, study streaks & more.
```

---

#### `store_assets/full_description.txt`

```
CampusIQ is the AI-powered academic productivity app built for Ghanaian university students — starting with KNUST.

PLAN YOUR CWA
Know exactly what scores you need in each course to hit your target CWA. Adjust your expected scores with a slider and see your projected CWA update in real time.

MANAGE YOUR TIME
Build your class timetable, add personal activities, and let CampusIQ find your free study blocks automatically.

TRACK YOUR STUDY SESSIONS
Start a study timer for any course. See your weekly hours, per-course breakdown, and planned vs actual session analytics.

BUILD STUDY STREAKS
Never lose momentum. CampusIQ tracks your daily study streak, celebrates milestones, and keeps you consistent all semester.

🤖 CAMPUSIQ PREMIUM — AI THAT KNOWS YOU
Upgrade to Premium and unlock your personal AI academic coach:

• Unlimited AI coach — ask anything about your courses, grades, or study strategy
• Auto study plan — a personalized weekly plan built from your real timetable and course priorities
• Weekly AI review — every Monday, see what went well, what to fix, and your #1 focus
• Exam prep generator — practice MCQs, short answers, and flash cards for any course
• Smart notifications — streak alerts and study reminders that actually know your schedule

PREMIUM PRICING
GHS 20/month or GHS 120/semester (best value)
Pay securely with MTN MoMo, Vodafone Cash, or AirtelTigo Money via Paystack.

---
Built by WesleyConsults · Takoradi, Ghana
Support: wesleyconsults@gmail.com
```

---

#### `store_assets/privacy_policy.md`

```markdown
# CampusIQ Privacy Policy

Last updated: [DATE OF LAUNCH]

## 1. Data We Collect

CampusIQ stores your academic data (courses, timetable, study sessions, streaks) **locally on your device only** using a local database (Isar). We do not upload your academic data to any server.

When you use Premium AI features, your study context (course names, CWA values, session hours, streak count) is sent to DeepSeek's API to generate personalized coaching. No personally identifiable information (name, student ID, phone number) is included in these requests. See DeepSeek's privacy policy for how they handle API data.

When you purchase a Premium subscription, your payment is processed by Paystack. We store only your transaction reference and subscription expiry date, locally on your device. Your payment details (card or MoMo number) are handled entirely by Paystack and are never seen or stored by CampusIQ.

## 2. Data We Do Not Collect

- We do not collect your name, student ID, or phone number
- We do not have user accounts or a sign-in system
- We do not track your location
- We do not use analytics SDKs (no Firebase, no Crashlytics)
- We do not display advertisements

## 3. Local Notifications

If you grant notification permission, CampusIQ schedules local notifications on your device. These notifications are generated locally and do not involve sending data to a server.

## 4. Data Deletion

To delete all your data, uninstall the app. All locally stored data is removed on uninstall.

## 5. Contact

Questions about this policy: wesleyconsults@gmail.com
```

---

#### `store_assets/whats_new.txt`

```
CampusIQ 1.0 — First release 🎉

- CWA Target Planner with live projections
- Class & personal timetable with free time detection
- Study session tracking & analytics
- Streak system with milestones
- AI Coach powered by DeepSeek (Premium)
- Auto study plan & weekly review (Premium)
- Pay with MTN MoMo, Vodafone Cash, or AirtelTigo Money
```

---

### `store_assets/LAUNCH_CHECKLIST.md`

```markdown
# CampusIQ Launch Checklist

Complete every item before submitting to Google Play.

## Secrets & Keys
- [ ] DeepSeek API key stored as `--dart-define=DEEPSEEK_API_KEY=...` (NOT in source or .env committed to git)
- [ ] Paystack public key stored as `--dart-define=PAYSTACK_PUBLIC_KEY=...`
- [ ] Paystack plan codes stored as `--dart-define=PAYSTACK_MONTHLY_PLAN=...` and `--dart-define=PAYSTACK_SEMESTER_PLAN=...`
- [ ] `.env` file is in `.gitignore` and not committed
- [ ] Git history checked for accidentally committed secrets (`git log --all -p | grep -i 'sk_'`)

## Build
- [ ] `flutter build appbundle --release --dart-define=DEEPSEEK_API_KEY=xxx --dart-define=PAYSTACK_PUBLIC_KEY=xxx --dart-define=PAYSTACK_MONTHLY_PLAN=xxx --dart-define=PAYSTACK_SEMESTER_PLAN=xxx` completes without errors
- [ ] AAB file size is under 150MB
- [ ] `flutter analyze` reports zero issues

## App Testing
- [ ] Tested on Android 8 (API 26) — minimum supported
- [ ] Tested on Android 10 (API 29)
- [ ] Tested on Android 12 (API 31)
- [ ] Tested on Android 14 (API 34) — target SDK
- [ ] Onboarding flow tested on clean install (uninstall → reinstall)
- [ ] Onboarding does NOT re-show on second launch
- [ ] All 4 main tabs functional after onboarding
- [ ] AI chat works under free quota (test: send 3 messages, confirm gate appears on 4th)
- [ ] AI chat unlimited after Paystack payment
- [ ] CWA coach and what-if explainer quotas enforced
- [ ] Study plan generates and persists
- [ ] Weekly review generates on Monday (or first Monday open)
- [ ] Exam prep generates all 3 question types
- [ ] Streak-at-risk notification fires (reduce delay for testing)
- [ ] Study reminder fires at correct free block time
- [ ] Paystack checkout opens and completes (use Paystack test card in sandbox)
- [ ] Premium activates immediately after successful payment
- [ ] Expired subscription downgrades on next launch (manually set past `expiresAt` in dev)
- [ ] Restore purchase works with a valid-format reference
- [ ] Account screen shows correct plan and expiry

## Play Store Console
- [ ] App signed with release keystore (keep keystore file safe — losing it means you can never update the app)
- [ ] Short description under 80 chars
- [ ] Full description uploaded
- [ ] At least 2 screenshots uploaded (minimum for Play Store)
- [ ] Privacy policy URL added (host the privacy_policy.md on GitHub Pages or a simple webpage)
- [ ] Content rating questionnaire completed
- [ ] Target audience set (18+ or General)
- [ ] App category: Education
- [ ] Country availability: Ghana (can expand later)

## Post-Launch
- [ ] Paystack live mode enabled (switch from test to live keys)
- [ ] Monitor DeepSeek API usage dashboard for the first week
- [ ] Set up a Paystack webhook (optional for v1, useful for v2) to verify payments server-side
```

---

### Release Build Command

Document this in `CLAUDE.md` and `store_assets/LAUNCH_CHECKLIST.md`:

```bash
flutter build appbundle --release \
  --dart-define=DEEPSEEK_API_KEY=your_deepseek_key \
  --dart-define=PAYSTACK_PUBLIC_KEY=pk_live_your_key \
  --dart-define=PAYSTACK_MONTHLY_PLAN=PLN_your_monthly_code \
  --dart-define=PAYSTACK_SEMESTER_PLAN=PLN_your_semester_code
```

---

### Session 2 Checkpoint

Commit: `feat(phase-16): app icon, splash screen, ProGuard, store assets, launch checklist`

Verify:
- [ ] `dart run flutter_launcher_icons` generates icons without error
- [ ] `dart run flutter_native_splash:create` runs without error
- [ ] App icon appears correctly on home screen (test on device)
- [ ] Splash screen appears on cold launch
- [ ] Release AAB builds successfully with the full `--dart-define` command
- [ ] All files present in `store_assets/`
- [ ] Privacy policy covers: local data storage, AI API usage, Paystack payment, no ads

---

## Phase 16 Done — Final Commit

`feat: Phase 16 complete — onboarding, Play Store assets, release build. CampusIQ v1.0 ready.`

---

## Final `CLAUDE.md` Update

At the end of Phase 16, rewrite `CLAUDE.md` to reflect the complete project state. It should cover:

**Project overview:** CampusIQ v1.0, Flutter, Android-first, KNUST students, Phases 1–16 complete

**Architecture:** Three-layer (data/domain/presentation), Riverpod + code-gen, Isar 3.x, GoRouter ShellRoute

**All Isar collections:**
- `CourseModel` (CWA)
- `TimetableSlotModel` (class timetable)
- `PersonalSlotModel` (personal timetable)
- `StudySessionModel` (sessions)
- `UserPrefsModel` (key/value store — attendance, onboarding, notification flags)
- `SubscriptionModel` (id:1, single row)
- `AiMessageModel` (chat history)
- `AiUsageModel` (daily quota tracking)
- `StudyPlanModel` + `StudyPlanSlotModel` (generated plan)
- `WeeklyReviewModel` (cached review)

**All routes:** `/cwa`, `/timetable`, `/sessions`, `/streak`, `/ai`, `/ai/weekly-review`, `/ai/exam-prep`, `/subscribe`, `/account`, `/onboarding`

**Key services:**
- `DeepSeekClient` — `lib/features/ai/domain/deepseek_client.dart`
- `ContextBuilder` — `lib/features/ai/domain/context_builder.dart`
- `NotificationService` — `lib/core/services/notification_service.dart`
- `PaystackService` — `lib/features/subscription/domain/paystack_service.dart`
- `SubscriptionRepository` — `lib/core/data/repositories/subscription_repository.dart`

**Secrets (dart-define only, never in source):**
- `DEEPSEEK_API_KEY`
- `PAYSTACK_PUBLIC_KEY`
- `PAYSTACK_MONTHLY_PLAN`
- `PAYSTACK_SEMESTER_PLAN`

**Build command:** (full command with all dart-defines)

**Known issues / future work:**
- Server-side Paystack webhook verification not yet implemented
- Restore purchase is local-trust only (no server verification)
- Multi-university support beyond KNUST not yet built
- Cloud backup of Isar data not yet built
