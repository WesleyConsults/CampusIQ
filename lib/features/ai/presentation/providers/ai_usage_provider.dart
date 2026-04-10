import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ai_providers.dart';

final aiUsageTodayProvider = FutureProvider.family<int, String>((ref, feature) async {
  final repo = await ref.watch(aiUsageRepositoryProvider.future);
  return repo.getUsageToday(feature);
});

final aiUsageRemainingProvider =
    FutureProvider.family<int, (String, int)>((ref, args) async {
  final (feature, limit) = args;
  final used = await ref.watch(aiUsageTodayProvider(feature).future);
  return (limit - used).clamp(0, limit);
});
