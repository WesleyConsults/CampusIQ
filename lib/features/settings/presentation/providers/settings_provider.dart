import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:campusiq/core/data/models/user_prefs_model.dart';
import 'package:campusiq/features/streak/presentation/providers/streak_provider.dart';

/// Exposes the full UserPrefsModel so the settings screen can read toggle states.
final notificationPrefsProvider = FutureProvider<UserPrefsModel>((ref) async {
  final repo = ref.watch(userPrefsRepositoryProvider);
  if (repo == null) return UserPrefsModel();
  return repo.getPrefs();
});

/// Maps the persisted theme mode index (0=system, 1=light, 2=dark) to ThemeMode.
final themeModeProvider = FutureProvider<ThemeMode>((ref) async {
  final repo = ref.watch(userPrefsRepositoryProvider);
  if (repo == null) return ThemeMode.system;
  final index = await repo.getThemeModeIndex();
  switch (index) {
    case 0:
      return ThemeMode.system;
    case 2:
      return ThemeMode.dark;
    default:
      return ThemeMode.light;
  }
});
