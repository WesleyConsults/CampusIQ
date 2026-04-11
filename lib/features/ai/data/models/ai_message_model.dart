import 'package:isar/isar.dart';
part 'ai_message_model.g.dart';

@collection
class AiMessageModel {
  Id id = Isar.autoIncrement;

  @Index()
  late String feature; // 'chat' | 'insight' | 'plan' | 'examprep' | 'coach'

  @Index()
  int? sessionId;

  late String role; // 'user' | 'assistant'
  late String content;
  late DateTime createdAt;
}
