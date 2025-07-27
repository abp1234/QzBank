import 'package:flutter/material.dart';
import 'screens/quiz_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url:'https://whjnhhxnundpbuvtqhba.supabase.co/',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indoam5oaHhudW5kcGJ1dnRxaGJhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM2MTgyMTMsImV4cCI6MjA2OTE5NDIxM30.0rBgFxKgaotNny1MIQElxJIOhrCDQWbO5FhhpRTOBKI',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: QuizScreen(),
    );
  }
}
