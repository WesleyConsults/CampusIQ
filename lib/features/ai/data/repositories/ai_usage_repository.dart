import 'package:isar/isar.dart';
import '../models/ai_usage_model.dart';

class AiUsageRepository {
  final Isar _isar;
  AiUsageRepository(this._isar);

  String _today() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
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
