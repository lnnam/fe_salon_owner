import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/model/staff.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'service.dart';
import 'summary.dart';

class StaffPage extends StatefulWidget {
  const StaffPage({super.key});

  @override
  StaffPageState createState() => StaffPageState();
}

class StaffPageState extends State<StaffPage> {
  @override
  void initState() {
    super.initState();
    // Pause booking auto-refresh when opening this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.pauseAutoRefresh();
      print('[StaffPage] Opened, auto-refresh paused');
    });
  }

  @override
  void dispose() {
    // Resume booking auto-refresh when closing this page
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.resumeAutoRefresh();
    print('[StaffPage] Closed, auto-refresh resumed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Staffs'),
      ),
      body: FutureBuilder<List<Staff>>(
        future: apiManager.ListStaff(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cannot connect to server. Please check your network or try again later.'),
                  backgroundColor: Colors.red,
                ),
              );
            });
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No staff found'));
          } else {
            final staffList = snapshot.data!;
            return Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: staffList.length,
                itemBuilder: (BuildContext context, int index) {
                  Staff staff = staffList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundImage: getImage(staff.photo),
                          child: getImage(staff.photo) == null
                              ? const Icon(Icons.person)
                              : null,
                        ),
                        title: Text(
                          staff.fullname,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Position: ${staff.position}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          final bookingProvider = Provider.of<BookingProvider>(
                              context,
                              listen: false);
                          final isEditMode = bookingProvider.onbooking.editMode;

                          // Set staff
                          bookingProvider.setStaff(staff.toJson());

                          if (isEditMode) {
                            safePush(context, const SummaryPage());
                          } else {
                            safePush(context, const ServicePage());
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
