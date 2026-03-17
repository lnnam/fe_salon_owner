import 'package:flutter/material.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/constants.dart';

class AppDrawerDashboard extends StatelessWidget {
  const AppDrawerDashboard({super.key});

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
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () {
              safePushReplacementNamed(context, '/profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.people_outline),
            title: const Text('Customers'),
            onTap: () {
              safePushReplacementNamed(context, '/customers');
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Setting'),
            onTap: () {
              safePushReplacementNamed(context, '/setting');
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout_outlined),
            title: const Text('Logout'),
            onTap: () {
              logout(context);
            },
          ),
        ],
      ),
    );
  }
}
