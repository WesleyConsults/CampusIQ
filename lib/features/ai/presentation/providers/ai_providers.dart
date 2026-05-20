import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/features/cwa/data/repositories/cwa_repository.dart';
import 'package:campusiq/features/session/data/repositories/session_repository.dart';
import 'package:campusiq/features/timetable/data/repositories/timetable_repository.dart';
import 'package:campusiq/core/data/repositories/user_prefs_repository.dart';
import 'package:campusiq/features/ai/domain/deepseek_client.dart';
import 'package:campusiq/features/ai/domain/context_builder.dart';

part 'ai_providers.g.dart';

@riverpod
Future<DeepSeekClient> deepseekClient(Ref ref) async {
  return const DeepSeekClient();
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
