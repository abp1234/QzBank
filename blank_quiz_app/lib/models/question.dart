class Question {
  final String questionText;
  final String answer;
  String? userAnswer;

  Question({
    required this.questionText,
    required this.answer,
    this.userAnswer,
  });
}
