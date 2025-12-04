import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/model/service.dart';
import 'package:salonapp/services/helper.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'calendar.dart'; // Import SchedulePage
import 'summary.dart';

class ServicePage extends StatefulWidget {
  const ServicePage({super.key});

  @override
  ServicePageState createState() => ServicePageState();
}

class ServicePageState extends State<ServicePage> {
  @override
  void initState() {
    super.initState();
    // Pause booking auto-refresh when opening this page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bookingProvider =
          Provider.of<BookingProvider>(context, listen: false);
      bookingProvider.pauseAutoRefresh();
      print('[ServicePage] Opened, auto-refresh paused');
    });
  }

  @override
  void dispose() {
    // Resume booking auto-refresh when closing this page
    final bookingProvider =
        Provider.of<BookingProvider>(context, listen: false);
    bookingProvider.resumeAutoRefresh();
    print('[ServicePage] Closed, auto-refresh resumed');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
      ),
      body: FutureBuilder<List<Service>>(
        future: apiManager.ListServices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No services found'));
          } else {
            final serviceList = snapshot.data!;
            return Container(
              color: Colors.white,
              child: ListView.builder(
                itemCount: serviceList.length,
                itemBuilder: (BuildContext context, int index) {
                  Service service = serviceList[index];
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
                        title: Text(
                          service.name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Price: \$${service.price}',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[600]),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Handle tap on service

                          final bookingProvider = Provider.of<BookingProvider>(
                              context,
                              listen: false);
                          final isEditMode = bookingProvider.onbooking.editMode;

                          // Set staff
                          bookingProvider.setService(service.toJson());

                          if (isEditMode) {
                            safePush(context, const SummaryPage());
                          } else {
                            safePush(context, const BookingCalendarPage());
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
}/* 

class BookingProvider with ChangeNotifier {
  
  final OnBooking _onbooking = OnBooking(staffkey: '', servicekey: '');

  OnBooking get onbooking => _onbooking;

  void setStaff(int staffkey) {
    _onbooking.staffkey = staffkey.toString();
    notifyListeners();
  }

  void setService(String servicekey) {
    _onbooking.servicekey = servicekey;
    notifyListeners();
  }

  String getStaff() {
    return _onbooking.staffkey;
  }

  void setSchedule(DateTime schedule) {
    // _onbooking.schedule = schedule;
    notifyListeners();
  }

  void setCustomerDetails(String name, String email) {
    // _onbooking.customerName = name;
    // _onbooking.customerEmail = email;
    notifyListeners();
  }
} */