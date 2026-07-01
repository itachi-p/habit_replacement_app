import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // 面接デモ用に、Supabase未初期化でもアプリがクラッシュしないよう対策
  try {
    WidgetsFlutterBinding.ensureInitialized();
    // 実際のURLとKeyがある場合はここに上書きしてください
    await Supabase.initialize(
      url: 'https://your-project-id.supabase.co',
      anonKey: 'your-anon-key-here',
    );
  } catch (e) {
    debugPrint('Supabase initial setup skipped for standalone demo: $e');
  }

  runApp(const HabitReplacementApp());
}

class HabitReplacementApp extends StatelessWidget {
  const HabitReplacementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '3週間 新習慣置き換えチャレンジ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0Entries121214),
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
  // 画面の状態管理
  String _message = 'やめたい悪習慣を、新しい行動に置き換えよう。\n今日のあなたの選択は？';
  String _emoji = '🎯';
  Color _accentColor = Colors.indigoAccent;
  int _dayCount = 12;
  double _successRate = 75.0;

  // アニメーション制御
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.5).chain(CurveTween(curve: Curves.elasticOut)), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.5, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // Supabaseへの擬似/実際インサート関数
  Future<void> _logHabit(String status, String note) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('habit_logs').insert({
        'status': status,
        'message': note,
        'created_at': DateTime.now().toIso8601String(),
      });
      debugPrint('Supabaseにログを保存しました: $status');
    } catch (e) {
      // 繋がっていなくてもデモを続行するためのキャッチ
      debugPrint('Supabaseへの保存（デモ動作）: $status - $note');
    }
  }

  // ボタンが押されたときのアクション
  void _handleOptionSelected(String type) {
    _controller.forward(from: 0.0);

    setState(() {
      if (type == '松') {
        _emoji = '🎉';
        _message = '素晴らしい！完璧な置き換え成功じゃ！\nその調子で脳の回路を書き換えていこう！';
        _accentColor = Colors.emeraldAccent;
        _dayCount += 1;
        _successRate = ((_successRate * 10 + 100) / 11).clamp(0, 100);
        _logHabit('松', '完璧に新習慣を実行できた');
      } else if (type == '竹') {
        _emoji = '🌟';
        _message = 'ナイスチャレンジ！意識して行動できたね。\nその「一歩」の積み重ねが未来を変えるよ！';
        _accentColor = Colors.amberAccent;
        _successRate = ((_successRate * 10 + 80) / 11).clamp(0, 100);
        _logHabit('竹', '意識して行動できた');
      } else {
        _emoji = '💪';
        _message = '気づけただけで100点満点！大前進じゃ！\n「あ、ついやってしもた」とメタ認知できた証拠。次また置き換えよう！';
        _accentColor = Colors.lightBlueAccent;
        _successRate = ((_successRate * 10 + 40) / 11).clamp(0, 100);
        _logHabit('梅', '悪習慣が出たが、自覚できた');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480), // スマホ風の幅に固定して見栄えを良くする
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 上部ヘッダー（進捗インジケーター）
                Card(
                  elevation: 4,
                  color: Colors.white.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          '3週間 新習慣置き換えチャレンジ',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildInfoColumn('経過日数', '$_dayCount / 21 日'),
                            _buildInfoColumn('習慣継続率', '${_successRate.toStringAsFixed(1)} %'),
                          ],
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: _dayCount / 21,
                          backgroundColor: Colors.white12,
                          color: _accentColor,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ),

                // 中央演出エリア
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ScaleTransition(
                        scale: _scaleAnimation,
                        child: Text(
                          _emoji,
                          style: const TextStyle(fontSize: 80),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: _accentColor, width: 4)),
                        ),
                        child: Text(
                          _message,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),

                // 下部アクションボタン（松竹梅のUX）
                Column(
                  children: [
                    const Text(
                      'ー 今日の行動を記録 ー',
                      style: TextStyle(fontSize: 12, color: Colors.white38, letterSpacing: 2),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: _buildActionButton('松', '完璧！', Colors.emerald, () => _handleOptionSelected('松'))),
                        const SizedBox(width: 10),
                        Expanded(child: _buildActionButton('竹', '意識した', Colors.amber.shade700, () => _handleOptionSelected('竹'))),
                        const SizedBox(width: 10),
                        Expanded(child: _buildActionButton('梅', '気づけた', Colors.blueGrey, () => _handleOptionSelected('梅'))),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white54)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildActionButton(String label, String subText, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        side: BorderSide(color: color.withOpacity(0.5), width: 1.5),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      onPressed: onPressed,
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subText, style: const TextStyle(fontSize: 10, color: Colors.white60)),
        ],
      ),
    );
  }
}