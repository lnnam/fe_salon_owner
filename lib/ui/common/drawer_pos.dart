import 'package:flutter/material.dart';
import 'package:salonapp/constants.dart';
import 'package:salonapp/services/helper.dart';

class AppDrawerPos extends StatelessWidget {
  const AppDrawerPos({super.key});

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
              'Salon POS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Sale'),
            onTap: () {
              safePushReplacementNamed(context, '/pos');
            },
          ),
          ListTile(
            title: const Text('Receipt'),
            onTap: () {
              safePushReplacementNamed(context, '/receipt');
            },
          ),
          ListTile(
            title: const Text('Summary Report'),
            onTap: () {
              safePushReplacementNamed(context, '/report');
            },
          ),
          ListTile(
            title: const Text('Daily Report'),
            onTap: () {
              safePushReplacementNamed(context, '/report-daily');
            },
          ),
        ],
      ),
    );
  }
}
