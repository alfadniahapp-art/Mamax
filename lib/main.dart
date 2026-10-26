import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/app_state.dart';
import 'screens/main_wrapper.dart';

void main() {
  runApp(const MamaxApp());
}

class MamaxApp extends StatelessWidget {
  const MamaxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..load(),
      child: MaterialApp(
        title: 'MAMX',
        theme: AppTheme.themeData,
        debugShowCheckedModeBanner: false,
        home: const SplashAndAuth(),
      ),
    );
  }
}

class SplashAndAuth extends StatefulWidget {
  const SplashAndAuth({super.key});

  @override
  State<SplashAndAuth> createState() => _SplashAndAuthState();
}

class _SplashAndAuthState extends State<SplashAndAuth> {
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return Scaffold(
        backgroundColor: const Color(0xFF061325),
        body: Center(
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Center(
              child: Text(
                'MAMX',
                style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w900, letterSpacing: 4),
              ),
            ),
          ),
        ),
      );
    }

    // تم تجاوز شاشة التفعيل مؤقتاً
    return const MainWrapper();
  }
}
