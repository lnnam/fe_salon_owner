import 'package:flutter/material.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/constants.dart';
import 'package:salonapp/ui/customer/customer_list.dart';
import 'package:salonapp/ui/booking/setting.dart';

class AppDrawerDashboard extends StatelessWidget {
  const AppDrawerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            height: 76,
            width: double.infinity,
            color: const Color(COLOR_PRIMARY),
            alignment: Alignment.center,
            child: const Text(
              'Menu',
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
              safePush(
                context,
                const CustomerListPage(),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text('Setting'),
            onTap: () {
              safePush(
                context,
                const SettingPage(),
              );
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
