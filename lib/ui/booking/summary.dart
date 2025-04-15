import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/provider/booking.provider.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/services/helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home.dart'; // Import Home


class SummaryPage extends StatefulWidget {
  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool isLoading = false; // Loading state for the booking process

  // Method to handle booking
      _addBooking(BuildContext context) async {
  setState(() {
    isLoading = true;
  });

  final bookingProvider = Provider.of<BookingProvider>(context, listen: false);
  final bookingDetails = bookingProvider.bookingDetails;

  String customerKey = bookingDetails['customerKey'] ?? '';
  String serviceKey = bookingDetails['serviceKey'] ?? '';
  String staffKey = bookingDetails['staffKey'] ?? '';
  String date = bookingDetails['date'] ?? '';
  String schedule = bookingDetails['schedule'] ?? '';
  String formattedschedule = bookingDetails['formattedschedule'] ?? '';
  
  String note = bookingDetails['note'] ?? '';
  String customerName = bookingDetails['customerName'] ?? '';
  String staffName = bookingDetails['staffName'] ?? '';
  String serviceName = bookingDetails['serviceName'] ?? '';

  dynamic result = await apiManager.AddBooking(
    customerKey, serviceKey, staffKey, date, schedule, 
    note, customerName, staffName, serviceName
  );

  setState(() {
    isLoading = false;
  });

  if (result != null) {
    // Show success dialog with custom-styled button
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Success"),
          content: Text("Booking Added"),
          actions: [
            Center(  // Center the button
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                 // Navigator.pushReplacementNamed(context, '/dashboard'); // Navigate
                  Navigator.push( context,  MaterialPageRoute(
                              builder: (context) => BookingHomeScreen()
                            ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: Text(
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
    // Show error dialog
    showAlertDialog(
      context,
      'Error : '.tr(),
      'Booking not saved. Contact support!'.tr(),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookingDetails = bookingProvider.bookingDetails;

    return Scaffold(
      appBar: AppBar(
        title: Text('Summary Booking'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildInfoRow('Schedule', bookingDetails['formattedschedule'] ?? 'Not Available', Icons.schedule),
            SizedBox(height: 12),
            _buildInfoRow('Customer Name', bookingDetails['customerName'] ?? 'Not Available', Icons.person),
            SizedBox(height: 12),
            _buildInfoRow('Staff', bookingDetails['staffName'] ?? 'Not Available', Icons.people),
            SizedBox(height: 12),
            _buildInfoRow('Service', bookingDetails['serviceName'] ?? 'Not Available', Icons.star),
            SizedBox(height: 12),

            Text(
              'Note:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
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
               // bookingProvider.updateNote(value); // Save the note in provider
              },
            ),
            SizedBox(height: 16),

            Center(
              child: ElevatedButton(
                onPressed: isLoading ? null : () => _addBooking(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Confirm Booking',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: Colors.blue, size: 16),
        ],
      ),
    );
  }
}
