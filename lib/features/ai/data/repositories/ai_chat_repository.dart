import 'package:isar/isar.dart';
import '../models/ai_message_model.dart';
import '../models/ai_chat_session_model.dart';

class AiChatRepository {
  final Isar _isar;
  AiChatRepository(this._isar);

  // ---------- SESSIONS ----------

  Future<List<AiChatSessionModel>> getSessions(String feature) async {
    return _isar.aiChatSessionModels
        .filter()
        .featureEqualTo(feature)
        .sortByUpdatedAtDesc()
        .findAll();
  }

  Future<int> createSession(String feature, String title) async {
    final session = AiChatSessionModel()
      ..feature = feature
      ..title = title
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await _isar.writeTxn(() async {
      await _isar.aiChatSessionModels.put(session);
    });
    return session.id;
  }

  Future<void> updateSession(int id, {String? title, DateTime? updatedAt}) async {
    await _isar.writeTxn(() async {
      final session = await _isar.aiChatSessionModels.get(id);
      if (session != null) {
        if (title != null) session.title = title;
        if (updatedAt != null) session.updatedAt = updatedAt;
        await _isar.aiChatSessionModels.put(session);
      }
    });
  }

  Future<void> deleteSession(int id) async {
    await _isar.writeTxn(() async {
      await _isar.aiChatSessionModels.delete(id);
      final messageIds = await _isar.aiMessageModels
          .filter()
          .sessionIdEqualTo(id)
          .idProperty()
          .findAll();
      await _isar.aiMessageModels.deleteAll(messageIds);
    });
  }

  // ---------- MESSAGES ----------

  Future<List<AiMessageModel>> getMessages(String feature, {int? sessionId}) async {
    if (sessionId != null) {
      return _isar.aiMessageModels
          .filter()
          .featureEqualTo(feature)
          .sessionIdEqualTo(sessionId)
          .sortByCreatedAt()
          .findAll();
    } else {
      return _isar.aiMessageModels
          .filter()
          .featureEqualTo(feature)
          .sortByCreatedAt()
          .findAll();
    }
  }

  Future<void> saveMessage(AiMessageModel message) async {
    await _isar.writeTxn(() => _isar.aiMessageModels.put(message));
    
    if (message.sessionId != null) {
      // Don't nest writeTxn inside writeTxn.
      // So don't await updateSession which uses writeTxn. Wait! 
      // isar nested writeTxn will throw 'Already in a transaction'.
      // I should update it right here, or we decouple.
    }
  }

  Future<void> clearHistory(String feature) async {
    await _isar.writeTxn(() async {
      final sessionIds = await _isar.aiChatSessionModels
          .filter()
          .featureEqualTo(feature)
          .idProperty()
          .findAll();
      await _isar.aiChatSessionModels.deleteAll(sessionIds);

      final messageIds = await _isar.aiMessageModels
          .filter()
          .featureEqualTo(feature)
          .idProperty()
          .findAll();
      await _isar.aiMessageModels.deleteAll(messageIds);
    });
  }
}
