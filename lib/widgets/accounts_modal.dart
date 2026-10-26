import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';

class AccountsModal extends StatelessWidget {
  const AccountsModal({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppTheme.gold, width: 3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // عنوان النافذة
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.red),
                onPressed: () => Navigator.pop(context),
              ),
              const Text('الحسابات المسجلة', style: TextStyle(color: AppTheme.txtLight, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 40),
            ],
          ),
          const SizedBox(height: 10),
          
          // قائمة الحسابات
          state.people.isEmpty
              ? const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('لا توجد حسابات مسجلة', style: TextStyle(color: AppTheme.txtLight)),
                )
              : ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.5),
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: state.people.map((p) {
                        return Container(
                          width: (MediaQuery.of(context).size.width - 50) / 2,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.cream,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.line, width: 2),
                          ),
                          child: Column(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.dk1,
                                radius: 20,
                                child: const Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(height: 5),
                              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.ink), textAlign: TextAlign.center),
                              const SizedBox(height: 4),
                              Text('${p.total} ${state.currency}', style: const TextStyle(color: AppTheme.green, fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
          
          const SizedBox(height: 15),
          // زر إضافة حساب جديد
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showAddPersonDialog(context, state),
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text('إضافة حساب جديد', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.dk1,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // نافذة إضافة حساب جديد
  void _showAddPersonDialog(BuildContext context, AppState state) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final balanceController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cream,
        title: const Text('إضافة حساب جديد', style: TextStyle(color: AppTheme.ink, fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'اسم الحساب',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف (اختياري)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: balanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'رصيد افتتاحي في الصندوق',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final newPerson = Person(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  wallets: {'cash': double.tryParse(balanceController.text) ?? 0.0},
                );
                state.people.add(newPerson);
                state.save();
                Navigator.pop(ctx);
                Navigator.pop(context); // إغلاق النافذة السفلية لتحديث البيانات
                
                // إعادة فتح النافذة السفلية لرؤية الحساب الجديد
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AccountsModal(),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.green),
            child: const Text('حفظ', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
