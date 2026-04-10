import 'package:isar/isar.dart';
part 'subscription_model.g.dart';

@collection
class SubscriptionModel {
  Id id = 1; // always 1 — single row document pattern

  late String tier; // 'free' | 'premium'
  String? expiresAt; // ISO 8601 date string — null means no expiry set
  String? purchasedAt; // ISO 8601
  String? transactionRef; // Paystack ref — stored for Phase 15 verification
  String? plan; // 'monthly' | 'semester'
}
