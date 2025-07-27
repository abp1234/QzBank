import 'package:flutter/material.dart';
//import '../utils/md_parser.dart';
import '../models/question.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}
//test

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  bool _isLoading = true;
  bool _showResult = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    //loadQuestions();
    loadQuestionsFromSupabase("네트워크");
  }

  // Future<void> loadQuestions() async {
  //   final qList =
  //       await MarkdownParser.parseQuestionsFromMarkdown('assets/summary.md');
  //   setState(() {
  //     _questions = qList;
  //     _isLoading = false;
  //   });
  // }

  Future<void> loadQuestionsFromSupabase(String category) async {
  try {
    final data = await Supabase.instance.client
        .from('questions')
        .select()
        .eq('category', category);
    print('***** Supabase query result: $data');
    setState(() {
      _questions = List<Map<String, dynamic>>.from(data)
        .map((e)=>Question.fromMap(e))
        .toList();
      _isLoading = false;
    });
  } catch (e) {
    print('질문 로딩 오류: $e');
    setState(() {
      _isLoading = false; // <- 실패해도 로딩 해제
    });
    // 필요 시 _isLoading false 처리 또는 오류 상태 반영
  }
}


  void _submitAnswers() {
    int correct = 0;
    for (var q in _questions) {
      if (q.userAnswer != null &&
          q.userAnswer!.trim().toLowerCase() == q.answer.toLowerCase()) {
        correct++;
      }else{
        markWrong(q.id);
      }
    }
    setState(() {
      _score = correct;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('빈칸 퀴즈')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
                final isCorrect = q.userAnswer?.trim().toLowerCase() ==
                    q.answer.toLowerCase();

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. ${q.questionText}',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          enabled: !_showResult,
                          decoration: InputDecoration(
                            labelText: '정답을 입력하세요',
                            border: const OutlineInputBorder(),
                            suffixIcon: _showResult
                                ? Icon(
                                    isCorrect ? Icons.check : Icons.close,
                                    color: isCorrect
                                        ? Colors.green
                                        : Colors.red,
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            q.userAnswer = value;
                          },
                        ),
                        if (_showResult && !isCorrect)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              '정답: ${q.answer}',
                              style: const TextStyle(
                                  color: Colors.blueGrey, fontSize: 14),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: _showResult ? null : _submitAnswers,
            child: const Text('정답 확인'),
          ),
          if (_showResult)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '정답 수: $_score / ${_questions.length}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}

Future<void> markWrong(int id) async{
  try{
    await Supabase.instance.client
        .from('questions')
        .update({'is_wrong':true})
        .eq('id',id);
  }catch(e){
    print('오답 저장 실패: $e');
  }
}