# CampusIQ — Pre-Launch Master Checklist

This document tracks the final steps required to transition CampusIQ from the MVP phase to a secure, production-ready app available on the Google Play Store.

---

## 🛠️ Part 1: Engineering & Code (To be done together)

These are the technical implementation steps we need to complete in the codebase.

- [ ] **1. Vercel API Proxy (Security)**
  - [ ] Create a Vercel serverless project.
  - [ ] Move `DEEPSEEK_API_KEY` and `OPENAI_API_KEY` to Vercel Environment Variables.
  - [ ] Add rate limiting to the Vercel functions (e.g., `@vercel/rate-limiter`) to prevent API budget abuse if the proxy URL is extracted.
  - [ ] Update `DeepSeekClient` in Flutter to point to the new Vercel endpoints instead of directly to the APIs.
  - [ ] Remove all API keys from the Flutter app's `.env` and `--dart-define` configurations.

- [ ] **2. Crash Logging & Error Tracking (Sentry)**
  - [ ] Install the `sentry_flutter` package.
  - [ ] Initialize Sentry in `main.dart` to catch fatal app crashes.
  - [ ] Override `FlutterError.onError` to pipe UI errors silently to the Sentry dashboard.

- [ ] **3. Usage & Feature Tracking (PostHog)**
  - [ ] Install the PostHog Flutter SDK.
  - [ ] Create an `analyticsProvider` to handle event logging.
  - [ ] Add event tracking for key actions (e.g., `session_started`, `ai_chat_sent`, `course_added`).
  - [ ] Add screen view tracking via a GoRouter observer.

- [ ] **4. Subscription Paywall (RevenueCat)**
  - [ ] *Note: Replaces the Paystack implementation planned in Phase 17.*
  - [ ] Install `purchases_flutter` (RevenueCat SDK).
  - [ ] Build the Subscription Paywall UI (`/subscribe`).
  - [ ] Wire the UI to RevenueCat to fetch Google Play product prices and trigger the native purchase sheet.
  - [ ] Update `SubscriptionRepository` to grant Premium status based on RevenueCat's entitlement response.

- [ ] **5. First-Run Onboarding Flow (Phase 16)**
  - [ ] Build the 5-screen welcome flow (Welcome → University → Programme → Target CWA → Notifications).
  - [ ] Setup GoRouter redirect gated by the `hasCompletedOnboarding` flag in Isar.
  - [ ] Save user preferences (University, Programme, Target CWA) upon completion.

- [ ] **6. Play Store Assets & Polish**
  - [ ] Generate the final App Icon using `flutter_launcher_icons`.
  - [ ] Generate the Splash Screen using `flutter_native_splash`.
  - [ ] Update Android `versionCode` and `versionName` in `build.gradle.kts`.
  - [ ] Configure `proguard-rules.pro` to protect Isar, Flutter, Sentry, RevenueCat, and Riverpod code-gen classes from code shrinking.
  - [ ] Build the final Release App Bundle (`.aab`).

- [ ] **7. App Signing & Key Store**
  - [ ] Generate a production keystore (`.jks`) for signing the release `.aab`.
  - [ ] Configure `key.properties` and reference it in `build.gradle.kts` for release builds.
  - [ ] Back up the keystore file, alias, and passwords in a secure location (1Password / encrypted drive). Losing this key means you can never update the app on Play — you'd have to publish a new package.

- [ ] **8. In-App Rating Prompt**
  - [ ] Add the `in_app_review` package.
  - [ ] Trigger the native review dialog after positive milestone moments (e.g., completing a 7-day streak, finishing a full study session). Early rating velocity directly impacts Play Store discovery.

- [ ] **9. Terms of Service**
  - [ ] Draft a Terms of Service covering user conduct (AI chat), subscription terms, and liability.
  - [ ] Host it at a public URL alongside the privacy policy.

- [ ] **10. Database Migration Safety**
  - [ ] Explicitly verify Isar schema version and migration path. The first production release must handle existing dev data gracefully — a migration crash silently loses user data.
  - [ ] Test: install the current dev build, add some data, then install the release `.aab` over it and confirm no crash.

- [ ] **11. Accessibility Baseline**
  - [ ] Verify all tappable elements have `semanticLabel` where needed.
  - [ ] Run a quick TalkBack (Android screen reader) smoke test on the main screens. Google Play flags apps with poor accessibility.

- [ ] **12. Startup Performance Check**
  - [ ] Run `flutter run --profile --trace-startup` and confirm time-to-first-frame is under 3 seconds on a mid-range device.
  - [ ] Profile the home screen for frame drops. Play Vitals tracks both and surfaces them in the Console.

- [ ] **13. Open Source License Attribution**
  - [ ] Run `flutter build apk --analyze-size` and verify the licenses output includes all third-party SDKs (RevenueCat, Sentry, PostHog, etc.). Missing attribution is a legal risk.

---

## 📝 Part 2: Admin & Accounts (For Edwin to prepare)

These are the account setups and configurations you need to do on the web.

- [ ] **1. Google Play Developer Account**
  - [ ] Register at the Google Play Console.
  - [ ] Pay the $25 one-time registration fee.

- [ ] **2. Google Payments Merchant Profile**
  - [ ] Set up the payments profile in the Play Console.
  - [ ] Link your Ghanaian bank account for payouts.
  - [ ] Verify your identity (Ghana Card).

- [ ] **3. RevenueCat Account Setup**
  - [ ] Create a free account at [RevenueCat.com](https://www.revenuecat.com/).
  - [ ] Register your app in the RevenueCat dashboard.

- [ ] **4. Create Subscription Products**
  - [ ] (Requires approved Google Play account) Create "Monthly" (GHS 20) and "Semester" (GHS 120) subscription products in the Google Play Console.
  - [ ] Link the Google Play Console to the RevenueCat dashboard so RevenueCat can read these products.

- [ ] **5. Prepare Store Listing Assets**
  - [ ] Prepare 3-5 high-quality app screenshots.
  - [ ] Write a compelling Short Description (max 80 chars) and Full Description.
  - [ ] Update the Privacy Policy to include mentions of RevenueCat, Sentry, and PostHog, and host it online (e.g., GitHub Pages or Notion).

- [ ] **6. App Signing Key Enrollment**
  - [ ] When creating the app in Play Console, decide on Play App Signing (Google manages the release key, you use an upload key). Decide before first upload — switching later is painful.

- [ ] **7. Support Email**
  - [ ] Create a dedicated support email (e.g., `campusiq.support@gmail.com`). A professional address listed in the store listing builds trust. Required for publication.

- [ ] **8. Hosted Privacy Policy URL**
  - [ ] Extract the draft from `_dev/PHASE_16_ONBOARDING_PLAYSTORE.md` into a standalone page.
  - [ ] Ensure it explicitly mentions data collection by RevenueCat, Sentry, and PostHog.
  - [ ] Host it at a public URL and enter it in the Play Console.

- [ ] **9. Hosted Terms of Service URL**
  - [ ] Host the ToS at a public URL (same platform as privacy policy). Required because the app handles user-generated content (AI chat) and subscriptions.

- [ ] **10. Content Rating Questionnaire**
  - [ ] Complete the content rating questionnaire in the Play Console. Required before publishing. For an academic app it should be quick, but it is a hard gate.

- [ ] **11. Data Safety Section**
  - [ ] Declare what user data the app collects (AI chat messages, course data, study session logs, analytics), how it's used, and whether it's shared. PostHog, Sentry, and RevenueCat all collect data that must be declared. Mandatory since 2022.

- [ ] **12. Sensitive Permissions Justification**
  - [ ] In the Play Console under "App content > Sensitive app permissions," justify why the app needs `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM` (study reminders and streak notifications). Required for Android 14+.

- [ ] **13. Staged Rollout Plan**
  - [ ] Internal testing (team only) → Closed alpha (invite link) → Open beta → 10% production → 50% → 100%. Each stage catches different issues before they reach everyone.

- [ ] **14. Device Testing Coverage**
  - [ ] Run the Play Console pre-launch report (tests on 5+ physical devices automatically).
  - [ ] Manually test on at least one low-end device (2GB RAM, Android 10) — that is the realistic baseline for Ghanaian university students.

---

## 📊 Summary Table

| # | Item | Severity | Section |
|---|---|---|---|
| 1 | Vercel API Proxy + rate limiting | **Blocker** | Part 1 — Security |
| 2 | Sentry crash logging | **Blocker** | Part 1 — Stability |
| 3 | PostHog analytics | High | Part 1 — Insights |
| 4 | RevenueCat subscriptions | **Blocker** | Part 1 — Monetisation |
| 5 | Onboarding flow | High | Part 1 — UX |
| 6 | Play Store assets (icon, splash, ProGuard, .aab) | **Blocker** | Part 1 — Build |
| 7 | Signing key generation & backup | **Blocker** | Part 1 — Build |
| 8 | In-app rating prompt | Medium | Part 1 — Growth |
| 9 | Terms of Service (draft + host) | **Likely required** | Part 1 — Legal |
| 10 | Database migration test | High | Part 1 — Data |
| 11 | Accessibility baseline | Medium | Part 1 — Quality |
| 12 | Startup performance check | Low | Part 1 — Quality |
| 13 | Open source license attribution | Low-Medium | Part 1 — Legal |
| — | — | — | — |
| 14 | Google Play Developer account ($25) | **Blocker** | Part 2 — Account |
| 15 | Google Payments merchant profile | **Blocker** | Part 2 — Monetisation |
| 16 | RevenueCat account setup | **Blocker** | Part 2 — Monetisation |
| 17 | Create subscription products in Play Console | **Blocker** | Part 2 — Monetisation |
| 18 | Store listing assets (screenshots, descriptions) | **Blocker** | Part 2 — Store |
| 19 | App signing key enrollment (Play Console) | **Blocker** | Part 2 — Store |
| 20 | Support email | **Blocker** | Part 2 — Store |
| 21 | Hosted privacy policy URL | **Blocker** | Part 2 — Legal |
| 22 | Hosted Terms of Service URL | **Likely required** | Part 2 — Legal |
| 23 | Content rating questionnaire | **Blocker** | Part 2 — Store |
| 24 | Data safety section | **Blocker** | Part 2 — Store |
| 25 | Sensitive permissions justification (Android 14+) | **Likely required** | Part 2 — Store |
| 26 | Staged rollout plan | Advisory | Part 2 — Risk |
| 27 | Device testing coverage (low-end + pre-launch report) | Advisory | Part 2 — Quality |

---

## 🎨 Part 3: UI Status & Remaining Work (Complete before backend)

This section tracks the state of every screen in the app. The goal: finish all UI work first, then move entirely to backend/infrastructure.

### Current state: 13 of 14 screens are fully built (~90%)

| Screen | Route | Lines | Status |
|---|---|---|---|
| PlanScreen (Today dashboard) | `/plan` | 1,312 | Done |
| CwaScreen (CWA planner) | `/cwa` | 1,610 | Done |
| TimetableScreen | `/timetable` | 489 | Done |
| SessionScreen (study timer) | `/sessions` | 893 | Done |
| AiChatScreen | `/ai` | 509 | Done |
| WeeklyReviewScreen | `/ai/weekly-review` | 189 | Done |
| StreakScreen | `/streak` | 129 | Done |
| InsightsScreen | `/insights` | 93 | Done |
| SettingsScreen | `/settings` | 241 | Done |
| CourseHubScreen | `/course/:courseCode` | 121 | Done |
| TimetableImportScreen | `/timetable/import` | 366 | Done |
| CwaManualEntryScreen | `/cwa/manual-entry` | 954 | Done |
| RegistrationSlipImportScreen | (Navigator.push) | 614 | Done |
| ResultSlipImportScreen | (Navigator.push) | 954 | Done |
| PastSemestersScreen | (Navigator.push) | 547 | Done |
| **SubscribeScreenStub** | `/subscribe` | 16 | **STUB — "Coming soon" text only** |

### Remaining UI work (4 items)

- [ ] **A. Onboarding Flow (5 screens)** — Build from scratch
  - Welcome screen (logo, tagline, CTA)
  - University selection (KNUST + future)
  - Programme selection
  - Target CWA setter (slider or input)
  - Notification permission priming
  - Wire `hasCompletedOnboarding` flag in Isar + GoRouter redirect guard

- [ ] **B. Subscribe / Paywall Screen** — Replace the 16-line stub
  - Two subscription tiers: Monthly (GHS 20) and Semester (GHS 120)
  - Feature comparison table (Free vs. Premium)
  - Subscribe CTA button (wired to RevenueCat trigger later)
  - Visual polish — this is the monetisation screen, conversion matters

- [ ] **C. App Icon** — `flutter_launcher_icons`
  - Design a 1024×1024 PNG icon asset
  - Add `flutter_launcher_icons` to `pubspec.yaml` dev_dependencies
  - Configure adaptive icon for Android

- [ ] **D. Splash Screen** — `flutter_native_splash`
  - Design splash asset (logo centered on brand background)
  - Add `flutter_native_splash` to `pubspec.yaml` dev_dependencies
  - Covers Android 12+ splash screen API automatically

### Recommended sequence

```
1. Onboarding (5 screens)   ← biggest, user's first impression
2. Subscribe / Paywall      ← ~1 screen, design-heavy, revenue-critical
3. App Icon                 ← one asset + config
4. Splash Screen            ← one asset + config
```

After these 4 are checked off, all UI work is complete. The remaining 23 checklist items in Parts 1 and 2 are backend, infrastructure, accounts, and store admin — no more screens or widgets to build.
