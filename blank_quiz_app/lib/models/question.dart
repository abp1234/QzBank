class Question {
  final int id;
  final String questionText;
  final String answer;
  String? userAnswer;

  Question({
    required this.id,
    required this.questionText,
    required this.answer,
    this.userAnswer,
  });

  factory Question.fromMap(Map<String, dynamic> map){
    return Question(
      id:map['id'],
      questionText:map['question_text'],
      answer:map['answer'],
    );
  }
}
