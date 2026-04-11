# CampusIQ — Phase 12: AI Infrastructure
## DeepSeek Client · Quota System · Subscription Model · AI Chat Screen

---

## Session Overview

**Phase:** 11 of 16  
**Sessions required:** 2  
**Depends on:** Phases 1–5 complete (MVP done)  
**Unlocks:** Phases 13–15 (all AI features depend on this phase)

**What this phase delivers:**
- DeepSeek API client (pure Dart, no Flutter deps)
- Context injection engine that reads live Isar data
- Daily AI usage quota system (enforces free tier limits)
- Subscription tier model stored in Isar
- AI chat screen with premium gate widget
- 5th tab added to bottom nav (AI / brain icon)
- `/subscribe` route stub (full paywall built in Phase 15)

**What this phase does NOT deliver:**
- Any specific AI feature (CWA coach, study plan, etc.) — those are Phases 12–14
- Real payment processing — subscription tier is local Isar only in this phase
- Server-side verification — comes in Phase 15

---

## Project Context

Read `CLAUDE.md` before starting. Key facts:
- Framework: Flutter, Dart, Riverpod (riverpod_annotation), Isar 3.x, GoRouter
- Architecture: `data/` → `domain/` → `presentation/` strictly enforced
- Domain layer: zero Flutter imports, pure Dart only
- State: Riverpod providers with `@riverpod` annotation + code generation
- Run `dart run build_runner build --delete-conflicting-outputs` after any Isar model or Riverpod annotation change
- Project lives at `/media/edwin/18FC2827FC28021C/projects/campusiq`

---

## Session 1 — Backend Wiring

### Goal
Build the full AI backend layer. No UI in this session. Everything in `lib/features/ai/`.

---

### 1. Folder Structure to Create

```
lib/features/ai/
├── data/
│   ├── models/
│   │   ├── ai_message_model.dart
│   │   ├── ai_message_model.g.dart        ← generated
│   │   ├── ai_usage_model.dart
│   │   └── ai_usage_model.g.dart          ← generated
│   └── repositories/
│       ├── ai_chat_repository.dart
│       └── ai_usage_repository.dart
└── domain/
    ├── context_builder.dart
    ├── deepseek_client.dart
    ├── deepseek_exception.dart
    └── prompt_templates.dart

lib/core/data/models/
└── subscription_model.dart                ← add here (core, not feature)
    subscription_model.g.dart              ← generated

lib/core/data/repositories/
└── subscription_repository.dart

lib/core/providers/
└── subscription_provider.dart
```

---

### 2. Add Dependency

Add to `pubspec.yaml` under `dependencies`:
```yaml
http: ^1.2.0
flutter_dotenv: ^5.1.0
```

Create `.env` in project root:
```
DEEPSEEK_API_KEY=your_key_here
```

Add `.env` to `pubspec.yaml` assets:
```yaml
flutter:
  assets:
    - .env
```

Add `.env` to `.gitignore` — do this before anything else.

Load in `main.dart` before `runApp`:
```dart
await dotenv.load(fileName: '.env');
```

---

### 3. `deepseek_exception.dart`

```dart
class DeepSeekException implements Exception {
  final String message;
  final int? statusCode;
  const DeepSeekException(this.message, {this.statusCode});

  @override
  String toString() => 'DeepSeekException($statusCode): $message';
}
```

---

### 4. `deepseek_client.dart`

Pure Dart. No Flutter imports. Responsibilities:
- Single public method: `Future<String> complete(...)`
- Handles HTTP 200 (parse response), 4xx/5xx (throw `DeepSeekException`)
- 30 second timeout
- Trims whitespace from response

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'deepseek_exception.dart';

class DeepSeekClient {
  final String apiKey;
  static const _baseUrl = 'https://api.deepseek.com/v1/chat/completions';
  static const _timeout = Duration(seconds: 30);

  const DeepSeekClient({required this.apiKey});

  Future<String> complete({
    required String systemPrompt,
    required List<Map<String, String>> messages,
    String model = 'deepseek-chat',
    int maxTokens = 800,
  }) async {
    final body = jsonEncode({
      'model': model,
      'max_tokens': maxTokens,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        ...messages,
      ],
    });

    final response = await http
        .post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: body,
        )
        .timeout(_timeout);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      return content.trim();
    } else {
      throw DeepSeekException(
        'API error: ${response.body}',
        statusCode: response.statusCode,
      );
    }
  }
}
```

---

### 5. `prompt_templates.dart`

Pure Dart. Static string templates used by `context_builder.dart`. Each feature in Phases 12–14 will add its own template here.

```dart
class PromptTemplates {
  PromptTemplates._();

  static const String basePersona = '''
You are an academic coach inside CampusIQ, a study app for Ghanaian university students.
Be concise, warm, and direct. Use plain English — no markdown formatting in your responses.
Do not repeat numbers the student can already see. Focus on advice, not description.
Limit responses to 3–4 sentences unless a list is genuinely needed.
''';

  static String withContext(String context) => '$basePersona\n$context';
}
```

---

### 6. `context_builder.dart`

Pure Dart. Injected with repositories. Reads live Isar data and assembles a plain-text system prompt context block.

Constructor parameters (inject all repositories needed):
- `CwaRepository`
- `SessionRepository`  
- `StreakCalculator` (or read from `StudySessionModel` directly)
- `TimetableRepository`
- `UserPrefsRepository`

Method: `Future<String> buildAcademicContext()`

Output format (plain text, under 600 tokens):
```
Student context:
- University: KNUST | Programme: Computer Engineering
- Courses: EE 301 (3cr, target 78, projected 72), MATH 251 (2cr, target 65, projected 68)
- Projected CWA: 2.87 | Target CWA: 3.0 | Gap: 0.13 points to go
- Study streak: 14 days (alive) | Longest ever: 21 days
- This week: 12.5 hours studied | Most studied: EE 301 (4.2hr)
- Today's free blocks: 10am–12pm, 4pm–6pm
- Today's classes: EE 301 Lecture 8–10am, MATH 251 Tutorial 2–4pm
```

Implementation notes:
- If no courses exist, omit the course and CWA lines
- If no sessions this week, write "No sessions logged this week yet"
- If streak is 0, write "No active streak"
- Pull today's free blocks using the existing `FreeTimeDetector` domain class
- University and programme come from `UserPrefsModel` (will be set in Phase 16 onboarding — for now default to "KNUST" if not set)
- Keep output concise — do not dump every session record

---

### 7. Isar Models

#### `ai_message_model.dart`

```dart
import 'package:isar/isar.dart';
part 'ai_message_model.g.dart';

@collection
class AiMessageModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String feature; // 'chat' | 'insight' | 'plan' | 'examprep' | 'coach'

  late String role;    // 'user' | 'assistant'
  late String content;
  late DateTime createdAt;
}
```

#### `ai_usage_model.dart`

```dart
import 'package:isar/isar.dart';
part 'ai_usage_model.g.dart';

@collection
class AiUsageModel {
  Id id = Isar.autoIncrement;

  @Index(composite: [CompositeIndex('feature')])
  late String date;    // 'yyyy-MM-dd' format

  late String feature; // 'chat' | 'whatif' | 'insight'
  late int count;
}
```

#### `subscription_model.dart` (goes in `lib/core/data/models/`)

```dart
import 'package:isar/isar.dart';
part 'subscription_model.g.dart';

@collection
class SubscriptionModel {
  Id id = 1; // always 1 — single row document pattern

  late String tier;       // 'free' | 'premium'
  String? expiresAt;      // ISO 8601 date string — null means no expiry set
  String? purchasedAt;    // ISO 8601
  String? transactionRef; // Paystack ref — stored for Phase 15 verification
  String? plan;           // 'monthly' | 'semester'
}
```

After creating all three models, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

### 8. Repositories

#### `ai_usage_repository.dart`

```dart
class AiUsageRepository {
  final Isar _isar;
  AiUsageRepository(this._isar);

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  Future<int> getUsageToday(String feature) async {
    final record = await _isar.aiUsageModels
        .filter()
        .dateEqualTo(_today())
        .featureEqualTo(feature)
        .findFirst();
    return record?.count ?? 0;
  }

  Future<void> incrementUsage(String feature) async {
    final today = _today();
    await _isar.writeTxn(() async {
      final record = await _isar.aiUsageModels
          .filter()
          .dateEqualTo(today)
          .featureEqualTo(feature)
          .findFirst();
      if (record == null) {
        await _isar.aiUsageModels.put(
          AiUsageModel()
            ..date = today
            ..feature = feature
            ..count = 1,
        );
      } else {
        record.count++;
        await _isar.aiUsageModels.put(record);
      }
    });
  }

  Future<bool> isUnderLimit(String feature, int freeLimit) async {
    final usage = await getUsageToday(feature);
    return usage < freeLimit;
  }
}
```

#### `ai_chat_repository.dart`

```dart
class AiChatRepository {
  final Isar _isar;
  AiChatRepository(this._isar);

  Future<List<AiMessageModel>> getMessages(String feature) async {
    return _isar.aiMessageModels
        .filter()
        .featureEqualTo(feature)
        .sortByCreatedAt()
        .findAll();
  }

  Future<void> saveMessage(AiMessageModel message) async {
    await _isar.writeTxn(() => _isar.aiMessageModels.put(message));
  }

  Future<void> clearHistory(String feature) async {
    await _isar.writeTxn(() async {
      final ids = await _isar.aiMessageModels
          .filter()
          .featureEqualTo(feature)
          .idProperty()
          .findAll();
      await _isar.aiMessageModels.deleteAll(ids);
    });
  }
}
```

#### `subscription_repository.dart` (in `lib/core/data/repositories/`)

```dart
class SubscriptionRepository {
  final Isar _isar;
  SubscriptionRepository(this._isar);

  Future<SubscriptionModel> getSubscription() async {
    return await _isar.subscriptionModels.get(1) ??
        (SubscriptionModel()
          ..id = 1
          ..tier = 'free');
  }

  Future<bool> isPremium() async {
    final sub = await getSubscription();
    if (sub.tier != 'premium') return false;
    if (sub.expiresAt == null) return true;
    return DateTime.parse(sub.expiresAt!).isAfter(DateTime.now());
  }

  Future<void> activatePremium({
    required String plan,
    required String transactionRef,
    required DateTime expiresAt,
  }) async {
    final sub = SubscriptionModel()
      ..id = 1
      ..tier = 'premium'
      ..plan = plan
      ..transactionRef = transactionRef
      ..purchasedAt = DateTime.now().toIso8601String()
      ..expiresAt = expiresAt.toIso8601String();
    await _isar.writeTxn(() => _isar.subscriptionModels.put(sub));
  }

  Future<void> checkAndDowngrade() async {
    final sub = await getSubscription();
    if (sub.tier == 'premium' && sub.expiresAt != null) {
      if (DateTime.parse(sub.expiresAt!).isBefore(DateTime.now())) {
        final downgraded = SubscriptionModel()
          ..id = 1
          ..tier = 'free';
        await _isar.writeTxn(() => _isar.subscriptionModels.put(downgraded));
      }
    }
  }

  // DEV ONLY — remove before Play Store release
  Future<void> devSetPremium(bool premium) async {
    final sub = SubscriptionModel()
      ..id = 1
      ..tier = premium ? 'premium' : 'free'
      ..expiresAt = premium
          ? DateTime.now().add(const Duration(days: 365)).toIso8601String()
          : null;
    await _isar.writeTxn(() => _isar.subscriptionModels.put(sub));
  }
}
```

---

### 9. Riverpod Providers

#### `subscription_provider.dart` (in `lib/core/providers/`)

```dart
@riverpod
Future<SubscriptionRepository> subscriptionRepository(Ref ref) async {
  final isar = await ref.watch(isarProvider.future);
  return SubscriptionRepository(isar);
}

@riverpod
Future<bool> isPremium(Ref ref) async {
  final repo = await ref.watch(subscriptionRepositoryProvider.future);
  return repo.isPremium();
}
```

Add providers for `AiUsageRepository`, `AiChatRepository`, `DeepSeekClient`, and `ContextBuilder` in `lib/features/ai/presentation/providers/ai_providers.dart`:

```dart
@riverpod
Future<DeepSeekClient> deepseekClient(Ref ref) async {
  final key = dotenv.env['DEEPSEEK_API_KEY'] ?? '';
  if (key.isEmpty) throw Exception('DEEPSEEK_API_KEY not set in .env');
  return DeepSeekClient(apiKey: key);
}

@riverpod
Future<AiUsageRepository> aiUsageRepository(Ref ref) async {
  final isar = await ref.watch(isarProvider.future);
  return AiUsageRepository(isar);
}

@riverpod
Future<AiChatRepository> aiChatRepository(Ref ref) async {
  final isar = await ref.watch(isarProvider.future);
  return AiChatRepository(isar);
}

@riverpod
Future<ContextBuilder> contextBuilder(Ref ref) async {
  // Inject all needed repositories
  final isar = await ref.watch(isarProvider.future);
  return ContextBuilder(
    cwaRepository: CwaRepository(isar),
    sessionRepository: SessionRepository(isar),
    timetableRepository: TimetableRepository(isar),
    userPrefsRepository: UserPrefsRepository(isar),
  );
}
```

Run build_runner after all providers are annotated.

---

### Session 1 Checkpoint
Commit: `feat(phase-12): AI backend — DeepSeek client, context builder, usage quota, subscription model`

Verify before committing:
- [ ] `.env` is in `.gitignore`
- [ ] `dart run build_runner build --delete-conflicting-outputs` runs clean
- [ ] `flutter analyze` shows no errors
- [ ] `SubscriptionModel`, `AiMessageModel`, `AiUsageModel` all appear in `IsarProvider` collection list

---

## Session 2 — AI Chat Screen + Premium Gate

### Goal
Build the visible AI tab. Wire everything from Session 1 into a working chat UI.

---

### 1. New Files

```
lib/features/ai/presentation/
├── providers/
│   ├── ai_chat_provider.dart
│   └── ai_usage_provider.dart
├── screens/
│   └── ai_chat_screen.dart
└── widgets/
    ├── ai_message_bubble.dart
    ├── ai_typing_indicator.dart
    ├── premium_gate_widget.dart
    └── usage_counter_chip.dart
```

---

### 2. `ai_chat_provider.dart`

State class:
```dart
class AiChatState {
  final List<AiMessageModel> messages;
  final bool isLoading;
  final String? error;
  final bool isAtLimit;

  const AiChatState({
    this.messages = const [],
    this.isLoading = false,
    this.error,
    this.isAtLimit = false,
  });

  AiChatState copyWith({...});
}
```

Notifier responsibilities:
- `Future<void> loadHistory()` — loads from Isar on init
- `Future<void> sendMessage(String userText)`:
  1. Check `isUnderLimit('chat', 3)` — if false, set `isAtLimit = true` and return
  2. Check `isPremium` — if true, skip limit check
  3. Save user message to Isar
  4. Set `isLoading = true`
  5. Build context via `ContextBuilder`
  6. Build messages list from history (last 6 messages max — keep token usage low)
  7. Call `DeepSeekClient.complete()`
  8. Save assistant response to Isar
  9. Increment usage counter
  10. Set `isLoading = false`
  11. On error: set `error` field, set `isLoading = false`

---

### 3. `ai_usage_provider.dart`

Simple provider that exposes today's usage count and remaining count for a feature.

```dart
@riverpod
Future<int> aiUsageToday(Ref ref, String feature) async {
  final repo = await ref.watch(aiUsageRepositoryProvider.future);
  return repo.getUsageToday(feature);
}

@riverpod
Future<int> aiUsageRemaining(Ref ref, String feature, int limit) async {
  final used = await ref.watch(aiUsageTodayProvider(feature).future);
  return (limit - used).clamp(0, limit);
}
```

---

### 4. `ai_chat_screen.dart`

`ConsumerStatefulWidget`. Layout (bottom to top):
- **Input row** at bottom: `TextField` + send `IconButton`
- **Usage counter chip** above input (hidden for premium users)
- **Message list** — `ListView.builder` in reverse, newest at bottom
- **Typing indicator** — shows when `isLoading == true`
- **Premium gate** — inline card that replaces the input row when `isAtLimit == true` and user is not premium

Behaviour:
- On `initState`: call `loadHistory()`
- `TextField` disabled while `isLoading == true`
- On send: clear the text field immediately, then call `sendMessage()`
- Scroll to bottom after new message is added
- Show `SnackBar` if `state.error` is not null
- `AppBar` title: "AI Coach" with a small "BETA" badge

Premium users see no usage chip and no gate — the input is always available.

---

### 5. `ai_message_bubble.dart`

```
User messages:   right-aligned, primary color background
Assistant msgs:  left-aligned, surface color background, slightly rounded differently
Timestamp:       small text below each bubble in muted color
```

---

### 6. `usage_counter_chip.dart`

Small pill-shaped chip. Examples:
- "3 messages left today" — green text
- "1 message left today" — amber text  
- "0 messages left — upgrade for unlimited" — red text, tappable → navigate to `/subscribe`

Takes `remaining` and `limit` as parameters.

---

### 7. `premium_gate_widget.dart`

Renders when free user hits their limit. NOT a dialog — it replaces the input area inline.

Content:
```
[lock icon]
You've used your 3 free messages today.

Premium unlocks:
• Unlimited AI coach messages
• Weekly personalized study plan
• Exam prep question generator
• Smart streak coaching

GHS 20/month · GHS 120/semester

[Upgrade to Premium →]  ← navigates to /subscribe
```

Style: card with a subtle border, no aggressive colors.

---

### 8. `ai_typing_indicator.dart`

Three animated dots (use `flutter_animate` package already in project). Styled to look like an assistant message bubble with dots inside.

---

### 9. Router + Nav Updates (`app_router.dart`)

Add `/ai` route:
```dart
GoRoute(
  path: '/ai',
  builder: (context, state) => const AiChatScreen(),
),
GoRoute(
  path: '/subscribe',
  builder: (context, state) => const SubscribeScreenStub(),
),
```

Add to `ShellRoute` bottom nav bar — 5th tab:
- Icon: `Icons.auto_awesome_outlined` (when inactive) / `Icons.auto_awesome` (active)
- Label: "AI Coach"

**`SubscribeScreenStub`** — minimal placeholder screen:
```dart
class SubscribeScreenStub extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Upgrade to Premium')),
    body: const Center(
      child: Text('Subscription coming soon.\nContact: wesleyconsults@gmail.com'),
    ),
  );
}
```

This stub is replaced fully in Phase 15.

---

### 10. Register New Isar Collections

In `lib/core/providers/isar_provider.dart`, add the three new collections to the `Isar.open()` call:
```dart
schemas: [
  // existing schemas...
  AiMessageModelSchema,
  AiUsageModelSchema,
  SubscriptionModelSchema,
],
```

Also call `subscriptionRepository.checkAndDowngrade()` in `app.dart` or `main.dart` during app startup (after Isar is open, before the widget tree builds).

---

### Session 2 Checkpoint
Commit: `feat(phase-12): AI chat screen, premium gate, usage counter, bottom nav update`

Verify before committing:
- [ ] AI tab visible in bottom nav
- [ ] Chat sends and receives messages successfully (test with real DeepSeek key)
- [ ] Usage counter decrements correctly (starts at 3, counts down)
- [ ] Premium gate appears after 3rd message and blocks input
- [ ] History loads correctly on screen re-open
- [ ] `/subscribe` stub navigates without crash
- [ ] `flutter analyze` clean

---

## Phase 12 Done — Final Commit
`feat: Phase 12 complete — AI infrastructure, DeepSeek client, chat screen, subscription model`

Update `CLAUDE.md` with:
- DeepSeek client location and usage pattern
- Context builder location
- Subscription tier reading pattern (`ref.watch(isPremiumProvider)`)
- Usage quota checking pattern
- New Isar collections added
- New routes added
