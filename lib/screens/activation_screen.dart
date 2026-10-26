import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/theme.dart';
import '../core/license.dart';
import '../core/constants.dart';

class ActivationScreen extends StatefulWidget {
  final VoidCallback onActivated;
  const ActivationScreen({super.key, required this.onActivated});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final TextEditingController _keyController = TextEditingController();
  String _deviceId = 'جاري التحميل...';
  String? _errorMessage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final id = await LicenseManager.getDeviceId();
    if (mounted) {
      setState(() {
        _deviceId = id;
      });
    }
  }

  Future<void> _verifyActivation() async {
    final input = _keyController.text.trim();
    if (input.isEmpty) {
      setState(() => _errorMessage = '❌ يرجى إدخال رمز التفعيل');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await LicenseManager.activate(input);

    if (success) {
      widget.onActivated();
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = '❌ رمز التفعيل غير صحيح أو غير مخصص لهذا الهاتف!';
          _keyController.clear();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _contactDev() async {
    final msg = 'مرحباً، أريد تفعيل تطبيق MAMX.\nرمز جهازي هو: $_deviceId\nالرجاء إرسال رمز التفعيل.';
    final url = Uri.parse('https://wa.me/${AppConstants.devPhone}?text=${Uri.encodeComponent(msg)}');
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        setState(() => _errorMessage = 'تعذر فتح واتساب، هل هو مثبت؟');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // حساب الرمز وعرضه على الشاشة
    final correctKey = LicenseManager.generateLicenseKey(_deviceId);

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: AppTheme.cream,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.gold, width: 3),
              boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 15, offset: Offset(0, 5))],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('MAMX', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppTheme.green)),
                const SizedBox(height: 5),
                const Text('نظام إدارة الحسابات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.dk2)),
                const SizedBox(height: 20),
                const Text(
                  'هذا التطبيق محمي. يرجى إرسال رمز الجهاز التالي للمطور عبر واتساب للحصول على رمز التفعيل.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: AppTheme.ink, height: 1.5),
                ),
                const SizedBox(height: 15),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                  decoration: BoxDecoration(
                    color: AppTheme.sand,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.gold, width: 2),
                  ),
                  child: Text(
                    _deviceId,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 2, color: AppTheme.red),
                  ),
                ),
                const SizedBox(height: 10),
                const Text('تنبيه: هذا الرمز فريد لهاتفك ولا يعمل على أي هاتف آخر.', 
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: AppTheme.red, fontWeight: FontWeight.bold),
                ),
                
                // عرض الرمز الصحيح على الشاشة
                if (_deviceId != 'جاري التحميل...')
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text('رمز التفعيل الخاص بك: $correctKey', 
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.green)),
                  ),

                const SizedBox(height: 15),
                TextField(
                  controller: _keyController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'monospace', letterSpacing: 2, color: AppTheme.ink),
                  decoration: InputDecoration(
                    hintText: 'أدخل رمز التفعيل هنا...',
                    hintStyle: TextStyle(color: AppTheme.ink.withOpacity(0.4), fontFamily: 'Tahoma', letterSpacing: 0),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.line, width: 2)),
                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppTheme.gold, width: 2)),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  onChanged: (val) => _keyController.text = val.toUpperCase(),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(_errorMessage!, style: const TextStyle(color: AppTheme.red, fontSize: 13, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ],
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyActivation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: _isLoading 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('تفعيل التطبيق', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _contactDev,
                    icon: const Icon(Icons.message, color: Colors.white),
                    label: const Text('إرسال الرمز للمطور (واتساب)', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
