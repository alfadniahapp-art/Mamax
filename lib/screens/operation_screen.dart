import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../core/theme.dart';
import '../providers/app_state.dart';

class OperationScreen extends StatefulWidget {
  final String initialType;
  const OperationScreen({super.key, this.initialType = 'dep'});

  @override
  State<OperationScreen> createState() => _OperationScreenState();
}

class _OperationScreenState extends State<OperationScreen> {
  late String _type;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _sourceDestController = TextEditingController();

  String? _fromPersonId;
  String? _toPersonId;

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
  }

  void _submit(AppState state) {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل مبلغاً صحيحاً')));
      return;
    }
    if (_type == 'dep' && _toPersonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر الحساب المستلم')));
      return;
    }
    if (_type == 'wd' && _fromPersonId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر الحساب المصدر')));
      return;
    }
    if (_type == 'tr' && (_fromPersonId == null || _toPersonId == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('اختر الحساب المصدر والمستلم')));
      return;
    }

    // التحقق من كفاية الرصيد للسحب والتحويل
    if (_type == 'wd' || _type == 'tr') {
      final fromPerson = state.getPersonById(_fromPersonId);
      if (fromPerson != null && (fromPerson.wallets['cash'] ?? 0) < amount) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('رصيد غير كافٍ!'),
          backgroundColor: AppTheme.red,
        ));
        return;
      }
    }

    final tx = Transaction(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: _type,
      amount: amount,
      date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
      fromPersonId: _type != 'dep' ? _fromPersonId : null,
      toPersonId: _type != 'wd' ? _toPersonId : null,
      sourceDest: _sourceDestController.text,
      note: _noteController.text,
    );

    state.addTransaction(tx);
    
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('تمت العملية بنجاح ✔'),
      backgroundColor: AppTheme.green,
    ));
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.dk2,
        elevation: 0,
        title: const Text('⚡ عملية جديدة', style: TextStyle(color: AppTheme.txtLight, fontWeight: FontWeight.bold)),
        iconTheme: const IconThemeData(color: AppTheme.txtLight),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // أزرار اختيار نوع العملية
            Row(
              children: [
                _typeButton('dep', 'إيداع'),
                const SizedBox(width: 8),
                _typeButton('wd', 'سحب'),
                const SizedBox(width: 8),
                _typeButton('tr', 'تحويل'),
              ],
            ),
            const SizedBox(height: 15),
            
            // نموذج العملية
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppTheme.cream,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.line, width: 2),
              ),
              child: Column(
                children: [
                  if (_type != 'dep') ...[
                    _buildPersonDropdown('من (الحساب)', _fromPersonId, (val) => setState(() => _fromPersonId = val), state),
                    const SizedBox(height: 10),
                  ],
                  
                  if (_type != 'wd') ...[
                    _buildPersonDropdown('إلى (الحساب)', _toPersonId, (val) => setState(() => _toPersonId = val), state),
                    const SizedBox(height: 10),
                  ],

                  if (_type != 'tr') ...[
                    TextField(
                      controller: _sourceDestController,
                      decoration: InputDecoration(
                        labelText: _type == 'dep' ? 'المصدر (جهة الإيداع)' : 'المستلم (جهة السحب)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true, fillColor: AppTheme.cream,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                    decoration: InputDecoration(
                      labelText: 'المبلغ (${state.currency})',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true, fillColor: AppTheme.sand,
                    ),
                  ),
                  const SizedBox(height: 10),

                  TextField(
                    controller: _noteController,
                    decoration: InputDecoration(
                      labelText: 'ملاحظة إضافية (اختياري)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true, fillColor: AppTheme.cream,
                    ),
                  ),
                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _submit(state),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.green,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('تنفيذ العملية', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typeButton(String type, String title) {
    final isSelected = _type == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _type = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.dk2 : AppTheme.cream,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppTheme.line, width: 2),
          ),
          child: Center(
            child: Text(title, style: TextStyle(color: isSelected ? AppTheme.txtLight : AppTheme.ink, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonDropdown(String label, String? currentVal, Function(String?) onChanged, AppState state) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true, fillColor: AppTheme.cream,
      ),
      value: currentVal,
      items: state.people.map((p) => DropdownMenuItem(
        value: p.id, 
        child: Text(p.name),
      )).toList(),
      onChanged: onChanged,
    );
  }
}
