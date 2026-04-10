import 'package:isar/isar.dart';
import '../models/ai_message_model.dart';

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
