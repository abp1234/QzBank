import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/question.dart';

class MarkdownParser {
  static final RegExp pattern = RegExp(r'\*\*(.+?)\*\*');

  static Future<List<Question>> parseQuestionsFromMarkdown(String assetPath) async {
    final content = await rootBundle.loadString(assetPath);
    final lines = const LineSplitter().convert(content);

    List<Question> questions = [];

    for (final line in lines) {
      if (!line.trim().startsWith('- ')) continue;

      final match = pattern.firstMatch(line);
      if (match != null) {
        final answer = match.group(1)!;
        final questionText = line.replaceFirst(pattern, '____').substring(2).trim();
        questions.add(Question(questionText: questionText, answer: answer));
      }
    }

    return questions;
  }
}
