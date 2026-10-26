import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../core/constants.dart';
import '../providers/app_state.dart';
import '../models/bank.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // العنوان
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('⚙️ الإعدادات', style: TextStyle(color: AppTheme.txtLight, fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppTheme.txtLight),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 1. قسم المراحل
          _buildSection(
            title: 'إنشاء / إخفاء حسابات المراحل',
            icon: Icons.visibility,
            child: Column(
              children: [
                const Text(
                  'الضغط على الزر لمرة واحدة: ينشئ الحسابات ويُظهرها.\nالضغط مرة أخرى: يُخفيها من الشاشات (بدون حذفها).\nالضغط مرة ثالثة: يُظهرها مجدداً.',
                  style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _stageButton('الابتدائي', Icons.book, false),
                    const SizedBox(width: 8),
                    _stageButton('المتوسط', Icons.school, false),
                    const SizedBox(width: 8),
                    _stageButton('الثانوي', Icons.menu_book, false),
                  ],
                ),
              ],
            ),
          ),

          // 2. قسم الثيمات
          _buildSection(
            title: 'مظهر التطبيق (الثيمات)',
            icon: Icons.palette,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('اختر المظهر الذي يناسبك:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _themeCard('بني كلاسيكي', const Color(0xFF8B6B4E), true),
                    _themeCard('ليلي داكن', const Color(0xFF121212), false),
                    _themeCard('أزرق المحيط', const Color(0xFF1A78C2), false),
                    _themeCard('أخضر زمردي', const Color(0xFF2E7D32), false),
                  ],
                ),
              ],
            ),
          ),

          // 3. التفضيلات العامة
          _buildSection(
            title: 'التفضيلات العامة',
            icon: Icons.language,
            child: Column(
              children: [
                _dropdownField('اللغة', 'العربية (ar)'),
                const SizedBox(height: 10),
                _dropdownField('الفترة الزمنية للشاشة الرئيسية', 'هذا العام'),
              ],
            ),
          ),

          // 4. العملة
          _buildSection(
            title: 'العملة',
            icon: Icons.attach_money,
            child: TextField(
              controller: TextEditingController(text: state.currency),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                filled: true,
                fillColor: AppTheme.cream,
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              ),
              onSubmitted: (val) {
                state.currency = val.trim().isEmpty ? 'ج.س' : val.trim();
                state.save();
              },
            ),
          ),

          // 5. البنوك
          _buildSection(
            title: 'البنوك',
            icon: Icons.account_balance,
            badge: '${state.banks.length}',
            child: Column(
              children: [
                ...state.banks.map((b) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.cream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.line),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink)),
                      const Icon(Icons.delete_outline, color: AppTheme.red, size: 20),
                    ],
                  ),
                )),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'اسم بنك جديد',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          filled: true,
                          fillColor: AppTheme.cream,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      width: 40,
                      decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.add, color: AppTheme.ink),
                    )
                  ],
                )
              ],
            ),
          ),

          // 6. حسابات البنوك
          _buildSection(
            title: 'حسابات البنوك المعتمدة',
            icon: Icons.account_balance_wallet,
            badge: '${state.bankAccounts.length}',
            child: Column(
              children: [
                const Text('سجل هنا أرقام الحسابات البنكية الرسمية لتستخدمها في عمليات الإيداع.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green),
                    child: Text('+ إدارة حسابات البنوك (${state.bankAccounts.length})', style: const TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),

          // 7. إدارة الحسابات
          _buildSection(
            title: 'إدارة الحسابات',
            icon: Icons.people,
            badge: '${state.people.length}',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('يمكنك هنا تعديل اسم الحساب أو حذفه.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 10),
                ...state.people.map((p) => Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.sand))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink)),
                      Row(
                        children: [
                          const Icon(Icons.edit, color: AppTheme.ink, size: 18),
                          const SizedBox(width: 15),
                          const Icon(Icons.delete_outline, color: AppTheme.red, size: 20),
                        ],
                      )
                    ],
                  ),
                )).toList(),
              ],
            ),
          ),

          // 8. النسخ الاحتياطي
          _buildSection(
            title: 'النسخ الاحتياطي التلقائي',
            icon: Icons.backup,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.sand, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.line)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('حفظ نسخة تلقائياً للهاتف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.ink)),
                          SizedBox(height: 2),
                          Text('سيتم تنزيل ملف نسخة احتياطية بعد كل عملية.', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        ],
                      ),
                      Switch(
                        value: state.autoBackup,
                        activeColor: AppTheme.green,
                        onChanged: (val) {
                          state.autoBackup = val;
                          state.save();
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text('* ملاحظة: سيقوم المتصفح بتنزيل الملف في مجلد التنزيلات (Downloads) في هاتفك. احتفظ به لإعادة استرجاع البيانات في حال حذف التطبيق.', 
                  style: TextStyle(fontSize: 10, color: AppTheme.red, fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          // 9. البيانات اليدوية
          _buildSection(
            title: 'البيانات اليدوية',
            icon: Icons.storage,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dk1),
                        child: const Text('تصدير نسخة الآن', style: TextStyle(color: AppTheme.txtLight, fontSize: 12)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dk1),
                        child: const Text('استيراد نسخة', style: TextStyle(color: AppTheme.txtLight, fontSize: 12)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
                    child: const Text('مسح كل البيانات', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                )
              ],
            ),
          ),

          // 10. عن المطور
          _buildSection(
            title: 'عن المطور',
            icon: Icons.info,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dk1),
                child: const Text('عن المطور / معلومات التطبيق', style: TextStyle(color: AppTheme.txtLight)),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // دالة مساعدة لبناء الأقسام المنسدلة
  Widget _buildSection({required String title, required IconData icon, required Widget child, String? badge}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.line, width: 2),
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.dk2,
          radius: 18,
          child: Icon(icon, color: AppTheme.txtLight, size: 20),
        ),
        title: Row(
          children: [
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink, fontSize: 14))),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: AppTheme.dk2, borderRadius: BorderRadius.circular(10)),
                child: Text(badge, style: const TextStyle(color: AppTheme.txtLight, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
        iconColor: AppTheme.ink,
        collapsedIconColor: AppTheme.ink,
        children: [
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }

  // زر المرحلة
  Widget _stageButton(String title, IconData icon, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [AppTheme.dk1, AppTheme.dk2]),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.txtLight, size: 20),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: AppTheme.txtLight, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // بطاقة الثيم
  Widget _themeCard(String name, Color color, bool isSelected) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? AppTheme.gold : Colors.transparent, width: 3),
      ),
      child: Column(
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
          if (isSelected) ...[
            const SizedBox(height: 4),
            const Text('(مُطبق)', style: TextStyle(color: AppTheme.gold, fontSize: 11)),
          ]
        ],
      ),
    );
  }

  // حقل منسدل
  Widget _dropdownField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.ink, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.cream,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.line),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(value, style: const TextStyle(color: AppTheme.ink)),
              const Icon(Icons.arrow_drop_down, color: AppTheme.ink),
            ],
          ),
        ),
      ],
    );
  }
}
