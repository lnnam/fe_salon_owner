import 'package:flutter/material.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/constants.dart';


class AppDrawerBooking extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color:  Color(COLOR_PRIMARY),
            ),
            child: Text(
              'Salon name ',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Dashboard'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          ListTile(
            title: Text('Go Sale'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/setting');
            },
          ),
          ListTile(
            title: Text('Go Checkout'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/setting');
            },
          ),
        ],
      ),
    );
  }
}
