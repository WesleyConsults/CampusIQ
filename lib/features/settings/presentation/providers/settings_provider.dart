import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

/// Exposes the full UserPrefsModel so the settings screen can read toggle states.
final notificationPrefsProvider =
    FutureProvider<UserPrefsModel>((ref) async {
  final repo = ref.watch(userPrefsRepositoryProvider);
  if (repo == null) return UserPrefsModel(); // safe default
  return repo.getPrefs();
});
