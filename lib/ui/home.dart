import 'package:flutter/material.dart';
import 'package:salonapp/ui/common/drawer_dashboard.dart';
import 'package:salonapp/model/user.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

   // final User user = ModalRoute.of(context)!.settings.arguments as User;

    return Scaffold(
      appBar: AppBar(
        title: Text('Salon APP'),
        iconTheme: IconThemeData(color: Colors.white)
      ),
      drawer: AppDrawerDashboard(),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/dashboard');
          },
          child: Text('Go to dashboard'),
        ),
      ),
    );
  }
}
