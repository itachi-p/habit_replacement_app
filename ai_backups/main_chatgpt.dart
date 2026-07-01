// main.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const supabaseUrl = 'https://YOUR_PROJECT.supabase.co';
const supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const HabitChallengeApp());
}

class HabitChallengeApp extends StatelessWidget {
  const HabitChallengeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3週間 新習慣置き換えチャレンジ',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.teal,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.teal,
        scaffoldBackgroundColor: const Color(0xff0F172A),
      ),
      home: const HabitHomePage(),
    );
  }
}

enum HabitGrade {
  pine,
  bamboo,
  plum,
}

class HabitHomePage extends StatefulWidget {
  const HabitHomePage({super.key});

  @override
  State<HabitHomePage> createState() => _HabitHomePageState();
}

class _HabitHomePageState extends State<HabitHomePage>
    with TickerProviderStateMixin {
  final client = Supabase.instance.client;

  late AnimationController _burstController;
  late AnimationController _messageController;

  late Animation<double> _burstScale;
  late Animation<double> _burstOpacity;
  late Animation<double> _messageScale;

  HabitGrade? selected;

  String emoji = "🎉";
  String message = "今日も一歩前進！";

  final Random random = Random();

  final List<_Particle> particles = [];

  int currentDay = 9;
  double completionRate = 0.75;

  @override
  void initState() {
    super.initState();

    _burstController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _messageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    _burstScale = CurvedAnimation(
      parent: _burstController,
      curve: Curves.elasticOut,
    );

    _burstOpacity = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _burstController,
        curve: const Interval(0.55, 1),
      ),
    );

    _messageScale = CurvedAnimation(
      parent: _messageController,
      curve: Curves.elasticOut,
    );

    for (int i = 0; i < 18; i++) {
      particles.add(_Particle(random));
    }
  }

  @override
  void dispose() {
    _burstController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> saveLog(
    HabitGrade grade,
    String message,
  ) async {
    try {
      await client.from('habit_logs').insert({
        'date': DateTime.now().toIso8601String(),
        'grade': switch (grade) {
          HabitGrade.pine => '松',
          HabitGrade.bamboo => '竹',
          HabitGrade.plum => '梅',
        },
        'message': message,
      });
    } catch (_) {
      // 面接用プロトタイプなので握りつぶす
    }
  }

  Future<void> onPressed(HabitGrade grade) async {
    switch (grade) {
      case HabitGrade.pine:
        emoji = "🎉";
        message = "最高！今日のあなたは新習慣マスター！";
        break;

      case HabitGrade.bamboo:
        emoji = "🌟";
        message = "ナイス！意識できた積み重ねが未来を変える！";
        break;

      case HabitGrade.plum:
        emoji = "💪";
        message = "気づけただけで十分すごい！次の一歩へ行こう！";
        break;
    }

    setState(() {
      selected = grade;
      for (final p in particles) {
        p.reset(random);
      }
    });

    _burstController.forward(from: 0);
    _messageController.forward(from: 0);

    await saveLog(grade, message);
  }

  Color gradeColor(HabitGrade grade) {
    switch (grade) {
      case HabitGrade.pine:
        return Colors.amber;
      case HabitGrade.bamboo:
        return Colors.greenAccent;
      case HabitGrade.plum:
        return Colors.pinkAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = currentDay / 21;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xff0F172A),
                  Color(0xff111827),
                  Color(0xff1E293B),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          AnimatedBuilder(
            animation: _burstController,
            builder: (_, __) {
              return IgnorePointer(
                child: Stack(
                  children: particles.map((p) {
                    return Positioned(
                      left: MediaQuery.of(context).size.width / 2 +
                          p.dx * _burstController.value,
                      top: MediaQuery.of(context).size.height / 2 +
                          p.dy * _burstController.value,
                      child: Opacity(
                        opacity: 1 - _burstController.value,
                        child: Transform.rotate(
                          angle: _burstController.value * pi * 4,
                          child: Text(
                            p.emoji,
                            style: TextStyle(
                              fontSize: 24 + p.size,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Card(
                        elevation: 10,
                        color: Colors.white.withOpacity(.06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Text(
                                "3週間 新習慣置き換えチャレンジ",
                                style: TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "現在 ${currentDay}日目  /  継続率 ${(completionRate * 100).round()}%",
                                style: TextStyle(
                                  color: Colors.grey.shade300,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: LinearProgressIndicator(
                                  value: progress,
                                  minHeight: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      SizedBox(
                        height: 150,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            FadeTransition(
                              opacity: _burstOpacity,
                              child: ScaleTransition(
                                scale: _burstScale,
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 82),
                                ),
                              ),
                            ),
                            ScaleTransition(
                              scale: _messageScale,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 18),
                                child: Text(
                                  message,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(),

                      buildButton(
                        HabitGrade.pine,
                        "🌲 松",
                        "完璧に置き換えた！",
                      ),

                      const SizedBox(height: 16),

                      buildButton(
                        HabitGrade.bamboo,
                        "🎋 竹",
                        "意識して行動できた！",
                      ),

                      const SizedBox(height: 16),

                      buildButton(
                        HabitGrade.plum,
                        "🌸 梅",
                        "つい悪習慣が出たが、気づけた！",
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(
    HabitGrade grade,
    String title,
    String subtitle,
  ) {
    final active = selected == grade;

    return AnimatedScale(
      scale: active ? 1.03 : 1,
      duration: const Duration(milliseconds: 250),
      child: SizedBox(
        width: double.infinity,
        height: 88,
        child: FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: gradeColor(grade),
            foregroundColor: Colors.black,
            elevation: active ? 12 : 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          onPressed: () => onPressed(grade),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Particle {
  late double dx;
  late double dy;
  late double size;
  late String emoji;

  static const emojis = [
    "✨",
    "🎉",
    "🌟",
    "💪",
    "🎈",
    "💚",
    "🧡",
    "💙",
    "💛",
    "🥳",
  ];

  _Particle(Random random) {
    reset(random);
  }

  void reset(Random random) {
    final angle = random.nextDouble() * pi * 2;
    final radius = 70 + random.nextDouble() * 180;

    dx = cos(angle) * radius;
    dy = sin(angle) * radius;

    size = random.nextDouble() * 12;
    emoji = emojis[random.nextInt(emojis.length)];
  }
}