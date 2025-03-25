import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:salonapp/provider/booking.provider.dart';

class SummaryPage extends StatelessWidget {
  // Sample booking details, replace with actual data from your app or provider
 

  @override
  Widget build(BuildContext context) {
    final bookingProvider = Provider.of<BookingProvider>(context);
    final bookingDetails = bookingProvider.bookingDetails;
    return Scaffold(
      appBar: AppBar(
        title: Text('Summary Booking'),
        backgroundColor: Colors.blue, // Using blue instead of deep purple
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Schedule Row
            _buildInfoRow('Schedule', bookingDetails['schedule'] ?? 'Not Available', Icons.schedule),
            SizedBox(height: 12),

            // Customer Name Row
            _buildInfoRow('Customer Name', bookingDetails['customerName'] ?? 'Not Available', Icons.person),
            SizedBox(height: 12),

            // Staff Row
            _buildInfoRow('Staff', bookingDetails['staffName'] ?? 'Not Available', Icons.people),
            SizedBox(height: 12),

            // Service Row
            _buildInfoRow('Service', bookingDetails['serviceName'] ?? 'Not Available', Icons.star),
            SizedBox(height: 12),

            // Note Section (Textbox for note)
            Text(
              'Note:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Changed to black for a neutral look
              ),
            ),
            SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'Enter any notes here...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue, width: 2), // Changed border color to blue
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                ),
              ),
              maxLines: 3,
              onChanged: (value) {
                // Handle note change if needed
              },
            ),
            SizedBox(height: 16),

            // Confirm Button (Submit button to finalize the booking)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle confirmation or next step logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Changed to blue
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                ),
                child: Text(
                  'Confirm Booking',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white, ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to build each row with the edit icon on the left and arrow icon on the right
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
            offset: Offset(0, 3), // Position of the shadow
          ),
        ],
      ),
      padding: EdgeInsets.all(12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(
            icon,
            color: Colors.blue, // Changed icon color to blue
          ),
          SizedBox(width: 12), // Space between the icon and the text
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 16, color: Colors.black87),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.blue, // Arrow icon color
            size: 16,
          ),
        ],
      ),
    );
  }
}
