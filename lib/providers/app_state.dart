import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Person {
  String id;
  String name;
  Map<String, double> wallets;
  String phone;

  Person({required this.id, required this.name, required this.wallets, this.phone = ''});

  double get total => wallets.values.fold(0, (a, b) => a + b);

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'wallets': wallets, 'phone': phone};

  factory Person.fromJson(Map<String, dynamic> json) => Person(
    id: json['id'], 
    name: json['name'], 
    wallets: Map<String, double>.from(json['wallets']),
    phone: json['phone'] ?? '',
  );
}

class Transaction {
  String id;
  String type; // 'dep', 'wd', 'tr'
  double amount;
  String date;
  String? fromPersonId;
  String? toPersonId;
  String sourceDest;
  String note;

  Transaction({
    required this.id, required this.type, required this.amount, required this.date,
    this.fromPersonId, this.toPersonId, this.sourceDest = '', this.note = ''
  });

  Map<String, dynamic> toJson() => {
    'id': id, 'type': type, 'amount': amount, 'date': date, 
    'fromPersonId': fromPersonId, 'toPersonId': toPersonId, 
    'sourceDest': sourceDest, 'note': note
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'], type: json['type'], amount: json['amount'], date: json['date'],
    fromPersonId: json['fromPersonId'], toPersonId: json['toPersonId'],
    sourceDest: json['sourceDest'] ?? '', note: json['note'] ?? ''
  );
}

class Bank {
  String id;
  String name;
  Bank({required this.id, required this.name});
  Map<String, dynamic> toJson() => {'id': id, 'name': name};
  factory Bank.fromJson(Map<String, dynamic> json) => Bank(id: json['id'], name: json['name']);
}

class AppState extends ChangeNotifier {
  String currency = 'ج.س';
  List<Person> people = [];
  List<Transaction> transactions = [];
  List<Bank> banks = [];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('MAMX_DATA');
    if (data != null) {
      final json = jsonDecode(data);
      currency = json['currency'] ?? 'ج.س';
      people = (json['people'] as List).map((e) => Person.fromJson(e)).toList();
      transactions = (json['transactions'] as List).map((e) => Transaction.fromJson(e)).toList();
      banks = (json['banks'] as List).map((e) => Bank.fromJson(e)).toList();
    } else {
      // بيانات افتراضية عند أول تشغيل
      banks = [Bank(id: 'b1', name: 'بنك الخرطوم'), Bank(id: 'b2', name: 'بنك فيصل')];
      people = [
        Person(id: 'p1', name: 'أول ابتدائي', wallets: {'cash': 0}),
        Person(id: 'p2', name: 'ثاني ابتدائي', wallets: {'cash': 0}),
        Person(id: 'p3', name: 'ثالث ابتدائي', wallets: {'cash': 0}),
      ];
    }
    notifyListeners();
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode({
      'currency': currency,
      'people': people.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'banks': banks.map((e) => e.toJson()).toList(),
    });
    await prefs.setString('MAMX_DATA', data);
    notifyListeners();
  }

  Person? getPersonById(String? id) {
    if (id == null) return null;
    try { return people.firstWhere((p) => p.id == id); } catch (e) { return null; }
  }

  void addTransaction(Transaction tx) {
    if (tx.type == 'dep') {
      final p = getPersonById(tx.toPersonId);
      if (p != null) p.wallets['cash'] = (p.wallets['cash'] ?? 0) + tx.amount;
    } else if (tx.type == 'wd') {
      final p = getPersonById(tx.fromPersonId);
      if (p != null) p.wallets['cash'] = (p.wallets['cash'] ?? 0) - tx.amount;
    } else if (tx.type == 'tr') {
      final from = getPersonById(tx.fromPersonId);
      final to = getPersonById(tx.toPersonId);
      if (from != null) from.wallets['cash'] = (from.wallets['cash'] ?? 0) - tx.amount;
      if (to != null) to.wallets['cash'] = (to.wallets['cash'] ?? 0) + tx.amount;
    }
    transactions.insert(0, tx);
    save();
  }
}
