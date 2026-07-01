// main.dart
// Flutter (Web / Mobile) - 3週間習慣置き換えチャレンジ - 単一ファイル完結プロトタイプ
//
// pubspec.yaml 依存関係の目安:
// dependencies:
//   flutter:
//     sdk: flutter
//   supabase_flutter: ^2.0.0
//
// 外部アセット一切なし。material.dart の標準アニメーションのみで演出。

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ── Supabase ダミー設定 ─────────────────────────────────────
// 実運用時は自身のプロジェクトの URL / anonKey に差し替えてください。
const String _kSupabaseUrl = 'https://your-project-id.supabase.co';
const String _kSupabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Supabase.initialize(url: _kSupabaseUrl, anonKey: _kSupabaseAnonKey);
  } catch (e) {
    // ダミーキーでの実行時はネットワークエラーになるが、UIデモには影響させない。
    debugPrint('Supabase init skipped (demo env): $e');
  }
  runApp(const HabitSwitchApp());
}

class HabitSwitchApp extends StatelessWidget {
  const HabitSwitchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3週間習慣チェンジ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: const Color(0xFF7C4DFF),
        scaffoldBackgroundColor: const Color(0xFF0F0B1E),
        fontFamily: 'Roboto',
      ),
      home: const HabitHomePage(),
    );
  }
}

enum Grade { matsu, take, ume }

extension GradeInfo on Grade {
  String get label {
    switch (this) {
      case Grade.matsu:
        return '松';
      case Grade.take:
        return '竹';
      case Grade.ume:
        return '梅';
    }
  }

  String get subtitle {
    switch (this) {
      case Grade.matsu:
        return '完璧に置き換えた！';
      case Grade.take:
        return '意識して行動できた！';
      case Grade.ume:
        return 'つい出たけど、気づけた！';
    }
  }

  Color get color {
    switch (this) {
      case Grade.matsu:
        return const Color(0xFFFFC107);
      case Grade.take:
        return const Color(0xFF4CAF50);
      case Grade.ume:
        return const Color(0xFFFF7597);
    }
  }

  List<String> get emojis {
    switch (this) {
      case Grade.matsu:
        return ['🎉', '🌟', '💪', '✨', '👑'];
      case Grade.take:
        return ['🙌', '✅', '🔥', '💪', '🌱'];
      case Grade.ume:
        return ['🌱', '💡', '👍', '✨', '🫶'];
    }
  }

  List<String> get messages {
    switch (this) {
      case Grade.matsu:
        return [
          '完璧！その調子で3週間走り抜けよう🔥',
          '神ムーブ！新しい自分に一歩近づいた✨',
          '最高の1日！この積み重ねが未来を変える👑',
        ];
      case Grade.take:
        return [
          '意識できたのが何より大事！えらい💪',
          'その積み重ねが確実に力になってる🌟',
          'ナイス継続！焦らず一歩ずつでOK🙌',
        ];
      case Grade.ume:
        return [
          '気づけただけで大偉業！次、いこう🌱',
          '戻れたことが才能。責めずに前へ👍',
          '大丈夫、気づきが一番の成長の証💡',
        ];
    }
  }
}

class _Particle {
  final double angle;
  final double distance;
  final double size;
  final String emoji;
  final double rotation;
  final double delay;

  _Particle({
    required this.angle,
    required this.distance,
    required this.size,
    required this.emoji,
    required this.rotation,
    required this.delay,
  });
}

class HabitHomePage extends StatefulWidget {
  const HabitHomePage({super.key});

  @override
  State<HabitHomePage> createState() => _HabitHomePageState();
}

class _HabitHomePageState extends State<HabitHomePage>
    with TickerProviderStateMixin {
  static const int _totalDays = 21;

  final List<Grade> _logHistory = [];
  final math.Random _rand = math.Random();

  late final AnimationController _celebrationController;
  late final AnimationController _messageController;

  List<_Particle> _particles = [];
  String _message = '';
  Grade? _lastGrade;
  Timer? _hideTimer;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _messageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      reverseDuration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    _messageController.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  int get _currentDay => math.min(_logHistory.length + 1, _totalDays);

  double get _continuationRate {
    if (_logHistory.isEmpty) return 100.0;
    final good = _logHistory.where((g) => g != Grade.ume).length;
    return (good / _logHistory.length) * 100;
  }

  Future<void> _saveToSupabase(Grade grade, String message) async {
    try {
      final client = Supabase.instance.client;
      await client.from('habit_logs').insert({
        'log_date': DateTime.now().toIso8601String(),
        'grade': grade.label,
        'message': message,
      });
    } catch (e) {
      // ダミー環境では通信に失敗するが、UIフローは止めない。
      debugPrint('habit_logs insert failed (demo env): $e');
    }
  }

  void _generateParticles(Grade grade) {
    final emojis = grade.emojis;
    _particles = List.generate(18, (i) {
      return _Particle(
        angle: _rand.nextDouble() * 2 * math.pi,
        distance: 90 + _rand.nextDouble() * 170,
        size: 22 + _rand.nextDouble() * 22,
        emoji: emojis[_rand.nextInt(emojis.length)],
        rotation: (_rand.nextDouble() - 0.5) * 4 * math.pi,
        delay: _rand.nextDouble() * 0.25,
      );
    });
  }

  Future<void> _handleLog(Grade grade) async {
    if (_busy) return;
    _busy = true;
    _hideTimer?.cancel();

    final message = grade.messages[_rand.nextInt(grade.messages.length)];

    setState(() {
      if (_logHistory.length < _totalDays) {
        _logHistory.add(grade);
      }
      _lastGrade = grade;
      _message = message;
      _generateParticles(grade);
    });

    _celebrationController
      ..reset()
      ..forward();
    _messageController
      ..reset()
      ..forward();

    _hideTimer = Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        _messageController.reverse();
      }
    });

    unawaited(_saveToSupabase(grade, message));

    Future.delayed(const Duration(milliseconds: 300), () {
      _busy = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final progress = _currentDay / _totalDays;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF130E29), Color(0xFF1F1440), Color(0xFF0F0B1E)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: _buildHeader(progress),
              ),
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildCelebrationLayer(),
                    _buildMessageBubble(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: _buildButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '3週間 新習慣置き換えチャレンジ',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C4DFF).withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '継続率 ${_continuationRate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB39DFF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$_currentDay',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 6, left: 4),
                child: Text(
                  '日目 / 21日',
                  style: TextStyle(fontSize: 14, color: Colors.white60),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress.clamp(0, 1)),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: Colors.white.withOpacity(0.08),
                valueColor: const AlwaysStoppedAnimation(Color(0xFF7C4DFF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationLayer() {
    return AnimatedBuilder(
      animation: _celebrationController,
      builder: (context, _) {
        final raw = _celebrationController.value;
        return IgnorePointer(
          child: Stack(
            children: _particles.map((p) {
              double t = ((raw - p.delay) / (1 - p.delay)).clamp(0.0, 1.0);
              final eased = Curves.easeOutCubic.transform(t);
              final opacity = (1 - t).clamp(0.0, 1.0);
              final dx = math.cos(p.angle) * p.distance * eased;
              final dy = math.sin(p.angle) * p.distance * eased -
                  60 * eased * eased;
              return Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Transform.translate(
                    offset: Offset(dx, dy),
                    child: Opacity(
                      opacity: opacity,
                      child: Transform.rotate(
                        angle: p.rotation * eased,
                        child: Text(
                          p.emoji,
                          style: TextStyle(fontSize: p.size),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildMessageBubble() {
    final grade = _lastGrade;
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _messageController,
        curve: Curves.elasticOut,
        reverseCurve: Curves.easeIn,
      ),
      child: FadeTransition(
        opacity: _messageController,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: (grade?.color ?? const Color(0xFF7C4DFF)).withOpacity(0.18),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: (grade?.color ?? const Color(0xFF7C4DFF)).withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (grade != null)
                Text(
                  grade.label,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: grade.color,
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                _message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        _GradeButton(grade: Grade.matsu, onTap: () => _handleLog(Grade.matsu)),
        const SizedBox(height: 12),
        _GradeButton(grade: Grade.take, onTap: () => _handleLog(Grade.take)),
        const SizedBox(height: 12),
        _GradeButton(grade: Grade.ume, onTap: () => _handleLog(Grade.ume)),
      ],
    );
  }
}

class _GradeButton extends StatefulWidget {
  final Grade grade;
  final VoidCallback onTap;

  const _GradeButton({required this.grade, required this.onTap});

  @override
  State<_GradeButton> createState() => _GradeButtonState();
}

class _GradeButtonState extends State<_GradeButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.96);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final grade = widget.grade;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: grade.color.withOpacity(0.14),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: grade.color.withOpacity(0.55), width: 1.4),
            boxShadow: [
              BoxShadow(
                color: grade.color.withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: grade.color.withOpacity(0.22),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  grade.label,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: grade.color,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      grade.subtitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: grade.color),
            ],
          ),
        ),
      ),
    );
  }
}