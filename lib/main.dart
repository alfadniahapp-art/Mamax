import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(const MamaxApp());
}

// 1. الألوان
class AppColors {
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
}

// 2. التطبيق الرئيسي
class MamaxApp extends StatelessWidget {
  const MamaxApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAMX',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [Locale('ar', 'SA')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(textDirection: TextDirection.rightToLeft, child: child!),
      home: const MainWrapper(),
    );
  }
}

// 3. الحالة والبيانات
class Person {
  String id; String name; Map<String, double> wallets;
  Person({required this.id, required this.name, required this.wallets});
  double get total => wallets.values.fold(0, (a, b) => a + b);
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'wallets': wallets};
  factory Person.fromJson(Map<String, dynamic> json) => Person(id: json['id'], name: json['name'], wallets: Map<String, double>.from(json['wallets']));
}

class Transaction {
  String id; String type; double amount; String date; String? fromId; String? toId; String sourceDest;
  Transaction({required this.id, required this.type, required this.amount, required this.date, this.fromId, this.toId, this.sourceDest = ''});
  Map<String, dynamic> toJson() => {'id': id, 'type': type, 'amount': amount, 'date': date, 'fromId': fromId, 'toId': toId, 'sourceDest': sourceDest};
  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(id: json['id'], type: json['type'], amount: json['amount'], date: json['date'], fromId: json['fromId'], toId: json['toId'], sourceDest: json['sourceDest'] ?? '');
}

class AppState extends ChangeNotifier {
  String currency = 'ج.س';
  List<Person> people = [];
  List<Transaction> transactions = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('MAMX_DATA');
    if (data != null) {
      final json = jsonDecode(data);
      currency = json['currency'];
      people = (json['people'] as List).map((e) => Person.fromJson(e)).toList();
      transactions = (json['transactions'] as List).map((e) => Transaction.fromJson(e)).toList();
    } else {
      people = [
        Person(id: '1', name: 'أول ابتدائي', wallets: {'cash': 0}),
        Person(id: '2', name: 'ثاني ابتدائي', wallets: {'cash': 0}),
      ];
    }
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('MAMX_DATA', jsonEncode({
      'currency': currency,
      'people': people.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
    }));
    notifyListeners();
  }

  Person? getPerson(String? id) {
    if (id == null) return null;
    try { return people.firstWhere((p) => p.id == id); } catch (e) { return null; }
  }

  void addTransaction(Transaction tx) {
    if (tx.type == 'dep') {
      final p = getPerson(tx.toId); if (p != null) p.wallets['cash'] = (p.wallets['cash'] ?? 0) + tx.amount;
    } else if (tx.type == 'wd') {
      final p = getPerson(tx.fromId); if (p != null) p.wallets['cash'] = (p.wallets['cash'] ?? 0) - tx.amount;
    } else if (tx.type == 'tr') {
      final from = getPerson(tx.fromId); final to = getPerson(tx.toId);
      if (from != null) from.wallets['cash'] = (from.wallets['cash'] ?? 0) - tx.amount;
      if (to != null) to.wallets['cash'] = (to.wallets['cash'] ?? 0) + tx.amount;
    }
    transactions.insert(0, tx);
    save();
  }
}

// 4. الشريط السفلي
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});
  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _idx = 0;
  final _state = AppState();

  @override
  void initState() {
    super.initState();
    _state.load();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => _state,
      child: Consumer<AppState>(
        builder: (context, state, _) {
          final screens = [HomeScreen(state: state), ReportsScreen(state: state), LogScreen(state: state), SettingsScreen(state: state)];
          return Scaffold(
            body: SafeArea(child: screens[_idx]),
            bottomNavigationBar: Container(
              decoration: const BoxDecoration(color: AppColors.dk2, border: Border(top: BorderSide(color: AppColors.line, width: 2)), borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
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
                            _nav(0, Icons.home, 'لوحة القيادة'),
                            _nav(1, Icons.bar_chart, 'التقارير'),
                            const SizedBox(width: 70),
                            _nav(2, Icons.layers, 'كل العمليات'),
                            _nav(3, Icons.settings, 'إعدادات'),
                          ],
                        ),
                        Positioned(
                          top: -35, left: MediaQuery.of(context).size.width / 2 - 37,
                          child: GestureDetector(
                            onTap: () => _showOpModal(context, state),
                            child: Container(
                              width: 74, height: 74, decoration: const BoxDecoration(color: AppColors.bg, shape: BoxShape.circle),
                              child: Center(child: Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.sand, shape: BoxShape.circle, border: Border.all(color: AppColors.txtLight, width: 3)), child: const Icon(Icons.flash_on, color: AppColors.ink, size: 28))),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity, height: 60,
                    decoration: const BoxDecoration(color: AppColors.dk1, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24))),
                    child: const Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout, color: AppColors.cream, size: 22), SizedBox(width: 10), Text('تسجيل الخروج', style: TextStyle(color: AppColors.cream, fontWeight: FontWeight.bold, fontSize: 16))])),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _nav(int i, IconData icon, String label) {
    final sel = _idx == i;
    return GestureDetector(
      onTap: () => setState(() => _idx = i),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: sel ? AppColors.gold : AppColors.txtLight.withOpacity(0.5), size: 22),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: sel ? AppColors.gold : AppColors.txtLight.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.bold)),
      ]),
    );
  }
}

// 5. لوحة القيادة
class HomeScreen extends StatelessWidget {
  final AppState state;
  const HomeScreen({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    double inc = state.transactions.where((t) => t.type == 'dep').fold(0, (a, t) => a + t.amount);
    double exp = state.transactions.where((t) => t.type == 'wd').fold(0, (a, t) => a + t.amount);
    double bal = state.people.fold(0, (a, p) => a + p.total);
    double cash = state.people.fold(0, (a, p) => a + (p.wallets['cash'] ?? 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Container(
          width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: AppColors.dk2, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.line)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.calendar_today, size: 16, color: AppColors.txtLight), SizedBox(width: 6), Text('إحصائيات: هذا العام', style: TextStyle(color: AppColors.txtLight, fontWeight: FontWeight.bold, fontSize: 13))]),
        ),
        const SizedBox(height: 15),
        Row(children: [
          Expanded(flex: 3, child: Column(children: [
            _sumCard('دخل', '${inc} ${state.currency}', AppColors.green, Icons.arrow_upward),
            const SizedBox(height: 6),
            _sumCard('مصروف', '${exp} ${state.currency}', AppColors.red, Icons.arrow_downward),
            const SizedBox(height: 6),
            _sumCard('الربح', '${bal} ${state.currency}', AppColors.gold, Icons.attach_money),
          ])),
          const SizedBox(width: 8),
          Expanded(flex: 2, child: Container(
            height: 115, decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line, width: 1.5)),
            child: Center(child: Container(
              width: 75, height: 75, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.red),
              child: Center(child: Container(width: 45, height: 45, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF2A2A2A)), child: Center(child: Text('${state.people.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12))))),
            )),
          )),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _midButton(Icons.people, 'الحسابات', '${state.people.length}', () => _showAccountsModal(context, state))),
          const SizedBox(width: 8),
          Expanded(child: _midButton(Icons.account_balance_wallet, 'الصندوق', '$cash', () {})),
          const SizedBox(width: 8),
          Expanded(child: _midButton(Icons.account_balance, 'البنوك', '${bal - cash}', () {})),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          const Icon(Icons.notifications, color: AppColors.txtLight, size: 24), const SizedBox(width: 12),
          const Icon(Icons.settings, color: AppColors.txtLight, size: 24),
          const Spacer(), const Text('القائمة السريعة', style: TextStyle(color: AppColors.txtLight, fontWeight: FontWeight.w900, fontSize: 16)),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _quickBtn(context, Icons.swap_horiz, 'تحويل', 'tr', state)),
          const SizedBox(width: 8),
          Expanded(child: _quickBtn(context, Icons.arrow_upward, 'سحب', 'wd', state)),
          const SizedBox(width: 8),
          Expanded(child: _quickBtn(context, Icons.arrow_downward, 'إيداع', 'dep', state)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _adminBtn(context, Icons.bar_chart, 'التقارير', () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportsScreen(state: state))))),
          const SizedBox(width: 8),
          Expanded(child: _adminBtn(context, Icons.history, 'السجل', () => Navigator.push(context, MaterialPageRoute(builder: (_) => LogScreen(state: state))))),
          const SizedBox(width: 8),
          Expanded(child: _adminBtn(context, Icons.people, 'الحسابات', () => _showAccountsModal(context, state))),
        ]),
        const SizedBox(height: 20),
      ]),
    );
  }

  Widget _quickBtn(BuildContext context, IconData icon, String title, String type, AppState state) {
    return GestureDetector(
      onTap: () => _showOpModal(context, state, type: type),
      child: Container(
        height: 90, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9C7B5B), Color(0xFF7B5F45)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line.withOpacity(0.5))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: AppColors.txtLight, size: 24)),
          const SizedBox(height: 8), Text(title, style: const TextStyle(color: AppColors.txtLight, fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _adminBtn(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 90, decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9C7B5B), Color(0xFF7B5F45)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line.withOpacity(0.5))),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: AppColors.txtLight, size: 24)),
          const SizedBox(height: 8), Text(title, style: const TextStyle(color: AppColors.txtLight, fontSize: 14, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }

  Widget _sumCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: const Color(0xFF2A2A2A), borderRadius: BorderRadius.circular(10), border: Border.all(color: color, width: 1.5)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [Text(title, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold)), const SizedBox(width: 4), Icon(icon, size: 14, color: color)]),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w900)),
      ]),
    );
  }

  Widget _midButton(IconData icon, String title, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF9C7B5B), Color(0xFF7B5F45)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
        child: Column(children: [
          Icon(icon, color: AppColors.txtLight, size: 22), const SizedBox(height: 6),
          Text(title, style: const TextStyle(color: AppColors.txtLight, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(height: 2),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
        ]),
      ),
    );
  }
}

// 6. التقارير
class ReportsScreen extends StatelessWidget {
  final AppState state;
  const ReportsScreen({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.dk2, title: const Text('التقارير', style: TextStyle(color: AppColors.txtLight)), iconTheme: const IconThemeData(color: AppColors.txtLight)),
      body: const Center(child: Text('شاشة التقارير (قيد التطوير)', style: TextStyle(color: AppColors.txtLight))),
    );
  }
}

// 7. السجل
class LogScreen extends StatelessWidget {
  final AppState state;
  const LogScreen({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.dk2, title: const Text('السجل', style: TextStyle(color: AppColors.txtLight)), iconTheme: const IconThemeData(color: AppColors.txtLight)),
      body: state.transactions.isEmpty ? const Center(child: Text('لا توجد حركات', style: TextStyle(color: AppColors.txtLight))) : ListView.builder(
        itemCount: state.transactions.length,
        itemBuilder: (context, i) {
          final tx = state.transactions[i];
          return ListTile(title: Text(tx.type, style: const TextStyle(color: AppColors.txtLight)), trailing: Text('${tx.amount}', style: const TextStyle(color: AppColors.gold)));
        },
      ),
    );
  }
}

// 8. الإعدادات
class SettingsScreen extends StatelessWidget {
  final AppState state;
  const SettingsScreen({super.key, required this.state});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(backgroundColor: AppColors.dk2, title: const Text('الإعدادات', style: TextStyle(color: AppColors.txtLight)), iconTheme: const IconThemeData(color: AppColors.txtLight)),
      body: const Center(child: Text('شاشة الإعدادات (قيد التطوير)', style: TextStyle(color: AppColors.txtLight))),
    );
  }
}

// 9. النوافذ المنبثقة
void _showOpModal(BuildContext context, AppState state, {String type = 'dep'}) {
  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) {
    final amountCtrl = TextEditingController();
    String? fromId, toId;
    return StatefulBuilder(builder: (context, setModalState) {
      return Container(
        padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('عملية: $type', style: const TextStyle(color: AppColors.txtLight, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          if (type != 'dep') DropdownButtonFormField<String>(decoration: InputDecoration(labelText: 'من الحساب', fillColor: AppColors.cream, filled: true), items: state.people.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(), onChanged: (v) => setModalState(() => fromId = v)),
          if (type != 'wd') DropdownButtonFormField<String>(decoration: InputDecoration(labelText: 'إلى الحساب', fillColor: AppColors.cream, filled: true), items: state.people.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(), onChanged: (v) => setModalState(() => toId = v)),
          const SizedBox(height: 10),
          TextField(controller: amountCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'المبلغ', fillColor: AppColors.sand, filled: true), textAlign: TextAlign.center),
          const SizedBox(height: 15),
          ElevatedButton(onPressed: () {
            final amt = double.tryParse(amountCtrl.text) ?? 0;
            if (amt > 0) {
              state.addTransaction(Transaction(id: DateTime.now().toString(), type: type, amount: amt, date: DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()), fromId: fromId, toId: toId));
              Navigator.pop(ctx);
            }
          }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.green), child: const Text('تنفيذ', style: TextStyle(color: Colors.white))),
        ]),
      );
    });
  });
}

void _showAccountsModal(BuildContext context, AppState state) {
  showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (ctx) => Container(
    padding: const EdgeInsets.all(20), decoration: const BoxDecoration(color: AppColors.bg, borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('الحسابات', style: TextStyle(color: AppColors.txtLight, fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      ...state.people.map((p) => ListTile(title: Text(p.name, style: const TextStyle(color: AppColors.txtLight)), trailing: Text('${p.total}', style: const TextStyle(color: AppColors.gold)))),
      ElevatedButton(onPressed: () => Navigator.pop(ctx), style: ElevatedButton.styleFrom(backgroundColor: AppColors.green), child: const Text('إغلاق', style: TextStyle(color: Colors.white))),
    ]),
  ));
}
