import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LicenseManager {
  static const String _keyActivated = 'MAMX_ACTIVATED';
  static const String _keyLicense = 'MAMX_LICENSE_KEY';
  static const String _keyDeviceId = 'MAMX_DEVICE_ID';

  static Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString(_keyDeviceId);
    if (storedId != null) return storedId;

    final deviceInfo = DeviceInfoPlugin();
    String raw = '';

    try {
      if (kIsWeb) {
        final webInfo = await deviceInfo.webBrowserInfo;
        raw = '${webInfo.userAgent}${webInfo.vendor}';
      } else if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        raw = '${androidInfo.id}${androidInfo.model}${androidInfo.device}${androidInfo.version.release}';
      } else {
        final webInfo = await deviceInfo.webBrowserInfo;
        raw = '${webInfo.userAgent}${webInfo.vendor}';
      }
    } catch (_) {
      raw = 'default_device_id';
    }

    final bytes = utf8.encode(raw);
    final digest = md5.convert(bytes);
    String hex = digest.toString().toUpperCase();
    
    storedId = '${hex.substring(0, 4)}-${hex.substring(4, 8)}';
    await prefs.setString(_keyDeviceId, storedId);
    
    return storedId;
  }

  static String generateLicenseKey(String deviceId) {
    final cleanId = deviceId.replaceAll('-', '');
    int hash = 0;
    for (int i = 0; i < cleanId.length; i++) {
      hash = ((hash << 5) - hash) + cleanId.codeUnitAt(i);
      hash |= 0;
    }
    hash = hash ^ 0x2008009;
    hash = hash * 31;
    String hex = hash.abs().toRadixString(16).toUpperCase().padLeft(8, '0');
    return 'M${hex.substring(0, 3)}-${hex.substring(3, 7)}';
  }

  // دالة مساعدة لطباعة الرمز (للتجربة فقط)
  static void printDebugLicense() {
    generateLicenseKey('B014-54E1').split('').forEach((char) {
      print('LicenseChar: $char');
    });
    print('YOUR_LICENSE_IS: ${generateLicenseKey('B014-54E1')}');
  }

  static Future<bool> isActivated() async {
    final prefs = await SharedPreferences.getInstance();
    final isAct = prefs.getBool(_keyActivated) ?? false;
    final savedKey = prefs.getString(_keyLicense);

    if (isAct && savedKey != null) {
      final deviceId = await getDeviceId();
      final expectedKey = generateLicenseKey(deviceId);
      
      if (savedKey == expectedKey) return true;
      else {
        await prefs.remove(_keyActivated);
        await prefs.remove(_keyLicense);
      }
    }
    return false;
  }

  static Future<bool> activate(String inputKey) async {
    final deviceId = await getDeviceId();
    final expectedKey = generateLicenseKey(deviceId);

    if (inputKey.trim().toUpperCase() == expectedKey) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyActivated, true);
      await prefs.setString(_keyLicense, inputKey.trim().toUpperCase());
      return true;
    }
    return false;
  }
}
