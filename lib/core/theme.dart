import 'package:flutter/material.dart';

class AppTheme {
  static const Color bg = Color(0xFF8B6B4E);
  static const Color cream = Color(0xFFF8F1E4);
  static const Color sand = Color(0xFFDFD0B5);
  static const Color dk1 = Color(0xFFA58765);
  static const Color dk2 = Color(0xFF6E5238);
  static const Color gold = Color(0xFFD4A853);
  static const Color red = Color(0xFFFF4D4D);
  static const Color green = Color(0xFF2F5A3A);
  static const Color ink = Color(0xFF4A3523);
  static const Color line = Color(0xFFC9B28E);
  static const Color txtLight = Color(0xFFF8F1E4);

  // قيمة افتراضية لمعرفة الثيم الحالي
  static String currentTheme = 'default';

  static ThemeData get themeData {
    return ThemeData(
      scaffoldBackgroundColor: bg,
      fontFamily: 'Tahoma', 
      colorScheme: const ColorScheme.light(
        primary: dk2,
        secondary: gold,
        surface: cream,
      ),
      useMaterial3: true,
    );
  }

  // دالة مساعدة لتغيير الثيم (سيتم استدعاؤها من الإعدادات)
  static void applyTheme(BuildContext context, String themeName) {
    // في Flutter، لتغيير الثيم بالكامل يتطلب إعادة بناء التطبيق من الجذر.
    // هنا سنقوم بحفظ اسم الثيم فقط، وسنقرأه في main.dart
    currentTheme = themeName;
  }
}
