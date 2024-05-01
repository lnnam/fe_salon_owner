import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:salonapp/constants.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/model/user.dart';
import 'package:salonapp/main.dart';
import 'package:salonapp/ui/common/drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:salonapp/constants.dart';


class Dashboard extends StatelessWidget {
  Future<User> _getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('objuser') ?? '{}';
    final userJson = json.decode(userData);
    return User.fromJson(userJson);
  }

  @override
  Widget build(BuildContext context) {
     final color = Color(COLOR_PRIMARY);
    return Scaffold(
      appBar: AppBar(
        title: Text(MyAppState.currentUser!.salonname,style: TextStyle(color: Colors.white)),
        backgroundColor: color, // Set app bar color
      ),
      drawer: AppDrawer(),
      body:
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome,sdfds!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('User ID: '),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildDashboardButton(context, 'Appointment', Icons.event, color, AppointmentScreen()),
                _buildDashboardButton(context, 'Go Sale', Icons.shopping_cart, color, SaleScreen()),
                _buildDashboardButton(context, 'Go Check-in', Icons.check_circle, color, CheckInScreen()),
                _buildDashboardButton(context, 'Go Check-out', Icons.check_circle_outline, color, CheckOutScreen()),
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => AppointmentScreen()));
                },
                icon: Icon(Icons.event, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SaleScreen()));
                },
                icon: Icon(Icons.shopping_cart, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CheckInScreen()));
                },
                icon: Icon(Icons.check_circle, color: Colors.white),
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CheckOutScreen()));
                },
                icon: Icon(Icons.check_circle_outline, color: Colors.white),
              ),
            ],
          ),
        ),
      ), /* GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(20.0),
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        children: <Widget>[
          Center(
            child: FutureBuilder<User>(
              future: _getUserInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final user = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Welcome, ${user.username}!'),
                      Text('Data: ${user.token}'),
                      // Add more widgets to display other user details as needed
                    ],
                  );
                }
              },
            ),
          ),
         
        ],
      ), */
    );
  }

  Widget _buildDashboardButton(BuildContext context, String title, IconData icon, Color color, Widget screen) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class AppointmentScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointment'),
        backgroundColor: Colors.blue, // Set app bar color
      ),
      body: Center(
        child: Text('Appointment Screen'),
      ),
    );
  }
}

class SaleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sale'),
        backgroundColor: Colors.blue, // Set app bar color
      ),
      body: Center(
        child: Text('Sale Screen'),
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
