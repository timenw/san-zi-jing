import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'screens/home_screen.dart';
import 'screens/reader_screen.dart';
import 'screens/about_screen.dart';
import 'models/phrase.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const SanZiJingApp(),
    ),
  );
}

class SanZiJingApp extends StatelessWidget {
  const SanZiJingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '亲子共读三字经',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD4A055),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: null, // 使用系统字体确保中文显示
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFFD4A055),
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashInitScreen(),
      routes: {
        '/home': (ctx) => const HomeScreen(),
        '/about': (ctx) => const AboutScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/reader') {
          final phrase = settings.arguments as Phrase;
          return MaterialPageRoute(
            builder: (ctx) => ReaderScreen(phrase: phrase),
          );
        }
        return null;
      },
    );
  }
}

/// 启动初始化屏
class SplashInitScreen extends StatefulWidget {
  const SplashInitScreen({super.key});

  @override
  State<SplashInitScreen> createState() => _SplashInitScreenState();
}

class _SplashInitScreenState extends State<SplashInitScreen> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final appState = context.read<AppState>();
    await appState.init();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD4A055),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 简单的Logo - 用文字
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(40),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '三\n字\n经',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD4A055),
                    height: 1.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              '亲子共读三字经',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'AI配音 · 家长录音 · 孩子跟读',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          ],
        ),
      ),
    );
  }
}
