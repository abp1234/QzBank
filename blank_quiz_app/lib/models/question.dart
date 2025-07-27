class Question {
  final int id;
  final String questionText;
  final String answer;
  final String category;
  final String createdAt;
  String? userAnswer;

  Question({
    required this.id,
    required this.questionText,
    required this.answer,
    required this.category,
    required this.createdAt,
    this.userAnswer,
  });

  factory Question.fromJson(Map<String, dynamic> json){
    return Question(
      id: json['id'] ?? 0,
      questionText: json['question'] ?? '',
      answer: json['answer'] ?? '',
      category: json['category'] ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }factory Question.fromMap(Map<String, dynamic> map) {
    return Question.fromJson(map);
  }
}
