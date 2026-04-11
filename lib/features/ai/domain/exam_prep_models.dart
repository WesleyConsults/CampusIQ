// Ephemeral value objects — held in provider state only, never persisted.

sealed class ExamQuestion {
  const ExamQuestion();
}

class McqQuestion extends ExamQuestion {
  final String question;
  final List<String> options;
  final String answer; // 'A' | 'B' | 'C' | 'D'
  final String explanation;

  const McqQuestion({
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
  });
}

class ShortAnswerQuestion extends ExamQuestion {
  final String question;
  final String answer;

  const ShortAnswerQuestion({required this.question, required this.answer});
}

class FlashCard extends ExamQuestion {
  final String front;
  final String back;

  const FlashCard({required this.front, required this.back});
}

class ExamPrepRequest {
  final String courseCode;
  final String courseName;
  final String questionType; // 'mcq' | 'short' | 'flash'
  final String? topic;
  final int count;

  const ExamPrepRequest({
    required this.courseCode,
    required this.courseName,
    required this.questionType,
    this.topic,
    this.count = 5,
  });
}
