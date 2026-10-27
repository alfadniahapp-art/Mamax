import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    // حساب الإحصائيات
    double totalIncome = state.transactions.where((t) => t.type == 'dep').fold(0, (a, t) => a + t.amount);
    double totalExpense = state.transactions.where((t) => t.type == 'wd').fold(0, (a, t) => a + t.amount);
    double totalBalance = state.people.fold(0, (a, p) => a + p.total);
    double cashBalance = state.people.fold(0, (a, p) => a + (p.wallets['cash'] ?? 0));
    double banksBalance = totalBalance - cashBalance;

    return Column(
      children: [
        // شريط العنوان
        Container(
          padding: const EdgeInsets.all(12),
          color: AppTheme.dk2,
          child: const Row(
            children: [
              Icon(Icons.bar_chart, color: AppTheme.txtLight),
              SizedBox(width: 8),
              Text('التقارير', style: TextStyle(color: AppTheme.txtLight, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // محتوى التقارير
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              const Text('ملخص مالي شامل', style: TextStyle(color: AppTheme.txtLight, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),
              
              // بطاقة الدخل
              _reportCard('إجمالي الدخل (الإيداعات)', totalIncome, state.currency, AppTheme.green, Icons.arrow_upward),
              const SizedBox(height: 8),
              
              // بطاقة المصروف
              _reportCard('إجمالي المصروف (السحوبات)', totalExpense, state.currency, AppTheme.red, Icons.arrow_downward),
              const SizedBox(height: 8),
              
              // بطاقة صافي الرصيد
              _reportCard('صافي الرصيد الإجمالي', totalBalance, state.currency, AppTheme.gold, Icons.attach_money),
              
              const SizedBox(height: 20),
              const Text('توزيع الأرصدة', style: TextStyle(color: AppTheme.txtLight, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 10),

              // بطاقة الصندوق
              _reportCard('رصيد الصندوق', cashBalance, state.currency, AppTheme.dk1, Icons.account_balance_wallet),
              const SizedBox(height: 8),

              // بطاقة البنوك
              _reportCard('رصيد البنوك', banksBalance, state.currency, AppTheme.ink, Icons.account_balance),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reportCard(String title, double amount, String currency, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            radius: 20,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color)),
          ),
          Text(
            '${_formatNum(amount)} $currency',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: color),
          ),
        ],
      ),
    );
  }

  String _formatNum(double num) {
    if (num == num.roundToDouble()) return num.toInt().toString();
    return num.toStringAsFixed(2);
  }
}
