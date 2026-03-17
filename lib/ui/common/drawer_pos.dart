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
          Container(
            height: 96,
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
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () {
              safePushReplacementNamed(context, '/');
            },
          ),
          ListTile(
            leading: const Icon(Icons.point_of_sale_outlined),
            title: const Text('Sale'),
            onTap: () {
              safePushReplacementNamed(context, '/pos');
            },
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('Receipt'),
            onTap: () {
              safePushReplacementNamed(context, '/receipt');
            },
          ),
          ListTile(
            leading: const Icon(Icons.summarize_outlined),
            title: const Text('Summary Report'),
            onTap: () {
              safePushReplacementNamed(context, '/report');
            },
          ),
          ListTile(
            leading: const Icon(Icons.calendar_view_week_outlined),
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
