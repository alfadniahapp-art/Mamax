import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'home_screen.dart';
import 'log_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart';
import 'operation_screen.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;

  // ترتيب الشاشات: 
  // 0: لوحة القيادة (يمين)
  // 1: التقارير
  // 2: كل العمليات
  // 3: الإعدادات (يسار)
  final List<Widget> _screens = [
    const HomeScreen(),
    const ReportsScreen(),
    const LogScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.dk2,
          border: Border(top: BorderSide(color: AppTheme.line, width: 2)),
          borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 80,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // الزر الأول (يمين): لوحة القيادة
                      _navItem(0, Icons.home, 'لوحة القيادة'),
                      // الزر الثاني: التقارير
                      _navItem(1, Icons.bar_chart, 'التقارير'),
                      // فراغ للزر العائم
                      const SizedBox(width: 70),
                      // الزر الثالث: كل العمليات
                      _navItem(2, Icons.layers, 'كل العمليات'),
                      // الزر الرابع (يسار): إعدادات
                      _navItem(3, Icons.settings, 'إعدادات'),
                    ],
                  ),
                  // الزر العائم (FAB)
                  Positioned(
                    top: -35,
                    left: MediaQuery.of(context).size.width / 2 - 37,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const OperationScreen()));
                      },
                      child: Container(
                        width: 74,
                        height: 74,
                        decoration: const BoxDecoration(color: AppTheme.bg, shape: BoxShape.circle),
                        child: Center(
                          child: Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              color: AppTheme.sand,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppTheme.txtLight, width: 3),
                            ),
                            child: const Icon(Icons.flash_on, color: AppTheme.ink, size: 28),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // زر تسجيل الخروج
            GestureDetector(
              onTap: () {},
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppTheme.dk1,
                  border: Border(top: BorderSide(color: AppTheme.dk2, width: 1)),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
                ),
                child: const Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout, color: AppTheme.cream, size: 22),
                      SizedBox(width: 10),
                      Text('تسجيل الخروج', style: TextStyle(color: AppTheme.cream, fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isSelected ? AppTheme.gold : AppTheme.txtLight.withOpacity(0.5), size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? AppTheme.gold : AppTheme.txtLight.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
