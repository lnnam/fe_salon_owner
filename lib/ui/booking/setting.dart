import 'package:flutter/material.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/constants.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'package:salonapp/provider/setting.provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  late TextEditingController _numStaffController;
  late TextEditingController _hoursOffController;
  bool _autoBooking = true;
  bool _openSunday = false;
  bool _aiConfirm = false;
  List<DateTime> _selectedDaysOff = [];

  @override
  void initState() {
    super.initState();
    _numStaffController = TextEditingController(text: '4');
    _hoursOffController = TextEditingController(text: '18,19,20,');
    
    // Pause booking auto-refresh when opening this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.pauseAutoRefresh();
      print('[SettingPage] Opened, auto-refresh paused');
      
      // Load booking settings from provider
      _loadSettingsFromProvider();
    });
  }

  void _loadSettingsFromProvider() {
    final settingProvider =
        Provider.of<SettingProvider>(context, listen: false);
    
    if (settingProvider.bookingSettings != null) {
      final settings = settingProvider.bookingSettings!;
      print('[SettingPage] Loading settings from provider: $settings');
      _applySettings(settings);
    } else {
      // Provider is empty after page reload, load from SharedPreferences
      print('[SettingPage] Provider is empty, loading from SharedPreferences');
      _loadSettingsFromStorage();
    }
  }

  void _applySettings(Map<String, dynamic> settings) {
    setState(() {
      // Load numeric value - ensure it's converted to string for TextField
      if (settings['numStaffAutoBooking'] != null) {
        final value = settings['numStaffAutoBooking'];
        _numStaffController.text = value.toString();
      }
      
      // Load boolean values - database stores as strings 'true'/'false'
      _autoBooking = _parseBooleanString(settings['onOff']);
      _openSunday = _parseBooleanString(settings['openSunday']);
      _aiConfirm = _parseBooleanString(settings['aiConfirm']);
      
      print('[SettingPage] Parsed booleans - onOff: ${settings['onOff']} -> $_autoBooking, openSunday: ${settings['openSunday']} -> $_openSunday, aiConfirm: ${settings['aiConfirm']} -> $_aiConfirm');
      
      // Load hours off - ensure it's a string
      if (settings['hoursOff'] != null) {
        final hoursValue = settings['hoursOff'];
        _hoursOffController.text = hoursValue.toString();
      }
      
      // Load days off
      if (settings['daysOff'] != null && settings['daysOff'].toString().isNotEmpty) {
        _selectedDaysOff.clear();
        final dateFormat = RegExp(r'(\d{4})-(\d{2})-(\d{2})');
        final matches = dateFormat.allMatches(settings['daysOff'].toString());
        for (var match in matches) {
          final year = int.parse(match.group(1)!);
          final month = int.parse(match.group(2)!);
          final day = int.parse(match.group(3)!);
          _selectedDaysOff.add(DateTime(year, month, day));
        }
        _selectedDaysOff.sort();
      }
    });
  }

  Future<void> _loadSettingsFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookingSettingsJson = prefs.getString('bookingSettings');
      
      if (bookingSettingsJson != null) {
        final bookingSettings = jsonDecode(bookingSettingsJson) as Map<String, dynamic>;
        print('[SettingPage] Loaded booking settings from SharedPreferences: $bookingSettings');
        
        // Also update the provider so it has the data
        final settingProvider = Provider.of<SettingProvider>(context, listen: false);
        settingProvider.updateBookingSettings(bookingSettings);
        
        _applySettings(bookingSettings);
      } else {
        print('[SettingPage] No settings in SharedPreferences, using defaults');
        _setDefaultValues();
      }
    } catch (e) {
      print('[SettingPage] Error loading from storage: $e');
      _setDefaultValues();
    }
  }

  /// Parse boolean string values from database
  /// Database stores: 'true' or 'false' (lowercase strings)
  bool _parseBooleanString(dynamic value) {
    if (value == null) return false;
    
    if (value is bool) return value;
    if (value is int) return value == 1;
    
    if (value is String) {
      final lowerValue = value.toLowerCase().trim();
      // Handle database string values
      return lowerValue == 'true' || lowerValue == '1' || lowerValue == 'on' || lowerValue == 'yes';
    }
    
    return false;
  }

  void _setDefaultValues() {
    setState(() {
      _numStaffController.text = '1';
      _hoursOffController.text = '';
      _autoBooking = true;
      _openSunday = false;
      _aiConfirm = false;
      
      _selectedDaysOff.clear();
      final defaultDaysStr = '';
      final dateFormat = RegExp(r'(\d{4})-(\d{2})-(\d{2})');
      final matches = dateFormat.allMatches(defaultDaysStr);
      for (var match in matches) {
        final year = int.parse(match.group(1)!);
        final month = int.parse(match.group(2)!);
        final day = int.parse(match.group(3)!);
        _selectedDaysOff.add(DateTime(year, month, day));
      }
    });
  }

  @override
  void dispose() {
    // Resume booking auto-refresh when closing this page
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.resumeAutoRefresh();
    print('[SettingPage] Closed, auto-refresh resumed');
    
    _numStaffController.dispose();
    _hoursOffController.dispose();
    super.dispose();
  }

  void _saveSettings() async {
    try {
      // Get setting provider first
      final settingProvider =
          Provider.of<SettingProvider>(context, listen: false);
      
      // Get the pkey value - it should be preserved from the initial load
      String pkeyValue = '';
      if (settingProvider.bookingSettings != null) {
        // Check if pkey is in the nested setting object
        if (settingProvider.bookingSettings!['setting'] is Map) {
          pkeyValue = settingProvider.bookingSettings!['setting']['pkey'] ?? '';
        } else {
          // Or check if it's at the top level (from first save)
          pkeyValue = settingProvider.bookingSettings!['settingkey'] ?? '';
        }
      }
      
      // Validate num staff input
      final staffText = _numStaffController.text.trim();
      if (staffText.isEmpty) {
        showAlertDialog(context, 'Error', 'NUM STAFF FOR AUTO BOOKING cannot be empty');
        return;
      }
      
      // Collect all settings data
      final numStaff = int.parse(staffText);
      
      // Convert selected days to string format (YYYY-MM-DD,YYYY-MM-DD,...)
      final daysOffString = _selectedDaysOff
          .map((date) => '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}')
          .join(',');
      
      // Get hours off string
      final hoursOff = _hoursOffController.text;

      // Build settings object for API - match database field names (numStaff is int)
      final settingsData = {
        'setting': {
          'pkey': pkeyValue,
          'num_staff_for_autobooking': numStaff,  // Keep as int for API
          'onoff': _autoBooking ? 'true' : 'false',
          'sundayoff': _openSunday ? 'true' : 'false',
          'autoconfirm': _aiConfirm ? 'true' : 'false',
          'listoffday': daysOffString,
          'listhouroff': hoursOff,
        }
      };

      print('[SettingPage] Saving settings: $settingsData');

      // Update provider (local storage) - store with original int type for consistency with provider
      // (provider will handle conversion to string in updateBookingSettings)
      final bookingSettingsToStore = {
        'settingkey': pkeyValue,
        'numStaffAutoBooking': numStaff,  // Keep as int - provider will convert to string when saving
        'onOff': _autoBooking ? 'true' : 'false',
        'openSunday': _openSunday ? 'true' : 'false',
        'aiConfirm': _aiConfirm ? 'true' : 'false',
        'daysOff': daysOffString,
        'hoursOff': hoursOff,
      };
      settingProvider.updateBookingSettings(bookingSettingsToStore);

      // TODO: Call API to save settings to backend
      // Uncomment when API is ready:
      // final result = await apiManager.SaveBookingSetting(settingsData);
      // if (result) {
      //   showAlertDialog(context, 'Success', 'Settings saved successfully');
      // } else {
      //   showAlertDialog(context, 'Error', 'Failed to save settings');
      // }

      // Show the exact data object being posted
      showAlertDialog(
        context,
        'Success - Data Sent',
        bookingSettingsToStore.toString(),
      );
    } catch (e, stackTrace) {
      print('[SettingPage] Error saving settings: $e');
      print('[SettingPage] Stack trace: $stackTrace');
      showAlertDialog(
        context,
        'Error',
        'Failed to save settings: $e',
      );
    }
  }

  void _showDaysOffPicker() async {
    final now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 1),
    );

    if (pickedDate != null) {
      setState(() {
        // Check if date is already selected
        final isExists = _selectedDaysOff.any(
          (date) =>
              date.year == pickedDate.year &&
              date.month == pickedDate.month &&
              date.day == pickedDate.day,
        );

        if (!isExists) {
          _selectedDaysOff.add(pickedDate);
          // Sort the list
          _selectedDaysOff.sort();
        } else {
          // Show a message that this date is already selected
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This date is already selected'),
              duration: Duration(seconds: 1),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System'),
        elevation: 0,
        backgroundColor: const Color(COLOR_PRIMARY),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NUM STAFF FOR AUTO BOOKING
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Expanded(
                      child: Text(
                        'NUM STAFF FOR AUTO BOOKING',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      child: TextField(
                        controller: _numStaffController,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ON / OFF TOGGLE
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ON / OFF',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: _autoBooking,
                      onChanged: (value) {
                        setState(() {
                          _autoBooking = value;
                        });
                      },
                      activeColor: const Color(COLOR_PRIMARY),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // SUNDAY OFF
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SUNDAY OFF',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: _openSunday,
                      onChanged: (value) {
                        setState(() {
                          _openSunday = value;
                        });
                      },
                      activeColor: const Color(COLOR_PRIMARY),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // AI CONFIRM
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'AI Confirm',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Switch(
                      value: _aiConfirm,
                      onChanged: (value) {
                        setState(() {
                          _aiConfirm = value;
                        });
                      },
                      activeColor: const Color(COLOR_PRIMARY),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // DAYS OFF
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DAYS off',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _showDaysOffPicker,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(COLOR_PRIMARY),
                      ),
                      child: const Text(
                        'Select Days Off',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_selectedDaysOff.isNotEmpty)
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedDaysOff
                            .map((date) => Chip(
                              label: Text(
                                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}',
                              ),
                              onDeleted: () {
                                setState(() {
                                  _selectedDaysOff.remove(date);
                                });
                              },
                              deleteIcon: const Icon(Icons.close, size: 18),
                            ))
                            .toList(),
                      )
                    else
                      Text(
                        'No days selected',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // HOURS OFF
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hours off',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _hoursOffController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Hour numbers separated by comma (e.g., 18,19,20,)',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // SAVE BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(COLOR_PRIMARY),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    'Save Settings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
