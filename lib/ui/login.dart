import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:salonapp/constants.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/model/user.dart';
import 'package:salonapp/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:salonapp/provider/setting.provider.dart';

class Login extends StatefulWidget {
  const Login({super.key});
  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _key = GlobalKey();
  String? salonkey, username, password;
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final formWidth = screenWidth > 560 ? 460.0 : screenWidth;

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Beauty Salon', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(COLOR_PRIMARY),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(COLOR_PRIMARY).withOpacity(0.08),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: formWidth),
                child: Card(
                  elevation: 2,
                  shadowColor: Colors.black12,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
                    child: Form(
                      key: _key,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Text(
                            'signIn',
                            style: TextStyle(
                              color: Color(COLOR_PRIMARY),
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ).tr(),
                         
                          const SizedBox(height: 18),
                          TextFormField(
                            initialValue: 'uk0001',
                            textInputAction: TextInputAction.next,
                            validator: validateFeild,
                            onSaved: (String? val) {
                              salonkey = val;
                            },
                            cursorColor: const Color(COLOR_PRIMARY),
                            decoration: InputDecoration(
                              labelText: 'Salon ID'.tr(),
                              prefixIcon: const Icon(Icons.storefront_outlined),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(COLOR_PRIMARY),
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            initialValue: 'lnnam',
                            textInputAction: TextInputAction.next,
                            validator: validateName,
                            onSaved: (String? val) {
                              username = val;
                            },
                            cursorColor: const Color(COLOR_PRIMARY),
                            decoration: InputDecoration(
                              labelText: 'Username'.tr(),
                              prefixIcon: const Icon(Icons.person_outline),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(COLOR_PRIMARY),
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            initialValue: 'lnnam',
                            obscureText: _obscurePassword,
                            validator: validatePassword,
                            onSaved: (String? val) {
                              password = val;
                            },
                            onFieldSubmitted: (value) => _login(),
                            textInputAction: TextInputAction.done,
                            cursorColor: const Color(COLOR_PRIMARY),
                            decoration: InputDecoration(
                              labelText: 'Password'.tr(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFF),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(COLOR_PRIMARY),
                                  width: 1.6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 22),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(COLOR_PRIMARY),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () => _login(),
                              child: Text(
                                'Login'.tr(),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_key.currentState?.validate() ?? false) {
      _key.currentState!.save();

      try {
        dynamic result = await apiManager.salonLogin(
            salonkey!.trim(), username!.trim(), password!.trim());

        print('salonLogin result: ${result.toString()}');

        if (result != null && result is User) {
          // Save token and user info
          if (kIsWeb) {
            // Store in cookies
            //setCookie('objuser', json.encode(result.toJson()));
            await setUserInfo(result);
          } else {
            // Store in SharedPreferences

            await setUserInfo(result);
          }
          MyAppState.currentUser = result;

          // Fetch app settings after successful login
          print('[Login] Starting to fetch app settings...');
          final settings = await apiManager.fetchAppSettings(result.token);
          print('[Login] Fetched App Settings: $settings');
          if (settings != null) {
            final settingProvider =
                Provider.of<SettingProvider>(context, listen: false);
            settingProvider.updateAppSettings(settings);

            // Map the booking settings from the API response
            // Use database field names for consistency
            final bookingSettingsData = {
              'pkey': settings['pkey'] ?? '',
              'num_staff_for_autobooking':
                  settings['num_staff_for_autobooking'] ?? 4,
              'onoff': settings['onoff'] ?? 'true',
              'sundayoff': settings['sundayoff'] ?? 'false',
              'autoconfirm': settings['autoconfirm'] ?? 'false',
              'aicheck': settings['ai_check'] ?? 'no',
              'listoffday': settings['listoffday'] ?? '',
              'listhouroff': settings['listhouroff'] ?? '',
            };
            settingProvider.updateBookingSettings(bookingSettingsData);
          } else {
            print('[Login] Failed to fetch app settings');
          }

          safePushReplacementNamed(context, '/booking');
        } else {
          showAlertDialog(context, 'Couldn\'t Authenticate'.tr(),
              'Login failed, Please try again.'.tr());
        }
      } catch (e) {
        print('[Login] Error during login: $e');

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            backgroundColor: Colors.white,
            title: Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red.shade600,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Server connection issue',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFC62828),
                    ),
                  ),
                ],
              ),
            ),
            content: const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'Server connection issue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(COLOR_PRIMARY),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Try Again'),
                ),
              ),
            ],
          ),
        );
      }
    }
  }

  // Function to set the cookie on the web platform
/*   void setCookie(String name, String value) {
    final cookieString = '$name=$value; Path=/';
    html.window.document.cookie = cookieString;
  } */

  // Function to save user information using SharedPreferences
  Future<void> setUserInfo(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', user.token);
    await prefs.setString('objuser', json.encode(user.toJson()));
  }
}
