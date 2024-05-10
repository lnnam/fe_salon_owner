import 'package:flutter/material.dart';

class Calendar extends StatelessWidget {
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