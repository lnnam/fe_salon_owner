import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/services/helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:salonapp/model/booking.dart';
import 'package:salonapp/provider/booking.provider.dart';

import 'home.dart';
import 'calendar.dart';   // ⬅️ Replace with actual path
import 'staff.dart';     // ⬅️ Replace with actual path
import 'customer.dart';  // ⬅️ Replace with actual path
import 'service.dart';   // ⬅️ Replace with actual path

class SummaryPage extends StatefulWidget {
  final Booking? booking;

  const SummaryPage({super.key, this.booking});

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool isLoading = false;
  String note = '';

  late String customerKey;
  late String serviceKey;
  late String staffKey;
  late String bookingDate;
  late String bookingTime;
  late String customerName;
  late String staffName;
  late String serviceName;

  @override
  void initState() {
    super.initState();
     final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      // ✅ Set edit mode to true
      bookingProvider.setEditMode(true);
    if (widget.booking != null) {
      final booking = widget.booking!;
      customerKey = booking.customerkey;
      serviceKey = booking.servicekey;
      staffKey = booking.staffkey;
      bookingDate = booking.bookingdate;
      bookingTime = booking.bookingtime;
      customerName = booking.customername;
      staffName = booking.staffname;
      serviceName = booking.servicename;
      note = '';
      bookingProvider.setBookingFromModel(booking);

    } else {
      final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
      final bookingDetails = bookingProvider.bookingDetails;
      customerKey = bookingDetails['customerKey'] ?? '';
      serviceKey = bookingDetails['serviceKey'] ?? '';
      staffKey = bookingDetails['staffKey'] ?? '';
      bookingDate = bookingDetails['date'] ?? '';
      bookingTime = bookingDetails['formattedschedule'] ?? '';
      customerName = bookingDetails['customerName'] ?? 'Unknown';
      staffName = bookingDetails['staffName'] ?? 'Unknown';
      serviceName = bookingDetails['serviceName'] ?? 'Unknown';
      note = bookingDetails['note'] ?? '';
    }
  }

  _addBooking(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final result = await apiManager.AddBooking(
      customerKey,
      serviceKey,
      staffKey,
      bookingDate,
      bookingTime,
      note,
      customerName,
      staffName,
      serviceName,
    );

    setState(() {
      isLoading = false;
    });

    if (result != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Success"),
            content: const Text("Booking Added"),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BookingHomeScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      );
    } else {
      showAlertDialog(
        context,
        'Error : '.tr(),
        'Booking not saved. Contact support!'.tr(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary Booking'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoRow(
              context,
              label: 'Schedule',
              value: '${_formatDate(bookingDate)} at ${_formatTime(bookingTime)}',
              icon: Icons.schedule,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BookingCalendarPage())),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              label: 'Customer Name',
              value: customerName,
              icon: Icons.person,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomerPage())),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              label: 'Staff',
              value: staffName,
              icon: Icons.people,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffPage())),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              context,
              label: 'Service',
              value: serviceName,
              icon: Icons.star,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServicePage())),
            ),
            const SizedBox(height: 12),
            const Text(
              'Note:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter any notes here...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              maxLines: 3,
              onChanged: (value) {
                setState(() {
                  note = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                ElevatedButton(
                  onPressed: isLoading ? null : () => _addBooking(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const BookingHomeScreen()),
                      (route) => false,
                    );
                  },
                  child: const Text(
                    'Cancel Booking',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context,
      {required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$label: $value',
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    try {
      final parsed = DateTime.parse(date);
      return DateFormat('d MMMM').format(parsed); // e.g., 10 April
    } catch (e) {
      return date;
    }
  }

  String _formatTime(String time) {
    try {
      final parsed = DateFormat('HH:mm').parse(time);
      return DateFormat('HH:mm').format(parsed); // 24h format
    } catch (e) {
      return time;
    }
  }
}
