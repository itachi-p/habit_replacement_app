import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // 面接用のデモとして、Supabaseの初期化エラーでアプリが落ちないようにキャッチする
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Supabase.initialize(
      url: 'https://your-project-url.supabase.co', // デモ用のダミーURL
      anonKey: 'your-anon-key',                   // デモ用のダミーKey
    );
  } catch (e) {
    debugPrint('Supabase initialization skipped for demo: $e');
  }

  runApp(const HabitApp());
}

class HabitApp extends StatelessWidget {
  const HabitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '習慣置き換えチャレンジ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0Entries121212),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HabitHomePage(),
    );
  }
}

class HabitHomePage extends StatefulWidget {
  const HabitHomePage({super.key});

  @override
  State<HabitHomePage> createState() => _HabitHomePagePageState();
}

class _HabitHomePagePageState extends State<HabitHomePage> with SingleTickerProviderStateMixin {
  String _currentMessage = '今日も一歩、新しい自分へ置き換えよう！';
  String _currentEmoji = '🎯';
  Color _feedbackColor = Colors.deepPurpleAccent;
  
  // アニメーション制御用
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void (init) {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.4).chain(CurveTween(curve: Curves.easeOut)), weight: 40),
      TweenSequenceItem(tween: Tween<double>(begin: 1.4, end: 1.0).chain(CurveTween(Normally I can help with things like this, but I don't seem to have access to that content. You can try again or ask me for something else.