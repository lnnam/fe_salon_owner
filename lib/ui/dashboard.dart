import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:salonapp/constants.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/model/user.dart';
import 'package:salonapp/main.dart';
import 'package:salonapp/ui/common/drawer_dashboard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salonapp/constants.dart';
import 'package:salonapp/ui/booking/home.dart';
import 'package:salonapp/ui/pos/home.dart';


class Dashboard extends StatelessWidget {

  Future<User> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('objuser') ?? '{}';
    final userJson = json.decode(userData);
    return User.fromJson(userJson);
  }

  MyAppState.currentUser = _getUserInfo();

  @override
  Widget build(BuildContext context) {
    final color = Color(COLOR_PRIMARY);
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: color, // Set app bar color
      ),
      drawer: AppDrawerDashboard(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, salon name ${MyAppState.currentUser!.salonname}!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('User: ${MyAppState.currentUser!.username}'),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildDashboardButton(context, 'Appointment', Icons.event,
                    color, BookingHomeScreen()),
                _buildDashboardButton(context, 'Go Sale', Icons.shopping_cart,
                    color, SaleScreen()),
                _buildDashboardButton(context, 'Go Check-in',
                    Icons.check_circle, color, CheckInScreen()),
                _buildDashboardButton(context, 'Go Check-out',
                    Icons.check_circle_outline, color, CheckOutScreen()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: color,
        child: Container(
          height: 56.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => BookingHomeScreen()));
                },
                icon: Icon(Icons.event, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SaleScreen()));
                },
                icon: Icon(Icons.shopping_cart, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => CheckInScreen()));
                },
                icon: Icon(Icons.check_circle, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CheckOutScreen()));
                },
                icon: Icon(Icons.check_circle_outline, color: Colors.white),
              ),
            ],
          ),
        ),
      ), 
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title,
      IconData icon, Color color, Widget screen) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => screen));
        },
        child: Card(
          elevation: 3,
          color: color,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class CheckInScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-in'),
        backgroundColor: Colors.blue, // Set app bar color
      ),
      body: Center(
        child: Text('Check-in Screen'),
      ),
    );
  }
}

class CheckOutScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Check-out'),
        backgroundColor: Colors.blue, // Set app bar color
      ),
      body: Center(
        child: Text('Check-out Screen'),
      ),
    );
  }
}
