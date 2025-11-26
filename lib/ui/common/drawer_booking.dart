import 'package:flutter/material.dart';
import 'package:salonapp/constants.dart';
import 'package:salonapp/services/helper.dart';

class AppDrawerBooking extends StatelessWidget {
  const AppDrawerBooking({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Color(COLOR_PRIMARY),
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
            title: const Text('Dashboard'),
            onTap: () {
              safePushReplacementNamed(context, '/dashboard');
            },
          ),
          ListTile(
            title: const Text('Go Sale'),
            onTap: () {
              safePushReplacementNamed(context, '/setting');
            },
          ),
          ListTile(
            title: const Text('Go Checkout'),
            onTap: () {
              safePushReplacementNamed(context, '/setting');
            },
          ),
        ],
      ),
    );
  }
}
