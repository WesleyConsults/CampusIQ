import 'package:isar/isar.dart';
import '../models/subscription_model.dart';

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
