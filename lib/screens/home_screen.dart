import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';
import 'operation_screen.dart';
import '../widgets/accounts_modal.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // 1. شريط التاريخ (إحصائيات: هذا العام)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.dk2.withOpacity(0.5), // لون داكن شفاف
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
          const SizedBox(height: 12),
          
          // 2. بطاقات الدخل والمصروف والرسم البياني
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الرسم البياني (الدائرة)
              Expanded(
                flex: 4,
                child: Container(
                  height: 140,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A), // لون داكن مطابق للصورة
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.line, width: 1.5),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _legendDot(AppTheme.green, 'دخل'),
                          const SizedBox(width: 8),
                          _legendDot(AppTheme.red, 'مصروف'),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // الدائرة
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.red, // لون أحمر لأن كل شيء 0
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2A2A2A),
                            ),
                            child: const Center(
                              child: Text('0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                            ),
                          ),
                          // المربع الصغير أسفل الدائرة
                          Positioned(
                            bottom: -5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.red,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('0', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // بطاقات الدخل والمصروف
              Expanded(
                flex: 5,
                child: Column(
                  children: [
                    _sumCard('دخل', '0 ${state.currency}', AppTheme.green, Icons.arrow_upward),
                    const SizedBox(height: 8),
                    _sumCard('مصروف', '0 ${state.currency}', AppTheme.red, Icons.arrow_downward),
                    const SizedBox(height: 8),
                    _sumCard('الربح', '0 ${state.currency}', AppTheme.gold, Icons.attach_money),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 3. أزرار الإحصائيات (الحسابات، الصندوق، البنوك)
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
              Expanded(child: _midButton(Icons.account_balance_wallet, 'الصندوق', '0')),
              const SizedBox(width: 8),
              Expanded(child: _midButton(Icons.account_balance, 'البنوك', '0')),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // 4. القائمة السريعة
          Row(
            children: [
              GestureDetector(
                onTap: () {},
                child: const Icon(Icons.notifications, color: AppTheme.txtLight, size: 24),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.settings, color: AppTheme.txtLight, size: 24),
              const SizedBox(width: 12),
              const Icon(Icons.calendar_today, color: AppTheme.txtLight, size: 24),
              const Spacer(),
              const Text('القائمة السريعة', style: TextStyle(color: AppTheme.txtLight, fontWeight: FontWeight.w900, fontSize: 16)),
            ],
          ),
          
          const SizedBox(height: 10),
          _sectionDivider('العمليات المالية'),
          
          // أزرار العمليات المالية
          Row(
            children: [
              Expanded(child: _quickButton(context, Icons.arrow_downward, 'إيداع', 'dep')),
              const SizedBox(width: 8),
              Expanded(child: _quickButton(context, Icons.arrow_upward, 'سحب', 'wd')),
              const SizedBox(width: 8),
              Expanded(child: _quickButton(context, Icons.swap_horiz, 'تحويل', 'tr')),
            ],
          ),

          const SizedBox(height: 15),
          _sectionDivider('الإدارة والتقارير'),

          // أزرار الإدارة والتقارير
          Row(
            children: [
              Expanded(child: _adminButton(context, Icons.people, 'الحسابات', () {})),
              const SizedBox(width: 8),
              Expanded(child: _adminButton(context, Icons.history, 'السجل', () {})),
              const SizedBox(width: 8),
              Expanded(child: _adminButton(context, Icons.bar_chart, 'التقارير', () {})),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
      ],
    );
  }

  Widget _sectionDivider(String title) {
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
          gradient: const LinearGradient(
            colors: [Color(0xFF9C7B5B), Color(0xFF7B5F45)], // ألوان مطابقة للصورة
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
          gradient: const LinearGradient(
            colors: [Color(0xFF9C7B5B), Color(0xFF7B5F45)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A), // لون داكن مطابق للصورة
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
        gradient: const LinearGradient(
          colors: [Color(0xFF9C7B5B), Color(0xFF7B5F45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
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
