import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';

class LogScreen extends StatelessWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Column(
      children: [
        // شريط العنوان
        Container(
          padding: const EdgeInsets.all(12),
          color: AppTheme.dk2,
          child: const Row(
            children: [
              Icon(Icons.history, color: AppTheme.txtLight),
              SizedBox(width: 8),
              Text('سجل الحركات', style: TextStyle(color: AppTheme.txtLight, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        
        // قائمة الحركات
        Expanded(
          child: state.transactions.isEmpty
              ? const Center(
                  child: Text('لا توجد حركات مسجلة حتى الآن', style: TextStyle(color: AppTheme.txtLight, fontSize: 16)),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: state.transactions.length,
                  itemBuilder: (context, index) {
                    final tx = state.transactions[index];
                    final isDep = tx.type == 'dep';
                    final isWd = tx.type == 'wd';
                    
                    // جلب أسماء الأشخاص
                    final fromPerson = state.getPersonById(tx.fromPersonId)?.name ?? 'غير محدد';
                    final toPerson = state.getPersonById(tx.toPersonId)?.name ?? 'غير محدد';

                    // تحديد نص البيان
                    String description = '';
                    if (isDep) {
                      description = 'من: ${tx.sourceDest.isEmpty ? "غير محدد" : tx.sourceDest} إلى: $toPerson';
                    } else if (isWd) {
                      description = 'من: $fromPerson إلى: ${tx.sourceDest.isEmpty ? "غير محدد" : tx.sourceDest}';
                    } else {
                      description = 'من: $fromPerson إلى: $toPerson';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.cream,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.line, width: 2),
                      ),
                      child: Row(
                        children: [
                          // أيقونة العملية
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: AppTheme.sand, shape: BoxShape.circle),
                            child: Icon(
                              isDep ? Icons.arrow_downward : isWd ? Icons.arrow_upward : Icons.swap_horiz,
                              color: isDep ? AppTheme.green : isWd ? AppTheme.red : AppTheme.ink,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          
                          // تفاصيل الحركة
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  description,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.ink),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tx.date,
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                                if (tx.note.isNotEmpty)
                                  Text(
                                    'ملاحظة: ${tx.note}',
                                    style: const TextStyle(fontSize: 10, color: AppTheme.dk1, fontStyle: FontStyle.italic),
                                  ),
                              ],
                            ),
                          ),
                          
                          // المبلغ
                          Text(
                            '${isWd ? '-' : isDep ? '+' : ''}${tx.amount} ${state.currency}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              color: isDep ? AppTheme.green : isWd ? AppTheme.red : AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
