import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingProvider with ChangeNotifier {
  Map<String, dynamic>? _appSettings;
  Map<String, dynamic>? _bookingSettings;
  String? salonName;
  String? sms;
  String? email;
  bool _isInitialized = false;

  SettingProvider() {
    // Don't auto-load from cache - wait for explicit login to load from API
    _isInitialized = true;
  }

  // Getter for app settings
  Map<String, dynamic>? get appSettings => _appSettings;
  
  // Getter for booking settings
  Map<String, dynamic>? get bookingSettings => _bookingSettings;
  
  // Getter to check if settings have been loaded
  bool get isInitialized => _isInitialized;
  
  // Future that completes when settings are loaded
  Future<void> waitForInitialization() async {
    int attempts = 0;
    while (!_isInitialized && attempts < 50) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }
  }

  // Method to update app settings
  void updateAppSettings(Map<String, dynamic> settings) {
    _appSettings = settings;
    salonName = settings['salon_name'] as String?;
    sms = settings['sms'] as String?;
    email = settings['email'] as String?;
    print('[SettingProvider] Updated settings - salonName: $salonName, sms: $sms, email: $email');
    
    // Save to SharedPreferences
    _saveSettings(settings);
    
    notifyListeners();
  }

  // Method to update booking settings
  void updateBookingSettings(Map<String, dynamic> settings) {
    // Ensure numStaffAutoBooking is safe for string conversion
    final sanitized = Map<String, dynamic>.from(settings);
    if (sanitized.containsKey('numStaffAutoBooking')) {
      final value = sanitized['numStaffAutoBooking'];
      // Safe conversion: if null, use '0', otherwise convert to string
      sanitized['numStaffAutoBooking'] = value == null ? '0' : value.toString();
    }
    
    _bookingSettings = sanitized;
    print('[SettingProvider] Updated booking settings: $sanitized');
    
    // Save booking settings to SharedPreferences
    _saveBookingSettings(sanitized);
    
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

  // Save booking settings to SharedPreferences
  Future<void> _saveBookingSettings(Map<String, dynamic> settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Ensure all values are properly typed for JSON encoding
      final sanitizedSettings = Map<String, dynamic>.from(settings);
      
      // Explicitly convert numStaffAutoBooking to string if present
      if (sanitizedSettings.containsKey('numStaffAutoBooking')) {
        final value = sanitizedSettings['numStaffAutoBooking'];
        // Convert any type to string safely
        sanitizedSettings['numStaffAutoBooking'] = value == null ? '0' : value.toString();
        print('[SettingProvider] Converting numStaffAutoBooking: $value -> ${sanitizedSettings['numStaffAutoBooking']}');
      }
      
      final jsonString = jsonEncode(sanitizedSettings);
      print('[SettingProvider] JSON to save: $jsonString');
      await prefs.setString('bookingSettings', jsonString);
      print('[SettingProvider] Booking settings saved to storage successfully');
    } catch (e, stackTrace) {
      print('[SettingProvider] Error saving booking settings: $e');
      print('[SettingProvider] Stack trace: $stackTrace');
      rethrow; // Re-throw so the caller knows there was an error
    }
  }

  // Reset all settings (call on logout)
  void resetSettings() {
    _appSettings = null;
    _bookingSettings = null;
    salonName = null;
    sms = null;
    email = null;
    _isInitialized = false;
    print('[SettingProvider] Reset all settings');
    notifyListeners();
  }
}