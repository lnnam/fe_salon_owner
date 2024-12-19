import 'constants.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/ui/home.dart';
import 'package:salonapp/ui/login.dart';
import 'package:salonapp/ui/dashboard.dart';
import 'package:salonapp/model/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salonapp/ui/pos/home.dart';
import 'package:salonapp/ui/booking/home.dart';
import 'package:flutter/rendering.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'package:provider/provider.dart';


 void main() async {
    debugPaintBaselinesEnabled = true; // Enable debug paint


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
        child: ChangeNotifierProvider(
        create: (context) => BookingProvider(),
        child: MyApp(),
      ),),
  );
} 


class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static User? currentUser;
 // static Future<User> currentUser;

  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
  }

  Future<void> _initializeCurrentUser() async {
    final user = await _getUserInfo();
    setState(() {
      currentUser = user;
          print('fdsfdsfdsfsdfsdfsdf');

    });
  }


  Future<User> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('objuser') ?? '{}';
    final userJson = json.decode(userData);
    return User.fromJson(userJson);
  }

  @override
  Widget build(BuildContext context) {
    const color = Color(COLOR_PRIMARY);
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      title: 'BEAUTY SALON APP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
       
        appBarTheme: AppBarTheme(
          color: color, // Set default app bar background color
          iconTheme: IconThemeData(color: Colors.white),
         titleTextStyle: Theme.of(context).textTheme.headline6?.copyWith(
        fontFamily: 'OpenSans',
        fontSize: 20,
        color: Colors.white,
      ),
        ),
        
      ),
      // home: AuthChecker(),
      initialRoute: '/',
      routes: {
        '/': (context) => AuthChecker(),
        '/dashboard': (context) => AuthChecker(),
        '/booking': (context) => BookingHomeScreen(),
        '/pos': (context) => SaleScreen(),
        '/checkin': (context) => CheckInScreen(),
        '/checkout': (context) => CheckOutScreen(),
        '/login': (context) => Login(),
        '/logout': (context) => Login(),
      },
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          if (snapshot.hasData && snapshot.data == true) {
            // Token is saved, proceed to main app
            // Update currentUser in MyAppState
            return Dashboard();
          } else {
            // Token is not saved, navigate to login page
            return Login();
          }
        }
      },
    );
  }

  Future<bool> _checkToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null;
  }
}
