import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';

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
              IconButton(icon: const Icon(Icons.arrow_back, color: AppTheme.txtLight), onPressed: () {}),
            ],
          ),
          const SizedBox(height: 10),

          // 1. قسم المراحل
          _buildSectionBox(
            title: 'إنشاء / إخفاء حسابات المراحل',
            icon: Icons.visibility,
            child: Column(
              children: [
                const Text(
                  'الضغط على الزر لمرة واحدة: ينشئ الحسابات ويُظهرها.\nالضغط مرة أخرى: يُخفيها من الشاشات (بدون حذفها).',
                  style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.5),
                  textAlign: TextAlign.right,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _stageButton('الابتدائي', Icons.book),
                    const SizedBox(width: 8),
                    _stageButton('المتوسط', Icons.school),
                    const SizedBox(width: 8),
                    _stageButton('الثانوي', Icons.menu_book),
                  ],
                ),
              ],
            ),
          ),

          // 2. قسم الثيمات
          _buildSectionBox(
            title: 'مظهر التطبيق (الثيمات)',
            icon: Icons.palette,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _themeCard('بني كلاسيكي', const Color(0xFF8B6B4E), true),
                _themeCard('ليلي داكن', const Color(0xFF121212), false),
                _themeCard('أزرق المحيط', const Color(0xFF1A78C2), false),
                _themeCard('أخضر زمردي', const Color(0xFF2E7D32), false),
              ],
            ),
          ),

          // 3. التفضيلات العامة
          _buildSectionBox(
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
          _buildSectionBox(
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
          _buildSectionBox(
            title: 'البنوك',
            icon: Icons.account_balance,
            badge: '${state.banks.length}',
            child: Column(
              children: [
                ...state.banks.map((b) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.line)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(b.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink)),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppTheme.red, size: 20),
                        onPressed: () { state.banks.removeWhere((bank) => bank.id == b.id); state.save(); },
                      ),
                    ],
                  ),
                )),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            state.banks.add(Bank(id: DateTime.now().toString(), name: val.trim()));
                            state.save();
                          }
                        },
                        decoration: InputDecoration(hintText: 'اسم بنك جديد', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), filled: true, fillColor: AppTheme.cream),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(height: 40, width: 40, decoration: BoxDecoration(color: AppTheme.gold, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.add, color: AppTheme.ink)),
                  ],
                )
              ],
            ),
          ),

          // 6. حسابات البنوك
          _buildSectionBox(
            title: 'حسابات البنوك المعتمدة',
            icon: Icons.account_balance_wallet,
            badge: '0',
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً...'))); },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green),
                child: const Text('+ إدارة حسابات البنوك (0)', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),

          // 7. إدارة الحسابات
          _buildSectionBox(
            title: 'إدارة الحسابات',
            icon: Icons.people,
            badge: '${state.people.length}',
            child: Column(
              children: state.people.map((p) => Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.sand))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: AppTheme.ink, size: 18),
                          onPressed: () {
                            final controller = TextEditingController(text: p.name);
                            showDialog(context: context, builder: (ctx) => AlertDialog(
                              title: const Text('تعديل الاسم'),
                              content: TextField(controller: controller),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                                TextButton(onPressed: () { p.name = controller.text; state.save(); Navigator.pop(ctx); }, child: const Text('حفظ')),
                              ],
                            ));
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppTheme.red, size: 20),
                          onPressed: () {
                            state.people.removeWhere((person) => person.id == p.id);
                            state.save();
                          },
                        ),
                      ],
                    )
                  ],
                ),
              )).toList(),
            ),
          ),

          // 8. النسخ الاحتياطي
          _buildSectionBox(
            title: 'النسخ الاحتياطي التلقائي',
            icon: Icons.backup,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('حفظ نسخة تلقائياً للهاتف', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.ink)),
                Switch(value: false, activeColor: AppTheme.green, onChanged: (val) {}),
              ],
            ),
          ),

          // 9. البيانات اليدوية
          _buildSectionBox(
            title: 'البيانات اليدوية',
            icon: Icons.storage,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dk1), child: const Text('تصدير نسخة الآن', style: TextStyle(color: AppTheme.txtLight, fontSize: 12)))),
                    const SizedBox(width: 8),
                    Expanded(child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dk1), child: const Text('استيراد نسخة', style: TextStyle(color: AppTheme.txtLight, fontSize: 12)))),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      showDialog(context: context, builder: (ctx) => AlertDialog(
                        title: const Text('تأكيد الحذف'),
                        content: const Text('هل أنت متأكد من مسح جميع البيانات؟'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
                          TextButton(onPressed: () {
                            state.people.clear();
                            state.transactions.clear();
                            state.save();
                            Navigator.pop(ctx);
                          }, child: const Text('مسح', style: TextStyle(color: Colors.red))),
                        ],
                      ));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.red),
                    child: const Text('مسح كل البيانات', style: TextStyle(color: Colors.white, fontSize: 12)),
                  ),
                )
              ],
            ),
          ),

          // 10. عن المطور
          _buildSectionBox(
            title: 'عن المطور',
            icon: Icons.info,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showDialog(context: context, builder: (ctx) => AlertDialog(
                    title: const Text('عن المطور'),
                    content: const Text('تطبيق MAMX\nالمطور: Abu Almull\nللتواصل: 0922008009'),
                    actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إغلاق'))],
                  ));
                },
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

  // دالة لبناء الأقسام بشكل مباشر
  Widget _buildSectionBox({required String title, required IconData icon, required Widget child, String? badge}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppTheme.cream, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.line, width: 2)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppTheme.line, width: 1))),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: AppTheme.dk2, radius: 16, child: Icon(icon, color: AppTheme.txtLight, size: 18)),
                const SizedBox(width: 10),
                Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink, fontSize: 14))),
                if (badge != null)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.dk2, borderRadius: BorderRadius.circular(10)), child: Text(badge, style: const TextStyle(color: AppTheme.txtLight, fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(12), child: child),
        ],
      ),
    );
  }

  Widget _stageButton(String title, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.dk1, AppTheme.dk2]), borderRadius: BorderRadius.circular(8)),
          child: Column(children: [Icon(icon, color: AppTheme.txtLight, size: 20), const SizedBox(height: 4), Text(title, style: const TextStyle(color: AppTheme.txtLight, fontSize: 12, fontWeight: FontWeight.bold))]),
        ),
      ),
    );
  }

  Widget _themeCard(String name, Color color, bool isSelected) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8), border: Border.all(color: isSelected ? AppTheme.gold : Colors.transparent, width: 3)),
      child: Column(children: [
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
        if (isSelected) ...[const SizedBox(height: 4), const Text('(مُطبق)', style: TextStyle(color: AppTheme.gold, fontSize: 11))],
      ]),
    );
  }

  Widget _dropdownField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.ink, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(color: AppTheme.cream, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.line)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(value, style: const TextStyle(color: AppTheme.ink)), const Icon(Icons.arrow_drop_down, color: AppTheme.ink)]),
        ),
      ],
    );
  }
}
