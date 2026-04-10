import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:campusiq/core/providers/isar_provider.dart';
import 'package:campusiq/core/data/repositories/subscription_repository.dart';

part 'subscription_provider.g.dart';

@riverpod
Future<SubscriptionRepository> subscriptionRepository(Ref ref) async {
  final isar = await ref.watch(isarProvider.future);
  return SubscriptionRepository(isar);
}

@riverpod
Future<bool> isPremium(Ref ref) async {
  final repo = await ref.watch(subscriptionRepositoryProvider.future);
  return await repo.isPremium();
}
