import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
        // إجبار التطبيق على اللغة العربية واتجاه RTL
        locale: const Locale('ar', 'SA'),
        supportedLocales: const [Locale('ar', 'SA'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        builder: (context, child) {
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
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
    // انتظار ثانيتين لعرض اللوجو
    await Future.delayed(const Duration(milliseconds: 2000));
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
        backgroundColor: const Color(0xFF061325), // لون الخلفية الداكن
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // عرض صورة الأيقونة
              Image.asset(
                'logo.png',
                width: 150,
                height: 150,
                errorBuilder: (context, error, stackTrace) {
                  // في حال لم يجد الصورة، يعرض النص
                  return const Text('MAMX', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold));
                },
              ),
            ],
          ),
        ),
      );
    }

    // بعد انتهاء شاشة البداية، ننتقل للشاشة الرئيسية
    return const MainWrapper();
  }
}
