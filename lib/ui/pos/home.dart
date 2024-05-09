import 'package:flutter/material.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/constants.dart';
import 'package:intl/intl.dart';
import 'package:salonapp/ui/common/drawer_booking.dart';

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