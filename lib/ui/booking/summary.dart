import 'package:flutter/material.dart';
import 'package:salonapp/api/api_manager.dart';
import 'package:salonapp/services/helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home.dart';
import 'package:salonapp/model/booking.dart';

class SummaryPage extends StatefulWidget {
  final Booking? booking;

  const SummaryPage({Key? key, this.booking}) : super(key: key);

  @override
  _SummaryPageState createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  bool isLoading = false;
  String note = '';

  _addBooking(BuildContext context) async {
    setState(() {
      isLoading = true;
    });

    final booking = widget.booking;

    if (booking == null) {
      showAlertDialog(context, 'Error'.tr(), 'Booking data is missing.'.tr());
      setState(() {
        isLoading = false;
      });
      return;
    }

    final result = await apiManager.AddBooking(
      booking.customerkey ?? '',
      booking.servicekey ?? '',
      booking.staffkey ?? '',
      booking.bookingdate ?? '',
      booking.bookingtime ?? '',
      note,
      booking.customername ?? '',
      booking.staffname ?? '',
      booking.servicename ?? '',
    );

    setState(() {
      isLoading = false;
    });

    if (result != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Success"),
            content: Text("Booking Added"),
            actions: [
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => BookingHomeScreen()),
                    );
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
      showAlertDialog(
        context,
        'Error : '.tr(),
        'Booking not saved. Contact support!'.tr(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return Scaffold(
      appBar: AppBar(
        title: Text('Summary Booking'),
        backgroundColor: Colors.blue,
      ),
      body: booking == null
          ? Center(child: Text("No booking details provided"))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  _buildInfoRow(
                      'Schedule',
                      '${booking.bookingdate ?? ''} at ${booking.bookingtime ?? ''}',
                      Icons.schedule),
                  SizedBox(height: 12),
                  _buildInfoRow('Customer Name', booking.customername ?? 'Not Available', Icons.person),
                  SizedBox(height: 12),
                  _buildInfoRow('Staff', booking.staffname ?? 'Not Available', Icons.people),
                  SizedBox(height: 12),
                  _buildInfoRow('Service', booking.servicename ?? 'Not Available', Icons.star),
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
                      setState(() {
                        note = value;
                      });
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
        ],
      ),
    );
  }
}
