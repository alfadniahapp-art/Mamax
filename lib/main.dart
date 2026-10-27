import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  runApp(const MamaxApp());
}

class MamaxApp extends StatelessWidget {
  const MamaxApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // تم تصحيح rtl إلى rightToLeft
        return Directionality(textDirection: TextDirection.rightToLeft, child: child!);
      },
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B6B4E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6E5238),
        title: const Text('اختبار البناء', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text(
          'التطبيق يعمل بنجاح ✔',
          style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
