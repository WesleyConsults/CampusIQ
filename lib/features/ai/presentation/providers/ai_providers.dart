import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/data/repositories/cwa_repository.dart';
import 'package:campusiq/features/session/data/repositories/session_repository.dart';
import 'package:campusiq/features/timetable/data/repositories/timetable_repository.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/features/ai/domain/deepseek_client.dart';
import 'package:campusiq/features/ai/domain/context_builder.dart';
import 'package:campusiq/features/ai/data/repositories/ai_usage_repository.dart';
import 'package:campusiq/features/ai/data/repositories/ai_chat_repository.dart';

part 'ai_providers.g.dart';

@riverpod
Future<DeepSeekClient> deepseekClient(Ref ref) async {
  final key = dotenv.env['DEEPSEEK_API_KEY'] ?? '';
  if (key.isEmpty) throw Exception('DEEPSEEK_API_KEY not set in .env');
  final model = dotenv.env['DEEPSEEK_MODEL'] ?? 'deepseek-chat';
  return DeepSeekClient(apiKey: key, model: model);
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
