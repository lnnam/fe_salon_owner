import 'package:flutter/material.dart';
import 'constants.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/ui/home.dart';
import 'package:salonapp/ui/login.dart';
import 'package:salonapp/ui/dashboard.dart';
import 'package:salonapp/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  //runApp(const MyApp());
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('vn')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        useFallbackTranslations: true,
        useOnlyLangCode: true,
        child: const MyApp()),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static User? currentUser;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      title: 'BEAUTY SALON APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        
      ),
      // home: const Login(title: 'Salon management system'),
       initialRoute: '/',
      routes: {
        '/': (context) => AuthChecker(),
        '/dashboard': (context) => Dashboard(),
        '/login': (context) => Login(title: 'Salon management system'),
        '/logout': (context) => Login(title: 'Salon management system'),
      }, 
    );
  }
}


class AuthChecker extends StatelessWidget {
  
  static Future<bool> verifyToken(String? token) async {
    print(token);
    return false;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder<bool>(
      future: Future<bool>.delayed(Duration(seconds: 2), () => false), // Implement this method in ApiService
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data!) {
          return Dashboard();
        } else {
          return Login(title: 'Salon management system');
        }
      },
    );
  }
}

