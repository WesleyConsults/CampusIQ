import 'package:isar/isar.dart';

part 'ai_chat_session_model.g.dart';

@collection
class AiChatSessionModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String feature; // 'chat' | 'insight' etc
  
  late String title;
  
  late DateTime createdAt;
  
  @Index()
  late DateTime updatedAt;
}
