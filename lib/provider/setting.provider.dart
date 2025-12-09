import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingProvider with ChangeNotifier {
  Map<String, dynamic>? _appSettings;
  Map<String, dynamic>? _bookingSettings;
  String? salonName;
  String? sms_pending;
  String? sms_confirm;
  String? email;
  bool _isInitialized = false;

  SettingProvider() {
    // Try to load settings from SharedPreferences on initialization
    // Note: This is called without await because it's in constructor
    // The _loadSettingsFromStorage completes asynchronously
    _loadSettingsFromStorage().then((_) {
      print('[SettingProvider] Constructor - Settings loaded from storage');
    }).catchError((e) {
      print('[SettingProvider] Constructor - Error loading settings: $e');
    });
    print(
        '[SettingProvider] Constructor called - Settings loading in background');
  }

  // Getter for app settings
  Map<String, dynamic>? get appSettings => _appSettings;

  // Getter for booking settings
  Map<String, dynamic>? get bookingSettings => _bookingSettings;

  // Getter to check if settings have been loaded
  bool get isInitialized => _isInitialized;

  // Load settings from SharedPreferences on initialization
  Future<void> _loadSettingsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('appSettings');

      if (settingsJson != null && settingsJson.isNotEmpty) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        _appSettings = settings;

        // Parse individual fields
        salonName = settings['salon_name'] as String?;
        sms_pending = settings['sms_pending'] as String?;
        sms_confirm = settings['sms_confirm'] as String? ??
            settings['smsConfirm'] as String? ??
            settings['sms_confirmation'] as String? ??
            sms_pending;
        email = settings['email'] as String?;

        print(
            '[SettingProvider] Loaded settings from storage - salonName: $salonName, sms_pending: $sms_pending, sms_confirm: $sms_confirm');
        _isInitialized = true;
      }

      // Also load booking settings
      final bookingJson = prefs.getString('bookingSettings');
      if (bookingJson != null && bookingJson.isNotEmpty) {
        final bookingSettings = jsonDecode(bookingJson) as Map<String, dynamic>;
        _bookingSettings = bookingSettings;
        print(
            '[SettingProvider] Loaded booking settings from storage: $bookingSettings');
      }
    } catch (e) {
      print('[SettingProvider] Error loading settings from storage: $e');
    }
  }

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
    print(
        '[SettingProvider] updateAppSettings - Raw settings keys: ${settings.keys.toList()}');
    print('[SettingProvider] updateAppSettings - Full settings: $settings');

    salonName = settings['salon_name'] as String?;
    sms_pending = settings['sms_pending'] as String?;

    // Try multiple field name variations for sms_confirm
    // If sms_confirm is not provided, fall back to sms_pending
    sms_confirm = settings['sms_confirm'] as String? ??
        settings['smsConfirm'] as String? ??
        settings['sms_confirmation'] as String? ??
        sms_pending;

    email = settings['email'] as String?;
    print(
        '[SettingProvider] Updated settings - salonName: $salonName, sms_pending: $sms_pending, sms_confirm: $sms_confirm, email: $email');

    // Mark as initialized AFTER settings are loaded
    _isInitialized = true;

    // Save to SharedPreferences
    _saveSettings(settings);

    notifyListeners();
  }

  // Method to update booking settings
  void updateBookingSettings(Map<String, dynamic> settings) {
    // Ensure num_staff_for_autobooking is safe for string conversion
    final sanitized = Map<String, dynamic>.from(settings);
    if (sanitized.containsKey('num_staff_for_autobooking')) {
      final value = sanitized['num_staff_for_autobooking'];
      // Safe conversion: if null, use '0', otherwise convert to string
      sanitized['num_staff_for_autobooking'] =
          value == null ? '0' : value.toString();
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

      // Explicitly convert num_staff_for_autobooking to string if present
      if (sanitizedSettings.containsKey('num_staff_for_autobooking')) {
        final value = sanitizedSettings['num_staff_for_autobooking'];
        // Convert any type to string safely
        sanitizedSettings['num_staff_for_autobooking'] =
            value == null ? '0' : value.toString();
        print(
            '[SettingProvider] Converting num_staff_for_autobooking: $value -> ${sanitizedSettings['num_staff_for_autobooking']}');
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
    sms_pending = null;
    sms_confirm = null;
    email = null;
    _isInitialized = false;
    print('[SettingProvider] Reset all settings');
    notifyListeners();
  }

  // Clear all settings from SharedPreferences (call on logout)
  Future<void> clearSettingsStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('appSettings');
      await prefs.remove('bookingSettings');
      print('[SettingProvider] Cleared settings from storage');
    } catch (e) {
      print('[SettingProvider] Error clearing settings from storage: $e');
    }
  }

  // Get individual setting values from SharedPreferences directly
  Future<String?> getSalonName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('appSettings');
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        return settings['salon_name'] as String?;
      }
    } catch (e) {
      print('[SettingProvider] Error getting salonName: $e');
    }
    return null;
  }

  Future<String?> getSmsPending() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('appSettings');
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        return settings['sms_pending'] as String?;
      }
    } catch (e) {
      print('[SettingProvider] Error getting sms_pending: $e');
    }
    return null;
  }

  Future<String?> getSmsConfirm() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('appSettings');
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        return settings['sms_confirm'] as String? ??
            settings['smsConfirm'] as String? ??
            settings['sms_confirmation'] as String? ??
            settings['sms_pending'] as String?;
      }
    } catch (e) {
      print('[SettingProvider] Error getting sms_confirm: $e');
    }
    return null;
  }

  Future<String?> getEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final settingsJson = prefs.getString('appSettings');
      if (settingsJson != null) {
        final settings = jsonDecode(settingsJson) as Map<String, dynamic>;
        return settings['email'] as String?;
      }
    } catch (e) {
      print('[SettingProvider] Error getting email: $e');
    }
    return null;
  }
}
