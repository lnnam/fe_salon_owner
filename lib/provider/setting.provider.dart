import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingProvider with ChangeNotifier {
  Map<String, dynamic>? _appSettings;
  String? salonName;
  String? sms;
  String? email;

  SettingProvider() {
    _loadSettings();
  }

  // Getter for app settings
  Map<String, dynamic>? get appSettings => _appSettings;

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('appSettings');
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        print('[SettingProvider] Loaded settings from storage: $settings');
        updateAppSettings(settings);
      }
    } catch (e) {
      print('[SettingProvider] Error loading settings: $e');
    }
  }

  // Method to update app settings
  void updateAppSettings(Map<String, dynamic> settings) {
    _appSettings = settings;
    salonName = settings['salon_name'] as String?;
    sms = settings['sms'] as String?;
    email = settings['salon_email'] as String?;
    print('[SettingProvider] Updated settings - salonName: $salonName, sms: $sms, email: $email');
    
    // Save to SharedPreferences
    _saveSettings(settings);
    
    notifyListeners();
  }

  // Save settings to SharedPreferences
  Future<void> _saveSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('appSettings', jsonEncode(settings));
      print('[SettingProvider] Settings saved to storage');
    } catch (e) {
      print('[SettingProvider] Error saving settings: $e');
    }
  }
}