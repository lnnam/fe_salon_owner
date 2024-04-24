import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:salonapp/constants.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/model/user.dart';
import 'package:salonapp/main.dart';
import 'package:salonapp/ui/common/drawer.dart';


class Dashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(MyAppState.currentUser!.username),
      ),
      drawer: AppDrawer(),
      body: GridView.count(
        crossAxisCount: 2,
        padding: EdgeInsets.all(20.0),
        crossAxisSpacing: 20.0,
        mainAxisSpacing: 20.0,
        children: <Widget>[
          DashboardButton(
            title: 'Button 1',
            color: Colors.red,
            onPressed: () {
              // Add action for button 1
            },
          ),
          DashboardButton(
            title: 'Button 2',
            color: Colors.green,
            onPressed: () {
              // Add action for button 2
            },
          ),
          DashboardButton(
            title: 'Button 3',
            color: Colors.blue,
            onPressed: () {
              // Add action for button 3
            },
          ),
          DashboardButton(
            title: 'Button 4',
            color: Colors.orange,
            onPressed: () {
              // Add action for button 4
            },
          ),
        ],
      ),
    );
  }
}

class DashboardButton extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onPressed;

  DashboardButton({
    required this.title,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(COLOR_PRIMARY),
        padding: EdgeInsets.all(20.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Text(
        title,
        style: TextStyle(fontSize: 18.0, color: Colors.white),
      ),
    );
  }
}
