# CampusIQ — Phase 15: Subscription Paywall + Payment Integration

---

## Session Overview

**Phase:** 15 of 16  
**Sessions required:** 2  
**Depends on:** Phase 11 (subscription model in Isar), Phases 12–14 (premium gates to unlock)  
**Unlocks:** Phase 16

**What this phase delivers:**
- Full subscription screen replacing the Phase 11 stub
- Paystack Mobile Money integration (MTN MoMo, Vodafone Cash, AirtelTigo)
- Monthly (GHS 20) and semester (GHS 120) plan options
- Post-payment premium activation in Isar
- Account screen with subscription management and restore purchase flow
- Support email deeplink

**What this phase does NOT touch:**
- AI features — those are complete from Phases 12–14
- Onboarding — that is Phase 16
- Any existing MVP screens (CWA, Timetable, Sessions, Streak)

---

## Pre-Phase Checklist (Edwin to complete BEFORE handing to agent)

These steps require human action — the agent cannot do them:

- [ ] Create Paystack account at paystack.com (register with Ghana Card + TIN)
- [ ] Retrieve **Public Key** from Paystack Dashboard → Settings → API Keys
- [ ] Create two subscription plans in Paystack Dashboard → Products → Plans:
  - Plan 1: "CampusIQ Monthly" — GHS 20, monthly interval
  - Plan 2: "CampusIQ Semester" — GHS 120, every 4 months interval
- [ ] Copy the plan codes (e.g. `PLN_xxxxxxx`) for both plans
- [ ] Store these as dart-define build arguments (do NOT put in .env for keys used in payment):
  ```
  PAYSTACK_PUBLIC_KEY=pk_live_xxxxx
  PAYSTACK_MONTHLY_PLAN=PLN_xxxxx
  PAYSTACK_SEMESTER_PLAN=PLN_xxxxx
  ```

Pass these values to the agent as dart-define constants. The agent will use `String.fromEnvironment('PAYSTACK_PUBLIC_KEY')` to read them.

---

## Project Context

Read `CLAUDE.md` before starting. Key facts:
- `SubscriptionModel` (Isar, id always 1) and `SubscriptionRepository` exist from Phase 11
- `isPremiumProvider` is used across Phases 12–14 — activating premium via `SubscriptionRepository.activatePremium()` will immediately unlock all gated features
- `/subscribe` route currently shows a stub screen — this phase replaces it entirely
- WesleyConsults support email: `wesleyconsults@gmail.com`
- Run `dart run build_runner build --delete-conflicting-outputs` only if new Riverpod annotations added (no new Isar schemas this phase)

---

## Session 1 — Subscription Screen + Paystack Integration

### Package to Add

```yaml
dependencies:
  flutter_paystack: ^1.0.0
  url_launcher: ^6.2.0  # for support email deeplink
```

Run `flutter pub get`.

---

### Android Manifest Update

In `android/app/src/main/AndroidManifest.xml`, Paystack requires internet permission (already present if http is used). Confirm:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

---

### Paystack Initialisation

In `main.dart`, initialise Paystack before `runApp`:
```dart
PaystackPlugin.initialize(publicKey: const String.fromEnvironment('PAYSTACK_PUBLIC_KEY'));
```

---

### New Files — Session 1

```
lib/features/subscription/
├── data/
│   └── repositories/           ← SubscriptionRepository already exists in core/
│       (no new files here)
├── domain/
│   └── paystack_service.dart
└── presentation/
    ├── providers/
    │   └── subscription_screen_provider.dart
    └── screens/
        └── subscribe_screen.dart
    └── widgets/
        ├── plan_card.dart
        ├── feature_comparison_widget.dart
        └── payment_success_screen.dart
```

---

### `paystack_service.dart`

Pure Dart class. Wraps the Paystack Flutter SDK. Responsibilities:
- `Future<PaystackResult> initiatePayment(BuildContext context, SubscriptionPlan plan, String userEmail)`

```dart
enum SubscriptionPlan { monthly, semester }

class PaystackResult {
  final bool success;
  final String? transactionRef;
  final String? error;
  const PaystackResult({required this.success, this.transactionRef, this.error});
}
```

Implementation:
```dart
Future<PaystackResult> initiatePayment(
  BuildContext context,
  SubscriptionPlan plan,
  String userEmail,
) async {
  final amount = plan == SubscriptionPlan.monthly ? 2000 : 12000; // Paystack uses pesewas
  final planCode = plan == SubscriptionPlan.monthly
      ? const String.fromEnvironment('PAYSTACK_MONTHLY_PLAN')
      : const String.fromEnvironment('PAYSTACK_SEMESTER_PLAN');

  final charge = Charge()
    ..amount = amount
    ..email = userEmail
    ..plan = planCode
    ..currency = 'GHS'
    ..reference = _generateRef();

  try {
    final response = await PaystackPlugin.chargeCard(context, charge: charge);
    if (response.status) {
      return PaystackResult(success: true, transactionRef: response.reference);
    } else {
      return PaystackResult(success: false, error: response.message);
    }
  } catch (e) {
    return PaystackResult(success: false, error: e.toString());
  }
}

String _generateRef() {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  return 'campusiq_$timestamp';
}
```

**Note to agent:** `PaystackPlugin.chargeCard` opens the Paystack in-app checkout UI (WebView-based). On success it returns to the app with `response.status == true`. The `reference` in the response is the transaction reference to store.

---

### `subscription_screen_provider.dart`

State:
```dart
class SubscriptionScreenState {
  final SubscriptionPlan selectedPlan;
  final String email;
  final bool isProcessing;
  final String? error;
  final bool paymentSuccess;
}
```

Initial selected plan: `SubscriptionPlan.semester` (best value — default highlight).

Notifier:
- `void selectPlan(SubscriptionPlan plan)`
- `void setEmail(String email)`
- `Future<void> purchase(BuildContext context)`:
  1. Validate email
  2. Set `isProcessing = true`
  3. Call `PaystackService.initiatePayment()`
  4. On success:
     - Compute `expiresAt`: monthly = +30 days, semester = +120 days
     - Call `SubscriptionRepository.activatePremium(plan, txRef, expiresAt)`
     - Invalidate `isPremiumProvider` (so all premium gates re-read and unlock)
     - Set `paymentSuccess = true`
  5. On failure: set `error`, set `isProcessing = false`

---

### `subscribe_screen.dart`

This replaces the stub from Phase 11. Same route: `/subscribe`.

**Screen layout (top to bottom):**

```
AppBar: "Upgrade to Premium" (no back button if navigated from gate, back button if from account)

Header section:
  [sparkle icon]
  Unlock your AI academic coach
  [subtitle: "Everything you need to finish the semester strong"]

Feature comparison (FeatureComparisonWidget):
  Free          Premium
  ✓ CWA planner    ✓ Everything in Free
  ✓ Timetable      ✓ Unlimited AI coach
  ✓ Study tracker  ✓ Auto study plan
  ✓ Streaks        ✓ Weekly AI review
  ✗ AI features    ✓ Exam prep generator
                   ✓ Smart notifications

Plan selection (two PlanCard widgets):
  [Monthly — GHS 20/month]
  [Semester — GHS 120/semester ← "Best Value — save GHS 20" badge]

Email input:
  TextField: "Your email (for receipt)"
  (Paystack requires an email — inform user it's for their payment receipt only)

Payment button:
  "Pay with Mobile Money →"
  [shows CircularProgressIndicator when isProcessing]

Fine print (small muted text):
  "Powered by Paystack · Supports MTN MoMo, Vodafone Cash, AirtelTigo Money"
  "Cancel anytime from your account settings"
```

When `paymentSuccess == true`: replace screen body with `PaymentSuccessScreen` widget (do not navigate away — replace in place with an `AnimatedSwitcher`).

---

### `plan_card.dart`

```dart
class PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;
  // ...
}
```

When selected: `border: 2px solid` using primary color. When not selected: `0.5px` border.

Monthly card:
```
GHS 20
per month
```

Semester card:
```
[BEST VALUE badge]
GHS 120
per semester (4 months)
Save GHS 20
```

---

### `feature_comparison_widget.dart`

Two-column layout. No tables — use two `Column` widgets side by side in a `Row`.

Left column header: "Free"  
Right column header: "Premium ✓"

Each row: icon + feature name. Free column uses `Icons.check` for included features and `Icons.close` with muted color for missing ones.

---

### `payment_success_screen.dart`

Widget (not a screen — rendered inside `subscribe_screen.dart`):

```
[confetti animation using flutter_animate or a simple animated widget]

✓  You're now Premium!

Your plan: [Monthly / Semester]
Valid until: [date]
Transaction ref: [ref]

[Start using CampusIQ Premium →]
  ← pops back to wherever the user came from
```

Use `flutter_animate` for a scale + fade entrance animation on the checkmark.

---

### Session 1 Checkpoint

Commit: `feat(phase-15): subscribe screen, Paystack integration, payment success`

Verify:
- [ ] Paystack checkout opens successfully (test in sandbox mode first)
- [ ] On payment success: `SubscriptionModel` in Isar shows `tier: 'premium'`
- [ ] Premium features unlock immediately without app restart — test by navigating to AI tab after payment
- [ ] `isPremiumProvider` invalidation works (all gates disappear)
- [ ] Both plan cards selectable; semester selected by default
- [ ] Email validation prevents empty email from triggering payment
- [ ] `flutter analyze` clean

---

## Session 2 — Account Screen + Restore Purchase

### New Files — Session 2

```
lib/features/subscription/presentation/
├── screens/
│   └── account_screen.dart
└── widgets/
    ├── subscription_status_card.dart
    └── restore_purchase_sheet.dart
```

---

### Route + Nav Update

Add `/account` route to `app_router.dart`:
```dart
GoRoute(
  path: '/account',
  builder: (context, state) => const AccountScreen(),
),
```

Add a 6th tab to the bottom nav — or replace the approach: add an account `IconButton` to the `AppBar` of the AI screen (right side). Either works, but a dedicated bottom nav tab is cleaner. Use `Icons.person_outline` / `Icons.person`.

**Decision for agent:** Add as a 6th bottom nav tab. Label: "Account". Icon: `Icons.person_outline` (inactive) / `Icons.person` (active).

---

### `account_screen.dart`

Layout:

```
AppBar: "My Account"

SubscriptionStatusCard
  ↳ shows tier badge, plan name, expiry date

[Manage subscription section]
  Transaction reference: [ref or "—"]
  Purchased: [date or "—"]
  Valid until: [date or "Free plan"]

[Restore purchase]
  TextButton → opens RestorePurchaseSheet

[Upgrade to Premium]
  ← only shown if tier == 'free'
  → navigates to /subscribe

[Contact support]
  TextButton → opens mailto deeplink

[Dev tools — only in debug mode]
  "Force Premium (dev)" → calls devSetPremium(true)
  "Force Free (dev)"   → calls devSetPremium(false)
```

**Dev tools** must be wrapped in:
```dart
if (kDebugMode) ...[
  // dev buttons
]
```

They must NOT appear in release builds.

---

### `subscription_status_card.dart`

Reads from `SubscriptionRepository.getSubscription()`.

Free tier:
```
[gray badge: FREE]
Free plan
Upgrade to unlock AI features →
```

Premium tier:
```
[purple badge: PREMIUM]
CampusIQ Premium
[Monthly / Semester]
Valid until: April 7, 2026
```

If `expiresAt` is within 7 days: show a warning: "Expires soon — renew to keep access"

---

### `restore_purchase_sheet.dart`

`DraggableScrollableSheet` opened from the account screen.

Content:
```
Restore your purchase

If you reinstalled CampusIQ, enter your Paystack transaction 
reference from your payment receipt email to restore access.

[Transaction reference TextField]
  hint: "e.g. campusiq_1712345678"

[Restore Access]  button

Fine print:
"Can't find your reference? Email us at wesleyconsults@gmail.com"
```

On tap "Restore Access":
1. Validate format — reference must start with `campusiq_` and be non-empty
2. In this phase: local validation only — trust the user's input, activate premium for the standard semester duration (4 months from today)
3. Call `SubscriptionRepository.activatePremium(plan: 'semester', txRef: input, expiresAt: ...)`
4. Invalidate `isPremiumProvider`
5. Show success snackbar: "Premium restored successfully"
6. Close the sheet

> **Note:** Phase 15 does not do server-side verification of the transaction reference. This is acceptable for early launch — the number of fraudulent attempts will be near zero at small scale. Server verification can be added in a future patch if needed.

---

### Support Email Deeplink

```dart
Future<void> _openSupportEmail() async {
  final uri = Uri(
    scheme: 'mailto',
    path: 'wesleyconsults@gmail.com',
    queryParameters: {
      'subject': 'CampusIQ Support',
      'body': 'Hi,\n\nI need help with CampusIQ.\n\n[Describe your issue here]',
    },
  );
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri);
  }
}
```

---

### `checkAndDowngrade()` on App Launch

In `app.dart` or `main.dart`, after Isar is open and before the widget tree builds:
```dart
final subscriptionRepo = SubscriptionRepository(isar);
await subscriptionRepo.checkAndDowngrade();
```

This handles expired subscriptions automatically every launch. If a monthly subscriber's 30 days are up, they are silently downgraded to free and will see the premium gates again.

---

### Session 2 Checkpoint

Commit: `feat(phase-15): account screen, subscription status, restore purchase, support email`

Verify:
- [ ] Account screen shows correct tier and expiry for both free and premium states
- [ ] Restore purchase with a valid-format reference activates premium immediately
- [ ] "Upgrade to Premium" button only shows for free users
- [ ] Support email link opens mail client with pre-filled subject and body
- [ ] `checkAndDowngrade()` runs on cold start — test by manually setting a past `expiresAt` in Isar
- [ ] Dev tools visible in debug mode, invisible in release builds (`flutter run --release` to test)
- [ ] `flutter analyze` clean

---

## Phase 15 Done — Final Commit

`feat: Phase 15 complete — subscription paywall, Paystack MoMo, account management`

Update `CLAUDE.md` with:
- Paystack initialisation in `main.dart`
- `PaystackService` location
- `checkAndDowngrade()` call location and importance
- `/account` route added
- Dev tools pattern (`kDebugMode`) used in account screen
- Dart-define keys: `PAYSTACK_PUBLIC_KEY`, `PAYSTACK_MONTHLY_PLAN`, `PAYSTACK_SEMESTER_PLAN`
