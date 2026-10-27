import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';
import 'operation_screen.dart';
import 'log_screen.dart';
import 'reports_screen.dart';
import 'settings_screen.dart'; // <--- تم إضافة هذا السطر
import '../widgets/accounts_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // حساب الإحصائيات
    double totalIncome = state.transactions.where((t) => t.type == 'dep').fold(0, (a, t) => a + t.amount);
    double totalExpense = state.transactions.where((t) => t.type == 'wd').fold(0, (a, t) => a + t.amount);
    double totalBalance = state.people.fold(0, (a, p) => a + p.total);
    double cashBalance = state.people.fold(0, (a, p) => a + (p.wallets['cash'] ?? 0));
    double banksBalance = totalBalance - cashBalance;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // شريط التاريخ
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.dk2,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.line),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppTheme.txtLight),
                SizedBox(width: 6),
                Text('إحصائيات: هذا العام', style: TextStyle(color: AppTheme.txtLight, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 15),
          
          // بطاقات الإحصائيات والرسم البياني
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _sumCard('دخل', '${_formatNum(totalIncome)} ${state.currency}', AppTheme.green, Icons.arrow_upward),
                    const SizedBox(height: 6),
                    _sumCard('مصروف', '${_formatNum(totalExpense)} ${state.currency}', AppTheme.red, Icons.arrow_downward),
                    const SizedBox(height: 6),
                    _sumCard('الربح', '${_formatNum(totalBalance)} ${state.currency}', AppTheme.gold, Icons.attach_money),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: Container(
                  height: 115,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.line, width: 1.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 75,
                      height: 75,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.red),
                      child: Center(
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2A2A2A)),
                          child: Center(
                            child: Text(
                              '${state.people.length}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // أزرار الإحصائيات
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (_) => const AccountsModal(),
                  ),
                  child: _midButton(Icons.people, 'الحسابات', '${state.people.length}'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: _midButton(Icons.account_balance_wallet, 'الصندوق', _formatNum(cashBalance))),
              const SizedBox(width: 8),
              Expanded(child: _midButton(Icons.account_balance, 'البنوك', _formatNum(banksBalance))),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // القائمة السريعة
          Row(
            children: [
              GestureDetector(onTap: () {}, child: const Icon(Icons.notifications, color: AppTheme.txtLight, size: 24)),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
                child: const Icon(Icons.settings, color: AppTheme.txtLight, size: 24),
              ),
              const Spacer(),
              const Text('القائمة السريعة', style: TextStyle(color: AppTheme.txtLight, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          
          const SizedBox(height: 10),
          _divider('العمليات المالية'),
          
          // العمليات المالية (تم تبديل الإيداع مع التحويل)
          Row(
            children: [
              Expanded(child: _quickButton(context, Icons.swap_horiz, 'تحويل', 'tr')),
              const SizedBox(width: 8),
              Expanded(child: _quickButton(context, Icons.arrow_upward, 'سحب', 'wd')),
              const SizedBox(width: 8),
              Expanded(child: _quickButton(context, Icons.arrow_downward, 'إيداع', 'dep')),
            ],
          ),

          const SizedBox(height: 15),
          _divider('الإدارة والتقارير'),

          // الإدارة والتقارير (تم تبديل الحسابات مع التقارير)
          Row(
            children: [
              Expanded(child: _adminButton(context, Icons.bar_chart, 'التقارير', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportsScreen()));
              })),
              const SizedBox(width: 8),
              Expanded(child: _adminButton(context, Icons.history, 'السجل', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LogScreen()));
              })),
              const SizedBox(width: 8),
              Expanded(child: _adminButton(context, Icons.people, 'الحسابات', () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AccountsModal(),
                );
              })),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _formatNum(double num) {
    if (num == num.roundToDouble()) return num.toInt().toString();
    return num.toStringAsFixed(2);
  }

  Widget _divider(String title) {
    return Row(
      children: [
        Text(title, style: const TextStyle(color: AppTheme.txtLight, fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(width: 10),
        const Expanded(child: Divider(color: AppTheme.line, thickness: 1)),
      ],
    );
  }

  Widget _quickButton(BuildContext context, IconData icon, String title, String type) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => OperationScreen(initialType: type)));
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF9C7B5B), Color(0xFF7B5F45)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.line.withOpacity(0.5), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppTheme.txtLight, size: 24),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: AppTheme.txtLight, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _adminButton(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF9C7B5B), Color(0xFF7B5F45)], begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.line.withOpacity(0.5), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: AppTheme.txtLight, size: 24),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: AppTheme.txtLight, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _sumCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)),
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: color),
            ],
          ),
          Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Widget _midButton(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF9C7B5B), Color(0xFF7B5F45)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line, width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.txtLight, size: 22),
          const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: AppTheme.txtLight, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
